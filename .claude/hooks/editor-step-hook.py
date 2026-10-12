#!/usr/bin/env python3
"""
PostToolUse + Stop + UserPromptSubmit hook for editor mode step tracking.

Reads .codeyam/editor-step.json and prints a reminder about the current step.
Logs each firing to .codeyam/logs/editor-log.jsonl.
If no state file exists, outputs nothing (not in editor mode or between features).
Only fires when CODEYAM_EDITOR_ACTIVE=1 (set by terminal.rs in editor PTY sessions).

Step labels, descriptions, and restrictions are loaded from
.codeyam/cache/step-metadata.json, which is regenerated from
crates/types/src/step.rs by `codeyam-editor editor verify-build`. The
cache is the single source of truth — do not embed step tables here.
If the cache is missing or unreadable, the hook degrades to a
label-less reminder rather than serving stale literals.
"""

import json
import os
import sys
from datetime import datetime, timezone

# `_step_metadata` lives next to this file; add the hook directory to
# sys.path so the shared loader is importable regardless of the cwd
# the hook runner launches from.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _step_metadata import (  # noqa: E402
    cli_command,
    load_step_metadata,
    mode_display_prefix,
    mode_is_build,
    resolve_mode_table,
)


def resolve_mode(state, metadata):
    """Return the workflow mode name and the matching mode table.

    Thin wrapper around the shared `resolve_mode_table` so callers in
    this file keep the original two-tuple return shape."""
    return resolve_mode_table(state, metadata)


def label_signals_user_feedback_phase(label):
    """Return True when the current step is one where late user
    feedback ("can you change X?") commonly arrives — and the agent
    should re-register/re-capture rather than refusing.

    Match keys on the label substring so a manifest reorder doesn't
    drift this gate. Today the slugs that produce these labels are
    `present-live` / `ui-present` / `backend-confirm` / `backend-present`
    (presentation phases), `reconcile` (glossary reconcile), and
    `finalize` (last gate before journal/commit)."""
    if not label:
        return False
    needle = label.strip().lower()
    return any(
        marker in needle
        for marker in ("present", "reconcile", "finalize")
    )


def label_signals_pre_commit_warning(label):
    """Return True when an uncommitted-changes warning is appropriate
    at this step. Fires on labels emitted by the presentation slugs
    (`present-live` / `ui-present` / `backend-confirm` / `backend-present`,
    where the user is seeing the work) and `finalize` (last gate before
    journal/commit)."""
    if not label:
        return False
    needle = label.strip().lower()
    return needle in ("present", "demo", "finalize")


def label_signals_sync_gate(label):
    """Return True at the Pre-Commit Sync step — the one step where a stale
    binary costs a 40-minute-to-two-hour run before anyone finds out.

    Matched on the label rather than the step NUMBER on purpose: the backend
    tail has already shifted once (`split-backend-present-approval-gate` moved
    `pre-commit-sync` from 16 to 17), and a hardcoded number would have gone
    quietly wrong at that commit."""
    if not label:
        return False
    return label.strip().lower() == "pre-commit sync"


# `rebuild-self --check` is documented to return in under a second — it never
# builds, swaps, or restarts. The timeout is a fault bound, not a budget.
_REBUILD_CHECK_TIMEOUT_S = 10


