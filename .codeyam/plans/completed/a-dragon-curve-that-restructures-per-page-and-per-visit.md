---
title: "A Dragon Curve That Restructures Per Page and Per Visit"
mode: ui
createdAt: "2026-08-18T01:25:13Z"
source: manual
---

## Summary

The dark band that closes every internal page carries a dragon curve across its
top, and that curve is the one structure on the site that never changes: it takes
no seed, has no client script, and `dragonPoints(12, { step: 7, fraction: 0.85 })`
draws the identical figure on every page and every visit. The branching tree, the
harmonograph and the Voronoi field all vary on two axes — per page at build time
from a hashed `seedKey`, per visit in the browser, both frozen by `?tree=static`.
Bring the dragon curve onto that same footing. Because the Heighway dragon is a
single fixed fractal with nothing to sample, the figure is generalised to its
FOLD-WORD family: the curve is a sequence of right-angle folds, and the classic
dragon is the word where every fold turns the same way. Drawing each fold from the
seed makes every load a genuinely different lattice curve of the same species,
with the shipped dragon still a member of the family. Rotation, iteration depth
and the cut-off point are sampled alongside it, and — as with the other three
structures — the result is checked against an acceptance envelope rather than
trusted, because a random fold word can retrace its own edges into a blot.

## Key Decisions

- **Generalise to the fold word, not just the parameters.** A dragon curve is
  built by repeated folding: `turns(k+1) = turns(k) ++ [d(k)] ++ reverse(negate(turns(k)))`.
  Fixing every `d` at right gives the Heighway dragon; drawing each `d` from the
  seed gives 2^n curves that are all still orthogonal lattice walks at the same
  complexity. This is what makes the change a RESTRUCTURE rather than the same
  fractal rotated — which is the thing the tree does and the reason it reads as
  grown rather than printed.
- **The all-right fold word must reproduce `dragonPoints` exactly, and a test
  asserts it.** That is the fidelity check that the generalisation is faithful,
  the same role `applyTreeGrowth`'s seven pre-existing tests played when
  `applyFigure` was extracted out from under them. `dragonPoints` therefore stays
  in `src/lib/structures.ts` unchanged — it is not dead code after this, it is the
  reference specimen the new generator is measured against.
- **A new `src/lib/dragon.ts`, not more of `structures.ts`.** The harmonograph and
  the Voronoi field each got their own module the moment they carried an envelope,
  a variant sampler, a shortfall score and an acceptance loop; this figure now
  carries the same four. The L-system primitives (`lsystem`, `turtle`,
  `kochPoints`, `dragonPoints`) stay where they are, because `KochFragment` still
  uses them and they are shared vocabulary rather than this figure's own.
- **Walk the folds through the existing `turtle`.** The turn sequence is emitted
  as a turtle command string and walked by `turtle(..., { angle: 90 })`, so
  `fraction`, `heading` and `origin` keep exactly the semantics they already have
  and the cut-off behaviour stays the one that is already tested. Writing a second
  walker would fork that.
- **Self-overlap is the acceptance term this figure needs and no other has.** The
  Heighway dragon famously never crosses itself; a random fold word often does,
  and a retraced edge draws twice as a visibly heavier line — the blot failure
  mode, arriving by a different route than the harmonograph's. So the shortfall
  score measures the fraction of lattice edges walked more than once and bands it
  near zero, alongside aspect and coverage terms of the kind the other three
  structures already use.
- **The envelope is calibrated to ADMIT the figure shipping today**, exactly as
  `SEGMENT_BAND`'s floor was set to admit the 39-segment tree that predated
  variation. The current curve is the one piece of ground truth about what reads
  correctly in this band, so `dragonShortfall` must score it 0; any band that
  rejects it is wrong, not the specimen.
- **`?tree=static` is reused, not joined by a fourth flag.** Its real meaning is
  already "do not regrow generated figures after load", every frozen scenario URL
  carries it, and a `?dragon=static` would mean rewriting all of them to freeze a
  page that would then hold four different structures.
- **The curve stays IN FLOW and its well keeps its fixed height.** The band's
  quote is pulled up through this figure (`margin-top: -306px`), so the redraw
  rewrites `d` and the viewBox inside a well whose height is still set by the
  `height` prop — no layout shift, and the pull-up keeps something to be pulled
  up through.
- **Per-page seed reaches the curve through the band, salted `:dragon`.**
  `ExploratoryBand` gains a pass-through `seedKey` and the route hands it
  `page.id`, so About, Contact and a page a CMS editor writes next year each get
  their own curve with no code change — and the salt keeps this figure from being
  the same draw as the harmonograph or the field on the same page.

## Implementation

### 1. The generator, its envelope and its acceptance check

**New file**: `src/lib/dragon.ts`

- `foldTurns(folds)` — build the turn sequence from a fold word by the recurrence
  above, returning `+1`/`-1` per turn. `2^n` folds give `2^n - 1` turns.
