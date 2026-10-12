#!/usr/bin/env python3
"""
PreToolUse hook for editor mode — blocks tool execution outside allowed slugs.

Reads `.codeyam/editor-step.json` for the active slug and
`.codeyam/cache/step-metadata.json` for the per-slug capability
allowlists, then blocks:
- Write/Edit to non-`.codeyam/`, non-`.claude/` files at slugs that
  don't carry the code-change capability.
- Bash `git commit` / `git add` outside slugs in `commitSlugs`.
- Bash `git push` outside slugs in `pushSlugs`.
- Bash test runs (`refresh-tests` / raw runners) at slugs NOT in
  `testRunSlugs` — every phase whose `test_scope` is `none`. Pre-Demo
  slugs are blocked to hold the prototype-speed "no tests before Demo"
  boundary; post-hardening slugs (presentation, journal, sync, commit,
  push) are blocked because a test run is out of scope at a gate. The
  `noTestSlugs` projection says which kind a slug is, so the refusal
  names a recovery that actually exists at that position.
- AskUserQuestion at slugs in `previewRequiredSlugs` unless
  `.codeyam/preview-shown.json` matches the current step.

One rule is deliberately NOT step-scoped: the scripted-source-rewrite
guard. CLAUDE.md's ban on machine-rewriting tracked source holds in
every session, editor mode or not, so that guard runs before the
`CODEYAM_EDITOR_ACTIVE` short-circuit in `main`.

The slug allowlists are projected into the cache by
`crates/codeyam-editor/src/commands/editor/slug_capabilities.rs` (the
single source of truth for per-slug capabilities), so a future
workflow renumbering never silently breaks a gate.

The Plan-tab PTY does not set `CODEYAM_EDITOR_ACTIVE`, so this hook is
silent there by design — Plan-tab commits are always allowed.

Returns exit code 2 to block, 0 to allow. Stderr is fed back to
Claude as feedback, and every refusal carries an `Evidence:` line
stating what was actually observed — the resolved project dir, the
file consulted, expected versus found — so a block is debuggable
without reading this source.

Heredoc bodies are elided before any command is lexed
(`elide_heredoc_bodies`): a commit-message body is data by shell
semantics, and lexing one as shell turned backticked code spans into
commands and a single apostrophe into an unterminated quote that
failed four guards closed at once.

Run with `--explain` to get the verdict and its evidence on STDOUT at
exit 0, changing nothing: it records no repeat fingerprint and never
writes to stderr. The flag is read from argv only — never from the
environment or the event — so nothing on the enforcement path can
reach it.
"""

import json
import os
import re
import shlex
import subprocess
import sys
import time

# `_step_metadata` lives next to this file; add the hook directory to
# `sys.path` so the import works regardless of the cwd the hook runner
# launches from.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _step_metadata import cli_command, load_step_metadata, resolve_mode_table  # noqa: E402

# Plan files live here and are always commitable regardless of current step.
PLAN_PATH_PREFIX = ".codeyam/plans/"


def staged_paths_are_plans_only(project_dir):
    """True iff `git diff --cached --name-only` is non-empty and every path
    starts with `.codeyam/plans/`. An empty staged set returns False — the
    commit would be a no-op and the existing error path is more useful."""
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=2,
        )
    except Exception:
        return False
    if result.returncode != 0:
        return False
    lines = [l for l in result.stdout.splitlines() if l.strip()]
    if not lines:
        return False
    return all(l.startswith(PLAN_PATH_PREFIX) for l in lines)


def git_add_paths_are_plans_only(command):
    """True iff a `git add` command targets only paths under .codeyam/plans/.

    Conservatively rejects any flag-like arg (-A/--all, -p/--patch,
    -i/--interactive, etc.) and a bare "." pathspec, since we cannot infer
    the eventual staged set in those cases."""
    tokens = command.split()
    try:
        add_idx = tokens.index("add")
    except ValueError:
        return False
    args = tokens[add_idx + 1:]
    if not args:
        return False
    for tok in args:
        if tok.startswith("-") or tok == ".":
            return False
    return all(p.startswith(PLAN_PATH_PREFIX) for p in args)


def merge_in_progress(project_dir):
    """True while a rebase, merge, or cherry-pick is paused mid-operation.

    Staging a conflict resolution is not the same act as creating a commit, but
    both spell `git add`. `pre-commit-sync` starts a rebase and, on a
    modify/delete conflict in the regenerated test-cache blobs, prints a
    recovery that ends in `git add -- <path>` — which the commit-slug gate then
    refused, wedging the very step that printed it. The gate was always this
    broad; it only became reachable once the hook's exit code stopped being
    swallowed. `git commit` stays gated regardless, so this cannot land a commit
    outside the commit slug — it only lets an in-flight rebase be finished."""
    git_dir = os.path.join(project_dir, ".git")
    return any(
        os.path.exists(os.path.join(git_dir, marker))
        for marker in ("rebase-merge", "rebase-apply", "MERGE_HEAD", "CHERRY_PICK_HEAD")
    )


def _slug_label(state, slug):
    """Human-readable identifier for BLOCKED messages. Slug is the
    primary handle; label is shown alongside when state carries it."""
    label = state.get("label", "") or ""
    if label:
        return f"{label} (slug={slug})"
    return f"slug={slug}"


def _commit_gate_phrase(commit_slugs):
    """Name the slug(s) a refusal should steer the agent toward, rendered
    for prose ("`commit`", "`assist-wrap`", "`a` / `b`").

    Derived from the active mode's own `commitSlugs` rather than written
    out, because the literal `commit` is the BUILD flow's gate. An assist
    session's one approval gate is `assist-wrap`, so a hard-coded
    "advance until the `commit` slug" told that session to walk toward a
    slug its 4-step track does not contain. For the build flow the set is
    `["commit"]` and this renders exactly the previous wording."""
    slugs = sorted(s for s in (commit_slugs or []) if isinstance(s, str))
    if not slugs:
        return "`commit`"
    return " / ".join(f"`{s}`" for s in slugs)


_REFUSAL_LOG = os.path.join(".codeyam", "state", "refusal-fingerprints.json")

# How long a refusal stays "recent" for repeat detection. Long enough to
# span the retry loops seen in the transcripts (four blocks inside 65
# seconds, two of them one second apart), short enough that a genuine
# return to the same slug an hour later is not scolded as a repeat.
_REPEAT_WINDOW_SEC = 600

# Cap on retained fingerprints. This is a debounce hint, not durable
# state — an unbounded file would grow for the life of the branch.
_REFUSAL_LOG_MAX = 40

# How many times a RULE must have been refused — ever, across sessions and
# across differing arguments — before its block announces itself as a
# recurring trap. Three, because the measured shape is one refusal per
# session (the journal-timestamp guard fired in five separate sessions,
# exactly once in each), so by the third the agent is rediscovering
# something the project already documents.
_RULE_RECURRENCE_MIN = 3

# Cap on the per-rule aggregate. Unlike `entries` this half IS durable — it
# has to outlive the session to see a cross-session repeat at all — so what
# bounds it is the hook's closed set of rule names, not a time window.
_RULE_LOG_MAX = 64


def _ordinal(n):
    """`3` -> "3rd". Pure, so the 11/12/13 exceptions are assertable
    without emitting a refusal."""
    if n % 100 in (11, 12, 13):
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
    return f"{n}{suffix}"


def _capped_rules(rules):
    """The per-rule aggregate trimmed to the most recently seen rules.

    The map is keyed on the hook's own closed set of rule names, so it is
    already small in practice. The cap makes boundedness a property of the
    file rather than of the caller — a rule name that ever becomes dynamic
    must not be able to grow this file for the life of the branch.
    """
    if len(rules) <= _RULE_LOG_MAX:
        return rules
    ordered = sorted(rules.items(), key=lambda kv: kv[1].get("lastAt", 0))
    return dict(ordered[-_RULE_LOG_MAX:])


def _load_refusal_log(path, now):
    """Read the refusal log at `path` as `(entries, rules)`.

    `entries` is the windowed fingerprint list with everything older than
    `_REPEAT_WINDOW_SEC` already dropped; `rules` is the durable per-rule
    aggregate. Malformed rows are discarded individually rather than
    condemning the whole file, so one bad entry cannot reset every count.

    A bare JSON list is the pre-`rules` shape. Reading it as `entries`
    keeps an existing log's debounce working across the upgrade instead
    of silently resetting every count to 1 the first time a refusal is
    recorded by a newer hook.

    Unreadable, absent, or corrupt degrades to `([], {})` — which renders
    exactly today's message — because this only decorates a refusal that
    is being emitted anyway and must never turn one into a crash.
    """
    try:
        with open(path) as f:
            loaded = json.load(f)
    except Exception:
        return [], {}

    raw_entries = loaded.get("entries") if isinstance(loaded, dict) else loaded
    raw_rules = loaded.get("rules") if isinstance(loaded, dict) else None

    entries = []
    if isinstance(raw_entries, list):
        entries = [
            e
            for e in raw_entries
            if isinstance(e, dict)
            and isinstance(e.get("at"), (int, float))
            and now - e["at"] <= _REPEAT_WINDOW_SEC
        ]

    rules = {}
    if isinstance(raw_rules, dict):
        rules = {
            name: agg
            for name, agg in raw_rules.items()
            if isinstance(agg, dict) and isinstance(agg.get("count"), int)
        }

    return entries, rules


def _record_refusal(project_dir, fingerprint, rule=None, now=None):
    """Record a refusal and return `(call_count, rule_count)`, both
    INCLUDING this one. `(1, 1)` means a first refusal on either tier.

    Two tiers, two windows, deliberately. `call_count` counts this exact
    `fingerprint` inside `_REPEAT_WINDOW_SEC` — the retry loop, where the
    agent re-issues a call that was just refused. `rule_count` counts
    `rule` with no time filter at all, because the mistake it exists to
    catch has the opposite shape: it recurs ACROSS sessions, with
    different arguments each time, so no windowed count of identical
    calls can ever see it.

    Durable and bounded at once. The `entries` half keeps its window and
    its cap and stays a debounce hint; the per-rule aggregate is keyed on
    the hook's closed set of rule names, so it is bounded by that set
    rather than by how long the branch lives.

    Best-effort by construction: this only decorates a message that is
    being emitted anyway, so an unreadable or unwritable log must never
    turn a clean refusal into a crash. Every failure path returns
    `(1, 1)`, which renders exactly today's message.
    """
    now = time.time() if now is None else now
    # The scripted-rewrite guard fires before the editor-mode short-circuit,
    # so this runs in non-codeyam repos too. Never CREATE `.codeyam/` as a
    # side effect of refusing something — no project state, no repeat log.
    if not os.path.isdir(os.path.join(project_dir, ".codeyam")):
        return 1, 1
    path = os.path.join(project_dir, _REFUSAL_LOG)
    entries, rules = _load_refusal_log(path, now)

    count = sum(1 for e in entries if e.get("fingerprint") == fingerprint) + 1
    entries.append({"fingerprint": fingerprint, "at": now})

    rule_count = 1
    if rule:
        prior = rules.get(rule)
        rule_count = (prior["count"] if prior else 0) + 1
        rules[rule] = {
            "count": rule_count,
            "firstAt": prior.get("firstAt", now) if prior else now,
            "lastAt": now,
        }

    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            json.dump(
                {
                    "entries": entries[-_REFUSAL_LOG_MAX:],
                    "rules": _capped_rules(rules),
                },
                f,
            )
    except Exception:
        pass
    return count, rule_count


def _repeat_notice(count, rule_count=1):
    """The line that leads a repeated refusal, or "" on the first one.

    Two tiers, and the exact-call one wins whenever both apply — it is
    both the more specific and the more urgent statement.

    Agents re-issued identical refused calls within seconds — four in a
    row at `backend-journal`. A block that reads the same the second time
    gives no signal that the state has not moved, so the retry looks as
    reasonable as the first attempt. Saying so explicitly is the cheapest
    thing that distinguishes them.

    The second tier catches the shape the first cannot see at all: one
    refusal per session, across sessions, with different arguments each
    time. Measured across 20 build sessions, guardrails refused 16 times
    and `ALREADY REFUSED` rendered ZERO times, while the
    journal-timestamp guard alone fired in five separate sessions. For an
    agent meeting that rule for the first time the accusatory wording
    would simply be false, and reusing it would train agents to discount
    the line — so this tier is informational: the rule is a known
    recurring trap, and the canonical path below is worth reading once
    rather than rediscovering.
    """
    if count >= 2:
        return (
            f"ALREADY REFUSED ({count}x in the last "
            f"{_REPEAT_WINDOW_SEC // 60} minutes): this exact call was refused "
            f"before and nothing has changed since. Re-issuing it will be "
            f"refused again — take the next valid action above instead.\n"
        )
    if rule_count >= _RULE_RECURRENCE_MIN:
        return (
            f"RECURRING GUARDRAIL ({_ordinal(rule_count)} time in this "
            f"project): this rule has blocked a call {rule_count} times here, "
            f"typically once each in a different session — so it is a known "
            f"recurring trap rather than a first encounter. The next valid "
            f"action above is the canonical path; it is worth reading once "
            f"rather than rediscovering.\n"
        )
    return ""


# Read-only explain mode, set ONCE from argv in `main`. Deliberately not an
# environment variable and not an event field: both are reachable from the
# enforcement path, and a verdict channel that the thing being judged can
# switch on is not a diagnostic, it is a bypass. argv belongs to whoever
# invokes the hook, which for a real PreToolUse call is Claude Code itself.
_EXPLAIN_MODE = False


def explain_requested(argv):
    """True when `--explain` appears in `argv`.

    Pure, so the one thing that must never be true during enforcement is
    assertable without running the hook."""
    return "--explain" in argv


def _emit_verdict(verdict, rule, detail, message):
    """Print an explain-mode verdict to STDOUT and exit 0.

    stdout, not stderr, is deliberate: stderr is the enforcement channel Claude
    reads as feedback, and an explain run must be inert there. Exit 0 for the
    same reason — `--explain` answers "what would this do", it never does it."""
    lines = [f"VERDICT: {verdict}"]
    if rule:
        lines.append(f"RULE: {rule}")
    if detail:
        lines.append(f"DETAIL: {detail}")
    if message:
        lines.append(message)
    print("\n".join(lines))
    sys.exit(0)


def allow(reason):
    """Allow the in-flight call — exit 0, silently under enforcement.

    Every allow path in `main` funnels through here so `--explain` can report
    WHICH allow fired. Under enforcement this is exactly `sys.exit(0)`; the
    reason string is never printed, so it costs a normal call nothing."""
    if _EXPLAIN_MODE:
        _emit_verdict("ALLOWED", "", "", reason)
    sys.exit(0)


def notice(rule, message):
    """Let the call through, but say something first — exit 0 with the text on
    stderr.

    The middle verdict between `allow` and `block`, for a call that is safe but
    costs the caller something they should know about. It is deliberately NOT a
    refusal: there is no `Next valid action:` contract to satisfy, because
    nothing needs recovering.

    stderr rather than stdout, and no JSON permission decision: an exit-0 hook
    that prints a `permissionDecision` would also be *granting* permission for
    the call, which is a much bigger claim than "here is a pointer" and would
    silently bypass a prompt the user might otherwise see."""
    if _EXPLAIN_MODE:
        _emit_verdict("NOTICE", rule, "", message)
    print(message, file=sys.stderr)
    sys.exit(0)


def block(project_dir, rule, reason, next_action, reference="", detail="", evidence="", call=""):
    """Emit a phase-gate refusal on the two-line contract and exit 2.

    Every refusal this hook emits goes through here, which is what makes
    `BLOCKED:` / `Next valid action:` an enforced contract rather than a
    documented convention — a new gate cannot ship without a recovery,
    because there is no other way to refuse. `reference` carries material
    the agent may want AFTER it knows what to do (the list of permitted
    slugs, the rationale); it never substitutes for `next_action`.

    `evidence` states what the hook actually OBSERVED — the resolved
    project dir, the file it consulted, expected versus found. It changes
    no verdict. Without it the only way to debug a refusal is to read this
    source, which is what agents did: one spent ~10 tool calls grepping
    this file to discover its own cwd had drifted, a fact the refusal held
    and did not print.

    The repeat fingerprint is `rule` + `detail` + the actual `call` + the
    evidence. Including the call is what stops three DIFFERENT commands
    refused under one rule from escalating to "this exact call was refused
    before" — a false statement that punished an agent for varying its
    approach. Including the evidence resets the counter when the consulted
    state genuinely changed, so a corrective action is no longer scolded as
    a repeat.

    The reason carries a leading `guardrail, not a breakage —` clause because
    the agent is not the only reader. Every one of these refusals is rendered
    into the client's Build tab in red, and a bare `BLOCKED: this pipes a
    gating command into a filter` reads to a watching human as the system
    falling over, when it is in fact the system doing precisely its job. On
    the sessions that were measured, 13 of 71 red results were guardrails
    working exactly as designed. The clause is deliberately INSIDE the reason
    rather than on a line above it, so the `BLOCKED: ` first-token contract
    that agents and `is_recovery_contract` grep for is left untouched.

    The text is laid out by `refusal_text` — action first, evidence last,
    and a repeat collapsed to two lines; see there for why.
    """
    if _EXPLAIN_MODE:
        _emit_verdict(
            "BLOCKED", rule, detail, refusal_text(reason, next_action, reference, evidence)
        )
    count, rule_count = _record_refusal(
        project_dir, "\x00".join((rule, detail, call, evidence)), rule
    )
    # The leading newline is for the harness, which prints
    # `PreToolUse:<Tool> hook error: [<the hook's whole shell command>]: `
    # immediately before this text. Without it the action is glued to the
    # end of ~130 characters of plumbing; with it, the action starts a line.
    print(
        "\n" + refusal_text(reason, next_action, reference, evidence, count, rule_count),
        file=sys.stderr,
    )
    sys.exit(2)


def refusal_text(reason, next_action, reference="", evidence="", count=1, rule_count=1):
    """The refusal as the agent reads it: recovery first, evidence last.

    The harness prefix is the one part of the line the hook cannot control,
    so the hook's own FIRST words are the instruction. The order used to be
    reassurance, cause, action, evidence — and with the action sandwiched,
    agents re-issued the identical refused `Edit` four times in a row at
    `present-live` before reading far enough to run `editor change`, which
    the very first refusal had named.

    A repeat (`count >= 2`) is REPLACED, not prepended to: the action plus a
    one-line `BLOCKED: ALREADY REFUSED …`, with no cause, evidence, or
    reference. The full form was already printed once and nothing has
    changed since (the fingerprint includes the evidence), so re-printing it
    only re-buries the one line that matters under the same wall.

    Both lines of the `BLOCKED:` / `Next valid action:` contract are present
    in both shapes; only their order differs from the CLI's, because a CLI
    error is read from the top of a terminal and this one is read after a
    prefix that eats the first line's attention.
    """
    action = f"Next valid action: {next_action}"
    notice = _repeat_notice(count, rule_count)
    if count >= 2:
        return f"{action}\nBLOCKED: {notice.rstrip()}"
    lines = [action, f"BLOCKED: guardrail, not a breakage — {reason}"]
    if notice:
        lines.append(notice.rstrip())
    if reference:
        lines.append(reference)
    if evidence:
        lines.append(f"Evidence: {evidence}")
    return "\n".join(lines)


def resolved_context(project_dir, consulted=""):
    """The evidence prefix every gate can state: where the hook thinks the
    project is, and which file it read to decide.

    `project_dir` falls back to `os.getcwd()` when `CLAUDE_PROJECT_DIR` is
    unset, so a session whose cwd drifted gets judged against the wrong repo
    and never learns why. Printing it makes that one-line obvious."""
    source = "CLAUDE_PROJECT_DIR" if os.environ.get("CLAUDE_PROJECT_DIR") else "os.getcwd()"
    parts = [f"project dir {project_dir} (from {source})"]
    if consulted:
        parts.append(f"consulted {consulted}")
    return "; ".join(parts)


def _test_run_block_message(state, slug, info):
    """Word the test-run block for `slug` from its phase kind.

    Returns a `(reason, next_action)` pair for `block`, which owns the
    two-line rendering. Returning the parts rather than a finished string
    is what keeps this gate on the same contract as every other one.

    `info` is the slug's `noTestSlugs` entry, or None when the cache
    predates that projection (or dropped the entry as malformed).

    Sixteen phases declare `test_scope: none`, but only five of them —
    plan / confirm / prepare / prototype / demo — are actually pre-Demo. The
    rest (final-presentation, journal, pre-commit-sync, commit, push,
    feature-complete) sit AFTER every test-running phase, so telling an
    agent there that hardening "starts at Deconstruct" and to run tests at
    `*-extract-tdd` names a step it has already passed and cannot reach
    without `editor change`. The block is right at both; only the
    explanation and the named recovery differ."""
    where = _slug_label(state, slug)
    if not info or info.get("kind") != "post-hardening":
        # Pre-Demo, or no projection to judge by. This wording is accurate
        # where it applies, and it is the status-quo degrade where the cache
        # cannot say.
        return (
            f"test runs are not allowed at {where} "
            f"(pre-Demo, test_scope: none). The Plan→Demo stretch is for building "
            f"fast and getting working functionality in front of the user — "
            f"hardening (tests, extraction, glossary) starts at Deconstruct.",
            "keep building — run tests at "
            "`ui-extract-tdd` / `backend-extract-tdd`.",
        )
    next_slug = info.get("nextTestRunSlug")
    if next_slug:
        recovery = (
            f"advance to `{next_slug}` — the next step in this mode where "
            f"test runs are in scope."
        )
    else:
        recovery = (
            "advance — no test-running step remains in this mode, so there is "
            "nowhere left to re-run this."
        )
    return (
        f"test runs are not allowed at {where} "
        f"(test_scope: none). The hardening phases already ran the tests; this "
        f"step is a presentation / commit gate, where a test run is out of "
        f"scope.",
        recovery,
    )


def _preview_hint(mode, project_dir):
    """Hint shown when AskUserQuestion is blocked for missing preview.

    Backend mode never has a live preview — point at the results
    panel instead. UI mode points at `editor preview` with the
    user-configured default screen size."""
    cli = cli_command()
    if mode == "backend":
        return f"{cli} editor show-results"
    default_dim = "Desktop"
    editor_config_path = os.path.join(project_dir, ".codeyam", "editor.json")
    try:
        with open(editor_config_path, "r") as f:
            cfg = json.load(f)
        default_dim = cfg.get("defaultScreenSize", "Desktop")
    except Exception:
        pass
    return f'{cli} editor preview \'{{"dimension":"{default_dim}"}}\''


# Stack-agnostic raw test runners, matched by TOKEN SHAPE rather than by a
# regex over the raw command string, so a runner NAME is only a test run when
# it names the program actually being run. A runner name inside a quoted
# argument is data: `editor change "Fix: missing pytest in the VM image"`,
# `git commit -m "add pytest coverage"`, and `python3 -c "print('refresh-tests')"`
# all mention a runner without invoking one, and a whole-string matcher refused
# every one of them. This is the same command-position discipline
# `_has_inplace_editor` and `_uses_pcre_grep` use — see `_in_command_position`
# and `_split_commands`, defined with the scripted-rewrite guard below.
#
# Runners invoked by bare name: `pytest tests/`, `jest`, `vitest run`.
_TEST_RUNNER_PROGRAMS = frozenset(("pytest", "jest", "vitest"))
# Runners that are a program plus a subcommand — `cargo build` is not a test
# run, `cargo test` is.
_TEST_RUNNER_SUBCOMMANDS = {
    "cargo": frozenset(("test", "nextest")),
    "go": frozenset(("test",)),
}
# `python3 -m pytest` — the module names the runner, not the interpreter. Any
# `python`/`python3`/`python3.12` spelling counts.
_PYTHON_INTERPRETER = re.compile(r"^python[0-9.]*$")
# `refresh-tests` is codeyam's own test command — the one the workflow actually
# uses — and is always a test run when it is the CLI's VERB. As an argument to
# some other verb it is a feature title or a search string, not a run.
_CODEYAM_CLIS = frozenset(("codeyam-editor", "codeyam-editor-dev"))
_CODEYAM_TEST_VERBS = frozenset(("refresh-tests",))
# Shells that run a script named as their argument, so a configured test script
# reached through one is still an invocation of it.
_SCRIPT_INTERPRETERS = frozenset(("bash", "sh", "zsh", "ksh", "dash"))


def _configured_test_scripts(project_dir):
    """Project-specific test-runner SCRIPT invocations derived from
    `testRunners[].command` in editor.json — e.g. `bash scripts/run-shell-tests.sh`.

    Lets the gate catch a raw run of the project's OWN test script, not just
    the stack-agnostic runners above, so the gate is config-aware rather than a
    fixed hardcoded list. Only tokens that look like a script path (`scripts/…`
    or ending in `.sh`) are lifted — that deliberately skips a bare interpreter
    like `python3` in `python3 -m pytest`, which `_invokes_test_runner` already
    covers and which would over-block if treated as a runner."""
    cfg_path = os.path.join(project_dir, ".codeyam", "editor.json")
    scripts = []
    try:
        with open(cfg_path) as f:
            cfg = json.load(f)
    except Exception:
        return scripts
    for runner in cfg.get("testRunners", []) or []:
        cmd = runner.get("command", "") if isinstance(runner, dict) else ""
        for tok in cmd.split():
            if tok.startswith("scripts/") or tok.endswith(".sh"):
                scripts.append(tok)
    return scripts


