---
name: codeyam-slice
description: |
  Adopt one vertical slice. Reads `codeyam-editor editor assess`, proposes
  the single highest-leverage feature/route to take fully through the
  codeyam loop (deconstruct → test → scenarios) as a worked example on the
  user's own code, confirms the blast radius, then boots the formal editor
  workflow at the Deconstruct step scoped to just that slice. The
  low-commitment adoption path — small, reviewable, reversible.
---

# Adopt One Vertical Slice

Take **one** feature/route fully through the codeyam loop as a worked example on the user's own code. Bounded by design: only that slice is touched, and every source edit flows through the guarded editor workflow — never ad-hoc agent freelancing across the repo.

## Critical Rule: Scope Is The Whole Point

This is the low-commitment path. The deliverable is a small, reviewable, reversible change set confined to one slice. **Surface the exact file list before any edit lands and confirm it with the user.** If the work starts spreading beyond the slice, stop and re-confirm — drift is the failure mode this skill exists to prevent.

This skill does **not** reimplement deconstruction or test logic. It picks the slice, confirms scope, and hands off to the existing editor workflow steps (which carry their own audit gates). The actual edits happen inside that workflow.

## Workflow

### Step 1 — Preflight

Confirm the project is initialized for codeyam-editor:

```bash
codeyam-editor editor config-show >/dev/null 2>&1 || {
  echo "Project is not initialized for codeyam-editor. Run /codeyam-onboard first."
  exit 1
}
```

If the check fails, tell the user to run `/codeyam-onboard` and stop. Do not proceed.

### Step 2 — Assess

Run the read-only assessment and parse it (nothing on disk changes):

```bash
codeyam-editor editor assess --format json
```

Relevant fields:

- `recommendedAction` — `adopt-vertical-slice` means a high-fan-in, under-tested file is the highest-leverage first slice. Other values still work: this skill is the explicit "I want a slice" entry point even when assess steers elsewhere.
- `blastRadius[]` — `{file, fanIn}`: high-fan-in files that also carry an untested entity. The top entry is the strongest slice candidate ("change this and nothing guards it").
- `hotspots[]` — `{file, lines}`: oversized (≥300-line) files — deconstruction targets.
- `untestedSample[]` — exported entities lacking tests.
- `shape` / `visualCaptureViable` — drive the stack-aware loop choice in Step 4.

### Step 3 — Propose the slice + confirm scope (HARD GATE)

Pick **one** slice candidate, in priority order:

1. `blastRadius[0].file` when present — highest leverage (high fan-in + untested).
2. else `hotspots[0].file` — an oversized multi-concern file to deconstruct.
3. else the file behind `untestedSample[0]` — exported logic to cover TDD-style.
4. if the codebase is already clean (no hotspots, no untested), pick a representative route/component to register scenarios for so the user still sees the loop end-to-end.

Resolve the slice's blast radius — the candidate file plus its direct test and the files that import it — into an explicit list. Then present via `AskUserQuestion`:

> Proposed slice: **`<file>`** — `<one-line rationale from assess: fan-in N, untested, or M lines>`.
>
> Scope (the only source files this slice touches):
> - `<file>`
> - `<its test file>`
> - `<direct callers, if deconstruction changes their imports>`
>
> Everything else in the repo is untouched. This is additive and reversible.

Options: `[Adopt this slice, Pick a different candidate, Cancel]`. If the user picks a different candidate, offer the next entries from `blastRadius` / `hotspots`. If Cancel, stop.

Do **not** write the plan or edit anything until the user approves the slice and its scope.

### Step 4 — Choose the stack-aware loop

Name which loop applies, from `shape` / `visualCaptureViable`:

- **UI slice** (`visualCaptureViable: true`, the file is a component/route) → deconstruct → test → **visual scenarios** (`mode: ui`).
- **Backend / CLI / non-visual slice** → deconstruct → test; the scenario step degrades to **state/output fixtures**, not screenshots (`mode: backend`).

If a slice spans UI **and** backend, scope to the UI portion and name the backend follow-up explicitly — do not silently pull both in.

### Step 5 — Hand off to the editor workflow

Write a plan scoped to the confirmed slice that boots the editor workflow at the **Deconstruct** step over the slice's already-existing code.

Write the plan **body** to a scratch file, then create the plan with `plan-create` — do **not** write the plan file yourself, and do not hand-author frontmatter. It derives the slug and stamps `createdAt` (a timestamp you have no clock to guess), then prints the path it wrote:

```bash
codeyam-editor editor plan-create \
  --title "Adopt slice: <feature/route name>" \
  --mode ui \
  --source slice \
  --step 11 \
  --body-file .codeyam/tmp/plan-body.md
```

Backend mode (from Step 4): `--mode backend --step 8`.

The plan body MUST:

- Name the **exact file list** confirmed in Step 3 as the scope boundary, and state that no source outside it is to be edited.
- Carry the assess rationale (fan-in, line count, untested entities) so the Deconstruct + TDD steps know what to target.
- Name the loop chosen in Step 4 (visual scenarios vs. state/output fixtures), and any backend follow-up deferred from a UI+backend split.

Then run `codeyam-editor editor launch-plan <slug>` with the slug from the printed path. This deterministically selects the plan and switches the UI to the Build tab via `usePlanLauncher.launchPlan` — it does not depend on the UI plan-watcher. Then output **exactly** `Done — opening Build to finalize.` and stop.

Do **NOT** `git add` / `git commit` the plan — the editor's feature-commit step sweeps it in alongside the slice's source changes.

## What NOT to do

- **Do not edit source outside the confirmed slice.** The file list from Step 3 is the contract. Spreading beyond it defeats the bounded-adoption purpose — re-confirm instead.
- **Do not reimplement deconstruction / TDD / scenario logic here.** Hand off to the workflow steps; they carry the audit gates that make the edits deliberate, tested, and reversible.
- **Do not skip the scope-confirmation gate.** Surfacing the blast radius before editing is the entire risk-lowering value of this path.
- **Do not commit the plan or any slice edits.** The feature-commit step at the end of the workflow handles that.

## Allowed tools

- `Bash` — `assess`, `config-show`, file ops.
- `AskUserQuestion` — the slice/scope confirmation gate.
- `Read` — to inspect candidate files when resolving the slice's blast radius.
- `Write` — only to write the plan file under `.codeyam/plans/`.
