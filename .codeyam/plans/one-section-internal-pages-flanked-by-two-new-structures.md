---
title: "One-Section Internal Pages Flanked by Two New Structures"
mode: ui
createdAt: "2026-08-17T18:27:20Z"
source: manual
---

## Summary

An internal page currently has exactly one prose shape: two columns with the
binary tree standing in the gap between them. That is right for About, which has
two sections — but Contact only wants to say one thing, and a one-section page
written into that layout leaves a half-empty second column with the tree
awkwardly beside it. Give the internal-page template a second prose shape: ONE
centred section with a different generated structure standing in a lane to its
left and another to its right. The shape is chosen automatically from the number
of `###` sections the body actually has, so a page a CMS editor writes next year
gets the right layout by writing, with no new field and no code change.

The two new structures are a **harmonograph** — the trace of two coupled
pendulums, the figure a Victorian drawing machine makes and the same maths that
makes two tones a musical interval — and a **Voronoi tessellation** — the
partition of space by nearest neighbour, which is how soap froth, crystal
grains, a giraffe's coat and a forest canopy actually divide territory. Both are
generated from their rules like every other structure on this site, both vary per
page and per visit like the tree, and both are deliberately left UNFINISHED: the
harmonograph's pen stops mid-swing before the pendulums settle, and the Voronoi
field has one cell missing an edge plus a site or two dropped in with no cell
worked out around them yet. They should read as something somebody is still
puzzling out, not as a finished diagram.

## Key Decisions

- **The layout is derived from the body, not declared in frontmatter.**
  `render(page)` already returns `headings`; counting `depth === 3` entries gives
  the section count for free. One section (or none) → the flanked single column;
  two or more → today's two columns with the tree. Adding a `proseLayout` field
  would put the decision in a place the writer has to remember, and the whole
  point of this template is that a page created from /admin gets the site's
  design without anyone touching code.

- **A body with no sections at all counts as one.** `/blank`
  (`page-title-without-body`) has an empty body and today renders the tree alone
  under the sine rule, which reads fine. Under the new rule it gets the two
  flanking lanes with nothing between them — a page still being written, framed
  by two structures still being worked out. No special case, and the honest
  reading of an empty page.

- **Two structures that contrast with each other and with the tree.** The tree is
  branching and vertical. A harmonograph is one continuous stroke that loops back
  on itself; a Voronoi field is a crystalline partition of straight edges.
  Nothing on the page repeats a gesture, and each is a legitimate structure that
  describes something real: coupled harmonic motion on the left, nearest-neighbour
  space division on the right.

