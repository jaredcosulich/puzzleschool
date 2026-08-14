---
title: "Vary the Branching Tree Per Page and Per Visit"
mode: ui
createdAt: "2026-08-14T19:05:47Z"
source: manual
---

## Summary

Today every internal page draws the identical branching tree: `ProseColumns` renders
`<BranchingTree />` with no props, so `treeSegments` runs at the component's fixed
defaults with `seed = 11` on About, on Contact, and on every page a CMS editor will
ever create. The structure is supposed to read as something grown, and a single frozen
specimen repeated down the site undercuts that. Make it vary on two axes at once —
**per page** (a seed derived from the page slug, rendered at build time) and **per
visit** (a client-side regrow on load with a fresh random seed) — with the variation
held inside a declared envelope so every tree is still recognisably the same species.
The envelope is enforced twice: parameters are *sampled* from bounded ranges, and the
resulting tree is *checked* against acceptance rules (segment count, canopy fill,
balance, a bare limb that actually landed) with a bounded resample when it fails.
Because the site is prerendered and codeyam captures screenshots of it, a
`?tree=static` escape hatch suppresses the client regrow so scenario captures stay
byte-stable.

## Key Decisions

- **Two seeds, two moments.** The build-time seed comes from the page slug via a small
  string hash, so About, Contact and a page created next year in `/admin` each grow
  their own tree with no code change — and the same tree on every build, which is what
  keeps the committed screenshots from churning. The visit-time seed is
  `Math.random()`, applied in the browser after load. Server tree and client tree
  genuinely differ; that is the point of picking "both".
- **The envelope is a function, not a comment.** `treeVariant(seed)` maps an arbitrary
  seed onto a bounded parameter set (depth 4–5, spread 28–40°, shrink 0.58–0.68,
  branchChance 0.42–0.58, plus stopChance, jitter and `bareLimb`). Free-form
  randomisation of `TreeOptions` would eventually produce a bald stick or a bush; a
  sampling function makes "within some constraints" a testable object rather than a
  hope.
- **Sampling is not sufficient — also check the result.** Even inside the ranges, a
  particular seed can grow something degenerate (all branches stopped early, everything
  combed to one side, the named bare limb never reached because that seed grew fewer
  branches than its index). `isAcceptableTree` scores the grown geometry and
  `growAcceptableTree` resamples with a derived seed, up to a bounded number of
  attempts, then falls back to the best attempt so the component can never fail to
  render.
- **`treeSegments` keeps its current signature.** Acceptance needs to know how many
  branches were grown and whether `bareLimb` actually landed, which is not recoverable
  from the segment list. Rather than change the return type (five existing tests and
  the component depend on it), add `growTree` returning `{ segments, branches,
  bareLimbApplied }` and reduce `treeSegments` to `growTree(...).segments`.
- **`?tree=static` disables the client regrow, presence-only.** The pages are
  prerendered, so a query parameter cannot influence the server render at all — it can
  only be a signal to the browser script. A *value*-carrying seed param would make the
  client draw a different tree than the server did, reintroducing a swap (and a race)
  during capture. A presence flag that says "leave the SSR tree alone" removes the race
  entirely, which is exactly what a screenshot needs.
- **Tree code stays in `src/lib/structures.ts`.** The client script imports
  `growAcceptableTree` from it; the module is side-effect-free ESM, so Rollup
  tree-shakes the sine/Fibonacci/L-system/morse exports out of the browser bundle. A
  separate `tree.ts` would be marginally more explicit at the cost of moving code and
  churning the dependency graph for no behavioural gain.
- **The swap on load is accepted, not animated.** The regrow rewrites the `d` and
  `stroke-width` attributes in a single `requestAnimationFrame` after module execution.
  The figure is an 80%-opacity hairline structure in a side lane, so the change should
  read as ambient rather than as a flash. If it reads badly in the preview, the fallback
  is a short opacity cross-fade on `.tree-flip` — noted here so it is a decision, not a
  discovery.

## Implementation

### 1. Seed derivation and the variation envelope

**File**: `src/lib/structures.ts`

Add, in the binary-tree section beneath `seededRandom`:

- `hashSeed(text: string): number` — FNV-1a 32-bit over the string, returning an
  unsigned 32-bit integer. This is what turns a page slug into a seed. Stable across
  builds and platforms (no `String.prototype.hashCode`-style host dependency).
- `TREE_ENVELOPE` — an exported constant describing the bounded ranges, so the envelope
  is one readable object rather than magic numbers scattered through a sampler:
  `depth 4–5`, `spread 28–40`, `shrink 0.58–0.68`, `branchChance 0.42–0.58`,
  `stopChance 0.10–0.20`, `jitter 0.35–0.55`, `wander 5–8`, `bareLimb 2–6`.
  `length`, `baseWidth`, `taper`, `segmentsPerLimb` stay fixed — they set the weight and
  scale of the drawing, and varying them changes how the figure sits in the 123×365 lane
  rather than how it grew.
