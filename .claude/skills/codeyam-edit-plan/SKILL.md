---
name: codeyam-edit-plan
description: |
  Edit an existing queued plan file. Invoked from the Plan tab's
  "Edit with Claude" button on a queued change row. Receives the plan
  slug as its argument.
---

# Edit a Queued Plan

Apply user-described edits to an existing `.codeyam/plans/<slug>.md` file.

## Critical Rule: Edit the Plan File Only

**You may only modify `.codeyam/plans/<slug>.md`.** You must NEVER:

- Edit, create, or modify source code files (`.ts`, `.tsx`, `.rs`, `.json`, etc.)
- Run `cargo`, `npm`, `vitest`, `tsc`, or any build/test command
- Run any `codeyam-editor` CLI command — the editor's filesystem watcher refreshes the UI automatically when the plan file is written
- Run `git add` or `git commit` — the user owns commits for plan edits

## Workflow

### Step 1: Read the plan

Parse the slug from `$ARGUMENTS`. If `$ARGUMENTS` is empty or contains anything other than `[a-z0-9-]+`, output:

> Usage: `/codeyam-edit-plan <slug>` (where `<slug>` is the plan's filename without `.md`).

Then stop — do not touch any files.

Otherwise, use the Read tool to load `.codeyam/plans/<slug>.md`. If the file does not exist, output:

> No plan found at `.codeyam/plans/<slug>.md`.

Then stop.

If the read succeeds, output a one-line confirmation that includes the plan's `title` (from frontmatter) so the user can verify they're editing the right plan.

### Step 2: Ask what to change

**Do NOT use the AskUserQuestion tool.** Output exactly this prompt as plain assistant text and stop, waiting for the user's freeform reply:

> **What would you like to change about this plan?**

End your turn here.

### Step 3: Apply the edits

When the user replies, write the updated plan back with the Write tool. **Copy the existing frontmatter block through byte-for-byte, except for the fields the user actually asked to change.** In particular, `createdAt` records when the plan was created and is stamped by the tooling — never re-type, regenerate, or "refresh" it. You have no reliable clock, so any value you type there is a guess, and the audit will flag it. `dependsOn` (a bracket array of prerequisite plan slugs, e.g. `dependsOn: ["session-recovery-ux"]`) likewise survives edits unless the user explicitly asks to add or remove a dependency.

**Assets:** if the edit adds a new asset (a screenshot, mockup, reference
image), write it into the plan's own asset directory
`.codeyam/plans/assets/<slug>/<name>` and reference it from the body with the
relative path `![description](assets/<slug>/<name>)` — the same convention the
plan-authoring skill uses, so the reference survives the queue→completed move
the editor performs. Conversely, when an edit **removes** an asset reference
from the body, delete the now-unused file from `.codeyam/plans/assets/<slug>/`
so the directory doesn't accumulate orphans.

After writing, briefly confirm what was updated (one or two short bullets). Then loop back to Step 2 and ask again — the user may want to make several changes in the same session.

### Step 4: Done

When the user indicates they're done (e.g. "looks good", "that's it", "thanks"), output a brief confirmation. Do **not** commit the change — the user will commit when they choose to.

## Tips

- The frontmatter must stay valid YAML. Re-emit it exactly as it was unless the user explicitly asks to change a frontmatter field.
- If the user's request is ambiguous (e.g. "make it shorter" but unclear which section), ask a single targeted clarifying question rather than guessing.
- The watcher refresh updates the Plan tab UI automatically after each Write. The user will see the change land in real time.
- If the plan you edited is the one currently pinned to a build session, `codeyam-editor editor plan-show` re-pins itself from the edited file, so the rendered plan follows your Write with no manual step. Only when it does not — a filesystem that gave the edit and the pin the same timestamp, or a pin deliberately left divergent — force it with `codeyam-editor editor plan-show --refresh`. Never hand-edit `.codeyam/editor-user-prompt.txt` to sync the two; that is what desyncs the pin from the plan file.