- `foldCommands(turns)` — the turtle string: `F`, then `+F` or `-F` per turn.
- `dragonTrace(options)` — `turtle(foldCommands(foldTurns(folds)), { angle: 90, step, fraction, heading, origin })`.
- `DRAGON_ENVELOPE` — the sampled ranges as one readable object, mirroring
  `TREE_ENVELOPE`'s `ranges`/`fixed` split: `iterations` 11–13 (integer),
  `fraction` 0.6–0.95, `quarterTurn` 0–3 (integer, multiplied to 0/90/180/270 for
  `heading`), plus one fold direction drawn per iteration. `step` is FIXED —
  the viewBox is derived from the walk's own bounds and stretched to the band
  with `preserveAspectRatio="none"`, so `step` is invisible in the output and
  varying it would be a variation costume over nothing.
- `dragonVariant(seed)` — maps a seed onto one bounded option set via
  `seededRandom`, drawing in a FIXED order so a seed is reproducible; the fold
  word is drawn last, one bit per iteration.
- `dragonViewBox(points)` — `pointBounds` plus a 1-unit margin, extracted for the
  same reason `treeViewBox` was: both the server render and the client redraw need
  it, and duplicating it lets the two frame the same curve differently.
- `dragonShortfall(points)` / `isAcceptableDragon` / `growAcceptableDragon(seed, attempts = 20)` —
  the same shape as `growAcceptableTree`: score, return the first draw that scores
  0, otherwise fall back to the closest attempt rather than throwing, because this
  runs inside a page render with nobody to catch an exception and a slightly-off
  curve beats an empty band.

Shortfall terms, each normalised to roughly "fraction of the way out of band" so
none dominates:

- **Retrace** — lattice edges walked more than once, as a fraction of edges
  walked. Keyed on the rounded endpoint pair so an edge and its reverse are the
  same edge. Banded near 0; this is the term that rejects the blot.
- **Aspect** — `width / height` of the walk's bounds, banded so the band's
  anisotropic stretch reads as fit rather than distortion. Calibrate the band
  against the currently shipped figure.
- **Coverage** — occupied lattice cells over bounding-box cells, in the spirit of
  `measureCoverage` in `src/lib/harmonograph.ts`. Rejects a sparse spike or a walk
  that is mostly one long straight run.
- **Openness** — the distance between first and last point, as a fraction of the
  bounding diagonal, floored. The figure's stated character is "cut off before it
  closes"; a draw that ends where it started reads as resolved, which is the one
  thing it must not be.

### 2. Tests for the generator

**New file**: `src/lib/dragon.test.ts`

- The all-right fold word reproduces `dragonPoints(n, ...)` point for point — the
  fidelity check.
- `foldTurns` length and symmetry: `2^n - 1` turns, and the second half is the
  reversed negation of the first.
- `fraction` below 1 stops the walk early (mirroring the existing `dragonPoints`
  test).
- `dragonVariant` is deterministic per seed and lands inside `DRAGON_ENVELOPE` for
  a sweep of seeds.
- `dragonShortfall` scores the currently shipped figure 0 (the ground-truth
  specimen), and scores a hand-built degenerate control — a fold word chosen to
  retrace heavily — materially higher.
- Zero fall-through: `growAcceptableDragon` returns an acceptable curve for a
  sweep of 3000 seeds, the bar the harmonograph and the field were held to.
- `dragonViewBox` frames the drawn points with the margin.

### 3. The component: two seeds, two moments

**File**: `src/components/structures/DragonCurve.astro`

- Add `seedKey` and `seed` props, resolving as the other two do:
  `seed ?? hashSeed(`${seedKey ?? 'default'}:dragon`)`.
- Draw with `growAcceptableDragon(resolved)`; frame with `dragonViewBox`; mark the
  `<svg>` `data-dragon`.
- Add the `<script>` block: read the presence-only `?tree=static` flag, and when
  not frozen redraw each `svg[data-dragon]` from `randomTreeSeed()` inside a
  single `requestAnimationFrame` via `applyFigure(svg, dragonViewBox(points), [{ d: toPath(points) }])`,
  wrapped in a `try` that silently keeps the server's curve on failure. Copy the
  reasoning structure of the harmonograph's script rather than inventing a
  different one.
- Keep the header comment's existing load-bearing notes (in flow, not absolute;
  `preserveAspectRatio="none"`; hairline via `vector-effect`) and add the
  two-axes note.

### 4. The band passes the page's identity down

**File**: `src/components/page/ExploratoryBand.astro`

Add an optional `seedKey` prop and forward it to `<DragonCurve seedKey={seedKey} />`.
Nothing else changes; a band rendered without one falls back to the shared
`default` curve, which is what the isolation pages want.

### 5. The route names the seed

**File**: `src/pages/[...slug].astro`

Pass `seedKey={page.id}` to `<ExploratoryBand>`, alongside the `seedKey` already
handed to `<ProseColumns>`. This is the whole per-page axis: a page created in
`/admin` next year gets its own curve with no code change.

### 6. A variations sheet, so the envelope can be judged

**New file**: `src/pages/isolated-components/DragonCurveVariations.astro`

