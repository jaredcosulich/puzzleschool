---
name: codeyam-plan
description: |
  Plan a new feature or bug fix. Asks what you want to build/fix, investigates
  the codebase for context, writes a structured plan to .codeyam/plans/, and
  commits it.
---

# Plan a Feature or Bug Fix

Investigate the codebase and create a structured plan file ready for the codeyam editor workflow.

## Critical Rule: Plan Only — Never Implement

**You are a planner, not an implementer.** Your job is to write a `.codeyam/plans/*.md` file describing what to change and why. You must NEVER:

- Edit, create, or modify source code files (`.ts`, `.tsx`, `.rs`, `.json`, etc.)
- Run `cargo`, `npm`, `vitest`, `tsc`, or any build/test command
- Make fixes, refactors, or "quick improvements" to the codebase
- Apply the plan you just wrote

Even if the fix is obvious and small, **write it in the plan and stop.** The user will execute the plan later through the editor workflow. If you catch yourself about to edit a source file, stop and put that change into the plan's Implementation section instead.

**One capability, one boundary:** a bug plan MAY *capture* a failing reproduction test as source-code text inside the plan file itself (`.codeyam/plans/<slug>.md`, in the `## Reproduction Test` section documented in Step 5). This is still just writing the plan file — you MUST NOT write that test into the real test tree, MUST NOT run any test, and MUST NOT edit any file outside `.codeyam/`. The test is captured as text only; the editor workflow materializes and runs it at execution time.

The only files you may write are:
- `.codeyam/plans/<slug>.md` (the plan itself)
- `git add` / `git commit` of that plan file (and **only** that plan file — never `git add -A`, never a bare `git commit` that would sweep in unrelated staged work). This is the plan-creation commit specifically — it must contain only the plan file. The feature-commit step at the end of the editor workflow has a different rule: it auto-commits all non-gitignored leftovers.

The one read-only CLI call this skill makes is `codeyam-editor editor plan-prefixes` in Step 2 (to offer every prefix used before as a one-click option). It prints to stdout and changes nothing — it is not an "implementation" command.

## Workflow

### Step 1: Ask what to build or fix

**If the skill was invoked WITH arguments, skip this step entirely.** The Plan tab's "Describe the change you want" textarea seeds the launch as `/codeyam-plan <text>`, so the argument IS the answer to the question below. Re-asking it would make the user type their request a second time. Take the argument as the plan basis and go straight to Step 2.

Only when the skill is invoked with NO argument does the rest of this step apply.

**Do NOT use the AskUserQuestion tool for this step.** AskUserQuestion is a structured multiple-choice tool — using it here will produce a menu, which is exactly what we don't want. Instead, output the question below as plain assistant text and stop, waiting for the user's reply in the next turn.

Output **exactly** this and nothing else (no preamble, no tool calls, no follow-up options):

> **What do you want to build or fix?**
>
> Describe the feature, enhancement, or bug in as much detail as you'd like.

Then end your turn. The user will reply with a freeform description.

Take the user's response as the plan basis and move to the name-prefix step (Step 2), then on to investigation. Only ask a follow-up question if the response is genuinely ambiguous (e.g., you can't tell which part of the codebase is involved). Never ask about type, scope, priority, or any other categorization — infer those from the description and the codebase.

### Step 2: Ask about a name prefix

A prefix tags the plan's filename and title by author or work item — developer initials (`jc`), a feature code (`auth`), or a ticket number (`PROJ-123`). The question is **always** a one-click `AskUserQuestion` menu, so the user never has to type a prefix to answer it:

1. Run `codeyam-editor editor plan-prefixes` and capture its trimmed, newline-delimited stdout as `priorPrefixes` (an ordered list, most-recent-first). It prints every distinct prefix any plan has used (scanning both the queue and `.codeyam/plans/completed/`), de-duplicated, or nothing when no plan carries a prefix — or there are no plans yet. The first line equals the legacy `last-plan-prefix` output.

