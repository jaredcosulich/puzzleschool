# Atlas

**A design system for fintech interfaces.**

> "Where every peso finds its way."

Atlas is a design system for fintech interfaces that want to feel calm, editorial and data-dense without becoming sterile. It treats numbers as typography, lines as ornament, and color as a signal rather than decoration. It is small on purpose: one accent at a time, two grotesks, one mono, a handful of radii, and the discipline to leave things alone.

It ships with five color themes (Electric blue, Forest, Amber, Rose, Violet) and a fully cascading dark mode that recolors itself per theme.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography, color tokens, spacing, radii, surface treatment, motion. Every surface inherits these.
2. **Essential components** (use as the brief requires) — cards, buttons, inputs, status pills, basic nav, tables, KPI cards, sparklines. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on marketing and hero surfaces. For Atlas, the showcase patterns include: **the multi-segment donut chart, the area-chart-with-tooltip hero, floating callouts on a dark isometric panel, the dark `.dcard.dark` accent card, full-marketing hero numbers, and the bilingual "Hecho en Buenos Aires" footer signature.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark, plus basic nav only if the brief implies it)
- The requested content (grid of cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer

That is the whole page. Do **not** add hero sections with marketing copy, KPI/stat strips, activity feeds, release-note bands, pull quotes, numbered feature rows, illustrated characters, footer signatures with italic taglines, or any showcase pattern unless the brief explicitly asks for it.

### Example compositions are examples

Any reference dashboards, landings, or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Atlas's voice.

---

## Principles

1. **Numbers are the loudest thing on the page.** Everything else negotiates around them. Display digits use Schibsted Grotesk at 600 weight with tabular numerals so columns of money line up regardless of the digit.

2. **One accent at a time.** A single accent color does the heavy lifting. The system never mixes accents; if you need contrast, reach for a tint of the same accent or for ink, never a second hue.

3. **Mono labels for system metadata.** Dates, IDs, statuses, eyebrow tags, version numbers and any string that exists for the machine, not the human, sits in JetBrains Mono with letter-spacing of about 0.1em. This separates the editorial from the operational at a glance.

4. **Italic serifs as the only flourish.** Schibsted Grotesk italic is the system's voice. It carries emphasis on headlines, names of sections, and the one or two words per page that should sing. Used sparingly, it makes the rest feel intentional.

5. **Geometry should be calm, not bubbly.** Border radii live in a tight ladder (10, 16, 22, 28, pill). 1px borders, never thicker. Shadows only when something must lift off the page; usually a hairline does the work.

---

## Foundations

### Color tokens

Atlas separates **neutrals** (theme-agnostic) from **accent** (theme-driven) from **semantic** (status). All three sets have light and dark mode values. Surfaces tinted with the accent are derived from `--accent-rgb` so they recolor automatically when the theme changes.

#### Neutrals, light mode

| Token | Value | Usage |
|---|---|---|
| `--bg` | `#F4F5F7` | Page background |
| `--paper` | `#FFFFFF` | Card surfaces |
| `--ink` | `#0A0F1F` | Primary text, hero numbers |
| `--ink-soft` | `#4D5566` | Secondary text |
| `--muted` | `#8B92A3` | Tertiary text, axis labels |
| `--line` | `#E5E8EE` | Card borders, dividers |
| `--line-soft` | `#F0F2F6` | Inner row dividers, chart grid |

#### Neutrals, dark mode

| Token | Value | Usage |
|---|---|---|
| `--bg` | `#0A0E1F` | Page background |
| `--paper` | `#131830` | Card surfaces |
| `--ink` | `#EEF0F8` | Primary text |
| `--ink-soft` | `#A8AFC2` | Secondary text |
| `--muted` | `#6B7388` | Tertiary text |
| `--line` | `#242B42` | Borders |
| `--line-soft` | `#1A1F35` | Inner dividers |

#### Accent (theme-driven)

The active theme defines six values plus an RGB triple used for derived surfaces.

| Token | Role |
|---|---|
| `--accent` | The base accent. Used for buttons, links, active states, italic accents. |
| `--accent-rgb` | RGB triple for `rgba()` calls. Required for derived surfaces. |
| `--accent-soft` | One step lighter. Used for the second segment in donuts, the second tone in bar charts. |
| `--accent-glow` | Two steps lighter. Used for hero gradient text and the third tone. |
| `--accent-deep` | One step darker. Used for primary button hover and gradient endpoints. |
| `--accent-darker` | Deep accent-tinted near-black. Used for "intentionally dark" cards. |
| `--accent-navy` | Deepest accent. Used as a recessed surface in dark cards. |

#### Surfaces derived from accent

In **light mode** these are solid pastels per theme. In **dark mode** they are computed as `rgba(var(--accent-rgb), x)` so they recolor for free.

| Token | Light value (blue) | Dark value | Usage |
|---|---|---|---|
| `--pale` | `#F5F7FF` | `rgba(accent, 0.08)` | KPI icon backgrounds, tab tracks, table head |
| `--ice` | `#E8EEFF` | `rgba(accent, 0.16)` | Light service card, floating callouts |
| `--ice-2` | `#DCE4FF` | `rgba(accent, 0.24)` | Hover states on light surfaces |

#### Semantic

| Token | Value | Usage |
|---|---|---|
| `--green` | `#2EC27E` | Income, positive deltas, "done" states |
| `--amber` | `#F4B400` | Soft warnings, expense-side tags |
| (red) | `#E55050` | Negative deltas, used in `.kpi-trend.down` |

### Themes

Five themes ship in the box. Each one redefines accent + ice + pale; everything else inherits. To activate, add `body.theme-X`. No class means the default (Electric blue).

| Theme | Accent | Best for |
|---|---|---|
| **Electric blue** | `#2D3FFF` | Default. Cool, tech-forward, neutral. |
| **Forest** | `#0F8F65` | Investment products, savings-positive framings. |
| **Amber** | `#D86A1A` | Warmer, premium-feeling, hospitality-adjacent. |
| **Rose** | `#D4267A` | Lifestyle, consumer-leaning surfaces. |
| **Violet** | `#6D33D6` | Pro tier, advanced tools, technical interfaces. |

Adding a sixth theme is one CSS block; see "Extending" at the end.

### Typography

Three families do everything.

| Family | Role | Weight | Used for |
|---|---|---|---|
| **Schibsted Grotesk** | Display | 500, 600 | Headlines, hero numbers, KPI values, section titles. Italics carry emphasis. |
| **Hanken Grotesk** | Body | 400, 500, 600, 700 | Paragraphs, button labels, list items, navigation. |
| **JetBrains Mono** | Data | 500, 600, 700 | Eyebrows, dates, IDs, version stamps, axis labels, status pills. |

#### Type scale

| Token (informal) | Size | Leading | Used for |
|---|---|---|---|
| Hero | 56-96px | 0.88-0.96 | Landing headline |
| Display L | 44-52px | 1.0 | Section H2 |
| Display M | 28-32px | 1.05 | Dashboard H1 |
| Display S | 22-24px | 1.1 | Card titles |
| Body L | 17-18px | 1.55 | Lead paragraphs |
| Body | 14-15px | 1.5 | Default |
| Body S | 12-13px | 1.45 | Captions, table cells |
| Mono | 9-12px | 1.0 | Eyebrows, labels, dates |

Letter-spacing is tightened on display (`-0.025em` to `-0.045em`) and opened on mono (`+0.06em` to `+0.18em` depending on size). Display gets tighter as it gets bigger; mono gets looser as it gets smaller.

#### Tabular numerals

Always set `font-variant-numeric: tabular-nums` on any number that lives in a column or that the user might compare to another number. Without it, currency tables wobble.

### Spacing

A 4px base scale. Common values are 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32, 40, 48, 56, 64, 80. Card padding is 18-22px on mobile, 22-32px on desktop. Section vertical rhythm is 80-100px.

### Radius

A small, deliberate ladder. Anything outside it should be justified.

| Token | Value | Used for |
|---|---|---|
| `--r-sm` | 10px | Small chips, search avatars |
| `--r-md` | 16px | Tiles, status pills, callouts |
| `--r-lg` | 22px | Standard cards |
| `--r-xl` | 28px | Hero cards, big visual frames |
| `--r-pill` | 999px | Buttons, tabs, eyebrows |

The phone bezel uses 44px and the screen 36px, but those are device, not interface.

### Lines

Every divider is exactly 1px. Two tones:

- `--line` for card borders, primary dividers, table head/foot rules
- `--line-soft` for inner row dividers, chart grid lines

Hairlines do most of the work that shadows would do in a heavier system. Resist thickening.

### Elevation

A single soft shadow exists for the theme picker pill: `0 8px 24px rgba(10, 15, 31, 0.18)`. The buttons get a colored shadow: `0 8px 24px rgba(var(--accent-rgb), 0.4)` plus an inset highlight. That is the whole elevation vocabulary. Cards lift with hairlines.

### Motion

Three durations only.

| Duration | Used for |
|---|---|
| 0.12s | Hover states, nav item color changes |
| 0.18s | Button hover (with subtle transform) |
| 0.25s | Card hover lift, larger transitions |

All easings are the browser default `ease`. No spring. No bounce. Money apps should not bounce.

---

## Dark mode

Dark mode is one CSS class on `<body>`. Every component uses tokens, so flipping `body.dark` is the entire payload.

### What changes

- Neutrals invert: page goes deep navy, paper becomes a slightly lifted navy-blue card surface
- Accent stays the same (preserves theme identity in both modes)
- Tinted surfaces (`--pale`, `--ice`, `--ice-2`) become rgba-derived from the accent, so they recolor with the theme

### What stays

Sections that were intentionally dark in light mode (the landing hero, CTA banner, dark service cards, image showcase, mobile target progress card) get re-pointed to `--accent-darker` in dark mode. This keeps them legibly different from `--paper` while inheriting a hint of the active accent. The result is a subtle layered look rather than a flat one.

### What needs special attention

A handful of elements need explicit dark overrides because they don't fully cascade:

- Status bar text in the phone mockup (must stay legible on the new paper color)
- Tab pills' active state (uses `--accent` instead of `--ink` in dark mode for contrast)
- Phone bottom-nav FAB (becomes accent-filled)
- Target progress bar track (becomes `--bg`, no border, otherwise it gets lost)

Adding a new component? Audit it in dark mode immediately. If anything doesn't read, the fix is usually swapping a hardcoded color for a token, or adding a `body.dark .your-class { ... }` override.

---

## Components

### Buttons

Five variants. Pick by intent, not by frequency.

| Class | When to use |
|---|---|
| `.btn-primary` | The single most important action on a page. Accent fill, white label, colored shadow. |
| `.btn-secondary` | Secondary action, paired with primary. Paper fill, ink border, ink label. |
| `.btn-ghost` | Tertiary action on dark surfaces. Transparent with hairline border. |
| `.btn-dark` | Primary action inside a light section that competes with the page primary. Ink fill. |
| `.btn-pill-light` | Used in dark navs where the primary needs to read against navy. White fill. |
| `.dash-icon-btn` | 36px circle, paper fill, hairline border. For utility actions like notifications. |

All buttons are pill-shaped. Padding is 10-14px vertical, 18-26px horizontal. They never get larger than that.

### Cards

`.dcard` is the base. Paper fill, 1px line border, 22px radius, 22px padding. Variants by adding a class:

- `.dcard.dark` flips to `--accent-darker` background, white text. Used sparingly, max one per dashboard row.
- `.dcard-hero`, `.dcard-kpi`, `.dcard-flow`, `.dcard-spend`, `.dcard-tx`, `.dcard-targets` are layout variants that set `grid-column: span N` on a 12-column grid.

Cards have an internal anatomy: an optional `.dcard-eyebrow` (mono uppercase tag with a small accent square), a `.dcard-title` (Schibsted Grotesk italic-accented), and the body.

When a card needs an action in the corner, wrap eyebrow + title in `.dcard-head` with `display: flex; justify-content: space-between` and put a `.dcard-action` pill on the right.

### Eyebrow + Title pattern

The system's signature pattern. Used everywhere from feature sections to dashboard cards.

```html
<div class="dcard-eyebrow">
  <span class="square"></span>
  CASHFLOW · LAST 12 MONTHS
</div>
<h2 class="dcard-title">Income vs <em>expense</em></h2>
```

Three rules:

1. The eyebrow is mono, uppercase, letter-spaced. It contains category, scope, time range, or version. Never sentence case.
2. The square is `--accent`. Pure visual punctuation. 7px square, no rounding.
3. The title is grotesk, italic only on the one or two words that matter. Never italicize the whole title.

### Tabs

Two patterns:

**Tab pill row** (`.nw-tabs`): Used for time-range pickers (1D / 1W / 1M / 1Y / ALL). Mono, uppercase, sits in a `--pale` track. Active tab fills with ink (light mode) or accent (dark mode).

**Tab chip row** (`.ph-tabs`): Used for filter chips (All / Banking / Invest / Crypto). Hanken sentence case, tabular spacing, sits flat on the page. Active fills with ink in both modes.

### Tables

The table is a first-class component, not an afterthought.

```
┌───────────────────────────────────────────────┐
│ MERCHANT  CATEGORY  DATE             AMOUNT  │  ← .tx-head (mono uppercase, --pale bg, hairline top + bottom)
├───────────────────────────────────────────────┤
│ [av] Mercado Libre  • Shopping  May 05  - $124│  ← .tx-row (separated by --line-soft)
│ [av] Salary         Income      May 03  + $5,420
│ ...
└───────────────────────────────────────────────┘
```

Rules:

1. Header is mono uppercase, sits in `--pale`, has hairlines top and bottom
2. Rows are separated by `--line-soft`, never by `--line` (rows are inside one card; the card already has the heavier border)
3. Amounts are right-aligned, Schibsted Grotesk 600, tabular nums. Positive amounts go green, negative stays ink.
4. Dates are mono, color `--muted`, smaller than other cell text
5. Each merchant gets a 36px rounded-square avatar with monogram. Avatar background is `--pale`, monogram is `--accent`. Salary/income rows can swap to a green-tinted avatar.

### Charts

Atlas ships four chart patterns. All share the same axis treatment: dashed `--line-soft` grid lines at 0.5px width, mono tick labels, no axes drawn (the grid implies them).

#### Multi-segment donut

The system's signature data viz. Five segments using the accent ladder (`--accent`, `--accent-soft`, `--accent-glow`, `--ink`, `--muted`). Built from stacked `<circle>` elements with `pathLength="100"` so `stroke-dasharray` reads as percentages.

Each segment is trimmed by 1 unit to create a hairline gap. The center holds either a small number (category count) or a large number (total spend). When the center holds a large number, the donut needs at least 160px diameter to avoid clipping.

#### Sparkline

A single 1.8px line in `--accent`, no axis, no labels. Lives inside KPI cards under the value. Optional area fill at 0.06 opacity if the card needs more presence.

#### Bar chart (grouped)

Used for cashflow. Two-tone grouped bars: income above the zero line in `--accent`, expense below in `--accent-soft`. Bars are 22px wide, 6px gap within a group, 18px gap between groups. The zero line is a 1px solid `--line`, the +/- gridlines are 0.5px dashed.

Labels are single letters (M, J, J, A...), mono, color `--muted`, except the current month which goes ink and 600 weight.

#### Area chart with tooltip

Used for the net worth hero. Linear gradient fill (accent at 25% opacity to 0%), 2.4px line on top in `--accent`. A pinned vertical guide with a hollow circle marks a moment of interest; a filled circle with a soft glow marks the present. A small ink-fill rounded rect tooltip floats above the pinned moment.

### Floating callouts

Used in the landing's split section, layered over the dark isometric panel. `--ice` background, `--ice-2` border, 16px radius, 12px shadow. Two-line content: a `--muted` mono label on top, a `--accent` strong line below. Position absolutely, rotate dashed lines connecting them to the panel.

### KPI card

```
┌────────────────────────┐
│ [icon]         [trend] │
│ Income · this month    │
│ $5,420.00              │
│ ╱╲╱╲╱╲╱╲ (sparkline)   │
└────────────────────────┘
```

Anatomy: 36px rounded icon top-left in `--pale` with `--accent` stroke. Mono trend pill top-right (green or red). Small `--muted` label, large value, sparkline at the bottom. Padding is 20-22px. Total height is uniform across the row.

### Inputs

The search field is the only input pattern in the system so far. Pill-shaped, `--paper` fill, 1px line border, 8-14px padding, 13px text. Search icon `--muted` to the left. Placeholder text uses `--muted`. Focus state inherits browser default (no ring); the system trusts you to know what's focused.

---

## Iconography

All icons are line-based, drawn as SVG with `stroke="currentColor"`, `fill="none"`, `stroke-linecap="round"`, `stroke-linejoin="round"`. Stroke widths sit in three buckets:

- 1.8 for decorative icons (illustrations, feature card markers)
- 2.0-2.2 for UI icons (nav, buttons, chips)
- 2.4-2.6 for chart icons (small, need to read at 12-14px)

Sizes: 14px in inline contexts, 15-16px in nav, 18-22px in card icons. Never larger than 22px without becoming an illustration.

The system uses Lucide-style geometry but does not depend on the Lucide library. Each icon is hand-inlined for full control.

---

## Voice & tone

Atlas is bilingual by default. The product's users live across English and Spanish (memorably, in Buenos Aires), and the copy reflects that with phrases like "Buenos días, Dani" and "Hecho en Buenos Aires" sitting comfortably alongside English UI.

Five rules:

1. **Calm, never pushy.** "Today is a perfect day to begin," not "Start now!" Money apps that yell make people feel worse.
2. **Specific over abstract.** "$48 routed to Trip pot" beats "savings progress." Always show the noun and the number.
3. **One small joke per page, max.** "Cancel anytime. No questions, no awkward call." That is the joke quota. Use it on the CTA section, not in error messages.
4. **Plain language for plain things.** "Where it went" beats "Categorical expense allocation." Reach for the everyday word first.
5. **Italics carry the voice.** "Quiet automation, *loud results*." "Comprehensive money tools *for people, not portfolios*." The italic word is the human one.

The system tries to never apologize, never threaten, and never use the word "smart" as a feature descriptor.

---

## Extending

### Adding a sixth theme

One CSS block, no SVG edits. Append to the tokens section:

```css
body.theme-ocean {
  --accent: #0E7490;
  --accent-rgb: 14, 116, 144;
  --accent-soft: #38AECC;
  --accent-glow: #94D8E8;
  --accent-deep: #075061;
  --accent-darker: #07252F;
  --accent-navy: #04161B;
  --ice: #DBF1F7;
  --ice-2: #C0E5EF;
  --pale: #EFF9FC;
}
```

Add the swatch button to the theme picker. The whole product, all three views, recolors. Dark mode "just works" because the dark surfaces are derived from `--accent-rgb`.

### Adding a new chart

Three rules: use tokens for every color, set `pathLength="100"` if you want to talk in percentages, and add an attribute selector if you must hardcode a color (so dark mode can override it):

```css
body.dark [stroke="#YOUR-HARDCODED-COLOR"] { stroke: var(--your-token); }
```

Avoid hardcoding when you can. The system is more durable when every color goes through a token.

### Adding a new component

Audit checklist:

1. Does it use tokens for every color, line, radius and spacing value?
2. Does it look right in all 5 themes?
3. Does it look right in dark mode?
4. If it has an icon, is the stroke width in the bucket?
5. If it has a number, is `tabular-nums` set?
6. If it has a label, is it mono uppercase?
7. If it has a title, does the italic carry the meaning?

If yes to all, it belongs.

---

*Atlas Design System v1.0 · Made in Buenos Aires.*
