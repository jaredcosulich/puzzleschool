# Mono-Brutalist

> Raw, typographic, terminal-warm UI. Monospace identity, dashed borders, single mint-green accent. For any web or mobile app.

## Philosophy

Brutalism's exposed skeleton — visible grids, raw type, no embellishment — warmed with organic off-whites, sage greens, and monospaced type. Feels like a well-worn notebook: structured but human.

**Rules:**

1. Monospace font carries the identity — labels, tags, metadata, inputs, buttons, nav all use mono
2. Dashed borders are the signature element — used on tags, chips, empty states, never on structural containers
3. Single chromatic accent (mint green) — resist adding secondary colors
4. Never use pure black (`#000`) or pure white (`#fff`) — everything lives between warm off-white and dark olive

## How to use this system

### Minimum viable composition

Monospaced text, dashed-border tag, input field with a hard outline,
button using the same mono family. If those four exist on the screen, it
reads as mono-brutalist.

### Example compositions are examples

Terminal panes, tab strips drawn with `─` glyphs, hand-typed-feeling
prose blocks, dashboard cards with serial numbers. Reach for these when
the content calls for it — opt-in flourishes, not signatures.

---

## Colors

### Light Mode

```css
[data-theme='light'] {
  --bg-base: #eeece6; /* warm off-white page bg */
  --bg-surface: #fafaf7; /* cards, panels */
  --bg-surface-raised: #ffffff; /* modals, overlays */
  --bg-inverse: #2d3228; /* dark olive — inverted accent blocks, headers */

  --text-primary: #2d3228; /* headings, primary content */
  --text-secondary: #555550; /* body, descriptions */
  --text-muted: #777772; /* labels, metadata */
  --text-faint: #999994; /* placeholders, disabled */

  --border: #e2dfd6; /* solid borders — cards, panels, dividers */
  --border-dashed: #999690; /* dashed borders — tags, chips, empty states */

  --shadow-sm: none; /* no shadows in this system — borders do the work */
  --shadow-md: none;
}
```

### Dark Mode

```css
[data-theme='dark'] {
  --bg-base: #1a1e18;
  --bg-surface: #222820;
  --bg-surface-raised: #2a3028;
  --bg-inverse: #2d3228; /* unchanged — constant anchor */

  --text-primary: #e0ddd6;
  --text-secondary: #a8a89e;
  --text-muted: #6a7a64;
  --text-faint: #4a5a44;

  --border: #2e3628;
  --border-dashed: #3e4a38;
  /* Accent unchanged. Inverse surfaces unchanged. */
}
```

Respect `@media (prefers-color-scheme: dark)` on `:root:not([data-theme="light"])`.

### Accents

```css
/* Mint green — the only chromatic accent. Unchanged between modes. */
--accent: #b8e0a0; /* primary: on dark surfaces, active indicators */
--accent-soft: #c5e8b0; /* light mode soft fill; dark mode: #1e3a18 */
--accent-dark: #82b870; /* darker variant for emphasis */
```

### Semantic

```css
--success-bg: #dff0d4;
--success-text: #3a5c2a;
--danger-bg: #f0d4d4;
--danger-text: #5c2a2a;
/* Dark mode: --success-bg: #1e3018; --success-text: #82b870; */
```

### Ordered Palette

```css
/* Single-accent system — categorical sequence uses value/opacity variations */
--palette-1: #2d3228; /* ink */
--palette-2: #82b870; /* accent dark */
--palette-3: #b8e0a0; /* accent */
--palette-4: #555550; /* secondary */
--palette-5: #999690; /* muted */
```

---

## Typography

**Font stack:** `'Courier New', Courier, monospace` (identity — labels, tags, inputs, buttons, nav), `system-ui, -apple-system, sans-serif` (headings and body prose only). Optional upgrade: `'DM Mono'` for mono.

| Style       | Size                     | Weight | Font | Notes                                                        |
| ----------- | ------------------------ | ------ | ---- | ------------------------------------------------------------ |
| Display     | `clamp(28px, 5vw, 56px)` | 300    | Sans | `letter-spacing: -0.02em; line-height: 1.2`                  |
| H1          | `clamp(22px, 3vw, 36px)` | 400    | Sans | `letter-spacing: -0.02em`                                    |
| H2          | 18px                     | 500    | Sans | Card titles                                                  |
| H3          | 14px                     | 500    | Sans | Panel titles                                                 |
| Body        | 13px                     | 400    | Sans | `line-height: 1.6`                                           |
| Mono L      | 13px                     | 400    | Mono | Large mono labels                                            |
| Mono M      | 12px                     | 400    | Mono | Default — inputs, content text                               |
| Mono S      | 11px                     | 400    | Mono | Tags, metadata, table cells. `letter-spacing: 0.03em`        |
| Mono XS     | 10px                     | 400    | Mono | Section labels, footers. `uppercase; letter-spacing: 0.12em` |
| Large Value | `clamp(28px, 4vw, 44px)` | 300    | Sans | Emphasized numbers. `letter-spacing: -0.02em`                |

**Key distinctions:**

- ALL CAPS labels always use `letter-spacing: 0.10em` minimum
- Wrapping user-generated content in quotes (`"text like this"`) is a signature pattern
- Mono for everything structural/interactive; sans only for headings and prose

---

## Spacing & Radius

Base unit: 4px. Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48px.