2. **Always** use `AskUserQuestion` — there is no plain-text fallback branch:
   - Question: "Would you like to prefix the plan's filename and title?"
   - One option per entry in `priorPrefixes`, in order, **capped at the 3 most-recent** (an `AskUserQuestion` menu allows at most 4 options and the last slot is reserved for "None"). Mark the **first** option "(Recommended)" with description = "Reuse the prefix from your most recent plan."; give the rest description = "Reuse a prefix you've used before."
   - A final option: label = "None", description = "No prefix — derive the filename and title from the description alone."
   - The auto-injected **Other** field lets the user type any prefix not shown (including one beyond the 3-most-recent cap).

   When `priorPrefixes` is empty, the menu still renders with just the "None" option (plus the **Other** field) — so the question is always answerable with a single click and the user is never forced to type.

   Interpret the answer: a listed prefix → that prefix; "None" → no prefix; an **Other** reply → the trimmed typed value as the prefix.

3. Strip any double-quote (`"`) characters from the resulting prefix before carrying it into the "Write the plan file" step (Step 5), so both the `title:` and the new `prefix:` frontmatter lines stay valid YAML.

Then move on to investigation (Step 3).

### Step 3: Investigate the codebase

Based on the user's description, explore the relevant parts of the codebase to understand:

1. **Where the change lives** — which files, components, modules, or crates are involved
2. **How things currently work** — read the relevant code to understand current behavior
3. **What needs to change** — identify the specific modifications, new files, or new components needed
4. **What to reuse** — find existing helpers, components, types, or patterns that should be leveraged
5. **What tests exist** — check for existing test coverage in the affected areas
6. **Bug or feature?** — classify the request as a **bug fix** (some current
   behavior is broken and you can state the correct expected behavior) vs a
   **feature/enhancement**. Only bug fixes get a `## Reproduction Test` section
   in Step 5. For a bug, note which existing test file (if any) already covers
   the affected code — that is where the reproduction test will live.

**Always check the project's registries and glossary first** — they are the
authoritative index of reusable code in a codeyam project. Skipping these is
what produces generic "look at the codebase" plans the editor workflow has
to re-research at the `explore` slug:

- `codeyam-editor editor glossary-find <name>` (flags: `--prefix`,
  `--substring`, `--feature`, `--format`) — look up named entries
- `codeyam-editor editor glossary-list` / `glossary-untested` /
  `glossary-by-tag <tag>` — projections across the whole table
- `.codeyam/glossary-index.txt` — line-oriented, greppable sidecar; safe to
  Read or grep directly. Use this when you need to scan for similar names
  or topics rather than look up a known entry
- `.codeyam/test-registry.json` — every registered test, its file, and the
  glossary entries it exercises. Use it to find which tests cover the
  area you're about to touch
- `.codeyam/deps-index.txt` — line-oriented projection of
  `dependency-graph.json`. Use it to find which functions/components
  call into the area you're touching, and what already exists nearby
  that you might reuse

NEVER `Read` `.codeyam/glossary.json` directly — it exceeds the Read tool
limit. Use the CLI / index sidecar.

After the registry/glossary pass, use the Explore agent or direct
Glob/Grep/Read tools to investigate code the indexes pointed you at. Be
thorough — the plan quality depends on understanding the codebase.

**Existing-implementation survey (config field / gate dimension plans).** If
the plan will add a config field, threshold, or gate dimension, grep the
target crate for the proposed field/behavior *before* writing the plan, and
record the result in the `## Reused existing code` section — even when the
answer is "nothing equivalent exists" (write that explicitly). A proposed
`perPathFloor` that duplicates an already-implemented `per_file` threshold
must be caught here, not mid-build. The Confirm gate's
`plan-staleness-check --format json` surfaces a non-null `existingImplAdvisory`
when a field/dimension-adding plan records no survey, so a missing survey
will be flagged at approval.

