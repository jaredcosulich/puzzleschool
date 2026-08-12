# Postlark + Quires — Build Spec

A self-contained spec for the Postlark + Quires design system: tokens, type, components, and patterns for a slow-correspondence and editorial-analytics aesthetic. The system originates from a reference style called Gleap (crisp light canvas, soft rounded containers, single saturated accent). What follows is the adapted, theme-aware version.

The system applies across surfaces; structure should follow the brief, not a fixed template.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Bricolage Grotesque + Inter + IBM Plex Mono with the strict role split, including the italic-emphasis-with-skewed-accent-underline pattern), color tokens, the four swappable accent themes, spacing, radii (24px cards / 10px buttons / 0px outline buttons), shadows. Every surface inherits these.
2. **Essential components** (use as the brief requires) — paper-surface cards (24px radius, soft shadow), buttons (amethyst/dark/outline), pills & badges, eyebrow, pulse dot for live status, sparklines, basic nav, theme dock if the brief implies theming. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on hero and marketing surfaces. For Postlark + Quires, the showcase patterns include: **the letter paper with grid texture (the "physical letter" object), the envelope card with stamp + dashed border + postmark + accent rotation, the wax seal disc, the hero "moon" + "hill" radial atmosphere with drift animation, marketing display headlines with the italic-skewed-underline emphasis as a hero device, and the dashboard's sparkline-heavy KPI compositions when stacked as a section.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark + basic nav only if the brief implies it)
- The requested content (grid of paper-surface cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer
- The theme dock only if the brief calls for theming

That is the whole page. Do **not** add the rotated letter paper, envelope cards, wax seals, the moon/hill hero atmosphere, KPI strips, activity logs, or any showcase pattern unless the brief explicitly asks for it. The italic-with-skewed-underline emphasis is fine for whatever heading the brief calls for — it's part of the core voice, not a hero-only device.

### Example compositions are examples

Any reference Postlark landings or Quires dashboards shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Postlark's voice.

---

## Design tokens

### Colors (light mode, default)

| Token | Value | Role |
|---|---|---|
| `--color-cloud-canvas` | `#f5f2f0` | Page background |
| `--color-porcelain-surface` | `#ffffff` | Card/panel background |
| `--color-graphite-text` | `#333333` | Body text |
| `--color-ink-text` | `#000000` | Headlines, navigation |
| `--color-platinum-border` | `#d6d6d6` | Borders, dividers |
| `--color-silver-detail` | `#bcbcbc` | Muted helper text |
| `--color-deep-plum` | `#7b7b7b` | Tertiary text |
| `--color-amethyst-accent` | (theme-driven) | Primary action, decorative bg |
| `--color-sky-blue-highlight` | `#91e0ff` | Secondary highlight, in-content |
| `--color-on-accent` | `#000000` | Foreground on accent backgrounds |
| `--color-positive` | `#2d6a3a` | Up trends |
| `--color-negative` | `#a14a3e` | Down trends |

### Colors (dark mode)

Override at `body[data-mode="dark"]`:

| Token | Value |
|---|---|
| `--color-cloud-canvas` | `#1a1817` |
| `--color-porcelain-surface` | `#242120` |
| `--color-graphite-text` | `#d4d2cf` |
| `--color-ink-text` | `#ffffff` |
| `--color-platinum-border` | `#3a3735` |
| `--color-silver-detail` | `#5a5754` |
| `--color-deep-plum` | `#9a9794` |
| `--color-positive` | `#8fbf95` |
| `--color-negative` | `#d49991` |
| `--shadow-md` | `rgba(0, 0, 0, 0.5) 0px 8px 24px 0px` |
| `--shadow-subtle` | `rgba(0, 0, 0, 0.3) 0px 1px 2px 0px` |

### Theme accents (4 swappable)

Each scopes one variable: `--color-amethyst-accent`. Olive is the default.

| Theme | Value |
|---|---|
| Olive (default) | `#bcd49a` |
| Persimmon | `#ffc299` |
| Acid | `#dcfa78` |
| Butter | `#ffe186` |

The original Gleap reference accent was magenta `#f1ccff`; we replaced it because it read too sweet. The variable name `--color-amethyst-accent` is preserved for legacy reasons but the value is now driven entirely by the four swappable themes above.

### Spacing scale (4px base)

`8, 12, 16, 20, 24, 32, 40, 56, 60, 80, 88, 116, 160`

### Border radii

| Element | Value |
|---|---|
| Cards | `24px` |
| Buttons | `10px` |
| Badges/pills | `10px` |
| Large elements (hero panels, CTA strip) | `42px` |
| Outline buttons | `0px` (intentional break, see notes) |

### Shadows

| Token | Value |
|---|---|
| `--shadow-md` | `rgba(0, 0, 0, 0.04) 0px 8px 16px 0px` |
| `--shadow-subtle` | `rgba(16, 24, 40, 0.05) 0px 1px 2px 0px` |

### Layout

- Page max-width: `1200px` (landing), `1280px` (dashboards)
- Section gap: `30-80px` depending on density
- Card padding: `24-40px`
- Element gap: `16px`

---

## Typography

Three families, each with a clear job. Loaded from Google Fonts in one `<link>`.

```html
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400..700&family=Inter:wght@400;500;600&family=IBM+Plex+Mono:ital,wght@0,400;0,500;1,400&display=swap" rel="stylesheet">
```

### Font roles

| Family | Variable | Role |
|---|---|---|
| Bricolage Grotesque (variable, opsz 12-96) | `--font-display` | Display headlines, section titles, KPI numbers, table ranks. Modern grotesque with personality. Optical sizing automatically adjusts the cut. |
| Inter | `--font-body` | All body text, UI labels, navigation, buttons. |
| IBM Plex Mono | `--font-mono` (or `--font-hand` in Postlark) | Letter content, data values, axis labels, table cells, percentages, deltas, timestamps. Use `font-feature-settings: "tnum"` on numeric cells. |

### Italic emphasis pattern

Bricolage doesn't ship a true italic, so `<em>` renders as a synthesized oblique. To make emphasis feel intentional rather than weak, every `<em>` in display headlines gets a colored skewed underline:

```css
h1 em {
  font-style: italic; /* synthesized oblique */
  position: relative;
}
h1 em::after {
  content: "";
  position: absolute;
  left: 4%; right: 4%;
  bottom: 4-6px;
  height: 10-14px;
  background: var(--color-amethyst-accent);
  z-index: -1;
  border-radius: 3-4px;
  transform: skewX(-4deg);
  transition: background 400ms ease;
}
```

This treatment is the visual signature of the system. It appears in: hero headlines, section titles, dashboard greetings, mobile titles, KPI labels.

### Mono sizing rules

IBM Plex Mono renders visually larger than Inter at the same px size. Bring mono content down 2-3px from where you'd intuitively set it. Concrete sizes that work:

- Letter body (landing): `14px`, `line-height: 1.95`
- Letter body (mobile): `11px`, `line-height: 1.95`
- Envelope greeting: `15px` (landing), `13px` (mobile)
- Envelope subtitle line: `11px` (landing), `10px` (mobile)
- Compose textarea: `11px`
- Table cells, axis labels, KPI deltas: `11-12px`
- Sparkline data callouts in tooltips: `11px` mono

### Display sizing

| Use | Size |
|---|---|
| Hero display | `clamp(44px, 7vw, 78px)` |
| Section title | `clamp(36px, 5vw, 56px)` |
| Card heading | `28-32px` |
| KPI number | `36-44px` |
| Subheading | `20px` |

---

## Component patterns

### Buttons

Three variants, all from the same `.btn` base. Outline button intentionally breaks the soft-rounded system with `border-radius: 0` (per the original Gleap spec).

```css
.btn-amethyst { /* primary CTA */
  background: var(--color-amethyst-accent);
  color: var(--color-on-accent);
  border-radius: 10px;
  padding: 11-14px 18-22px;
}
.btn-dark { /* affirmative / nav CTA */
  background: var(--color-ink-text);
  color: var(--color-porcelain-surface);
  border-radius: 10px;
}
.btn-outline { /* secondary, sharp corners */
  background: transparent;
  color: var(--color-ink-text);
  border: 1px solid var(--color-ink-text);
  border-radius: 0;
  padding: 14-17px 20-22px;
}
```

### Cards

```css
.card {
  background: var(--color-porcelain-surface);
  border-radius: 24px;
  padding: 24-40px;
  box-shadow: var(--shadow-md);
}
```

### Pills / badges

```css
.pill {
  font-size: 10-11px;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 2-5px 8-12px;
  border-radius: 10px;
  border: 1px solid var(--color-platinum-border);
  background: var(--color-cloud-canvas);
}
.pill.live { background: var(--color-amethyst-accent); border-color: transparent; }
```

### Eyebrow

```css
.eyebrow {
  font-size: 11-13px;
  text-transform: uppercase;
  letter-spacing: 0.14-0.18em;
  color: var(--color-deep-plum);
  font-weight: 500;
}
```

### Pulse dot (live status)

Animated indicator next to "live" / "new" labels. Pulse uses `color-mix` for the halo so it follows the active theme.

```css
.pulse-dot {
  width: 6-7px; height: 6-7px;
  border-radius: 50%;
  background: var(--color-amethyst-accent);
  box-shadow: 0 0 0 4px color-mix(in srgb, var(--color-amethyst-accent) 28%, transparent);
  animation: pulse 2s ease-in-out infinite;
}
@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 4px color-mix(in srgb, var(--color-amethyst-accent) 28%, transparent); }
  50%      { box-shadow: 0 0 0 7px color-mix(in srgb, var(--color-amethyst-accent) 8%, transparent); }
}
```

### Letter paper

Cream paper (`#fefcf8`) with a square grid texture as background. No horizontal ruled lines, no vertical margin line.

```css
.letter-paper {
  background: #fefcf8;
  border-radius: 24px;
  padding: 48px 44px;
  box-shadow: var(--shadow-md);
  transform: rotate(-1.5deg); /* landing only */
  position: relative;
  overflow: hidden;
}
.letter-paper::after {
  content: "";
  position: absolute; inset: 0;
  background-image:
    repeating-linear-gradient(0deg,  transparent, transparent 23px, rgba(214, 214, 214, 0.4) 24px),
    repeating-linear-gradient(90deg, transparent, transparent 23px, rgba(214, 214, 214, 0.4) 24px);
  pointer-events: none;
}
```

Use 24px grid on landing, 20px grid on mobile (tighter to suit smaller paper). Body text inside the paper uses IBM Plex Mono.

A `.hl` span gets the Sky Blue highlight: `background: var(--color-sky-blue-highlight); padding: 0 3-4px;`

### Envelope

Mock envelope card, rotated, with: dashed-border stamp in the active accent, stamp glyph is italic Bricolage "P", a postmark circle in the corner, IBM Plex Mono content.

```css
.envelope {
  background: var(--color-porcelain-surface);
  border-radius: 24px;
  padding: 28px;
  box-shadow: var(--shadow-md);
  transform: rotate(-3deg to -8deg);
}
.stamp {
  width: 56px; height: 64px;
  background: var(--color-amethyst-accent);
  border-radius: 6px;
  border: 2px dashed rgba(0,0,0,0.12);
  display: grid; place-items: center;
  font-family: var(--font-display);
  font-style: italic;
  font-size: 22px;
  color: var(--color-ink-text);
}
.postmark {
  width: 70px; height: 70px;
  border: 2px solid rgba(0,0,0,0.55);
  border-radius: 50%;
  font-family: var(--font-body);
  font-size: 9px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  transform: rotate(-12deg);
  /* "Postlark · 04 · 29" content */
}
```

### Wax seal

Disc with italic "P" rotated `-6deg`. Uses inset shadow to read as 3D wax.

```css
.wax {
  width: 56px; height: 56px;
  background: var(--color-amethyst-accent);
  border-radius: 50%;
  font-family: var(--font-display);
  font-style: italic;
  font-size: 24px;
  box-shadow: inset rgba(0,0,0,0.08) 0 -4px 8px;
  transform: rotate(-6deg);
}
```

### Theme dock (fixed, bottom-right)

Pill containing: sun/moon mode toggle, divider, "Accent" label, four accent swatches.

```html
<div class="theme-dock">
  <button class="mode-toggle">[sun + moon SVGs, one hidden by mode]</button>
  <div class="dock-divider"></div>
  <span class="label">Accent</span>
  <div class="swatch active" data-theme="olive"></div>
  <div class="swatch" data-theme="persimmon"></div>
  <div class="swatch" data-theme="acid"></div>
  <div class="swatch" data-theme="butter"></div>
</div>
```

JS: clicking a swatch sets `document.body.dataset.theme = ...`; clicking the mode toggle flips `document.body.dataset.mode` between `light` and `dark`.

### Sparkline (inline SVG)

Hand-rolled, no library. Always 80x24, accent-colored when trending up, deep-plum when flat, negative-color when down. End point gets a 2px filled circle.

```html
<svg width="80" height="24" viewBox="0 0 80 24">
  <path d="M0 18 L11 16 L23 17 L34 13 L46 11 L57 12 L69 6 L80 4"
        stroke="var(--color-amethyst-accent)" stroke-width="1.6"
        fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="80" cy="4" r="2" fill="var(--color-amethyst-accent)"/>
</svg>
```

### Hero atmosphere

Soft "moon" radial gradient (top-right, accent-driven via `color-mix`) + "hill" radial gradient (bottom-left, sky-blue-driven) + SVG fractal noise grain overlay. Moon drifts on a 12s loop.

```css
.moon {
  background: radial-gradient(circle at 35% 35%,
    var(--color-amethyst-accent) 0%,
    color-mix(in srgb, var(--color-amethyst-accent) 60%, white) 40%,
    var(--color-cloud-canvas) 75%);
  filter: blur(8px);
  animation: drift 12s ease-in-out infinite;
}
```

---

## Theme switching mechanics

The whole point: every accent surface in the entire app must respond when the theme changes. Hardcoded magenta/lilac values must be replaced with `color-mix` derivations from `--color-amethyst-accent` so they shift cleanly when the variable updates.

Concrete examples in the codebase:

```css
/* Pulse halo */
box-shadow: 0 0 0 4px color-mix(in srgb, var(--color-amethyst-accent) 28%, transparent);

/* Atmospheric halo behind featured cards */
background: radial-gradient(circle, color-mix(in srgb, var(--color-amethyst-accent) 50%, transparent), transparent 70%);

/* Featured pricing card glow */
box-shadow: color-mix(in srgb, var(--color-amethyst-accent) 50%, transparent) 0 16px 32px;

/* Letter margin (deprecated, removed) was: */
background: color-mix(in srgb, var(--color-amethyst-accent) 60%, transparent);
```

Any element whose visual rests on the accent color must use either `var(--color-amethyst-accent)` directly or a `color-mix` of it. Never hardcode a tint.

---

## Dark mode behavior

Triggered by `body[data-mode="dark"]`. Pure token swap on most elements, except:

### Surfaces that stay light in dark mode

These represent **physical objects** in the metaphor (paper, envelopes, the highlighted pricing tier as a "premium card"). They scope token overrides back to light values inside their selector:

```css
body[data-mode="dark"] .letter-paper,
body[data-mode="dark"] .envelope,
body[data-mode="dark"] .price-card.featured {
  --color-ink-text: #000000;
  --color-graphite-text: #333333;
  --color-deep-plum: #7b7b7b;
  --color-platinum-border: #d6d6d6;
  --color-silver-detail: #bcbcbc;
}
```

### CTA strip

The landing CTA strip uses `var(--color-ink-text)` as background (black in light → white in dark, which breaks the design). Force it to a near-black `#0d0c0b` in dark mode so it stays a "press-here" pop block.

### Phone bezels

In dark mode the dark phone disappears into the dark canvas. Add an inner ring + outer hairline:

```css
body[data-mode="dark"] .phone {
  background: #2a2828;
  box-shadow:
    0 30px 60px -20px rgba(0, 0, 0, 0.6),
    0 18px 36px -18px rgba(0, 0, 0, 0.5),
    inset 0 0 0 1.5px #3d3d3d,
    0 0 0 1px rgba(255, 255, 255, 0.06);
}
```

### Trend pills (Quires)

Hardcoded green/red backgrounds need alpha-tinted dark-mode versions:

```css
body[data-mode="dark"] .kpi-delta {
  background: rgba(143, 191, 149, 0.1);
  border-color: rgba(143, 191, 149, 0.3);
  color: #8fbf95;
}
```

### Dark-mode chart "now" tooltip (Quires)

The chart uses `var(--color-ink-text)` for the floating tooltip rect. In dark mode that flips to white, which is wrong. Pin it back:

```css
body[data-mode="dark"] .chart-svg rect[fill="var(--color-ink-text)"] { fill: #0d0c0b; }
body[data-mode="dark"] .chart-svg circle[fill="var(--color-ink-text)"] { fill: #ffffff; }
```

### Glyph color on accent backgrounds

Anything with an accent background (wax seal, "Live" pills, FAQ open toggle, accent feed icons) needs `color: #000000` forced in dark mode, since `--color-on-accent` is defined as `#000000` for light readability against the pastel accents and that holds in dark mode too.

---

## Implementation rules / learned constraints

These are the things we tuned through iteration. Skipping them produces a draft that looks 90% right but reads off.

### Mono content always smaller than feels natural
IBM Plex Mono renders visually larger than a sans at the same px size. Drop letter body and envelope content by 2-3px from where you'd intuitively set it. Do not deviate from the sizes given above without testing.

### Grid texture, not ruled lines, no margin
The letter paper uses a square grid (24px on landing, 20px on mobile). No horizontal-only ruled lines (reads like a school worksheet). No vertical margin line on the left (was `color-mix` of accent at 60%, removed because it competed with the grid).

### Outline buttons keep `border-radius: 0`
Per the original Gleap spec. It's the only place the soft-rounded system breaks. Don't "fix" it.

### Tabular figures
Anything with numbers that align in columns (table cells, KPI numbers, axis labels) needs:
```css
font-family: var(--font-mono);
font-feature-settings: "tnum";
```

### `color-mix` everywhere accent is tinted
Hardcoded RGBA tints (e.g. the original `rgba(241, 204, 255, 0.5)` magenta halos) break theme switching. Always use:
```css
color-mix(in srgb, var(--color-amethyst-accent) X%, transparent)
```

### Italic emphasis needs the underline
Bricolage's synthesized italic alone is too subtle on display sizes. The skewed accent underline behind every `<em>` is what carries the editorial register and ties everything to the active theme.

### Dark mode physical metaphor
Letter paper, envelopes, wax seals, and the featured pricing card stay light in dark mode. They are physical objects on a dark desk, not screens. Achieved by re-scoping the light tokens inside those selectors when `body[data-mode="dark"]` is set.

### Phone bezels need help in dark mode
Dark phone on dark canvas disappears. Bump bezel to `#2a2828` and add an inner `#3d3d3d` ring + a 1px outer white-alpha hairline.

### Default state
Both dark/light pages default to **light mode**. Don't auto-detect `prefers-color-scheme` unless the user asks for it. The toggle is right there.

### No em-dashes
Replace any em-dash with a comma, semicolon, or "—" with hyphens-and-context. This applies to all generated copy, headlines, microcopy, and tooltips.

---

## Tech stack

- Plain HTML, CSS, and minimal vanilla JS
- No frameworks, no build step, no bundler
- One Google Fonts link per file
- All tokens declared once at `:root`, themed at `body[data-theme="..."]` and `body[data-mode="dark"]`
- All interactive state via `data-*` attributes on `<body>` (theme, mode) or class toggles (active nav, open FAQ)

---

When applying the system across multiple files, copy the `:root`, theme blocks, dark-mode overrides, and theme-dock markup verbatim between files. The design system lives in exactly one place per file but is identical across files.
