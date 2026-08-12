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
from _step_metadata import cli_command, load_step_metadata, resolve_mode_table  # noqa: E402


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
# where it is not deferred, came back "no matching deferred tools". The Task*
# tools ARE deferred and must be preloaded before the first step hand-off.
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
SESSION_START_SELECT_QUERY = TOOL_LOADING_SELECT_QUERY + ",Monitor"


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
    fail-open path keeps injecting rather than persisting an unkeyed marker)."""
    if not session_id:
        return
    marker_path = os.path.join(project_dir, _TOOL_LOADING_MARKER_REL)
    try:
        os.makedirs(os.path.dirname(marker_path), exist_ok=True)
        with open(marker_path, "w") as f:
            json.dump({"session_id": session_id}, f)
    except Exception:
        pass


def main():
    # Only run in editor Build sessions
    if not os.environ.get("CODEYAM_EDITOR_ACTIVE"):
        return

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
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
            f"Call `ToolSearch` with `{SESSION_START_SELECT_QUERY}` before your first "
            "turn so the editor workflow's Task* step-tracking tools are available when "
            "step-task tracking needs them, and `Monitor`'s schema is loaded before any "
            "call that needs it — a Monitor invoked without its schema fails with "
            "`InputValidationError`. Monitor is for watching a CONDITION the harness will "
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

    if not os.path.exists(state_path):
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
    mode_prefix = "Backend Flow" if mode == "backend" else "UI Flow"

    if not step:
        return

    # ── Task tracking ──────────────────────────────────────────────────
    task_tracking_path = os.path.join(project_dir, ".codeyam", "editor-task-tracking.json")

    if event_type == "post_tool_use":
        tool_name = event_data.get("tool_name", "")
        tool_input = event_data.get("tool_input", {}) or {}
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
    next_cmd = (
        f"{_cli} editor step {step + 1}"
        if total_steps and step < total_steps
        else f"{_cli} editor step 1"
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
        session_id = event_data.get("session_id")
        if not _tool_loading_already_injected(project_dir, session_id):
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
        else:
            lines.append(
                f"You are on step {step}. Follow the `{_cli} editor` workflow. "
                f"Do NOT skip ahead or make changes outside the current step."
            )
        if restriction:
            lines.append(restriction)
        lines.append('</user-prompt-submit-hook>')
        print("\n".join(lines))
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
