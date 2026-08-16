---
title: "Full-Bleed Layout for the Site Container"
mode: ui
createdAt: "2026-08-16T10:50:44Z"
source: manual
---

## Summary

The site renders as a literal page: a 1280px paper canvas with a hairline
border, centred on a darker `--desk` background. Above 1280px the desk shows as
colour strips down both sides, and — the part that actually dates it — the ink
bands stop at 1280px too, so the dark quote band reads as a dark rectangle
inside a page rather than a band across a website.

Make the site full-width: drop the desk and the page border so paper runs edge
to edge, and let the ink bands bleed to the viewport while their content stays
on today's 1280px measure.

This is the container only. Type scale, spacing tokens, palette, the generated
line structures and the deliberately empty third card column are all unchanged.
Chosen from a six-option design round (`.codeyam/design/rounds/round-1/`,
option 1) because it preserves every proportion already approved — the 56px
statement against its 900px measure, the 3-column card grid, the Fibonacci
spiral growing out of the Contact card's rule — while changing the one thing
that reads as dated.

## Key Decisions

- **Paper becomes the body background; the canvas keeps its 1280px cap.** With
  `body` painted paper, the page no longer sits *on* anything, so the canvas
  cap stops being visible as an edge and becomes what it should be — a reading
  measure. That means most components need no change at all: their existing
  `padding: X var(--gutter)` already centres content at 1280.

- **Only the ink bands actually need to escape the container.** Paper-on-paper
  needs no bleed. The dark bands are the only elements whose background must
  reach the viewport edge, so a single `.bleed` utility applied to three
  components does the whole job. This is why the change is small rather than a
  rewrite of every band into wrapper + inner.

- **`.bleed` uses the margin-inline escape, not a restructure.**
  `margin-inline: calc(50% - 50vw); width: 100vw` lets a band break out of its
  centred parent without adding a wrapper element or touching the inner
  layout — so each band's existing padding, grid and structure anchoring keep
  working exactly as they do now.

- **Horizontal overflow moves to `overflow-x: clip` on `html, body`.** `.page`
  currently carries `overflow: hidden`, which is what stops the overhanging
  structures from producing a scrollbar — but it would also clip a full-bleed
  child, defeating the change. `clip` contains the overhang without creating a
  scroll container, so a bled band still measures a true 100vw. Declared as
  `overflow-x: hidden; overflow-x: clip` so the older keyword remains the
  fallback.

- **`QuoteBand` must stay unclipped.** Its own comment records why: the Koch
  fragment is stroked in ink, invisible against the band, and only legible
  where it crosses onto the paper above. `.bleed` adds no clip, so this holds —
  but it is the one thing to re-check visually after the change.

- **`--desk` stays in `tokens.css`, unused, with a note.** It is part of the
  documented palette in the design handoff. Deleting the token would make the
  handoff and the code disagree; marking it as no longer applied records the
  decision where the next reader will find it.

## Implementation

### 1. Repaint the ground and move the overflow guard

**File**: `src/styles/tokens.css`

- `body` background `var(--desk)` → `var(--paper)`.
- Replace `html { overflow-x: hidden }` with `html, body { overflow-x: hidden;
  overflow-x: clip }`, keeping the existing comment about structures
  overhanging and extending it to say why `clip` rather than `hidden`.
- Leave `--desk` defined; update its comment to record that nothing paints it
  since the site went full-width.

### 2. Unframe the canvas

**File**: `src/layouts/BaseLayout.astro`

In the `.page` rule: drop `border: 1px solid var(--hairline)` and
`overflow: hidden`; keep `width: min(var(--page-width), 100%)` and
`margin: 0 auto`. Update the component comment — it currently describes "a
1280px paper-coloured canvas with a hairline border, centred on a darker desk",
which is exactly what stops being true.

Add the shared `.bleed` utility to `src/styles/tokens.css` (global, since three
components in two directories use it and Astro component styles are scoped):

```css
.bleed {
  margin-inline: calc(50% - 50vw);
  width: 100vw;
}
```

### 3. Bleed the three ink bands

- **`src/components/home/QuoteBand.astro`** — add `bleed` to `section.band`.
  Confirm the Koch fragment still crosses onto the paper above and is not
  clipped.
- **`src/components/page/ExploratoryBand.astro`** — add `bleed` to
  `section.band`. It keeps its own `overflow: hidden` (the dragon curve is
  clipped to the band deliberately); that clip is on the band, not the page, so
  it is unaffected by the bleed.
- **`src/components/structures/MorseRule.astro`** — add `bleed` to the ink
  strip so the 12px rule spans the viewport rather than stopping at 1280.

Because `.bleed` is a global utility and Astro scopes component styles, apply it
as a plain class in the markup; no `:global` escape hatch is needed in the
component `<style>` blocks.

### 4. Check the internal-page hairline

**File**: `src/pages/[...slug].astro`

The internal template has a hairline rule between the prose columns and the
band (`margin: 0 40px` in the handoff). Confirm whether it should stay on the
content measure or bleed with the bands; keep it on the measure unless it reads
as orphaned once the bands are full-width.

### Explicitly out of scope

- Type scale, spacing tokens, palette, border radius — unchanged.
- The generated structures and where they anchor — they stay anchored to the
  content column, not the viewport edge (that was option 4 in the round).
- The empty third card column stays empty.
- Content, copy and CMS wiring — untouched.

## Reused existing code

**Existing-implementation survey.** Grepped `src/` for `bleed`, `100vw`,
`margin-inline` and `50vw`: **no full-bleed helper exists today.** The only
viewport-relative sizing in the codebase is the `clamp()` fluid type and gutter
tokens, which are unrelated. `.bleed` is genuinely new.

- `--page-width`, `--gutter`, `--gutter-wide`, `--paper`, `--ink`, `--hairline`
  from `src/styles/tokens.css` — the change re-points which of these paint the
  ground; it introduces no new colour or measure.
- The eight existing `@media (max-width: 840px)` blocks across
  `ProseColumns`, `PageHeader`, `BandQuote`, `ExploratoryBand`, `ActionCards`,
  `FibonacciStructure`, `BranchingTree`, `DragonCurve` and `KochFragment` —
  all continue to apply unchanged; the bleed is a container change above that
  breakpoint's concerns.

## Scenarios to Demonstrate

- **Home at 1280 — the design width.** Identical to today except the desk
  strips and page border are gone and the quote band reaches both edges.
- **Home at 1920 — the case that motivated this.** Paper and the ink band run
  edge to edge; the statement, cards and Fibonacci spiral hold their 1280
  measure and stay centred.
- **Home at 1280 with the Koch fragment checked.** The fragment still crosses
  from the band onto the paper above — the regression `.bleed` could plausibly
  cause.
- **Internal page (About) at 1920.** The morse rule and the exploratory band
  both span the viewport; the three prose columns and the branching structure
  between them stay on the content measure.
- **Narrow viewport (below 840).** The existing breakpoints still collapse the
  card grid to one column and drop the structures; no horizontal scrollbar
  appears despite the bled bands — the `overflow-x: clip` check.

Every scenario captured today is Desktop-only, so the narrow-viewport case
needs a new capture rather than a re-capture.