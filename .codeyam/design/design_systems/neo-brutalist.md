# Neo-Brutalist

> Hard-edged, warm, editorial UI. Offset shadows, bold borders, hot pink accent. For any web or mobile app.

## Philosophy

Heavy black borders and offset box shadows create a "printed" feel. Warm off-white base (never pure white or grey). Typography is heavy and confident. No gradients. No rounded corners over 18px.

**Rules:**

1. Cards always have `border: 2px solid` + offset box shadow
2. Interactive elements "press" on hover/active (`translate(2px, 2px)`, shadow removed)
3. Dark mode inverts backgrounds but keeps accent colors identical
4. Dark cards/sidebar stay dark in both modes

## How to use this system

### Minimum viable composition

Card with `2px` solid border and offset shadow, heavy display heading,
hot-pink primary button. Once the press-on-hover behavior is wired up,
the system is recognizable.

### Example compositions are examples

Sticker-style badges, hand-drawn divider rules, oversized "Get started"
hero buttons, "printed paper" alert blocks. Use these when the content
wants to feel produced — they are not required for every screen.

---

## Colors

### Light Mode

```css
[data-theme='light'] {
  --bg-base: #f5f0e8; /* warm off-white page bg */
  --bg-surface: #ffffff; /* cards, panels */
  --bg-muted: #ede8de; /* subtle sections, table headers */
  --bg-inverse: #0d0d0d; /* dark surfaces */

  --text-primary: #0d0d0d;
  --text-secondary: #666666;
  --text-muted: #999999;
  --text-inverse: #ffffff;

  --border: #0d0d0d;
  --border-light: #e5ddd0; /* internal dividers */

  --shadow-sm: 2px 2px 0px #0d0d0d;
  --shadow-md: 4px 4px 0px #0d0d0d;
  --shadow-lg: 6px 6px 0px #0d0d0d;
  --shadow-accent: 4px 4px 0px #ff90e8;
}
```

### Dark Mode

```css
[data-theme='dark'] {
  --bg-base: #111111;
  --bg-surface: #1a1a1a;
  --bg-muted: #222222;
  --text-primary: #f5f0e8;
  --text-secondary: #aaaaaa;
  --text-muted: #666666;
  --text-inverse: #0d0d0d;
  --border: #f5f0e8;
  --border-light: #2a2a2a;
  --shadow-sm: 2px 2px 0px #f5f0e8;
  --shadow-md: 4px 4px 0px #f5f0e8;
  --shadow-lg: 6px 6px 0px #f5f0e8;
  /* Accents unchanged. Dark cards/sidebar unchanged. */
}
```

Respect `@media (prefers-color-scheme: dark)` on `:root:not([data-theme="light"])`.

### Accents

```css
/* These don't change between modes */
--pink: #ff90e8; /* primary: CTAs, active nav, highlights */
--pink-light: #ffe4f8;
--teal: #14b8a6; /* secondary: success states, live data */
--teal-light: #ccfbf1;
--teal-dark: #0f766e;
--yellow: #facc15; /* tertiary: alerts, featured labels */
--yellow-light: #fef9c3;
--yellow-dark: #ca8a04;
--orange: #fb923c; /* quaternary: warnings */
```

### Semantic

```css
--success-bg: #d1fae5;
--success-text: #065f46;
--danger-bg: #fee2e2;
--danger-text: #991b1b;
--warning-bg: #fef9c3;
--warning-text: #854d0e;
/* Dark mode: --success-bg: #052e16; --success-text: #86efac; etc. */
```

### Ordered Palette

```css
/* For any categorical sequence: tags, categories, avatars, etc. */
--palette-1: #ff90e8; /* pink */
--palette-2: #14b8a6; /* teal */
--palette-3: #facc15; /* yellow */
--palette-4: #fb923c; /* orange */
--palette-5: #818cf8; /* purple */
```

---

## Typography

**Font stack:** `'DM Sans', sans-serif` (body), `'DM Serif Display', serif` (display/h1), `'DM Mono', monospace` (code)

| Style       | Size                     | Weight              | Notes                                                 |
| ----------- | ------------------------ | ------------------- | ----------------------------------------------------- |
| Display     | `clamp(28px, 4vw, 48px)` | 400 (Serif Display) | `letter-spacing: -1.5px; line-height: 1.1`            |
| H1          | `clamp(22px, 3vw, 36px)` | 900                 | `letter-spacing: -1px`                                |
| H2          | 20px                     | 900                 | `letter-spacing: -0.5px`                              |
| H3          | 15px                     | 700                 |                                                       |
| Label       | 11px                     | 700                 | `uppercase; letter-spacing: 1px; color: --text-muted` |
| Body        | 14px                     | 400                 | `line-height: 1.6`                                    |
| Body SM     | 13px                     | 400                 | `line-height: 1.5`                                    |
| Large Value | `clamp(22px, 3vw, 32px)` | 900                 | `letter-spacing: -1px` — for emphasized numbers       |

**Common pattern — eyebrow + title:** Label above H2 in almost every section.

---

## Spacing & Radius

Base unit: 4px. Scale: 4, 8, 12, 16, 20, 24, 28, 32, 40, 48px.

| Context                | Value       |
| ---------------------- | ----------- |
| Card padding (compact) | `16px 18px` |
| Card padding (default) | `22px 24px` |
| Card padding (large)   | `28px 28px` |
| Grid gap               | 18px        |

```css
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 18px; /* cards — max radius in the system */
--radius-pill: 999px; /* badges, avatars */
```