def _leading_operand(tokens):
    """The first token that is a subcommand rather than an option — the `test`
    in `cargo +nightly test -p codeyam-types`. None when there is none."""
    for tok in tokens:
        if tok.startswith("-") or tok.startswith("+"):
            continue
        return tok
    return None


def _module_target(tokens):
    """The module an interpreter's `-m` flag runs — `pytest` in
    `python3 -m pytest tests/`. None when there is no `-m`."""
    for index, tok in enumerate(tokens):
        if tok == "-m" and index + 1 < len(tokens):
            return tokens[index + 1]
    return None


def _codeyam_verb(tokens):
    """The subcommand verb of a codeyam CLI invocation, skipping options and the
    `editor` subcommand group — `refresh-tests` in `codeyam-editor editor
    refresh-tests --changed`, but `change` in `codeyam-editor editor change
    "Fix: missing pytest in the VM image"`. None when there is no verb."""
    for tok in tokens:
        if tok.startswith("-") or tok == "editor":
            continue
        return tok
    return None


def _invokes_test_runner(tokens):
    """True when the program in command position of one already-split command is
    a test runner, in any of the shapes a runner is actually invoked through:
    bare name, program + subcommand, interpreter + module, or codeyam CLI verb.

    Blind to quoted text by construction — `shlex` has already collapsed each
    quoted region into a single token, so a runner name inside a feature title,
    a commit message, or a string literal can never be the program."""
    for index, tok in enumerate(tokens):
        if not _in_command_position(tokens, index):
            continue
        program = _program_name(tok)
        rest = tokens[index + 1:]
        if program in _TEST_RUNNER_PROGRAMS:
            return True
        if _leading_operand(rest) in _TEST_RUNNER_SUBCOMMANDS.get(program, ()):
            return True
        if _PYTHON_INTERPRETER.match(program) and _module_target(rest) in _TEST_RUNNER_PROGRAMS:
            return True
        if program in _CODEYAM_CLIS and _codeyam_verb(rest) in _CODEYAM_TEST_VERBS:
            return True
    return False


def _shell_c_payload(tokens):
    """The command string a shell is asked to run — `pytest tests/` in
    `bash -c "pytest tests/"`. None when this is not a `-c` invocation.

    Tokenizing alone would read that payload as one opaque argument and let a
    real test run through, so the payload is re-scanned as a command in its own
    right. This is the one place a quoted string IS an invocation."""
    for index, tok in enumerate(tokens):
        if _program_name(tok) not in _SCRIPT_INTERPRETERS:
            continue
        if not _in_command_position(tokens, index):
            continue
        rest = tokens[index + 1:]
        for offset, arg in enumerate(rest):
            if arg == "-c" and offset + 1 < len(rest):
                return rest[offset + 1]
    return None


def _program_name(token):
    """A token reduced to the name it is compared on, so a path-qualified
    invocation matches its bare spelling — `/usr/bin/pytest` is `pytest`, and a
    configured `scripts/run-shell-tests.sh` matches `./scripts/run-shell-tests.sh`."""
    return token.rsplit("/", 1)[-1]


def _invokes_configured_script(tokens, project_dir):
    """True when one of the project's configured test scripts is what this
    command runs — in command position (`./scripts/run-shell-tests.sh`) or as the
    script argument of a shell (`bash scripts/run-shell-tests.sh`).

    Comparing whole tokens is what keeps `git commit -m "fixes
    scripts/run-shell-tests.sh"` allowed: a quoted message is one token, and one
    token is never equal to the script path inside it."""
    scripts = {_program_name(s) for s in _configured_test_scripts(project_dir)}
    if not scripts:
        return False
    for index, tok in enumerate(tokens):
        if _program_name(tok) not in scripts:
            continue
        if _in_command_position(tokens, index):
            return True
        if _program_name(tokens[index - 1]) in _SCRIPT_INTERPRETERS:
            return True
    return False


def is_test_run_command(command, project_dir):
    """True when `command` invokes a test run — a common raw runner, codeyam's
    own `refresh-tests`, or the project's configured test script — False when
    it provably does not, and None when a stage cannot be tokenized.

    Scoped to one command at a time, so a runner in one segment says nothing
    about the next. The caller fails closed on None, so a malformed quote is
    never an evasion path — the same contract `_uses_pcre_grep` carries, and
    split from True for the same reason: an apostrophe in a heredoc comment
    used to be refused as a "test run" it never contained."""
    undecidable = False
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            undecidable = True
            continue
        if _invokes_test_runner(tokens):
            return True
        if _invokes_configured_script(tokens, project_dir):
            return True
        payload = _shell_c_payload(tokens)
        if payload is not None:
            nested = is_test_run_command(payload, project_dir)
            if nested:
                return True
            undecidable = undecidable or nested is None
    return None if undecidable else False


# --- Scripted source-rewrite guard -----------------------------------------
#
# CLAUDE.md bans machine-rewriting tracked source ("never a `python`/regex/
# brace-matching find-and-replace … such scripts parse the language with the
# wrong grammar and self-match the code they just generated"). Documentation
# alone did not hold, so this guard turns the guideline into a refusal that
# names the sanctioned alternatives.
#
# The signature is the SHAPE, not the interpreter: a shell command that both
# computes a text transform in-process AND lands it on a git-tracked source
# file. Inspecting JSON state, running a committed script, and writing to a
# temp/untracked path all stay allowed.

# Suffixes whose files a reviewer reads as a diff, and which must therefore be
# edited with the Edit tool rather than machine-rewritten. Deliberately broad
# and additive across stacks: a language absent from this list is simply not
# guarded, so an unlisted extension degrades to "allow", never to a spurious
# block. `.json` is omitted on purpose — rewriting JSON through a parser is
# structurally sound and is how config edits are legitimately scripted.
SOURCE_SUFFIXES = (
    ".rs", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".py", ".rb", ".go",
    ".java", ".kt", ".swift", ".m", ".mm", ".c", ".h", ".cc", ".cpp", ".hpp",
    ".cs", ".php", ".ex", ".exs", ".sh", ".bash", ".zsh", ".ps1", ".sql",
    ".svelte", ".vue", ".astro", ".css", ".scss", ".html", ".md", ".toml",
    ".yaml", ".yml", ".dart",
)

# Bound the git query so a pathological command cannot spawn a huge argv.
_MAX_PATH_CANDIDATES = 40

# A pathspec we are willing to hand to `git ls-files`. Excludes whitespace and
# `:` (git's pathspec-magic prefix) so an odd token cannot change git's parse.
_PATHSPEC_SAFE = re.compile(r"^[A-Za-z0-9_./*+-]+$")

_OPEN_CALL = re.compile(r"\bopen\s*\(")
# `Path("x").write_text(` yields its literal; a bare `p.write_text(` does not.
_WRITE_TEXT = re.compile(
    r"""(?:Path\s*\(\s*(?P<q>['"])(?P<path>[^'"]+)(?P=q)\s*\)\s*)?\.write_(?:text|bytes)\s*\("""
)
_NODE_WRITE = re.compile(
    r"""writeFile(?:Sync)?\s*\(\s*(?:(?P<q>['"`])(?P<path>[^'"`]+)(?P=q))?"""
)
# `> path` / `>> path`, but not the fd forms (`2>&1`, `>&2`).
_SHELL_REDIRECT = re.compile(r"""(?<![0-9&])>>?\s*(?P<path>[^\s;|&<>()'"]+)""")
# Anything shaped like a path with an extension, wherever it appears. Matching
# the shape directly rather than tokenizing by quotes or whitespace is what
# makes the fallback survive nested quoting — a one-liner like
# `python3 -c "p = 'src/lib.rs'; …"` yields no clean quoted or whitespace token,
# because the inner quotes interleave with the outer ones.
_PATHLIKE = re.compile(r"/?[A-Za-z0-9_][A-Za-z0-9_./*+-]*\.[A-Za-z0-9]+")
# An in-place flag for sed/perl: `-i`, `-i.bak`, `-pi`, `--in-place`. The
# pre-`i` letter class excludes `e`/`E`/`I` so perl's `-Ilib` (a library path,
# not an in-place edit) does not false-match.
_INPLACE_FLAG = re.compile(r"^(?:--in-place(?:=.*)?|-[a-df-hj-zA-DF-HJ-Z0-9]*i.*)$")
# Unquoted characters that end one command and begin another. `||` and `&&` are
# runs of these, so splitting per-character yields an empty middle segment that
# is simply dropped. `(`/`)`/backtick are boundaries too, so a subshell or a
# command substitution is scanned as its own command rather than as an argument.
_COMMAND_SEPARATORS = ";|&\n()`"
# Tokens that may precede a program without changing which program runs, so an
# in-place edit reached through one is still an in-place edit. `find … -exec sed
# -i … {} \;` and `xargs sed -i …` are the most natural ways to rewrite a tree
# in bulk; requiring `sed` to be literally first would have unblocked them.
_COMMAND_PREFIXES = frozenset(
    (
        "sudo", "env", "xargs", "time", "nohup", "command", "exec", "nice",
        "ionice", "stdbuf", "-exec", "-execdir", "then", "do", "else", "{",
        # `npx vitest run` runs `vitest` — the launcher resolves the binary
        # without changing which program it is.
        "npx",
    )
)
# `LC_ALL=C sed -i …` — a leading assignment is a prefix, not the program.
_ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
# grep short options that consume the rest of their cluster as a value, so a
# `P` following one is that value (`grep -eP` searches for the text "P") rather
# than the PCRE flag.
_GREP_VALUE_FLAGS = frozenset("efmABCDd")

# The `codeyam-editor editor` subcommands that may not be piped into a filter.
# Keep in sync with the CLAUDE.md "CLI error conventions" section, under "Do not
# pipe gating or long-running `codeyam-editor` commands through `tail` / `grep`
# / `head`".
#
# Deliberately NOT every subcommand. The rule's rationale is about what a pipe
# destroys, so it covers the commands that have something to lose. Three of the
# four are properties of the command's own output — a meaningful exit code, a
# liveness heartbeat, and a tail-safe completion trailer — which is what the
# gates whose exit code is a verdict and the long ones that heartbeat while they
# run all carry. Piping a small read-only query (`registry-query … | jq .`)
# loses nothing, and refusing it would make the rule feel arbitrary rather than
# earned.
#
# The fourth is stronger and is why the `preview` family is listed: a SIDE
# EFFECT A LATER GATE DEPENDS ON. `preview`, `preview-flow`, `preview-html`,
# `preview-interact`, `preview-verify`, and `show-results` each write the
# preview-shown marker
# (`.codeyam/preview-shown.json`) that `present-interactive` reads before it will
# allow an `AskUserQuestion`. A downstream `head -1` closes the pipe and SIGPIPEs
# the process mid-command, so the loss is invisible: the capture succeeds, the
# screenshots are correct, the body reports `success=true`, and only the gate
# stays shut. That cost five VM-13 sessions a wall each. The marker write now
# precedes every stdout write in those commands, which makes the loss
# unreachable — this entry is defense in depth, not the fix. `preview-nav`
# writes no marker; it rides along so the rule is "don't pipe the preview
# family" rather than an exception nobody will remember. `preview-show` writes
# none either, and that one is deliberate rather than incidental: it is
# read-only on the live pane (it broadcasts no nav and captures nothing), so it
# reports where a preview WOULD render without ever rendering one — marking off
# it would open the gate on a frame no user ever saw.
# `preview_gate::marker_writing_command_sources()` is the enforced twin of this
# enumeration; a new writer must join both.
_GATING_SUBCOMMANDS = frozenset(
    (
        "advance",
        "analyze-imports",
        "audit",
        # An `--scope impacted` sweep runs ~10 minutes and is routinely
        # backgrounded and piped; unwrapped, it left no status document.
        "client-errors",
        # The two terminal steps. Neither is slow in the ordinary case, and that
        # is exactly why they belong here: each POSTs to a handler that shells
        # out to git, so each CAN block, and each is the LAST command of its
        # flow — so a block strands the whole cycle with nothing left to report
        # it. Unwrapped, `feature-complete` hung for ten minutes emitting no
        # heartbeat and no status document, which is indistinguishable from
        # working. Membership here is what buys the liveness signal.
        "feature-complete",
        # Sizes the merge wall with the same strict gather Phase 2 runs, so it
        # takes minutes on a large project — long enough that an unwrapped run
        # read as wedged with no status document to say otherwise.
        "finalize-preview",
        "plan-complete",
        "pre-commit-sync",
        "preview",
        "preview-flow",
        "preview-html",
        "preview-interact",
        "preview-nav",
        "preview-verify",
        # Runs the suite twice — the most reliably long command a build session
        # issues, so it gets backgrounded and piped like the rest.
        "prove-red",
        "push",
        "reconcile-registry",
        "refresh-tests",
        "scenario-matrix",
        "scenario-taxonomy",
        "session-checkpoint",
        "session-finalize",
        "show-results",
        "test-on-base",
        "verify-build",
        "verify-full-finalize",
        "verify-test-cache",
    )
)
# A `codeyam-editor editor <subcommand>` invocation with its subcommand
# captured. Used only as the fail-closed fallback for a stage `shlex` cannot
# tokenize; the tokenizing path in `_gating_subcommand` is position-aware and
# is what runs normally.
_GATING_INVOCATION = re.compile(
    r"\bcodeyam-editor(?:-dev)?\s+editor\s+([a-z][a-z0-9-]*)"
)
# `--help` / `-h` as a standalone argument. A help text has no exit code to
# lose, no heartbeat, and no completion trailer, so piping one is harmless.
_HELP_FLAG = re.compile(r"(?:^|\s)(?:--help|-h)(?=\s|$)")


def _string_literal(expr):
    """The inner text of `expr` when it is a single quoted string literal."""
    expr = expr.strip()
    if len(expr) >= 2 and expr[0] == expr[-1] and expr[0] in "'\"`":
        inner = expr[1:-1]
        if expr[0] not in inner:
            return inner
    return None


def _call_args(text, paren_index):
    """Top-level, comma-separated argument expressions of the call whose `(`
    sits at `paren_index`. Quote-aware so a comma or paren inside a string
    literal does not split an argument. Returns [] if the parens never close."""
    depth = 0
    quote = ""
    args = []
    current = []
    for i in range(paren_index, len(text)):
        ch = text[i]
        if quote:
            if ch == quote:
                quote = ""
            current.append(ch)
            continue
        if ch in "'\"`":
            quote = ch
            current.append(ch)
            continue
        if ch in "([{":
            depth += 1
            if depth == 1:
                continue
        elif ch in ")]}":
            depth -= 1
            if depth == 0:
                args.append("".join(current))
                return args
        if depth == 1 and ch == ",":
            args.append("".join(current))
            current = []
        else:
            current.append(ch)
    return []


def _is_redirection_ampersand(chars, index):
    """True when the `&` at `chars[index]` is part of a REDIRECTION rather than
    a command boundary — `2>&1`, `>&2`, `&>out`.

    `&` is a separator character, so without this the single most common way to
    capture a command's stderr splits it in two: `… --auto-apply 2>&1 | tail`
    tokenizes as `… 2>` and `1 | tail`, putting the command and its filter in
    different pipelines. That is exactly the shape of every observed violation
    of the no-piping rule, so it is the shape the rule most has to see."""
    if chars[index] != "&":
        return False
    if index > 0 and chars[index - 1] in "><":
        return True
    return index + 1 < len(chars) and chars[index + 1] == ">"


# Programs whose heredoc body is DATA — a message, a document, a patch — and
# never a program. Only these have their bodies elided.
#
# An allowlist, not a denylist, because the two directions fail differently. A
# body fed to `python3 - <<'EOF'` IS the program: eliding it hides the exact
# incidents the scripted-rewrite guard was built from (a heredoc that read a
# tracked `.rs` file, ran `str.replace`, and wrote it back). A body fed to
# `git commit -F -` is prose the shell never lexes. Guessing wrong about an
# unknown program costs a false positive one way and an evasion path the
# other, so the unknown program keeps its body.
_HEREDOC_DATA_CONSUMERS = frozenset(
    (
        "cat", "tee", "git", "mail", "mailx", "sendmail", "wc", "sort", "uniq",
        "head", "tail", "column", "tr", "jq", "less", "more", "diff", "patch",
        "md5sum", "sha256sum", "base64", "gpg", "curl", "wget",
    )
)


def _heredoc_consumer(prefix):
    """The program that will consume the heredoc opened at the end of `prefix`
    — `git` in `git commit -F - <<'EOF'`, `python3` in `python3 - <<'EOF'`.

    Scans back to the last unquoted separator so only the CURRENT command is
    considered, then skips the wrappers and leading assignments that do not
    change which program runs. Deliberately does not reuse `_split_commands`:
    that routes through `elide_heredoc_bodies`, and calling it from inside the
    elision would be mutual recursion."""
    boundary = -1
    quote = ""
    escaped = False
    for index, ch in enumerate(prefix):
        if escaped:
            escaped = False
        elif ch == "\\" and quote != "'":
            escaped = True
        elif quote:
            if ch == quote:
                quote = ""
        elif ch in "'\"":
            quote = ch
        elif ch in _COMMAND_SEPARATORS:
            boundary = index
    for tok in prefix[boundary + 1:].split():
        if tok in _COMMAND_PREFIXES or _ASSIGNMENT.match(tok):
            continue
        return _program_name(tok)
    return ""


def _heredoc_openers(line):
    """The heredocs `line` opens, as `(delimiter, strip_tabs, elide)` triples in
    the order the shell will consume their bodies.

    `elide` is False when the consuming program EXECUTES the body rather than
    reading it as data — see `_HEREDOC_DATA_CONSUMERS`. Such a body is still
    tracked here, because the hook must know where the heredoc ends to resume
    scanning correctly on the line after it; it is simply kept rather than
    dropped.

    Quote-aware, so a literal `<<` inside a string is not an opener. `<<<` is a
    here-STRING — its operand is the data itself, on the same line, with no body
    to elide — so it is skipped rather than mistaken for a heredoc."""
    openers = []
    quote = ""
    escaped = False
    index = 0
    while index < len(line):
        ch = line[index]
        if escaped:
            escaped = False
        elif ch == "\\" and quote != "'":
            escaped = True
        elif quote:
            if ch == quote:
                quote = ""
        elif ch in "'\"":
            quote = ch
        elif ch == "<" and line[index + 1:index + 2] == "<":
            if line[index + 2:index + 3] == "<":
                index += 3
                continue
            cursor = index + 2
            strip_tabs = line[cursor:cursor + 1] == "-"
            if strip_tabs:
                cursor += 1
            while cursor < len(line) and line[cursor] in " \t":
                cursor += 1
            if line[cursor:cursor + 1] == "\\":
                cursor += 1
            delimiter, cursor = _heredoc_delimiter(line, cursor)
            if delimiter:
                consumer = _heredoc_consumer(line[:index])
                openers.append(
                    (delimiter, strip_tabs, consumer in _HEREDOC_DATA_CONSUMERS)
                )
            index = cursor
            continue
        index += 1
    return openers


def _heredoc_delimiter(line, cursor):
    """The delimiter word starting at `cursor`, plus the index just past it.

    Handles the three spellings the shell accepts — `'EOF'`, `"EOF"`, and a
    bare `EOF`. The quoting only controls whether the BODY is expanded, which
    is irrelevant here: either way the body is data the shell never lexes as
    commands, which is the whole reason it is elided."""
    opener = line[cursor:cursor + 1]
    if opener in "'\"":
        end = line.find(opener, cursor + 1)
        if end == -1:
            return ("", len(line))
        return (line[cursor + 1:end], end + 1)
    end = cursor
    while end < len(line) and (line[end].isalnum() or line[end] in "_-."):
        end += 1
    return (line[cursor:end], end)


def elide_heredoc_bodies(command):
    """`command` with every heredoc BODY removed, leaving the line that opens it
    — redirects and all — intact.

    A heredoc body is data by shell semantics, exactly as a quoted argument is,
    and this hook already honours the latter. Without this, a commit message
    piped through `git commit -F - <<'EOF'` was lexed as shell: a backticked
    code span in the prose became a command (`` `sed -i` `` read as a scripted
    rewrite, `` `grep -P` `` as a portability violation, `` `cargo test` `` as a
    test run), and a single apostrophe opened an unterminated quote that failed
    four guards closed at once — refusing a commit whose message merely NAMED a
    source file as a machine-rewrite of it.

    Eliding the body rather than relaxing the tokenizer is the point: the
    fail-closed contract on a malformed quote stays exactly as strict, because
    a body the shell never lexes was never the tokenizer's input to begin with.
    The opening line SURVIVES, so `cat <<'EOF' > src/lib.rs` still trips the
    scripted-rewrite guard on its redirect, and `git commit -F - <<'EOF'` is
    still a `git commit`.

    And only a DATA consumer's body is elided. `python3 - <<'EOF'` executes its
    body, so that body is a program and is kept — eliding it would have blinded
    the scripted-rewrite guard to the very incidents it was built from."""
    if "<<" not in command:
        return command
    kept = []
    pending = []
    for line in command.split("\n"):
        if pending:
            delimiter, strip_tabs, elide = pending[0]
            candidate = line.lstrip("\t") if strip_tabs else line
            if candidate.rstrip() == delimiter:
                pending.pop(0)
            if not elide:
                kept.append(line)
            continue
        kept.append(line)
        pending.extend(_heredoc_openers(line))
    return "\n".join(kept)


def _split_commands_with_separators(command):
    """`command` split at unquoted shell separators, as `(segment, separator)`
    pairs — the separator being the character that ENDED the segment, or `""`
    for the final one.

    Heredoc bodies are elided first (`elide_heredoc_bodies`) — this is the one
    seam every command-scanning guard passes through, so eliding here is what
    makes the whole hook heredoc-aware rather than each predicate separately.

    Quote-aware: a separator inside `'…'` or `"…"` is data — a grep pattern, not
    a boundary — and a backslash escapes the next character outside single
    quotes, so `find … {} \\;` does not split at its terminator. Every character
    is preserved verbatim within its segment, including the quotes, so an
    unterminated quote survives into the segment and is caught downstream.

    Empty segments are KEPT here, unlike in `_split_commands`. `||` and `&&`
    are runs of separator characters, so they yield an empty middle segment,
    and that emptiness is exactly what distinguishes `a || b` from the pipe
    `a | b` for `_pipelines`. Callers that only want the commands use
    `_split_commands`, which drops them."""
    pairs = []
    current = []
    quote = ""
    escaped = False
    chars = list(elide_heredoc_bodies(command))
    for index, ch in enumerate(chars):
        if escaped:
            current.append(ch)
            escaped = False
        elif ch == "\\" and quote != "'":
            current.append(ch)
            escaped = True
        elif quote:
            current.append(ch)
            if ch == quote:
                quote = ""
        elif ch in "'\"":
            current.append(ch)
            quote = ch
        elif ch in _COMMAND_SEPARATORS and not _is_redirection_ampersand(chars, index):
            pairs.append(("".join(current), ch))
            current = []
        else:
            current.append(ch)
    pairs.append(("".join(current), ""))
    return pairs


def _split_commands(command):
    """`command` split into individual commands at unquoted shell separators.

    The non-empty segments of `_split_commands_with_separators` — one scanner
    serves both, so the quote handling that keeps `grep -rn "grep -P"` from
    self-matching cannot drift between the two."""
    return [segment for segment, _ in _split_commands_with_separators(command)
            if segment.strip()]


def _in_command_position(tokens, index):
    """True when `tokens[index]` is the program a command runs rather than one
    of its arguments — allowing for the wrappers and leading environment
    assignments that still run it (`sudo sed`, `find … -exec sed`, `LC_ALL=C
    sed`). This is what keeps `grep -rn sed -i crates/` — where `sed` is a
    search term — from reading as an in-place edit."""
    if index == 0:
        return True
    prior = tokens[index - 1]
    return prior in _COMMAND_PREFIXES or bool(_ASSIGNMENT.match(prior))


def _has_inplace_editor(command):
    """True iff `command` invokes `sed`/`perl` with an in-place flag.

    Scoped to one command and blind to quoted text. A `sed` in one command says
    nothing about a flag in the next, so the scan restarts at every separator;
    and quoted regions collapse into single tokens, so a `-i` inside a grep
    pattern is data. Fails closed: a command that cannot be tokenized counts as
    an in-place edit, so a malformed quote is never an evasion path."""
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            return True
        for index, tok in enumerate(tokens):
            if tok.rsplit("/", 1)[-1] not in ("sed", "perl"):
                continue
            if not _in_command_position(tokens, index):
                continue
            if any(_INPLACE_FLAG.match(t) for t in tokens[index + 1:]):
                return True
    return False


def _is_pcre_flag(token):
    """True when `token` is grep's PCRE flag in any spelling GNU accepts: `-P`,
    a short cluster containing it (`-Pn`, `-rP`, `-Pio`), or `--perl-regexp`
    and the unambiguous abbreviations of it (`--perl`, `--perl-reg`). A cluster
    stops at the first value-taking letter, so `-eP` is a search for "P"."""
    if token.startswith("--"):
        return len(token) >= len("--perl") and "--perl-regexp".startswith(token)
    if not token.startswith("-") or token == "-":
        return False
    for ch in token[1:]:
        if ch == "P":
            return True
        if ch in _GREP_VALUE_FLAGS:
            return False
    return False