- `treeVariant(seed: number): TreeOptions` — draws one value per range from a
  `seededRandom(seed)` sequence, with integer ranges rounded. Pure; same seed, same
  options.

Also add the acceptance layer:

- `TreeGrowth` interface: `{ segments: Segment[]; branches: number; bareLimbApplied: boolean }`.
- `growTree(options: TreeOptions): TreeGrowth` — the current body of `treeSegments`,
  additionally counting branches grown and recording whether the `bareLimb` index was
  actually reached.
- `treeSegments(options)` becomes `growTree(options).segments`, so every existing caller
  and test is untouched.
- `isAcceptableTree(growth: TreeGrowth): boolean` — the envelope enforced on the *result*:
  - segment count within 40–110;
  - `bareLimbApplied` is true (a bare limb the tree never reached is not a bare limb);
  - canopy width ≥ 60% of the bounding box width at the widest, i.e. the tree fills its
    lane rather than growing as a narrow spike;
  - bounding-box aspect ratio (width / height) within 0.4–1.1 — outside this the
    `preserveAspectRatio="none"` stretch into the lane distorts the figure visibly;
  - horizontal balance: the mean x of all segment endpoints sits within the middle third
    of the bounding box, which is what rejects a tree combed onto one side.
- `growAcceptableTree(seed: number, attempts = 8): TreeGrowth` — sample, grow, check;
  on failure derive the next seed (`seed * 2654435761 + attempt`, kept unsigned) and try
  again. After `attempts`, return the attempt with the most segments rather than
  throwing — a slightly off tree beats a blank lane.

### 2. The component: build-time seed, client-time regrow, and the static escape hatch

**File**: `src/components/structures/BranchingTree.astro`

- Replace the long list of individually-defaulted geometry props with a `seedKey?: string`
  and a `seed?: number` prop. `seed` wins when given; otherwise `seed = hashSeed(seedKey ?? 'default')`.
  Keep `width` / `height` props (the lane is a layout fact, not a variation axis). Keep
  an escape hatch for explicit `options` overrides only if the variations page in step 5
  needs it; otherwise drop the geometry props entirely, since nothing else passes them.
- Render from `growAcceptableTree(seed)` instead of `treeSegments({...})`.
- Give the `<svg>` a stable hook (`data-tree`) and each `<path>` nothing special — the
  script rewrites the whole path list.
- Add an Astro `<script>` (bundled, module) that:
  - returns immediately when `new URLSearchParams(location.search).has('tree')` and the
    value is `static`;
  - for each `[data-tree]` on the page, calls `growAcceptableTree(Math.floor(Math.random() * 2 ** 32))`,
    recomputes the viewBox from the new bounds exactly as the frontmatter does, and inside
    one `requestAnimationFrame` rewrites the `viewBox` plus the `<path>` `d` /
    `stroke-width` list (creating or removing paths as the count differs);
  - is wrapped in try/catch so a failure leaves the SSR tree standing rather than an empty
    lane.
- Extend the component's header comment: the two-seed model, why the SSR tree must remain
  valid on its own (no-JS and pre-script paint), and what `?tree=static` is for.

The viewBox computation is currently inline in the frontmatter (lines 85–90) and would be
duplicated in the script. Extract it to `treeViewBox(segments): string` in
`src/lib/structures.ts` and call it from both, so the two renders cannot drift.

### 3. Pass the page identity down

**File**: `src/components/page/ProseColumns.astro`

Accept `seedKey?: string` and forward it to `<BranchingTree seedKey={seedKey} />`. No
style changes — the lane geometry is unchanged.

**File**: `src/pages/[...slug].astro`

Pass the page id: `<ProseColumns seedKey={page.id}>`. This is the whole per-page axis —
About, Contact, `/a-day-in-the-life` and every future CMS page get distinct trees for free.

### 4. Keep the captures deterministic

**Files**: `.codeyam/scenarios/about-full-design.json`,
`.codeyam/scenarios/contact-email-only.json`,
`.codeyam/scenarios/page-created-from-the-cms.json`,
`.codeyam/scenarios/page-minimal-fields.json`,
`.codeyam/scenarios/prosecolumns-default.json`,
`.codeyam/scenarios/branchingtree-default.json`

Append `?tree=static` to each scenario `url` (`/about?tree=static`, `/contact?tree=static`,
`/a-day-in-the-life?tree=static`, `/notes?tree=static`,
`/isolated-components/ProseColumns?tree=static`,
`/isolated-components/BranchingTree?tree=static`). Without this the client regrow fires
during capture and every one of these screenshots changes on every run, which would make
"unchanged" impossible to report and drown the real diffs.