---

## Layout

### Common Patterns

- **Sidebar:** 220px fixed left, `--bg-inverse`, always dark in both modes
- **Top nav:** Sticky, 64px height, `--bg-base`, bottom border
- **Bottom nav (mobile):** Fixed, 64px, `--pink-light` active bg. Add `env(safe-area-inset-bottom)` padding
- **Main content:** flex-1, `--bg-base`, padding `36px 40px`

### Navigation States

- Logo mark: 36px accent square + bold name
- Nav items: 14px, `10px 14px` padding, rounded 10px. Hover/active → `--pink` bg + dark text
- Top nav active link: inverse bg pill

### Mobile / Small Viewport

- Single column, 16px padding
- Cards stack vertically, buttons full-width in forms
- Reduce shadows to `--shadow-sm`

---

## Components

### Card

```css
.card {
  background: var(--bg-surface);
  border: 2px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 22px 24px;
  box-shadow: var(--shadow-md);
  position: relative;
  overflow: hidden;
}
```

**Variants:** `default` (white), `dark` (inverse bg + accent shadow), `pink`, `teal`, `yellow`, `muted` (base bg).

**Interactive states:** hover → `translateY(-3px)` + `shadow-lg`. Active → `translate(2px, 2px)` + `shadow-sm`.

### Value Card

Card with: decorative accent circle (top-right, 64px, 20% opacity), icon box (40px, accent bg, 2px border, rounded 10px), label (eyebrow), emphasized value (Large Value style), optional trend badge (pill, success/danger colors).

### Button

```css
.btn {
  padding: 11px 22px;
  border-radius: var(--radius-md);
  font-weight: 700;
  font-size: 14px;
  border: 2px solid var(--border);
}
.btn:hover {
  transform: translate(-1px, -1px);
}
.btn:active {
  transform: translate(2px, 2px);
  box-shadow: none;
}
```

| Variant   | Background     | Text             | Border/Shadow             |
| --------- | -------------- | ---------------- | ------------------------- |
| Primary   | `--pink`       | `--text-primary` | `--shadow-md`             |
| Secondary | `--bg-surface` | `--text-primary` | `--shadow-sm`             |
| Teal      | `--teal`       | `--text-primary` | `--shadow-md`             |
| Yellow    | `--yellow`     | `--text-primary` | `--shadow-md`             |
| Dark      | `--bg-inverse` | `--text-inverse` | `--shadow-accent`         |
| Ghost     | transparent    | `--text-primary` | none; hover: `--bg-muted` |

| Size         | Padding     | Font Size |
| ------------ | ----------- | --------- |
| SM           | `7px 14px`  | 12px      |
| MD (default) | `11px 22px` | 14px      |
| LG           | `15px 30px` | 16px      |

Icon-only: 40x40, no padding, `--radius-sm`.

### Badge / Pill

`padding: 3px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; border: 1.5px solid currentColor`. Semantic variants: success, danger, warning, pink, teal, yellow, neutral. Solid variant: inverse bg+text.

### Input

`padding: 11px 16px; border: 2px solid var(--border); border-radius: var(--radius-md); font-size: 14px`. Focus: `box-shadow: 0 0 0 3px var(--pink)`. Input-group: input + button joined with zero'd inner radii.

### Table

Container: card shell (border, radius-lg, shadow-md, overflow hidden). Header: `--bg-muted`, 11px uppercase labels. Rows: `16px 28px` padding, `--border-light` divider, hover → muted bg.

### Progress Bar

Track: 12px height, `--bg-muted`, pill radius, 2px border. Fill: pill radius, accent color. Animate: `width 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)`.

### Avatar

Square-ish (`--radius-sm`), 2px border. Sizes: 28/36/48px. Cycle through ordered palette colors.

### Tag / Chip

`padding: 5px 12px; border-radius: 999px; border: 2px solid var(--border); font-size: 13px; font-weight: 600`. Hover → pink bg. Active → inverse bg+text.

### Tooltip

`background: --bg-inverse; border: 2px solid --pink; border-radius: --radius-md; padding: 10px 16px; color: --text-inverse; font-size: 13px`. Bold label + bold value.

---

## Motion

```css
--transition-fast: 120ms ease; /* button press */
--transition-base: 180ms ease; /* card hover, general */
```

Bouncy and tactile — elements lift and press. Staggered fade-up on page load:

```css
@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
/* animation: fadeUp 0.4s ease forwards; delay: n * 0.05s */
```

---

## Checklist

- [ ] Background is `#F5F0E8` (light) or `#111111` (dark) — never pure white or grey
- [ ] Every card has 2px border + offset box shadow
- [ ] Interactive elements press-shift on :active
- [ ] DM Sans (body) + DM Serif Display (headlines) + DM Mono (code)
- [ ] At least one pink element visible on every screen
- [ ] Labels: 11px uppercase, letter-spacing 1px
- [ ] Badges are pill-shaped with border
- [ ] Dark sidebar/cards unchanged in dark mode
- [ ] No gradients anywhere
- [ ] Spacing follows 4px grid

## Anti-patterns

- Don't soften the borders to `1px` or hairline — the 2px stroke is
  what makes the system read as printed.
- Don't drop the offset shadow on interactive cards; the press-shift
  behavior depends on the shadow being there to remove.
- Don't introduce gradients or glass effects — the system is flat
  ink-on-paper, not glossy.
- Don't tone down the pink to a desaturated rose. The accent has to
  feel hot to do its job.
