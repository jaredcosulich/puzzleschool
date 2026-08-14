---
title: "More Space Between The Statement And Card Bands On Home"
mode: ui
createdAt: "2026-08-14T19:25:57Z"
source: manual
---

## Summary

On the home page the statement band — the 56px claim, the body copy, and the
"Welcome to The Puzzle School" lead that closes it — sits too close to the
action-card band below it (the two cards with the teal and coral 6px accent
rules). The gap is `StatementBlock`'s 62px bottom padding (`--space-2xl`), which
is the smallest band-to-band gap on the page: the statement's own top padding is
92px, the card band's bottom padding is 104px, and the quote band is 104px top
and bottom. Raise that bottom padding to 104px (`--space-4xl`) so the break
between the statement and the cards reads as a section break at the same scale
as every other band transition.

## Key Decisions

- **Grow `StatementBlock`'s bottom padding, do not add top padding to
  `ActionCards`.** `ActionCards` hosts `FibonacciStructure`, which is
  `position: absolute` (via the global `.structure` rule in
  `src/styles/tokens.css`) with `top: -106px` measured from the `.cards`
  section box. Padding on `.cards` moves the cards down but leaves the spiral
  where it is, so the spiral detaches from the Contact card's teal rule — the
  exact "rooted in the card" effect the component's own comment says to
  preserve. Padding on the statement above moves the whole card band, spiral
  included, so the anchoring is untouched.
- **104px (`--space-4xl`), not 92px.** 104px matches the card band's bottom
  padding and the quote band's vertical rhythm, so the statement→cards gap
  becomes consistent with the two band transitions that bracket it. 92px would
  merely make the statement symmetric with its own top padding and still leave
  this the tightest transition on the page.
- **Make it fluid, matching the file's existing pattern.** The statement's top
  padding is already `clamp(52px, 7vw, var(--space-3xl))`. A flat 104px bottom
  padding would be heavy on narrow screens where the cards stack into one
  column, so use `clamp(62px, 8vw, var(--space-4xl))` — the current 62px stays
  the small-screen floor, so nothing gets tighter than today, and the full
  104px only applies at desktop width. The `8vw` slope matches `QuoteBand`'s
  `clamp(56px, 8vw, var(--space-4xl))`.
- **Use the existing token, do not introduce a new one.** `--space-4xl` is
  already 104px in `src/styles/tokens.css`; no token changes are needed.

## Implementation

### 1. Grow the statement band's bottom padding

**File**: `src/components/home/StatementBlock.astro`

In the `.statement` rule, change the third value of the `padding` shorthand from
`var(--space-2xl)` to `clamp(62px, 8vw, var(--space-4xl))`:

```css
/* before */
padding: clamp(52px, 7vw, var(--space-3xl)) var(--gutter-wide) var(--space-2xl);

/* after */
padding: clamp(52px, 7vw, var(--space-3xl)) var(--gutter-wide)
  clamp(62px, 8vw, var(--space-4xl));
```

Nothing else in the component changes. Leave the internal `gap: var(--space-lg)`
alone — the spacing between the heading, the body copy, and the lead is correct;
only the space *after* the band is being changed.

### 2. Leave `ActionCards` and `FibonacciStructure` untouched

**File**: `src/components/home/ActionCards.astro` (no edit — recorded so the
build does not "helpfully" add a top padding here)

**File**: `src/components/structures/FibonacciStructure.astro` (no edit)

`.cards` keeps `padding: 0 var(--gutter-wide) var(--space-4xl)` and `.fibonacci`
keeps `top: -106px`. The spiral's bottom edge must still overlap the Contact
card's 6px teal rule after the change; if it visibly detaches in the
`home-full-design` capture, the padding landed on the wrong element and the fix
is to move it back to `StatementBlock`, not to re-tune `top`.

### 3. Recapture the affected scenarios

No new scenarios are needed — the change is visible in scenarios that already
exist:

- `home-full-design` — the page-level capture where the too-tight gap is
  visible. The primary before/after.
- `statementblock-default` (`/isolated-components/StatementBlock`) — the
  isolated capture renders the component with its own padding, so its captured
  height grows by up to 42px.
- `actioncards-default` — should be **unchanged**. If it moves, something edited
  `ActionCards` and Change 2 was violated.

## Reused existing code

- `--space-4xl` (104px) and `--space-2xl` (62px) from `src/styles/tokens.css` —
  the existing spacing scale; no new token.
- `--space-3xl`/`clamp()` fluid-padding pattern already in
  `src/components/home/StatementBlock.astro` and
  `src/components/home/QuoteBand.astro` (`clamp(56px, 8vw, var(--space-4xl))`) —
  the `8vw` slope is copied from there rather than invented.
- `.structure { position: absolute }` in `src/styles/tokens.css` — the rule that
  makes top padding on `.cards` the wrong seam; documented above so the
  constraint is not rediscovered mid-build.

**Existing-implementation survey:** grepped `src/` for every use of
`--space-2xl`, `--space-3xl`, and `--space-4xl`. The only band-spacing sites are
`src/components/home/StatementBlock.astro:27`,
`src/components/home/ActionCards.astro:38`,
`src/components/home/QuoteBand.astro:34`, and
`src/components/page/ContactButton.astro:19`. There is no shared "section spacing" utility, mixin, or
wrapper component to extend — each band owns its own padding — so editing the one
padding value is the whole change, not a shortcut around an existing abstraction.

## Scenarios to Demonstrate

- **Home, full design (desktop)** — the primary before/after: the gap between
  "Welcome to The Puzzle School" and the teal/coral card rules grows from 62px to
  104px, and the Fibonacci spiral stays rooted in the Contact card's teal rule.
- **Home at the 840px card breakpoint** — the grid collapses to one column and
  the spiral is hidden; confirm the larger gap still looks deliberate rather than
  like a dead zone above a single stacked card.
- **Home on a narrow phone viewport (~375px)** — the `clamp` floor holds the gap
  at 62px, unchanged from today.
- **StatementBlock isolated (`statementblock-default`)** — the component's own
  capture, taller by the added padding.
- **ActionCards isolated (`actioncards-default`)** — the control: identical to
  its current capture.