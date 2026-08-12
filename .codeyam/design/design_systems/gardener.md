# Garden

A soft editorial design system for naturalist, wellness, and slow-tech interfaces. Garden sits between **luxury minimal** and **organic warmth**: sage cream surfaces, glassy depth-of-field gradients, lavender accents, and a typography pairing that mixes chunky display serifs with tracked uppercase grotesque.

The first expression of Garden is **Understory**, a houseplant tracker. Examples throughout reference Understory but the language is general; use Garden for any product where the tone should feel patient, lived-in, and editorial rather than industrial.

This document is everything Claude Code needs to reproduce Garden across new applications and views.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Instrument Serif + Bricolage Grotesque + DM Sans with the strict role split, including italic-word-in-headline pattern), color tokens, the body atmosphere (bokeh + grain), spacing, radii, motion. Every surface inherits these.
2. **Essential components** (use as the brief requires) — standard cards (white in light, dark green in dark), buttons (primary ink/cream pill + outlined secondary + filter pill), inputs, search pill, eyebrow + pulse dot, avatar stack, sticky blurred nav, toggle switch. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on marketing and hero surfaces. For Garden, the showcase patterns include: **the orb card (the signature 5-layer recipe), the verdure gauge (any variant), the gradient bar chart with dashed rows, the lavender accent card and warm bokeh card as feature surfaces, the floating-gauge hero, the italic pull quote, numbered feature rows (`01 / soft science` style), and the footer signature with massive italic two-word phrase ("well tended.", "slow grown.", etc.).** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark with mini-orb + wordmark, plus basic nav only if the brief implies it)
- The requested content (grid of standard cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer

That is the whole page. Do **not** add the orb card hero, the verdure gauge, the italic pull quote, numbered feature rows, the warm-bokeh callout cards, the italic footer signature, or any other showcase pattern unless the brief explicitly asks for it. The italic-word-in-headline trick is fine for any prominent heading the brief calls for; it's part of the core voice. The body atmosphere (bokeh + grain) always applies — it's the page surface, not a showcase moment.

### Example compositions are examples

Any reference dashboards (Understory, "Verdure" pages) or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Garden's voice.

---

## 1. Aesthetic Principles

- **Soft, not sterile.** Cream and sage surfaces over pure white in light mode. Deep forest greens (not black) in dark mode.
- **Depth via gradients, never shadows.** Cards lift through radial bokeh and conic light. Drop shadows appear only on the hero orb, primary buttons on hover, and phone mockups.
- **Typography does the heavy lifting.** Italic serif for emotional moments, chunky uppercase grotesque for structure, sans for body. Numbers are always serif.
- **Asymmetric mixed scales.** Bento grids with one statement card and supporting cards in pastel/muted. Big italic headlines paired with small all-caps eyebrows.
- **Organic, never rigid.** Pill buttons, 28px rounded cards, dashed dividers, soft 9-second floats.
- **One italic word.** Every brand wordmark and most H1s have exactly one italic word in the brand green (or lime, in dark mode). It's the signature move.

**Don'ts:** No drop shadows on cards. No hard borders. No purple-on-white SaaS gradients. No Inter, Roboto, or system fonts. No emoji-heavy UI; emoji is allowed as small punctuation. No stiff right angles. Pure black is not used; primary text is `#1A2E1F` (light mode) or `#F5F2E5` (dark mode).

---

## 2. Color Tokens

Garden uses the same semantic token names in both modes. Most components reference variables; specific overrides apply where intent inverts (e.g. high-contrast button surfaces).

### Light mode

```css
:root {
  /* surfaces */
  --bg: #E8E9DC;          /* sage cream — page */
  --bg-warm: #EFEEDF;     /* alt section */
  --card: #FFFFFF;        /* card surface */
  --cream: #F5F2E5;       /* used for text on dark green */

  /* ink */
  --ink: #1A2E1F;         /* primary text */
  --ink-soft: #4F5C4A;    /* secondary text */
  --ink-mute: #8A9285;    /* eyebrows, captions */
  --line: #DBDCCD;        /* dashed dividers, light borders */

  /* greens */
  --green-deep: #2F5234;  /* dark accent, focused buttons */
  --green: #6B8E5E;
  --green-glow: #98B576;  /* gradient mid-stop */
  --green-light: #B8D472; /* lime accent, active pills */

  /* accents */
  --lilac: #D4B5D8;
  --lilac-soft: #E5D0E8;
  --terracotta: #C97B5C;
}
```

### Dark mode

```css
:root {
  /* surfaces */
  --bg: #1F3826;          /* deep forest — page */
  --bg-warm: #243F2A;
  --card: #294532;        /* lifted card */
  --card-bright: #345030; /* most lifted */
  --cream: #F5F2E5;

  /* ink (cream becomes primary) */
  --ink: #F5F2E5;
  --ink-soft: rgba(245, 242, 229, 0.72);
  --ink-mute: rgba(245, 242, 229, 0.48);
  --line: rgba(245, 242, 229, 0.1);

  /* greens shifted lighter for dark contrast */
  --green-deep: #4D6E48;
  --green: #6B8E5E;
  --green-glow: #98B576;
  --green-light: #B8D472;

  /* accents */
  --lilac: #D4B5D8;
  --lilac-soft: rgba(212, 181, 216, 0.14);
  --terracotta: #E89B7C;
}
```

### Inversion rules

Some components carry semantic intent that doesn't survive a token flip. In those cases, use explicit values:

- **Primary button** (high contrast on page): in light, `bg: var(--ink); color: var(--bg)`. In dark, `bg: var(--cream); color: #1A2E1F`.
- **Active pill in product nav**: same flip. Light = ink pill, cream text. Dark = cream pill, near-black text.
- **Active toggle ON state**: `bg: var(--green-deep)` in light. In dark, since `--green-deep` shifted lighter, you can use `bg: #2F5234` explicitly to keep the deep saturation.
- **Toggle OFF track**: `#DCDCD0` in light, `#3D5840` in dark.
- **Featured "+2" avatar pill**: `bg: var(--bg)` in light works because `--bg` is light cream. In dark, use `bg: #345030` explicitly so it reads on the card.

When in doubt, ask: "is this element supposed to be the brightest thing on the page or the darkest?" If brightest, use cream. If darkest, use near-black or deep-green hex literals.

---

## 3. Typography

Three families, all from Google Fonts, loaded together:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,500;12..96,600;12..96,700&family=Instrument+Serif:ital@0;1&family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,600&display=swap" rel="stylesheet">
```

| Role | Font | Where |
|---|---|---|
| **Display** | Instrument Serif (italic preferred) | H1, H2, big numbers, brand mark, sign-offs ("well tended.") |
| **Structure** | Bricolage Grotesque 600/700 | Eyebrows (UPPERCASE 0.18em), card titles, button labels, nav |
| **Body** | DM Sans 400/500 | Body text, captions, axis labels |

### Type scale rules

- **Display headlines:** `clamp(56px, 9vw, 124px)`, line-height `0.95`, letter-spacing `-0.025em`. Always include one italic word in `--green-deep` (light) or `--green-light` (dark).
- **Big stat numbers:** Instrument Serif, 56–72px, letter-spacing `-0.025em`. Suffix units (h, °c, %) at 50–60% of the size in `--ink-mute`.
- **Eyebrows:** 11–12px, weight 600, letter-spacing `0.18–0.22em`, uppercase, color `--ink-mute` or accent green.
- **Body:** 14–16px, line-height 1.5, letter-spacing `-0.01em`.
- **Card headers (UPPERCASE):** 14px, weight 700, letter-spacing 0.08em.

---

## 4. Layout & Spacing

- **Page padding:** 48px desktop, 24px mobile.
- **Max width:** 1400px, centered.
- **Card radius:** 28px (containers), 18px (inner cards), 14px (buttons), 999px (pills).
- **Card padding:** 28px standard, 36px for feature cards, 56px for CTA cards.
- **Gap between cards:** 20px.
- **Bento grid:** 12 columns. Hero card spans 5, supporting card spans 7. Stat cards span 4. Stack on mobile.
- **Mobile breakpoint:** 980px.

---

## 5. Atmosphere

Two layers, applied to `body`. This is non-negotiable.

### Light mode

```css
body {
  background: var(--bg);
  background-image:
    radial-gradient(ellipse 80% 50% at 5% -10%, rgba(180, 200, 140, 0.32) 0%, transparent 50%),
    radial-gradient(ellipse 60% 60% at 95% 110%, rgba(212, 181, 216, 0.22) 0%, transparent 55%);
  background-attachment: fixed;
}

body::after {
  content: '';
  position: fixed; inset: 0;
  pointer-events: none;
  opacity: 0.05;
  z-index: 1;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 400 400' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='3'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
}
```

A lime bokeh top-left (5%, -10%), a lavender bokeh bottom-right (95%, 110%), plus 5% SVG noise grain. Page content sits at `z-index: 2` so it's above the grain.

### Dark mode

Same recipe, accents bumped to be visible on dark:

```css
body {
  background: var(--bg);
  background-image:
    radial-gradient(ellipse 80% 50% at 5% -10%, rgba(184, 212, 114, 0.14) 0%, transparent 55%),
    radial-gradient(ellipse 60% 60% at 95% 110%, rgba(212, 181, 216, 0.14) 0%, transparent 55%);
}
/* grain opacity bumps to 0.06 */
```

---

## 6. Signature Component: The Orb Card

The most distinctive component. A glassy depth-of-field card with multiple radial gradients on a forest green base.

```css
.orb-card {
  background:
    radial-gradient(ellipse 60% 50% at 25% 25%, rgba(220, 230, 180, 0.55) 0%, transparent 55%),
    radial-gradient(ellipse 50% 40% at 80% 75%, rgba(212, 181, 216, 0.32) 0%, transparent 50%),
    radial-gradient(ellipse 40% 30% at 60% 15%, rgba(255, 255, 255, 0.28) 0%, transparent 45%),
    radial-gradient(ellipse 70% 60% at 50% 100%, rgba(20, 40, 25, 0.35) 0%, transparent 55%),
    linear-gradient(135deg, #9CB079 0%, #4D6E48 50%, #345030 100%);
  color: var(--cream);
  border-radius: 28px;
  padding: 28px;
}
```

**Recipe (5 stacked layers on a `135deg` linear base):**
1. Cream/lime bokeh top-left (25%, 25%)
2. Lavender pocket bottom-right (80%, 75%)
3. White highlight upper-middle (60%, 15%)
4. Inset shadow at bottom (50%, 100%) for depth
5. Linear forest gradient base

This same recipe scales:
- 22px sphere = brand mark in nav (use simplified 2-layer version)
- 460px circle (with `filter: blur(0.5px)`) = floating hero orb (deprecated, replaced with gauge)
- Full card = the verdure dashboard card

---

## 7. Component Catalog

### Brand mark

A 22px sphere mimicking the orb card recipe in miniature.

```css
.brand-mark {
  width: 22px; height: 22px;
  border-radius: 50%;
  background:
    radial-gradient(circle at 30% 30%, rgba(255,255,255,0.5), transparent 50%),
    radial-gradient(circle at 70% 70%, var(--green-light), transparent 60%),
    linear-gradient(135deg, var(--green-glow), var(--green-deep));
  box-shadow: inset 0 0 0 1px rgba(255,255,255,0.2);
}
```

Used in `<div class="brand"><span class="brand-mark"></span><span>Word<em>mark</em></span></div>` where `em` is italic in green.

### Buttons

**Primary (high contrast, ink/cream pill):**

```css
.btn-primary {
  background: var(--ink);   /* light: dark on cream | dark: cream on dark */
  color: var(--bg);          /* (in dark mode, override to color: #1A2E1F) */
  padding: 15px 28px;
  border-radius: 999px;
  font-family: 'Bricolage Grotesque', sans-serif;
  font-weight: 600;
  font-size: 13px;
  letter-spacing: 0.02em;
  border: none;
  transition: transform 0.2s, box-shadow 0.2s;
}
.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 30px -8px rgba(26,46,31,0.4);
}
```

**Secondary (outlined):** transparent bg, 1px border `rgba(26,46,31,0.18)` in light or `rgba(245,242,229,0.22)` in dark.

**Filter pill (used inside card headers):** sage bg, small dark green icon square, dropdown chevron.

```html
<button class="pill-btn">
  <span class="ico"></span>
  Today ⌄
</button>
```

```css
.pill-btn {
  background: var(--bg);
  padding: 9px 16px 9px 12px;
  border-radius: 999px;
  font-family: 'Bricolage Grotesque', sans-serif;
  font-weight: 600;
  font-size: 12.5px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border: none;
}
.pill-btn .ico {
  width: 18px; height: 18px;
  background: var(--green-deep);
  border-radius: 5px;
}
```

On the orb card, swap pill bg to `rgba(255,255,255,0.14)` with `backdrop-filter: blur(8px)`.

### Cards (4 variants)

1. **Standard card:** `bg: var(--card); border-radius: 28px; padding: 28px;` (white in light, lifted dark green in dark)
2. **Orb card:** the signature 5-layer recipe above. Used for the main "hero" card in any view.
3. **Lavender accent:** `bg: var(--lilac-soft);` (solid lavender in light, translucent lavender in dark with `border: 1px solid rgba(212,181,216,0.18)`)
4. **Warm bokeh:** cream/sage gradient with lavender + lime accents, used for the "recent win" type cards.

```css
.warm-bokeh-card {
  background:
    radial-gradient(ellipse 60% 50% at 80% 30%, rgba(212, 181, 216, 0.3) 0%, transparent 55%),
    radial-gradient(ellipse 50% 40% at 20% 80%, rgba(184, 212, 114, 0.35) 0%, transparent 50%),
    linear-gradient(135deg, var(--cream), #EBE5D2);
}
/* Dark mode: shift base gradient to dark warm forest */
.warm-bokeh-card-dark {
  background:
    radial-gradient(ellipse 60% 50% at 80% 30%, rgba(212, 181, 216, 0.22) 0%, transparent 55%),
    radial-gradient(ellipse 50% 40% at 20% 80%, rgba(184, 212, 114, 0.22) 0%, transparent 50%),
    linear-gradient(135deg, #345030, #1F3826);
}
```

### Verdure Gauge (two variants)

A circular metric display: dashed outer ring, masked conic-gradient arc, marker dot, 60 ticks, inner disk with serif percentage and tracked label.

**Variant A: white lines on green background** (used inside the orb card on the dashboard):

```css
.gauge { width: 240px; height: 240px; position: relative; }
.gauge-ring {
  position: absolute; inset: 0;
  border-radius: 50%;
  border: 1.5px solid rgba(255, 255, 255, 0.16);
}
.gauge-arc {
  position: absolute; inset: 0;
  border-radius: 50%;
  background: conic-gradient(from 200deg, white 0deg 280deg, transparent 280deg 360deg);
  -webkit-mask: radial-gradient(circle, transparent 47.5%, black 48.5%, black 50%, transparent 51%);
  mask: radial-gradient(circle, transparent 47.5%, black 48.5%, black 50%, transparent 51%);
}
.gauge-dot {
  position: absolute;
  width: 14px; height: 14px;
  background: white;
  border-radius: 50%;
  top: 50%; left: -7px;
  transform: translateY(-50%);
  box-shadow: 0 0 0 5px rgba(255,255,255,0.18);
}
.gauge-tick-wrap { position: absolute; inset: 38px; border-radius: 50%; }
.gauge-tick {
  position: absolute;
  width: 1px; height: 5px;
  background: rgba(255,255,255,0.22);
  left: 50%; top: 0;
  transform-origin: 50% 82px; /* (240 - 76) / 2 */
}
.gauge-inner {
  position: absolute; inset: 38px;
  border-radius: 50%;
  background: rgba(40, 60, 40, 0.32);
  backdrop-filter: blur(4px);
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
}
.gauge-num { font-family: 'Instrument Serif', serif; font-size: 56px; color: white; line-height: 1; }
.gauge-label { font-family: 'Bricolage Grotesque', sans-serif; font-size: 10.5px; letter-spacing: 0.22em; text-transform: uppercase; color: rgba(255,255,255,0.78); margin-top: 8px; }
```

**Variant B: colored lines on cream/dark page** (used as a hero element). Same structure, recolored:

- Ring: `border: 1px dashed rgba(47, 82, 52, 0.2)` (light) or `rgba(245, 242, 229, 0.22)` (dark)
- Arc: conic gradient through brand greens. Light mode: `#C5DC8A` → `var(--green-glow)` → `var(--green-deep)`. Dark mode: `#C5DC8A` → `var(--green-light)` → `var(--green-glow)` (stay in lighter range so the deep end remains visible on dark bg).
- Mask thickness: bump to `47% / 50.5%` for slightly thicker lines.
- Dot: `var(--green-deep)` (light) or `var(--cream)` (dark).
- Ticks: low-opacity ink (light) or low-opacity cream (dark).
- Inner: no background; text floats on the page color.
- Number: `var(--green-deep)` (light) or `var(--cream)` (dark).

**Tick rendering JS** (60 marks, 6° apart):

```js
const tickWrap = document.getElementById('ticks');
for (let i = 0; i < 60; i++) {
  const t = document.createElement('div');
  t.className = 'gauge-tick';
  t.style.transform = `rotate(${i * 6}deg)`;
  tickWrap.appendChild(t);
}
```

For different gauge sizes, recompute `transform-origin: 50% Npx` where `N = (gauge-size - 2*inset) / 2`.

### Gradient Bar Chart

Pill-shaped bars on dashed dividers. Each bar is a horizontal gradient inside one of the three accent families (lime/green, lavender, mixed).

```html
<div class="chart-row">
  <span class="chart-date">28.06</span>
  <div class="chart-track">
    <div class="chart-bar" style="left: 18%; width: 22%;
         background: linear-gradient(90deg, #C5DC8A, #98B576);">
      <span class="bar-dot"></span>
    </div>
  </div>
</div>
```

```css
.chart-row {
  display: grid;
  grid-template-columns: 50px 1fr;
  gap: 16px;
  padding: 22px 0;
  border-bottom: 1px dashed var(--line);
}
.chart-bar {
  position: absolute;
  height: 28px;
  border-radius: 999px;
}
.bar-dot {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: white;
}
```

Standard gradient pairs:
- Lime: `#C5DC8A → #98B576`
- Mid green: `#B8D472 → #6B8E5E`
- Deep mix: `#C5DC8A → #4D6E48`
- Lavender: `#E5D0E8 → #C098C5`
- Lavender deep: `#D4B5D8 → #B292B7`

### Toggle Switch

Lavender thumb on green track when ON. Grey track with white/cream thumb when OFF.

```css
.toggle {
  width: 50px; height: 28px;
  background: var(--green-deep);  /* dark mode: #2F5234 explicit */
  border-radius: 999px;
  position: relative;
  cursor: pointer;
  transition: background 0.25s;
}
.toggle::after {
  content: '';
  position: absolute;
  width: 22px; height: 22px;
  border-radius: 50%;
  background: var(--lilac);
  top: 3px; right: 3px;
  transition: all 0.25s;
}
.toggle.off { background: #DCDCD0; }       /* dark: #3D5840 */
.toggle.off::after {
  background: white;                       /* dark: rgba(245,242,229,0.4) */
  right: auto; left: 3px;
}
```

### Task Row

Serif time, Bricolage title, body sub, avatar stack, toggle. Dashed top border.

```css
.task-row {
  display: grid;
  grid-template-columns: 80px 1fr auto auto;
  gap: 24px; align-items: center;
  padding: 22px 0;
  border-top: 1px solid var(--line);
}
.task-time {
  font-family: 'Instrument Serif', serif;
  font-size: 30px;
  letter-spacing: -0.02em;
  line-height: 1;
}
```

### Featured / Stats / Climate cards

Compact stat cards in the bento. Pattern: small eyebrow, big serif number, optional bar/sub.

- **Featured:** date block (month + day), avatar bubble, label + name. 56px lavender avatar.
- **Stats:** Instrument Serif number with smaller `<span>` unit suffix, optional segmented bar at bottom.
- **Climate:** stat number with right-aligned secondary metric (humidity %).

### Avatar Stack

Overlapping circles with 2px white (or card-colored) borders.

```css
.avatar-stack > * {
  width: 32px; height: 32px;
  border-radius: 50%;
  border: 2px solid white;        /* dark: 2px solid var(--card) */
  margin-left: -8px;
}
.avatar-stack > *:first-child { margin-left: 0; }
```

### Search Pill (product nav)

```css
.search-pill {
  display: flex; align-items: center; gap: 8px;
  background: var(--card);
  border: 1px solid rgba(26,46,31,0.08);    /* dark: rgba(245,242,229,0.08) */
  padding: 9px 14px;
  border-radius: 999px;
  width: 220px;
}
.kbd {
  font-family: 'Bricolage Grotesque', sans-serif;
  font-size: 10px;
  background: var(--bg);                    /* dark: var(--card-bright) */
  padding: 2px 6px;
  border-radius: 4px;
}
```

---

## 8. Mobile Components

### Phone frame

A 320 x 660px hardware shell with a 52px outer radius and a 44px inner-screen radius. Always include the dynamic island (100x28 pill at the top center) and a status bar.

```css
.phone {
  width: 320px; height: 660px;
  background: linear-gradient(135deg, #2A2A26 0%, #15150F 100%);
  border-radius: 52px;
  padding: 8px;
  box-shadow:
    0 40px 80px -20px rgba(20, 40, 25, 0.28),
    0 12px 24px -8px rgba(20, 40, 25, 0.14),
    inset 0 0 0 1px rgba(255,255,255,0.04);
  position: relative;
}
.screen {
  background: var(--bg);
  border-radius: 44px;
  height: 100%;
  overflow: hidden;
  display: flex; flex-direction: column;
}
.dynamic-island {
  position: absolute;
  top: 10px; left: 50%; transform: translateX(-50%);
  width: 100px; height: 28px;
  background: #000;
  border-radius: 999px;
  z-index: 20;
}
.status-bar {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 28px 8px;
  font-size: 13.5px; font-weight: 600;
  color: var(--ink);
}
```

### Mobile tab bar

4 tabs at the bottom, with the active tab's icon background filled in lime green. iOS home bar indicator at the bottom.

```css
.m-tabs {
  border-top: 1px solid rgba(26,46,31,0.06);
  background: rgba(232, 233, 220, 0.92);
  backdrop-filter: blur(12px);
  padding: 12px 24px 30px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  position: relative;
}
.m-tab.active .tab-icon-wrap {
  background: var(--green-light);
}
.tab-icon-wrap {
  width: 36px; height: 24px;
  border-radius: 999px;
  display: flex; align-items: center; justify-content: center;
}
.m-tabs::after {
  content: '';
  position: absolute;
  bottom: 8px; left: 50%; transform: translateX(-50%);
  width: 130px; height: 4px;
  background: var(--ink);
  border-radius: 2px;
}
```

### Mobile gauge

Same gauge structure scaled down. For a 160px gauge: inset 26px, transform-origin: 50% 54px, gauge-num font-size 38px.

### Mobile cards

- Card radius drops to 18px (from 28px on desktop).
- Padding 14–18px (from 28px).
- Use compact vertical rhythm (8px gaps between rows).

---

## 9. Patterns

- **Brand wordmark:** `Brand<em>name</em>` with `em` italic in `--green-deep` (light) or `--green-light` (dark). Same trick for headlines: one italic green word per H1.
- **Numbered features:** `01 / soft science`, `02`, `03`. Italic Instrument Serif numbers, italic descriptor after a slash. Sit above the feature title with 56px gap.
- **Eyebrow + pulse dot:** small `--green-light` dot with pulsing ring shadow, followed by all-caps eyebrow text. Use once per page section.
- **Italic pull quote:** centered, 30–52px Instrument Serif italic, attribution underneath in tracked uppercase grotesque prefixed with `·`.
- **Footer signature:** small eyebrow on the left with version + tagline; massive italic two-word phrase on the right (`well tended.`, `slow grown.`, `carry on.`).

---

## 10. Motion

- **Page entrance:** `fade` keyframe (opacity 0 → 1, translateY 8px → 0, 0.5s ease).
- **Hero gauge float:** translateY ±22px, scale 1 → 1.02, 9s ease-in-out infinite.
- **Pulse dot:** scale 1 → 1.15, 2.5s infinite.
- **Hover lifts:** `translateY(-1px)` for buttons, `translateY(-4px)` for feature cards.
- **Toggle:** `0.25s` background and thumb position transition.

Avoid spring physics, parallax scrolling, or anything jumpy. Motion in Garden is breathing, not bouncing.

---

## 11. Quick Component Inventory

For greppable lookup when extending the system:

- Page background (sage/forest + bokeh + grain)
- Sticky blurred nav (light or dark variant)
- Brand mark (mini orb)
- Hero with floating gauge
- Orb card (the signature 5-layer)
- Verdure gauge (white-on-green or colored-on-page)
- Gradient bar chart with dashed rows
- Pill filter buttons (default + glassy on green)
- Bento grid (12-col)
- Standard card (white/dark)
- Lavender accent card
- Warm bokeh card
- Stat card with serif number
- Featured plant row (date block + avatar + label)
- Task row (serif time + sans title + avatars + toggle)
- Italic pull quote
- Footer signature
- Phone frame + screen + dynamic island + status bar
- Mobile tab bar with iOS home indicator

Build new screens by composing from this inventory. Don't invent new component shapes; vary content and reuse the patterns.

---

## 12. Reproducing Garden

When asked to build a Garden interface in a new context:

1. Pick light or dark and paste the appropriate `:root` tokens.
2. Add the font import.
3. Apply body atmosphere (bokeh + grain).
4. Compose from the component catalog (section 7) using the spacing scale (section 4) to fit the surface the brief asks for. Don't impose a fixed page sequence; let the requested content drive structure.
5. Use the patterns in section 9 for headlines, numbering, quotes, and signoffs as needed.
6. The product/topic doesn't need to be plants; the language works for any patient, slow-tech, naturalist, or wellness domain. Substitute the metaphor (e.g. "Verdure" → "Pulse" → "Tide" depending on the subject).

The only thing that should never change: typography, spacing scale, and the orb card recipe. Those three define Garden. Surface structure is open.
