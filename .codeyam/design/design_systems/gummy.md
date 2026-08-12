# Penny Press — Design System

Self-contained guidelines for reproducing the Penny Press design language, in light mode, dark mode, and four alternate palettes. The system applies across surfaces; structure should follow the brief, not a fixed template.

---

## Theme

A high-contrast digital playground. Stark backgrounds (white or cream) splashed with vivid, almost-neon color accents. Geometric flat illustrations softened only by pill-shaped buttons and rounded card edges. Playful but focused — the kind of system that feels like an indie publication ran off with the design budget.

**Theme model**: light-first, with selectively inverted dark mode and four alternate palettes that swap the brand DNA without touching layout.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Inter with `ss04, ss11` features, the strict 400/500/700 weights, the tightened tracking), the 9-token color palette, spacing, radii (4px CTA + 16px cards + 9999px pills), and the chunky-offset shadow vocabulary. Every surface inherits these.
2. **Essential components** (use as the brief requires) — cards with 1px ink border + 16px radius, buttons (solid-black 4px primary + pills for everything else), inputs (gray bg + 4px), tags & chips as pills, avatars with dark border + colored fill, status/delta pills (lime up + orange down), simple basic nav. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on marketing and hero surfaces. For Penny Press, the showcase patterns include: **the floating coins (the brand mark scattered around heroes), the stripe-behind-headline emphasis, the stadium pill CTA section, the big-number block with blinking ticker (`$1,402,318` + LIVE pill), illustrated character cards (the chunky-stroke SVG blobs), the category pill cloud as its own section, the activity feed / event log with colored circle icons, and large illustrated marketing heroes.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (small logo coin + brand wordmark + basic nav only if the brief implies it)
- The requested content (grid of bordered cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied (use cat-pill style)
- An optional single-line footer

That is the whole page. Do **not** add floating coins, stripe-behind-headline marketing heroes, the stadium pill CTA, big-number blocks with tickers, illustrated character SVGs, the category pill cloud as a standalone section, multi-row activity feeds, or any showcase pattern unless the brief explicitly asks for it. The chunky 4px offset shadow is part of the core vocabulary — apply it to whichever surfaces the brief calls for (cards, buttons), no need to invent extra surfaces to feature it.

### Example compositions are examples

Any reference Gumroad-style landings or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Penny Press's voice.

---

## 1. Tokens

### The 9 token slots

Every palette in this system fills exactly nine slots. Memorize these — they're the entire system:

| Token | Role |
|---|---|
| `--pitch-black` | Primary "ink" — text, icons, key borders, primary CTAs (called pitch-black for legacy reasons; in alternate palettes it's whatever dark color anchors the system) |
| `--light-linen` | Page canvas — main background, card surfaces, text on dark elements |
| `--marketplace-gray` | Subtle muted surface — input bgs, secondary content blocks |
| `--graphite-border` | Secondary text, subtle ink, descriptive labels |
| `--subtle-ash` | Soft borders for less-prominent elements |
| `--creator-pink` | Primary brand accent — illustrations, decorative elements, *NOT* primary CTAs |
| `--sunshine-yellow` | Secondary accent — graphic flourishes, occasional backgrounds |
| `--lime-glow` | Tertiary accent — fresh/growth signals, illustrative pops |
| `--firecracker-orange` | Quaternary accent — bold dynamic pops |

A fifth optional slot `--sky-blue` is added for charts and data viz that need a 5th hue. Use sparingly.

### Default (Gumroad) palette

```css
:root {
  --pitch-black: #000000;
  --light-linen: #ffffff;
  --marketplace-gray: #f4f4f0;
  --graphite-border: #242423;
  --subtle-ash: #d1d5dc;
  --creator-pink: #ff90e8;
  --sunshine-yellow: #ffc900;
  --lime-glow: #f1f333;
  --firecracker-orange: #fc6c34;
  --sky-blue: #88d4ff;
}
```

### Dark mode (selective inversion)

Dark mode is **not** a simple color flip. Three principles:

1. **Accent colors stay the same.** Pink, yellow, lime, orange — these are the brand and they're mode-independent. They look great on both light and dark canvases.
2. **Text on accent colors stays dark.** Since pink/yellow/lime stay bright in dark mode, text on top of them must remain dark — never use the off-white "ink" on a pink button. Use the dedicated `--on-accent` token for this.
3. **Borders are softer than the ink.** Pure-white 2px strokes on every card become loud and graphic-novel-noisy. Use `--border-strong` (a soft warm gray) for outer card edges, `--subtle-ash` for internal dividers.

```css
:root {
  /* Text & ink */
  --pitch-black: #f0efeb;          /* warm off-white, NOT pure white */

  /* Surfaces (canvas → cards) */
  --light-linen: #0e0e0c;          /* page bg */
  --marketplace-gray: #1c1c1a;     /* muted surface, secondary cards */
  --card-bg: #161614;              /* primary card, lifted slightly from canvas */

  /* Borders */
  --border-strong: #3a3a36;        /* outer card edges, structural lines */
  --subtle-ash: #2a2a27;           /* internal dividers (very subtle) */

  /* Secondary text */
  --graphite-border: #a8a8a3;      /* muted labels, secondary copy */

  /* Accents (UNCHANGED from light) */
  --creator-pink: #ff90e8;
  --sunshine-yellow: #ffc900;
  --lime-glow: #f1f333;
  --firecracker-orange: #fc6c34;
  --sky-blue: #88d4ff;

  /* On-accent text — dark, for use on pink/yellow/lime/orange */
  --on-accent: #0a0a08;
}
```

**Things that need explicit `--on-accent`** (not inherit `--pitch-black`):
- Text inside pink/yellow/lime/orange filled buttons or pills
- Text inside the floating coins
- The blob character's eyes/mouth (on pink)
- Section eyebrow stripes (pink stripe behind a headline word)
- Stadium-pill CTA section (yellow bg)
- Logo mark (pink circle with the "P")
- KPI featured pink card (text + delta pill inside)
- Sidebar active state when it's pink
- Calendar payout days (lime/pink)
- Activity feed icons (lime/pink/yellow circles)
- All accent-color avatars in lists
- Tab bar notification badges
- Phone bezel offset shadow (use `--creator-pink` not `--pitch-black`, otherwise it's a glaring white blob in dark mode)

**Things that can keep `--pitch-black`** (the off-white ink):
- Body copy on the page canvas
- Card titles and headings
- Sidebar links (when inactive)
- Subject/title input fields
- Secondary CTA borders

**Anti-pattern in dark mode**: Don't use `--pitch-black` (off-white) as a *background* with `--light-linen` (canvas) as text. That creates a glaring white block on the dark canvas — which reads as the inverse of the design. Active states, "Today" markers in calendars, primary CTAs in dark mode should use `--creator-pink` (pink) as their fill instead.

### Alternate palettes

These swap the entire brand DNA but keep layout, illustrations, structure, and CSS class names identical. Each defines its own "ink" color (which becomes `--pitch-black`), its own canvas, and its own 4-accent set.

#### Tropical Punch — beach zine

```css
:root {
  --pitch-black: #0a3540;          /* deep teal ink */
  --light-linen: #e6f9f5;          /* mint-cream canvas */
  --marketplace-gray: #d0f0e8;
  --graphite-border: #1f5060;
  --subtle-ash: #a8d8cc;
  --creator-pink: #ff5e5b;         /* hot coral */
  --sunshine-yellow: #ffd23f;
  --lime-glow: #5eead4;            /* aqua mint */
  --firecracker-orange: #f97316;
  --sky-blue: #60a5fa;
}
```

#### Riso Dream — Risograph print aesthetic

```css
:root {
  --pitch-black: #1a2a6c;          /* cobalt ink */
  --light-linen: #faf6ef;          /* warm cream canvas */
  --marketplace-gray: #f0e8d8;
  --graphite-border: #2a3f7d;
  --subtle-ash: #e0d4b8;
  --creator-pink: #f8a5c2;         /* blush pink */
  --sunshine-yellow: #ffd980;      /* butter yellow */
  --lime-glow: #a3a8e8;            /* periwinkle */
  --firecracker-orange: #e85d3a;   /* tomato red */
  --sky-blue: #7bb6d6;             /* dusty blue */
}
```

#### Forest Pop — cozy bookshop

```css
:root {
  --pitch-black: #2a1a3a;          /* deep plum ink */
  --light-linen: #ecf0e5;          /* sage cream canvas */
  --marketplace-gray: #d8dfc8;
  --graphite-border: #4a3055;
  --subtle-ash: #b5c0a0;
  --creator-pink: #d4827e;         /* dusty rose */
  --sunshine-yellow: #f5d76e;      /* butter yellow */
  --lime-glow: #95b87a;            /* moss green */
  --firecracker-orange: #c45c2e;   /* terracotta */
  --sky-blue: #89a8b2;             /* foggy teal */
}
```

#### Newsprint — vintage editorial

```css
:root {
  --pitch-black: #1a1a1a;
  --light-linen: #f5efe0;          /* newsprint cream */
  --marketplace-gray: #e8e0c8;
  --graphite-border: #3a3a3a;
  --subtle-ash: #c8bfa3;
  --creator-pink: #d62828;         /* tomato red */
  --sunshine-yellow: #e6b325;      /* mustard */
  --lime-glow: #5a8c5a;            /* spinach green */
  --firecracker-orange: #c25b30;   /* burnt orange */
  --sky-blue: #386fa4;             /* denim blue */
}
```

### How alternate palettes work mechanically

The trick that makes the system support multiple palettes without rewriting CSS: **`--pitch-black` is treated as "the ink color of the system" rather than literally black.**

Every component in the system uses `var(--pitch-black)` for its ink (text, icons, primary borders), and `var(--light-linen)` for its canvas (backgrounds). When you swap a palette, you redefine what those variables resolve to, and the entire page re-skins itself.

**Updates required in SVG illustrations** when changing palette:
- Hardcoded `fill="#ff90e8"` (creator-pink) values → swap to the new variant's pink
- Hardcoded `stop-color="#ff90e8"` in chart gradients → swap to new variant's pink
- The `stroke="#000"` strokes inside illustrations should stay literal black — they're the chunky outline style that's part of the brand. Don't tokenize them.

### Color rules

**Lime and sunshine yellow are accent fills, not text colors.** Don't render body copy in yellow or lime — they're for backgrounds, illustration fills, and decorative chips.

**Creator-pink is for illustrations and decorative accents, NOT for primary text or interactive states.** Pink is the brand color, but the *primary CTA is always solid black-on-white* (or in inverted/alt palettes, ink-on-canvas). Pink can be used for secondary CTAs (pill buttons), avatar backgrounds, hero stripe behind a word, illustrated elements.

**Don't introduce new colors.** The palette is closed at 9 tokens. If you need a 5th data series in a chart, use `--sky-blue`. If you need green for "success" specifically, in light mode use a custom dark green (`#1a7a3f`); in dark mode bump to a brighter green (`#4dd384`).

### Typography

```css
:root {
  --font-sans: 'Inter', Arial, sans-serif;
}

body {
  font-family: var(--font-sans);
  font-feature-settings: "ss04", "ss11";
  -webkit-font-smoothing: antialiased;
  line-height: 1.4;
  letter-spacing: -0.32px;
}
```

The reference uses Inter as a substitute for ABC Favorit. **Always include `font-feature-settings: "ss04", "ss11"`** — these are Inter's stylistic alternates that bring it closer to the Favorit feel.

**Type scale:**

| Role | Size | Line Height | Letter Spacing | When to use |
|---|---|---|---|---|
| caption | 14px | 1.43 | -0.406px | Smallest helper text, footer copy |
| body | 16px | 1.4 | -0.32px | All UI body text |
| subheading | 20px | 1.33 | -0.34px | Sub-headlines, hero supporting copy |
| heading | 36px | 1.25 | -0.022em | Section titles |
| heading-lg | 72px | 1.0 | -1.44px | Hero headlines on standard pages |
| display | 96px | 0.9 | -1.92px | Massive numbers (revenue counters etc.) |

**Letter spacing — always tighten.** Inter at every size needs negative tracking to feel right. Use the values above; don't eyeball.

**Weights used**: 400, 500, 700. Nothing else. 700 is reserved for headings, key data values, button labels, and uppercase eyebrows. Don't use 600 or 800.

### Spacing

Base unit: **4px**. Density: **comfortable** (this is the opposite of the Linear-style "compact").

Common values: `--section-gap: 48px`, `--element-gap: 8px`. Cards have `padding: 24-28px`. Page sections have `padding: 80-96px` vertical. Hero sections have `padding: 96px 32px 48px`.

The principle: **generous breathing room everywhere.** This is a system about clarity and play, not density. Don't be afraid of whitespace.

### Border radius

```css
:root {
  --radius-default: 4px;     /* small chips, inputs, small cards */
  --radius-card: 16px;       /* primary cards */
  --radius-large: 24px;      /* large self-contained blocks */
  --radius-pill: 9999px;     /* buttons, tags, pills */
}
```

**Buttons are pills.** Almost always. The only exception is the primary "solid black" CTA button in the hero, which uses 4px radius for a bold, blocky feel. Every other interactive element — secondary buttons, navigation links, filter chips, tags, badges — is a pill (9999px).

**Cards are 16px.** Don't deviate. The hero product mockups, feature cards, testimonial cards, KPI cards — all 16px.

**Large content blocks** (the yellow stadium CTA pill, the big-number band) can use 24px or full pill (9999px) depending on shape.

### Shadows

The system **does not use shadows for elevation.** Elevation comes from borders and backgrounds.

The only place shadows appear:
1. **Chunky offset shadows** — used on standout buttons and the phone bezel. Always `Npx Npx 0 var(--something)` with no blur. The classic Gumroad/Memphis "second sticker" effect:

```css
box-shadow: 4px 4px 0 var(--pitch-black);     /* for buttons */
box-shadow: 8px 8px 0 var(--creator-pink);    /* for phone bezels */
```

In dark mode, the offset shadow color **must** be a brand accent (pink/yellow), never the ink. A 4px offset of `--pitch-black` in dark mode would be a glaring white blob.

---

## 2. Components

### Buttons

```html
<!-- Primary: solid black, blocky 4px radius. THE hero CTA -->
<button class="btn btn-primary">Start your press</button>

<!-- Pill (secondary): white pill with subtle border -->
<button class="btn btn-pill">Log in</button>

<!-- Pill dark: filled black pill, navigation actions -->
<button class="btn btn-pill-dark">Start a press</button>

<!-- Pill pink: brand-accent pill for emphasized secondary actions -->
<button class="btn btn-pill-pink">Find out how →</button>
```

```css
.btn {
  font-size: 16px;
  font-weight: 500;
  letter-spacing: -0.32px;
}
.btn-primary {
  background: var(--pitch-black);
  color: var(--light-linen);
  padding: 14px 32px;
  border-radius: 4px;             /* the only non-pill button */
  border: 2px solid var(--pitch-black);
}
.btn-pill {
  background: var(--light-linen);
  color: var(--pitch-black);
  padding: 8px 16px;
  border: 1px solid var(--subtle-ash);
  border-radius: 9999px;
}
.btn-pill-dark {
  background: var(--pitch-black);
  color: var(--light-linen);
  padding: 10px 20px;
  border-radius: 9999px;
}
.btn-pill-pink {
  background: var(--creator-pink);
  color: var(--pitch-black);   /* in dark mode, swap to var(--on-accent) */
  padding: 14px 28px;
  border: 2px solid var(--pitch-black);  /* in dark mode, var(--on-accent) */
  border-radius: 9999px;
  font-weight: 700;
}
```

In dark mode, `btn-pill-pink` swaps its text to `var(--on-accent)` and its border to `var(--on-accent)` — it's still pink, but the dark text/border keeps it readable.

### Cards

```css
.card {
  background: var(--light-linen);
  border: 1px solid var(--pitch-black);
  border-radius: 16px;
  padding: 24-28px;
}
```

Two card variants:

**Default card** — used everywhere. White (or canvas-color) background, 1px black border.

**Featured/colored card** — sits on a brand accent. Used for highlighted KPIs (pink earnings card), the lime "Next payout" notice, etc. Always pair an accent fill with **on-accent text** — never use the ink color on a saturated bg.

**In dark mode**, default cards use `--card-bg` (lifted) instead of `--light-linen` (canvas). This creates a 3-level hierarchy: page canvas → muted surface → card. Borders use `--border-strong`, never the off-white ink.

### Inputs

```css
.input {
  background: var(--marketplace-gray);
  border: 1px solid var(--graphite-border);
  border-radius: 4px;
  padding: 14px 16px;
  font-size: 16px;
  color: var(--pitch-black);
}
.input::placeholder { color: var(--graphite-border); opacity: 0.6; }
```

Inputs use the muted gray background, not pure white. The 4px radius matches the primary button.

### Status / data indicators

For positive deltas in KPIs, use a **lime pill with dark text**:
```css
.delta-up {
  background: var(--lime-glow);
  color: var(--pitch-black);
  border: 1px solid var(--pitch-black);
  border-radius: 9999px;
  padding: 2px 8px;
}
```

For negative deltas, **firecracker orange** with `--light-linen` text in light mode (or `--on-accent` in dark mode for consistency).

### Tags & chips

```css
.tag {
  background: var(--light-linen);
  border: 1px solid var(--pitch-black);
  border-radius: 9999px;
  padding: 4px 12px;
  font-size: 14px;
  font-weight: 500;
}
```

All chips are pills. Active states fill the chip with `--pitch-black`. In dark mode, active states fill with `--creator-pink` instead (so they don't look like glaring white blocks).

### Avatars

Always have a dark border and a colored fill:

```css
.av {
  width: 36px; height: 36px;
  border-radius: 50%;
  border: 1px solid var(--pitch-black);  /* in dark: var(--on-accent) */
  display: grid; place-items: center;
  font-weight: 700;
}
.av.pink { background: var(--creator-pink); color: var(--pitch-black); }
.av.yellow { background: var(--sunshine-yellow); color: var(--pitch-black); }
.av.lime { background: var(--lime-glow); color: var(--pitch-black); }
.av.orange { background: var(--firecracker-orange); color: var(--light-linen); }
```

In dark mode, the user themselves (when they appear in their own UI as a "you" indicator) gets a lime avatar with `--on-accent` initials.

### Floating coins (the signature element)

The Penny Press "P" coin is a recurring brand element — pink (or accent-colored) circles with a chunky border and the letter inside, scattered around the hero in floating positions:

```css
.coin {
  position: absolute;
  width: 88px; height: 88px;
  background: var(--creator-pink);
  color: var(--pitch-black);             /* dark: var(--on-accent) */
  border: 2px solid var(--pitch-black);  /* dark: var(--on-accent) */
  border-radius: 50%;
  display: grid; place-items: center;
  font-size: 40px; font-weight: 700;
}
.coin.c1 { top: 80px; left: 5%; transform: rotate(-12deg); }
.coin.c2 { top: 40px; right: 8%; transform: rotate(8deg); width: 64px; height: 64px; }
.coin.c3 { background: var(--sunshine-yellow); ... }
.coin.c4 { background: var(--lime-glow); ... }
```

Vary coin sizes (56-96px), rotations (-12 to +20 degrees), and colors (rotate through pink/yellow/lime). Place 3-5 around the hero. Don't overdo it.

---

## 3. Cross-context patterns

### The "card on bright accent" pattern

Highlighted KPIs, callout cards, the hero pricing block — these sit on a brand accent fill. Every time you do this, **explicitly set the text color to ink (or `--on-accent` in dark mode)**:

```css
.featured-card {
  background: var(--creator-pink);
  color: var(--pitch-black);             /* dark: var(--on-accent) */
  border: 1px solid var(--pitch-black);  /* dark: var(--on-accent) */
  border-radius: 16px;
  padding: 18-24px;
}
```

### Stripe-behind-headline

The signature hero treatment: one word in the headline gets a pink stripe behind it, slightly rotated:

```html
<h1>From <span class="pink-stripe">scribbles</span><br/>to subscribers.</h1>
```

```css
.pink-stripe {
  background: var(--creator-pink);
  color: var(--pitch-black);   /* dark: var(--on-accent) */
  padding: 0 12px;
  display: inline-block;
  transform: rotate(-1.5deg);
}
```

This is the brand's emphasis pattern. Use sparingly — one word per headline, max one headline per section.

### Hero headline punctuation rule

**Hero headlines must not break on sentence boundaries.** If the headline copy is multiple sentences (e.g., "Save the good stuff. Share the great stuff."), keep the period in the markup but render the headline as a single flowing block of text that wraps naturally based on viewport width — never force a line break after a period.

In practice, this means:

```html
<!-- ✅ DO: one continuous string, periods preserved, natural wrapping -->
<h1>Save the good stuff. Share the great stuff.</h1>

<!-- ❌ DON'T: forced break after the period -->
<h1>Save the good stuff.<br/>Share the great stuff.</h1>

<!-- ❌ DON'T: separate paragraphs -->
<h1>Save the good stuff.</h1>
<h1>Share the great stuff.</h1>
```

The only acceptable `<br/>` in a hero headline is the one used to position the pink-stripe word on its own visual line (see "Stripe-behind-headline" above). Sentence-ending periods are typographic punctuation, not layout instructions.

To prevent accidental forced breaks from CSS or word-spacing, use this defensive rule on `h1.hero-headline`:

```css
.hero-headline {
  /* Let the browser wrap based on width, not punctuation */
  text-wrap: balance;
  white-space: normal;
}
```

`text-wrap: balance` (modern browsers) makes multi-line headlines visually balanced when they do wrap, so the line break happens at the most natural mid-point rather than right after a period.

### Stadium pill CTA

A massive yellow pill that contains a centered character/blob illustration with text rows around it. Used as a section break / soft CTA. Direct riff on the Gumroad pattern:

```css
.stadium {
  background: var(--sunshine-yellow);
  color: var(--pitch-black);             /* dark: var(--on-accent) */
  border: 2px solid var(--pitch-black);  /* dark: var(--on-accent) */
  border-radius: 9999px;
  padding: 28px 48px;
  display: grid;
  grid-template-columns: 1fr auto 1fr;
}
```

### Big-number block

For revenue counters, milestones, "Paid out this week" stats. Use display-size type (96-192px) with the live ticker pill (lime) underneath:

```html
<div class="big-num">
  <div class="amount">$1,402,318</div>
  <div class="ticker"><span class="ticker-dot"></span>PAID OUT THIS WEEK</div>
  <p>To independent presses, illustrators, writers, and weirdos worldwide.</p>
</div>
```

The ticker is a lime pill with a blinking black dot animation:

```css
.ticker-dot {
  width: 8px; height: 8px;
  background: var(--pitch-black);   /* dark: var(--on-accent) */
  border-radius: 50%;
  animation: blink 1.4s ease-in-out infinite;
}
@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
```

### Category pill cloud

Multiple rows of pills with tiny accent-colored circle icons. Used for taxonomies, tags, and categorical browse:

```css
.cat-pill {
  background: var(--light-linen);
  border: 1px solid var(--pitch-black);
  border-radius: 9999px;
  padding: 10px 20px;
  display: inline-flex;
  align-items: center;
  gap: 10px;
}
.cat-pill .icon {
  width: 18px; height: 18px;
  border-radius: 50%;
  /* fill with one of: pink, yellow, lime, orange, blue */
}
.cat-pill:hover { transform: translateY(-2px); }
```

### Illustrated character cards

Two-column grid of cards, each containing a flat-outlined SVG character on a brand-color background. The illustrations are simple geometric: oval body, circle head with a leaf-antenna, line arms, drawn entirely in chunky 2-2.5px strokes with `#000` (literal black, not tokenized):

- Pink card: character at desk drawing
- Yellow card: character celebrating with floating zines

```html
<div class="ill-card">
  <div class="badge">Instead of waiting for permission…</div>
  <div class="illo pink">
    <svg viewBox="0 0 240 180">
      <!-- chunky 2.5px black stroke outlines, white fills, no shadows -->
    </svg>
  </div>
</div>
```

### Charts

SVG-based, **chunky-outline style**:
- Lines use the brand pink (or whatever the variant's pink is) at 2-3px width
- Bars are filled with `--sky-blue` and stroked with **literal black** at 1px (in dark mode use `--on-accent` at 0.5 opacity)
- End-of-line markers are colored circles with a 2px black outline
- Grid lines use `--subtle-ash` at 1px (not the ink color — too loud)
- Axis labels are 10-11px Inter 500, fill `--graphite-border`

```html
<svg viewBox="0 0 800 240">
  <!-- Grid -->
  <g stroke="#d1d5dc" stroke-width="1">
    <line x1="0" y1="40" x2="800" y2="40"/>
  </g>
  <!-- Bar -->
  <rect fill="#88d4ff" stroke="#000" stroke-width="1"/>
  <!-- Line + gradient fill -->
  <path d="M0,180 L40,170..." fill="url(#pg)"/>
  <path d="M0,180 L40,170..." fill="none" stroke="#ff90e8" stroke-width="3"/>
  <path d="M0,180 L40,170..." fill="none" stroke="#000" stroke-width="1.5"/>
  <!-- End dot -->
  <circle cx="800" cy="8" r="5" fill="#ff90e8" stroke="#000" stroke-width="2"/>
</svg>
```

The "double-stroke" effect (a colored line with a thin black overlay on top) is part of the chunky brand. **In dark mode, hide the secondary black stroke entirely** (set `opacity="0"`) — it doesn't translate.

### Tables

Headers are uppercase 10-11px Inter 700, with `--graphite-border` text on `--marketplace-gray` background. Body rows have 10-12px vertical padding, hover bumps to `--marketplace-gray`. Dividers use `--subtle-ash`, not the ink color.

### Activity feed / event log

Live activity items with colored circle icons (lime/pink/yellow/blue) on the left, text in the middle, amount/timestamp on the right:

```html
<div class="feed-item">
  <div class="feed-icon sale">     <!-- lime, pink, yellow, blue -->
    <svg class="icon">...</svg>
  </div>
  <div class="feed-text">
    <div class="top">New sale · <b>Issue 04</b></div>
    <div class="sub-line">From a reader in Buenos Aires 🇦🇷</div>
  </div>
  <div class="feed-amt green">+$8.00<span class="ago">2m</span></div>
</div>
```

The colored icon backgrounds rotate by event type. Every icon must have `--on-accent` (or `--pitch-black` in light) for the actual icon stroke since they sit on bright fills.

---

## 4. The five+ palettes — implementation rules

When implementing alternate palettes (Tropical, Riso, Forest, Newsprint), only change these things:

1. **The 9-token `:root` block** at the top of the file
2. **Hardcoded SVG colors** that reference the original `#ff90e8` pink — search for `fill="#ff90e8"` and `stop-color="#ff90e8"` and replace with the variant's pink
3. **The chart bar fill** if you want it to match the variant's blue (`#88d4ff` → variant's sky-blue)

Do **not** change:
- Layout, structure, or any HTML beyond inline SVG colors
- Class names
- Font, font features, or type scale
- Radii, spacing, or any structural CSS
- The chunky black `stroke="#000"` in illustrations — this stays literal black across all light-mode variants (it's the brand outline style)

In dark mode + alternate palettes are **not currently implemented**. If you need a dark Tropical, dark Riso, etc., apply the same dark-mode token-restructuring approach (introduce `--card-bg`, `--border-strong`, `--on-accent`) on top of the variant's accent set. The accents stay the same in dark; only the canvas/ink/borders shift.

### Switching palettes from default

To convert any reference file to a variant:

```js
// 1. Replace the :root block with the variant's tokens
// 2. Find/replace SVG colors:
//    fill="#ff90e8" → fill="<variant-pink>"
//    stop-color="#ff90e8" → stop-color="<variant-pink>"
// 3. Update any theme-toggle link href
// 4. Update the toggle button colors to use the variant's pink
//    background: var(--creator-pink); color: var(--pitch-black);
//    box-shadow: 4px 4px 0 var(--pitch-black);
```

Five minutes per variant. The system is designed to make this trivial.

---

## 5. Things that look like decoration but aren't

These details are easy to mistake for "designer flourish" but they're load-bearing:

1. **The pink coin with the "P"** (or "¢") — this is the brand's recurring motif. It floats in heroes, footers, and inside featured KPIs. It's not optional decoration — every major page should have at least 2-3 visible.

2. **Slight rotations on stickers and pills** — the pink stripe rotates -1.5°, the yellow greeting pill rotates -1°, the floating coins rotate between -12° and +20°. These tilts are what makes the system feel alive vs. corporate.

3. **The chunky 2px outline on illustrations and accent elements** — every illustrated character, blob, and floating coin has a literal-black 2-2.5px stroke. This is the visual identity. Don't replace with shadows or no-borders.

4. **The `font-feature-settings: "ss04", "ss11"` on body** — the alternate stylistic sets in Inter that mimic ABC Favorit. Without them, Inter feels generic.

5. **The blinking ticker dot** in the big-number band — `animation: blink 1.4s ease-in-out infinite`. Live, breathing UI.

6. **The chunky offset shadow without blur** — `Npx Npx 0 var(...)`, no spread, no blur. This is the Memphis/poster-design move. A blurred shadow would kill the brand instantly.

7. **The `_Subscriber sources_` bars are five different brand colors** — not one color in different opacities. The system loves rotating through its full palette in any given list.

---

## 6. Anti-patterns

Things that will break the look:

- **Don't use shadows for elevation.** The system uses borders and color planes. The only allowed shadows are the chunky offset variety (`Npx Npx 0 var(--something)` with no blur).
- **Don't use brand accent colors for body text.** Pink, yellow, lime, orange — all decorative fills only.
- **Don't deviate from pill (9999px) buttons** except for the primary CTA (which is 4px). Don't introduce 8px or 12px button radii.
- **Don't use Inter without the `ss04, ss11` features.** It looks generic without them.
- **Don't make secondary CTAs pink.** Pink is a brand accent, not an interactive state. Secondary CTAs are pill-shaped with subtle borders or are filled black-on-white.
- **Don't introduce gradients** except for: chart line area-fills (transparent gradient under a colored line) and avatar fills if you really need them.
- **In dark mode, don't use `--pitch-black` (off-white) as a button background.** That creates glaring white blocks against the dark canvas. Use `--creator-pink` for active/primary states instead.
- **Don't use plain underlines** for links inside running text. Either use a hover color change, or — if you need underlines — style them with `text-underline-offset: 3px; text-decoration-thickness: 1px;` for a more refined look.
- **Don't flatten the rotation on tilted elements.** The slight rotations on the pink stripe, yellow greeting pill, and floating coins are critical to the playful feel. If you copy a pattern, copy the rotation.
- **Don't use Title Case in mono labels.** Section eyebrows are ALL CAPS. Body copy is sentence case. Never mix.
- **Don't break hero headlines on periods.** Multi-sentence hero copy ("Save the good stuff. Share the great stuff.") flows as a single wrapping paragraph. Never insert `<br/>` after a sentence-ending period. The only `<br/>` allowed in a hero headline is the one positioning the pink-stripe word.

---

## 7. Quick decision tree

When implementing a new component:

1. **Is it a primary CTA?** → Solid black, 4px radius, 14×32px padding.
2. **Is it a secondary action?** → Pill-shaped (9999px) with pitch-black border or filled.
3. **Does it need a brand accent?** → Pink for emphasis, yellow for warmth/celebration, lime for "growth"/positive deltas, orange for negative deltas.
4. **Is it a card?** → 1px pitch-black border, 16px radius, 24-28px padding.
5. **Is it on an accent fill?** → Text MUST be `--pitch-black` (or `--on-accent` in dark mode).
6. **Does it need elevation?** → Bump it to a different surface (`--light-linen` → `--marketplace-gray` → accent fill). Don't add shadows.
7. **Does it need a "live" feel?** → Add a slight rotation (-2° to +2°), or use the blinking dot pattern.
8. **Is it data?** → Bars get `--sky-blue` fill + black stroke. Lines get pink stroke + double-stroke black overlay. End-points get colored dots with black outlines.

---

The 9-token system makes everything reskinnable. Compose from the component vocabulary above to fit the surface the brief asks for; remap the `:root` block to switch palettes without touching layout.
