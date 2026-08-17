---
title: "Keep the branching structure on the seam with the band"
mode: ui
createdAt: "2026-08-17T01:38:23Z"
source: manual
---

## Summary

On the Contact page the branching structure stops roughly 97px above the black
`ExploratoryBand`, instead of landing on the seam the way it does on About. The
tree is absolutely positioned at `bottom: 0` of `.prose-grid` inside
`ProseColumns`, and its foot therefore lands wherever that element ends. On
About, `.prose-grid` is the last thing before the band, so the trunk sits exactly
on the black edge. On Contact, `[...slug].astro` renders `<ContactButton>` as a
*sibling* between `ProseColumns` and `ExploratoryBand`, which pushes the band
down by the button's own height and bottom padding while leaving the tree's
anchor where it was — the visible gap. Fix it structurally rather than with an
offset: give `ProseColumns` a named `foot` slot rendered *inside* `.prose-grid`,
and move the contact CTA into it. The tree then hangs from the true bottom edge
of the paper block, so it meets the band on Contact, on About, and on any future
page that puts something between the prose and the band.

## Key Decisions

- **Reparent the CTA, do not offset the tree.** A `bottom: 97px` (or a
  `--tree-foot-offset` variable set per page) would fix Contact and break the
  next page that adds anything below the prose. Making `.prose-grid` own
  everything that sits between the sine rule and the band means the anchor is
  correct by construction — this is what makes it "always connect" rather than
  "connect on Contact".
- **The figure moves down; its height does not change.** Chosen over stretching
  the lane to reach the band. `height = 365px` is a design fact stated in both
  `BranchingTree.astro` and `ProseColumns.astro`, and `preserveAspectRatio="none"`
  means a variable height would silently restretch the generated geometry — the
  tree would read as a different specimen on every page depending on how much
  furniture sat below the prose. Anchoring keeps one figure at one scale and just
  puts its foot in the right place.
- **A generic `foot` slot, not a `contactHref` prop on `ProseColumns`.**
  `ProseColumns` should not learn what a contact button is. A slot keeps the CTA's
  ownership in the route, where the `showContactButton` field is already read,
  and makes the seam guarantee available to whatever the next page needs there.
- **Cancel the doubled gutter with a negative margin on the slot wrapper, not by
  editing `ContactButton`.** `.prose-grid` already pads `var(--gutter)`
  horizontally, and `.contact-cta` pads the same amount — nested naively the
  button shifts 40px right and stops aligning with the prose's left edge.
  Bleeding the wrapper back out by `calc(var(--gutter) * -1)` restores the exact
  geometry the CTA had as a sibling, and leaves `ContactButton` itself untouched
  so its isolated scenario (`ContactButton - Default`) does not change.
- **No band means nothing to connect to.** On a page with no `heading` (e.g. the
  `Page - Minimal Fields` scenario at `/notes`) the tree lands on the bottom of
  the paper block above the paper-coloured footer. That is unchanged and correct
  — there is no black section there to meet.

## Implementation

### 1. Add a `foot` slot inside the prose grid

**File**: `src/components/page/ProseColumns.astro`

Render a named slot after `.prose` but still inside `.prose-grid`:

```astro
<div class="prose-grid">
  <div class="prose" {...{ [CMS_BODY_ATTR]: '' }}><slot /></div>
  <div class="prose-foot"><slot name="foot" /></div>
  <BranchingTree seedKey={seedKey} />
</div>
```

Style the wrapper so slotted content keeps the full-bleed context it had as a
sibling of `.prose-grid`:

```css
.prose-foot {
  margin: 0 calc(var(--gutter) * -1);
}
```

The wrapper collapses to zero height when the slot is empty, so About and every
page without a CTA render byte-identically.

Update the existing comment on `.prose-grid :global(.tree-well)` — which already
says the structure "sits on the seam with the section below" — to record *why*
that is now true: anything rendered between the prose and the band belongs in the
`foot` slot, because the tree's foot is measured from this element's bottom edge.
A sibling placed after `ProseColumns` reintroduces the gap.

Also note on `min-height: calc(365px + 24px)` that the reservation is now a floor
for the prose block *including* its foot; a taller block only pushes the tree
further below the sine rule, so the guard still holds.