- **Incompleteness is a parameter, exactly as `src/lib/structures.ts` already
  argues for `fraction` / `openLast` / `bareLimb`.** The harmonograph gets
  `fraction` (the pen lifts before the swing decays, so the figure's envelope
  never closes) and the Voronoi field gets `openCell` (one cell drawn with one
  edge missing) plus `unresolvedSites` (sites placed but excluded from the
  tessellation, so their neighbours' cells have visibly not accounted for them).
  The unresolved sites are the strongest carrier of "still being puzzled out" —
  a partition that does not yet know about some of its own points.

- **The result is accepted or resampled, not just sampled.** Both structures
  follow `growAcceptableTree`'s shape: bounded ranges in, a shortfall score on
  the geometry that came out, resample from a derived seed, fall back to the
  closest attempt rather than throwing. A harmonograph can collapse to a straight
  line at a 1:1 ratio in phase, and a Voronoi can produce slivers — both are
  inside the input ranges and both look broken, so the check has to be on the
  output.

- **Reuse the existing `?tree=static` freeze rather than inventing a second
  flag.** Every committed scenario URL already carries it, and the flag's real
  meaning is "do not regrow generated figures after load". Both new components
  read the same parameter, so captures stay deterministic with no scenario
  rewrites.

- **Generalise `applyTreeGrowth` instead of copying it.** The regrow logic
  (reuse existing `<path>` elements, clone the first as a template for extras,
  remove surplus, reframe the viewBox) is the fiddly part and is already tested.
  Extract the general form, keep `applyTreeGrowth` as a delegating wrapper so its
  seven registered tests stay green unchanged.

- **Do not rename `randomTreeSeed`.** It is a generic 32-bit seed source and the
  new structures use it as-is; renaming it would churn a registered test key for
  no behavioural gain.

## Implementation

### 1. Choose the prose shape from the body's section count

**File**: `src/pages/[...slug].astro`

`render(page)` currently destructures only `Content`. Take `headings` too, count
the `depth === 3` entries, and pass the result to `ProseColumns` as an explicit
layout choice (e.g. `layout={sectionCount >= 2 ? 'columns' : 'single'}`) rather
than passing the raw count — the component should not have to know the rule.

Everything else about the route is unchanged: `MorseRule`, `PageHeader`,
`SineRule`, the `foot` slot for `ContactButton`, and the conditional
`ExploratoryBand` all stay exactly as they are.

### 2. Give ProseColumns a flanked single-section shape

**File**: `src/components/page/ProseColumns.astro`

Add a `layout?: 'columns' | 'single'` prop, defaulting to `'columns'` so every
existing caller (including `src/pages/isolated-components/ProseColumns.astro`)
renders identically to today.

- `'columns'` — unchanged: `.prose { columns: 2; column-gap: 203px }` with
  `<BranchingTree>` in the gap.
- `'single'` — one column of prose held to a readable measure and centred, with a
  123px lane on each side separated from the text by the same 40px gutter the
  two-column gap uses, so the three lanes land on the design's rhythm. Render
  `<Harmonograph>` in the left lane and `<VoronoiField>` in the right.

Position the flanking lanes the way `.tree-well` is positioned today —
absolutely, `bottom: 0`, so both figures sit on the seam with whatever section
follows, which is the guarantee the completed
`keep-the-branching-structure-on-the-seam-with-the-band` plan established and
this must not break. Do the positioning HERE (a wrapper div per lane) rather than
inside the structure components, so each component only owns its own geometry.

Keep the existing `min-height: calc(365px + 24px)` floor — it applies unchanged
to the flanked shape, and it is what keeps the figures from rising through the
sine rule on a short page. Keep the `.prose-foot` slot bleed exactly as is: the
Contact button renders through it and must still line up with the prose's left
edge.

Below the existing 840px breakpoint the flanking lanes collapse (`display: none`)
and the floor drops to 0, matching what `.tree-well` already does.

Leave the `cmsBody()` marker on `.prose` and nothing else. Note the known limit
worth stating in a comment: staged CMS preview patches `.prose`'s innerHTML, so
editing a body from two sections down to one does not re-pick the layout until
the next build. That is acceptable — the layout is a build-time fact — but it
should be written down rather than discovered.

### 3. Generate the harmonograph

**New file**: `src/lib/harmonograph.ts`

Pure geometry, in the style of `src/lib/structures.ts` (numbers in, path strings
out, no DOM).

The figure is the classic four-pendulum harmonograph:

```
x(t) = A1·sin(f1·t + p1)·e^(−d1·t) + A2·sin(f2·t + p2)·e^(−d2·t)
y(t) = A3·sin(f3·t + p3)·e^(−d3·t) + A4·sin(f4·t + p4)·e^(−d4·t)
```

sampled at a fixed step over `t`. Export:

- `harmonographPoints(options)` — the sampled trace.
- `HARMONOGRAPH_ENVELOPE` — the variation bounds, as one readable object next to
  `TREE_ENVELOPE`'s precedent. Frequency ratios drawn from a small set of
  small-integer intervals (1:2, 2:3, 3:4, 3:5), each with a small DETUNE — the
  detune is the whole character of the figure, since exact ratios close into a
  static Lissajous while a detuned pair precesses into a drifting rosette.
  Phases, per-pendulum damping and amplitude balance also sampled; the lane's
  width/height stay fixed, as with the tree.
- `harmonographVariant(seed)` — one seed to one bounded option set, drawn in a
  fixed order so a seed is reproducible.
- `growAcceptableHarmonograph(seed, attempts = 20)` — resample against a
  shortfall score, fall back to the closest attempt.

The unfinishedness: `fraction` (0–1) cuts the trace short of the point where
damping brings the pen to rest, so the stroke stops mid-swing. Score the result
so the cut is VISIBLE — the gap between the first and last sampled point must be
a meaningful fraction of the bounding-box diagonal, otherwise the trace happens
to stop where it started and reads as closed.

Shortfall terms, each normalised the way `treeShortfall` normalises its own:
aspect ratio inside a band that suits a tall lane; turning-point count inside a
band (too few is a lazy oval, too many silts into a ball of thread); a
degeneracy guard so a near-1:1 in-phase draw that collapses to a line is
rejected; and the open-end term above.

**New file**: `src/lib/harmonograph.test.ts`

Cover the properties, not the pixels: a detuned ratio does not retrace its own
path; `fraction` below 1 leaves the ends apart; the same seed gives the same
trace and a different seed gives a different one; a hand-built degenerate option
set scores worse than a good one; `growAcceptableHarmonograph` returns an
acceptable figure for a spread of seeds, and returns SOMETHING (not a throw)
when none qualifies.

### 4. Generate the Voronoi field

**New file**: `src/lib/voronoi.ts`

- `jitteredSites(seed, bounds, count)` — stratified sampling (a jittered grid)
  rather than uniform random points, so cells stay evenly sized instead of
  producing slivers that read as a mistake.
- `voronoiCells(sites, bounds)` — each cell is the bounds rectangle clipped
  successively by the half-plane of the perpendicular bisector against every
  other site (Sutherland–Hodgman). O(n²) at n ≈ 12–20 is nothing, and it keeps
  the module free of a triangulation dependency.
- `VORONOI_ENVELOPE`, `voronoiVariant(seed)`, `growAcceptableVoronoi(seed)` —
  same three-part shape as the tree and the harmonograph.

The unfinishedness, and this is the part to get right:

- `openCell` — one cell's outline is drawn with one edge omitted, the same idea
  as `openRectPath`'s three-sided square: a boundary somebody has not closed yet.
- `unresolvedSites` — one or two sites are drawn as bare dots and EXCLUDED from
  the tessellation entirely, so the surrounding cells visibly have not accounted
  for them. A partition that does not yet know about some of its own points is
  the clearest way to say "still being worked out".
- The lane's own frame is not stroked, so cells run off the top and bottom edges
  unresolved rather than being tidied into a box.

Return whether `openCell` and the unresolved sites actually landed — the same
`bareLimbApplied` lesson: a missing deliberate feature is invisible in a
geometry list, so acceptance has to be told about it. Score cell count against a
band and reject slivers (any cell far below the mean area).

**New file**: `src/lib/voronoi.test.ts`

Every point inside a cell is nearer that cell's site than any other (the
defining property — check by sampling cell centroids); cells cover the bounds
without overlapping beyond edge sharing; an unresolved site has no cell; the
open cell is short exactly one edge; the same seed reproduces the same field;
`growAcceptableVoronoi` rejects a slivered field.

