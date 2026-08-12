---
name: codeyam-audit
user-invocable: true
disable-model-invocation: false
description: |
  Bring the current branch into full codeyam alignment, finalize it
  whole-repo, clean it for presentation, and drive it to merge-ready —
  aggressive on deterministic drift, supervised on every judgment call,
  with push / PR / merge human-gated. Idempotent and resumable. Also
  offers a cheap report-only mode (what's misaligned + deferred-commit
  attribution, touching nothing). Use it when you have accumulated
  deferred commits, did manual commits outside the workflow, or just
  want to align + finalize whatever HEAD currently is.
---

# Align, finalize, present, and drive the current branch to merge-ready

This skill is a thin, stable entry point. Its full operating procedure —
the supported-stack gate, the ORIENT → align → finalize → presentability →
merge-ready sequence, and the inlined gotchas — lives in the
version-controlled sibling procedure so it can evolve through normal review
instead of silent self-edits:

**Read `.claude/skills/codeyam-audit/finalize-procedure.md` now and follow
it.** Everything below is the contract; the procedure is the body.

## Contract

- **Operate on the current branch** by default (the procedure's ORIENT step
  reads `git branch --show-current`). The user need not name it.
- **Aggressive on deterministic drift; supervised on judgment.** Apply the
  mechanical alignment fixes autonomously (reconcile registry, refresh
  tests / evidence / descriptions, sync capture scripts, refresh
  screenshots, refresh the import graph). **Stop and ask** on every judgment
  call: a bulk unregistered-entity wall (`SOURCE_HAS_UNREGISTERED`), an
  ambiguous classification (fixture vs real, testable vs untestable), and
  anything that deletes or rewrites content. No unsupervised
  mass-registration or mass-deletion.
- **Supported-stack gate — sync or bail loud, never half-sync.** Read
  `.codeyam/stack.json` first. For a supported stack, drive to full sync.
  For one the engine does not yet support, fail loud and actionable
  (`/codeyam-audit does not yet fully support stack 'X'. Supported: ...`)
  rather than reporting a partially-aligned repo as clean.
- **Idempotent and resumable — relentless toward done.** Every run makes
  progress and ends **either** at merge-ready **or** at a specific,
  answerable question whose answer advances the next run. It never
  bails-and-abandons mid-way and never leaves the repo half-aligned.
- **Never rebase, amend, or force-push.** Assume the branch may be shared;
  integrate a moved primary branch by **merging** it in. This is the one
  unrecoverable rule.
- **A green Fast-Commit session is NOT merge-ready.** The per-step gate is
  diff-scoped; `session-finalize` is whole-repo-scoped. Trust
  `verify-full-finalize`, not the session's green steps.
- **Outward actions are human-gated.** Pushing the branch, opening the PR,
  and merging the PR each require explicit user confirmation. Red CI is
  never waved off — root-cause it from its failing-job log before any
  "flake/infra" label (procedure step 8a).
- **Report-only mode** is the explicit cheap path: list what's misaligned +
  the deferred-commit attribution and stop, touching nothing (procedure's
  "Report-only mode" section).

## Preflight

Confirm the project is initialized for codeyam-editor:

```bash
codeyam-editor editor config-show >/dev/null 2>&1 || {
  echo "Project is not initialized for codeyam-editor. Run /codeyam-onboard first."
  exit 1
}
```

If it fails, tell the user to run `/codeyam-onboard` and stop.

## Run

Work through `.claude/skills/codeyam-audit/finalize-procedure.md` top to
bottom. Then run its final **Reflect & self-improve** step: route durable
lessons to a `memory/` file and structural gaps to a proposed plan/diff
against the procedure file — never a silent edit to this `SKILL.md`. If the
run was clean, say "nothing new learned" and write nothing.