**Mechanism-feasibility (per-scenario delivery plans).** If the plan
introduces a new mechanism for carrying per-scenario state — an env var, a
launch flag, a process-level config — confirm in the plan that the chosen seam
is read on scenario activation, not only once at dev-server launch. The dev
server starts once and stays up, so a launch-time value is fixed for the whole
session and cannot vary per scenario; the per-scenario seam is the MockEngine
path, not a launch env var.

**First-time cross-target gate inventory.** If the plan adds a cross-target
gate (a new entry in `crossTargetChecks`) for the first time, run a full
no-`-D` inventory of that target and put the real file/item count in the plan.
Scope discovered mid-build (one named file turning into 14 across 10 files)
forces a stop-and-re-scope; the inventory belongs in the plan before approval.

**Referenced-path resolution.** Every repo-relative file path the plan cites
as an *existing* dependency — the root-cause file, the module to modify, the
site to reference — must actually resolve in the tree. Verify each path exists
before writing it into the plan (a wrong root-cause file sends the whole build
against the wrong surface). Paths the plan will *create* are exempt; mark them
`(new)` so they read as intended-new rather than stale. The Confirm gate's
`plan-staleness-check --format json` surfaces a non-null `referencedPathAdvisory`
when a cited, repo-rooted, non-created path does not exist.

**Repro-fixture geometry.** For a bug plan, do not hardcode a reproduction
geometry (a 40x40 grid, an N×M input) as settled fact when it is really an
unverified guess — a fixture that does not actually trigger the failure leaves
the red-first test green and wastes the loop. State in the plan that the
geometry is to be confirmed empirically at execution (observe the fixture
reproduce the bug before trusting it). The Confirm gate surfaces a non-null
`reproFixtureAdvisory` when a repro-context plan names a hardcoded geometry.

**Constrained-file pre-check.** Once investigation has produced the
candidate file list, run it through the editor so the plan never invites an
edit the guards will reject:

```bash
codeyam-editor editor classify-constrained-files <path>... --format json
```

It returns only the constrained files (unconstrained paths are dropped),
each tagged with one or both of:

- **`leanContract`** — a SKILL.md governed by an enforced max-line-count
  test (`skill_md_is_lean`). When `atLimit` is true, additions fail that
  test, so the plan must NOT schedule new lines there. Watch `nearLimit`
  too: it is true within a few lines of the cap, which means a plan adding
  more lines than `headroom` is already over even though `atLimit` is
  false. In either case route the new guidance to a step-library fragment
  and name it in the plan — the concrete command is
  `codeyam-editor editor new-step-fragment <name> --slug <slug>`, which
  writes the fragment, wires its `{<name>_block}` placeholder into
  `step.rs` and each named slug, and prints the leak test to add. Do not
  write a plan whose Implementation section targets a `nearLimit` or
  `atLimit` SKILL.md: the Write/Edit hook refuses that edit, so the plan
  would be unbuildable as written. Reductions (refactors that shrink the
  file) stay fine.
- **`agentConfig`** — a file the harness reads as instructions/settings
  (`.claude/`, `.gemini/`, `ui/.claude/`, `settings.json`, keybindings).
  Edits trip the auto-mode self-modification guard. If the plan genuinely
  needs the change, confirm with the user once (Step 4) that it's an
  authorized agent-config edit before writing it into the plan; otherwise
  route the intent elsewhere.

Surfacing these at plan time avoids the costly discover-at-edit-time cycle —
a full test run to reveal a lean-limit failure, plus a confusing self-mod
denial mid-implementation.

**Reminder: investigation means reading, not changing.** Use only Read, Grep, Glob, and Explore tools here. Do not edit any files during investigation.

### Step 4: Clarify scope

Based on what you found in investigation, ask 1-2 targeted clarifying questions using AskUserQuestion. These should be **specific questions that emerged from reading the code**, not generic planning questions.