### 5. Generalise the per-visit regrow

**New file**: `src/lib/figure-dom.ts`

Lift the general form out of `applyTreeGrowth`: given an `SVGSVGElement`, a
viewBox and a list of `{ d, width? }` paths, reuse the existing `<path>`
elements, clone the first as a template for extras, drop the surplus, and reframe
the viewBox — returning false and leaving the element untouched when there is no
template path to clone. The reason it lives outside the component's `<script>` is
unchanged and worth restating: logic inside an Astro script tag is unreachable
from vitest, and this is the part most likely to break quietly.

**File**: `src/lib/tree-dom.ts`

Rewrite `applyTreeGrowth` as a thin wrapper that maps segments to `{ d, width }`
and delegates. Its signature and behaviour do not change, so all seven registered
`applyTreeGrowth` tests stay green untouched — that is the check that the
extraction was faithful.

**New file**: `src/lib/figure-dom.test.ts`

The generic cases that are no longer specific to trees: reuse, grow, shrink, no
template, empty input.

### 6. The two structure components

**New file**: `src/components/structures/Harmonograph.astro`

**New file**: `src/components/structures/VoronoiField.astro`

Follow `src/components/structures/BranchingTree.astro` closely — it is the
existing worked example of a structure that varies on two axes:

- Props: `seedKey` (hashed for the per-page seed), an explicit `seed` override
  for a variations sheet, and `width` / `height` for the lane (123 × 365, the
  same lane the tree fills) — layout facts, not variation axes.