Eight fixed seeds side by side, plus a CONTROL lane or two that bypass
`growAcceptableDragon` and pass a raw degenerate fold word straight through, so
the retrace guard can be SEEN failing rather than trusted — the pattern
`src/pages/isolated-components/HarmonographVariations.astro` and
`src/pages/isolated-components/VoronoiFieldVariations.astro` already establish.
Because the curve is drawn full-width, lay the specimens out stacked rather than
in a row. Register with:

`codeyam-editor editor register '{"name":"DragonCurve - Variations","componentName":"DragonCurve","url":"/isolated-components/DragonCurveVariations?tree=static","dimensions":["Desktop"]}'`

### 7. Freeze the scenarios that now hold a redrawing figure

**File**: `.codeyam/scenarios/dragoncurve-default.json`

**File**: `.codeyam/scenarios/exploratoryband-default.json`

**File**: `.codeyam/scenarios/exploratoryband-without-quote.json`

**File**: `.codeyam/scenarios/prosecolumns-with-foot.json`

Add `?tree=static` to each `url`. These four render a structure that will now
redraw after load, and an unfrozen capture races the swap. `prosecolumns-with-foot`
is worth calling out: it already renders a `BranchingTree` through `ProseColumns`
and already lacked the flag, so this closes a pre-existing gap on the same
surface rather than only the one this change opens.

Every committed screenshot containing the band changes, because the build-time
figure is now sampled from the envelope rather than fixed at
`dragonPoints(12, { step: 7, fraction: 0.85 })`: `about-full-design`,
`about-footer-contact-link-followed`, `contact-email-only`,
`page-created-from-the-cms`, `page-minimal-fields`, `prosecolumns-single-section`,
the two `exploratoryband-*` scenarios, `prosecolumns-with-foot` and
`dragoncurve-default`. Recapture them; the change is expected, not drift.

## Reused existing code

- `turtle`, `lsystem` and `dragonPoints` from `src/lib/structures.ts` (glossary
  entries: `dragonPoints`) — the walker the fold word is emitted into, and the
  reference specimen the generalisation is tested against.
- `toPath`, `pointBounds`, `outOfBand`, `seededRandom`, `hashSeed`,
  `randomTreeSeed` from `src/lib/structures.ts` (glossary entries: `outOfBand`,
  `randomTreeSeed`, `hashSeed`) — the shared vocabulary of every structure's
  seeding and acceptance scoring.
- `applyFigure` from `src/lib/figure-dom.ts` (glossary entry: `applyFigure`) — the
  per-visit rewrite. This is a one-path figure, the case the function's own surplus-and-shortfall handling already covers, so nothing there changes.
- `growAcceptableTree` / `treeShortfall` / `TREE_ENVELOPE` in
  `src/lib/structures.ts` (glossary entries: `growAcceptableTree`,
  `treeShortfall`, `treeVariant`) — the shape the new dragon module copies:
  envelope object, variant sampler, shortfall score, resample-with-derived-seed
  loop, closest-attempt fallback.
- `measureCoverage` from `src/lib/harmonograph.ts` (glossary entry:
  `measureCoverage`) — the precedent for a MEASURED acceptance term rather than an
  outline-based one, which is what the coverage and retrace terms are.
- `growAcceptableVoronoi` / `voronoiViewBox` in `src/lib/voronoi.ts` (glossary
  entries: `growAcceptableVoronoi`, `voronoiViewBox`) and the `<script>` block of
  `src/components/structures/VoronoiField.astro` — the closest existing template
  for the component-side change.

**Existing-implementation survey.** Nothing equivalent exists today: grepping
`src/` for `dragonPoints` finds exactly two call sites (the component and its
test), `src/components/structures/DragonCurve.astro` has no `<script>` block, no seed prop and no
`data-` hook, and the only per-visit redraw machinery in the tree is the three
components listed in `src/lib/figure-dom.ts`'s header — the dragon is not among
them. `?tree=static` already exists and is read identically by all three, so no
new flag or config field is introduced by this plan.

## Scenarios to Demonstrate

- **The band on a real internal page, frozen** — `/about?tree=static`: the
  build-time curve for the `about` seed, the state a no-JS visitor keeps and the
  state every capture records.
- **A different page, a different curve** — `/contact?tree=static` beside About:
  the per-page axis, visible as two unmistakably different lattice walks in the
  same band.
- **The variations sheet** — eight seeds stacked, showing the family stays one
  species across the envelope.
- **The degenerate control** — a raw fold word that retraces heavily, drawn beside
  a healthy one on the same sheet, so the retrace guard can be seen rejecting
  something rather than trusted.
- **The one-section page** — `/notes?tree=static`: the flanked layout, where the
  band's curve now varies alongside the harmonograph and the Voronoi field, and
  the three must read as three different figures rather than one repeated idea.
- **The band with no quote** — `/isolated-components/ExploratoryBandNoQuote?tree=static`:
  the pull-up is switched off, so this is where a curve that changed the well's
  height would show as a gap.