Good questions:
- "I found that X and Y are tightly coupled — should both be in scope, or just X?"
- "The current implementation uses pattern A, but pattern B would be simpler here. Which do you prefer?"
- "This change touches the API layer — should we include backend changes, or keep it frontend-only?"

**Skip this step entirely** if the request is unambiguous and investigation answered all questions. Don't ask questions for the sake of asking — only when the answer genuinely affects the plan.

### Step 4b: Decide how many plans (and consolidate before writing)

Investigation often surfaces several findings at once — especially for review,
audit, or "what's wrong with X" requests. Decide the grouping **now**, before
Step 5. Consolidating afterwards means deleting plan files and re-running
`plan-create`, and a `plan-create` that already ran has stamped a `createdAt`
you cannot reproduce.

**One plan per concern — where a concern is a single reason the code changes.**
Fewer plans is better. A reader should be able to state what one plan is about
in a sentence, without "and also".

**Merge two candidates when ALL of these hold:**

1. **Shared cause or surface** — fixing one puts you in the same files, or they
   trace to the same root cause.
2. **One review** — a reviewer looking at one diff would want to see the other
   in it.
3. **One coherent Summary and Key Decisions** — the merged Summary names a
   single problem, and the decisions read as one set rather than two lists
   stapled together.
4. **Nothing gets delayed** — neither piece is independently shippable in a way
   the merge would hold up. A one-line `.gitattributes` fix must not be blocked
   behind a multi-module refactor.

**Keep them separate when any of these hold:**

- **Different rationale, even in the same file.** Two unrelated rules in the
  same hook are two plans.
- **Different subsystems with no shared seam.**
- **Materially different size or risk** — a trivial config change bundled with
  a redesign hides the cheap win and inflates the risky one.
- **The merged Implementation would need more than about five numbered
  changes**, or the merged title needs an "and" joining unlike things.

**The smell test:** write the merged title and the first Summary sentence. If
either needs "and also", or names two problems, it is two plans. If the title
reads as one sentence about one problem, merge.

**Prefer merging over a `dependsOn` chain** when the pieces would land in the
same commit anyway. Reserve `dependsOn` (Step 5) for genuinely sequential
deliverables — a seam that must exist before its consumers can be built.

**Decide this yourself; report it, don't ask.** Apply the test and act on it.
When you authored more than two or three plans, tell the user the grouping in
Step 6 — the count, and a one-line reason for each merge you made *and each one
you declined*. That is a summary to react to, not a question to answer. Ask
only when a genuine judgment call survives the test — for example when merging
would produce one large plan that a reasonable person might still want split
for review or scheduling reasons.

### Step 5: Write the plan file

**Do not create the plan file with the Write tool, and never hand-author its
YAML frontmatter.** Write the plan **body** to a scratch file, then hand it to
`plan-create`, which derives the slug, writes the frontmatter, stamps
`createdAt`, and validates the result:

```bash
codeyam-editor editor plan-create \
  --title "Dark Mode Toggle" \
  --prefix "PROJ-123" \
  --mode ui \
  --body-file .codeyam/tmp/plan-body.md
```

Omit `--prefix` when Step 2 produced no prefix. The command prints the path it
wrote, and refuses rather than clobbering an existing slug.

**Why a command and not the Write tool:** `createdAt` has to be a real
timestamp, and you have no reliable clock — anything you type there is a guess
that the Plan tab then renders as fact. `plan-create` stamps it from the system
clock, so the field is not on your authoring surface at all. There is nothing to
guess and nothing to get wrong.

**Body format** (no frontmatter — `plan-create` writes it):

