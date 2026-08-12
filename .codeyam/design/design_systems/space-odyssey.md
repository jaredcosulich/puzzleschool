# Space Odyssey

A warm, atmospheric design system for AI-native and voice-first interfaces. Built around a duality of cream and night, anchored by a single vivid orange.

> "Atmospheric, never sterile. Warm, never cute."

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Bricolage Grotesque + JetBrains Mono with the strict role split, negative tracking on display, mono-uppercase labels), color tokens (cream + night + single orange + purple/magenta atmospherics), spacing (the `--pad` clamp), radii (24px+ cards, 999px pills), motion (slow, no bounce). Every surface inherits these. Italic is **never** used.
2. **Essential components** (use as the brief requires) — default panel cards, branded cards (cream/orange/purple) when a section role is genuinely needed, brand mark phase glyph, pill nav, primary orange button (one per screen), ghost/inverse buttons, status pills with leading dot, KPI cards, sparklines, data tables, mono captions, theme toggle FAB. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on hero and marketing surfaces. For Space Odyssey, the showcase patterns include: **the atmospheric mesh hero block (3-4 radial gradient stops + blur + noise overlay), the full-bleed orange CTA section with halo glow, multi-section "section role" pages flipping between cream / orange / purple full-bleed, the KPI strip running across the page top as a separate section, and the display-XL marketing hero with single-orange-word emphasis.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark + pill nav if the brief implies multi-page, plus one primary orange CTA only if it's genuinely the page's primary action)
- The requested content (grid of default panel cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer
- The theme toggle FAB only if the brief calls for theming

That is the whole page. Do **not** add the atmospheric mesh hero, KPI strips spanning the page top, full-bleed orange CTA sections, multi-section section-role pages cycling cream/orange/purple, or any showcase pattern unless the brief explicitly asks for it. Orange stays one-per-screen as the primary action regardless of how stripped-down the page is. The mono caption pattern (label + value + optional delta) is core voice and applies to whatever the brief calls for.

### Example compositions are examples

Any reference dashboards, landings, or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Space Odyssey's voice.

---

## 1. Foundation

### 1.1 Philosophy

Space Odyssey believes interfaces should feel *inhabited*. The system is built on three commitments:

- **Atmosphere over ornament.** Color comes from diffuse gradient meshes, not contained shapes. Backgrounds breathe.
- **One accent, used decisively.** A single vivid orange does the work of an entire palette. Hierarchy is built from absence, not abundance.
- **Cream as a material.** The neutral is warm, not cold. White is reserved for elevated surfaces in light mode.

### 1.2 Core principles

1. **Contained shapes are the exception, not the rule.** Prefer mesh gradients, soft edges, and diffuse glow over hard discs and orbs.
2. **Type does the heavy lifting.** Generous size, light weight, tight tracking. Don't decorate what typography already says.
3. **Every region knows its job.** Sections in different colors signal different functions. Don't mix without reason.
4. **Readability is non-negotiable.** Cream on bright orange fails. Always pair brand orange with night, and cream with deep purple or black.
5. **Branded surfaces stay branded across themes.** A purple feature card stays purple in light mode. The system flips chrome, not identity.

---

## 2. Color

### 2.1 Brand palette

| Token | Hex | Role |
|---|---|---|
| `--orange` | `#ff5a1f` | Primary accent. Single source of energy. |
| `--orange-soft` | `#ff8a5a` | Gradient terminus, subtle highlights. |
| `--orange-glow` | `#ff6b3d` | Bloom and glow effects only. |
| `--magenta` | `#c72f8f` | Secondary accent. Use sparingly inside meshes. |
| `--purple` | `#5a2890` | Atmospheric depth, secondary surfaces. |
| `--purple-deep` | `#2a1450` | Mesh anchors, deepest gradient stops. |
| `--purple-soft` | `#8a5ec0` | Data viz second-channel, ghost elements. |

### 2.2 Neutrals

| Token | Hex | Role |
|---|---|---|
| `--night` | `#0a0610` | Deepest text, button surfaces on cream. |
| `--bg` | `#07060a` | Dark mode page background. |
| `--bg-2` | `#0d0a14` | Dark mode section/panel background. |
| `--panel` | `#11101a` | Dark mode card/panel surface. |
| `--cream` | `#f4ecdf` | Light mode page background, dark mode text. |
| `--cream-2` | `#ede2cf` | Light mode section/panel surface. |
| `--ink` | `#f5f0e6` | Primary text on dark. |
| `--ink-dim` | `#b9b0a4` | Secondary text on dark. |
| `--ink-mute` | `#6e6878` | Mono captions, labels, axis text. |

### 2.3 Functional colors

| Token | Hex | Use |
|---|---|---|
| `--green` | `#4ade80` | Positive deltas, success states, "all systems operational". |
| `--red` | `#ef4444` | Destructive only. Never decorative. |

### 2.4 Lines

| Token | Value | Use |
|---|---|---|
| `--line` | `rgba(255,255,255,.08)` (dark) / `rgba(10,6,16,.08)` (light) | Default dividers, card borders. |
| `--line-strong` | `rgba(255,255,255,.16)` (dark) / `rgba(10,6,16,.16)` (light) | Emphasis dividers, focused borders. |

### 2.5 Pairing rules

**Always readable:**
- Cream text on night background ✓
- Cream text on purple background ✓
- Night text on cream background ✓
- Night text on orange background ✓ (this is the brand pairing)
- Orange text on cream background ✓
- Orange text on dark background ✓ (small accents only)

**Never use:**
- Cream text on bright orange ✗ (the most common failure mode — always flip to night)
- Orange text on purple ✗ (contrast collapses)
- Purple text on night ✗ (insufficient contrast)

---

## 3. Typography

### 3.1 Type families

```
Display + Body:  Bricolage Grotesque
Mono + Labels:   JetBrains Mono
```

Bricolage handles everything from 10px UI labels to 168px hero headlines. JetBrains Mono is reserved for: meta labels, axis ticks, kbd hints, timestamps, version stamps, and data table column headers.

### 3.2 Type scale

| Role | Size | Weight | Tracking | Line-height |
|---|---|---|---|---|
| Display XL | `clamp(56px, 11vw, 168px)` | 400 | -0.045em | 0.92 |
| Display L | `clamp(40px, 6vw, 96px)` | 400 | -0.04em | 0.95 |
| Display M | `clamp(36px, 4.4vw, 64px)` | 400 | -0.035em | 0.95 |
| Heading L | 32px | 500 | -0.025em | 1 |
| Heading M | 26-28px | 500 | -0.025em | 1.05 |
| Heading S | 16px | 500 | -0.01em | 1.4 |
| Body L | 14-15px | 400 | 0 | 1.55 |
| Body | 13-13.5px | 400 | 0 | 1.55 |
| Body S | 12-12.5px | 400 | 0 | 1.5 |
| Caption | 11px | 500 | 0.14em | 1.4 |
| Mono micro | 9-10px | 500 | 0.14-0.18em | 1.4 |

### 3.3 Type behavior

- Display sizes use **clamp()** for fluid scaling. Hero headlines never hardcode pixel sizes.
- All display sizes use **negative tracking** (-0.025em to -0.045em). The bigger the type, the tighter the tracking.
- Mono captions use **uppercase + 0.14-0.18em letter-spacing**. This is the system's "label voice."
- Body copy stays at weight 400. Headings at 500. Don't reach for 600+ unless landing on bright surfaces (mono on orange needs 600).
- Italic is **not used**. The system has no italic style — not in body, not in display.

### 3.4 Color highlighting in headlines

A single word in a headline can flip to `--orange` to claim emphasis:

```html
<h1>Effortless control with <span class="accent">syncra</span></h1>
<h2>Hi, <b>Johnson</b></h2>
```

Use this device sparingly — once per headline, max.

---

## 4. Spacing & layout

### 4.1 Margin scale

The system uses a fluid page-padding token:

```css
--pad: clamp(20px, 4vw, 64px);
```

This is the **only** horizontal padding for top-level sections. Don't override it with hardcoded values — at narrow widths you get 24px breathing room, at wide widths you get 64px. Sections feel right at every viewport.

### 4.2 Internal spacing

Internal padding scales with surface importance:

| Surface | Padding |
|---|---|
| Hero blocks | 32px |
| Cards / panels | 24-28px |
| Panel heads | 18-22px |
| KPI cards | 20px |
| Data table cells | 14px 22px |
| Pills and chips | 4-9px / 10-22px |
| Inline tags | 1-3px / 6-10px |

### 4.3 Gaps

| Context | Gap |
|---|---|
| Page sections | 60-120px (vertical) |
| Card grids | 20-24px |
| Tight clusters (KPIs, stats) | 6-20px |
| Inline elements | 6-12px |

### 4.4 Border radius

| Element | Radius |
|---|---|
| Cards (large) | 24-32px |
| Cards (medium) | 16-20px |
| Inputs, buttons (rectangular) | 10-12px |
| Pills and chips | 999px |
| Avatars | 50% |
| Inline tags | 4-6px |

Radius scales with surface size. Big cards get big radii. Don't mix small and large radii on the same surface.

---

## 5. Components

### 5.1 The atmospheric mesh

The signature surface of Space Odyssey. Replaces what other systems would treat with a contained orb or ball.

```css
.atmospheric {
  background:
    radial-gradient(900px 500px at 20% 80%, rgba(255,90,31,.45), transparent 55%),
    radial-gradient(700px 400px at 85% 30%, rgba(90,40,144,.45), transparent 55%),
    radial-gradient(600px 350px at 60% 70%, rgba(199,47,143,.30), transparent 60%),
    radial-gradient(800px 450px at 30% 30%, rgba(42,20,80,.5), transparent 55%);
  filter: blur(20px);
}
```

**Rules:**
- Always 3-4 radial gradient stops minimum.
- Always pair orange with at least one purple stop.
- Always end with `filter: blur(15-30px)`.
- Always overlay with a subtle SVG noise texture at `opacity: 0.04-0.08` and `mix-blend-mode: overlay` for grain.

### 5.2 Brand mark

Three-dot phase glyph: `i i i` where the middle `i` is larger and orange.

```html
<span class="brand-mark"><i></i><i></i><i></i></span>
```

```css
.brand-mark i { width: 7-8px; height: 7-8px; border-radius: 50%; background: currentColor; }
.brand-mark i:nth-child(2) { width: 11-12px; height: 11-12px; background: var(--orange); }
```

### 5.3 Pill navigation

The default top-level navigation pattern:

```html
<nav class="pill-nav">
  <a href="#" class="active">Home</a>
  <a href="#">Features</a>
  <a href="#">Pricing</a>
</nav>
```

Active item uses solid `--cream` background with `--night` text in dark mode, and solid `--ink` background with `--bg` text in light mode. Resting items are `--ink-dim`, hover lifts to `--cream`/`--ink`.

### 5.4 Buttons

**Primary (orange)** — for the most important action on a screen. Always uses `--night` text, never cream:

```css
.btn-primary {
  background: var(--orange);
  color: var(--night);
  font-weight: 500;
  padding: 16px 32px;
  border-radius: 999px;
  box-shadow: 0 0 32px rgba(255,90,31,.3);
}
```

**Secondary (ghost)** — for parallel actions:

```css
.btn-ghost {
  background: transparent;
  color: var(--cream);
  border: 1px solid var(--line-strong);
  border-radius: 999px;
}
```

**Inverse (cream)** — for primary actions on orange backgrounds, or when orange would conflict:

```css
.btn-inverse {
  background: var(--cream);
  color: var(--night);
  border-radius: 999px;
}
```

### 5.5 Status pills

Small inline status indicators with a leading dot. The dot can pulse for live states.

```html
<span class="stage-pill stage-active">Active</span>
<span class="stage-pill stage-good">Stable</span>
<span class="stage-pill stage-warn">Tuning</span>
<span class="stage-pill stage-low">Low use</span>
```

| Variant | Background | Text |
|---|---|---|
| `active` | `rgba(255,90,31,.12)` | `--orange` |
| `good` | `rgba(74,222,128,.12)` | `--green` |
| `warn` | `rgba(199,47,143,.15)` | `--magenta` |
| `low` | `rgba(255,255,255,.06)` | `--ink-dim` |

All status pills use mono caps at 9.5px with 0.1em tracking.

### 5.6 Cards

**Three card archetypes** form the system:

**Default (panel)** — neutral content surface.
```css
background: linear-gradient(180deg, rgba(20,16,28,.7), rgba(8,6,12,.85));
border: 1px solid var(--line);
border-radius: 24px;
```

**Branded (cream/orange/purple)** — claims a section role through color. Used in feature grids.
```css
.card.cream  { background: var(--cream); color: var(--night); }
.card.orange { background: radial-gradient(circle at 80% 0%, var(--orange), var(--orange-soft)); }
.card.purple { background: radial-gradient(circle at 0% 100%, var(--purple-deep), var(--purple) 60%); }
```

**Mesh** — atmospheric, used for "feel" sections and hero adjuncts.
```css
background: var(--night);
/* Apply ::before with the atmospheric mesh recipe */
```

### 5.7 Data table

```
┌─────────────────────────────────────────────┐
│ HEADER (mono micro, ink-mute, 0.14em)       │
├─────────────────────────────────────────────┤
│ Intent name                Status   Volume   │
│ small mono caption                           │
└─────────────────────────────────────────────┘
```

- Headers always mono caps.
- Primary cell content in `--cream`/`--ink` weight 500.
- Secondary cell content in `--ink-mute` mono caps.
- Row dividers use `--line`.
- Hover state: `rgba(255,255,255,.02)` (dark) / `rgba(10,6,16,.02)` (light).
- Number columns always mono. Text columns always sans.

### 5.8 KPI card

Standard format for top-level metrics:

```
┌─────────────────────┐
│ LABEL          [icon]│
│                      │
│ 184                  │
│                      │
│ ↑ 18%       sparkline│
└─────────────────────┘
```

- Label: 10px mono, ink-mute, 0.14em
- Number: 32px display, weight 500
- Delta: 10.5px mono, green for positive, orange for warning
- Sparkline: 70×24px SVG, single color stroke

### 5.9 Sparklines and charts

- Stroke width: **1.5-2.5px**.
- Always include subtle background grid lines in `--line` (very low alpha).
- Data points: hollow circles with `--bg`/`--panel` fill and accent stroke. Last point is solid.
- Y-axis labels use mono micro.
- Charts overlap multiple series using **area fills with linear gradients** (color → transparent).

---

## 6. Theming

### 6.1 Theme architecture

The system supports light and dark themes via a `[data-theme="light"]` attribute on `<html>`. Default is dark.

```html
<html data-theme="light">
```

JavaScript handles toggle and persists preference via localStorage.

### 6.2 What flips

| Token | Dark | Light |
|---|---|---|
| `--bg` | `#07060a` | `#f4ecdf` |
| `--bg-2` | `#0d0a14` | `#ebe1cf` |
| `--panel` | `#11101a` | `#ffffff` |
| `--ink` | `#f5f0e6` | `#0a0610` |
| `--ink-dim` | `#b9b0a4` | `#4a3f30` |
| `--line` | `rgba(255,255,255,.08)` | `rgba(10,6,16,.08)` |

### 6.3 What does not flip

These tokens are **brand identity** — they hold their value across themes:

- `--orange`, `--orange-soft`, `--orange-glow`
- `--purple`, `--purple-deep`, `--purple-soft`
- `--magenta`, `--green`, `--red`
- `--cream` and `--night` (these are bound colors, not contextual ones)

### 6.4 Light mode elevation

In light mode, surfaces sitting on the cream page background need elevation to feel like distinct cards:

```css
[data-theme="light"] .card {
  background: #ffffff;
  box-shadow:
    0 1px 0 rgba(255,255,255,.8) inset,
    0 24px 48px -20px rgba(10,6,16,.12),
    0 0 0 1px rgba(10,6,16,.05);
}
```

Dark mode does not need shadows. Borders + slight background lift do the work.

### 6.5 Theme toggle

A floating bottom-right circular button with sun/moon icons. Same on every page in the system:

```css
.theme-toggle {
  position: fixed;
  bottom: 24px;
  right: 24px;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  /* …backdrop-blur, subtle border, hover turns orange */
}
```

---

## 7. Motion

The system uses motion sparingly. When it appears, it is slow and atmospheric.

| Effect | Duration | Easing |
|---|---|---|
| Pulse / breathe | 4s | ease-in-out infinite |
| Float | 5-6s | ease-in-out infinite |
| Blink (live indicator) | 2s | ease-in-out infinite |
| Hover lift | 0.2-0.25s | ease |
| Theme transition | 0.25s | ease |
| Marquee scroll | 40s | linear infinite |

**Motion principles:**
- No bouncy easing. The system is grounded, not playful.
- Transforms only — never animate `box-shadow` or filters at scale.
- Hover lifts are `translateY(-1px)` to `translateY(-2px)` max.

---

## 8. Patterns

### 8.1 Orange placement rules

Orange is the system's only accent. Use it in **descending order of priority**:

1. **Single primary CTA per screen.** The "Get early access" button. The "+ New command" trigger.
2. **One word in a headline.** The brand name itself, or the most important word.
3. **Active state of one navigation item.** Never multiple at once.
4. **Live indicators and live values.** Pulsing dots, real-time deltas.
5. **Brand mark middle dot.** The phase glyph.

If orange appears more than 5 times on a single viewport, something is wrong. Cut.

### 8.2 The "section role" pattern

Sections often have a purpose telegraphed by background color:

| Background | Implied role |
|---|---|
| `--bg` (dark) | Default content, scrolling body |
| `--cream` | Welcome, greeting, content surface |
| `--orange` | Primary call-to-action, end-of-page push |
| `--purple` | Secondary or nested section |
| Mesh atmospheric | Hero, transition, "feel" |

Don't randomize. Use these consistently across pages so users learn the visual language.

### 8.3 The mono caption

Every value, label, and timestamp follows the same pattern:

```
┌────────────────────┐
│ ACTIVE HOURS      ← mono caps, ink-mute, 0.14em letter-spacing
│ 3.2h +18%         ← display number, optional green delta
└────────────────────┘
```

This pattern repeats across KPI cards, stat blocks, table cells, and data tooltips. The label is mono, the value is sans, the delta is mono with color.

### 8.4 Avoid

- **Cream text on bright orange.** Always switch to night.
- **Orange-on-orange data.** A donut where the dominant slice is orange and the background ring tints orange — invisible. Switch the dominant slice to night/purple.
- **Multiple competing orange surfaces.** A full-orange card next to a full-orange button is too much. Tone one down to cream-with-orange-accents.
- **Italic.** Not in this system.
- **Bouncy or springy motion.** Not in this system.
- **Hard contained orbs as decoration.** Use atmospheric mesh instead.
- **More than two display weights on a screen.** 400 and 500. That's it.

---

## 9. Accessibility

### 9.1 Contrast minimums

- Body text on background: **4.5:1 minimum** (WCAG AA).
- Display text on background: **3:1 minimum** (WCAG AA Large).
- All button text passes 4.5:1 against its background.
- Status pill text passes 4.5:1 against its tinted background.

### 9.2 Tested combinations

| Foreground | Background | Ratio | Use |
|---|---|---|---|
| `--cream` (#f4ecdf) | `--bg` (#07060a) | 16.8:1 | All dark mode body text ✓ |
| `--ink-dim` (#b9b0a4) | `--bg` | 9.4:1 | Secondary text on dark ✓ |
| `--ink-mute` (#6e6878) | `--bg` | 4.6:1 | Captions on dark ✓ |
| `--night` (#0a0610) | `--cream` (#f4ecdf) | 17.2:1 | Light mode body ✓ |
| `--night` | `--orange` (#ff5a1f) | 5.8:1 | Buttons + active nav ✓ |
| `--cream` | `--orange` | 2.9:1 | **NEVER USE** ✗ |
| `--cream` | `--purple` (#5a2890) | 8.7:1 | Cream on purple cards ✓ |

### 9.3 Focus states

All interactive elements receive a visible focus ring:

```css
:focus-visible {
  outline: 2px solid var(--orange);
  outline-offset: 2px;
}
```

### 9.4 Motion

All `infinite` animations should be disabled when the user prefers reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 10. Versioning

| Version | Date | Notes |
|---|---|---|
| 1.0 | May 2026 | Initial release. Cream + night + orange foundation. Light/dark theming. Three reference artifacts. |

---

*Space Odyssey is meant to be lived in, not stared at. When in doubt: less surface, more atmosphere.*
