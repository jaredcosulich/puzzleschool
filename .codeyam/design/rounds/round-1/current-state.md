# Current state — Home, container/layout treatment

## The surface

**Home** (`/`), rendered by `src/pages/index.astro` from the `pages` content
collection entry `src/content/pages/home.md`. Every visual section is a
component; `index.astro` is imports and composition only.

Section order, top to bottom:

1. `home/Masthead.astro` — 124px compass-rose mark, "The Puzzle School" wordmark
   (70px/600/-.035em), teal kicker "AN EXPERIMENTAL K–12 SCHOOL".
2. `structures/SineRule.astro` — 720×42px centred sine field, gold, largest wave
   cut off mid-cycle.
3. `home/StatementBlock.astro` — 56px statement heading (max 900px), two body
   paragraphs at 19px/1.7 (max 760px), then the 24px lead line "Welcome to The
   Puzzle School". Closes with `--space-5xl` (156px) of space.
4. `home/ActionCards.astro` → two `home/ActionCard.astro` — a 3-column grid
   (`repeat(3, 1fr)`, 48px gap) holding **two** cards; **column 3 is
   deliberately empty**. Card 1 teal (Contact), card 2 coral (Learn More), each
   with a 6px top rule and a square button. `structures/FibonacciStructure.astro`
   is absolutely positioned to grow upward out of card 1's teal rule.
5. `home/QuoteBand.astro` — the ink band: night mark, the 46px Bertrand Russell
   pull quote, gold-free attribution at 18px. `structures/KochFragment.astro`
   overlaps its top edge.
6. `chrome/SiteFooter.astro` (`variant="home"`) — 11px uppercase meta row.

Home passes `showNav={false}`: it has no nav bar, because the masthead *is* the
navigation.

## The container — what this round is about

All of the framing lives in **one rule**, `src/layouts/BaseLayout.astro:74`:

```css
.page {
  width: min(var(--page-width), 100%);   /* --page-width: 1280px */
  margin: 0 auto;
  background: var(--paper);              /* #faf7f1 */
  border: 1px solid var(--hairline);     /* #e6e0d4 */
  overflow: hidden;
}
```

with `body { background: var(--desk); }` (`--desk: #e9e5dc`) behind it.

So the site renders as a **literal page**: a 1280px paper-coloured canvas with a
hairline border, centred on a darker desk. Above 1280px viewport width the desk
shows as colored strips down both sides. Critically, the **ink bands stop at
1280px too** — the dark QuoteBand is a dark rectangle inside the page rather
than a full-width band.

**The user's objection:** this reads as dated and magazine-like — "a colored
padding on the left and right vs a legitimate full width website that is
responsive." This round explores full-width / modern container treatments.

## What must NOT change

The design system is settled and stays exactly as-is:

- **Type** — Instrument Sans only, weights 400/500/600. The scale in
  `src/styles/tokens.css` (70 / 56 / 46 / 42 / 32 / 25 / 24 / 19 / 18 / 17 / 13
  / 12 / 11px) and its letter-spacing.
- **Palette** — paper `#faf7f1`, ink `#16211e`, teal `#1f7a72`, coral `#d4562f`,
  gold `#d9a01e`, teal-on-ink `#2f9e94`, body `#414a46`, body-on-ink `#b6c2be`,
  footer `#7d7468`, hairline `#e6e0d4`.
- **Square corners everywhere, no border-radius, no shadows.**
- **The generated line structures** (Fibonacci spiral, sine field, Koch
  fragment, dragon curve, branching tree, morse rule), drawn at hairline weight
  and **deliberately left incomplete** — a limb ends bare, a curve stops before
  it closes. This carries the "one piece is always missing" idea and is the
  identity of the site.
- **The empty third card column** — another instance of the missing piece.
- Copy is final as shown in `home.md`.

The **only** variable across the mockups is the layout container strategy:
where the paper ends, where the bands end, how wide content is allowed to get,
and where the structures anchor.

## Scenario that renders this surface

| Scenario | Slug | Sizes | Data state |
| --- | --- | --- | --- |
| Home - Full Design | `home-full-design` | Desktop | Full — every optional field in `home.md` populated (kicker, heading, lead, two cards, quote + attribution) |

Component-level scenarios also cover the pieces in isolation:
`masthead-default`, `sinerule-default`, `statementblock-default`,
`actioncards-default`, `actioncard-default`, `actioncard-coral-accent`,
`quoteband-default`, `sitefooter-home-variant`, `fibonaccistructure-default`,
`kochfragment-default`, `mark-default`, `mark-on-ink`.

**Gap worth noting:** every captured scenario is **Desktop only**. The site has
`@media (max-width: 840px)` rules in eight components, but no scenario captures
them — so there is no visual evidence for the responsive behaviour this round
is explicitly about. Whatever direction is chosen should add at least one
narrow-viewport capture.

## Reference

`.codeyam/design/user_files/design_handoff_puzzle_school/index.html` is the
original design reference for this page — self-contained, fixed at 1280px,
carrying the SVG symbol sprite and every structure as inline SVG. It is the
faithful record of the intended look, and the base the mockups vary from.
