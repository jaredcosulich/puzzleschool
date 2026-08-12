# Ethereal

A design system for soft, dreamy, atmospheric interfaces. Built around gradient orbs, iridescent washes, and a deliberate split between mono UI and sans editorial.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Schibsted Grotesk + JetBrains Mono with the strict role split), color tokens, the static-ink contract on gradient surfaces, spacing, radii, motion. Every surface inherits these.
2. **Essential components** (use as the brief requires) — paper/surface cards, bracketed primary CTAs (the brand voice), mono labels with status dots, ghost buttons, inputs, mode toggle. The everyday vocabulary needed to render almost any page. Bracketed CTAs and mono labels are part of the brand voice and belong on every page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on marketing and hero surfaces. For Ethereal, the showcase patterns include: **gradient orbs as hero elements, the orb cluster, full-card iridescent / aurora / warm / cool / dusk gradient surfaces, the soft bar chart, large editorial display headlines with single-word color emphasis, and "night sky" hero compositions.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark with mini-orb, plus basic nav only if the brief implies it)
- The requested content (grid of paper cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer

That is the whole page. Do **not** add hero sections with marketing copy, KPI/stat strips, activity feeds (timelines), release-note bands, pull quotes, gradient orb clusters, atmospheric mesh hero blocks, or any showcase pattern unless the brief explicitly asks for it. A simple listing should sit on the paper surface with paper cards — the gradient atmospheres only appear when the brief calls for a hero or feature moment.

### Example compositions are examples

Any reference dashboards, showcases, or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it Ethereal's voice.

---

## Philosophy

**Atmosphere over ornament.** Ethereal is not minimal. It is *spacious*. The page breathes, the gradients drift, the orbs hover. Every screen should feel like the morning light through a north-facing window: soft, clean, full of possibility.

Three rules govern the system:

1. **Gradients are content, not background.** A gradient orb is a hero element with the same weight as a headline. Never use gradients as filler texture behind dense UI.
2. **Mono is the voice of the product, sans is the voice of the brand.** In-app UI, labels, timers, and CTAs use a technical mono. Marketing pages, editorial headlines, and long-form body use a refined geometric sans.
3. **Bracketed actions.** Primary actions are wrapped in literal brackets, like `[Begin]` or `[Listen]`. This is the system's signature.

---

## Color

Ethereal uses a warm off-white paper as its base in light mode, and a deep indigo "night sky" paper in dark mode. The pastel gradients are *identical* across modes — they read as pigment on paper in light mode and as luminous nebulae against deep space in dark mode. This is the system's central trick.

Surfaces stack: paper at the page level, surface on cards, gradients on hero/feature elements.

### Surface tokens

| Token | Light | Dark |
|---|---|---|
| `--paper` | `#F6F5F2` | `#0B0D14` |
| `--paper-cool` | `#F2F4F7` | `#0E101A` |
| `--surface` | `#FFFFFF` | `#161826` |
| `--surface-tint` | `#FAFAF8` | `#1A1D2C` |
| `--hairline` | `rgba(20, 22, 31, 0.06)` | `rgba(255, 255, 255, 0.06)` |
| `--hairline-strong` | `rgba(20, 22, 31, 0.12)` | `rgba(255, 255, 255, 0.14)` |

### Ink tokens

| Token | Light | Dark | Usage |
|---|---|---|---|
| `--ink` | `#14161F` | `#F0EFEA` | Primary text, headlines |
| `--ink-soft` | `#5A5F6E` | `#A8ACBA` | Body copy, secondary text |
| `--ink-faint` | `#9CA0AC` | `#6A6E7E` | Tertiary text, metadata |
| `--ink-ghost` | `#C8CBD3` | `#3A3D4D` | Disabled, very low-emphasis |

### Static ink (do not flip)

For text that sits on a pastel gradient surface (warm/cool/iridescent cards, dusk phone backgrounds, aurora footer), use the static ink tokens. These never flip — the gradients themselves don't change between modes, so their text shouldn't either.

| Token | Value |
|---|---|
| `--ink-static` | `#14161F` |
| `--ink-static-soft` | `rgba(20, 22, 31, 0.7)` |
| `--ink-static-faint` | `rgba(20, 22, 31, 0.5)` |

### Gradient tokens (mode-agnostic)

The heart of Ethereal. Each gradient is a *named atmosphere*, not a list of stops. Identical in light and dark.

**Cool** — calm, technical, focused
```css
linear-gradient(135deg, #C8C1FA 0%, #B5CBEA 50%, #ECEAE7 100%)
```

**Warm** — welcoming, human, optimistic
```css
linear-gradient(135deg, #F9DEDC 0%, #FFD9E3 50%, #FAE4EC 100%)
```

**Iridescent** — magical, AI-forward, the brand moment
```css
linear-gradient(135deg, #A8D5BA 0%, #B5CBEA 33%, #C8C1FA 66%, #FFD9E3 100%)
```

**Aurora** — dramatic poster gradient (top-down, vertical)
```css
linear-gradient(180deg, #B5CBEA 0%, #C8C1FA 50%, #FFD9E3 80%, #B5CBEA 100%)
```

**Dusk** — used for emotive states
```css
linear-gradient(180deg, #ECEAE7 0%, #FFD9E3 40%, #E2A8A8 100%)
```

### Functional accents

| Token | Light | Dark | Usage |
|---|---|---|---|
| `--accent` | `#6B7AC4` | `#9AA8E8` | Brand blue, links |
| `--status-live` | `#E15A5A` | `#FF6B6B` | Recording dot, live indicators |
| `--status-ok` | `#5BA88E` | `#6BC4A0` | Success, mint check marks |

### Button tokens

The primary button **inverts** between modes — dark pill in light, cream pill in dark. This keeps the primary action a strong contrast moment in both.

| Token | Light | Dark |
|---|---|---|
| `--btn-primary-bg` | `#14161F` | `#F0EFEA` |
| `--btn-primary-fg` | `#F6F5F2` | `#14161F` |

### Color rules

- **Never** use a gradient as a background behind dense UI text. Gradients live in cards, orbs, hero blocks, never under a paragraph.
- **Never** mix more than one named gradient on a single screen (showcase / sample contexts excepted).
- **Always** keep at least 60% of any screen as paper or surface. Gradients are accents.
- **Always** use static ink tokens for text on pastel gradient surfaces. The gradients don't flip between modes, so the text on them mustn't either.

---

## Typography

Two families. Strictly enforced roles.

### Display & body — Schibsted Grotesk

Used for editorial headlines, marketing pages, and long-form body copy. A modern neo-grotesque with subtle warmth.

```html
<link href="https://fonts.googleapis.com/css2?family=Schibsted+Grotesk:wght@400;500;600;700;900&display=swap" rel="stylesheet">
```

| Role | Size / Line | Weight | Tracking |
|---|---|---|---|
| `display-xl` | 96px / 0.95 | 600 | -0.04em |
| `display-l` | 64px / 1.0 | 600 | -0.03em |
| `display-m` | 44px / 1.05 | 500 | -0.025em |
| `headline` | 28px / 1.15 | 500 | -0.02em |
| `body-l` | 18px / 1.5 | 400 | -0.01em |
| `body` | 15px / 1.55 | 400 | 0 |

### UI & technical — JetBrains Mono

Used for product UI, labels, timers, status indicators, and bracketed CTAs. The system's voice when speaking to users mid-task.

```html
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
```

| Role | Size / Line | Weight | Treatment |
|---|---|---|---|
| `mono-label` | 11px / 1.2 | 500 | UPPERCASE, +0.12em tracking |
| `mono-ui` | 13px / 1.4 | 400 | Default mono UI text |
| `mono-cta` | 14px / 1.0 | 500 | Used inside `[brackets]` |
| `mono-stat` | 32px / 1.1 | 500 | Large numerical readouts |

### Typography rules

- **Never** mix mono and sans inside the same paragraph. They live in different layers.
- **Always** wrap primary CTAs in literal brackets: `[Begin]`, `[Listen]`, `[Continue]`.
- **Always** use mono for timers, durations, version numbers, and status labels.
- **Never** use sans for in-app navigation labels. Mono only.

---

## Spacing & layout

A 4px base unit. Generous on all axes — Ethereal needs room to breathe.

```
--space-1: 4px
--space-2: 8px
--space-3: 12px
--space-4: 16px
--space-5: 24px
--space-6: 32px
--space-7: 48px
--space-8: 64px
--space-9: 96px
--space-10: 128px
```

**Section padding** is always at least `--space-8` (64px) vertical. Hero sections use `--space-10` (128px).

---

## Radius

```
--radius-sm: 8px      (small chips, tags)
--radius-md: 14px     (inputs, small cards)
--radius-lg: 24px     (default card)
--radius-xl: 32px     (hero cards, mobile screens)
--radius-pill: 9999px (buttons, badges)
```

The default card radius is `24px`. Pill buttons are full-radius. Mobile screen frames use `32px` (mimicking real device corners).

---

## Elevation

Shadows are *whispered*, never declared. Two levels.

```css
--shadow-soft:
  0 1px 2px rgba(20, 22, 31, 0.04),
  0 8px 24px rgba(20, 22, 31, 0.04);

--shadow-card:
  0 1px 2px rgba(20, 22, 31, 0.05),
  0 12px 40px rgba(20, 22, 31, 0.06);
```

In dark mode, shadows are deeper and more spread to compensate for the lower base brightness:

```css
[data-theme="dark"] {
  --shadow-soft:
    0 1px 2px rgba(0, 0, 0, 0.3),
    0 8px 24px rgba(0, 0, 0, 0.2);
  --shadow-card:
    0 1px 2px rgba(0, 0, 0, 0.3),
    0 12px 40px rgba(0, 0, 0, 0.25);
}
```

Note: gradient orbs do **not** carry a shadow. They're atmospheres, not objects.

---

## Motifs

The four visual signatures of Ethereal.

### 1. Gradient Orb

A soft, multi-stop radial gradient cloud. No hard edges, no specular highlight, no drop shadow — they read as atmospheres rather than objects. Built from four to five overlapping radial gradients with transparency, then blurred 1–2px for softness.

```css
.orb {
  width: 240px;
  height: 240px;
  border-radius: 50%;
  background:
    radial-gradient(circle at 35% 30%, #A8D5BA 0%, transparent 55%),
    radial-gradient(circle at 70% 30%, #B5CBEA 0%, transparent 55%),
    radial-gradient(circle at 75% 75%, #C8C1FA 0%, transparent 55%),
    radial-gradient(circle at 30% 75%, #FFD9E3 0%, transparent 55%),
    radial-gradient(circle at 50% 50%, #ECEAE7 0%, transparent 40%);
  filter: blur(2px);
}
```

Variants: `iridescent` (full multi-color), `cool` (lavender + blue + cream), `warm` (pink + cream), `mint` (green + blue + cream). The same orbs appear identical in light and dark mode — in dark, the deep paper turns them into glowing nebulae.

### 2. Mono label with status dot

The system's way of timestamping or framing a screen.

```
● 00:30   INTERSTELLAR
```

A 6px dot (status color) followed by a mono label (uppercase, tracked). Used at the top of cards, screens, and sections.

### 3. Bracketed CTA

```
[Listen]   [Begin]   [Continue →]
```

Pill-shaped, 56px tall, full-radius. Filled with `--ink` for primary, transparent with `--ink` border for secondary. Always mono, always bracketed.

### 4. Soft bar chart

Bars are blurred vertical pills with gradient fills, sitting on a thin grey baseline. Data points are tiny circles connected by a faint curve.

```css
.chart-bar {
  width: 14px;
  border-radius: 9999px;
  background: linear-gradient(180deg, var(--g-iri-1), var(--g-iri-3));
  filter: blur(6px);
  opacity: 0.85;
}
```

---

## Components

### Buttons

| Variant | Use | Style |
|---|---|---|
| `[Primary]` | Main action | Black pill, white mono text, in brackets |
| `[Secondary]` | Alt action | Transparent pill, ink border, ink mono text |
| `Ghost` | Tertiary | No border, ink-soft text, hover underline |
| `Soft` | Subdued primary | `--g-warm` pill, accent text |

### Cards

| Variant | Use |
|---|---|
| `card-paper` | White surface, default container |
| `card-warm` | Warm gradient fill, used for highlight/feature |
| `card-cool` | Cool gradient fill, used for AI/technical features |
| `card-iridescent` | Multi-stop gradient, used for hero/special moments |

All cards use `--radius-lg`, `--shadow-card`, and have at least `--space-5` internal padding.

### Inputs

48px tall, `--radius-pill`, light hairline border, mono placeholder text. Focus state: hairline turns to `--accent`.

---

## Theming

Ethereal ships with a "night sky" dark mode. The intent is not a black-on-white inversion, it's a parallel atmosphere where the same pastel gradients glow against deep indigo instead of sitting on warm cream. Both modes are first-class.

### How it works

Theme is set on `<html>` via `data-theme="light"` or `data-theme="dark"`. CSS variables flip with the attribute. Pastel gradients are mode-agnostic and don't change. The primary button inverts (dark pill in light mode, cream pill in dark) so it always reads as the strongest contrast moment.

### Defaulting

Default to dark mode and persist the user's choice in `localStorage` under the key `ethereal-theme`. The toggle is a single button in the top bar / status bar.

### Static-ink contract

Any element that lives on a pastel gradient surface (warm/cool/iridescent cards, dusk phone backgrounds, aurora footer) must use the static ink tokens — never `--ink`, since that flips. The system enforces this in CSS via overrides that pin those elements to `--ink-static` regardless of theme. If you build a new component on top of a gradient surface, follow the same rule.

### React API

```jsx
import { EtherealStyles, EtherealThemeProvider, ThemeToggle, Button, Orb } from './ethereal-components';

function App() {
  return (
    <EtherealThemeProvider defaultTheme="dark">
      <EtherealStyles />
      <ThemeToggle />
      {/* your app */}
    </EtherealThemeProvider>
  );
}
```

`useTheme()` is a hook that returns the current theme's resolved tokens plus `_name: "light" | "dark"` if you need to branch on the active mode in JS.

---

## Voice & content rules

- **Use brackets for actions.** `[Begin]`, not `Begin`.
- **Mono for technical, sans for emotional.** A timer is mono. A tagline is sans.
- **Status dots before labels.** `● LIVE`, never `LIVE ●`.
- **No exclamation points** in mono text. Mono is calm.
- **Lowercase taglines under sans display.** "grasped with knowledge, filled with emotion" — soft, lyrical.

---

## Don'ts

- Don't use pure black `#000` anywhere. Always `--ink` (`#14161F`).
- Don't use a gradient as a full-page background behind text-heavy content.
- Don't use sans inside a button. Buttons are mono and bracketed.
- Don't use a shadow on a gradient orb. Orbs are atmospheres, not objects.
- Don't use more than two named gradients on a single screen.
- Don't use border-radius below 8px anywhere.
- Don't use Inter, Roboto, Helvetica, or system fonts.

---

*Ethereal v1.0. Built for products that want to feel like a deep breath.*
