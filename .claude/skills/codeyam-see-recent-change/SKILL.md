---
name: codeyam-see-recent-change
description: Demonstrate a recent change as codeyam scenarios. Points codeyam at a recent PR or the last N commits, maps the changed files to the routes/components they affect, and shows the change rendered as scenarios — existing ones that already cover it, plus new ones it offers to capture for surfaces with no scenario yet. Read-only on git; additive on .codeyam/, fully reversible.
---

# CodeYam — Demonstrate a Recent Change

You are running a **guided, opt-in demo** built around the single most
compelling first-session hook: showing the user *their own recent change*
rendered as codeyam scenarios. Tying codeyam to work they just did beats a
generic home-page capture — it answers "what does codeyam do for the change I
just made?" directly.

Like `/codeyam-see-app`, this is **safe to try**:

- **Read-only on git.** You only *read* history and diffs — never commit, amend,
  checkout, or reset.
- **Purely additive on `.codeyam/`.** You write scenario JSON + screenshots under
  `.codeyam/` and **never edit application source**. If you reach for a file
  outside `.codeyam/`, stop — that is out of scope for this flow.
- **Fully reversible.** Phase 5 offers one-step teardown of exactly what this
  flow created. Reversibility is the trust mechanic — lead with it.

This flow builds on `/codeyam-see-app` (which captures high-value surfaces
generally); here the surfaces are chosen *from the diff*, so every scenario
demonstrates something the change actually touched.

## Phase 0 — Set expectations

Tell the user, in one or two sentences, what is about to happen: you'll look at
a recent change (a PR or the last few commits), find the routes/components it
affected, and show them rendered as codeyam scenarios — reusing scenarios that
already cover the change and offering to capture new ones where none exist.
Additive, under `.codeyam/` only, and removable afterward. Then continue.

## Phase 1 — Pick the change to demonstrate

Establish the base to diff against. Ask the user, or infer a sensible default:

- **Last N commits** — diff against `HEAD~N` (e.g. `HEAD~1` for the last commit,
  `HEAD~5` for the last five).
- **A PR / branch** — diff against the merge-base with the primary branch
  (e.g. `main`), so the change set is "everything this branch added."
- **Uncommitted work** — omit `--base` to use the working-tree delta.

Keep it concrete: confirm the base with the user before running, so the
"recent change" matches what they have in mind.

## Phase 2 — Map the change to surfaces

Run the read-only mapper. It diffs git against the base, maps changed files to
UI surfaces via the dependency graph, and partitions the result:

```
codeyam-editor editor changed-surfaces --base <ref> --format json
```

(Omit `--base` for the working-tree delta.) The JSON has:

- **`covered`** — existing scenarios that already demonstrate the change, each
  with the tier (1 = the scenario's own source/JSON changed, 2 = its route
  renders a changed page, 3 = a transitive dependency) and the reason. These are
  the *fastest* payoff: the user's change is already visible in scenarios they
  have. Surface these first.
- **`uncovered`** — changed **surfaces with no scenario yet** (`kind` is
  `component` or `route`, plus `name`, `file`, and a `suggestedSlug`). These are
  the propose-and-capture candidates for Phase 3.
- **`noUiImpact`** — changed files that are neither a surface nor a transitive
  dependency of any scenario (pure backend / util / config / state). There is
  nothing visual to capture for these; see Phase 4.

If `changedFiles` is empty, the base resolved to no diff — tell the user plainly
and ask for a different base (Phase 1).

## Phase 3 — Show covered, then propose + capture uncovered

**Covered first.** For each `covered` recommendation, point the user at the
existing scenario that demonstrates their change (slug + reason). If a preview is
up, navigate to one or two so they *see* it:

```
codeyam-editor editor preview-nav '{"path":"/","dimension":"<defaultScreenSize>"}'
```

**Then propose the uncovered surfaces.** Show the `uncovered` list once (slug +
what it captures + the change it demonstrates) — do not prompt per-scenario.
Keep it to a handful; this is a taste, not exhaustive coverage. For each one the
user wants, register it additively, then capture:

```
# Write a UNIQUE scratch file per call — register consumes & deletes it on success.
cat > .codeyam/tmp/recent-change-<suggestedSlug>-<unique>.json <<'EOF'
{ "slug": "recent-change-<suggestedSlug>", "kind": "application", "url": "<route>", "screen_size": "<defaultScreenSize>" }
EOF
codeyam-editor editor register --file .codeyam/tmp/recent-change-<suggestedSlug>-<unique>.json
```

- For a `route` surface, `name` is the real URL — use it as the application
  scenario's `url`.
- For a `component` surface, register a component scenario using **this
  project's isolation contract** (the same kind/url shape `/codeyam-see-app`
  Phase 3 and `/codeyam-onboard` Phase 5 use). Do not invent a different schema
  or hardcode an isolation path — match what `register` expects for this stack.

**Prefix every scenario slug with `recent-change-`** so Phase 5 teardown removes
exactly what this flow created and nothing else.

Then capture screenshots for what you registered:

```
codeyam-editor editor recapture-stale --skip-when-clean --prefer-touched
```

`--prefer-touched` orders the just-changed surfaces first so the `--max-seconds`
budget captures the change you came to see before any unrelated
environmentally-drifted screenshots. It only reorders — it never excludes or
expands the set.

- **Preview up:** the user sees their change rendered — surface the captures.
- **Preview down:** register anyway and say capture is **pending** — the
  scenarios exist and will capture next time the preview is up. Don't fail.

This phase is **best-effort**: if one surface fails to register or capture, log
it and continue — never block the whole demo on a single surface.

## Phase 4 — Handle the no-UI-impact case honestly

When the change is mostly or entirely `noUiImpact` (a pure backend/util/config
change), say so plainly — there is no screenshot to show for those files. Don't
fabricate a visual. Instead:

- If the project supports **data/state scenarios** for the affected logic,
  offer to register one that exercises the changed behavior.
- Otherwise, point the user at a **unit test** as the right way to demonstrate
  this change, and note that codeyam's value here is the test coverage, not a
  screenshot.

A change with no visual surface is a normal, expected outcome — frame it as
"this change is backend logic; here's how codeyam demonstrates *that*," not as a
failure of the flow.

## Phase 5 — Offer teardown (reversibility)

Always offer to remove the demo scenarios so trying this is fully reversible.
Ask whether to keep them or remove them.

- **Keep:** done — the scenarios are theirs.
- **Remove:** delete the `recent-change-`-prefixed scenarios under
  `.codeyam/scenarios/` and their captured screenshots. Because the flow only
  ever wrote under `.codeyam/` and never ran a mutating git command, removing
  those scenarios returns the repo to its exact prior state. Confirm to the user
  that nothing outside `.codeyam/` was changed and no git history was touched.

## Guardrails

- **Read-only git.** Diffs and history only — never a mutating git command.
- **Never edit application source.** Writes are confined to `.codeyam/`.
- **Best-effort, not all-or-nothing.** One bad surface is logged and skipped.
- **Stack-aware.** `changed-surfaces` returns no route/component surfaces for a
  non-web stack — fall back to the Phase 4 test/state framing rather than forcing
  a screenshot.
- **Re-runnable.** Safe to run again against a different base; the
  `recent-change-` prefix keeps its scenarios identifiable and teardown surgical.