def _uses_pcre_grep(command):
    """True when `command` invokes `grep` with a PCRE flag, False when it
    provably does not, and None when it cannot be tokenized — undecidable.

    Scoped to one command and blind to quoted text, for the same reason as
    `_has_inplace_editor`: the flag is only a flag when it is an argument of an
    actual `grep` invocation. That keeps `grep -rn "grep -P" .claude/` — where
    the flag is the search term — and `echo 'do not use grep -P'` from reading
    as PCRE use. `git grep -P` is excluded because `grep` is not in command
    position there, and git's own PCRE support is portable across both hosts.

    The caller still fails closed on None, so a malformed quote is never an
    evasion path. None is kept apart from True because the two refusals make
    different claims: collapsing them told agents a PCRE flag had been FOUND in
    commands containing no `grep` at all — an apostrophe in a heredoc comment
    (`brief's`) was enough — and pointed them at a rewrite that could not
    address a phantom. See `unparseable_command_refusal`.

    Every segment is scanned before settling on None, so a decidable `grep -P`
    beside an untokenizable stage still gets the refusal that fits it."""
    undecidable = False
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            undecidable = True
            continue
        for index, tok in enumerate(tokens):
            if tok.rsplit("/", 1)[-1] != "grep":
                continue
            if not _in_command_position(tokens, index):
                continue
            if any(_is_pcre_flag(t) for t in tokens[index + 1:]):
                return True
    return None if undecidable else False


# git's own options that CONSUME the next argument, so the token after one is a
# value rather than the subcommand. Without this, `git -C /path commit` reads
# `/path` as the subcommand and the commit gate never fires.
_GIT_VALUE_OPTIONS = frozenset(
    (
        "-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path",
        "--super-prefix", "--config-env",
    )
)


def _git_subcommand(rest):
    """The subcommand of a `git` invocation — `commit` in `git -C /repo commit
    -m x`. None when the invocation names no subcommand."""
    skip = False
    for tok in rest:
        if skip:
            skip = False
            continue
        if tok in _GIT_VALUE_OPTIONS:
            skip = True
            continue
        if tok.startswith("-"):
            continue
        return tok
    return None


def invokes_git_subcommand(command, subcommand):
    """True iff `command` actually RUNS `git <subcommand>`.

    Replaces a bare `"git commit" in command` substring test, which read any
    MENTION of the verb as an invocation: `echo "remember to git commit later"`
    was refused, and so was a commit whose own message discussed committing.
    Position-aware for the same reason `_uses_pcre_grep` is — the name is only
    an invocation when it is the program being run, and `shlex` has already
    collapsed every quoted region into one token, so a verb inside a message can
    never be it.

    A shell payload is re-scanned as a command in its own right, so
    `bash -c "git commit -m x"` is still a commit. Fails closed: a stage that
    cannot be tokenized counts as a match, the same contract every other guard
    here carries."""
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            return True
        for index, tok in enumerate(tokens):
            if _program_name(tok) != "git" or not _in_command_position(tokens, index):
                continue
            if _git_subcommand(tokens[index + 1:]) == subcommand:
                return True
        payload = _shell_c_payload(tokens)
        if payload is not None and invokes_git_subcommand(payload, subcommand):
            return True
    return False


# The `codeyam-editor:editor` spelling reaches the same CLI through the plugin
# invocation form, so it is one token rather than a program plus a subcommand.
# Derived from _CODEYAM_CLIS rather than spelled out. commands::apply_cli_name
# rewrites the canonical plugin-form token into the dev-wrapper one at install
# time, so a hardcoded pair collapses to a single element on a -dev install and
# recognition of the canonical spelling is silently lost. Deriving the set keeps
# the CLI-name list single-sourced, survives that rewrite, and leaves no
# non-canonical literal for the SHIPPED_AGENT_FILE_NONCANONICAL_CLI_NAME audit
# invariant to flag — which is why this file needs no allowlist entry.
_CODEYAM_EDITOR_TOKENS = frozenset(f"{cli}:editor" for cli in _CODEYAM_CLIS)


def invokes_codeyam_editor(command):
    """True iff `command` actually RUNS a `codeyam-editor editor …` subcommand.

    This one gates an ALLOW, not a refusal, which is why it had to change: the
    substring test it replaces short-circuited the commit, push, code-change and
    PCRE gates for any command whose TEXT contained the CLI name anywhere —
    including inside a quoted commit message. `git commit -m "chore: document
    codeyam-editor editor advance"` was allowed at every slug. Closing that is
    the same substring-versus-structure fix as `invokes_git_subcommand`, applied
    in the opposite direction.

    Fails closed the way an allow must: a stage that cannot be tokenized does
    NOT earn the bypass, so a malformed quote can never buy one."""
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            continue
        for index, tok in enumerate(tokens):
            if not _in_command_position(tokens, index):
                continue
            if _program_name(tok) in _CODEYAM_EDITOR_TOKENS:
                return True
            if _program_name(tok) not in _CODEYAM_CLIS:
                continue
            rest = tokens[index + 1:]
            if rest and rest[0] == "editor":
                return True
    return False


def _pipelines(command):
    """`command` grouped into pipelines — each a list of the stages joined by
    unquoted `|`, in order.

    A lone command is a one-stage pipeline, so `len(stages) > 1` is exactly the
    "this was piped" test. `||` is NOT a pipe: it is two separator characters,
    so it yields an empty middle segment, and an empty segment ends the current
    pipeline rather than extending it. That empty-segment check is the whole
    difference between `audit || echo failed` (allowed — two pipelines) and
    `audit | tail` (one two-stage pipeline)."""
    pipelines = []
    current = []
    pairs = _split_commands_with_separators(command)
    for index, (segment, separator) in enumerate(pairs):
        if not segment.strip():
            if current:
                pipelines.append(current)
                current = []
            continue
        current.append(segment)
        piped_into_next = (
            separator == "|"
            and index + 1 < len(pairs)
            and pairs[index + 1][0].strip()
        )
        if not piped_into_next:
            pipelines.append(current)
            current = []
    if current:
        pipelines.append(current)
    return pipelines


def _gating_subcommand(stage):
    """The gating `codeyam-editor editor <subcommand>` that `stage` RUNS, or
    None.

    Position-aware for the same reason `_uses_pcre_grep` is: the name is only
    an invocation when it is the program the stage runs, so
    `grep "codeyam-editor editor audit" notes.md | head` — where it is a search
    term — does not trip the rule. Fails closed: a stage that cannot be
    tokenized falls back to the position-blind regex, so a malformed quote is
    never an evasion path."""
    try:
        tokens = shlex.split(stage, posix=True)
    except ValueError:
        match = _GATING_INVOCATION.search(stage)
        return match.group(1) if match else None
    for index, tok in enumerate(tokens):
        if tok.rsplit("/", 1)[-1] not in ("codeyam-editor", "codeyam-editor-dev"):
            continue
        if not _in_command_position(tokens, index):
            continue
        rest = tokens[index + 1:]
        if len(rest) >= 2 and rest[0] == "editor" and rest[1] in _GATING_SUBCOMMANDS:
            return rest[1]
    return None


def _is_tee_stage(stage):
    """True when `stage` is a `tee` — the one downstream stage that preserves
    what a pipe would otherwise destroy. `tee` copies stdout to a file and
    passes it through unchanged, and a pipeline ending in `tee` reports `tee`'s
    status, which fails only on a write error. So the exit code, the heartbeat,
    and the completion trailer all survive."""
    try:
        tokens = shlex.split(stage, posix=True)
    except ValueError:
        return False
    return bool(tokens) and tokens[0].rsplit("/", 1)[-1] == "tee"


def _capture_available():
    """True when the liveness bracket's stream capture is available on this
    host, which is what makes piping a gating command lossless.

    The capture is Unix descriptor surgery (`stream_capture.rs`, `#[cfg(unix)]`).
    Elsewhere `TranscriptGuard::install` returns `None`, so a piped command
    writes straight to the caller's pipe: its `println!` sites see EPIPE, panic,
    and the run dies mid-flight with no transcript and no status document to
    recover from. On those hosts the old refusal is still the right answer."""
    return os.name == "posix"


def piped_gating_command(command):
    """The gating subcommand `command` pipes into a filter, or None.

    This is the mechanical form of the CLAUDE.md "do not pipe gating or
    long-running commands" rule. The rule is documented at length and violated
    anyway, on the very commands it names — so it is enforced here rather than
    left to prose.

    Three properties of a wrapped gating command die at a pipe. The shell
    reports the LAST stage's status, so `verify-build | tail` exits 0 when the
    build failed — a false green that advances the workflow past a failing
    gate. `tail`/`grep` block-buffer to EOF, so a still-running command's output
    and its `CODEYAM_CMD_RUNNING` heartbeat never surface and the read looks
    empty. And the tail-safe completion trailer — the `EXACT_TASK_TITLE`
    hand-off and the `CODEYAM_CMD_COMPLETE` sentinel — gets sliced off.

    Only `tee` is exempt, because only `tee` rescues all three: it copies stdout
    to a file and passes it through unchanged, so the exit code, the heartbeat,
    and the trailer all survive. `set -o pipefail` and `${PIPESTATUS[0]}` rescue
    the exit code ALONE and were previously honoured as full exemptions — which
    let a `reconcile-registry … 2>&1 | tail -30` through on the strength of a
    `PIPESTATUS` echo and cost the session ten minutes staring at a
    block-buffered pipe. `--help` is exempt because a help text has no exit code
    to lose, no heartbeat, and no trailer."""
    for stages in _pipelines(command):
        for index, stage in enumerate(stages[:-1]):
            subcommand = _gating_subcommand(stage)
            if subcommand is None or _HELP_FLAG.search(stage):
                continue
            if all(_is_tee_stage(later) for later in stages[index + 1:]):
                continue
            return subcommand
    return None


def piped_gating_notice(subcommand):
    """The advisory text for a piped gating command — allowed, not refused.

    The pipe used to be refused because it destroyed four things. Three are now
    recovered from disk and the fourth cannot happen: every subcommand in
    `_GATING_SUBCOMMANDS` runs inside the liveness bracket, where stdout is a
    pipe the command's own process owns, so a departed filter can no longer
    SIGPIPE it mid-run. What a pipe still costs is the terminal DISPLAY, the
    shell-level exit code, and — when the run is auto-backgrounded — the
    COMPLETION NOTIFICATION. This names where each was written instead.

    That third cost is the one this notice used to get wrong, by claiming a
    pipe cost "exactly two things". A filter that outlives the command holds the
    pipeline open, so the harness task never exits and no notification is ever
    going to fire; the command meanwhile finished and wrote its verdict.
    Observed 2026-08-23 on a `session-checkpoint` piped through `grep | tail`:
    verdict on disk in 343s, agent still waiting hours later, because "no
    notification yet" is indistinguishable from "still running" unless something
    says otherwise. The root leak that produced it is fixed, but any long-lived
    process the command leaves behind can hold a pipe open, so the agent still
    needs to know the verdict does not depend on the notification.

    Saying it at all — rather than allowing silently — is the point. The
    pipeline's `$?` is the filter's, and an agent that reads it will believe a
    failed gate passed. The notice has to arrive BEFORE the command runs,
    because afterwards the misleading exit code is already in hand."""
    return (
        f"NOTE: `{cli_command()} editor {subcommand}` is piped into a filter. "
        f"That is allowed — the command runs to completion and every side "
        f"effect lands — but your shell reports the FILTER's exit code, not the "
        f"command's, so do not read `$?` as the verdict.\n"
        f"  Real verdict: .codeyam/state/command-output/{subcommand}.status.json "
        f"(the `status` field — the same document the "
        f"`CODEYAM_CMD_COMPLETE` line carries). Authoritative the moment the "
        f"command finishes, whether or not a notification ever arrives.\n"
        f"  Full output:  .codeyam/state/command-output/{subcommand}.txt "
        f"(complete stdout + stderr, unsliced).\n"
        f"  Still alive?  a backgrounded run's one-line `.heartbeat` sidecar.\n"
        f"  If backgrounded: a filter that outlives the command holds the task "
        f"open, so the completion notification may NEVER fire. Do not read "
        f"\"no notification yet\" as \"still running\" — check the status "
        f"document above.\n"
        f"`| tee out.txt` remains the filter that costs you nothing."
    )


# `pgrep` flags that consume the NEXT argv element. Without these the value
# would be mistaken for the pattern operand — `pgrep -f -u root foo` would
# report `root`, and the self-match test would then run against the wrong text.
_PGREP_VALUE_FLAGS = frozenset("dPuUgGstF")
_PGREP_LONG_VALUE_FLAGS = frozenset(
    (
        "--delimiter",
        "--parent",
        "--euid",
        "--uid",
        "--group",
        "--session",
        "--terminal",
        "--pgroup",
        "--pidfile",
        "--ns",
        "--nslist",
    )
)

# One `pgrep` invocation, up to the next command boundary. `|` is a boundary so
# a `| grep -v $$` filter is not swallowed into the flag scan.
_PGREP_CALL = re.compile(r"\bpgrep\b([^;|&\n()]*)")

# A wait loop, in the two halves that have to BOTH be present. The keyword
# alone matches `for f in *.rs` on one line of a longer command; the body alone
# matches a `do`/`done` belonging to something else.
_LOOP_KEYWORD = re.compile(r"\b(?:while|until|for)\b")
_LOOP_BODY = re.compile(r"\bdo\b.*\bdone\b", re.DOTALL)


def _pgrep_full_pattern(segment):
    """Return the pattern operand of a `pgrep` call that scans FULL argv.

    `None` when the call does not scan argv at all (no `-f`/`--full`), when it
    is anchored to the program name (`-x`/`--exact`, which cannot match a
    shell's long command line and is therefore already one of the fixes), or
    when there is no pattern to read."""
    try:
        tokens = shlex.split(segment, posix=True)
    except ValueError:
        return None
    full = False
    exact = False
    index = 0
    while index < len(tokens):
        token = tokens[index]
        if token == "--":
            index += 1
            break
        if token[:1] in (">", "<") or (token[:1].isdigit() and ">" in token):
            index += 1
            continue
        if token.startswith("--"):
            name = token.split("=", 1)[0]
            if name == "--full":
                full = True
            elif name == "--exact":
                exact = True
            elif name in _PGREP_LONG_VALUE_FLAGS and "=" not in token:
                index += 1
            index += 1
            continue
        if token.startswith("-") and len(token) > 1:
            letters = token[1:]
            if "f" in letters:
                full = True
            if "x" in letters:
                exact = True
            if letters[-1] in _PGREP_VALUE_FLAGS:
                index += 1
            index += 1
            continue
        break
    if not full or exact or index >= len(tokens):
        return None
    return tokens[index]


def self_matching_pgrep_loop(command):
    """Return the pattern of a wait loop whose `pgrep -f` will match itself.

    `pgrep -f` scans every process's FULL command line, and the polling loop is
    itself a process whose command line contains the pattern — because the
    pattern is written inside it. So the loop finds itself, the condition never
    goes false, and it never exits. Observed 2026-08-25: a session sat in
    `until ! pgrep -f 'codeyam-editor editor commit'; do sleep 20; done`
    waiting on a commit that had already finished, because the only process
    still matching was the waiter.

    Three conditions, and each one earns its place:

    - A LOOP. A one-shot `pgrep -f` self-matches too, but it returns a wrong
      answer once; a loop never terminates. Only the second is worth a notice.
    - `-f` WITHOUT `-x`. `-x` matches the program name, which a shell's long
      command line can never equal — that is one of the fixes, not the hazard.
    - THE PATTERN ACTUALLY MATCHES THE COMMAND TEXT. This is what makes the
      rule discriminating rather than a blanket ban on `pgrep -f` in a loop: it
      lets the classic bracket trick through. `pgrep -f '[c]odeyam-editor'`
      contains no literal `codeyam-editor` run for its own regex to find, so it
      does not self-match, and it is correctly not flagged.

    A command that already excludes its own pid (`$$`) is likewise left alone —
    the author has seen this problem and handled it."""
    if not command or "pgrep" not in command:
        return None
    if not _LOOP_KEYWORD.search(command) or not _LOOP_BODY.search(command):
        return None
    if "$$" in command:
        return None
    for match in _PGREP_CALL.finditer(command):
        pattern = _pgrep_full_pattern(match.group(1))
        if not pattern:
            continue
        try:
            if re.search(pattern, command):
                return pattern
        except re.error:
            # Not a valid regex to Python. `pgrep` would reject it too, but the
            # substring test still answers the question that matters.
            if pattern in command:
                return pattern
    return None


def self_matching_pgrep_notice(pattern):
    """The advisory text for a self-matching wait loop — allowed, not refused.

    A notice rather than a block because nothing is destroyed and nothing needs
    recovering: the command is safe, it simply will not finish. It has to
    arrive BEFORE the command runs, because afterwards the agent is inside a
    loop that never returns and has no turn left in which to read anything.

    `wait-for` leads because it is this repo's sanctioned answer — it blocks to
    completion in one call and its exit code is trustworthy. The two `pgrep`
    repairs follow for the case where polling is genuinely what you want."""
    return (
        f"NOTE: this loop polls with `pgrep -f {pattern!r}`, and `pgrep -f` "
        f"matches against each process's FULL command line — including this "
        f"loop's own. The pattern is written inside the loop, so `pgrep` finds "
        f"the loop itself, the condition never goes false, and it never "
        f"exits.\n"
        f"  Best:  do not poll at all. `{cli_command()} editor wait-for "
        f"<task-id>` blocks to completion in ONE call and returns the real "
        f"verdict — or just keep working and let the harness completion "
        f"notification re-invoke you.\n"
        f"  Or:    match the program NAME instead of the argv: `pgrep -x "
        f"<name>`.\n"
        f"  Or:    exclude yourself: `pgrep -f {pattern!r} | grep -v $$`.\n"
        f"Observed 2026-08-25: a session waited on a commit that had already "
        f"finished, because the only process still matching was the waiter."
    )


# ── write-target resolution ────────────────────────────────────────────
#
# The scripted-rewrite guard falls back to "every tracked path the command
# MENTIONS" whenever a write target is opaque. That fallback is right for a
# target that genuinely cannot be known, and wrong for the two shapes that
# used to reach it needlessly (four refusals in one session, 2026-09-18):
#
#   - a target held in a variable bound to a string literal in the same
#     command — `p = '.codeyam/tmp/batch.json'` … `open(p, 'w')`, or
#     `P=/tmp/notes.md` … `sed -i '' 's#a.rs#b.rs#' "$P"`. Resolving the
#     binding makes the target explicit, so the write is judged on what it
#     actually writes rather than on the tracked paths it merely mentions;
#   - a write construct that is itself DATA — inside a Python/JS string
#     literal or comment, or inside a quoted argument or heredoc handed to a
#     program that does not execute it. Quoting `open(p, 'w')` in order to
#     test, log or describe the guard is not a write.
#
# Both narrow only what counts as a target. Every case this cannot settle
# still falls through to the mention scan, so the failure direction stays a
# refusal, never an unguarded rewrite.

# Interpreters whose code this guard can read string literals in.
_JS_INTERPRETERS = frozenset(("node", "nodejs", "bun", "deno", "tsx", "ts-node"))
# Programs that may execute text the lexer below sees only as a quoted word
# (`bash -c "…"`, `ssh host "…"`, `ruby -e '…'`). Their presence anywhere in a
# command means a quoted word can no longer be assumed to be data.
_EXECUTING_PROGRAMS = frozenset(
    (
        "bash", "sh", "zsh", "ksh", "dash", "fish", "eval", "source", "exec",
        "ssh", "su", "watch", "parallel", "docker", "podman", "kubectl",
        "script", "tmux", "screen", "ruby", "perl", "php", "lua", "osascript",
    )
)
# Code that can run a string as code. A literal in such a program may be the
# program, so its literals are not treated as data.
_DYNAMIC_EXECUTION = re.compile(
    r"\b(?:exec|eval|compile|Function|system|popen|subprocess|child_process|"
    r"execSync|execFile|spawn|spawnSync|runpy)\b"
)
# Python string prefixes that do not interpolate. `f` does, so an f-string is
# never data.
_PY_LITERAL_PREFIXES = frozenset(("", "r", "u", "b", "br", "rb"))
# A shell redirection token, which is never a script operand.
_REDIRECT_TOKEN = re.compile(r"^[0-9&]*[<>]")
_BARE_IDENTIFIER = re.compile(r"^[A-Za-z_$][A-Za-z0-9_$]*$")
# An interpreter's own positional argument — `sys.argv[1]`, `process.argv[2]`.
_ARGV_REFERENCE = re.compile(r"(?P<module>sys|process)\.argv\s*\[\s*(?P<index>\d+)\s*\]")
_PYTHON_PROGRAM = re.compile(r"^python(?:\d+(?:\.\d+)?)?$")
# Python flags that take no argument, so a script operand can still be found
# past them. Anything else makes the argv layout unknowable.
_PYTHON_BARE_FLAGS = frozenset("bBdEiIOqsSuv")
# A redirection operator with its target in the NEXT token (`<< 'PY'`, `2> f`).
_BARE_REDIRECT = re.compile(r"^[0-9&]*(?:<<-?|<<<|<|>>|>|&>)$")
# The end of a statement right after an assignment's literal — so `p = 'a' + x`
# is not read as binding `p` to `'a'`.
_STATEMENT_END = re.compile(r"""[ \t]*(?:$|[;\n#]|//|["'`][ \t]*(?:$|[;\n|&)]))""")
_MAX_RESOLVED_TARGETS = 16


def _lex_shell_words(command):
    """Position-aware shell lexing: `(commands, heredocs)`, or None for a
    command this lexer does not model (`$'…'` quoting, an unterminated quote).

    `commands` is a list of word lists, split where `_split_commands` splits.
    Each word is `(text, start, end, quoted)`: `text` is the unquoted value
    and `quoted` lists the `(inner_start, inner_end, quote_char)` raw ranges
    of its quoted parts. `heredocs` lists `(command_index, body_start,
    body_end)` for every heredoc body, attributed to the command that opened
    it. Unlike `_split_commands`, nothing is elided — positions index the raw
    command, which is what a construct match is reported against."""
    if "$'" in command:
        return None
    commands = [[]]
    heredocs = []
    pending = []
    chars = []
    quoted = []
    start = None
    i = 0
    n = len(command)

    def end_word(end):
        nonlocal chars, quoted, start
        if start is not None:
            commands[-1].append(("".join(chars), start, end, quoted))
        chars, quoted, start = [], [], None

    while i < n:
        ch = command[i]
        if ch in "'\"":
            if start is None:
                start = i
            j = i + 1
            while j < n and command[j] != ch:
                if ch == '"' and command[j] == "\\" and j + 1 < n:
                    j += 1
                    if command[j] not in '"\\$`\n':
                        chars.append("\\")
                chars.append(command[j])
                j += 1
            if j >= n:
                return None
            quoted.append((i + 1, j, ch))
            i = j + 1
            continue
        if ch == "\\":
            if command[i + 1:i + 2] == "\n":
                i += 2
                continue
            if start is None:
                start = i
            if i + 1 < n:
                chars.append(command[i + 1])
            i += 2
            continue
        if command.startswith("<<", i) and not command.startswith("<<<", i):
            end_word(i)
            cursor = i + 2
            strip_tabs = command[cursor:cursor + 1] == "-"
            if strip_tabs:
                cursor += 1
            while cursor < n and command[cursor] in " \t":
                cursor += 1
            if command[cursor:cursor + 1] == "\\":
                cursor += 1
            delimiter, cursor = _heredoc_delimiter(command, cursor)
            if delimiter:
                pending.append((delimiter, strip_tabs, len(commands) - 1))
            i = max(cursor, i + 2)
            continue
        if ch == "\n":
            end_word(i)
            i += 1
            for delimiter, strip_tabs, owner in pending:
                body_start = i
                while True:
                    line_end = command.find("\n", i)
                    if line_end == -1:
                        line_end = n
                    line = command[i:line_end]
                    candidate = line.lstrip("\t") if strip_tabs else line
                    if candidate.rstrip() == delimiter or line_end >= n:
                        body_end = i if candidate.rstrip() == delimiter else n
                        heredocs.append((owner, body_start, body_end))
                        i = line_end + 1
                        break
                    i = line_end + 1
            pending = []
            commands.append([])
            continue
        if ch in " \t":
            end_word(i)
            i += 1
            continue
        if ch in _COMMAND_SEPARATORS and not _is_redirection_ampersand(command, i):
            end_word(i)
            commands.append([])
            i += 1
            continue
        if start is None:
            start = i
        chars.append(ch)
        i += 1
    end_word(n)
    for _, strip_tabs, owner in pending:
        heredocs.append((owner, n, n))
    return commands, heredocs


def _interpreter_code_source(texts, index, lang):
    """Where the interpreter at `texts[index]` reads its program from:
    `("arg", word_index)` for `-c`/`-e` code, `("stdin", None)`, or
    `("file", None)` for a script or module operand."""
    j = index + 1
    while j < len(texts):
        tok = texts[j]
        if _REDIRECT_TOKEN.match(tok):
            j += 2 if tok.rstrip("0123456789&<>") == "" and tok[-1] in "<>" else 1
            continue
        if tok == "-":
            return ("stdin", None)
        if lang == "py":
            if not tok.startswith("--") and re.match(r"^-[A-Za-z]*c$", tok):
                return ("arg", j + 1) if j + 1 < len(texts) else ("file", None)
            if tok == "-m":
                return ("file", None)
            if tok in ("-W", "-X", "-Q"):
                j += 2
                continue
        elif tok in ("-e", "--eval", "-p", "--print", "-pe") or (
            tok == "eval" and texts[index] == "deno"
        ):
            return ("arg", j + 1) if j + 1 < len(texts) else ("file", None)
        if tok.startswith("-"):
            j += 1
            continue
        return ("file", None)
    return ("stdin", None)


