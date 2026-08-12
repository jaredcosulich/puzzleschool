# Clean Dashboard

> Minimal, information-dense UI. Subtle depth via soft shadows and thin borders. For any web or mobile app.

## Philosophy

High data clarity, minimal chrome. Neutral palette with restrained color accents. Soft shadows and thin borders create depth without visual weight. Professional, calm motion. Consistent 4px grid.

**Rules:**

1. Cards use `var(--bg-surface)` — never hardcoded or colored backgrounds
2. Text hierarchy: primary → secondary → tertiary (never skip levels)
3. No drop shadows on elements already inside a card
4. Max 2 font weights per card
5. Both light and dark mode required via `data-theme` attribute

## How to use this system

### Minimum viable composition

Card, table, button, input, badge. A dashboard becomes recognizable as
"clean-dashboard" the moment it shows tabular data inside neutral cards
with subtle borders.

### Example compositions are examples

Sparkline, KPI tile, side-nav with section dividers, filter rail. Reach
for these when the layout calls for them — they are showcase patterns,
not required.

---

## Colors

### Light Mode

```css
[data-theme='light'] {
  --bg-base: #f7f8fa; /* page background */
  --bg-surface: #ffffff; /* cards, panels */
  --bg-overlay: #ffffff; /* modals, dropdowns */
  --bg-muted: #f2f3f7; /* hover states, inactive */
  --bg-active: #eef2ff; /* selected items */

  --text-primary: #1a1b25;
  --text-secondary: #6b7280;
  --text-tertiary: #9ca3af;
  --text-disabled: #c4c7ce;

  --border: #e8e9ed;
  --border-strong: #d1d3db;

  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.08);
}
```

### Dark Mode

```css
[data-theme='dark'] {
  --bg-base: #14141f;
  --bg-surface: #1e1e2e;
  --bg-overlay: #252537;
  --bg-muted: #252537;
  --bg-active: #2d2d45;

  --text-primary: #e8e9f0;
  --text-secondary: #9899aa;
  --text-tertiary: #5e5f72;
  --text-disabled: #3a3a50;

  --border: #2a2a3e;
  --border-strong: #383856;

  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4);
}
```

Respect `@media (prefers-color-scheme: dark)` on `:root:not([data-theme="light"])`.

### Accents

```css
/* These don't change between modes */
--green-a: #34d399;
--green-b: #a7f3d0; /* positive states */
--red: #f87171; /* negative states */
--purple-a: #9b8afb;
--purple-b: #c4b5fd;
--blue-a: #60a5fa;
--blue-b: #bae6fd;
--yellow: #fcd34d;
```

### Semantic

```css
--success-bg: var(--green-b);
--success-text: #065f46;
--danger-bg: #fee2e2;
--danger-text: #991b1b;
--warning-bg: #fef9c3;
--warning-text: #854d0e;
```

### Ordered Palette

```css
/* For any categorical sequence: tags, categories, avatars, etc. */
--palette-1: #6c8ef5; /* blue-purple */
--palette-2: #34d399; /* green */
--palette-3: #f87171; /* red */
--palette-4: #fbbf24; /* yellow */
--palette-5: #a78bfa; /* purple */
--palette-6: #22d3ee; /* cyan */
```

---

## Typography

**Font stack:** `'Inter', sans-serif`

| Style   | Size | Weight  | Notes                 |
| ------- | ---- | ------- | --------------------- |
| Display | 48px | 600     | Large emphasis values |
| 2XL     | 24px | 400/600 | Section headings      |
| LG      | 18px | 400/600 | Card titles           |
| SM      | 14px | 400/600 | Body, labels          |
| XS      | 12px | 400/600 | Captions, timestamps  |

---

## Spacing & Radius

Base unit: 4px. Scale: 4, 8, 12, 16, 20, 24, 32, 40px.

| Context              | Value       |
| -------------------- | ----------- |
| Card padding         | `20px 24px` |
| Gap between cards    | 16px        |
| Gap between sections | 24px        |

```css
--radius-sm: 6px; /* badges, chips */
--radius-md: 8px; /* inputs, small cards */
--radius-lg: 12px; /* cards, panels */
--radius-xl: 16px; /* large containers */
--radius-full: 9999px; /* pills, avatars */
```

