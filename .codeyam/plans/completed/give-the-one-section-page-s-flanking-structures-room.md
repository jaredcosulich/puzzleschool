---
title: "Give the One-Section Page's Flanking Structures Room"
mode: ui
createdAt: "2026-08-17T23:43:23Z"
source: manual
---

## Summary

The one-section internal page shipped in `ce4da69f` reads badly: the harmonograph
in the left lane sits noticeably lower than the Voronoi field opposite it, and
the prose between them runs so wide that both figures are squeezed against the
page edges with no air around them. The low harmonograph is not a taste call, it
is arithmetic — the flank lane is `123 × 365` (aspect `0.337`) while
`ASPECT_BAND` in `src/lib/harmonograph.ts` only accepts figures between `0.42`
and `0.62`, so under `preserveAspectRatio="xMidYMax meet"` the figure is always
scaled to fit the lane's WIDTH and can only ever claim `123 / 0.62 ≈ 198px` to
`123 / 0.42 ≈ 293px` of the lane's 365px height. `YMax` then dumps every pixel of
that shortfall at the TOP, which is exactly the 70–170px of dead space above the
figure that reads as "too low". The fix is to make the lane fit the figure rather
than the other way round: widen both flank lanes to `200 × 365`, cap the accepted
aspect at the lane's own ratio so `meet` binds on HEIGHT for every draw, and pay
for the wider lanes by narrowing the single-column measure from 760px to 600px —
which is the same change the "text column is too wide" complaint asks for.

## Key Decisions

- **Widen the lane instead of flattening the figure.** `harmonograph.ts` already
  argues, in the `ASPECT_BAND` comment, that chasing the lane's 0.34 aspect
  "buys the last third of the height at the cost of the figure". That reasoning
  stands — so the lane moves, not the figure. At `200 × 365` the lane's aspect is
  `0.548`, which sits inside the band the figure already draws at.
- **Cap `ASPECT_BAND.max` at the lane's aspect (`0.62 → 0.548`).** Under `meet`,
  a figure fills its lane's full height exactly when its aspect is at or below
  the lane's. With the cap, every accepted draw is height-bound, the vertical
  dead space is gone by construction, and the residual letterboxing moves to the
  HORIZONTAL — where `xMid` centres it and nobody can see it. This is the change
  that actually fixes "too low"; the widened lane alone would only shrink the gap.
- **Keep `YMax`, keep the bottom anchor.** Both are the seam guarantee, and the
  fix must not cost it. With the cap in place there is no vertical slack left for
  `YMax` to place anyway, so it becomes belt-and-braces rather than the thing
  producing the fault.
- **New `--measure-prose-single` token rather than editing `--measure-body`.**
  `--measure-body: 760px` is the site-wide body measure; the single prose column
  is the only place that wants 600px, and narrowing the shared token would pull
  the page header's intro and everything else in with it.
- **The two-column shape is untouched.** About renders correctly today — the
  branching tree's 123px lane, the 203px column gap and `preserveAspectRatio="none"`
  all stay exactly as they are. This plan only moves geometry that the
  `single` layout owns.
- **Raise the single shape's collapse breakpoint to 960px.** Two 200px lanes plus
  two 64px gutters cost 528px of the 1200px content box. Below roughly 960px
  viewport the 600px measure would be squeezed under 400px, which is worse than
  no lanes at all — so below that width the flanked shape collapses to the plain
  block flow it already falls back to at 840px.

## Implementation

### 1. Publish the flank lane as one shared geometry fact

**File**: `src/lib/structures.ts`

Export `FLANK_LANE = { width: 200, height: 365 }` alongside the existing shared
geometry helpers, with a comment saying what it is: the lane the one-section
page's two flanking structures stand in, distinct from the branching tree's
123px lane in the two-column shape. Both flank components and the Voronoi
envelope read it, so the number exists once in TypeScript. The CSS side
(`ProseColumns.astro`) restates it as a literal with a comment pointing here —
the same convention the file already uses for `123px` / `365px`.

### 2. Cap the accepted harmonograph aspect at the lane's aspect

**File**: `src/lib/harmonograph.ts`

