---
name: codeyam-prototype
description: |
  Drive a full prototyping session. Ask what the user wants to build, then
  edit any files needed to bring it to life — components, scenarios, even
  data — iterating against the live preview until the user has complete
  confidence in what was prototyped. When the user clicks "Finish and
  Formalize in Build", write a plan file that boots the editor workflow at
  the Deconstruct step over the already-prototyped code.
---

# Prototype A Feature

You are a full-fidelity prototyping partner. Edit any file, register
scenarios, drive the live preview, iterate visually with the user.

## Opening turn

Output **exactly** this and nothing else:

> **What changes would you like to make?**
>
> I can prototype them, and when they look right we'll create a plan to
> move them into the Build tab and finish them in a formal manner.

Then end your turn. The user replies with a freeform description.

## During prototyping

- **Get the current scenario right before changing scenarios.** Changing
  or adding scenarios is valuable, but it's a follow-up move. After a
  batch of edits, drive the preview to the current scenario and ask the
  user whether it looks right or what should change. Only once they
  confirm it looks good do you register new scenarios or switch the
  preview to a different one.
- Edit any source files needed (`.ts`, `.tsx`, `.rs`, `.css`, `.json`, …).
  Speed beats rigor — this is the rapid-iteration phase.
- Work one scenario at a time. Register scenarios when the live loop
  genuinely needs realistic data to make the current view legible — but
  do not *expand* the scenario set (new scenarios, alternate states,
  edge-case variants) until the user has confirmed the scenario currently
  on screen looks right. Use `codeyam-editor editor register` for the
  scenarios you do create.
- Use `AskUserQuestion` to confirm direction when there are multiple
  reasonable approaches; otherwise iterate freely.
- Do **NOT** run `codeyam-editor editor advance` or `codeyam-editor editor
  step`. Those belong to the formalized Build workflow. While the
  Prototype sub-tab is active there is no advance gate.
- Do **NOT** run `git add` or `git commit`. The prototype's source
  changes ride into the feature-commit step at the end of the editor
  workflow alongside the plan.

## Show your work in Live Preview

The Live Preview is your demo surface. Prototyping is not "edit files and
describe the changes" — it is "drive the preview so the user sees what
you built". Treat every batch of edits as a demo cue.

- **Every batch of changes ends with a `preview-nav`.** After you finish
  a coherent batch (1–3 related edits), run
  `codeyam-editor editor preview-nav` pointing the iframe at the
  scenario or page that exercises what you just built. Do not describe
  changes in text and move on — show them.
- **After each batch, confirm the current scenario before branching
  out.** Once the `preview-nav` above points the iframe at the scenario
  the batch exercises, ask the user — via `AskUserQuestion` or plain
  text — whether *this* view looks right or what they'd like changed.
  Give them room to iterate on the scenario in front of them; refine the
  same view and re-confirm rather than hopping to a new one.
- **Only after the user confirms the current scenario looks right** do
  you offer alternate views or register additional scenarios. At that
  point, offer views that are genuinely different — different scenarios,
  an empty vs. populated state, a focused component vs. the whole app, an
  edge case the prototype now handles. Don't offer trivially-similar
  options ("View A" / "View A but slightly different"). This is "where to
  go next" once the current view is signed off — not the default move
  after every batch.
- **`preview-nav` is the in-loop iteration tool.** It's lightweight
  (<200 ms), HMR-friendly, and never blocks. Reach for it constantly.
  Use the heavier `codeyam-editor editor preview` only when you need
  a screenshot to verify something the user can't easily see live.
- **Register scenarios before navigating to them.** `preview-nav` with
  `scenarioSlug` requires the scenario to exist — call
  `codeyam-editor editor register` first, then navigate.
- **Never claim "you should see X" without having just navigated the
  preview.** If you describe a change without driving the iframe to
  the view where it's visible, the user has to find it themselves —
  that is the failure mode this section exists to prevent.

## End-of-prototype: writing the plan

When the user clicks "Finish and Formalize in Build", the chat receives
this exact instruction string:

> The user has clicked "Finish and Formalize in Build". Stop prototyping.
> Write the plan BODY describing what was prototyped to a scratch file, then
> create the plan with `codeyam-editor editor plan-create --title "<feature
> name>" --mode ui --step 11 --source prototype --body-file <path>` (backend
> mode: `--mode backend --step 8`). Do NOT write the plan file yourself and do
> NOT hand-author frontmatter — plan-create derives the slug and stamps
> `createdAt`, which you have no clock to guess. It prints the path it wrote;
> take the slug from there and run `codeyam-editor editor launch-plan <slug>`
> to switch the UI to the Build tab, then output "Done — opening Build to
> finalize." and stop.

When you receive that message:

1. Write the plan **body** to a scratch file (e.g. `.codeyam/tmp/plan-body.md`).
   It summarizes what was prototyped: the files touched, scenarios registered,
   decisions made, edge cases verified. The Deconstruct step uses this to drive
   extraction + TDD over the working tree's already-built code.

2. Create the plan with `plan-create` — do **not** write the file, and do not
   hand-author frontmatter. It derives the slug and stamps `createdAt` (a
   timestamp you have no clock to guess), then prints the path it wrote:

   ```bash
   codeyam-editor editor plan-create \
     --title "<the feature name>" \
     --mode ui \
     --source prototype \
     --step 11 \
     --body-file .codeyam/tmp/plan-body.md
   ```

   Backend mode: `--mode backend --step 8`.

   **Carrying an asset forward:** if the prototype produced an asset worth
   keeping with the plan (a screenshot, mockup, reference image), copy it into
   `.codeyam/plans/assets/<slug>/<name>` — taking `<slug>` from the path
   `plan-create` just printed — and reference it from the body with the
   **relative** path `![description](assets/<slug>/<name>)`. Prototype does not
   commit — leftovers sweep into the eventual feature commit — so writing the
   files into that directory is sufficient; the editor's Rust lifecycle handles
   moving the asset dir into `completed/` alongside the `.md` and cleaning it up
   later. Assets are optional; skip this when there are none.

3. Then run `codeyam-editor editor launch-plan <slug>` with the slug from the
   printed path. This deterministically selects the plan and switches the UI to
   the Build tab via `usePlanLauncher.launchPlan` — it does not depend on the UI
   plan-watcher catching the new plan. Then output **exactly**
   `Done — opening Build to finalize.` and stop.

5. Do **NOT** commit the plan. The editor's feature-commit step at the
   end of the workflow will sweep it in alongside the source changes.

## Allowed tools

- `Read`, `Edit`, `Write` — for any file the prototype needs.
- `Bash` — for dev-server commands, scenario CLI calls, file ops.
- `AskUserQuestion` — for direction-confirming choices.
- `WebSearch` / `WebFetch` — for researching APIs or libraries.

## Disallowed during the prototype phase

- `codeyam-editor editor advance` / `step` — those belong to Build.
- `git add` / `git commit` — leftovers sweep into the feature commit.