| Context                | Value  |
| ---------------------- | ------ |
| Card padding (compact) | `16px` |
| Card padding (default) | `24px` |
| Grid gap (cards)       | 10px   |
| Section gap            | 32px   |

```css
--radius-sm: 8px; /* badges */
--radius-md: 12px; /* inputs, small cards */
--radius-lg: 16px; /* cards, panels */
--radius-xl: 20px; /* modals */
--radius-pill: 100px; /* buttons, tag pills */
```

---

## Layout

### Common Patterns

- **Sidebar/Header:** Dark olive (`--bg-inverse`), same in both modes — constant anchor
- **Top bar:** Sticky, dark olive bg, mint accent for active nav
- **Bottom nav (mobile):** Dark olive bg, mint accent active indicator
- **Main content:** flex-1, `--bg-base`, 40px padding (desktop), 20px (mobile)

### Navigation States

- Section labels: Mono XS, uppercase, `letter-spacing: 0.12em`, `--text-muted`
- Nav items: Mono M, `--text-secondary`. Hover → `--bg-surface` bg. Active → mint accent text on inverse bg
- Dark olive header is always present — `--bg-inverse`, `z-index: 20`

### Mobile / Small Viewport

- Single column, 20px padding
- Cards full-width, `--radius-lg`
- Tag pills in horizontal scroll row (no wrap)
- Tap targets minimum 44px height
- Display type scales down via clamp

---

## Components

### Card

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 24px;
}
```

**Variants:** `default` (surface), `inverted` (ink bg, no border), `accent` (accent-soft bg, accent border).

**Interactive states:** hover → subtle bg shift only. No transforms, no shadows.

**Card anatomy:** Label row (ALL CAPS mono) → content → footer (timestamp + tag pill).

### Value Card

Card with: label (Mono XS, uppercase), emphasized value (Large Value style), optional trend indicator (`--success-text` for up, `--danger-text` for down, italic). Stats row: grid with thin border gaps between cards.

### Button

```css
.btn {
  font-family: var(--font-mono);
  font-size: 12px;
  padding: 12px 22px;
  border-radius: var(--radius-pill);
  letter-spacing: 0.04em;
  cursor: pointer;
}
```

| Variant   | Background     | Text             | Border                              |
| --------- | -------------- | ---------------- | ----------------------------------- |
| Primary   | `--bg-inverse` | `--accent`       | none                                |
| Secondary | transparent    | `--text-primary` | `1.5px dashed var(--border-dashed)` |
| Ghost     | transparent    | `--text-muted`   | `1px solid var(--border)`           |

Primary: always dark bg + mint text. All buttons use mono font, pill radius.

### Tag / Pill (signature element)

`font-family: mono; font-size: 11px; padding: 4px 11px; border-radius: 100px; border: 1.5px dashed var(--border-dashed); letter-spacing: 0.03em; background: transparent`. Active → solid border + inverse bg + white text. Accent variant → accent-dark border + accent-dark text.

### Badge

`font-family: mono; font-size: 10px; padding: 3px 10px; border-radius: 100px; letter-spacing: 0.04em`. Variants: trending (inverse bg + accent text), rising (success bg + success text), default (base bg + muted text).

### Input

`font-family: mono; font-size: 12px; padding: 12px 16px; border-radius: var(--radius-md); border: 1px solid var(--border); background: var(--bg-base)`. Focus: `border-color: var(--border-dashed)`. Placeholder: `--text-faint`, mono.

### Table

Header: Mono XS uppercase labels, `--text-muted`. Rows: Mono S, `--text-secondary`, `border-bottom: 1px solid var(--border)`. Hover → `--bg-base`. Numbers: `--text-primary`, weight 500.

### Empty State

Centered dashed circle (`1.5px dotted var(--accent-dark)`, 50px, `+` inside) on accent-soft background. Lowercase conversational text: `"no items here yet"`.

---

## Motion

```css
--transition-fast: 100ms ease; /* button/tag hover */
--transition-base: 120ms ease; /* card hover, general */
--transition-slow: 200ms ease-out; /* modals, panels */
```

Grounded and minimal — things slide and fade, never bounce. No spring physics, parallax, rotation, or scale-up on hover. Page load: staggered fade-up, 40ms delay per item.

---

## Checklist

- [ ] Background is warm off-white (`#eeece6`) or dark olive (`#1a1e18`) — never pure black or white
- [ ] Monospace font on all labels, tags, inputs, buttons, and nav — sans only for headings/prose
- [ ] Tags/pills use dashed borders — structural containers use solid borders
- [ ] Only one chromatic accent (mint green) — no secondary colors
- [ ] Primary buttons: dark bg + mint text, always pill-shaped
- [ ] ALL CAPS labels have letter-spacing 0.10em+
- [ ] Dark olive inverse surfaces are the same in both light and dark mode
- [ ] No box-shadows — borders and background contrast only
- [ ] User content wrapped in quotes (`"..."`) where applicable
- [ ] Motion is grounded — fade and slide only, no bounce

## Anti-patterns

- Don't smooth out the dashed borders into solid lines — the dash is
  the signature; without it the system looks like ordinary outlined UI.
- Don't add a second accent color "for variety." One mint accent
  enforces the discipline.
- Don't pair the monospace voice with rounded cards or soft shadows —
  the contradiction breaks the terminal-warmth that holds the system
  together.
- Don't use display sans-serifs for labels or buttons; if it sits in a
  control, it must be mono.