Change `ASPECT_BAND` from `{ min: 0.42, max: 0.62 }` to
`{ min: 0.42, max: 0.548 }` (`FLANK_LANE.width / FLANK_LANE.height`), and rewrite
the comment above it to say why the ceiling is that number and not a taste
judgement: at or below the lane's aspect, `meet` scales the figure by HEIGHT, so
the figure fills the lane top to bottom and the letterboxing that is left is
horizontal. Update the `123×365` references in the surrounding comments
(lines ~147, ~210, ~269, ~377) to the new lane.

The band is now `0.13` wide where it was `0.20`, so the raw accept rate drops.
`growAcceptableHarmonograph` already falls back to the closest attempt rather
than throwing, so nothing breaks — but at execution, check the fallback rate the
way the existing 60-attempt number was checked and raise `attempts` to 80 if
draws start landing off-band.

### 3. Draw the Voronoi field at the new lane

**File**: `src/lib/voronoi.ts`

`VORONOI_ENVELOPE.fixed.width` goes `123 → 200` (from `FLANK_LANE`). Because the
field renders with `preserveAspectRatio="none"`, the generated frame IS the lane
— keeping 123 here would stretch every cell horizontally by 1.6×. The
`columns` range moves from `{ min: 2, max: 3 }` to `{ min: 3, max: 4 }` so cells
stay roughly square against the unchanged `rows: { min: 5, max: 7 }` at the new
`0.548` aspect, and the "deliberately tall and narrow" comment above the envelope
is updated with the new numbers.

### 4. Default both flank components to the new lane

**File**: `src/components/structures/Harmonograph.astro`

Default `width` from `123` to `FLANK_LANE.width` (import it), leaving `height` at
`FLANK_LANE.height`. Update the `.harmonograph-well` comment and its `min-height`
to match, and move the `@media (max-width: 840px)` collapse to `960px`.

**File**: `src/components/structures/VoronoiField.astro`

The same three changes: default width from the shared constant, updated
`.voronoi-well` comment, collapse breakpoint `840px → 960px`.

### 5. Rebalance the one-section grid

**File**: `src/components/page/ProseColumns.astro`

In `.prose-grid--single`:

- `grid-template-columns: 123px minmax(0, var(--measure-body)) 123px` becomes
  `200px minmax(0, var(--measure-prose-single)) 200px`.
- `column-gap: 40px` becomes `64px` — the extra air between the text and each
  figure is half of what "space to breathe" is asking for.
- Add a comment recording the arithmetic, so the next reader does not have to
  re-derive it: `200 + 64 + 600 + 64 + 200 = 1128` inside the 1200px content box
  (`--page-width: 1280px` less two 40px gutters), leaving 36px of slack each side.
- Add a `@media (max-width: 960px)` rule setting `.prose-grid--single { display: block }`,
  matching the components' new collapse width. The existing `840px` block stays
  as-is; it governs the two-column shape.

Leave the `columns` shape, the `.tree-well` rule, the `min-height` floor and the
`prose-foot` bleed untouched.

### 6. Add the single-column measure token

**File**: `src/styles/tokens.css`

Add `--measure-prose-single: 600px;` next to the existing measures, commented as
the measure of the one-section page's centred prose column — narrower than
`--measure-body` because the two flanking structures need the width more than the
text does.

### 7. Show the components at their real lane in isolation

**File**: `src/pages/isolated-components/Harmonograph.astro`

**File**: `src/pages/isolated-components/VoronoiField.astro`

**File**: `src/pages/isolated-components/HarmonographVariations.astro`

**File**: `src/pages/isolated-components/VoronoiFieldVariations.astro`

Each of these hardcodes `width: 123px` (and says so in a comment) precisely so the
capture judges the envelope at the real lane. All four move to `200px` with their
comments updated. `BranchingTreeVariations.astro` keeps `123px` — that is the
tree's lane and it has not changed.

### 8. Update the tests that pin the old geometry

**File**: `src/lib/voronoi.test.ts`

`FRAME` at line 19 and the `'0 0 123 365'` viewBox expectation at line 299 both
encode the old lane and will fail; move them to `200`.

**File**: `src/lib/harmonograph.test.ts`

Add the reproduction test below, and update any existing expectation that
encodes the `0.62` ceiling.

## Reused existing code

- The new lane constant (new) sits beside `hashSeed`, `pointBounds`, `outOfBand`
  and `toPath` in `src/lib/structures.ts` (glossary entries: `hashSeed`,
  `pointBounds`) — the module both flank components already import from.