def _code_literal_spans(command, region, lang):
    """Raw `(start, end)` spans of the string literals and comments in the
    code `region` — a list of `(char, raw_index)` pairs, already shell-
    unescaped. None when the code runs strings as code, or when a literal
    does not terminate: either way nothing in it can be called data."""
    text = "".join(ch for ch, _ in region)
    if _DYNAMIC_EXECUTION.search(text):
        return None
    local = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        comment = (lang == "py" and ch == "#") or (lang == "js" and text.startswith("//", i))
        if comment:
            end = text.find("\n", i)
            end = n if end == -1 else end
            local.append((i, end))
            i = end
            continue
        if lang == "js" and text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end == -1:
                return None
            local.append((i, end + 2))
            i = end + 2
            continue
        if ch in "'\"" or (lang == "js" and ch == "`"):
            k = i
            while k > 0 and text[k - 1].isalpha():
                k -= 1
            prefix = text[k:i].lower()
            if lang != "py" or (k > 0 and (text[k - 1].isalnum() or text[k - 1] == "_")):
                prefix, k = "", i
            delimiter = ch * 3 if lang == "py" and text.startswith(ch * 3, i) else ch
            j = i + len(delimiter)
            while j < n and not text.startswith(delimiter, j):
                if text[j] == "\\":
                    j += 1
                elif text[j] == "\n" and len(delimiter) == 1 and ch != "`":
                    return None
                j += 1
            if j >= n:
                return None
            end = j + len(delimiter)
            interpolates = (
                prefix not in _PY_LITERAL_PREFIXES
                if lang == "py"
                else ch == "`" and "${" in text[i:end]
            )
            if not interpolates:
                local.append((k, end))
            i = end
            continue
        i += 1
    return [(region[s][1], region[e - 1][1] + 1) for s, e in local if e > s]


def _quoted_region(command, word):
    """The code inside `word` when it is ONE quoted string, as `(char,
    raw_index)` pairs with the shell's double-quote escapes undone. None for
    a word that is unquoted or pieced together from several parts."""
    _, start, end, quoted = word
    if len(quoted) != 1:
        return None
    inner_start, inner_end, quote = quoted[0]
    if inner_start != start + 1 or inner_end != end - 1:
        return None
    region = []
    i = inner_start
    while i < inner_end:
        if quote == '"' and command[i] == "\\" and i + 1 < inner_end and command[i + 1] in '"\\$`':
            i += 1
        region.append((command[i], i))
        i += 1
    return region


def _command_program(texts):
    """The program a lexed command runs, past wrappers and assignments."""
    for tok in texts:
        if tok in _COMMAND_PREFIXES or _ASSIGNMENT.match(tok):
            continue
        return _program_name(tok)
    return ""


def write_construct_data_spans(command):
    """Raw `(start, end)` spans of `command` in which a write construct is
    DATA rather than a write, so the scripted-rewrite guard can skip it.

    Two kinds, and each fails closed:

    - A string literal or comment inside code an interpreter runs — a
      `python3 -c` argument or a `python3 - <<'EOF'` body. Skipped when that
      code can run strings as code (`exec`, `subprocess`, …).
    - A quoted argument, or a heredoc body, handed to a program that does not
      execute it — a `git commit -m` message, an `echo`, a `cat` heredoc.
      Skipped entirely when ANY word of the command could execute text: a
      shell, `eval`, `ssh`, an interpreter reading code from its stdin, or a
      double-quoted string carrying a command substitution.

    Everything else stays in scope, exactly as before."""
    lexed = _lex_shell_words(command)
    if lexed is None:
        return []
    commands, heredocs = lexed
    heredoc_owners = {owner for owner, _, _ in heredocs}
    spans = []
    code_words = set()
    stdin_code = {}
    fail_closed = False
    for ci, words in enumerate(commands):
        texts = [w[0] for w in words]
        for wi, tok in enumerate(texts):
            program = _program_name(tok)
            if _PYTHON_INTERPRETER.match(program):
                lang = "py"
            elif program in _JS_INTERPRETERS:
                lang = "js"
            else:
                if program in _EXECUTING_PROGRAMS:
                    fail_closed = True
                continue
            kind, code_index = _interpreter_code_source(texts, wi, lang)
            if kind == "arg":
                code_words.add((ci, code_index))
                region = _quoted_region(command, words[code_index])
                literal = _code_literal_spans(command, region, lang) if region else None
                spans.extend(literal or [])
            elif kind == "stdin":
                if ci in heredoc_owners:
                    stdin_code[ci] = lang
                else:
                    fail_closed = True
    for owner, body_start, body_end in heredocs:
        if owner in stdin_code:
            region = [(command[i], i) for i in range(body_start, body_end)]
            spans.extend(_code_literal_spans(command, region, stdin_code[owner]) or [])
        elif not fail_closed:
            texts = [w[0] for w in commands[owner]]
            if _command_program(texts) in _HEREDOC_DATA_CONSUMERS:
                spans.append((body_start, body_end))
    if fail_closed:
        return spans
    for ci, words in enumerate(commands):
        for wi, word in enumerate(words):
            if (ci, wi) in code_words:
                continue
            for inner_start, inner_end, quote in word[3]:
                inner = command[inner_start:inner_end]
                if quote == '"' and ("$(" in inner or "`" in inner):
                    continue
                spans.append((inner_start, inner_end))
    return spans


def _in_spans(position, spans):
    return any(start <= position < end for start, end in spans)


def _literal_value(command, index):
    """The string literal starting at `command[index]` and the index past it,
    when it is a plain literal ending its statement — optionally wrapped as
    `Path("…")`. None for anything computed, escaped or interpolated."""
    wrapped = re.match(r"(?:pathlib\.)?Path\s*\(\s*", command[index:])
    if wrapped:
        index += wrapped.end()
    quote = command[index:index + 1]
    if quote not in ("'", '"'):
        return None
    end = command.find(quote, index + 1)
    if end == -1:
        return None
    value = command[index + 1:end]
    if not value or "\\" in value or "\n" in value:
        return None
    end += 1
    if wrapped:
        close = re.match(r"\s*\)", command[end:])
        if not close:
            return None
        end += close.end()
    if not _STATEMENT_END.match(command, end):
        return None
    return value


def _without_redirections(tokens):
    """`tokens` with every shell redirection and its target removed, so a
    heredoc opener (`<<'PY'`, `<< PY`) is never read as a positional argument."""
    kept = []
    skip = False
    for tok in tokens:
        if skip:
            skip = False
        elif _BARE_REDIRECT.match(tok):
            skip = True
        elif not _REDIRECT_TOKEN.match(tok):
            kept.append(tok)
    return kept


def _python_argv(args):
    """The `sys.argv` a `python` invoked with `args` sees, or None when an
    option is not understood well enough to lay it out."""
    for i, tok in enumerate(args):
        if tok == "-" or not tok.startswith("-"):
            return args[i:]
        flags = tok[1:]
        if flags.endswith("c") and set(flags[:-1]) <= _PYTHON_BARE_FLAGS:
            return ["-c"] + args[i + 2:] if i + 1 < len(args) else None
        if not flags or not set(flags) <= _PYTHON_BARE_FLAGS:
            return None
    return None


def _node_argv(args):
    """The `process.argv` a `node` invoked with `args` sees, or None when an
    option is not understood well enough to lay it out. `node -e CODE a` puts
    `a` at index 1; `node - a` and `node script a` put it at index 2."""
    for i, tok in enumerate(args):
        if tok in ("-e", "--eval", "-p", "--print"):
            return ["node"] + args[i + 2:] if i + 1 < len(args) else None
        if tok == "-" or not tok.startswith("-"):
            return ["node"] + args[i:]
        return None
    return None


def _argv_is_read_only(command):
    """True when every mention of `argv` in `command` is a read of one element
    (`sys.argv[1]`, `process.argv[2]`) that is not assigned to.

    A script that can CHANGE its argv before writing — `sys.argv[1] =
    "<tracked>"`, `from sys import argv`, `a = sys.argv` — makes the shell
    argument say nothing about the file it opens, so resolving through it
    would name the wrong file and could let a tracked write pass."""
    references = list(_ARGV_REFERENCE.finditer(command))
    if len(references) != len(re.findall(r"\bargv\b", command)):
        return False
    return not any(
        re.match(r"\s*(?://|\*\*|<<|>>|[-+*/%|&^@])?=(?!=)", command[ref.end():])
        for ref in references
    )


def _interpreter_invocations(command, module):
    """The arguments of every `python*` (module `sys`) or `node` (module
    `process`) invocation in `command`, redirections removed — or None when a
    segment that may hold one cannot be tokenized."""
    is_program = (
        _PYTHON_PROGRAM.match if module == "sys"
        else lambda name: name in ("node", "nodejs")
    )
    invocations = []
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            if re.search(r"\b(?:python|node)", segment):
                return None
            continue
        for i, tok in enumerate(tokens):
            if is_program(tok.rsplit("/", 1)[-1]) and _in_command_position(tokens, i):
                invocations.append(_without_redirections(tokens[i + 1:]))
    return invocations


def interpreter_argument(command, module, index):
    """The literal paths `sys.argv[index]` (module `sys`) or
    `process.argv[index]` (module `process`) holds when `command` runs — or
    None when that cannot be proven.

    Proven only when argv is never mutated (`_argv_is_read_only`), `command`
    invokes exactly ONE interpreter of that family, its options are all
    understood, and the argument is a literal or a shell variable bound to
    literals in the same command. This is the hop that makes `F=<path>` …
    `python3 - "$F"` … `open(sys.argv[1], "w")` legible. Every doubt resolves
    to None — opaque — which keeps the conservative fallback: a wrong index
    would name the wrong file and could let a tracked write pass."""
    if index < 1 or not _argv_is_read_only(command):
        return None
    invocations = _interpreter_invocations(command, module)
    if not invocations or len(invocations) != 1:
        return None
    layout = _python_argv if module == "sys" else _node_argv
    argv = layout(invocations[0])
    if argv is None or index >= len(argv):
        return None
    return _expand_shell_operand(command, argv[index])


def _argv_value(command, index):
    """The paths an `sys.argv[N]` / `process.argv[N]` expression starting at
    `command[index]` resolves to, when it is the whole statement — else None."""
    match = _ARGV_REFERENCE.match(command, index)
    if not match or not _STATEMENT_END.match(command, match.end()):
        return None
    return interpreter_argument(command, match.group("module"), int(match.group("index")))


def resolve_identifier(command, name):
    """Every string literal `name` is bound to in `command` — a Python or JS
    variable (`p = "…"`) — or None when it cannot be resolved.

    Resolved only when EVERY binding of `name` is a plain literal assignment.
    Any other binding form — a computed value, a loop target, a parameter, an
    import, `as p`, tuple unpacking, an augmented assignment — makes it
    unresolvable. Several literal bindings resolve to all of their values,
    since a loop may reach any of them: an extra candidate can only add a
    refusal, never remove one."""
    if not _BARE_IDENTIFIER.match(name):
        return None
    ident = re.escape(name)
    bound = rf"(?<![\w.$]){ident}(?![\w$])"
    other_bindings = (
        rf"\bfor\b[^\n;:]*?{bound}[^\n;:]*?\b(?:in|of)\b",
        rf"\bas\s+{ident}(?![\w$])",
        rf"\b(?:def|class|function)\s+{ident}(?![\w$])",
        rf"\bdef\s+\w+\s*\([^)]*{bound}",
        rf"\bfunction\b[^(\n]*\([^)]*{bound}",
        rf"\blambda\b[^:\n]*{bound}[^:\n]*:",
        rf"\([^()\n]*{bound}[^()\n]*\)\s*=>",
        rf"{bound}\s*=>",
        rf"\b(?:import|global|nonlocal)\b[^\n;]*{bound}",
        # Unpacking: `p, q = …`, `a, p = …`, `[a, p] = …` — anchored at a
        # statement start so `open(p, mode="w")` is not read as one.
        rf"(?:^|[;\n\"'])\s*(?:(?:const|let|var)\s+)?[\[(]?\s*{ident}(?![\w$])\s*,[^=\n;]*=(?![=>])",
        rf"(?:^|[;\n\"'])\s*(?:(?:const|let|var)\s+)?[\[(]?\s*(?:[\w$*.]+\s*,\s*)+"
        rf"{ident}(?![\w$])[^=\n;]*=(?![=>])",
        rf"\{{[^}}\n]*{bound}[^}}\n]*\}}\s*=(?![=>])",
        rf"{bound}\s*(?:\*\*|//|>>|<<|\?\?|\|\||&&|[-+*/%|&^:@])=",
        rf"{bound}\s*:[^=\n]*=(?![=>])",
    )
    if any(re.search(pattern, command) for pattern in other_bindings):
        return None
    values = []
    assignment = re.compile(rf"(?<![\w.$])(?:(?:const|let|var)\s+)?{ident}\s*=(?![=>])\s*")
    for match in assignment.finditer(command):
        value = _literal_value(command, match.end())
        resolved = [value] if value is not None else _argv_value(command, match.end())
        if resolved is None:
            return None
        values.extend(v for v in resolved if v not in values)
    return values or None


def _shell_variable_values(command, name):
    """Every literal a shell variable is assigned in `command` (`P=/tmp/x`),
    or None when any binding of it is not a standalone literal assignment.

    An assignment PREFIXING a program (`P=x sed … "$P"`) does not count: the
    shell expands `"$P"` before that assignment takes effect."""
    ident = re.escape(name)
    if re.search(
        rf"\bfor\s+{ident}\b|\bread\b[^;\n|&]*\b{ident}\b|\b{ident}\+=|\$\{{{ident}:?[=?]",
        command,
    ):
        return None
    values = []
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            return None
        if tokens and tokens[0] in ("export", "local", "declare", "readonly", "typeset"):
            tokens = [t for t in tokens[1:] if not t.startswith("-")]
        standalone = all(_ASSIGNMENT.match(t) for t in tokens)
        for tok in tokens:
            if not _ASSIGNMENT.match(tok):
                break
            key, _, value = tok.partition("=")
            if key != name:
                continue
            if not standalone or not value or re.search(r"[$`]", value):
                return None
            if value not in values:
                values.append(value)
    return values or None


def _expand_shell_operand(command, operand):
    """`operand` with its `$VAR`/`${VAR}` references replaced by their
    literal values, as a list of candidate paths — or None when a reference
    cannot be resolved or the operand is otherwise computed."""
    candidates = [operand]
    for match in re.finditer(r"\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?", operand):
        values = _shell_variable_values(command, match.group(1))
        if values is None:
            return None
        candidates = [
            c.replace(match.group(0), v, 1) for c in candidates for v in values
        ][:_MAX_RESOLVED_TARGETS]
    if any(re.search(r"[$`{}]", c) for c in candidates):
        return None
    return candidates


_SED_LONG_FLAGS = frozenset(
    (
        "--quiet", "--silent", "--in-place", "--regexp-extended", "--separate",
        "--null-data", "--unbuffered", "--posix", "--debug", "--sandbox",
        "--follow-symlinks", "--binary", "--expression", "--file",
    )
)


def _sed_operands(tokens):
    """The file operands of the `sed` whose arguments are `tokens`, or None
    when an option is not understood well enough to tell a file from the
    script."""
    script_given = False
    operands = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok == "--":
            operands.extend(tokens[i + 1:])
            break
        if tok.startswith("--"):
            name = tok.split("=", 1)[0]
            if name not in _SED_LONG_FLAGS:
                return None
            if name in ("--expression", "--file"):
                script_given = True
                if "=" not in tok:
                    i += 1
            i += 1
            continue
        if tok.startswith("-") and len(tok) > 1:
            for j, flag in enumerate(tok[1:], start=1):
                if flag in "ef":
                    script_given = True
                    if j == len(tok) - 1:
                        i += 1
                    break
                if flag in "iI":
                    # BSD spells an empty backup suffix as its own `''` argument.
                    if j == len(tok) - 1 and i + 1 < len(tokens) and tokens[i + 1] == "":
                        i += 1
                    break
                if flag not in "nErszuab":
                    return None
            i += 1
            continue
        operands.append(tok)
        i += 1
    if not script_given:
        if not operands:
            return None
        operands = operands[1:]
    return operands


def _perl_operands(tokens):
    """The file operands of the `perl` whose arguments are `tokens`, or None
    when an option is not understood well enough to tell a file from the
    program."""
    code_given = False
    operands = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok == "--":
            operands.extend(tokens[i + 1:])
            break
        if tok.startswith("-") and len(tok) > 1 and not tok.startswith("--"):
            j = 1
            while j < len(tok):
                flag = tok[j]
                if flag in "eE":
                    code_given = True
                    if j == len(tok) - 1:
                        i += 1
                    break
                if flag == "i" or (flag in "IMmxCdDF" and j < len(tok) - 1):
                    break
                if flag in "0l":
                    j += 1
                    digits = "01234567"
                    if flag == "0" and tok[j:j + 1] == "x":
                        j += 1
                        digits = "0123456789abcdefABCDEF"
                    while j < len(tok) and tok[j] in digits:
                        j += 1
                    continue
                if flag not in "acnpstTuUvwWXh":
                    return None
                j += 1
            i += 1
            continue
        if tok.startswith("--"):
            return None
        operands.append(tok)
        i += 1
    if not code_given:
        if not operands:
            return None
        operands = operands[1:]
    return operands


def inplace_edit_targets(command):
    """`(found, paths)` for the in-place `sed`/`perl` edits in `command`:
    `found` is True when there is one, and `paths` lists every file they
    rewrite — or is None when any of them cannot be resolved (a positional
    list fed by `xargs`/`find -exec`, an unknown option, an unresolvable
    variable, an untokenizable command). Fails closed exactly as
    `_has_inplace_editor` does."""
    if not _has_inplace_editor(command):
        return False, []
    paths = []
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            return True, None
        for index, tok in enumerate(tokens):
            program = tok.rsplit("/", 1)[-1]
            if program not in ("sed", "perl") or not _in_command_position(tokens, index):
                continue
            rest = tokens[index + 1:]
            if not any(_INPLACE_FLAG.match(t) for t in rest):
                continue
            if any(t in ("xargs", "-exec", "-execdir", "parallel") for t in tokens[:index]):
                return True, None
            rest = [t for t in rest if not _REDIRECT_TOKEN.match(t)]
            operands = _sed_operands(rest) if program == "sed" else _perl_operands(rest)
            if not operands:
                return True, None
            for operand in operands:
                expanded = _expand_shell_operand(command, operand)
                if expanded is None:
                    return True, None
                paths.extend(expanded)
    return True, paths or None


def _resolved_expression(command, expr):
    """The literal paths a write construct's target expression names — the
    literal itself, the values of a bare variable bound to literals, or the
    interpreter argument a `sys.argv[N]` / `process.argv[N]` holds — or None
    when it cannot be resolved."""
    literal = _string_literal(expr)
    if literal:
        return [literal]
    expr = expr.strip()
    if _BARE_IDENTIFIER.match(expr):
        return resolve_identifier(command, expr)
    argv = _ARGV_REFERENCE.fullmatch(expr)
    if argv:
        return interpreter_argument(command, argv.group("module"), int(argv.group("index")))
    return None


def write_targets(command):
    """Parse `command` for in-process file-write constructs.

    Returns `(explicit, opaque, append_only)`: `explicit` lists the paths the
    command writes to — literal, or resolved from a variable bound to a
    literal (`p = "…"` … `open(p, "w")`, `P=…` … `sed -i … "$P"`), or from an
    interpreter argument (`F=…` … `python3 - "$F"` … `open(sys.argv[1], "w")`,
    see `interpreter_argument`); `opaque`
    is True when at least one write construct targets a path that cannot be
    resolved statically. A construct that is data rather than code — see
    `write_construct_data_spans` — is not a write construct at all.

    `append_only` is True when every construct found EXTENDS its target
    (`>>`, `open(p, "a")`) rather than replacing it. Appending is still a
    write and is still refused, but the refusal owes an accurate account of
    what the command did, so the distinction has to survive the parse instead
    of being discarded here. Mixed commands report False — of "this appends"
    and "this rewrites", the stronger claim is the true one."""
    explicit = []
    opaque = False
    appending = False
    truncating = False
    constructs = ("open", "write_", "writeFile")
    data = write_construct_data_spans(command) if any(c in command for c in constructs) else []

    def add(resolved):
        nonlocal opaque
        if resolved is None:
            opaque = True
        else:
            explicit.extend(resolved)

    for match in _OPEN_CALL.finditer(command):
        if _in_spans(match.start(), data):
            continue
        args = _call_args(command, match.end() - 1)
        if len(args) < 2:
            continue
        mode = _string_literal(re.sub(r"^\s*mode\s*=", "", args[1]))
        if mode is None or not set(mode) & set("wax+"):
            continue
        if "a" in mode:
            appending = True
        else:
            truncating = True
        add(_resolved_expression(command, args[0]))

    for pattern in (_WRITE_TEXT, _NODE_WRITE):
        for match in pattern.finditer(command):
            if _in_spans(match.start(), data):
                continue
            truncating = True
            if match.group("path"):
                explicit.append(match.group("path"))
            elif pattern is _NODE_WRITE:
                args = _call_args(command, command.index("(", match.start()))
                add(_resolved_expression(command, args[0]) if args else None)
            else:
                receiver = re.search(r"(?<![\w.)\]])([A-Za-z_]\w*)\s*$", command[:match.start()])
                add(resolve_identifier(command, receiver.group(1)) if receiver else None)

    for match in _SHELL_REDIRECT.finditer(command):
        if match.group(0).startswith(">>"):
            appending = True
        else:
            truncating = True
        explicit.append(match.group("path"))

    found, paths = inplace_edit_targets(command)
    if found:
        truncating = True
        add(paths)

    return explicit, opaque, appending and not truncating


def _repo_relative(path, project_dir):
    """`path` expressed relative to `project_dir`, or None when it escapes the
    repo (an absolute path elsewhere, `~`, or a `../` climb)."""
    if not path or path.startswith("~"):
        return None
    if os.path.isabs(path):
        try:
            rel = os.path.relpath(path, project_dir)
        except ValueError:
            return None
    else:
        rel = path
    while rel.startswith("./"):
        rel = rel[2:]
    if not rel or rel.startswith(".."):
        return None
    return rel


def eligible_pathspecs(paths, project_dir):
    """The repo-relative, source-suffixed, pathspec-safe subset of `paths`,
    de-duplicated and capped at `_MAX_PATH_CANDIDATES`.

    Pure — no git, no filesystem. Split from `tracked_source_paths` so the
    normalize-and-filter half is testable without a git repository."""
    candidates = []
    for path in paths:
        rel = _repo_relative(path, project_dir)
        if not rel or not rel.lower().endswith(SOURCE_SUFFIXES):
            continue
        if not _PATHSPEC_SAFE.match(rel) or rel in candidates:
            continue
        candidates.append(rel)
        if len(candidates) >= _MAX_PATH_CANDIDATES:
            break
    return candidates


