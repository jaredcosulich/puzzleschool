---
name: codeyam-see-app
description: See your existing app rendered as codeyam scenarios. A guided, opt-in, purely additive flow — captures a handful of high-value pages/components as scenarios (writes only under .codeyam/, never touches app source) so you immediately see your real app in real states. Fully reversible via one-step teardown.
---

# CodeYam — See Your App as Scenarios

You are running a **guided, opt-in demo**: capture a few high-value pages and
components from the user's *existing* app as codeyam scenarios, so they
immediately see their real app rendered in real states inside codeyam.

This is the fastest "oh, I get it" moment for someone evaluating codeyam on a
repo they already have. The whole point is that it is **safe to try**:

- **Purely additive.** You write scenario JSON + screenshots under `.codeyam/`
  and **never edit application source**. If you find yourself reaching for a
  file outside `.codeyam/`, stop — that is out of scope for this flow.
- **Fully reversible.** You offer a one-step teardown at the end (Phase 5) that
  removes the demo scenarios, so the user can try this and walk away with their
  repo exactly as it was. Reversibility is the trust mechanic — lead with it.

Unlike `/codeyam-onboard` (which captures scenarios autonomously, deep inside a
larger flow with no user control), this is a first-class, **re-runnable**
"show me my app" experience. Ask before you capture; the user is in control.

## Phase 0 — Set expectations

Tell the user, in one or two sentences, what is about to happen: you'll look at
their repo, pick a few meaningful surfaces, register them as codeyam scenarios
(additive, under `.codeyam/` only), capture screenshots if a preview is
available, and offer to remove everything afterward. Then continue.

Do **not** prompt for per-scenario confirmation — propose the set once
(Phase 2), capture, and show the result.

## Phase 1 — Assess (let the repo pick the surfaces)

Do not guess at what to capture. Read the read-only assessment:

```
codeyam-editor editor assess --format json
```

This is zero-mutation. From the JSON, note:

- `shape` and `visualCaptureViable` — tells you whether this stack renders
  screenshots at all (a CLI, a backend service, or an unsupported stack will be
  `false`). **Branch on this in Phase 3.**
- `recommendedAction` — when it is `capture-scenarios`, the repo is well-covered
  and this flow is exactly the recommended next step; lead with that framing.
  When it is `go-forward-only` / `scaffold-app`, see Phase 3's non-visual /
  empty-repo branches.
- `blastRadius[]` — high fan-in files are the **most-imported components**; the
  top entry is usually the single most meaningful component to showcase.
- `hotspots[]` — large files; useful secondary signal for "what matters here."

## Phase 2 — Propose ≤5 scenarios

From the assessment, assemble a list of **at most 5** scenarios spanning, where
they exist:

1. The home / landing page (an **application** scenario at the real route `/`).
2. The 1–2 most-imported components from `blastRadius[]` (**component**
   scenarios via isolation routes).
3. One auth- or data-loaded page if the app has one (an application scenario;
   it may need browser state / seeding to render meaningfully).

Show the user the proposed list (slug + what it captures + why it was picked)
before registering. Keep it short — this is a taste, not exhaustive coverage.

## Phase 3 — Register (additive) and capture

For each proposed scenario, write a **unique** scratch file and register it.
`register` consumes and deletes the scratch file on success, so never reuse a
filename across calls.

```
# application scenario (a real route)
cat > .codeyam/tmp/see-app-home-<unique>.json <<'EOF'
{ "slug": "see-app-home", "kind": "application", "url": "/", "screen_size": "Desktop" }
EOF
codeyam-editor editor register --file .codeyam/tmp/see-app-home-<unique>.json
```

Component scenarios use isolation routes rather than a top-level URL — the same
contract `/codeyam-onboard` Phase 5 uses. Match the kind/url shape the
`register` command expects for this project; do not invent a different schema.

**Prefix every demo slug with `see-app-`** so Phase 5 teardown can find and
remove exactly what this flow created and nothing else.

Then branch on `visualCaptureViable` from Phase 1:

- **Visual stack, preview up:** capture screenshots with
  `codeyam-editor editor recapture-stale --skip-when-clean --prefer-touched`.
  `--prefer-touched` orders the scenarios you just registered first so the
  `--max-seconds` budget captures them before any unrelated
  environmentally-drifted surface (pure reordering, never expands the set). The
  user sees their real app rendered in real states — this is the payoff; surface
  the captured scenarios.
- **Visual stack, preview down:** register the scenarios anyway and tell the
  user plainly that capture is **pending** — the scenarios exist and will
  capture the next time the dev server / preview is up. Do not fail the flow.
- **Non-visual stack** (CLI, backend service, unsupported — `visualCaptureViable`
  is `false`): say so plainly. There are no screenshots for this stack. Fall
  back to registering data/state scenarios where the project supports them;
  if nothing applies, explain that this flow is screenshot-oriented and the
  user's best next step is the one `assess` recommended (`recommendedAction`),
  then skip to Phase 5.

This phase is **best-effort**: if one scenario fails to register or capture, log
it for the user and continue — never block the whole demo on a single surface.

## Phase 4 — Show the result

Point the user at what they now have: the registered scenarios and (if visual)
their captured screenshots. This is the "see your app as scenarios" moment —
make it concrete (slugs, what each shows). Briefly note these are real states of
*their* app, captured without touching a line of their source.

## Phase 5 — Offer teardown (reversibility)

Always offer to remove the demo scenarios so trying this is fully reversible.
Ask the user whether to keep the scenarios or remove them.

- **Keep:** done — the scenarios are theirs.
- **Remove:** delete the registered scenario files this flow created (the
  `see-app-`-prefixed scenarios under `.codeyam/scenarios/`, plus any captured
  screenshots for them). Because the flow only ever wrote under `.codeyam/`,
  removing those scenarios returns the repo to its exact prior state. Confirm to
  the user that nothing outside `.codeyam/` was changed.

## Guardrails

- **Never edit application source.** Writes are confined to `.codeyam/`.
- **Best-effort, not all-or-nothing.** One bad scenario is logged and skipped.
- **Stack-aware.** Non-visual stacks get an honest "no screenshots here" plus a
  graceful fallback — never a hard failure and never a fabricated screenshot.
- **Re-runnable.** This flow is safe to run again; the `see-app-` prefix keeps
  its scenarios identifiable and its teardown surgical.