- Server render is VALID ON ITS OWN — it is what no-JS visitors keep and what
  every capture records; the client regrow is an enhancement.
- Client `<script>`: skip entirely when `?tree=static` is present; otherwise
  regrow from `randomTreeSeed()` and write through `applyFigure` inside a single
  `requestAnimationFrame`, wrapped in try/catch that silently keeps the server
  figure on failure.
- Stroke in `var(--gold)` with `vector-effect="non-scaling-stroke"`, and
  `aria-hidden="true"` / `focusable="false"` — these are decorative.
- Salt the seed per lane (e.g. `hashSeed(`${seedKey}:harmonograph`)` and
  `:voronoi`) so the left and right figures are not two draws of the same number.

Match `BranchingTree`'s `preserveAspectRatio` decision deliberately rather than
copying it blindly: the tree uses `none` to fill its lane exactly. A harmonograph
distorts visibly under an anisotropic stretch, so frame it to the lane instead
(`meet`, with the envelope's aspect band doing the fitting) and say so in the
comment.

### 7. Make Contact a one-section page

**File**: `src/content/pages/contact.md`

Fold today's two sections ("Who we want to hear from" / "What happens next") into
one. Keep the reader-facing heading and let the closing paragraphs carry what
happens next — the copy is short enough that the second heading was structure for
its own sake. The frontmatter is unchanged, including `showContactButton: true`,
so the EMAIL US button still renders through the `foot` slot.

**File**: `.codeyam/scenarios/contact-email-only.json`

Update the `contact` entry's seeded `body` to match the new one-section shape, so
the application scenario demonstrates the flanked layout rather than the old two.
Change ONLY that field.

Note the overlap with the queued plan `restore-coherent-world-scenario-seeds`,
which also edits this file — it restores the seed's `pages` array membership,
while this edits one entry's `body`. They do not conflict logically, but whichever
lands second should re-read the file rather than assume its prior shape.

**File**: `.codeyam/scenarios/about-full-design.json`

Its seed carries a `contact` entry with the old two-section body. Update it for
consistency, even though `/about` is the captured route.

### 8. Isolation pages, scenarios and recaptures

**New file**: `src/pages/isolated-components/Harmonograph.astro`

**New file**: `src/pages/isolated-components/VoronoiField.astro`

**New file**: `src/pages/isolated-components/ProseColumnsSingle.astro`

Follow the existing isolation-page pattern exactly (see
`src/pages/isolated-components/BranchingTree.astro` and
`src/pages/isolated-components/ProseColumns.astro`): body-level flex centring,
the `#codeyam-capture` wrapper, real seeded content, and the registration command
in a comment. Consider variations sheets for the two new structures alongside
`src/pages/isolated-components/BranchingTreeVariations.astro`, which is how the
tree's envelope was actually calibrated — several pinned seeds side by side is
the only practical way to judge whether an acceptance band is right.

Register the new component scenarios with `codeyam-editor editor register`, all
with `?tree=static` in the URL so captures are deterministic.

Existing application screenshots that WILL change, and each should be looked at
rather than blind-recaptured: `contact-email-only` (the point of the change),
`page-minimal-fields` (`/notes` has exactly one section, so it moves to the
flanked layout), and `page-title-without-body` (`/blank`, empty body, now two
lanes with nothing between them). `about-full-design`,
`page-created-from-the-cms` and every `prosecolumns-*` component scenario keep
the two-column shape and should come back UNCHANGED — if any of them moves, the
default was not preserved.

## Reused existing code

- `hashSeed`, `seededRandom`, `randomTreeSeed`, `toPath` and the `Point` type
  from `src/lib/structures.ts` (glossary entries: `hashSeed`, `randomTreeSeed`,
  `toPath`), covered by `src/lib/structures.test.ts` — the new generators build
  on these rather than restating a PRNG or a path serialiser.
- `growAcceptableTree` / `isAcceptableTree` / `outOfBand` from
  `src/lib/structures.ts` (glossary entries: `growAcceptableTree`,
  `isAcceptableTree`, `outOfBand`) — the envelope + shortfall + resample pattern
  the two new structures follow; `outOfBand` is reused directly for the band
  terms.
- `applyTreeGrowth` from `src/lib/tree-dom.ts` (glossary entry:
  `applyTreeGrowth`), covered by `src/lib/tree-dom.test.ts` — generalised into
  the new figure-dom module rather than duplicated, with the wrapper keeping its
  tests as the fidelity check.
- `src/components/structures/BranchingTree.astro` (glossary entry: nearest is the
  `growAcceptableTree` entry it renders) — the worked example for a two-axis
  varying structure, including the `?tree=static` freeze and the
  server-render-must-stand-alone rule.
- `openRectPath` from `src/lib/structures.ts` (glossary entry: `openRectPath`) —
  the existing precedent for drawing a shape deliberately short of one edge; the
  Voronoi open cell follows it rather than inventing a new idiom.
- `cmsBody` from `src/lib/cmsMarkers.ts` (glossary entry: `cmsBody`) — stays on
  `.prose` in both layouts, unchanged.
- `ContactButton` from `src/components/page/ContactButton.astro` (glossary entry:
  `ContactButton` isolation scenario `contactbutton-default`) — rendered through
  the existing `foot` slot in both layouts, no change.

**Existing-implementation survey.** Nothing in the repo already selects a page
layout: `src/pages/[...slug].astro` renders one fixed shape, `src/content/config.ts`
has no layout-ish field (`showContactButton` is the only behavioural flag), and
`ProseColumns` has no variant prop today. No existing structure generator draws
a closed-curve figure or a space partition — the five that exist are a sine
field, a Fibonacci square tiling, two L-systems (Koch, dragon) and the branching
tree. So both new generators are genuinely new, and the layout choice has no
prior implementation to extend.

## Scenarios to Demonstrate

- **Contact, one section, flanked.** `/contact` with the harmonograph at the left
  and the Voronoi field at the right, both sitting on the seam with the dark
  band, the EMAIL US button still in place.
- **About, unchanged.** `/about` keeps two columns with the tree between them —
  proof the default shape was preserved rather than replaced.
- **A minimal CMS page.** `/notes` (`page-minimal-fields`) has one section and
  moves to the flanked layout with no code or content change — the "a page
  written next year gets this for free" demonstration.
- **An empty page.** `/blank` (`page-title-without-body`): two structures with
  nothing yet between them.
- **A two-section CMS page.** `/a-day-in-the-life` (`page-created-from-the-cms`)
  keeps the tree, showing the rule keys off the writing rather than the route.
- **Harmonograph in isolation**, plus a variations sheet of pinned seeds spanning
  the envelope — including the near-degenerate draws the acceptance check is
  supposed to reject.
- **Voronoi field in isolation**, plus a variations sheet — showing the open cell
  and the unresolved sites clearly enough to judge whether they read as
  "unfinished" or merely as "wrong".
- **Narrow viewport.** Below 840px both lanes collapse and the prose runs as a
  single column with no reserved gap.
- **Per visit.** Loading `/contact` twice without `?tree=static` draws two
  different harmonographs and two different Voronoi fields; with the flag, the
  build-time figures stand unchanged — which is what keeps captures stable.