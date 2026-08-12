---
name: codeyam-editor
description: CodeYam Editor Mode — scaffold a project and build code + data scenarios together
---

# CodeYam Editor Mode

You are in **Editor Mode**. The user sees a split-screen: this terminal on the left, live preview on the right.

## Preflight: is another session already driving this workflow?

Two `/codeyam-editor` panes on one project corrupt each other's workflow state. Before anything else — before the project description or `step 1` — run `codeyam-editor editor workflow-holder --format json` and branch:

- **Non-zero exit** (e.g. `error: unrecognized subcommand 'workflow-holder'` or an unknown-flag error) — `workflow-holder` is a real, current command, so a parse failure means your `codeyam-editor` binary is **stale**. Do NOT conclude the command doesn't exist, do NOT skip the preflight, and do NOT rebuild or restart the editor yourself: **STOP, do not run `step 1`, and tell the user the editor binary is stale and to ask the maintainer to rebuild it** — never silently proceed, which forfeits the concurrent-session protection this preflight provides. (If you are developing codeyam-editor itself, its CLAUDE.md "Rebuilding the editor mid-session" covers the maintainer-only recovery.)
- **`held_by_other: false`** — no foreign holder (or the lock is yours, e.g. after `/clear` and re-invoke). Proceed normally.
- **`held_by_other: true`, `holder_stale: false`** — a live session is
  driving. Do NOT run `step 1`. Print the holder identity fields
  (`holder_session_id`/`holder_pid`/`holder_acquired_at`/`holder_transcript_path`)
  and tell the user to switch to that pane or wait, then stop.
- **`held_by_other: true`, `holder_stale: true`** — a crashed/abandoned
  session left a stale lock. Do NOT run `step 1`. Tell the user to run
  `codeyam-editor editor session-reset` then re-invoke, then stop.

## Project description is mandatory

Before doing ANYTHING in step 1, run `codeyam-editor editor project-info --format json` and inspect the returned `projectDescription`. Bare `project-info` (no JSON argument) is the read-only query surface for this: it parses `.codeyam/editor.json` and `.codeyam/stack.json` for you, returns them under the standard `entries` array, answers before the editor server is up, and exits `0` with `configPresent: false` on an un-scaffolded project. Do NOT hand-read those files with a `python3` heredoc or a `cat`/`jq` pipeline — that is the banned ad-hoc-parse path this command exists to close.

- If it is **empty or missing**, stop and ask the user: *"I don't have a project description yet — what are you building?"*
- If it is **shorter than 20 characters**, contains **no whitespace**, or matches a placeholder like `test`, `todo`, `app`, `demo`, `hello`, `untitled`, `foo`, `bar`, `tbd`, `wip`, `example` (case-insensitive), treat it as not-yet-set and ask the user the same question.
- Do **NOT** call `editor project-info` *with a JSON argument* (the write path) to set a fabricated description. The endpoint enforces this — it returns `409 project_description_already_set` for any overwrite without `"allowOverwrite": true`, and `allowOverwrite` is only legitimate when the user has *explicitly* asked you to rename the project. Fabricating wastes a round-trip and confuses the user when they see the rejected POST in logs.
- When you later need the project's display **title** (its brand / product name), take `projectTitle` from the same response — it already resolves the legacy `projectName` fallback, so you never check two keys. Never search the codebase (components, layouts, logos) for it. If it comes back unset, ask the user; do not fabricate one.

Only proceed past step 1 once `projectDescription` is a real, multi-word description provided by the user.

## CRITICAL: How This Works

You MUST follow a step-by-step workflow driven by `codeyam-editor editor step` commands. Each command tells you exactly what to do next. **You do NOT have all the instructions upfront** — the commands provide them incrementally.

**Your first action:** If this request may not be a build — a config change, a walkthrough, design exploration, or external-service setup — run `codeyam-editor editor step --slug assist-triage --mode assist` to triage it; otherwise run `codeyam-editor editor step 1`.

**The rule:** After completing what a command tells you to do, run the NEXT command it specifies. The commands are your instructions — follow them one at a time.

## Task Tracking

Steps 2+ include `━━━ TASK ━━━` directives with exact task titles and procedures. Follow what each directive says: create the task, do the work, mark it completed before advancing. Step 1 has no task.

The advance gate reads `.codeyam/editor-task-tracking.json` (populated by the PostToolUse hook from your TaskCreate / TaskUpdate calls) and will `BLOCKED` if the current-step task is missing or not marked completed. Do NOT edit that JSON directly — go through TaskCreate/TaskUpdate so the hook records the state.

## The Cycle

Each feature flows through plan → confirm → prepare → prototype → demo → deconstruct → present → reconcile → finalize → journal → commit → push → feature-complete. Run `codeyam-editor editor step 1` to start; subsequent commands tell you the next slug.

User confirmation is required at the `ui-confirm-plan` / `backend-confirm-plan`, `present-live` / `backend-confirm`, and `ui-present` / `backend-present` slugs. All others auto-advance — run the next step command immediately, do not wait for the user to prompt you.

## Scenario Coverage and Audit

At the **reconcile** step, `codeyam-editor editor audit` is run to verify project integrity.
- **Visual Components**: Captured component scenarios automatically satisfy the `missingTests` check. No `testFile` is required in the glossary if a matching scenario exists.
- **Entry-Point Pages**: Application scenarios satisfy `missingTests` for pages.
- **Pure Logic**: Still requires a `testFile` pointing to a unit test.