---

## Layout

### Common Patterns

- **Sidebar:** 200px fixed, `--bg-surface`, right border
- **Top bar:** 52px height, `--bg-surface`, bottom border. Contains: breadcrumbs (left), search (center), actions (right)
- **Side panel:** 260px fixed, `--bg-surface`, left border (optional, toggle on small viewports)
- **Main content:** flex-1, `--bg-base`, 24px padding

### Navigation States

- Section labels: XS, `--text-tertiary`, uppercase, `letter-spacing: 0.08em`
- Nav items: SM, `--text-secondary`, hover → `--bg-muted`
- Active item: `--bg-active`, `--text-primary`, weight 600
- Nested indent: 16px

### Mobile / Small Viewport

- Sidebar collapses to hamburger menu or bottom tab bar
- Side panel becomes slide-over or hidden
- Cards stack single-column, full width, reduce padding to 16px
- Top bar simplified: hamburger + key actions only

---

## Components

### Card

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 20px 24px;
  box-shadow: var(--shadow-sm);
}
```

**Variants:** none — cards are always neutral surface color.

**Interactive states:** hover → `--bg-muted` background or `--shadow-md`. No transform.

### Value Card

Card with: label (SM, `--text-secondary`), emphasized value (Display 48px, semibold), optional trend indicator. Positive: `--green-a` + `↗`. Negative: `--red` + `↘`. Trend text: XS, weight 500.

### Button

```css
.btn {
  padding: 0 14px;
  border-radius: var(--radius-md);
  font-weight: 500;
  font-size: 13px;
  border: none;
  cursor: pointer;
}
/* Hover: 8% brightness shift. Disabled: 40% opacity, not-allowed. */
```

| Variant      | Background       | Text               | Border/Shadow                    |
| ------------ | ---------------- | ------------------ | -------------------------------- |
| Filled       | `--text-primary` | `--bg-base`        | none                             |
| Filled muted | `--bg-muted`     | `--text-primary`   | none                             |
| Outline      | transparent      | `--text-primary`   | `1px solid var(--border-strong)` |
| Ghost        | transparent      | `--text-secondary` | none                             |

| Size         | Padding     | Font Size |
| ------------ | ----------- | --------- |
| SM           | `6px 10px`  | 12px      |
| MD (default) | `8px 14px`  | 13px      |
| LG           | `11px 18px` | 14px      |

Icon-only: square at size height. Split button: text + chevron with 1px divider.

### Badge / Pill

`border-radius: var(--radius-sm)` for chips, `--radius-full` for pills. Use accent colors at low opacity for backgrounds.

### Input

`--bg-surface`, `1px solid var(--border)`, `--radius-md`, SM text. Focus: `--border-strong` or accent ring.

### Table / Data Row

Rows 32px height, `border-bottom: var(--border)`. Labels SM, `--text-secondary`. Hover → `--bg-muted`.

---

## Motion

```css
--transition-fast: 100ms ease; /* hover states */
--transition-base: 180ms ease; /* general transitions */
--transition-slow: 280ms ease-in-out; /* panels, overlays */
```

Calm and professional — no bounce or spring. Subtle opacity and position transitions only.

---

## Checklist

- [ ] Page bg is `--bg-base`, cards are `--bg-surface` — no hardcoded colors
- [ ] Both `data-theme="light"` and `"dark"` fully supported
- [ ] Text uses primary/secondary/tertiary hierarchy consistently
- [ ] All spacing on 4px grid
- [ ] No colored card backgrounds (except active-state chips)
- [ ] No shadows on elements inside cards
- [ ] Max 2 font weights per card
- [ ] Motion is subtle and fast — no bounce effects
- [ ] Icons are outlined, 1.5px stroke, inherit currentColor
- [ ] Ordered palette colors used consistently for categorical items

## Anti-patterns

- Don't use bright fills for card backgrounds — color belongs in
  badges, charts, and ordered accents, not in the surface itself.
- Don't stack drop shadows on nested elements — depth is owned by the
  card edge, not its contents.
- Don't mix multiple font scales inside a single card. Two weights at
  one scale stays calm; more reads as a brochure.
- Don't reach for animation to "delight" — motion serves transitions
  and state changes only.