Note for execution: these six screenshots **will** change once, legitimately — the
per-page seeds replace the single `seed = 11` tree. Expect and accept that diff; what must
not happen is a second change on a re-capture.

### 5. A variations sheet, so the envelope is reviewable

**New file**: `src/pages/isolated-components/BranchingTreeVariations.astro`

An isolation page rendering eight `<BranchingTree seed={n} />` in a row for eight fixed
seeds. This is the only surface where the envelope can actually be judged: one tree tells
you nothing about whether the constraints hold, and eight side by side make a degenerate
draw obvious at a glance. Register it as a scenario
(`BranchingTree - Variations`, `/isolated-components/BranchingTreeVariations?tree=static`).

### 6. Tests

**File**: `src/lib/structures.test.ts`

Extend the existing `treeSegments` describe block and add new ones:

- `hashSeed` returns the same number for the same string, and different numbers for
  `'about'` / `'contact'` / `'a-day-in-the-life'`.
- `treeVariant` keeps every sampled parameter inside `TREE_ENVELOPE`, swept across a few
  hundred seeds. This is the constraint claim, and a sweep is the only honest way to make it.
- `treeVariant` is deterministic for a given seed.
- `growAcceptableTree` returns an acceptable tree across a sweep of seeds — the property
  the whole feature rests on.
- `growAcceptableTree` is deterministic for a given seed (per-page trees must be stable
  across builds).
- Different seeds grow different trees.
- `isAcceptableTree` rejects a hand-built degenerate growth (e.g. a single unbranched limb).
- `growTree` reports `bareLimbApplied: false` when `bareLimb` names an index past the
  branches actually grown, and `true` when it lands.
- `treeSegments` still returns exactly `growTree(options).segments` — the compatibility
  guarantee that keeps the five existing tree tests meaningful.

## Reused existing code

- `treeSegments`, `seededRandom`, `Segment`, `TreeOptions`, `Point`, `toPath` from
  `src/lib/structures.ts` — the whole feature is a layer over the existing generator;
  the growth algorithm itself is not being rewritten.
- `BranchingTree` from `src/components/structures/BranchingTree.astro` — the lane
  geometry, the `scaleY(-1)` flip, the `preserveAspectRatio="none"` fill and the 840px
  collapse all stay exactly as they are.
- `ProseColumns` from `src/components/page/ProseColumns.astro` — the `1fr 123px 1fr`
  column arithmetic is untouched; only a prop is threaded through.
- The isolation-page pattern from `src/pages/isolated-components/BranchingTree.astro`
  (`#codeyam-capture` wrapper, centring body, the `src/styles/tokens.css` import) is the
  template for the new variations page.
- The existing `seededRandom` / `treeSegments` determinism tests in
  `src/lib/structures.test.ts` are the model for the new sweep tests.

**Existing-implementation survey.** Grepped `src/` for the names this plan proposes to
introduce — hashSeed, seedFor, treeSeed, variant, searchParams — and nothing equivalent
exists. The variant hits are unrelated: colour variants in
`src/components/Mark.astro`, home/internal variants in
`src/components/chrome/SiteFooter.astro`. There is no
per-page seed derivation, no parameter envelope, no acceptance check, and no client-side
script anywhere in `src/` today — this is the first one, which is why the `?tree=static`
capture question has to be answered here rather than inherited.

**Constrained-file pre-check.** `classify-constrained-files` over every file above returns
`{"constrained": []}` — no lean-contract or agent-config files are involved.

## Scenarios to Demonstrate

- **About - Full Design** — the internal-page template with the About-seeded tree; the
  baseline everything else is compared against.
- **Contact - Email Only** — the same template, a visibly different tree. Seeing these two
  side by side is the per-page axis, proven.
- **Page Created from the CMS** (`/a-day-in-the-life`) — a page nobody wrote code for,
  growing its own tree. This is the case that matters most: the variation has to arrive
  for free when an editor creates a page.
- **Page - Minimal Fields** (`/notes`) — the sparest page, confirming the tree still fills
  its lane when there is little prose beside it.
- **BranchingTree - Variations** (new) — eight seeds in a row: the envelope made
  inspectable. Look for a bald stick, a one-sided comb, or a tree that does not reach the
  top of its lane.
- **BranchingTree - Default** and **ProseColumns - Default** — the isolated components,
  pinned with `?tree=static`, confirming the escape hatch actually holds the SSR tree
  still.
- **Manual check (not a scenario):** load `/about` in the preview and reload three or four
  times. A different tree each time is the per-visit axis; watch specifically for how
  visible the swap is on first paint, which is the one judgement call this plan defers to
  execution.