```markdown
## Summary

One-paragraph description of what to build or fix and why.

## Key Decisions

- Decision 1 — why this approach
- Decision 2 — what was considered and why this was chosen

## Implementation

### 1. First change

**File**: `path/to/file.ext`

Description of what to change and why.

### 2. Second change

**New file**: `path/to/new-file.ext`

Description of what this new file does.

## Reused existing code

- `helperName` from `path/to/helper.ts` (glossary entry: `helperName`)
- `ComponentName` from `path/to/Component.tsx` (glossary entry: `ComponentName`)

Cite registry / glossary entries by name when the plan reuses them. This is
what makes the plan "well-researched" enough for the editor workflow's Plan
and Explore steps to fast-path through to Confirm.

## Reproduction Test

<!-- BUG FIXES ONLY. Omit this whole section for feature/enhancement plans. -->

One sentence naming the buggy behavior this test pins.

**Target**: `path/to/real/test-file.ext` — run with
`codeyam-editor editor refresh-tests --test <name>`.

```ts
// New test: a `//` (or `///` for Rust) description comment is mandatory.
it("returns the merged total for overlapping ranges", () => {
  expect(mergeRanges([[1, 3], [2, 5]])).toEqual([[1, 5]]);
});
```

Status: PROPOSED — confirm red at execution. Expected failure: mergeRanges
returns [[1, 3], [2, 5]], so the `toEqual([[1, 5]])` assertion fails.

## Scenarios to Demonstrate

- Happy path with realistic data
- Empty state
- Edge case 1
- Edge case 2
```

**`plan-create` flags:**
- `--title` (required) — Feature name, the **base title only**. Pass the prefix
  separately via `--prefix`; do not fold it into the title yourself.
- `--mode` (required) — `ui` or `backend`. Default to `ui` unless the change is
  purely backend.
- `--prefix` (optional) — The author/work-item prefix from Step 2, **verbatim**
  as the user typed it. It is stored as the canonical record of the prefix —
  `editor plan-prefixes` (and `editor last-plan-prefix`) read it back to seed the
  next plan's options. **Omit the flag entirely when no prefix was chosen.**
- `--body-file` (required in practice) — Path to the body markdown. Reads stdin
  when omitted.
- `--depends-on <slug>` (optional, repeatable) — A prerequisite plan. The Plan
  tab gates Run on this plan until each listed plan has been archived under
  `.codeyam/plans/completed/`.
- `--skip-citation-check` (optional) — Suppress the citation report described
  below. Only for the deliberate forward reference.

Queue position (`order`) is set via the Plan tab's drag or `editor plan-reorder`,
not at creation.

**`plan-create` verifies the citations you just wrote.** After the plan is
written it resolves every file, `path:line`, and symbol the body cites against
the real tree, and prints a report. Plans routinely cite files, functions, and
line numbers that do not exist; the cost lands on the build agent at the Confirm
gate, an hour after you had the context to fix it in seconds.

What it checks, and what it deliberately does not:

| Section | Citation | Checked? |
|---|---|---|
| `## Implementation` | `**File**:` | Yes — you asserted it exists now |
| `## Implementation` | `**New file**:` | No — you are about to create it |
| `## Reused existing code` | paths and symbols | Yes — reuse presupposes existence |
| `## Reproduction Test` | anything | No — a proposed test names what is not there yet |
| Any fenced code block | anything | No — fixtures are not citations |
| `## Summary`, `## Key Decisions` | anything | No — prose names files illustratively |

A `path:840` is checked against the file's actual length, and against the
symbols cited beside it — a line number that still lands inside the file but
points at unrelated code is the error this catches and a bare path check cannot.

**The report is advice, not a refusal.** `plan-create` writes the plan and exits
`0` either way. Read the report, fix what is genuinely wrong, and move on; pass
`--skip-citation-check` when the forward reference is deliberate. The same scan
reappears as `citationAdvisory` on `editor plan-staleness-check`, so a plan
queued before this shipped still gets the report at the Confirm gate.

**Worked example (prefixed):** `--title "Dark Mode Toggle" --prefix "PROJ-123"`
writes `.codeyam/plans/proj-123--dark-mode-toggle.md` with
`title: "PROJ-123 -- Dark Mode Toggle"` and `prefix: "PROJ-123"` — the ` -- ` in
the title and the `--` join in the slug are both derived for you.

