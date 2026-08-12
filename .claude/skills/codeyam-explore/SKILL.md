---
name: codeyam-explore
description: The first thing to run in an existing repo. Reads `editor assess`, explains where the repo stands in plain language, then offers a small menu of low-risk, clearly-labeled options — diagnose deeper, see your app as scenarios, adopt one vertical slice, go forward-only, or spin up a new companion app. Every option is additive and reversible, so trying codeyam on a real codebase never feels like a commitment. Opt-in and interactive, unlike the autonomous `/codeyam-onboard` flow.
---

# CodeYam — Explore (First-Run Options Menu)

You are the **on-ramp**: the first thing a user runs after pointing codeyam at a
repo they already have. Your job is to lower the felt risk of trying codeyam to
near zero. You do that by (1) reading a zero-mutation assessment of the repo,
(2) explaining where it stands in plain language, and (3) offering a small menu
of **low-risk, clearly-labeled options** — each described in terms of *what it
does*, and the fact that it is **additive and reversible**.

Nothing you do in this skill writes outside `.codeyam/`, and you never start a
chosen option without the user picking it. Exploring codeyam in a real codebase
should never feel like a commitment.

Unlike `/codeyam-onboard` — which is **autonomous**, one-size, and writes
everything end-to-end — this flow is **interactive and menu-driven**: it does
the minimum the user chooses, and only that.

## Phase 0 — Detect project state

Before assessing, find out whether this repo is already onboarded. Run:

```
codeyam-editor editor migration-status --format json
```

Branch on `schema`:

- **`modern`** — `.codeyam/editor.json` is present and current. This repo is
  already onboarded. Don't run the on-ramp menu; tell the user they're set up
  and the normal path is to plan and build the next feature (`/codeyam-plan`,
  then the editor workflow). Offer the menu anyway if they want to explore the
  other options, but lead with "you're already onboarded."
- **`legacy`** — an old codeyam-tool layout (`.codeyam/config.json` with
  `webapps`). This needs migration, not the on-ramp. Route the user to
  `/codeyam-onboard`, which handles the legacy → modern migration, and stop.
- **`none`** — no `.codeyam/` yet. This is the on-ramp's **primary audience**.
  Continue to Phase 1.

## Phase 1 — Assess (zero-mutation)

Read the read-only assessment. It mutates nothing on disk:

```
codeyam-editor editor assess --format json
```

From the JSON, note:

- `recommendedAction` — the single deterministic next action the assessment
  recommends, one of `scaffold-app`, `go-forward-only`, `adopt-vertical-slice`,
  `backfill-tests`, `capture-scenarios`. Use it to **pre-select** the menu's
  default option (Phase 3), not to override the user's choice.
- `recommendationDetail` — a one-line plain-language reason for the
  recommendation. Surface it verbatim; it's already user-facing copy.
- `visualCaptureViable` / `shape` — whether this stack renders screenshots at
  all. A CLI, a backend service, or an unsupported stack is `false`; that steers
  the menu away from "see your app as scenarios" and toward forward-only / new
  companion app.
- `blastRadius[]` — high fan-in files carrying untested entities. The top entry
  is usually the best first vertical slice. `hotspots[]` — large files worth
  deconstructing. `untestedEntities` / `untestedSample` — TDD gaps.

## Phase 2 — Explain where the repo stands

In **plain language** (not raw JSON), tell the user what the assessment found:
the size of the codebase, whether it's visual, where the test gaps and
highest-leverage files are, and what codeyam recommends as a first step
(`recommendationDetail`). Keep it short — a few sentences, oriented around "here
is where you are and here is the safest first thing to try."

## Phase 3 — Present the options menu

Present the menu via `AskUserQuestion`. **Order it so the assessment's
`recommendedAction` is the first (recommended) option**, then list the rest. For
each option, the copy must carry the risk framing — name what it does *and* that
it is additive and reversible. The options:

- **A. Diagnose deeper** — walk through the assessment in detail (hotspots,
  blast radius, untested entities) so the user understands their codebase before
  changing anything. Reads only; writes nothing. *Default when
  `recommendedAction` is `backfill-tests` or the user wants to understand the
  repo first.*
- **B. See your app as scenarios** — capture a handful of real pages/components
  as codeyam scenarios so the user immediately sees their app in real states.
  Writes only under `.codeyam/`, never touches app source, fully reversible via
  one-step teardown. Runs the `/codeyam-see-app` flow. *Default when
  `recommendedAction` is `capture-scenarios` and `visualCaptureViable` is true.*
- **C. Adopt one vertical slice** — pick the single highest-leverage file (the
  top `blastRadius[]` entry) and bring just that slice under codeyam's
  deconstruct + TDD + scenario standard. Scoped to one slice; the rest of the
  repo is untouched. *Default when `recommendedAction` is `adopt-vertical-slice`.*
- **D. Use it going forward** — leave the existing code as-is and start using the
  normal plan → build workflow on the *next* feature. Nothing in the current
  codebase changes; codeyam only governs new work. *Default when
  `recommendedAction` is `go-forward-only` or the stack is non-visual.*
- **E. Spin up a new companion app** — scaffold a fresh, codeyam-native app
  alongside the existing repo, leaving the current code entirely untouched.
  *Default when `recommendedAction` is `scaffold-app` / the repo is empty.*

Always make the additive-and-reversible framing first-class in the copy, not a
footnote — lowering felt risk is the whole point of this skill.

## Phase 4 — Route to the chosen option

Hand off to the backing flow for the user's choice. Some backing flows ship as
their own skills; others are planned and not yet built. Route what exists, and
for the rest, **name the option and tell the user it's coming** — never pretend
a route exists that doesn't, and never silently drop a choice:

- **B. See your app as scenarios** → run the `/codeyam-see-app` skill.
- **D. Use it going forward** → start the normal workflow: `/codeyam-plan` to
  plan the next feature, then drive the editor workflow.
- **A. Diagnose deeper** → walk the `assess` JSON with the user inline (no
  separate skill needed); the data is already in hand from Phase 1.
- **C. Adopt one vertical slice** → backed by a dedicated adoption flow
  (`onramp-vertical-slice-adoption`). If that skill isn't installed yet, explain
  what adopting a slice will do and that the guided flow is coming; you can still
  begin manually by planning a slice with `/codeyam-plan`.
- **E. Spin up a new companion app** → backed by a dedicated scaffold flow
  (`onramp-new-companion-app`). If not installed yet, explain what it will do and
  that the guided flow is coming.

Routes light up as their backing plans land. This skill is shippable before
them: it names every option and explains what each does, so the menu is honest
and useful from day one.

## Guardrails

- **Opt-in, always.** Never start an option the user didn't pick. The menu is
  the contract.
- **Additive and reversible.** Everything this skill touches lives under
  `.codeyam/`. If you reach for a file outside `.codeyam/`, stop — that belongs
  to a chosen option's flow, not the on-ramp.
- **State-aware.** A `modern` repo is already onboarded; a `legacy` repo routes
  to `/codeyam-onboard`; a `none` repo is the primary audience. Don't run the
  full menu on a repo that doesn't need it.
- **Honest about what's built.** Name options that aren't wired yet as coming —
  never fabricate a route, never silently drop a choice.
- **Risk framing is product copy.** Every option states what it does and that
  it's safe to try. That copy is the deliverable, not a nicety.