def rebuild_check_verdict(project_dir):
    """Return the `rebuild-self --check` verdict, or "" when unanswerable.

    The read-only probe: it never builds, swaps, or restarts, and prints one of
    `current` / `rebuild-in-flight` / `stale` / `aliases-diverged`, so it is
    safe to run on every turn end at the step that needs it.

    Split from the notice below on the same seam as `wedge_check` /
    `emit_wedge_block` in this file: shelling out and deciding what verdict
    means are different concerns, and the verdict parse is worth reading on its
    own line.

    Every failure collapses to "": an absent or older binary (a fleet
    mid-upgrade) predates the `--check` flag and exits non-zero, and a hook that
    raised would interrupt an otherwise-fine turn."""
    import subprocess as _sp

    try:
        result = _sp.run(
            [cli_command(), "editor", "rebuild-self", "--check"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=_REBUILD_CHECK_TIMEOUT_S,
        )
    except Exception:
        return ""
    if result.returncode != 0:
        return ""
    tail = result.stdout.strip().splitlines()[-1:]
    return tail[0].strip() if tail else ""


def stale_binary_notice(project_dir):
    """Surface a stale installed binary BEFORE the agent launches the sync.

    Returns the notice text, or "" when the binary is current or the question
    cannot be answered.

    Only `stale` is reported. `rebuild-in-flight` means a build is already
    converging on its own, and `aliases-diverged` self-heals at the next
    per-role re-exec — neither is a reason to interrupt the agent here.

    The CLI gate in `pre_commit_sync` is the ENFORCING check; this is only the
    earlier, cheaper word, which is why it degrades to silence rather than to a
    guess."""
    if rebuild_check_verdict(project_dir) != "stale":
        return ""
    return (
        "\n\033[1;31m⚠️  The installed editor binary is out of date.\033[0m\n"
        "   `pre-commit-sync` runs 40 minutes to two hours and would spend all of it "
        "producing a verdict from code this branch has already replaced.\n"
        "   Run this FIRST — it rebuilds the CLI without bouncing the editor server, "
        "so this session stays alive:\n"
        "     codeyam-editor editor rebuild-self --defer-restart"
    )


def log_event(project_dir, event, data=None):
    """Append a JSONL entry to .codeyam/logs/editor-log.jsonl."""
    try:
        logs_dir = os.path.join(project_dir, ".codeyam", "logs")
        os.makedirs(logs_dir, exist_ok=True)
        log_path = os.path.join(logs_dir, "editor-log.jsonl")
        entry = {"ts": datetime.now(timezone.utc).isoformat(), "event": event}
        if data:
            entry.update(data)
        with open(log_path, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


# ── Question-copy observer ─────────────────────────────────────────────
#
# Records what the agent ACTUALLY asked the user, so the question of
# "did the plain-language guidance work?" is answered with evidence
# rather than impression. It is the measurement half of a contract whose
# other half is guidance only: there is deliberately no refusal here and
# no blocking path, because blocking a question the agent has already
# composed costs a full round trip and teaches it that asking is risky —
# and an agent that asks less is a worse outcome than one that asks
# clumsily.
#
# Three properties are load-bearing, and all three are about staying out
# of the way: it never blocks, it never writes to the agent's stream, and
# it swallows every error. A logging failure is not worth one interrupted
# turn.

QUESTION_COPY_LOG = "question-copy.jsonl"

# Seconds to wait for the jargon check before giving up on it. The check
# is a nicety; the record of what was asked is the point, so a slow or
# absent binary costs the flagged terms and nothing else.
JARGON_CHECK_TIMEOUT_S = 3


def _flagged_terms(project_dir, text):
    """Return the jargon terms `check-question-copy` flags in `text`.

    Shells out rather than reimplementing the vocabulary, so the term
    table has exactly ONE home (`plain_language.rs`) and a term added
    there protects this log too. Returns [] on any failure — a missing
    binary, a timeout, a parse error — because a hook that raises is a
    hook that interrupts a turn.

    Note the deliberate absence of `stderr=STDOUT`: under `--format json`
    the editor routes every marker line to stderr, so merging the streams
    is exactly what would break the parse.
    """
    try:
        import subprocess

        proc = subprocess.run(
            [
                cli_command(),
                "editor",
                "check-question-copy",
                text,
                "--format",
                "json",
            ],
            cwd=project_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            timeout=JARGON_CHECK_TIMEOUT_S,
        )
        doc = json.loads(proc.stdout.decode("utf-8", "replace"))
        return [row.get("term") for row in doc.get("entries", [])]
    except Exception:
        return []


# Seconds to wait for the audience recorder. Like the jargon check it is an
# observer: a slow binary costs the automatic save (the step's explicit
# `audience --set` instruction still stands) and never delays the turn more.
AUDIENCE_RECORD_TIMEOUT_S = 3


def _record_audience_answer(project_dir, event_data):
    """Save the answer to the one-time "explain or keep it brief?" question.

    Asking and saving used to be two separate agent actions, and the save
    was the one that got dropped — so the preference stayed unset and the
    question came back. This hands every answered question to
    `audience --record-answer`, which decides in Rust whether it was the
    audience question (the label vocabulary lives beside the step copy that
    defines it) and records the choice. It prints nothing and swallows every
    failure: a hook that raises interrupts the turn.
    """
    try:
        import subprocess

        payload = json.dumps(
            {
                "tool_input": event_data.get("tool_input", {}) or {},
                "tool_response": event_data.get("tool_response"),
            }
        )
        subprocess.run(
            [cli_command(), "editor", "audience", "--record-answer", "-"],
            cwd=project_dir,
            input=payload.encode("utf-8"),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=AUDIENCE_RECORD_TIMEOUT_S,
        )
    except Exception:
        pass


def _log_question_copy(project_dir, event_data, in_cycle=True):
    """Append one line per question asked, to .codeyam/logs/question-copy.jsonl.

    `in_cycle=False` is a question asked outside an editor session. It is
    logged with a null slug and step — the ad-hoc shape — even when a stale
    `editor-step.json` from an earlier cycle is still on disk, because no
    step was in flight when it was asked.

    Written under `.codeyam/logs/` deliberately: that directory is already
    gitignored, so the log needs no new ignore rule and therefore no
    matching entry in `workspace_hygiene`'s LOCAL_ONLY_IGNORES declaration.
    `.codeyam/state/` is NOT ignored wholesale — only its `command-output/`
    subdirectory is — so putting it there would leak the log into commits.
    """
    try:
        tool_input = event_data.get("tool_input", {}) or {}
        questions = tool_input.get("questions", []) or []
        if not questions:
            return

        # Best-effort step context. A question asked outside a cycle (no
        # state file) still gets logged with nulls — those are exactly the
        # ad-hoc questions the contract most needs to see.
        slug = None
        step = None
        try:
            if in_cycle:
                state_path = os.path.join(project_dir, ".codeyam", "editor-step.json")
                with open(state_path, "r") as f:
                    state = json.load(f)
                slug = state.get("slug")
                step = state.get("step")
        except Exception:
            pass

        logs_dir = os.path.join(project_dir, ".codeyam", "logs")
        os.makedirs(logs_dir, exist_ok=True)
        log_path = os.path.join(logs_dir, QUESTION_COPY_LOG)
        now = datetime.now(timezone.utc).isoformat()

        with open(log_path, "a") as f:
            for question in questions:
                text = question.get("question", "") or ""
                options = [
                    option or {} for option in (question.get("options", []) or [])
                ]
                labels = [option.get("label", "") or "" for option in options]
                # Descriptions are recorded index-aligned with the labels:
                # `question-copy-query` judges each option on its label and
                # description together, and descriptions are where
                # identifiers leaked most.
                descriptions = [option.get("description", "") or "" for option in options]
                # Check the labels alongside the question: an option label
                # is a question the user has to answer too, and it is where
                # jargon leaks most.
                f.write(
                    json.dumps(
                        {
                            "ts": now,
                            "slug": slug,
                            "step": step,
                            "header": question.get("header", "") or "",
                            "question": text,
                            "optionLabels": labels,
                            "optionDescriptions": descriptions,
                            "flaggedTerms": _flagged_terms(
                                project_dir,
                                " ".join([text] + labels + descriptions),
                            ),
                        }
                    )
                    + "\n"
                )
    except Exception:
        pass


def _terminal_signal_missing(project_dir, state):
    """Return True if state.step is the terminal step AND the
    completion-signal field is absent from feature-finalized.json.

    Reads `totalSteps` from the marker (written by save_step_state at the
    terminal step). If the marker is absent, this is not a terminal-step
    completion attempt — return False so the hook falls through to the
    normal tracking write. If the marker exists with `featureCompleteSignaledAt`
    set, the gate is satisfied — return False. Otherwise the agent is trying
    to mark the terminal-step task done before `editor feature-complete`
    actually fired — return True so the hook refuses the write.
    """
    try:
        marker_path = os.path.join(project_dir, ".codeyam", "feature-finalized.json")
        if not os.path.exists(marker_path):
            return False
        with open(marker_path, "r") as f:
            marker = json.load(f)
        total = int(marker.get("totalSteps", 0))
        step = int(state.get("step", 0) or 0)
        if total <= 0 or step < total:
            return False
        return not marker.get("featureCompleteSignaledAt")
    except Exception:
        return False


def detect_event():
    """Detect whether this is a PostToolUse, Stop, UserPromptSubmit, or SessionStart hook from stdin."""
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return "unknown", {}
        data = json.loads(raw)
        if data.get("hook_event_name") == "SessionStart":
            return "session_start", data
        if "tool_name" in data:
            return "post_tool_use", data
        elif "stop_hook_active" in data:
            return "stop", data
        elif "prompt" in data:
            return "user_prompt", data
        return "unknown", data
    except Exception:
        return "unknown", {}


# Only genuinely-deferred tools belong here. `AskUserQuestion` is a *resident*
# top-level tool in editor PTY sessions (it is not in the session's deferred
# registry), so a `select:AskUserQuestion` preload was a guaranteed wasted
# round-trip — it either re-fetched an already-available schema or, on harnesses
# where it is not deferred, came back "no matching deferred tools".
#
# The Task* tools are deferred on SOME harnesses and absent from others. This
# comment used to assert they "ARE deferred and must be preloaded", and that
# sentence is what kept the preload unconditional: on the fleet the lookup
# returns nothing every time, so 39 of 39 measured sessions paid a
# guaranteed-empty round-trip and then read ~20 step directives prescribing a
# tool they could not call. Neither answer can be hard-coded — a laptop session
# genuinely needs the preload — so the preload still fires once, and what the
# session OBSERVES is recorded (`taskToolsAvailable` below) and honored from
# then on.
TOOL_LOADING_SELECT_QUERY = "select:TaskCreate,TaskList,TaskUpdate,TaskGet"

# SessionStart preloads one extra tool beyond the gate-step set: `Monitor`,
# for watching a condition the harness will not notify about. Loading its
# schema once up front means the first such call never hits the
# `Monitor`-before-its-schema-is-loaded `InputValidationError` that
# historically triggered a fallback to polling loops. Monitor is NOT how a
# backgrounded long command (refresh-tests, session-finalize, rebuild-self) is
# awaited — that completion notification arrives on its own and
# `editor wait-for` is the same-turn blocking path; see
# `steps/library/fragments/background_wait_block.txt`. It is NOT in the
# per-prompt gate-tool query because it is not a gate-step tool — only the
# session-entry preload needs it.
#
# It is a SEPARATE query from `TOOL_LOADING_SELECT_QUERY`, and that separation
# is load-bearing rather than cosmetic. This was once
# `TOOL_LOADING_SELECT_QUERY + ",Monitor"`, and concatenating them silently
# disabled the capability mechanism above: `Monitor` resolves on every harness,
# so the combined lookup can never come back "no matching deferred tools" and —
# on a harness without the Task* tools — never carries a Task* schema either.
# `_observe_task_tool_capability` saw neither signal, recorded nothing, and
# `task_tools_available()` stayed None for the whole session. Measured across 42
# fleet sessions: the combined query settled the question 0 times out of 42, and
# 12 of those sessions then obeyed a step directive to call `TaskCreate` and hit
# `No such tool available`. Asking the two questions separately is what lets the
# Task* half answer.
SESSION_START_MONITOR_QUERY = "select:Monitor"


# Marker recording the harness session that last received the per-prompt
# tool-loading-protocol injection. Keyed by session_id so the block fires at
# most ONCE per session instead of on every UserPromptSubmit — the wasted
# re-injection the fleet observed on every resumed prompt.
_TOOL_LOADING_MARKER_REL = os.path.join(".codeyam", "state", "tool-loading-injected.json")


def _tool_loading_already_injected(project_dir, session_id):
    """Return True if the tool-loading-protocol was already injected for this
    session. When session_id is absent (older harness payloads that omit it),
    return False so the block still fires — fail-open preserves the pre-one-shot
    behavior rather than silently suppressing the preload for the whole session.
    """
    if not session_id:
        return False
    marker_path = os.path.join(project_dir, _TOOL_LOADING_MARKER_REL)
    try:
        with open(marker_path, "r") as f:
            return json.load(f).get("session_id") == session_id
    except (IOError, json.JSONDecodeError):
        return False


def _mark_tool_loading_injected(project_dir, session_id):
    """Record that this session received the tool-loading-protocol so later
    prompts in the same session skip it. No-op when session_id is absent (the
    fail-open path keeps injecting rather than persisting an unkeyed marker).

    Writes a FRESH document, deliberately dropping any `taskToolsAvailable`
    a previous session recorded. That reset is what lets the editor read the
    field without knowing a session id: whatever value is present always
    belongs to the session currently running."""
    if not session_id:
        return
    marker_path = os.path.join(project_dir, _TOOL_LOADING_MARKER_REL)
    try:
        os.makedirs(os.path.dirname(marker_path), exist_ok=True)
        with open(marker_path, "w") as f:
            json.dump({"session_id": session_id}, f)
    except Exception:
        pass


def _task_tools_available(project_dir):
    """Return what this session observed about the Task* tools: True, False,
    or None for not-yet-known.

    Read unkeyed on purpose. A recorded `True` is cleared by the next
    session's first prompt (`_mark_tool_loading_injected` rewrites the
    document); a recorded `False` deliberately persists, which is what stops
    the fleet paying the empty lookup in every subsequent session. A `False`
    that has gone WRONG — the same project on a harness that does have the
    tools — self-corrects on that session's first ToolSearch, because the
    SessionStart preload is unconditional. Until it does, the session renders
    the `track-step` procedure, which works on every harness.

    Anything unreadable is None, and None behaves exactly as the hook behaved
    before the field existed."""
    marker_path = os.path.join(project_dir, _TOOL_LOADING_MARKER_REL)
    try:
        with open(marker_path, "r") as f:
            value = json.load(f).get("taskToolsAvailable")
    except (IOError, json.JSONDecodeError):
        return None
    return value if isinstance(value, bool) else None


def _record_task_tools_available(project_dir, available):
    """Persist an observation about Task* availability beside the session
    marker. Merges into the existing document so the session id survives; a
    missing or corrupt document is replaced rather than left to poison every
    later read."""
    marker_path = os.path.join(project_dir, _TOOL_LOADING_MARKER_REL)
    try:
        doc = {}
        try:
            with open(marker_path, "r") as f:
                loaded = json.load(f)
            if isinstance(loaded, dict):
                doc = loaded
        except (IOError, json.JSONDecodeError):
            pass
        if doc.get("taskToolsAvailable") is available:
            return
        doc["taskToolsAvailable"] = available
        os.makedirs(os.path.dirname(marker_path), exist_ok=True)
        with open(marker_path, "w") as f:
            json.dump(doc, f)
    except Exception:
        pass


# Substrings that identify a ToolSearch that found nothing, and a Task* call
# the harness refused. Both are the SAME observation — this session has no
# task tool — arriving by two routes, because a harness that hides the tools
# from `ToolSearch` may still surface a call to them as a hard error.
_NO_MATCHING_TOOLS_MARKERS = ("no matching deferred tools",)
_TOOL_UNAVAILABLE_MARKERS = ("no such tool available", "is disabled for this session")

# The step-tracking tools, lowercased for substring matching. ONE tuple feeds
# both the query side (`_looks_like_task_tool_query`) and the response side
# (`_observe_task_tool_capability`), so the set of names a query is recognized
# by can never drift from the set its answer is judged against.
_TASK_TOOL_NAMES = ("taskcreate", "tasklist", "taskupdate", "taskget")


def _looks_like_task_tool_query(query):
    """True when a ToolSearch query is the Task* preload this hook prescribes.

    Matched on the tool NAMES rather than the exact query string so a caller
    that reorders them, or searches for a subset, still settles the question."""
    lowered = (query or "").lower()
    return "select:" in lowered and any(
        name in lowered for name in _TASK_TOOL_NAMES
    )


def _task_tools_in_search_result(blob):
    """True when a Task*-preload response carries a Task* schema, else False.

    Only ever called for a query `_looks_like_task_tool_query` accepted, so the
    question is already narrowed to "did the tools we asked for come back?" —
    which makes the no-Task*-name case an ANSWER (they are absent), not silence.
    Deciding on the names present rather than on the harness's "nothing matched"
    wording is what lets a PARTIAL result settle it: a query that resolved only
    its non-Task* names returns False here instead of going unrecorded.

    The no-match marker stays as a fast path and is checked FIRST, so a response
    that echoes the query back cannot be read as a hit — the echo necessarily
    contains every Task* name the query asked for."""
    if any(marker in blob for marker in _NO_MATCHING_TOOLS_MARKERS):
        return False
    return any(name in blob for name in _TASK_TOOL_NAMES)


def _observe_task_tool_capability(project_dir, tool_name, tool_input, tool_response):
    """Record what a just-finished tool call proves about Task* availability.

    Three signals, in the order they arrive in a real session: a Task* preload
    whose answer carried no Task* schema (False), a Task* call the harness
    refused (False), and a Task* call that worked (True).

    A tool call this function was not asked about — an unrelated `ToolSearch`,
    any non-Task* tool — is not evidence and is ignored; silence must never be
    read as an absence. A Task* preload that came back WITHOUT them is the
    opposite case and must not be mistaken for silence: it is the absence."""
    # Name-check BEFORE serializing: this runs on every PostToolUse, and a
    # `Read` of a large file would otherwise pay a full stringify to learn it
    # is not a tool this function cares about.
    if tool_name != "ToolSearch" and not tool_name.startswith("Task"):
        return
    blob = json.dumps(tool_response, default=str).lower() if tool_response else ""
    if tool_name == "ToolSearch":
        if not _looks_like_task_tool_query((tool_input or {}).get("query")):
            return
        # Either way this is a recorded answer. Recording the positive matters
        # as much as the negative: the SessionStart preload fires every session,
        # so a harness that GAINS the tools re-settles here rather than staying
        # on `track-step` forever.
        _record_task_tools_available(project_dir, _task_tools_in_search_result(blob))
        return
    if any(marker in blob for marker in _TOOL_UNAVAILABLE_MARKERS):
        _record_task_tools_available(project_dir, False)
    else:
        _record_task_tools_available(project_dir, True)


# How long `wedge-check` is allowed to take. It is a directory listing and a
# handful of small reads, plus — only when a command was launched seconds ago —
# a wait of at most 6s for it to get past its pre-flight (the editor's
# `EARLY_BAIL_WAIT_BUDGET`, which must stay below this). Anything approaching
# this is itself a malfunction — and a hook that hung would freeze the very
# turn-end it is instrumenting.
_WEDGE_CHECK_TIMEOUT_SECS = 10


def _wedge_notice(project_dir):
    """Ask the editor whether this turn is ending on something worth saying.

    `wedge-check` composes five verdicts and this call is blind to which one
    came back, deliberately — the hook's job is to put the text in front of the
    agent, and the editor owns what the text says:
      * a background command already FAILED moments ago — typically a
        precondition refusal seconds after launch — so the long wait the turn
        is ending on is not happening;
      * a background task is demonstrably STRANDED — its result is not coming;
      * a background task is HEALTHY but has been running past the reporting
        threshold — waiting is correct, and the user should be told rather than
        left to ask;
      * the turn is ending mid-workflow with NOTHING pending and no question
        outstanding, so nothing will re-invoke the agent;
      * a cycle just CLOSED and no closing question has been asked since, so
        the user was never alerted that the session finished.

    Returns the notice text, or "" for the overwhelmingly common case of
    nothing being wrong. Every failure mode collapses to "" on purpose: the
    binary being absent or old (a fleet mid-upgrade), the command timing out,
    a non-zero exit. This runs on EVERY turn end, so a fault here must cost
    nothing — a backstop that broke ordinary turns would be worse than the
    stall it looks for.

    `wedge-check` exits 0 whether or not it found something, so emptiness is
    the signal and the return code is only a fault check.
    """
    import subprocess as _sp

    try:
        result = _sp.run(
            [cli_command(), "editor", "wedge-check"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=_WEDGE_CHECK_TIMEOUT_SECS,
        )
    except Exception:
        return ""
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def emit_wedge_block(project_dir, event_data):
    """Reopen the turn when `wedge-check` has something to say about its ending.

    Returns True when it emitted a block decision (and the caller must print
    nothing else, because a Stop hook's stdout is parsed as one JSON document).

    Blocking rather than printing is the whole point. Stop-hook stdout on a
    plain exit is transcript decoration the agent never reads, and the agent is
    exactly who has to act: a stranded result means every plan that depends on
    it is void, a healthy long-running task means the USER needs a status line
    only the agent can write, and an idle stop means nothing will re-invoke the
    agent at all. A `block` decision puts the notice in front of the agent and
    reopens the turn, which is the one thing that distinguishes this from the
    launch trigger that could not reach it.

    Four separate guards keep that from becoming a loop, because reopening a
    turn is the one failure mode a Stop hook can inflict that nothing else can:
      * `stop_hook_active` is set by the harness on a turn that a Stop hook
        already reopened, so we never block twice in a row;
      * a task notice is one-shot per task — `claim_unreported` drops a
        `.wedge-reported` marker beside the task output, shared across the two
        task verdicts and the launch trigger, so the same task is announced
        exactly once by any of them;
      * the idle-stop notice is one-shot per workflow step, and stays silent
        entirely whenever a question is outstanding to the user — ending a turn
        on a gate is correct, and talking over the question would be worse than
        the silence this closes;
      * any failure at all is silent, and silence means "do not block".

    Note what is NOT a guard: the wording. Every one of the three notices asks
    the agent to do something — relay, continue, or say what it is blocked on —
    and none of them refuses the stop. A turn-end hook that told an agent it may
    not stop would inflict exactly the failure the guards above exist to avoid.
    """
    if event_data.get("stop_hook_active"):
        return False
    notice = _wedge_notice(project_dir)
    if not notice:
        return False
    print(json.dumps({"decision": "block", "reason": notice}))
    return True


def main():
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())

    # Only run in editor Build sessions — except for the question-copy
    # observer. A question asked in a plain session on a codeyam project
    # (plan authoring through a skill, say) reaches a user exactly as one
    # asked mid-cycle does, and returning here first left the log blind to
    # it: no reviewed VM had a log, because the ad-hoc path never set the
    # flag. `.codeyam/` must exist so a non-codeyam checkout never grows one.
    if not os.environ.get("CODEYAM_EDITOR_ACTIVE"):
        if os.path.isdir(os.path.join(project_dir, ".codeyam")):
            event_type, event_data = detect_event()
            if (
                event_type == "post_tool_use"
                and event_data.get("tool_name") == "AskUserQuestion"
            ):
                _log_question_copy(project_dir, event_data, in_cycle=False)
                _record_audience_answer(project_dir, event_data)
        return

    state_path = os.path.join(project_dir, ".codeyam", "editor-step.json")
    prompt_path = os.path.join(project_dir, ".codeyam", "editor-user-prompt.txt")

    metadata = load_step_metadata(project_dir)
    event_type, event_data = detect_event()

    # ── SessionStart: fires before any state file may exist. Remind Claude
    # to preload the tools every editor step depends on. Silent when
    # CODEYAM_EDITOR_ACTIVE is unset (handled by the early return above).
    if event_type == "session_start":
        print("<session-start-hook>")
        print(
            "Before your first turn, make TWO SEPARATE `ToolSearch` calls — they ask "
            "two different questions and a combined query answers neither:\n"
            f"  1. `{TOOL_LOADING_SELECT_QUERY}` — the editor workflow's step-tracking "
            "tools. If this returns `no matching deferred tools`, this harness does not "
            "have them; that is a normal answer, it is recorded, and the workflow will "
            "stop asking you for them and use `codeyam-editor editor track-step` instead. "
            "Do NOT widen this query with other tool names — a name that resolves "
            "everywhere masks the very absence this call exists to detect.\n"
            f"  2. `{SESSION_START_MONITOR_QUERY}` — loads `Monitor`'s schema before any "
            "call that needs it; a Monitor invoked without its schema fails with "
            "`InputValidationError`.\n"
            "Monitor is for watching a CONDITION the harness will "
            "not notify you about; a backgrounded long command (refresh-tests, "
            "session-finalize) is not that — its completion notification arrives on its "
            "own, and `codeyam-editor editor wait-for` is the same-turn blocking path. "
            "(AskUserQuestion is already resident in editor sessions, so it needs no "
            "preload.)"
        )
        print("</session-start-hook>")
        return

    # ── Capture user's feature request prompt ──────────────────────────
    if event_type == "user_prompt":
        prompt_text = event_data.get("prompt", "").strip()
        if prompt_text and not prompt_text.startswith("/"):
            should_capture = not os.path.exists(prompt_path)
            if not should_capture:
                if not os.path.exists(state_path):
                    should_capture = True
                else:
                    try:
                        with open(state_path, "r") as f:
                            prev = json.load(f)
                        _, prev_table = resolve_mode(prev, metadata)
                        if prev.get("step", 0) >= prev_table["total"]:
                            should_capture = True
                    except Exception:
                        pass
            if should_capture:
                try:
                    os.makedirs(os.path.dirname(prompt_path), exist_ok=True)
                    with open(prompt_path, "w") as f:
                        f.write(prompt_text)
                except Exception:
                    pass

    # ── Record what was actually asked ─────────────────────────────────
    # Placed BEFORE the state-file early return on purpose: a question
    # asked outside a cycle is still a question a user had to answer, and
    # returning first would blind the log to exactly the ad-hoc questions
    # the contract most needs to see. Falls through afterwards — this
    # observer prints nothing and changes no control flow.
    if event_type == "post_tool_use" and event_data.get("tool_name") == "AskUserQuestion":
        _log_question_copy(project_dir, event_data)
        _record_audience_answer(project_dir, event_data)

    if not os.path.exists(state_path):
        # No editor-step.json — a stateless session entry. This is the exact
        # moment the routing decision gets made AND the request is in hand, so
        # name triage as the entry rather than leaving it to a self-judged
        # build-vs-not call made before the request has been read. Advisory,
        # like every other directive this hook emits, and scoped to a real
        # user prompt: slash commands carry their own routing.
        if event_type == "user_prompt":
            entry_prompt = event_data.get("prompt", "").strip()
            if entry_prompt and not entry_prompt.startswith("/"):
                print("<user-prompt-submit-hook>")
                print(
                    "Editor Mode — no cycle in flight. Enter this request at triage, not "
                    "at the build flow: run "
                    f"`{cli_command()} editor step --slug assist-triage --mode assist`. "
                    "Triage classifies the request against a written rubric (and defaults "
                    "to `build` when ambiguous), then hands off to the build flow itself "
                    "when it really is one — so do not judge build-vs-not yourself here."
                )
                print("</user-prompt-submit-hook>")
        # A cycle that just closed has already wiped its step state, but its
        # closing question may still be owed. Gated on the editor's owed
        # marker so an ordinary stateless turn end pays no subprocess.
        if event_type == "stop" and os.path.exists(
            os.path.join(project_dir, ".codeyam", "run", "closing-question-owed.json")
        ):
            emit_wedge_block(project_dir, event_data)
        return

    try:
        with open(state_path, "r") as f:
            state = json.load(f)
    except (json.JSONDecodeError, IOError):
        return

    step = state.get("step")
    feature = state.get("feature", "")
    mode, mode_table = resolve_mode(state, metadata)
    total_steps = mode_table["total"]
    step_labels = mode_table["labels"]
    step_restrictions = mode_table["restrictions"]
    label = step_labels.get(step, "Unknown")
    mode_prefix = mode_display_prefix(mode)

    if not step:
        return

    # ── Task tracking ──────────────────────────────────────────────────
    task_tracking_path = os.path.join(project_dir, ".codeyam", "editor-task-tracking.json")

    if event_type == "post_tool_use":
        tool_name = event_data.get("tool_name", "")
        tool_input = event_data.get("tool_input", {}) or {}
        # Settle, once per session, whether this harness has the Task* tools
        # at all. Separate from the step-tracking flags below and deliberately
        # unconditional: a Task* call that FAILED still answers this question,
        # even though the flags treat it the same as one that worked.
        _observe_task_tool_capability(
            project_dir, tool_name, tool_input, event_data.get("tool_response")
        )
        # TaskCreate → mark the current step's task as created, provided
        # the subject references this step. If no subject is provided, trust
        # the agent and flip the flag anyway.
        if tool_name == "TaskCreate":
            subject = tool_input.get("subject", "") or ""
            expected_prefix = f"Complete codeyam editor step {step}"
            subject_ok = (not subject) or subject.startswith(expected_prefix)
            if subject_ok:
                try:
                    tracking = {}
                    if os.path.exists(task_tracking_path):
                        with open(task_tracking_path, "r") as f:
                            tracking = json.load(f)
                    tracking["step"] = step
                    tracking["taskCreated"] = True
                    tracking.setdefault("taskCompleted", False)
                    with open(task_tracking_path, "w") as f:
                        json.dump(tracking, f)
                except Exception:
                    pass
        # TaskUpdate with status=completed → mark the current step's task
        # as completed. Only flips the flag if tracking is already on this
        # step (avoids treating unrelated task updates as step check-offs).
        # At the terminal step, the flip is gated on the
        # `featureCompleteSignaledAt` field in feature-finalized.json — the
        # cycle cannot be marked done without `editor feature-complete`
        # having actually fired the modal.
        elif tool_name == "TaskUpdate":
            if tool_input.get("status") == "completed":
                if _terminal_signal_missing(project_dir, state):
                    print(
                        "Cannot mark the feature-complete step task as done — "
                        f"`{cli_command()} editor feature-complete` has not run yet. "
                        "Run that command first; it writes the "
                        "`featureCompleteSignaledAt` marker that closes the cycle.",
                        file=sys.stderr,
                    )
                else:
                    try:
                        if os.path.exists(task_tracking_path):
                            with open(task_tracking_path, "r") as f:
                                tracking = json.load(f)
                            if tracking.get("step") == step and tracking.get("taskCreated"):
                                tracking["taskCompleted"] = True
                                with open(task_tracking_path, "w") as f:
                                    json.dump(tracking, f)
                    except Exception:
                        pass

    # Log the hook firing
    log_data = {"step": step, "label": label, "feature": feature, "hook": event_type}
    if event_type == "post_tool_use":
        log_data["tool"] = event_data.get("tool_name", "")
    log_event(project_dir, "hook", log_data)

    restriction = step_restrictions.get(step, "")
    _cli = cli_command()
    # In-cycle, the next step is simply the next step. At the END of a cycle
    # the next USER REQUEST is not necessarily a build, so route it through
    # triage rather than booting the build flow: "deploy it and give me the
    # live URL" is a config/hosting request that a `step 1` fallback drags
    # through the whole 28-step UI workflow. `assist-triage` classifies it and
    # hands off to the build flow itself when it really is one.
    next_cmd = (
        f"{_cli} editor step {step + 1}"
        if total_steps and step < total_steps
        else f"{_cli} editor step --slug assist-triage --mode assist"
    )

    # ── UserPromptSubmit: inject step context ──────────────────────────
    if event_type == "user_prompt":
        lines = [
            '<user-prompt-submit-hook>',
            f'Editor Mode — {mode_prefix} Step {step}/{total_steps} ({label}): "{feature}"',
        ]

        # One-shot per session: the tool-loading-protocol is a session-entry
        # concern, not a per-prompt one. Injecting it on every UserPromptSubmit
        # re-fired the wasted preload round-trip on every resumed prompt, so gate
        # it behind a session_id-keyed marker and emit it at most once per session.
        # A session that already looked and found nothing must not be told to
        # look again. This is the belt to the one-shot marker's braces: when
        # the harness payload omits session_id the marker fails open and
        # re-injects on EVERY prompt, which is the shape the fleet measured.
        session_id = event_data.get("session_id")
        if (
            not _tool_loading_already_injected(project_dir, session_id)
            and _task_tools_available(project_dir) is not False
        ):
            lines.extend([
                '',
                '<tool-loading-protocol>',
                f"If the Task tools (`TaskCreate`, `TaskList`, `TaskUpdate`, `TaskGet`) "
                f"are not loaded yet, call `ToolSearch` with `{TOOL_LOADING_SELECT_QUERY}` "
                "before your first tool call. The editor workflow routes every step "
                "hand-off through these Task tools; skipping this preload stalls the step. "
                "(AskUserQuestion is already resident, so it needs no preload.)",
                '</tool-loading-protocol>',
            ])
            _mark_tool_loading_injected(project_dir, session_id)

        # Inject editor-mode-context.md directly so Gemini doesn't have to read it blindly
        context_path = os.path.join(project_dir, ".codeyam", "editor-mode-context.md")
        try:
            if os.path.exists(context_path):
                with open(context_path, "r") as f:
                    lines.append("\n<editor-mode-context>")
                    lines.append(f.read().strip())
                    lines.append("</editor-mode-context>\n")
        except Exception:
            pass

        # Include active scenario context
        active_scenario_path = os.path.join(project_dir, ".codeyam", "active-scenario.json")
        try:
            with open(active_scenario_path, "r") as f:
                active = json.load(f)
            scenario_name = (
                active.get("scenarioName")
                or active.get("scenarioSlug", "").replace("_", " ")
            )
            if scenario_name:
                lines.append(
                    f'The user is currently viewing scenario: "{scenario_name}". '
                    "Assume any feedback refers to this scenario unless they say otherwise."
                )
        except (IOError, json.JSONDecodeError):
            pass

        if label_signals_user_feedback_phase(label):
            lines.append(
                "If the user is requesting changes (even indirectly), "
                "make the changes, re-register affected scenarios, and update the journal. "
                "Then continue from the current step."
            )
        elif mode_is_build(mode):
            lines.append(
                f"You are on step {step}. Follow the `{_cli} editor` workflow. "
                f"Do NOT skip ahead or make changes outside the current step."
            )
        else:
            # A non-build track (assist, design) is not walking a build to
            # completion, so "do not skip ahead" asserts something untrue
            # about the session on every single prompt — the exact framing
            # these tracks exist to avoid. Point at the current step without
            # claiming the session is mid-build.
            lines.append(
                f"You are on step {step} of the `{mode}` track. "
                f"Follow the `{_cli} editor` steps for this track."
            )
        if restriction:
            lines.append(restriction)
        lines.append('</user-prompt-submit-hook>')
        print("\n".join(lines))
        return

    # ── Stop: the turn-end backstop, now covering three verdicts ───────
    # The detector itself has always been correct; its only trigger was the
    # launch of a wrapped command, which an agent parked on a result it cannot
    # get never performs. So the backstop could only rescue an agent that did
    # not need rescuing. This is the reachable trigger: the end of the turn IS
    # the moment parking happens, and it needs no suspicion and no agent action.
    #
    # Reachability was necessary and not sufficient. The scan behind it reported
    # only demonstrably-STRANDED tasks, so a task that was merely slow kept its
    # heartbeat ticking and the turn ended in the identical silence — 11 parked
    # turns and 14.9 h of dead time across six VMs, every one ended by a human
    # asking rather than by the system saying. A third shape sat beside it: nine
    # turns that ended right after announcing the next step with nothing pending
    # at all. Same channel, same subprocess, same "empty means nothing wrong";
    # what changed is that healthy-but-slow and idle-stop now have a verdict too.
    if event_type == "stop" and emit_wedge_block(project_dir, event_data):
        return

    # ── Stop: show progress tracker ────────────────────────────────────
    lines = [
        f'Editor Mode — {mode_prefix} Step {step}/{total_steps} ({label}): "{feature}"',
    ]
    if restriction:
        lines.append(restriction)

    if event_type == "stop":
        GREEN = "\033[32m"
        BOLD_CYAN = "\033[1;36m"
        DIM = "\033[2m"
        RESET = "\033[0m"

        tracker = [f"{DIM}  ┌──────────────────────────────────────┐{RESET}"]
        for i in range(1, total_steps + 1):
            lbl = step_labels.get(i, f"Step {i}").ljust(28)
            num = f" {i}" if i < 10 else f"{i}"
            content = f"{num}. {lbl}"
            if i < step:
                tracker.append(f"{DIM}  │{RESET}{GREEN}  ✓  {content}{RESET}{DIM}│{RESET}")
            elif i == step:
                tracker.append(f"{DIM}  │{RESET}{BOLD_CYAN}  →  {content}{RESET}{DIM}│{RESET}")
            else:
                tracker.append(f"{DIM}  │  ○  {content}│{RESET}")
        tracker.append(f"{DIM}  └──────────────────────────────────────┘{RESET}")

        lines.append("Present this progress tracker to the user (copy verbatim):")
        lines.extend(tracker)
        lines.append(
            "For the CURRENT step (→), show each checklist item with "
            "✓ (done) or ✗ (skipped + reason)."
        )

    if event_type == "stop" and label_signals_pre_commit_warning(label):
        import subprocess as _sp
        try:
            _result = _sp.run(
                ["git", "status", "--porcelain"],
                cwd=project_dir,
                capture_output=True, text=True, timeout=5
            )
            has_uncommitted = bool(_result.stdout.strip())
        except Exception:
            has_uncommitted = False

        if has_uncommitted:
            lines.append(
                "\n\033[1;31m⚠️  You have uncommitted changes.\033[0m"
            )

    # Stale-binary pre-flight for the sync gate. Deliberately here, at the turn
    # end that lands the agent ON the step, rather than after it has launched a
    # multi-hour run: one session saw the drift 60 seconds in and recorded that
    # it had no way to act on it. The CLI gate refuses too, but a refusal costs
    # a round trip this notice does not.
    if event_type == "stop" and label_signals_sync_gate(label):
        _stale = stale_binary_notice(project_dir)
        if _stale:
            lines.append(_stale)

    if event_type == "stop":
        lines.append(
            f"\n\033[2mReminder: Follow `{_cli} editor step` workflow.\033[0m"
        )

    lines.append(f"When this step is complete, run: {next_cmd}")

    # PostToolUse: only print for significant tools
    if event_type == "post_tool_use":
        tool_name = event_data.get("tool_name", "")
        if tool_name in ("Bash", "Write", "Edit"):
            if restriction:
                print(f"[Step {step}: {label}] {restriction}")
            return

    if event_type == "stop":
        print("\n".join(lines))


if __name__ == "__main__":
    main()