**When to use `dependsOn`:** if the user's request is too big to deliver in
one plan and you split it into multiple plans (per the Step 4b test), declare
dependencies on the prerequisites instead of relying on queue order alone. Reference the slugs
of plans you've authored in the same session — they exist in
`.codeyam/plans/`. The user can then run them in any order; the editor
will block Run on a downstream plan until its prerequisites land.

**The `## Reproduction Test` section (bug fixes only):**

Add this section **only** when the plan is a bug fix *and* a targeted failing
test is genuinely writable from reading the codebase. Its job is to hand the
editor workflow a red-first reproduction it can materialize verbatim. Shape:

- **One sentence** stating the buggy behavior the test pins.
- **Target** — the real test file path where execution should place or modify
  the test, plus the run command `codeyam-editor editor refresh-tests --test
  <name>`. Never hand-write a `cargo test` / `vitest` invocation; the language,
  extension, and runner come from the *target file's* stack, not a default.
- **New test** → a fenced code block with the full test, including the
  mandatory `//` (or `///` for Rust) description comment directly above the
  `it()` / `#[test]` — the rule the audit enforces.
- **Change to an existing test** → name the existing test and give a fenced
  unified-diff (or before/after) showing the assertion flip that turns it red,
  so execution can apply it exactly.
- **Status** — `Status: PROPOSED — confirm red at execution`, plus the expected
  failure (which assertion fails and roughly what message). You cannot run the
  test (the critical rule), so confirming the red is the execution workflow's
  job, not yours.
- **Backticks in this section are load-bearing.** `plan-staleness-check` reads
  the first backticked bare identifier here and RUNS it, to detect a fix that
  already landed. It only cites an identifier that names a **registered** test, so
  an ordinary English word in backticks is passed over — but keep prose symbols
  unbackticked anyway, and put the test you actually want run in backticks first.
  The `**Target**:` path is documentation for the human and is **never run**. A
  path names where the test will be written, not a test that exists, so running
  that file would only prove its *other* tests pass — a fact about other work, not
  about this plan. Citing one used to fire a blocking "the fix already landed"
  false positive; now it anchors no run and reports a non-blocking advisory
  instead. Only a backticked bare identifier naming a registered test anchors the
  staleness run.
- **When no reproduction test is writable** (visual/layout regressions, bugs
  needing live runtime state), still include the section but record a one-line
  *reason* instead of fabricating a weak test — e.g. *"Visual regression — no
  isolatable unit repro; demonstrate via scenario 'empty dashboard'."* An honest
  "no unit-level repro" beats a fake red.

**Guidelines for plan content:**
- Focus on **what the user will see and do**, not just implementation details
- For a **bug fix**, capture a `## Reproduction Test` (see above) that isolates
  the bug's root cause, stays minimal, and matches the target file's stack — no
  hardcoded runner or extension. Skip the section entirely for features.
- Be specific about file paths — you investigated the codebase, so name real files
- List concrete scenarios with interesting data states (empty, rich, error, edge cases)
- Keep the summary concise — the editor's Step 1 will refine details
- For bug fixes, describe the current broken behavior and the expected correct behavior
- Reference real existing code that should be reused — include file paths
- Honor Step 3's constrained-file pre-check: never leave a section as "edit
  SKILL.md" for a lean file at its limit — name the step `.txt` file the
  guidance should live in instead, and call out any authorized agent-config
  edit explicitly so the editor workflow isn't surprised by the self-mod guard

**Co-locating plan assets (screenshots, mockups, reference images):** when the
user uploaded or provided an asset the plan should carry, write it into the
plan's own asset directory and reference it from the body with a **relative**
path:

- Directory: `.codeyam/plans/assets/<slug>/<name>` — the same `<slug>` as the
  `.md` file (no prefix normalization beyond the slug rules above).