## Handling User Feedback / Changes

When the user asks for changes mid-workflow, always:
1. Make the requested changes
2. Re-register any affected scenarios. Use a per-invocation scratch path (unique filename per call — e.g. `.codeyam/tmp/register-<batch-tag>.json`); `register` auto-deletes the file on success, so do NOT reuse a shared path.
3. Update the journal if needed
4. Resume from the current step

## Key Rules

- **Run the commands** — they ARE your instructions, not suggestions
- **One step at a time** — run each step command, read its FULL output, complete every checklist item, then advance
- **NEVER batch-run steps** — each step has unique instructions you must read and follow
- **Every feature gets scenarios** — this is the core value of CodeYam. Create at least one scenario that drives the Live Preview *during the build loop*, not as a Demo-step afterthought. A component with no top-level route (buried in a flow, or a self-hosting editor change) is shown via an isolated-component scenario at `/isolated-components/<Component>?s=<Scenario>` — that is the normal path, not a reason to skip the demo.
- **Keep the preview moving** — refresh it frequently so the user sees progress. The Demo step (`present-live`) requires a NAVIGABLE preview: its advance gate blocks until a verified capture exists for the feature, or a structural exception is recorded with `codeyam-editor editor demo-skip --reason "..."`. Test evidence alone never advances the Demo step.
- **Run `codeyam-editor editor advance` bare — do NOT pipe it through `tail` or `head`.** The command prints the next step's full instructions plus a tail-safe trailer (`━━━ BEGIN STEP N: <label> ━━━`) that carries the `EXACT_TASK_TITLE` and the immediate next actions. Slicing it strips the task hand-off body and the workflow stalls. This is one instance of the general rule (see CLAUDE.md "CLI error conventions") to run gating/long-running `codeyam-editor` commands bare — a pipe also hands you the filter's exit code instead of the command's.
- **After `advance` succeeds, keep working in the same turn.** Read the trailer, create the next step's task, run its checklist. Do NOT announce the advance and stop — that forces the user to send "Ok continue" every step. The only exception is the `(CONFIRMATION GATE)` trailer variant, which redirects you to `AskUserQuestion` and forbids auto-advance.
- **Wait on the completion sentinel, never on a success-string regex.** The long commands (`pre-commit-sync`, `refresh-tests`, `session-checkpoint`) print a stable final stdout line — a JSON object carrying the token `CODEYAM_CMD_COMPLETE` plus the command name and a terminal `status` (`ok` | `error`) — on BOTH success and failure. When the harness auto-backgrounds one, **trust the completion notification**: the harness re-invokes you the moment the task exits, and that re-invocation IS your completion signal. If you must block within the SAME turn, run the printed `codeyam-editor editor wait-for <task-id>` line BARE, exactly once — then read `status` off the sentinel line. `Monitor` is **not** an alternative here: it watches a condition the harness will not notify you about, so a Monitor armed on a backgrounded command is redundant when it fires and misleading when it times out (its "re-arm if needed" message is not an instruction to re-arm). The `━━━ WAITING ON BACKGROUND WORK ━━━` block scopes it. Do NOT hand-roll an `until grep "CODEYAM_CMD_COMPLETE" … sleep` polling loop or re-read the task `.output` file on a timer: a bare `sleep` is blocked by the harness, so the poll never even works — treat a grep-poll strictly as a last-resort fallback for an environment that does not deliver completion notifications, never the default. And do NOT guess at `HEAD ACQUIRED`/`recovered`/`pulled`-style English regexes. This is the same model the step hook states — its `━━━ WAITING ON BACKGROUND WORK ━━━` block, its step-1 `Monitor`-preload preamble, and its SessionStart preload message all name `wait-for` as the same-turn blocking path and scope `Monitor` to conditions the harness will not report. One model, not two.
- **Recover a bailed `pre-commit-sync` in one shot.** When `pre-commit-sync` bails on a dirty-tree rebase refusal or a duplicate plan slug, run `codeyam-editor editor pre-commit-sync --recover`. It runs `git pull --rebase --autostash` → `post-merge-drift-sweep` → `plan-cleanup-duplicates` and re-attempts the sync in a single command — do NOT hand-stitch those three steps across multiple runs, and do NOT `git add` a deleted queue-plan copy by hand (`plan-cleanup-duplicates` now stages that deletion for you).

## Quick Reference

Most commands are shown in context by the step that needs them. A few non-obvious ones:

```bash
# Find scenarios for a specific component (avoids a whole-repo grep)
codeyam-editor editor scenarios --component PreviewPanel
# Filter by name or slug substring (case-insensitive); flags AND together
codeyam-editor editor scenarios --name "Loading" --slug previewpanel

# Look up glossary entries — do NOT Read glossary.json directly (~71k tokens)
codeyam-editor editor glossary-find <name>
# Flags: --prefix, --substring, --feature <name>, --format json|pretty

# Diagnose an empty section in the Working Session Results panel
codeyam-editor editor explain-results
# Preview blank/broken/wrong-project? Fingerprint the reached server FIRST, before container health (see --help)
codeyam-editor editor server-identity
```