def tracked_source_paths(paths, project_dir):
    """The subset of `paths` that git tracks and that carries a source suffix.

    Untracked files, temp/scratchpad paths, and generated artifacts all fall
    out here — they are not tracked, so they are never blocked."""
    candidates = eligible_pathspecs(paths, project_dir)
    if not candidates:
        return []
    try:
        result = subprocess.run(
            ["git", "ls-files", "-z", "--"] + candidates,
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception:
        return []
    if result.returncode != 0:
        return []
    return sorted(p for p in result.stdout.split("\0") if p)


def _path_tokens(command):
    """Every path-shaped substring in `command` that could name a file.
    Suffix and tracked-ness filtering happen in `tracked_source_paths`."""
    return [m.group(0) for m in _PATHLIKE.finditer(command)]


def _offending_stage(stages):
    """The first of `stages` that itself carries a write construct, or `""`
    when none can be attributed.

    Best-effort by design, and it must stay that way. `_split_commands` splits
    on `(`/`)` among others, so an INTERPRETER heredoc — the shape the whole
    guard was built from — shreds into stages like `open`, `p, "w"`, `.write`,
    none of which carries a recognisable write on its own. That is fine here
    (an unattributable stage simply suppresses the compound sentence) and would
    be catastrophic in the detection itself, which is why detection stays
    whole-command."""
    for stage in stages:
        explicit, opaque, _ = write_targets(stage)
        if explicit or opaque:
            return stage.strip()
    return ""


def scripted_rewrite_stage(command, project_dir):
    """`(tracked_path, stage, stage_count, append_only, target_inferred)` when
    `command` writes tracked source off-transcript, else None. `stage` is `""`
    when the offending half cannot be attributed; `append_only` is
    `write_targets`' construct verdict, carried through so the refusal can
    describe an append as an append.

    `target_inferred` is True when `tracked_path` came from the opaque
    fallback below rather than from a resolved write target — the command
    MENTIONS it, and writes somewhere the parse could not see. The refusal owes
    that distinction: one session was told its heredoc "machine-rewrites"
    `step_handoff.rs`, a path that appeared only inside a replacement string,
    while the file it actually wrote was an untracked plan.

    Detection is WHOLE-COMMAND, unchanged: a command qualifies only when it
    BOTH carries a write construct AND that write lands on tracked source.
    When every write target resolves — a literal path, or a variable bound to
    literals in the same command, which is the shape the real incidents took
    (`p = "…/opencode.rs"` … `open(p, "w")`, with the assignment and the write
    on different lines) — only those paths are judged, so a write to a temp
    file is not refused for the tracked paths it merely mentions. When a
    target is still opaque, it falls back to every tracked source path the
    command mentions. Narrowing that fallback to a single stage silently
    disarms the guard on exactly the cases it covers.

    Stage ATTRIBUTION is layered on top so the refusal can name the offending
    half of a compound command. One session ran `cp <file> <backup> && perl
    -0pi …`; the whole call was refused, so the backup never happened and the
    agent lost its safety net without being told — the splitter knew both
    stages and the refusal named only a file."""
    explicit, opaque, append_only = write_targets(command)
    if not explicit and not opaque:
        return None
    candidates = _path_tokens(command) if opaque else explicit
    tracked = tracked_source_paths(candidates, project_dir)
    if not tracked:
        return None
    resolved = eligible_pathspecs(explicit, project_dir)
    target = next((path for path in tracked if path in resolved), tracked[0])
    stages = _split_commands(command)
    return (target, _offending_stage(stages), len(stages), append_only, target not in resolved)


def scripted_source_rewrite_target(command, project_dir):
    """The git-tracked source file a scripted in-process rewrite would clobber,
    or None when `command` is not one. The verdict half of
    `scripted_rewrite_stage`, for callers that need only the path."""
    found = scripted_rewrite_stage(command, project_dir)
    return found[0] if found else None


# ── line-budget guard ──────────────────────────────────────────────────
#
# A codeyam-editor project caps `.claude/skills/codeyam-editor/SKILL.md` at a
# line count enforced by a Rust test (`skill_md_is_lean`). Nothing used to say
# so until that test went red — long after the content was written, and under
# Fast Commit possibly not until finalize. One session appended three bullets to
# a file already sitting at exactly 100 lines, discovered the wall from a red
# full-suite run, reverted its own work, and re-authored it as a step-library
# fragment. The content ended up in the right place; the detour was pure waste.
#
# These helpers mirror `commands::editor::line_budget`'s parsing so an edit that
# would exceed the budget is refused BEFORE it lands. They mirror the *parsing*,
# never the *number* — the cap is read from the test that declares it, so raising
# or lowering it stays a one-line edit there.

# Directories never worth walking for the contract test. Mirrors
# `control-api`'s `ALWAYS_EXCLUDED_DIRS`.
_BUDGET_SCAN_EXCLUDED_DIRS = frozenset(("node_modules", ".codeyam", ".git", "target"))

# Upper bound on Rust files examined while looking for the contract. The real
# marker sits in a test file near the top of the walk; the cap only stops a
# pathological tree from making a PreToolUse hook slow.
_BUDGET_SCAN_MAX_FILES = 4000

# The "approaching the cap" gradient lives in `line_budget::WARN_MARGIN` and is
# reported by `classify-constrained-files` at plan time. It is deliberately NOT
# mirrored here: this hook can only speak by refusing (exit 2), and a refusal is
# the wrong response to an edit that still fits. What this guard owes is the
# hard stop, worded so the author never has to discover the wall by test.


def _is_rust_comment(line):
    """True for a Rust comment line. Comments DISCUSS the contract; they never
    declare it. Load-bearing: `line_budget.rs`'s own doc comment names the parsed
    construct, and a parser that read comments latched onto that placeholder and
    reported a guarded path of `…SKILL.md` — a lookup matching no real file, which
    silently disabled this guard."""
    return line.lstrip().startswith("//")


def read_rel_skill_path(line):
    """The guarded SKILL.md argument of a `read_rel("…")` call, or None."""
    if _is_rust_comment(line):
        return None
    parts = line.split('read_rel("')
    if len(parts) < 2:
        return None
    literal = parts[1].split('"')[0]
    return literal if literal.endswith("SKILL.md") else None


def line_count_limit(line):
    """The integer N from a `line_count <= N` assertion on `line`, or None."""
    if _is_rust_comment(line):
        return None
    parts = line.split("line_count <=")
    if len(parts) < 2:
        return None
    digits = ""
    for ch in parts[1].lstrip():
        if not ch.isdigit():
            break
        digits += ch
    return int(digits) if digits else None


def parse_lean_contract(test_src):
    """`(guarded repo-relative path, max line count)` from the contract test
    source, or None when either literal is absent."""
    path = None
    limit = None
    for line in test_src.splitlines():
        if path is None:
            path = read_rel_skill_path(line)
        if limit is None:
            limit = line_count_limit(line)
        if path is not None and limit is not None:
            return (path, limit)
    return None


def _is_integration_test_path(path):
    """True when `path` sits under a `tests/` directory.

    The enforced contract is an integration test. A `src/` file carrying the
    marker is documentation about the contract or a test *fixture* imitating it —
    `line_budget.rs` and `classify_constrained_files.rs` both hold one — and
    parsing a fixture yields a cap that belongs to nobody."""
    return "tests" in path.replace("\\", "/").split("/")


def discover_lean_contract(project_dir):
    """Scan the project's Rust integration tests for the `skill_md_is_lean`
    marker and parse the contract out of it. None when the project enforces no
    cap — the correct degradation, and what makes this guard silent on every
    project that is not codeyam-editor itself."""
    examined = 0
    for root, dirs, files in os.walk(project_dir):
        dirs[:] = [d for d in dirs if d not in _BUDGET_SCAN_EXCLUDED_DIRS]
        if not _is_integration_test_path(os.path.relpath(root, project_dir)):
            continue
        for name in files:
            if not name.endswith(".rs"):
                continue
            examined += 1
            if examined > _BUDGET_SCAN_MAX_FILES:
                return None
            try:
                with open(os.path.join(root, name), "r", encoding="utf-8") as f:
                    src = f.read()
            except Exception:
                continue
            if "skill_md_is_lean" in src:
                parsed = parse_lean_contract(src)
                if parsed:
                    return parsed
    return None


def projected_line_count(tool_name, tool_input, current_body):
    """The line count `file_path` would have AFTER this Write/Edit, or None when
    it cannot be determined.

    Write replaces the whole file, so its `content` is the answer outright. Edit
    is computed by performing the same substring replacement in memory — exact,
    rather than a line-delta estimate that drifts on a multi-line old_string. An
    Edit whose `old_string` is not present changes nothing, so it is left to the
    Edit tool's own error rather than judged here."""
    if tool_name == "Write":
        content = tool_input.get("content")
        return None if content is None else len(content.splitlines())
    old = tool_input.get("old_string")
    new = tool_input.get("new_string")
    if current_body is None or old is None or new is None or old not in current_body:
        return None
    if tool_input.get("replace_all"):
        return len(current_body.replace(old, new).splitlines())
    return len(current_body.replace(old, new, 1).splitlines())


def line_budget_refusal(rel_path, limit, current, projected):
    """The `(reason, next_action)` pair for an edit that would break a file's
    line budget.

    The reason states the arithmetic — an author who sees `100/100, this edit
    makes it 103` knows immediately that the target is wrong rather than that the
    file is off limits. The next action names the whole fragment mechanism: the
    command, the file it writes, the placeholder, the substitution site, and the
    leak test. Naming only the destination ("move it into step .txt files") is
    what left the four steps to be rediscovered by reading a sibling."""
    return (
        f"`{rel_path}` is at its enforced line budget: {current}/{limit} lines, and "
        f"this edit would make it {projected}. The `skill_md_is_lean` test would go "
        f"red — possibly not until finalize, long after this content is written. The "
        f"cap is not a bug to route around: hitting it is what moves operational "
        f"guidance into the step library, where a step body re-reads it every step "
        f"instead of once per session.",
        f"author a step-library fragment instead. Run "
        f"`{cli_command()} editor new-step-fragment <name> --slug <slug>`: it writes "
        f"crates/codeyam-editor/src/commands/editor/steps/library/fragments/<name>_block.txt, "
        f"adds the `include_str!` substitution for `{{<name>_block}}` in "
        f"crates/codeyam-editor/src/commands/editor/step.rs, inserts the placeholder into "
        f"each named slug's .txt, and prints the placeholder-leak test to add. Then put "
        f"this guidance in that fragment. To check any file's remaining headroom first: "
        f"`{cli_command()} editor classify-constrained-files {rel_path}`.",
    )


def line_budget_violation(tool_name, tool_input, project_dir):
    """`(rel_path, limit, current, projected)` when this Write/Edit would push a
    line-budgeted file past its cap, else None.

    Cheap in the common case: the contract scan is skipped entirely unless the
    target is named `SKILL.md`, so an ordinary source edit pays one basename
    comparison."""
    file_path = tool_input.get("file_path", "")
    if os.path.basename(file_path) != "SKILL.md":
        return None
    rel = _repo_relative(file_path, project_dir)
    if not rel:
        return None
    contract = discover_lean_contract(project_dir)
    if not contract:
        return None
    guarded, limit = contract
    if rel.replace("\\", "/") != guarded:
        return None
    try:
        with open(os.path.join(project_dir, guarded), "r", encoding="utf-8") as f:
            body = f.read()
    except Exception:
        body = None
    projected = projected_line_count(tool_name, tool_input, body)
    if projected is None or projected <= limit:
        return None
    current = len(body.splitlines()) if body is not None else 0
    return (rel, limit, current, projected)


def compound_stage_evidence(stage, stage_count):
    """The sentence a refused COMPOUND command owes: which stage matched, and
    that nothing ran.

    A refusal is all-or-nothing — the hook returns exit 2 before the shell sees
    any of it — so the safe half of `cp <backup> && perl -0pi …` is lost too.
    Saying which half matched, and that the other did NOT run, is the difference
    between re-issuing the safe half and silently continuing without it.

    Silent when the stage cannot be attributed. An interpreter heredoc splits
    into many pseudo-stages that are fragments of one program, not commands, so
    claiming it is an "11-stage compound command" would be worse than saying
    nothing."""
    if not stage or stage_count < 2:
        return ""
    return (
        f"this is a {stage_count}-stage compound command and the match is in "
        f"stage `{stage}`; NOTHING ran — the other stage(s) were refused with "
        f"it, so re-issue any safe half (a `cp` backup, a `mkdir`) on its own"
    )


def _inferred_target_refusal(path, append_only):
    """The `(reason, next_action)` pair when the write's destination could not
    be resolved and `path` is only a tracked file the command MENTIONS.

    It must not claim the command writes `path` — that is an inference, and an
    agent told its command rewrites a file it demonstrably never opens learns to
    read the next refusal as a false positive. The block itself stays: erring
    safe on an unresolvable target is what makes the guard worth having."""
    construct = "an append" if append_only else "a scripted write"
    return (
        f"this command performs {construct} whose destination could not be "
        f"resolved statically, and `{path}` is a tracked source file the command "
        f"mentions — so it is refused as if it wrote that file. A scripted write "
        f"computes its diff at runtime, so the change never appears in the "
        f"transcript a reviewer reads, and it bypasses the file-state tracking "
        f"that lets Edit refuse a file that changed underneath it.",
        f"if the destination is NOT tracked source, make it legible and re-run: "
        f"bind it to a literal in the same command — `p = \"path\"` … "
        f"`open(p, \"w\")`, or `F=path` … `python3 - \"$F\"` reading "
        f"`sys.argv[1]` — and the hook judges that path instead of every path the "
        f"command mentions. If it IS tracked source, use the Edit tool; several "
        f"Edit calls in ONE message run in parallel, and `replace_all: true` covers "
        f"a replace-every-occurrence pass.",
    )


def scripted_rewrite_refusal(path, append_only=False, target_inferred=False):
    """The `(reason, next_action)` pair for a refused scripted write. Names the
    path that matched and the sanctioned alternatives — batching is the reason
    agents reach for a script, so the refusal has to answer it.

    Branches on how the path was FOUND before anything else: a resolved target
    gets the definite wording below, an inferred one gets
    `_inferred_target_refusal`, which says what the hook could and could not
    see.

    Branches on the CONSTRUCT, not the file. `cat >> file` is refused for the
    same two reasons a rewrite is (the diff is computed at runtime so it never
    reaches the transcript, and it bypasses Edit's file-state tracking), but it
    does not parse the file or self-match generated code, and none of
    `replace_all` / `rename-symbol` answers "add 100 lines to the end". Calling
    it a rewrite and offering replace-shaped recoveries left the agent to
    re-read the file tail and synthesize an anchor by hand — the round trip
    that made this the most-hit block on the fleet."""
    if target_inferred:
        return _inferred_target_refusal(path, append_only)
    if append_only:
        return (
            f"this command appends to the tracked source file `{path}`. "
            f"An append is still a write whose diff is computed at runtime, so "
            f"the change never appears in the transcript a reviewer reads; and "
            f"it bypasses the file-state tracking that lets Edit refuse a file "
            f"that changed underneath it.",
            f"use the Edit tool anchored on the file's existing final construct: "
            f"`old_string` is that construct verbatim, `new_string` is that same "
            f"construct followed by the new content. Batching is not a reason to "
            f"script — several Edit calls in ONE message run in parallel. Writing "
            f"to an untracked file, to /tmp, or to the scratchpad is unaffected.",
        )
    return (
        f"this command machine-rewrites the tracked source file `{path}`. "
        f"A scripted in-process rewrite (`open(p, 'w')`, `.write_text(`, `sed -i`, "
        f"`perl -pi`) computes its diff at runtime, so the change never appears in "
        f"the transcript a reviewer reads; it parses the language with the wrong "
        f"grammar and self-matches the code it just generated; and it bypasses the "
        f"file-state tracking that lets Edit refuse a file that changed underneath "
        f"it.",
        f"use the Edit tool. Batching is not a reason to script — "
        f"several Edit calls in ONE message run in parallel. For a genuine "
        f"replace-every-occurrence pass use Edit with `replace_all: true`; to rename "
        f"an identifier across source + glossary + registry run "
        f"`{cli_command()} editor rename-symbol`. Writing to an untracked file, to "
        f"/tmp, or to the scratchpad is unaffected.",
    )


def unparseable_command_refusal(command):
    """The `(reason, next_action, evidence)` for a command this hook's
    tokenizer cannot split, which is therefore refused unverified.

    It claims only what the hook established: that tokenizing failed, on which
    stage, and why. It names no guard, because none was evaluated — the PCRE
    refusal used to fire here with `Evidence: a PCRE flag was found …` on
    commands containing no `grep`, and the agent spent its retries rewriting a
    flag that did not exist. The usual trigger is not a shell error at all:
    `shlex` has no heredoc support, so an apostrophe inside a quoted heredoc
    body (`# the brief's names`) reads as an unclosed quote even though bash
    accepts the command."""
    stage, error = command.strip(), "unknown tokenizer error"
    for segment in _split_commands(command):
        try:
            shlex.split(segment, posix=True)
        except ValueError as e:
            stage, error = segment.strip(), str(e)
            break
    return (
        "this command could not be tokenized, so the hook could not check it "
        "against its guards and refuses it rather than guess. This is not a "
        "finding of any rule — not `grep -P`, not a test run. The usual "
        "cause is an apostrophe inside a heredoc body or comment (`brief's`): "
        "bash accepts it, but the hook's tokenizer has no heredoc support and "
        "reads it as an unclosed quote.",
        "if this command changes a file, use the Edit tool instead — several "
        "Edit calls in ONE message run in parallel. Otherwise remove or balance "
        "the stray quote (reword `brief's` to `the brief`, or escape it) and "
        "re-run.",
        f"the tokenizer reported `{error}` on the stage: {stage}",
    )


def refuse_unparseable(project_dir, command, call):
    """Refuse `command` as undecidable and exit. Every guard whose detector
    returns None for an untokenizable command routes here, so they share one
    reason and one `unparseable-command` fingerprint instead of each claiming
    its own rule matched."""
    reason, next_action, evidence = unparseable_command_refusal(command)
    block(
        project_dir,
        "unparseable-command",
        reason,
        next_action,
        evidence=evidence,
        call=call,
    )


# ── preview-origin hand-write guard ────────────────────────────────────
#
# The subpath-hydration recovery is two coupled writes: `sameOriginSafe` in
# `.codeyam/stack.json` and a `previewOrigin` in the editor config. Scripting
# either by hand is the VM-7 incident — a python one-liner flipping
# `sameOriginSafe` — and doing one half alone leaves the preview flagged
# dedicated with no origin to move to. `.json` is deliberately outside
# `SOURCE_SUFFIXES`, so the scripted-rewrite guard never saw it; this guard is
# narrow on purpose (those keys, in those files) and names the verb that
# performs both writes, since before it existed the refusal had nothing to offer.
_PREVIEW_ORIGIN_KEYS = re.compile(r"sameOriginSafe|previewOrigin")
_PREVIEW_ORIGIN_FILES = (
    ".codeyam/stack.json",
    ".codeyam/editor.json",
    ".codeyam/editor.local.json",
)


def preview_origin_hand_write_target(command):
    """The preview-origin config file `command` scripts a write of the preview
    origin keys into, or None. Both halves are required: a write construct
    landing on one of `_PREVIEW_ORIGIN_FILES`, and a mention of one of the
    keys. Reading those files, or writing another key into them, is untouched."""
    if not _PREVIEW_ORIGIN_KEYS.search(command):
        return None
    explicit, opaque, _append_only = write_targets(command)
    if not explicit and not opaque:
        return None
    candidates = _path_tokens(command) if opaque else explicit
    return next((p for p in candidates if p.endswith(_PREVIEW_ORIGIN_FILES)), None)


def preview_origin_hand_write_refusal(path):
    """The `(reason, next_action)` pair for a refused preview-origin hand write."""
    return (
        f"this command scripts a write of the preview origin into `{path}`. "
        f"Serving the Live Preview from its own origin is two coupled writes "
        f"(`preview.sameOriginSafe` in `.codeyam/stack.json` and a "
        f"`previewOrigin` in the editor config); either one alone leaves the "
        f"preview half-switched, with nowhere to move to.",
        f"run `{cli_command()} editor preview-origin-mode dedicated --origin "
        f"<ABSOLUTE-ORIGIN>` — it performs both writes, or neither. "
        f"`{cli_command()} editor preview-origin-mode same-origin` undoes it.",
    )


# --- Recursive-delete guard ------------------------------------------------
#
# A recursive delete is the most destructive thing an agent can do to a working
# tree and the one whose damage is invisible until something else surfaces it.
# `rm -rf crates/codeyam-editor/.codeyam` was issued in the belief that it was
# stray generated output; it was 12 git-TRACKED fixture files, and nothing said
# so until a later `git status`.
#
# The mistake was reasonable. `.codeyam/` at the repo root IS internal cache
# state (it is in `ALWAYS_EXCLUDED_DIRS`), and the same directory name one level
# down inside a crate is a tracked test fixture. That ambiguity is not going
# away — which is exactly why the guard keys on git-tracked-ness rather than on
# a denylist of directories that "look like cache". A denylist is the reasoning
# that caused the loss. Whether git tracks a file is the fact that actually
# matters, it is cheap to ask, and it generalizes to every fixture directory in
# every client project.
#
# There is deliberately no bypass flag. A rule an agent can wave away under time
# pressure is not a guard, and a genuinely intended deletion of tracked files
# already has a reversible, reviewable spelling: `git rm`.
#
# Scope is recursive deletes only. A single `rm <file>` names exactly what it
# removes and is visible in the transcript; `-r` against a directory is the
# shape whose blast radius the author cannot see.

_RM_LONG_RECURSIVE = "--recursive"

# The shortest unambiguous abbreviation GNU `rm` accepts for `--recursive`.
# `--recursive` is the only long option of `rm` beginning with `r`, so getopt
# resolves `--r` to it.
_RM_LONG_RECURSIVE_MIN = len("--r")

# Textual last resort when a segment cannot be tokenized. Matches `rm` only in
# command position (start of segment, or after a separator) so a mention inside
# an unterminated string is not one.
_RM_TEXTUAL = re.compile(r"(?:^|[\s;|&(])(?:[^\s;|&]*/)?rm(?=\s)")
_RM_TEXTUAL_RECURSIVE = re.compile(r"(?:^|\s)-(?:-r|[A-Za-z]*[rR])")


def is_recursive_rm_flag(token):
    """True when `token` is `rm`'s recursive flag in any spelling it accepts:
    `-r`, `-R`, a short cluster containing either (`-rf`, `-fr`, `-Rf`), or
    `--recursive` and its unambiguous abbreviations.

    Clustering needs no value-flag stop list the way grep's `-P` does: none of
    `rm`'s short options takes a value, so every letter in a cluster is a flag
    and `r` anywhere in one means recursive."""
    if token.startswith("--"):
        return (
            len(token) >= _RM_LONG_RECURSIVE_MIN
            and _RM_LONG_RECURSIVE.startswith(token)
        )
    if not token.startswith("-") or token == "-":
        return False
    return any(ch in "rR" for ch in token[1:])


def recursive_rm_operands(tokens):
    """The paths a recursive `rm` in one already-split command would delete, or
    `[]` when this command is not a recursive `rm`.

    `_in_command_position` is what keeps `grep -rn "rm -rf" .claude/` and
    `git commit -m "drop rm -rf from the script"` from reading as deletions —
    in both, `rm` is an argument, and in the second it is not even a token of
    its own. Everything after a `--` terminator is an operand, including a path
    that begins with a dash."""
    for index, tok in enumerate(tokens):
        if _program_name(tok) != "rm":
            continue
        if not _in_command_position(tokens, index):
            continue
        recursive = False
        operands = []
        end_of_flags = False
        for arg in tokens[index + 1:]:
            if end_of_flags:
                operands.append(arg)
            elif arg == "--":
                end_of_flags = True
            elif arg.startswith("-") and arg != "-":
                recursive = recursive or is_recursive_rm_flag(arg)
            else:
                operands.append(arg)
        if recursive and operands:
            return operands
    return []


def tracked_file_count(path, project_dir):
    """How many git-tracked files live AT or UNDER `path`.

    Deliberately not `tracked_source_paths`: that filters to source suffixes,
    and the files actually lost here were `.json` fixtures. A delete does not
    care what a reviewer reads as a diff — every tracked file it removes counts.

    Asked as TWO pathspecs, which is not redundancy. Git's directory-prefix
    rule — the thing that makes the bare path `fixtures/.codeyam` match every
    file beneath it — applies only to a LITERAL pathspec. The moment the
    operand carries a glob the pattern is fnmatched instead, and
    `crates/*/.codeyam` matches no file at all, because the real entries carry
    a `/editor.json` tail the pattern does not cover. That is exactly the shape
    that would wipe the fixture out of every crate at once, so it cannot be the
    one shape that slips through. Appending `/*` gives the glob case a pattern
    that does match, and costs the literal case nothing (`ls-files` reports
    each index entry once however many pathspecs select it).

    Returns 0 when the path escapes the repo, is not pathspec-safe, or git
    cannot answer. Those are all "this guard has nothing to say", not "this is
    safe": a path outside the repo is not git's to protect, and a guard that
    blocked on an unanswerable question would refuse ordinary `rm -rf /tmp/…`
    and `rm -rf node_modules` on every project where git happens to be
    unavailable.

    Two shapes are statically undecidable and therefore NOT covered, by
    construction rather than by oversight: an unexpanded variable
    (`rm -rf "$BUILD_DIR"`) and a `find … -exec rm -rf {} +` placeholder. In
    both the operand names no path until the shell or `find` produces one, and
    refusing on unknowability would refuse the legitimate majority of both
    shapes. This is the same best-effort boundary `_has_inplace_editor` and
    `_uses_pcre_grep` draw."""
    rel = _repo_relative(path, project_dir)
    if rel is None or not _PATHSPEC_SAFE.match(rel):
        return 0
    try:
        result = subprocess.run(
            ["git", "ls-files", "-z", "--", rel, f"{rel.rstrip('/')}/*"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception:
        return 0
    if result.returncode != 0:
        return 0
    return len([p for p in result.stdout.split("\0") if p])


def tracked_recursive_rm(command, project_dir):
    """`(path, tracked_count)` for the first recursive-`rm` target in `command`
    that git tracks, else None. `tracked_count` is None when the segment could
    not be tokenized.

    Scoped per split command, so a delete buried in an `&&` chain is seen on its
    own, and re-entered for a `bash -c` payload — the two shapes that would
    otherwise hide the operand inside a single opaque token.

    Fails closed on a malformed quote, but only for a segment that textually
    looks like a recursive `rm`. The blanket fail-closed its sibling predicates
    use (`_has_inplace_editor` returns True for any untokenizable command) would
    refuse every mistyped quote in every session; narrowing it to the shape this
    guard is about keeps the evasion path shut without that cost."""
    for segment in _split_commands(command):
        try:
            tokens = shlex.split(segment, posix=True)
        except ValueError:
            if _RM_TEXTUAL.search(segment) and _RM_TEXTUAL_RECURSIVE.search(segment):
                return (segment.strip(), None)
            continue
        for operand in recursive_rm_operands(tokens):
            count = tracked_file_count(operand, project_dir)
            if count:
                return (operand, count)
        payload = _shell_c_payload(tokens)
        if payload is not None:
            nested = tracked_recursive_rm(payload, project_dir)
            if nested:
                return nested
    return None


def recursive_rm_refusal(path, tracked_count):
    """The `(reason, next_action)` pair for a refused recursive delete.

    Names the path, the count, and `git rm -r` — the count is what turns "this
    looked like build output" into a fact the author can check, and `git rm` is
    the same deletion in a form that is staged, reviewable, and undoable."""
    if tracked_count is None:
        return (
            f"this command could not be parsed, and it looks like a recursive "
            f"`rm`: `{path}`. The hook cannot tell whether it would delete "
            f"git-tracked files, and a recursive delete is not recoverable from "
            f"the transcript.",
            "fix the quoting and re-run, so the target can be checked against "
            "git. If the delete is genuinely aimed at tracked files, run "
            "`git rm -r <path>` instead.",
        )
    return (
        f"this command recursively deletes `{path}`, which holds "
        f"{tracked_count} git-tracked file(s). Tracked files are not build "
        f"output — a directory that looks like cache can be a committed test "
        f"fixture (`crates/*/.codeyam/` is exactly that, while `.codeyam/` at "
        f"the repo root is real internal state). Nothing surfaces the loss "
        f"until a later `git status`.",
        f"if you mean to delete it, run `git rm -r {path}` — the same removal, "
        f"staged and reversible (`git restore --staged {path}` then "
        f"`git checkout -- {path}`) and visible in review. If you meant to clear "
        f"generated output, name the untracked path directly; untracked paths "
        f"(`target/`, `node_modules/`, scratch dirs) are not guarded.",
    )


def read_event():
    """The PreToolUse event from stdin, or None when it is absent or
    unparseable — in which case the hook allows rather than blocks."""
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return None
        return json.loads(raw)
    except Exception:
        return None


# Internal `.codeyam/` state stores that have a purpose-built inspector,
# mapped to the command that answers questions about them. Ordered
# most-specific-path first so `.codeyam/test-cache/blobs/…` matches the
# cache inspector rather than a broader prefix.
#
# These are stores whose on-disk shape is INTERNAL and undocumented at the
# read site: a hand-rolled walk has to guess whether a field is a string
# or a list, and the observed failures were exactly that guess going wrong
# (`'list' object has no attribute 'split'`, `JSONDecodeError` on a
# blob file that had been externalized). The inspectors interpret the
# store instead, so the question is answerable without knowing the schema.
_INSPECTOR_BY_STORE = [
    (".codeyam/logs/audit-history.jsonl", "audit-history"),
    (".codeyam/state/finalize-debt.json", "finalize-debt"),
    (".codeyam/state/last-advance.txt", "step-handoff --section <NAME> (bare to list sections)"),
    (".codeyam/dependency-graph.json", "deps-imports / deps-imported-by"),
    (".codeyam/test-registry.json", "registry-query"),
    (".codeyam/per-test-evidence.json", "evidence-query"),
    (".codeyam/project-deliverables.json", "deliverables"),
    (".codeyam/editor.local.json", "config-show --source"),
    (".codeyam/scenarios/coverage-plan", "scenario-coverage-plan"),
    (".codeyam/scenarios/_shared", "shared-data"),
    (".codeyam/editor-step.json", "step"),
    (".codeyam/glossary.json", "glossary-find / glossary-list"),
    (".codeyam/editor.json", "config-query (testRunners / staticChecks) / config-show"),
    (".codeyam/stack.json", "project-info"),
    (".codeyam/scenarios", "scenarios / scenario-explain"),
    (".codeyam/test-cache", "test-cache-query"),
    (".codeyam/journal", "journal-find"),
    (".codeyam/plans", "plans / plan-show"),
]

# A path under `.codeyam/` naming something more specific than the
# directory itself. Used only for the no-inspector case, so `ls .codeyam/`
# — an ordinary first look around — stays quiet while a probe of a
# particular state file is answered.
_CODEYAM_STATE_PATH = re.compile(r"\.codeyam/[A-Za-z0-9_.][A-Za-z0-9_./+-]*")

# Read-shaped commands, matched in COMMAND POSITION — at the start of the
# string or just after a shell separator, allowing leading `VAR=value`
# assignments and transparent prefixes. Position is what distinguishes a
# probe from an incidental mention: `git ls-files .codeyam/glossary.json`
# and `git add .codeyam/test-registry.json` both name a store without
# reading it the way this nudge is about, and neither matches here.
#
# The verb set is the python forms the nudge has always covered plus the
# shell reads agents actually reach for. The rationale in
# `inspector_nudge`'s docstring was never python-specific: `ls` on a
# guessed path re-derives a store's layout exactly the way a python walk
# re-derives its schema, and fails the same way.
#
# `sed` and `awk` are here because their absence made the one idiom that
# actually dropped instructions — `sed -n '160,260p'` on the saved step
# hand-off — invisible to this nudge entirely. A windowed `sed` on a guessed
# anchor re-derives a store's layout the same way; widening the verb set
# widens the nudge for every `.codeyam/` store, which is the intended
# direction (a broader net argues for keeping the instrument soft, not for
# narrowing the net).
_READ_VERB = re.compile(
    r"""(?:\A|[\n;|&`(]|\$\()\s*
        (?:[A-Za-z_][A-Za-z_0-9]*=\S*\s+)*
        (?:(?:sudo|command|time|xargs)\s+)*
        (?:python3?|ls|cat|head|tail|wc|jq|grep|find|sed|awk)\b
    """,
    re.VERBOSE,
)

# A `codeyam-editor editor …` invocation, under either the canonical name
# or the local-dev branding.
_INSPECTOR_INVOCATION = re.compile(r"\bcodeyam-editor(?:-dev)?\s+editor\b")


def is_read_shaped_command(command):
    """True when `command` READS something in command position — a python
    invocation or a shell read verb.

    Pure and side-effect free so the predicate can be tested directly,
    separately from the store mapping it gates."""
    return bool(_READ_VERB.search(command))


def is_inspector_invocation(command):
    """True when `command` runs a `codeyam-editor editor …` subcommand.

    An inspector necessarily names the store it inspects, so nudging one
    would point the agent at the command it is already running."""
    if _INSPECTOR_INVOCATION.search(command):
        return True
    return f"{cli_command()} editor " in command


def matching_inspector(command):
    """The `(store, inspector)` pair `command` touches, or None.

    Separated from the message that reports it so the
    longest-path-first ordering of `_INSPECTOR_BY_STORE` — which is what
    keeps `.codeyam/scenarios/_shared/…` from resolving to the broader
    scenarios entry — is assertable without going through message text."""
    for store, inspector in _INSPECTOR_BY_STORE:
        if store in command:
            return (store, inspector)
    return None


def probed_state_path(command):
    """The `.codeyam/` state path `command` names, or None.

    A bare `.codeyam/` is deliberately not a match: listing the
    directory is an ordinary first look around, not a probe of a
    particular store, and nudging it would be noise."""
    match = _CODEYAM_STATE_PATH.search(command)
    return match.group(0) if match else None


def inspector_nudge(command):
    """Return a pointer to the matching inspector when `command` reads a
    `.codeyam/` state store, else None. When the probed store has no
    inspector, say so rather than staying silent — the absence is a fact
    worth reporting, since silence reads as "no such command found".

    Pure and side-effect free so the mapping can be tested directly.

    This is a NUDGE, never a block. Reading internal state by hand is
    wasteful, not incorrect — the reader re-derives a shape that a
    command already knows, and gets it wrong often enough to cost a turn
    plus a re-read. That asymmetry is what makes a pointer the right
    instrument and a refusal the wrong one: a block would strand an agent
    whose question genuinely has no inspector. It matters more under the
    wider trigger, not less — a broader net means more false positives,
    which is an argument for keeping the instrument soft."""
    # Heredoc bodies are elided for the same reason the gates elide them: a
    # commit message that MENTIONS `.codeyam/glossary.json` is prose, and
    # nudging it would point at an inspector for a store nothing is reading.
    command = elide_heredoc_bodies(command)
    if is_inspector_invocation(command):
        return None
    if not is_read_shaped_command(command):
        return None
    matched = matching_inspector(command)
    if matched:
        store, inspector = matched
        return (
            f"NOTE: this reads {store} — an internal codeyam state store. "
            f"`{cli_command()} editor {inspector}` answers questions about it directly, "
            f"and interprets the store rather than dumping it, so the field shapes are "
            f"named instead of guessed. Not blocking; your command still runs."
        )
    probed = probed_state_path(command)
    if probed:
        return (
            f"NOTE: this reads {probed} — internal codeyam state with no "
            f"read-only inspector. No `{cli_command()} editor` verb interprets it, so "
            f"reading the file is the only option here; the absence is real, not "
            f"something you missed. Not blocking; your command still runs."
        )
    return None


# ── windowed hand-off read guard ───────────────────────────────────────
#
# The saved step hand-off is an INSTRUCTION file, and a window of one is the
# single read shape with no trustworthy interpretation: the lines that come
# back are accurate, and nothing in them says a section body was cut.
#
# Observed: an agent read its step-3 hand-off with
# `sed -n '160,260p' .codeyam/state/last-advance.txt`. The window ended
# exactly on a `━━━ ASK WHETHER TO KEEP ASKING ━━━` banner, so it got the
# heading and none of the body, never asked the question that section told it
# to ask, and had no signal anything was missing — the read exited 0 with text
# that looked complete BECAUSE it ended on a heading. The user caught it turns
# later.
#
# BLOCK, not notice — the opposite call from `inspector_nudge` above, and the
# asymmetry is what decides it. Hand-parsing a JSON store is wasteful but
# recoverable inside the same turn; a half-read instruction file costs
# SILENTLY UNEXECUTED INSTRUCTIONS discovered turns later. This is the hook's
# own criterion for its blocking half: the cases where there is no reading
# under which the result is trustworthy. And a block strands nobody, which is
# the condition `inspector_nudge` reasons from in the other direction —
# `cat` and `step-handoff --section` are always-available COMPLETE
# alternatives, so there is no legitimate question this refusal leaves
# unanswerable.
#
# `grep` and a whole-file `cat` stay allowed on purpose: locating a section is
# not reading a window of one, and `cat` is the recovery the pointer line has
# always named.
_HANDOFF_STORE = ".codeyam/state/last-advance.txt"

# The hand-off text lives in FIVE places, byte-identical, and this guard used to
# reach one of them. The other four are what an agent actually reaches for once
# the `cat` is truncated, so a guard on the canonical path alone was a fence
# across the least-used door:
#
#   1. `.codeyam/state/last-advance.txt`      — the canonical store.
#   2. `.codeyam/state/last-step-show.txt`    — the read-only `--show` render.
#   3. `.codeyam/state/command-output/runs/advance-<runId>.txt`
#                                             — the run-keyed transcript.
#   4. the harness's persisted tool result    — an OPAQUE filename, so it is
#                                               matched by CONTENT, below.
#   5. the harness's task output for a
#      BACKGROUNDED command                   — likewise matched by CONTENT.
#
# Observed on the mirrors specifically: `sed -n '1,200p' …/tool-results/<id>.txt
# | sed -n '40,200p'` at three separate steps of one session, and an
# `awk '/━━━ ASK WHETHER TO KEEP ASKING ━━━/,…'` over the run-keyed transcript
# in another. Identical hazard, unguarded.
#
# Door 5 is the MOST travelled of the five, not a corner case: `advance` is in
# `_GATING_SUBCOMMANDS`, so every advance is auto-backgrounded and its hand-off
# lands in the task output, which the agent then retrieves with `wait-for`. One
# session windowed exactly that FOURTEEN times, once per step, with
# `wait-for … | sed -n '/BEGIN STEP/,$p' | head -12` — a window that starts AT
# the banner, so the checklist the trailer says is "printed above this trailer"
# is discarded wholesale, and then ends on another banner, handing back a
# heading with no body. It reads as complete and is not.
#
# Widening this is only safe BECAUSE the delivery side landed with it: blocking
# the mirrors while `cat` still truncated would have left no way to read a
# hand-off at all. That is why the plan made them one change.
_HANDOFF_PATH_MIRRORS = (
    _HANDOFF_STORE,
    ".codeyam/state/last-step-show.txt",
)

# The run-keyed transcript. A regex because the run id varies per invocation.
_HANDOFF_RUN_TRANSCRIPT = re.compile(
    r"\.codeyam/state/command-output/runs/advance-[0-9a-fA-F-]+\.txt"
)

# A harness-persisted tool result. The filename carries no hint of what is in
# it, so the path shape only makes a file a CANDIDATE — whether it holds a
# hand-off is decided by reading it.
_HANDOFF_TOOL_RESULT = re.compile(r"[^\s'\"]*/tool-results/[^\s'\"]+\.txt")

# A harness task output for a backgrounded command. Same deal as the tool
# result above: the id is opaque, so the path shape only makes a file a
# CANDIDATE and the content sniff decides. This is where every backgrounded
# `advance` puts its hand-off.
#
# Deliberately NOT anchored on the `/tmp/claude-<uid>/<project>/<session>/`
# prefix, for the same reason spelled out for `_HARNESS_TOOL_RESULT_TRANSCRIPT`
# below: that prefix is not stable — `/tmp/claude-0/-workspace/…` in a fleet
# container, `/tmp/claude-501/-Users-…/…` on a laptop. The `/tasks/` segment is
# the part that does not move. Requiring the literal leading slash keeps
# `my-tasks/x.output` out.
_HANDOFF_TASK_OUTPUT = re.compile(r"[^\s'\"]*/tasks/[^/\s'\"]+\.output\b")

# The two shapes above are the CONTENT-SNIFFED ones: both are named by an
# opaque harness id, so neither can be decided from the path alone. Grouped so
# the sweep below states that strategy once — a sixth door of this kind is one
# entry here, not another copy of the same three lines.
_HANDOFF_CONTENT_SNIFFED = (_HANDOFF_TOOL_RESULT, _HANDOFF_TASK_OUTPUT)

# What identifies a persisted tool result as holding a hand-off: the pointer
# token `advance` prints, or the banner shape every step body is fenced with.
# `step-handoff --section` answers carry neither banner (theirs are
# `━━━ <NAME> ━━━`), so that command prints the pointer token as its first
# stdout line — one marker here, not a second grammar to learn.
# Read from a bounded prefix — enough to see a hand-off's opening banner, small
# enough that a PreToolUse hook never stalls on a large file.
_HANDOFF_CONTENT_MARKERS = ("CODEYAM_FULL_HANDOFF", "━━━ BEGIN STEP ")
_HANDOFF_SNIFF_BYTES = 8192


def _handoff_paths_in(text):
    """Every hand-off-carrying path `text` names, opaque tool results included.

    Returns the literal substrings found, so callers can test stage membership
    the same way the single-path version did."""
    found = [store for store in _HANDOFF_PATH_MIRRORS if store in text]
    found.extend(match.group(0) for match in _HANDOFF_RUN_TRANSCRIPT.finditer(text))
    # Content-gated, and for the task output the reason is sharper than for the
    # tool result: a task output is only a hand-off SOMETIMES. Most backgrounded
    # commands are test runs, commits, rebuilds — outputs an agent has every
    # right to window. Measured across eight sessions: 49 windowed `wait-for`
    # reads, of which 14 carried a hand-off. Refusing the other 35 would strand
    # agents for no benefit, which is what the sniff's fail-open exists to avoid.
    for pattern in _HANDOFF_CONTENT_SNIFFED:
        found.extend(
            match.group(0)
            for match in pattern.finditer(text)
            if _file_holds_handoff(match.group(0))
        )
    return found


def _file_holds_handoff(path):
    """True when `path` is readable and its opening bytes carry a hand-off.

    Content-sniffed rather than name-matched because the harness names these
    files by an opaque id. Fails OPEN — an unreadable or missing path is not a
    hand-off — because this guard's job is to refuse a read of a KNOWN
    instruction file, and refusing an unrelated tool result the agent has every
    right to window would strand it for no benefit."""
    try:
        with open(path, "rb") as handle:
            head = handle.read(_HANDOFF_SNIFF_BYTES).decode("utf-8", "replace")
    except OSError:
        return False
    return any(marker in head for marker in _HANDOFF_CONTENT_MARKERS)

# The command-position anchor is `_READ_VERB`'s, for the same reason: position
# is what separates a read from an incidental mention, so the path quoted in a
# commit message or handed to `git add` is not a hit.
_HANDOFF_VERB_ANCHOR = r"""(?:\A|[\n;|&`(]|\$\()\s*
        (?:[A-Za-z_][A-Za-z_0-9]*=\S*\s+)*
        (?:(?:sudo|command|time|xargs)\s+)*
    """

# `head`/`tail` truncate with or WITHOUT an explicit `-n`: a bare
# `head FILE` is already a ten-line window, which is why no flag is required.
_HANDOFF_HEAD_TAIL = re.compile(_HANDOFF_VERB_ANCHOR + r"(head|tail)\b", re.VERBOSE)
_HANDOFF_SED = re.compile(_HANDOFF_VERB_ANCHOR + r"(sed)\b", re.VERBOSE)
_HANDOFF_AWK = re.compile(_HANDOFF_VERB_ANCHOR + r"(awk)\b", re.VERBOSE)

# A `sed` address that truncates by LINE NUMBER: `160,260p`, `1,+20p`,
# `160,$p`, `40p`, `260q`, `1,100d`. A `sed` carrying no such address is not
# windowing by line and is left alone — a substitution whose replacement
# happens to contain a digit does not reach `[pqd]`.
_SED_LINE_WINDOW = re.compile(r"\d+\s*(?:,\s*(?:\d+|\+\d+|\$))?\s*[pqd]\b")

# A `sed` address that truncates by PATTERN RANGE: `/BEGIN STEP/,$p`,
# `/^# Backend Flow/,/━━━ TASK ━━━/p`. Anchoring on a banner is the most
# natural way to carve one section out of a hand-off, and it is the shape the
# refusal describes — a range that ENDS on a banner hands back a heading with
# no body. A single `/PATTERN/p` with no range is a filter, not a window.
# Applied to LIVE output only (`_live_handoff_idiom`).
_SED_PATTERN_WINDOW = re.compile(r"/[^/]+/\s*,\s*(?:/[^/]+/|\d+|\+\d+|\$)\s*[pqd]")

# `awk` truncates when it guards on the record number.
_AWK_NR = re.compile(r"\bNR\b")

# The `sed` pattern range above, spelled in awk:
# `awk '/━━━ ASK WHETHER TO KEEP ASKING ━━━/,/━━━/'`. Live output only.
_AWK_PATTERN_RANGE = re.compile(r"/[^/]+/\s*,\s*/[^/]+/")

# A stage that REDUCES the store to a match list rather than emitting a
# contiguous body. Truncating a match list is not reading a window of one
# section, which is why the glossary names grep and wc as non-matches.
_HANDOFF_REDUCER = re.compile(
    _HANDOFF_VERB_ANCHOR + r"(grep|egrep|fgrep|rg|wc)\b", re.VERBOSE
)


def _handoff_idiom(stage):
    """The truncating idiom `stage` runs, or None.

    Stage-scoped on purpose: whether that truncation actually lands on the
    hand-off's body is the CALLER's question, because the answer depends on
    what the rest of the pipeline feeds it."""
    head_tail = _HANDOFF_HEAD_TAIL.search(stage)
    if head_tail:
        return head_tail.group(1)
    if _HANDOFF_SED.search(stage) and _SED_LINE_WINDOW.search(stage):
        return "sed"
    if _HANDOFF_AWK.search(stage) and _AWK_NR.search(stage):
        return "awk"
    return None


def _live_handoff_idiom(stage):
    """The truncating idiom `stage` runs over LIVE hand-off output, or None.

    `_handoff_idiom` plus the pattern ranges. Over live output a banner-anchored
    range is the commonest window there is — the line numbers are not known
    until the command has run, so a pattern is what agents reach for."""
    idiom = _handoff_idiom(stage)
    if idiom:
        return idiom
    if _HANDOFF_SED.search(stage) and _SED_PATTERN_WINDOW.search(stage):
        return "sed"
    if _HANDOFF_AWK.search(stage) and _AWK_PATTERN_RANGE.search(stage):
        return "awk"
    return None


def _handoff_emits_body(upstream):
    """True when some stage in `upstream` emits a contiguous BODY of a store.

    Fails CLOSED: any stage that reads a hand-off and is not a recognised
    reducer counts as a body emitter, so an unfamiliar reader piped into
    `head`/`tail` is still refused."""
    return any(
        _handoff_paths_in(stage) and not _HANDOFF_REDUCER.search(stage)
        for stage in upstream
    )


def windowed_handoff_read(command):
    """Return the truncating idiom `command` uses to read a WINDOW of the
    saved step hand-off, or None.

    Fires only when the command BOTH names a hand-off-carrying file (see
    `_handoff_paths_in` for the five of them) AND truncates it. A persisted
    tool result and a backgrounded command's task output are matched by
    CONTENT, so windowing an unrelated one is not a hit. Heredoc bodies are
    elided first, for the same reason every other guard elides them: a commit
    message that quotes the path is prose, not a read.

    A bare `cat`, a `grep`, and a `wc -l` of the same path are deliberately
    NOT matches. Reading the file whole is the recovery this guard points at,
    and locating a section by name is how an agent legitimately discovers what
    to ask `--section` for — refusing either would break the way out.

    The match is STAGE-SCOPED, not whole-command: a truncating verb counts only
    when its own stage names the store, or when an upstream stage in the SAME
    pipeline emits the store's body. Scanning the whole string refused
    `grep PATTERN FILE | head` — which truncates grep's OUTPUT, not the file —
    and refused a `head` belonging to an entirely different command joined by
    `;`, handing the agent a refusal that named its own command as permitted.

    Pure and side-effect free, so the idiom set is assertable directly without
    going through captured stdout."""
    if not command:
        return None
    command = elide_heredoc_bodies(command)
    if not _handoff_paths_in(command):
        return None
    for pipeline in _pipelines(command):
        for index, stage in enumerate(pipeline):
            idiom = _handoff_idiom(stage)
            if not idiom:
                continue
            if _handoff_paths_in(stage) or _handoff_emits_body(pipeline[:index]):
                return idiom
    return None


# Door six — and it names no path at all. Every door above is a FILE the
# hand-off was written to; this one is the LIVE stdout of the command that
# produces it, windowed before it lands anywhere:
# `advance 2>&1 | sed -n '/^# Backend Flow/,/━━━ TASK ━━━/p'`,
# `step-handoff --section a,b,c | head -5`. A path sweep cannot see it because
# there is no path to sweep, and it carries the traffic: measured across 59
# fleet sessions, 239 windowed live reads in 42 of them, none refused, against
# 29 refusals on the five file doors combined. A seventh producer is one entry
# here.
_HANDOFF_PRODUCING_SUBCOMMANDS = frozenset(("advance", "step", "step-handoff"))

# The position-blind fallback for a stage `shlex` cannot tokenize, so a
# malformed quote is never an evasion path. `step-handoff` is listed before
# `step` because `step\b` also matches at the hyphen.
_HANDOFF_PRODUCER_INVOCATION = re.compile(
    r"\bcodeyam-editor(?:-dev)?\s+editor\s+(step-handoff|advance|step)\b"
)

# An inverted match passes nearly everything through, so `grep -v heartbeat`
# is a filter, not a reducer — and it is exactly what the measured
# banner-ended window was hidden behind.
_INVERTED_MATCH = re.compile(r"(?:^|\s)(?:-[A-Za-z]*v[A-Za-z]*|--invert-match)\b")


def _handoff_subcommand(stage):
    """The hand-off-producing `codeyam-editor editor <subcommand>` that
    `stage` RUNS, or None — `"step-handoff --section"` for a section answer,
    the one read the command exists to make complete.

    Position-aware for the reason `_gating_subcommand` is: the name is only an
    invocation when it is the program the stage runs, so
    `grep "editor advance" notes.md | head` is not a hit."""
    try:
        tokens = shlex.split(stage, posix=True)
    except ValueError:
        match = _HANDOFF_PRODUCER_INVOCATION.search(stage)
        return match.group(1) if match else None
    for index, tok in enumerate(tokens):
        if _program_name(tok) not in _CODEYAM_CLIS:
            continue
        if not _in_command_position(tokens, index):
            continue
        rest = tokens[index + 1:]
        if len(rest) >= 2 and rest[0] == "editor" and rest[1] in _HANDOFF_PRODUCING_SUBCOMMANDS:
            if rest[1] == "step-handoff" and any(
                arg == "--section" or arg.startswith("--section=") for arg in rest[2:]
            ):
                return "step-handoff --section"
            return rest[1]
    return None


def _reduces_output(stage):
    """True when `stage` reduces its input to a match list or a count, so a
    window downstream of it truncates THAT, not the hand-off — the same
    carve-out the path guard makes for `grep FILE | head`."""
    return bool(_HANDOFF_REDUCER.search(stage)) and not _INVERTED_MATCH.search(stage)


def windowed_live_handoff(command):
    """`(subcommand, idiom)` when `command` pipes the LIVE output of a
    hand-off-producing subcommand into a truncating stage, or None.

    Evaluated per pipeline, so a window buried in the second of three
    `;`/`&&`-joined commands is still seen, and a `head` belonging to a
    different command is not. A pipe into `grep` stays allowed for the reason
    it does on the path guard: a search is not a window and does not present
    itself as a complete read. A bare run is never a match.

    Pure, so the idiom set is assertable directly."""
    if not command:
        return None
    command = elide_heredoc_bodies(command)
    for pipeline in _pipelines(command):
        for index, stage in enumerate(pipeline):
            subcommand = _handoff_subcommand(stage)
            if not subcommand:
                continue
            for downstream in pipeline[index + 1:]:
                if _reduces_output(downstream):
                    break
                idiom = _live_handoff_idiom(downstream)
                if idiom:
                    return subcommand, idiom
    return None


def handoff_refusal_collateral(command):
    """The pipelines of `command` that read no hand-off window — what a
    pre-execution refusal discards along with the read.

    The hook refuses the WHOLE call, so in `sed -n 392,420p <hand-off>; cargo
    fmt` the `cargo fmt` never runs. 11 of 29 measured refusals were compound
    like that, one of them discarding a `track-step completed` workflow
    mutation, and nothing said so. Naming them is the fix."""
    collateral = []
    for pipeline in _pipelines(elide_heredoc_bodies(command or "")):
        text = " | ".join(stage.strip() for stage in pipeline)
        if windowed_handoff_read(text) or windowed_live_handoff(text):
            continue
        collateral.append(text)
    return collateral


def windowed_handoff_read_tool(tool_input):
    """The truncating idiom a `Read` TOOL call uses on the saved step hand-off,
    or None.

    The `Read` tool reaches the same failure through a different door:
    `offset`/`limit` are a line window by another name, and the unconditional
    read-only allow further down would wave it through.

    Split out of `main()` for the reason the Bash half already is — a pure
    predicate is assertable directly, where three lines inlined in `main()`
    can only be reached end-to-end through a captured exit code.

    `file_path` is matched on its normalised tail, so an absolute path answers
    the same as a project-relative one. A `Read` carrying NEITHER key is a
    whole-file read and deliberately not a match: that is one of the two
    complete alternatives the refusal points at."""
    tool_input = tool_input or {}
    path = str(tool_input.get("file_path") or "").replace("\\", "/")
    if not _handoff_paths_in(path):
        return None
    if tool_input.get("offset") is None and tool_input.get("limit") is None:
        return None
    return "Read offset/limit"


def windowed_handoff_read_refusal(idiom, subcommand=None, collateral=()):
    """The `(reason, next_action)` pair for a windowed hand-off read.

    `subcommand` is set for door six — the live output of `advance`, `step`,
    or `step-handoff` — and swaps the opening for one that names the command,
    since there is no file in the call to point at. A `--section` answer gets
    one more sentence: there the window is self-defeating, because the answer
    ENDS with the line naming any required section the request did not show,
    and a window short of the whole answer deletes exactly that line.

    `collateral` lists the parts of a compound command that did not run —
    the refusal fires before execution, so they were discarded with the read.

    The reason states the failure CONCRETELY — a window can end on a banner
    and yield a heading with no body. The abstract version ("you might miss
    something") is exactly what an agent holding accurate-looking text
    discounts, which is how this failed the first time.

    The next action names `step-handoff --section` FIRST, and says why it
    beats the line range the agent may already be holding. `HandoffSection`
    publishes `start_line`/`end_line` and documents them as meaning what
    `sed -n 'A,Bp'` means, so an agent that ran `step-handoff` is actively
    INVITED to sed the range it was handed. Refusing that read is still right
    — the arithmetic is the hazard, and a copied range is complete only if it
    was copied exactly — so the recovery has to say the named form reaches the
    same answer without any of it."""
    if subcommand:
        opening = (
            f"this pipes the LIVE output of `{cli_command()} editor {subcommand}` "
            f"into `{idiom}`, which reads a WINDOW of a step hand-off — the same "
            f"text it saves to `{_HANDOFF_STORE}`. That is "
        )
    else:
        opening = (
            f"this reads a WINDOW of a saved step hand-off with `{idiom}`. That is "
        )
    section_clause = ""
    if subcommand == "step-handoff --section":
        section_clause = (
            " For a `--section` answer the window is self-defeating: you asked "
            "for COMPLETE sections, and the answer ends with the line "
            "`step-handoff: N REQUIRED section(s) of this step are NOT shown "
            "above: …` — the one signal that your narrowing dropped an "
            "instruction. Any window short of the whole answer deletes that "
            "trailer first."
        )
    live_clause = ""
    if subcommand:
        live_clause = (
            "run it WITHOUT the window — the command already saves and prints "
            "its complete answer, and a `--section` request is already as "
            "narrow as you asked for. To narrow further, "
        )
    collateral_clause = ""
    if collateral:
        listed = "; ".join(f"`{part}`" for part in collateral)
        collateral_clause = (
            f" The whole call was refused before it ran, so these parts of it "
            f"did NOT run either — re-issue them on their own: {listed}."
        )
    return (
        f"{opening}"
        f"an instruction file, and a window of one is the single read shape "
        f"with no trustworthy interpretation: the lines that come back are "
        f"accurate, and nothing in them tells you a section body was cut. A "
        f"window that ends on a `━━━ … ━━━` banner hands back a heading with "
        f"no body — it reads as complete and is not, which is how a whole "
        f"section's instructions went unexecuted and were caught only turns "
        f"later. The same text lives in `{_HANDOFF_STORE}`, in the run-keyed "
        f"transcript, and in the harness's persisted tool result, so this "
        f"applies wherever you reached it.{section_clause}",
        f"{live_clause}"
        f"read it by NAMED SECTION: `{cli_command()} editor step-handoff "
        f"--section <NAME>` returns one COMPLETE section, marks which sections "
        f"are REQUIRED, and now reports any required section your request did "
        f"not show — so narrowing no longer risks dropping an instruction "
        f"silently. Run it bare to list the sections this hand-off has. If "
        f"this window is of a persisted `--section` answer that was too large "
        f"to show, re-run that request: an answer that large is now written "
        f"one section per file under `.codeyam/state/handoff-sections/`, and "
        f"it prints one `cat` line per section, each a COMPLETE read. `cat "
        f"{_HANDOFF_STORE}` still returns all of it. Line numbers printed by "
        f"`step-handoff` are NOT a licence to `sed` the range back — the named "
        f"form gives the same answer with none of the arithmetic. `grep`, "
        f"`wc -l`, and a bare `cat` of this file are unaffected, and so is a "
        f"pipe of the live output into `grep`.{collateral_clause}",
    )


# ── scripted state-read guard ──────────────────────────────────────────
#
# `inspector_nudge` above is the SOFT, editor-mode-only pointer: it fires on
# any read verb touching `.codeyam/` and it only ever advises. This guard is
# the narrow, always-on companion for the one shape that keeps recurring —
# a command that PARSES a `.codeyam/` store as JSON.
#
# The measurement that motivates it: across 12 autonomous sessions agents
# hand-parsed `.codeyam/` state with ad-hoc `json.load` heredocs 84 times in
# 10 of the 12, producing 12 `JSONDecodeError` crashes. `journal-commit-message`
# scored ZERO uses against 34 hand-rolls and 36 hardcoded timestamps — and it
# was already documented by name in the very CLAUDE.md table whose other
# commands enjoy healthy adoption. Prose has now failed twice on that one, so
# it gets the mechanical instrument instead.
#
# Two verdicts, and the split is deliberate:
#
#   NOTICE for a mapped store — reading state by hand is wasteful, not
#   incorrect, and a block would strand a legitimate one-off inspection.
#   Same asymmetry `inspector_nudge` reasons from.
#
#   BLOCK for the two cases where there is no reading under which the
#   result is TRUSTWORTHY. Parsing `state/command-output/*` is parsing a
#   live tee of two interleaved streams — not a document, and no
#   brace-matcher makes it one (one session wrote four successive
#   brace-balancing heredocs against it before giving up). Building a commit
#   body from a hand-named journal entry silently attributes another
#   feature's description, which is precisely what the command's own entry
#   resolution exists to prevent.
#
# It fires BEFORE the `CODEYAM_EDITOR_ACTIVE` short-circuit, unlike
# `inspector_nudge`: a commit body carrying the wrong feature's description
# is just as wrong outside the editor workflow as inside it.

# JSON-parsing constructs. Deliberately narrower than `_READ_VERB` — this
# guard has a blocking half, so it keys on the construct that makes the
# result untrustworthy rather than on reading in general.
_JSON_PARSE_CALL = re.compile(r"\b(?:json\.loads?|JSON\.parse)\s*\(")

# `jq` in COMMAND POSITION, mirroring `_READ_VERB`'s shape: a `jq` mentioned
# inside a filter string is not a parse of anything.
_JQ_INVOCATION = re.compile(
    r"""(?:\A|[\n;|&`(]|\$\()\s*
        (?:[A-Za-z_][A-Za-z_0-9]*=\S*\s+)*
        (?:(?:sudo|command|time|xargs)\s+)*
        jq\b
    """,
    re.VERBOSE,
)

# The transcript sidecar. Kept out of `_INSPECTOR_BY_STORE` on purpose: that
# table maps a store to the command that ANSWERS questions about it, and
# nothing answers questions about this file — the recovery is to re-run the
# original command differently, which is a refusal's job, not a pointer's.
_COMMAND_OUTPUT_STORE = ".codeyam/state/command-output"

# The scope is the FILE, not the directory, and that distinction is the whole
# point. The untrustworthiness is a property of one file shape — the `<cmd>.txt`
# tee of stdout AND stderr — never of the store that holds it. Its sibling
# `<cmd>.status.json` is a single clean JSON document, and reading it is the
# DOCUMENTED recovery after piping a command: `piped_gating_notice` hands the
# agent that exact path as `Real verdict: …`. A directory-prefix match therefore
# had this file refusing the read its own sibling guard prescribes — caught by
# dogfooding one command after the guard shipped, when `push` printed the
# sidecar path and reading it was blocked in the same session that added the
# block. Two guards in one file giving opposite instructions about one file.
#
# `<task>.heartbeat` is the same shape of read (a one-line liveness sidecar
# CLAUDE.md also directs agents to) and lives outside this directory, so it was
# never caught — but keying on the transcript rather than on a filename
# exception is what keeps it, and any future sidecar, correct by construction.
#
# Do NOT re-widen this to a `in command` membership test on the store.
_COMMAND_OUTPUT_TRANSCRIPT = re.compile(
    re.escape(_COMMAND_OUTPUT_STORE) + r"/[^/\s'\"]+\.txt\b"
)

# The HARNESS's own persisted tool-result transcript — the file Claude Code
# writes whenever a command's output exceeds the inline budget, and hands back
# as "Full output saved to: …/tool-results/<id>.txt". It is the same shape as
# the command-output tee above (both streams, bounded, written for a human),
# so it fails a scripted parse the same way, and agents reach for it for the
# same reason.
#
# Keyed on the `tool-results/<id>.txt` FILE, on the same terms and for the same
# reason as `_COMMAND_OUTPUT_TRANSCRIPT` above: match the file, never the
# directory it lives in. The lookbehind keeps `my-tool-results/x.txt` out.
#
# Deliberately NOT anchored on the `~/.claude/projects/` prefix, because that
# prefix is not stable: it is `/root/.claude/…` in a fleet container,
# `/Users/<name>/.claude/…` on a laptop, and anywhere at all under
# `CLAUDE_CONFIG_DIR`. The `tool-results/` segment is the part that does not
# move.
_HARNESS_TOOL_RESULT_TRANSCRIPT = re.compile(
    r"(?<![\w.-])tool-results/[^/\s'\"]+\.txt\b"
)

_HARNESS_TOOL_RESULTS_STORE = "tool-results"

# A journal entry named by a literal timestamp — the `<eyeballed-from-ls>`
# shape. A journal read that does NOT name one is an ordinary search and
# stays a notice pointing at `journal-find`.
#
# Kept out of `_INSPECTOR_BY_STORE` for the same reason `_COMMAND_OUTPUT_STORE`
# is, plus one specific to it: adding a `.codeyam/journal/entries` row ahead of
# `.codeyam/journal` would re-point `matching_inspector` — and therefore
# `inspector_nudge`, which is not what this change is about — at
# `journal-commit-message` for every journal read, including the searches
# `journal-find` genuinely answers. `test_matching_inspector_maps_the_journal_store`
# pins that mapping, and it is pinning the right thing.
_HAND_NAMED_JOURNAL_ENTRY = re.compile(r"\.codeyam/journal/entries/20\d\d-")

_JOURNAL_ENTRIES_STORE = ".codeyam/journal/entries"


def parses_json(command):
    """True when `command` parses JSON in process — a python/node parse call,
    or `jq` in command position.

    Pure and side-effect free so the construct test is assertable separately
    from the store mapping it gates."""
    return bool(_JSON_PARSE_CALL.search(command) or _JQ_INVOCATION.search(command))


def parses_command_output_transcript(command):
    """True when `command` names the command-output TRANSCRIPT — a
    `.codeyam/state/command-output/<cmd>.txt` path.

    Deliberately narrower than the store it lives in. The `.txt` tee is the
    unparseable file; the `<cmd>.status.json` sidecar beside it is a single
    clean JSON document that `piped_gating_notice` tells the agent to read.
    Both are named from the same `<cmd>` stem in the same directory, so the
    SUFFIX is the only thing that separates them — which is why the predicate
    keys on it and not on the directory prefix.

    Pure and side-effect free, and named rather than inlined into
    `scripted_state_read_target`, so the boundary between the two files is
    assertable directly instead of through a refusal's message text."""
    return bool(_COMMAND_OUTPUT_TRANSCRIPT.search(command))


def parses_harness_tool_result(command):
    """True when `command` names the harness's own tool-result TRANSCRIPT — a
    `…/tool-results/<id>.txt` path.

    The file-shaped counterpart to `parses_command_output_transcript`, and
    narrow for the same reason: it matches the `<id>.txt` capture itself, never
    the session directory holding it, so a future sibling written beside it is
    not swept in by a directory-prefix match — the boundary that had the
    command-output guard refusing the read of the `.status.json` its own other
    guard prescribes.

    Pure and side-effect free, and named rather than inlined into
    `scripted_state_read_target`, so the boundary is assertable directly
    instead of through a refusal's message text."""
    return bool(_HARNESS_TOOL_RESULT_TRANSCRIPT.search(command))


def writes_into_codeyam(command):
    """True when `command` WRITES to a `.codeyam/` path, or writes somewhere
    this parser cannot resolve.

    The exclusion that keeps the guard off the sanctioned path: CLAUDE.md
    explicitly blesses rewriting `.json` through a parser, and a heredoc that
    builds a scenario file reads its neighbours to do so. Judging such a
    command on its `json.load` alone would refuse the very construct the
    project asks for.

    Scoped to `.codeyam/` targets rather than to writes in general, so an
    ordinary `… > out.json` capture of a hand-parse is still seen. An opaque
    target counts, because a write this parser could not resolve may well be
    the scenario write."""
    explicit, opaque, _ = write_targets(command)
    if opaque:
        return True
    return any(".codeyam/" in path for path in explicit)


def scripted_state_read_target(command):
    """The `(kind, store, inspector)` a scripted JSON parse of codeyam state
    touches, or None when `command` is not one.

    `kind` is `"command-output"`, `"harness-tool-result"` or `"journal-entry"`
    for the three blocking cases, `"inspectable"` for a mapped store that only
    warrants a pointer. `inspector` is None for every blocking kind: each
    carries its recovery in `scripted_state_read_refusal` rather than in the
    shared store table, so none of them perturbs what `matching_inspector`
    reports.

    All three blocking cases are tested BEFORE the table lookup AND before the
    write exclusion. Order is the whole mechanism, twice over.

    Before the table, because a hand-named journal entry also matches the
    broader `.codeyam/journal` row, and letting the table win would downgrade
    a misattributed commit body to a pointer.

    Before the write exclusion, because the canonical failure WRITES: it reads
    a journal entry and writes the commit body out. When that output path is a
    variable rather than a literal, `write_targets` reports it opaque, and an
    exclusion applied first would suppress the block on precisely the shape
    the guard exists for. The exclusion protects the sanctioned scenario
    write, which is a `.codeyam/scenarios/` write — never a parse of the
    command-output tee, never a regex carved out of the harness's own capture
    of one, and never a commit body built from an eyeballed timestamp. No
    blocking case has a reading under which the result is trustworthy,
    whatever else the command does with it.

    Pure and side-effect free — the verdict is separated from the message
    that reports it so the mapping is assertable without going through
    message text, exactly as `matching_inspector` is.

    Heredoc bodies are elided on the same terms every other guard elides
    them: `elide_heredoc_bodies` keeps an EXECUTING body (`python3 - <<'EOF'`
    is a program) and drops a DATA one, so a commit message that quotes a
    `json.load(...)` line as prose — this feature's own plan file does — is
    not read as a parse of anything."""
    command = elide_heredoc_bodies(command)
    if is_inspector_invocation(command):
        return None
    if not parses_json(command):
        return None
    if parses_command_output_transcript(command):
        return ("command-output", _COMMAND_OUTPUT_STORE, None)
    if parses_harness_tool_result(command):
        return ("harness-tool-result", _HARNESS_TOOL_RESULTS_STORE, None)
    if _HAND_NAMED_JOURNAL_ENTRY.search(command):
        return ("journal-entry", _JOURNAL_ENTRIES_STORE, None)
    if writes_into_codeyam(command):
        return None
    matched = matching_inspector(command)
    if not matched:
        return None
    store, inspector = matched
    return ("inspectable", store, inspector)


def scripted_state_read_refusal(kind):
    """The `(reason, next_action)` pair for a refused scripted state read.

    Branches on the KIND, not the store, because the three blocking cases fail
    for unrelated reasons and want unrelated recoveries — one re-runs the
    original command with a different flag, one points at a document already on
    disk, and one swaps to a command that resolves the entry itself."""
    if kind == "command-output":
        return (
            f"this parses `{_COMMAND_OUTPUT_STORE}/<cmd>.txt`, which is a live "
            f"TEE of stdout AND stderr in arrival order. The JSON document sits "
            f"interleaved with narrative lines, so the file is not a JSON "
            f"document and no brace-matcher or regex rescue can make it one — "
            f"one session wrote four successive brace-balancing heredocs "
            f"against it before giving up.",
            f"if you only need the VERDICT, read the sibling "
            f"`{_COMMAND_OUTPUT_STORE}/<cmd>.status.json` — one clean JSON "
            f"document carrying the same `status` the `CODEYAM_CMD_COMPLETE` "
            f"line does, already on disk. That read is NOT blocked and needs no "
            f"re-run, which matters when the original command was a `push`, a "
            f"`commit`, or a `session-finalize`. If you need the full document "
            f"instead, re-run the ORIGINAL command with `--format json` and "
            f"redirect stdout ALONE (`{cli_command()} editor <command> "
            f"--format json > report.json`). Under `--format json` the marker "
            f"lines move to stderr, the narrative falls silent, and terminal "
            f"output bounding is disabled, so the redirect is exact and "
            f"complete.",
        )
    if kind == "harness-tool-result":
        return (
            f"this carves a document out of a `tool-results/<id>.txt` file — "
            f"the HARNESS's own persisted capture of a command's terminal "
            f"output, saved because that output was too large to show inline. "
            f"It holds both streams in arrival order and is bounded for a "
            f"human reader, so it is not a JSON document: a brace-matcher or "
            f"an `rfind`/`re.search` over it either throws or silently returns "
            f"a FRAGMENT, and the fragment is the worse outcome because "
            f"nothing about it looks wrong.",
            f"read the document itself — it is almost certainly already on "
            f"disk and needs no re-run. Any `--format json` run of a wrapped "
            f"command also writes "
            f"`{_COMMAND_OUTPUT_STORE}/runs/<cmd>-<runId>.json`: the stdout "
            f"document ALONE, no stderr narrative, not terminal-bounded, and "
            f"keyed on the RUN so a later narrower re-run cannot clobber it. "
            f"The command named that exact path on its own "
            f"`CODEYAM_FULL_OUTPUT: … — PARSEABLE:` line, so `cat` what the "
            f"pointer printed. If you only need ONE finding rather than the "
            f"whole document, recompute it cheaply instead of mining a large "
            f"one: `{cli_command()} editor audit --only <INVARIANT_ID> "
            f"--format json` (pass `--only ?` to list the ids), or the "
            f"read-only query surface for the store in question "
            f"(`registry-query`, `evidence-query`, `glossary-list`, "
            f"`scenarios --format entries`, …), each of which emits one clean "
            f"document with its rows under `entries`.",
        )
    return (
        f"this builds on a journal entry named by a LITERAL timestamp. The "
        f"entry matching the active feature is not necessarily the one whose "
        f"filename was read off an `ls`, so this can silently land on another "
        f"feature's entry — you read that feature's fields believing they are "
        f"this one's, or you commit its description as this feature's body. "
        f"Either way the wrong entry is invisible in the result, which is why "
        f"the filename is not the selector and entry resolution exists.",
        f"pick by what you are doing with it — all three resolve the ACTIVE "
        f"feature's entry, so none of them needs a timestamp. TO READ THE ENTRY: "
        f"`{cli_command()} editor journal-show` prints its title, type, "
        f"description, and references; `--format json` emits the standard "
        f"query-surface envelope, so "
        f"`{cli_command()} editor journal-show --format json` parses with the "
        f"same `entries` key as every other read-only surface. TO BUILD THE "
        f"COMMIT: `{cli_command()} editor journal-commit-message` prints the "
        f"finished message on stdout and nothing else, so "
        f"`{cli_command()} editor journal-commit-message | git commit -F -` "
        f"needs no temp file; add `--trailer '<line>'` (repeatable) for "
        f"`Co-Authored-By:` / `Claude-Session:` lines. TO CHANGE THE ENTRY: "
        f"`{cli_command()} editor journal-update '<json>'` patches it — omit "
        f"`time` from the payload and it lands on the active feature's entry "
        f"rather than on whichever entry is newest. This is the one to reach "
        f"for instead of rewriting the JSON by hand: picking the wrong entry "
        f"on a WRITE overwrites another feature's record, where the same "
        f"mistake on a read merely misinforms you. All three take "
        f"`--entry <path>` to override the resolution deliberately, and all "
        f"three report on stderr which entry they chose and why.",
    )


def scripted_state_read_notice(store, inspector):
    """The pointer text for a scripted parse of a store that has an inspector.

    Distinct from `inspector_nudge`'s wording because the caller's problem is
    distinct: they are not merely reading the store, they are re-deriving its
    SCHEMA, and the answer is that the inspector emits one clean document
    under `--format json`."""
    return (
        f"NOTE: this hand-parses {store} — an internal codeyam state store whose "
        f"schema is internal and moves, so a parse that is right today reads wrong "
        f"the day the shape changes. `{cli_command()} editor {inspector}` answers "
        f"the question directly and emits ONE clean JSON document under "
        f"`--format json`, with the row set always under `entries`. Not blocking; "
        f"your command still runs."
    )


def classify_write_target(file_path, project_dir):
    """How the slug gate should treat a Write/Edit target: `("outside", None)`,
    `("editor-state", rel)`, or `("code", rel)`.

    Two bugs of the same shape lived in the substring test this replaces.

    A path OUTSIDE the repository is not a code change at all, so the slug gate
    has nothing to say about it. It used to refuse one anyway: at
    `slug=commit`, `Write <scratchpad>/commit-msg.txt` exited 2 while
    `cat > <scratchpad>/commit-msg.txt <<'EOF'` — the same write, through the
    shell — was allowed. Agents took the second path and said so. That inverts
    the very property CLAUDE.md's scripted-rewrite ban exists to protect: a
    `Write` shows its content as a structured field in the transcript, a
    heredoc makes a reviewer reconstruct it from a shell string. The
    neighbouring rule already carves out temp paths and advertises it
    ("Writing to an untracked file, to /tmp, or to the scratchpad is
    unaffected"); this gate made that sentence false.

    And because the escape was a SUBSTRING (`"/.codeyam/" in file_path`), it
    keyed on a LEADING SLASH: `Write .codeyam/editor.json` was refused while
    `Write /x/.codeyam/editor.json` was allowed. Comparing a normalized
    repo-relative prefix is what makes the relative spelling — the one actually
    used — work.

    Repo-membership, not tracked-ness, is the predicate: a brand-new source
    file at a gate slug IS a code change."""
    rel = _repo_relative(file_path, project_dir)
    if rel is None:
        return ("outside", None)
    normalized = rel.replace("\\", "/")
    if normalized.startswith((".codeyam/", ".claude/")):
        return ("editor-state", normalized)
    return ("code", normalized)


def preview_marker_state(marker_path, step):
    """`(preview_ok, observed)` for the preview gate — whether the marker at
    `marker_path` matches `step`, and a human-readable account of what was
    actually found there.

    The `observed` half is the point. The gate compares a marker step to the
    current step and used to name neither, so the only way to debug a refusal
    was to read this source — which is what agents did. The three not-ok
    states are genuinely different problems (never shown, corrupt, shown at a
    different step) and want different responses."""
    if not os.path.exists(marker_path):
        return (False, "file absent")
    try:
        with open(marker_path, "r") as f:
            marker = json.load(f)
    except Exception:
        return (False, "unreadable")
    found = marker.get("step")
    return (found == step, f"step {found!r}")


# The commands that WRITE the preview-shown marker, mirroring
# `preview_gate::marker_writing_command_sources`
# (crates/codeyam-editor/src/commands/editor/preview_gate.rs). Keep the two in
# agreement. Naming them turns "which command counts as showing a preview?"
# from a guess into a lookup — `recapture-stale` renders a preview and still
# writes no marker.
#
# `preview-verify` used to sit on that non-marking side and no longer does. It
# runs the same navigate+capture `preview` does and then asserts three gates
# over the result, so it was the STRONGEST evidence available that a preview
# had been shown while still leaving this gate shut — four sessions across four
# VMs each answered that by paying a redundant `preview` run whose only product
# was the marker. Anything moved between the two sides here must move in
# `marker_writing_command_sources` in the same change.
MARKER_WRITING_COMMANDS = (
    "preview",
    "preview-flow",
    "preview-html",
    "preview-interact",
    "preview-verify",
    "show-results",
)


def preview_required_next_action(observed, step, hint):
    """The `Next valid action:` text for a preview-gate refusal, routed by the
    discriminant [`preview_marker_state`] already returned.

    Its three not-ok states are different problems, and this gate used to emit
    ONE narrative for all of them: a pipe/SIGPIPE story that is provably not the
    cause on POSIX, where every marker-writing command runs under
    `run_with_liveness` (so it never sees EPIPE) and writes the marker before its
    first stdout write (pinned by `marker_is_written_before_any_stdout`). An
    agent hit it with an ABSENT marker, believed it, and copied the false
    diagnosis into its transcript. Each arm now describes the state it is in.

    The pipe warning survives only in the `unreadable` arm — a truncated marker
    is the one state where a severed write still explains the symptom, and
    `stream_capture` is `#[cfg(unix)]`, so a non-POSIX host can still reach it."""
    marking = ", ".join(f"`{c}`" for c in MARKER_WRITING_COMMANDS)
    if observed == "file absent":
        return (
            f"no preview has been shown at THIS step. The marker is cleared on "
            f"every `advance`, and only {marking} write it — `recapture-stale` "
            f"shows a preview but does NOT mark it. Run "
            f"`{hint}`, then call AskUserQuestion."
        )
    if observed == "unreadable":
        return (
            f"the marker exists but does not parse, so a write was cut short "
            f"mid-file. Check whether you piped `{hint}` into `head`/`tail`/"
            f"`grep`: that closes the pipe early and SIGPIPEs the command, so the "
            f"capture and the screenshots succeed but the marker write is lost. "
            f"Re-run it bare (no pipe)."
        )
    return (
        f"a preview was shown, but at a different step — the marker holds "
        f"{observed} and this is step {step}. Advancing clears it, so re-show it "
        f"HERE: run `{hint}`, then call AskUserQuestion."
    )


def describe_call(tool_name, tool_input):
    """A short, stable identifier for the call being judged.

    Folded into the repeat fingerprint so two DIFFERENT calls refused under one
    rule are not reported as "this exact call was refused before" — six of the
    eleven block sites used to pass only the slug, so three distinct `grep -P`
    commands escalated to a 3x repeat notice that was simply false."""
    if tool_name == "Bash":
        return f"Bash: {tool_input.get('command', '')}"
    file_path = tool_input.get("file_path", "")
    return f"{tool_name}: {file_path}" if file_path else tool_name


def main():
    """Claude Code PreToolUse hook entry point: read the current
    editor step from `.codeyam/editor-step.json` and either allow or
    block the in-flight tool call based on the active step's rules."""
    global _EXPLAIN_MODE
    # Set from argv ONCE, before any rule runs, and never read from the
    # environment or the event — see `_EXPLAIN_MODE`.
    _EXPLAIN_MODE = explain_requested(sys.argv[1:])

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())

    # Read the tool use event from stdin
    event = read_event()
    if event is None:
        allow("no parseable PreToolUse event on stdin")

    tool_name = event.get("tool_name", "")
    tool_input = event.get("tool_input", {})
    call = describe_call(tool_name, tool_input)

    # Scripted-source-rewrite guard. Unlike every other rule here this one is
    # neither step-scoped nor editor-mode-scoped — the ban on machine-rewriting
    # tracked source holds in every session — so it fires before the
    # `CODEYAM_EDITOR_ACTIVE` short-circuit below.
    if tool_name == "Bash":
        found = scripted_rewrite_stage(tool_input.get("command", ""), project_dir)
        if found:
            rewrite_target, stage, stage_count, append_only, target_inferred = found
            reason, next_action = scripted_rewrite_refusal(
                rewrite_target, append_only, target_inferred
            )
            evidence = resolved_context(project_dir, "git ls-files")
            compound = compound_stage_evidence(stage, stage_count)
            if compound:
                evidence = f"{evidence}; {compound}"
            block(
                project_dir,
                "scripted-rewrite",
                reason,
                next_action,
                detail=rewrite_target,
                evidence=evidence,
                call=call,
            )

    # Preview-origin hand-write guard. Same scope as the guard above: a
    # half-applied origin switch breaks the preview in any session.
    if tool_name == "Bash":
        origin_target = preview_origin_hand_write_target(tool_input.get("command", ""))
        if origin_target:
            reason, next_action = preview_origin_hand_write_refusal(origin_target)
            block(
                project_dir,
                "preview-origin-hand-write",
                reason,
                next_action,
                detail=origin_target,
                call=call,
            )

    # Scripted state-read guard. Neither step-scoped nor editor-mode-scoped,
    # for the same reason as the guard above: a commit body carrying another
    # feature's description is just as wrong outside the editor workflow, and
    # a parse of the command-output tee is just as impossible. It also has to
    # fire before the "always allow codeyam-editor editor" short-circuit
    # further down, which would otherwise exit 0 and skip both verdicts.
    #
    # `inspector_nudge` — the softer, editor-mode-only pointer — is reached
    # much further down and never doubles up with this: `notice` and `block`
    # both exit, so a command judged here never reaches it.
    if tool_name == "Bash":
        state_read = scripted_state_read_target(tool_input.get("command", ""))
        if state_read:
            kind, store, inspector = state_read
            if kind == "inspectable":
                notice("scripted-state-read", scripted_state_read_notice(store, inspector))
            reason, next_action = scripted_state_read_refusal(kind)
            block(
                project_dir,
                "scripted-state-read",
                reason,
                next_action,
                detail=store,
                evidence=(
                    f"the command parses JSON (`json.load`/`JSON.parse`/`jq`) and "
                    f"names `{store}`; no `.codeyam/` write construct present, so "
                    f"this is a read"
                ),
                call=call,
            )

    # Piped-gating-command guard. Neither step-scoped nor editor-mode-scoped,
    # for the same reason as the guard above: the rule holds in every session.
    # It also has to fire before the "always allow codeyam-editor editor"
    # short-circuit further down, which would otherwise exit 0 silently and
    # skip the pointer.
    #
    # This is an ADVISORY now, not a refusal. Every gating subcommand runs
    # inside the liveness bracket, which makes a pipe cost the terminal display
    # and the shell exit code — both recoverable from the two sidecars the
    # notice names — instead of costing the command. Where the bracket's capture
    # does not exist, the original harms are all still live and so is the block.
    #
    # A pipe that WINDOWS a live hand-off (`advance | head`) is not advised
    # here: the notice exits 0, which would wave through the refusal the
    # windowed-handoff guard below exists to issue. That pipe costs
    # instructions, not just an exit code.
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        piped = piped_gating_command(command)
        if piped and not windowed_live_handoff(command):
            if not _capture_available():
                block(
                    project_dir,
                    "piped-gating-command",
                    f"this pipes `{cli_command()} editor {piped}` into a filter "
                    f"on a host with no stream capture, so the command writes "
                    f"straight to your pipe. A filter that stops reading kills "
                    f"it mid-run, and there is no transcript or status document "
                    f"to recover the output or the verdict from.",
                    f"run it BARE and read the verdict off its own terminal line "
                    f"(`CODEYAM_VERIFY_BUILD: PASS|FAIL`, the "
                    f"`CODEYAM_CMD_COMPLETE` `status`). `| tee out.txt` is the "
                    f"one filter that costs nothing.",
                    detail=piped,
                    evidence=(
                        f"`{piped}` is in the gating-subcommand set; "
                        f"os.name={os.name!r} has no `#[cfg(unix)]` stream "
                        f"capture; `| tee` not present"
                    ),
                    call=call,
                )
            notice("piped-gating-command", piped_gating_notice(piped))

    # Recursive-delete guard. Neither step-scoped nor editor-mode-scoped, for
    # the same reason as the two above: `rm -rf` over tracked files is a loss in
    # any session, and the damage does not surface until a later `git status`.
    if tool_name == "Bash":
        deletion = tracked_recursive_rm(tool_input.get("command", ""), project_dir)
        if deletion:
            target, tracked_count = deletion
            reason, next_action = recursive_rm_refusal(target, tracked_count)
            block(
                project_dir,
                "recursive-delete",
                reason,
                next_action,
                detail=target,
                evidence=(
                    f"{resolved_context(project_dir, 'git ls-files')}; "
                    + (
                        "segment could not be tokenized"
                        if tracked_count is None
                        else f"`git ls-files -- {target}` reports {tracked_count} tracked file(s)"
                    )
                ),
                call=call,
            )

    # Windowed hand-off read guard. Neither step-scoped nor editor-mode-scoped,
    # for the same reason as the guards above: a half-read hand-off is just as
    # wrong outside the editor workflow, and drops its instructions just as
    # silently there.
    #
    # Placed after `recursive-delete` and before `self-matching-pgrep`: a
    # refusal about destroying something must never be displaced by one about a
    # read, and an advisory about a command that merely will not finish must
    # never displace this one.
    #
    # The `Read`-tool half lives HERE rather than beside the read-only allow
    # further down, and that is forced rather than preferred: the
    # `Read`/`Glob`/`Grep` allow-branch sits after the `CODEYAM_EDITOR_ACTIVE`
    # short-circuit, so a guard that must pre-empt it cannot live below it.
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        idiom = windowed_handoff_read(command)
        if idiom:
            reason, next_action = windowed_handoff_read_refusal(
                idiom, collateral=handoff_refusal_collateral(command)
            )
            block(
                project_dir,
                "windowed-handoff-read",
                reason,
                next_action,
                detail=idiom,
                evidence=(
                    f"the command names a hand-off file in a read position and "
                    f"truncates it with `{idiom}`; a whole-file `cat`, a `grep`, "
                    f"and a `wc -l` of the same path are not matched"
                ),
                call=call,
            )
        live = windowed_live_handoff(command)
        if live:
            subcommand, idiom = live
            reason, next_action = windowed_handoff_read_refusal(
                idiom,
                subcommand=subcommand,
                collateral=handoff_refusal_collateral(command),
            )
            block(
                project_dir,
                "windowed-handoff-read",
                reason,
                next_action,
                detail=idiom,
                evidence=(
                    f"the command pipes the live output of `editor {subcommand}` "
                    f"into `{idiom}`; a bare run and a pipe into `grep` are not "
                    f"matched"
                ),
                call=call,
            )

    # A `Read` of the hand-off carrying NEITHER key is a whole-file read and
    # stays allowed — it is one of the two complete alternatives the refusal
    # points at.
    if tool_name == "Read":
        idiom = windowed_handoff_read_tool(tool_input)
        if idiom:
            reason, next_action = windowed_handoff_read_refusal(idiom)
            block(
                project_dir,
                "windowed-handoff-read",
                reason,
                next_action,
                detail=idiom,
                evidence=(
                    f"Read targets `{tool_input.get('file_path')}` with "
                    f"offset={tool_input.get('offset')!r} limit={tool_input.get('limit')!r}; "
                    f"the same Read carrying neither key is a whole-file read and is allowed"
                ),
                call=call,
            )

    # Self-matching-pgrep guard. Neither step-scoped nor editor-mode-scoped,
    # for the same reason as the guards above: a wait loop that polls for its
    # own argv hangs in any session, and it hangs silently — an agent inside
    # one has no turn left in which to notice.
    #
    # It sits LAST among the unscoped guards deliberately. `notice` exits 0, so
    # whichever verdict fires first is the only one emitted, and an advisory
    # about a command that merely will not finish must never displace a refusal
    # about a command that destroys something.
    if tool_name == "Bash":
        pgrep_pattern = self_matching_pgrep_loop(tool_input.get("command", ""))
        if pgrep_pattern:
            notice("self-matching-pgrep", self_matching_pgrep_notice(pgrep_pattern))

    # Every remaining rule is a workflow-step gate — only enforce in editor mode
    if not os.environ.get("CODEYAM_EDITOR_ACTIVE"):
        allow("CODEYAM_EDITOR_ACTIVE unset — step gates do not apply")

    state_path = os.path.join(project_dir, ".codeyam", "editor-step.json")

    # No state file = not in editor mode, allow everything
    if not os.path.exists(state_path):
        allow(f"no step state at {state_path} — not in editor mode")

    try:
        with open(state_path, "r") as f:
            state = json.load(f)
    except (json.JSONDecodeError, IOError):
        allow(f"step state at {state_path} is unreadable — degrading to allow")

    step = state.get("step", 0)
    slug = state.get("slug") or ""

    if not step:
        allow(f"step state at {state_path} carries no step number")

    metadata = load_step_metadata(project_dir)
    mode, mode_table = resolve_mode_table(state, metadata)

    code_change_slugs = set(mode_table.get("codeChangeSlugs", []))
    commit_slugs = set(mode_table.get("commitSlugs", []))
    push_slugs = set(mode_table.get("pushSlugs", []))
    preview_required_slugs = set(mode_table.get("previewRequiredSlugs", []))
    test_run_slugs = set(mode_table.get("testRunSlugs", []))
    no_test_slugs = mode_table.get("noTestSlugs", {}) or {}

    # Always allow codeyam-editor commands. Match both the canonical
    # name and the local-dev wrapper so saved sessions emitted under
    # either spelling keep working after the canonical-name rollout.
    if tool_name == "Bash":
        command = tool_input.get("command", "")

        # Test-run gate. `testRunSlugs` is the per-mode set of slugs whose
        # phase declares a non-None test_scope — a slug NOT in it may not run
        # tests. This must fire BEFORE the "always allow codeyam-editor editor"
        # short-circuit below, because `codeyam-editor editor refresh-tests` is
        # itself a test run. Empty `testRunSlugs` (a stale v1/v2 cache) => no
        # gating, mirroring the `and commit_slugs` / `and push_slugs`
        # short-circuits below — a cache skew degrades to "allow", never "block
        # every test run".
        #
        # The MEMBERSHIP test is one line; wording the refusal is not, because
        # a blocked slug can be pre-Demo or post-hardening and the two need
        # opposite advice. `_test_run_block_message` reads that from the
        # `noTestSlugs` projection.
        #
        # An untokenizable command (None) is refused on the honest
        # unparseable reason rather than asserted to be a test run.
        test_run = False
        if slug and test_run_slugs and slug not in test_run_slugs:
            test_run = is_test_run_command(command, project_dir)
        if test_run is None:
            refuse_unparseable(project_dir, command, call)
        if test_run:
            reason, next_action = _test_run_block_message(
                state, slug, no_test_slugs.get(slug)
            )
            kind = (no_test_slugs.get(slug) or {}).get("kind") or "unclassified"
            block(
                project_dir,
                "test-run",
                reason,
                next_action,
                detail=slug,
                evidence=(
                    f"{resolved_context(project_dir, state_path)}; slug `{slug}` "
                    f"(kind {kind}) is not in testRunSlugs"
                ),
                call=call,
            )

        # Inspector nudge. Emitted on stderr and then FALLEN THROUGH from
        # — never `sys.exit`ed on — so the command still runs and every
        # gate below still applies. stderr is the channel every other
        # message in this hook uses; pairing it with a 0 exit is what
        # makes this a pointer rather than a refusal.
        nudge = inspector_nudge(command)
        if nudge:
            print(nudge, file=sys.stderr)

        # Position-aware, unlike the substring test it replaces: a command that
        # merely MENTIONS the CLI — most of all inside a quoted commit message —
        # used to short-circuit the commit, push, code-change and PCRE gates
        # below. See `invokes_codeyam_editor`.
        if invokes_codeyam_editor(command):
            allow("runs a `codeyam-editor editor` subcommand")

    # Always allow reading
    if tool_name in ("Read", "Glob", "Grep", "WebFetch", "WebSearch", "Agent"):
        allow(f"{tool_name} is a read-only tool")

    # Always allow task management
    if tool_name in ("TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "Skill", "ToolSearch"):
        allow(f"{tool_name} is workflow/task management")

    # Gate AskUserQuestion at preview-required slugs — require preview marker first
    if tool_name == "AskUserQuestion":
        if slug and slug in preview_required_slugs:
            marker_path = os.path.join(project_dir, ".codeyam", "preview-shown.json")
            preview_ok, observed = preview_marker_state(marker_path, step)

            if not preview_ok:
                hint = _preview_hint(mode, project_dir)
                block(
                    project_dir,
                    "preview-required",
                    f"This step ({_slug_label(state, slug)}) requires showing "
                    f"the live preview before asking the user for confirmation.",
                    preview_required_next_action(observed, step, hint),
                    detail=slug,
                    evidence=(
                        f"{resolved_context(project_dir, marker_path)}; marker "
                        f"holds {observed}, this step is {step}"
                    ),
                    call=call,
                )

        allow("AskUserQuestion with the preview requirement satisfied")

    # Check Write/Edit to non-.codeyam files
    if tool_name in ("Write", "Edit"):
        file_path = tool_input.get("file_path", "")

        # `@import url(...)` in CSS is render-blocking and bypasses Next.js's
        # font pipeline. Webfonts belong in layout.tsx via next/font or a
        # <link rel="preconnect"> + <link href> — check BEFORE the .codeyam/
        # short-circuit so authored CSS is gated regardless of step.
        if file_path.endswith(".css"):
            content_str = tool_input.get("content", "") or tool_input.get("new_string", "")
            if "@import url" in content_str:
                block(
                    project_dir,
                    "css-import-url",
                    "`@import url(...)` in CSS is render-blocking and hurts LCP.",
                    "load the webfont via next/font in layout.tsx (or a "
                    "<link rel=\"preconnect\"> + <link href> pair), then re-apply "
                    "this edit without the `@import url(...)` line.",
                    detail=file_path,
                    evidence=f"`@import url` found in the {tool_name} payload for {file_path}",
                    call=call,
                )

        # A line-budgeted file is checked BEFORE the `.claude/` short-circuit
        # below, for the same reason the CSS rule is: the guarded file lives
        # under `.claude/`, so a gate placed after that short-circuit would never
        # fire on the one file it exists for. This is not step-scoped either —
        # the budget holds at every slug, editor mode or not.
        violation = line_budget_violation(tool_name, tool_input, project_dir)
        if violation:
            rel, limit, current, projected = violation
            reason, next_action = line_budget_refusal(rel, limit, current, projected)
            block(
                project_dir,
                "line-budget",
                reason,
                next_action,
                detail=rel,
                evidence=(
                    f"{resolved_context(project_dir, rel)}; budget {limit} lines, "
                    f"currently {current}, this edit makes it {projected}"
                ),
                call=call,
            )

        # Target-path model, replacing a pair of substring tests — see
        # `classify_write_target` for the two bugs that lived here.
        placement, normalized_target = classify_write_target(file_path, project_dir)
        if placement == "outside":
            allow(f"{file_path} resolves outside {project_dir} — not a code change")
        if placement == "editor-state":
            allow(f"{normalized_target} is editor state, writable at every slug")
        # Empty allowlist means the cache is missing/stale (e.g. a v1
        # cache after a binary downgrade) — degrade to "allow" rather
        # than brick the session. An empty `slug` means the state file
        # predates the slug field; the next `editor step` invocation
        # will migrate it, so degrade to "allow" rather than block on
        # an unmatchable allowlist.
        # Resolving a conflict is not authoring a feature. `pre-commit-sync`
        # starts a rebase and, on a genuine source conflict, prints a recovery
        # that reads "resolve each file, `git add` it, then `git rebase
        # --continue`" — which this gate then refused, wedging the very step
        # that printed it, with no in-band way out. The `git add` half already
        # carries exactly this escape (see merge_in_progress); the EDIT that
        # must precede it did not, so only half the recovery was reachable.
        # Scope is narrow: it opens only while a rebase/merge/cherry-pick is
        # PAUSED mid-operation, and `git commit` stays gated by its own slug
        # check regardless, so this cannot land a commit outside the commit
        # slug — it only lets an in-flight integration be finished.
        if (
            slug
            and code_change_slugs
            and slug not in code_change_slugs
            and not merge_in_progress(project_dir)
        ):
            allowed = ", ".join(sorted(code_change_slugs))
            # The list of permitted slugs is REFERENCE, deliberately below
            # both contract lines. Led with, it reads as a set to reason
            # about — which is how this block came to be the most-retried
            # one in the transcripts (four in a row at `backend-journal`).
            # One named command reads as an instruction to follow, so the
            # action is just that command; what it does is reference too.
            block(
                project_dir,
                "code-change",
                f"This step ({_slug_label(state, slug)}) does not allow code changes.",
                f"run `{cli_command()} editor change`, then make this edit.",
                reference=(
                    f"`editor change` reopens the build loop: it MOVES the workflow "
                    f"cursor back to the nearest earlier slug that permits edits and "
                    f"prints the command to return here. Code changes are allowed at "
                    f"slugs: {allowed}."
                ),
                detail=f"{slug}\x00{file_path}",
                evidence=(
                    f"{resolved_context(project_dir, state_path)}; target "
                    f"resolves to `{normalized_target}` INSIDE the repo; slug "
                    f"`{slug}` is not in codeChangeSlugs"
                ),
                call=call,
            )

    # Check Bash commands for git commit/push
    if tool_name == "Bash":
        command = tool_input.get("command", "")

        # `-P` (PCRE) is a GNU extension; BSD grep on macOS has no such flag.
        # This repo is developed on macOS laptops and run on Linux VMs, so the
        # rule is about PORTABILITY, not about the current host — it fires on
        # every platform, and the message must therefore stay true on every
        # platform. Do not reintroduce a claim about which OS is running: the
        # block previously asserted the host was macOS and fired inside Linux
        # containers, which teaches an agent to distrust the hook's other
        # explanations.
        #
        # The recovery names commands that run through Bash, because Bash is
        # the one tool every harness has. It used to prescribe "the Grep tool",
        # and the harness running the fleet exposes no such tool — the very next
        # call after the block failed with "No such tool available: Grep". A
        # harness search tool is mentioned only conditionally, never as the
        # sole next action.
        #
        # An untokenizable command is undecidable (None), not a match: it is
        # still refused, but on its own honest reason with its own fingerprint,
        # so it neither claims a PCRE flag it never saw nor inflates the
        # `grep-p` recurrence count.
        pcre = _uses_pcre_grep(command)
        if pcre is None:
            refuse_unparseable(project_dir, command, call)
        if pcre:
            block(
                project_dir,
                "grep-p",
                "`grep -P` (PCRE) is not portable — BSD grep on macOS has no "
                "`-P`, so a command written on a Linux VM fails on a "
                "developer's laptop. The rule applies on every platform.",
                "re-run it through Bash as `grep -E` with the pattern rewritten "
                "in POSIX extended syntax (e.g. `[0-9]` for `\\d`, `[[:space:]]` "
                "for `\\s`); when the pattern genuinely needs PCRE (lookarounds, "
                "lazy quantifiers), run ripgrep through Bash instead: "
                "`rg --pcre2 '<pattern>' <path>`. A harness-provided search "
                "tool also works, if this session has one.",
                evidence=f"a PCRE flag was found on a `grep` in command position in: {command}",
                call=call,
            )

        # Each of these three used to be a bare `"git <verb>" in command`
        # substring test, so a mere MENTION of the verb was refused —
        # `echo "remember to git commit later"` at a plan slug, and any commit
        # whose own message discussed committing. `invokes_git_subcommand`
        # asks whether the verb is what the command RUNS.
        if invokes_git_subcommand(command, "commit"):
            if slug and commit_slugs and slug not in commit_slugs and not staged_paths_are_plans_only(project_dir):
                allowed = ", ".join(sorted(commit_slugs))
                block(
                    project_dir,
                    "git-commit",
                    f"git commit is only allowed at slug(s): {allowed}. "
                    f"You are at {_slug_label(state, slug)}.",
                    "keep following the workflow — `codeyam-editor editor advance` "
                    f"until the {_commit_gate_phrase(commit_slugs)} slug, which commits for you. "
                    "If this commit genuinely belongs OUTSIDE the workflow (re-triggering a "
                    "stalled deploy, a release pass), advancing the whole workflow is not a "
                    "route to that goal — run `codeyam-editor editor commit --out-of-workflow "
                    '-m "<msg>"` instead (add `--allow-empty` for an empty commit). It runs the '
                    "static-check and test-cache gates itself before committing, and is the "
                    "gated replacement for `git commit --no-verify`, which skips every gate. "
                    "To read what "
                    "a later slug requires without moving the workflow pointer, run "
                    "`codeyam-editor editor step --show --slug <slug>`.",
                    reference="Plan-file commits (.codeyam/plans/*.md) are allowed at any step.",
                    detail=slug,
                    evidence=(
                        f"{resolved_context(project_dir, state_path)}; `git commit` "
                        f"is in command position; staged set is not plans-only"
                    ),
                    call=call,
                )
        elif invokes_git_subcommand(command, "add"):
            if (
                slug
                and commit_slugs
                and slug not in commit_slugs
                and not git_add_paths_are_plans_only(command)
                and not merge_in_progress(project_dir)
            ):
                allowed = ", ".join(sorted(commit_slugs))
                block(
                    project_dir,
                    "git-add",
                    f"git add is only allowed at slug(s): {allowed}. "
                    f"You are at {_slug_label(state, slug)}.",
                    f"leave staging to the workflow — the {_commit_gate_phrase(commit_slugs)} slug runs "
                    "`codeyam-editor editor stage-feature`, which stages this for you.",
                    reference="Plan-file commits (.codeyam/plans/*.md) are allowed at any step, "
                    "and `git add` is permitted while a rebase/merge is paused mid-operation.",
                    detail=slug,
                    evidence=(
                        f"{resolved_context(project_dir, state_path)}; `git add` is in "
                        f"command position; paths are not plans-only; no rebase/merge "
                        f"is paused"
                    ),
                    call=call,
                )

        if invokes_git_subcommand(command, "push"):
            if slug and push_slugs and slug not in push_slugs:
                allowed = ", ".join(sorted(push_slugs))
                block(
                    project_dir,
                    "git-push",
                    f"git push is only allowed at slug(s): {allowed}. "
                    f"You are at {_slug_label(state, slug)}.",
                    "keep advancing to the `push` slug, which runs "
                    "`codeyam-editor editor push` with the queue held.",
                    detail=slug,
                    evidence=(
                        f"{resolved_context(project_dir, state_path)}; `git push` is "
                        f"in command position; slug `{slug}` is not in pushSlugs"
                    ),
                    call=call,
                )

    # Allow everything else
    allow("no gate matched this call")


if __name__ == "__main__":
    main()