- Reference in the markdown body with standard image syntax and the path
  **relative to the plan file**: `![description](assets/<slug>/<name>)`.

Use the relative form deliberately. The editor's Rust lifecycle moves the asset
directory into `.codeyam/plans/completed/assets/<slug>/` in parallel with the
`.md` when the plan is selected, so the identical relative reference resolves
in both the queued and completed locations — an absolute or
`.codeyam/plans/…`-rooted path would break on that move. You only write the
files and the relative reference; the engine guarantees the move and the
eventual cleanup (prune / delete) even if this skill forgets. A plan with no
assets simply has no `assets/<slug>/` directory — it is entirely optional.

### Step 6: Present and confirm

Run `codeyam-editor editor plans` to verify the plan is parseable and shows up correctly.

Show the user a brief summary of the plan. When Step 4b produced more than two
or three plans, lead with the grouping: how many there are, and one line per
merge you made and per merge you considered and declined. Then use
AskUserQuestion with these options:
- **"Looks good, commit it" (Recommended)** — Commit the plan and finish
- **"I want changes"** — User describes changes, you revise the plan, then re-present
- **"Discard and start over"** — Delete the plan file and go back to Step 1

### Step 7: Act on response

- **Looks good** — Commit the plan, then signal the UI.

  **Commit hygiene:** the plan commit must contain only the plan file
  `.codeyam/plans/<slug>.md` **plus, when the plan co-located assets, its
  `.codeyam/plans/assets/<slug>/` directory**. Use the pathspec form below — do
  not run a bare `git commit`, since other files may be staged from prior work.
  (This is the plan-creation commit specifically — it must contain only the plan
  file and its asset directory. The feature-commit step at the end of the editor
  workflow has a different rule: it auto-commits all non-gitignored leftovers.)
  After committing, verify with `git show --stat HEAD` that only the plan file
  (and any asset files) are listed; if anything else appears, run `git reset
  --soft HEAD~1` and retry with the pathspec form.

  **Always append `[skip ci]` to the commit message.** Plan files don't change source or tests, so CI must not be triggered. This is non-optional — apply it on the initial commit and on any amend.

  The plan file is brand-new and untracked, so it must be staged before the
  pathspec commit — `git commit -- <pathspec>` only commits *already-tracked*
  changes and fails with `pathspec ... did not match any file(s) known to git`
  on a new file. Stage the single plan file first (this does not violate the
  "only the plan file — never `git add -A`" guarantee; the pathspec commit
  still scopes the commit to that one file).

  ```bash
  # Add the asset dir pathspec too when the plan co-located assets:
  #   git add .codeyam/plans/<slug>.md .codeyam/plans/assets/<slug>
  git add .codeyam/plans/<slug>.md
  git commit -m "plan: <short description of the feature/fix> [skip ci]" -- .codeyam/plans/<slug>.md
  git show --stat --name-only HEAD   # verify only the plan file (and any assets) are in the commit
  codeyam-editor editor plan-complete
  ```
  After the commit succeeds, `plan-complete` triggers a confirmation modal
  in the Plan tab offering to start another plan or return to the queued
  changes list. Only run `plan-complete` on this branch — not on "I want
  changes" (which loops back to Step 6) or "Discard" (which returns to
  Step 1 with no plan saved).
- **I want changes** — Make the requested changes to the plan file, then go back to Step 6
- **Discard** — Delete the plan file and return to Step 1

## Tips

- Spend most of your time in Step 3 (investigation). A plan based on real codebase understanding is far more valuable than a generic one.
- If the feature touches multiple areas, organize the Implementation section by area, not by order of execution.
- Plans with `mode: backend` will suggest backend mode when selected in the editor.
- Don't over-specify implementation — leave room for the editor workflow to make tactical decisions. Focus on the "what" and "why", with enough "how" to be actionable.