### 2. Move the contact CTA into the slot

**File**: `src/pages/[...slug].astro`

Move the conditional `<ContactButton>` from between `<ProseColumns>` and
`<ExploratoryBand>` into the `ProseColumns` children, carrying `slot="foot"`:

```astro
<ProseColumns seedKey={page.id}>
  <Content />
  {showContactButton ? <ContactButton href={contactHref} slot="foot" /> : null}
</ProseColumns>
```

Note that `<Content />` must stay in the default slot — it is the CMS body target
marked with `CMS_BODY_ATTR`, and moving it would break staged preview patching.

Vertical rhythm is preserved exactly: the same boxes in the same DOM order, only
reparented, so the black band starts at the same y position it does today and
only the tree's anchor moves.

### 3. Recapture the affected scenario

**File**: `.codeyam/scenarios/contact-email-only.json` (capture only, no edit)

`Contact - Email Only` is the scenario that pins this bug. Its screenshot will
change — the trunk moves down ~97px to land on the band's top edge. `About - Full
Design`, `ProseColumns - Default` and `ContactButton - Default` should all be
byte-identical; if any of them moves, the slot wrapper is leaking layout and that
is the thing to fix, not the baseline.

Consider adding a scenario for a page that has *both* a contact button and a
band under a short body, so the seam guarantee is pinned for the short-prose case
where `min-height` is what sets the block's height.

## Reused existing code

- `BranchingTree` from `src/components/structures/BranchingTree.astro` — the
  `.tree-well` / `.tree-flip` bottom-anchoring is already correct and is not
  touched; only the box it measures against changes.
- `ContactButton` from `src/components/page/ContactButton.astro` — reused
  verbatim, including its `padding: 0 var(--gutter) var(--space-2xl)`. The
  negative margin on the slot wrapper exists specifically so this file needs no
  change.
- `ExploratoryBand` from `src/components/page/ExploratoryBand.astro` — the black
  band the tree must meet; unchanged.
- `growAcceptableTree` / `treeViewBox` from `src/lib/structures.ts` (glossary
  entries: `growAcceptableTree`, `treeViewBox`) — the generated geometry is
  untouched, which is what keeps the fix from disturbing any tree unit test.
- `--gutter`, `--space-2xl` from `src/styles/tokens.css` — the offset is
  expressed in the existing gutter token, not a literal 40px.

**Existing-implementation survey**: `src/components/page/ProseColumns.astro` has no named slots today
(only the default `<slot />`), and no offset/anchor prop or CSS variable exists on
either `ProseColumns` or `BranchingTree` that already parameterises the tree's
foot position. Searching for `bottom:` across `src/components` finds the anchor only in
`src/components/structures/BranchingTree.astro` (its `.tree-flip` rule) and the
`.tree-well` override in `src/components/page/ProseColumns.astro`. Nothing
equivalent is already implemented.

## Reproduction Test

No unit-level reproduction is writable: this is a pure layout regression that
lives in the DOM parenting and CSS box geometry of two `.astro` components, with
no pure function to assert against. The tree generator in `src/lib/structures.ts`
is already fully tested and is not implicated — it produces the same geometry
either way; only where that geometry is anchored is wrong.

Demonstrate and verify visually instead, via the `Contact - Email Only` scenario:
before the fix its screenshot shows the trunk ending ~97px above the black band's
top edge; after, the trunk terminates on that edge, matching `About - Full
Design`.

## Scenarios to Demonstrate

- **Contact as it ships** (`/contact`) — prose, the "Email us" button, and the
  band with no quote. The trunk lands on the black edge.
- **About, unchanged** (`/about`) — no contact button; the tree still meets the
  band exactly as it does today, proving the empty slot costs nothing.
- **Short body with a CTA and a band** — a page whose prose is shorter than the
  365px lane, so `min-height` drives the block height. The tree must still sit on
  the seam and stay clear of the sine rule above.
- **Page with a CTA but no band** — `heading` left blank, so the paper block runs
  into the footer. The tree rests on the bottom of the block; nothing black to
  meet, and no gap artefact.
- **Narrow viewport (≤840px)** — the structure lane collapses and the tree is not
  drawn; the CTA must still render in the right place with the correct gutter and
  no reserved empty height.