- `growAcceptableHarmonograph` and `harmonographShortfall` from
  `src/lib/harmonograph.ts` (glossary entries: `growAcceptableHarmonograph`,
  `harmonographShortfall`) — the fallback-to-closest-attempt behaviour is what
  makes tightening `ASPECT_BAND` safe, so no new resilience is written.
- `voronoiVariant`, `growAcceptableVoronoi` and `voronoiViewBox` from
  `src/lib/voronoi.ts` (glossary entries: `voronoiVariant`,
  `growAcceptableVoronoi`, `voronoiViewBox`) — all three read the frame from
  `VORONOI_ENVELOPE`, so changing the envelope is the whole of the Voronoi change.
- `Harmonograph` and `VoronoiField` from `src/components/structures/` (glossary
  entries: `Harmonograph`, `VoronoiField`) — both already take `width`/`height`
  props, so no new prop surface is needed.
- `ProseColumns` from `src/components/page/ProseColumns.astro` (glossary entry:
  `ProseColumns`) — the `layout: 'columns' | 'single'` prop and the
  `proseLayoutFor` rule that drives it are unchanged; this plan only edits the
  CSS of the shape that already exists.

**Existing-implementation survey.** Before proposing `--measure-prose-single` and
`FLANK_LANE`, both were grepped for. `src/styles/tokens.css` has
`--measure-statement: 900px`, `--measure-body: 760px` and `--measure-quote: 780px`
— there is no existing single-column prose measure, and `--measure-body` is used
elsewhere so it cannot be repurposed. There is no shared lane constant anywhere:
`123` is currently a literal in eleven places across the component, library and
test files (`grep -rn "123" src`), of which the six listed above belong to the
flank lane and the rest belong to the branching tree.

## Reproduction Test

Pins the arithmetic behind "the structure on the left is too low": with the
current `ASPECT_BAND` ceiling, accepted harmonographs are wider than their own
lane, so `meet` scales them by width and they cannot reach the top of it.

**Target**: `src/lib/harmonograph.test.ts` — run with
`codeyam-editor editor refresh-tests --test harmonograph`.

```ts
// A figure only fills its lane's full height under `meet` when its aspect is at
// or below the lane's. Every accepted draw must clear that bar, or the lane
// letterboxes vertically and `YMax` banks the whole shortfall above the figure.
it("accepts only harmonographs that fill the flank lane's full height", () => {
  // Must match FLANK_LANE in src/lib/structures.ts once that constant exists.
  const LANE = { width: 200, height: 365 };
  const laneAspect = LANE.width / LANE.height;

  for (let seed = 1; seed <= 60; seed += 1) {
    const box = pointBounds(growAcceptableHarmonograph(seed).points);
    const scale = Math.min(LANE.width / box.width, LANE.height / box.height);
    expect(box.height * scale).toBeCloseTo(LANE.height, 0);
    expect(box.width / box.height).toBeLessThanOrEqual(laneAspect);
  }
});
```

Status: PROPOSED — confirm red at execution. Expected failure: `ASPECT_BAND.max`
is `0.62` today, so seeds drawing above `0.548` are accepted and the
`toBeLessThanOrEqual(0.5479…)` assertion fails (with the `toBeCloseTo` height
assertion failing on the same seeds, reporting a height well short of 365).

## Scenarios to Demonstrate

- **Contact as it ships** — the real one-section page, harmonograph and Voronoi
  field both filling their lanes to the same height, 600px of prose between them.
  (`contact-email-only` recapture.)
- **The isolated one-section shape with a foot** — `ProseColumnsSingle`, where
  the seam guarantee is observable: both figures still land on the join with the
  band even though the CTA sits in the `foot` slot.
- **A blank page** — no sections at all, so the two structures stand at full
  height with nothing between them and the new measure has no copy to size it.
- **Harmonograph variations sheet** — eight draws at the 200px lane, all reaching
  the top of the lane, which is the sheet that proves the tightened band did not
  cost the figures their character.
- **Voronoi variations sheet** — eight fields at the 200px lane with 3–4 columns,
  confirming cells read as roughly square rather than stretched.
- **Narrow viewport (≤960px)** — the flanked shape collapsed to plain block flow,
  no empty lanes, prose at full width.
- **About, unchanged** — the two-column page, as the control that this plan did
  not move the branching tree's geometry.