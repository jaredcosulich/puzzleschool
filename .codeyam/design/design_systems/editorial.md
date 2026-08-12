# Editorial

> Serif-first, warm, print-inspired UI. Parchment tones, sharp corners, typography-driven hierarchy. For any web or mobile app.

## Philosophy

Draws from quality print publications and luxury brand identities. Typography, spacing, and weight do the work that color and shape do in other systems. Warmth without softness. Restraint with intention — minimal color means color carries meaning when it appears.

**Rules:**

1. Cards use borders only — never box-shadows
2. Nearly square-cornered everywhere (max 4px radius, no pills)
3. Background is always warm parchment — never white, never grey
4. Accent colors (burgundy, sage, gold) appear only as text, borders, or thin fills — never large background fills
5. Font-weight never exceeds 500 — heaviness destroys the elegance

## How to use this system

### Minimum viable composition

Serif display heading on parchment, body text in a humanist sans, a
hairline-bordered card, and a single accent (burgundy, sage, or gold)
used in a text link or rule. That carries the editorial voice.

### Example compositions are examples

Drop-caps for long-form copy, table-of-contents column with leading
numerals, footnoted captions, magazine-style two-up image+caption
layouts. Use them when the content invites; they are signatures, not
chrome.

---

## Colors

### Light Mode (only mode — no dark mode)

```css
:root {
  /* Surfaces — lightest to darkest warm neutral */
  --bg-base: #f4efe4; /* parchment page bg */
  --bg-surface: #ede5d6; /* cards, sidebar, topbar */
  --bg-muted: #e0d5c0; /* hover states, inset areas */

  /* Text */
  --text-primary: #1c1409; /* headings, active states (warm near-black, not #000) */
  --text-secondary: #5a4f3f; /* body text, secondary content */
  --text-muted: #8a7d6b; /* labels, metadata, placeholders */

  /* Border */
  --border: #c9bbaa; /* all borders and dividers */

  /* Shadows — intentionally none. Borders and background contrast do all separation. */
  --shadow-sm: none;
  --shadow-md: none;
}
```

Hover states shift surfaces one step darker: base → surface → muted.

### Accents

```css
/* Use sparingly — as text, borders, or thin fills only */
--burgundy: #7a1e1e; /* critical, error, accent highlight */
--burgundy-lt: #c84b4b; /* burgundy hover */
--sage: #3e5145; /* success, active, positive */
--gold: #b08830; /* warning, in-progress, special */
```

### Semantic

```css
/* Outlined badges at 6% opacity tint, never solid fills */
--success-border: var(--sage);
--success-text: var(--sage);
--danger-border: var(--burgundy);
--danger-text: var(--burgundy);
--warning-border: var(--gold);
--warning-text: var(--gold);
```

### Ordered Palette

```css
/* For any categorical sequence: tags, categories, avatars, etc. */
--palette-1: #1c1409; /* ink */
--palette-2: #7a1e1e; /* burgundy */
--palette-3: #3e5145; /* sage */
--palette-4: #b08830; /* gold */
--palette-5: #5a4f3f; /* secondary */
```

---

## Typography

**Font stack:** `'Cormorant Garamond', Georgia, serif` (display/UI), `'EB Garamond', Georgia, serif` (body prose only)

| Style          | Size    | Weight | Notes                                                                         |
| -------------- | ------- | ------ | ----------------------------------------------------------------------------- |
| Display        | 44–52px | 300    | `letter-spacing: -0.02em; line-height: 1`. Italic `em` for editorial emphasis |
| Headline       | 28–36px | 400    | Italic. Section headers                                                       |
| Subhead        | 18–22px | 500    | `letter-spacing: 0.01em`. Card titles                                         |
| Label / Kicker | 9–11px  | 400    | `uppercase; letter-spacing: 0.22–0.28em; color: --text-muted`                 |
| Body           | 15–16px | 400    | EB Garamond. `line-height: 1.6`                                               |
| Body Italic    | 14–15px | 400    | EB Garamond italic. Metadata, timestamps, captions                            |
| UI Small       | 11–13px | 400    | `letter-spacing: 0.12–0.18em`. Buttons, badges, tags                          |
| Large Value    | 32–44px | 300    | `letter-spacing: -0.02em`. Emphasized numbers                                 |

**Key distinctions:**

- Display font (Cormorant Garamond) for ALL UI chrome: nav, labels, buttons, badges, numbers
- Body font (EB Garamond) ONLY for prose text and descriptions
- Labels and categories are ALWAYS uppercase with generous letter-spacing (0.2em+)
- Italic signals metadata, dates, captions — use it meaningfully, not decoratively
- Prefer Unicode symbols (✦ ◈ ◇ ▷) over icon libraries — they fit the editorial aesthetic

---

## Spacing & Radius

Base unit: 4px. Scale: 4, 8, 16, 24, 40, 64px.

| Context      | Value                            |
| ------------ | -------------------------------- |
| Card padding | `24px` (header/body/footer each) |
| Grid gap     | 40px                             |
| Section gap  | 40px                             |

```css
--radius-sm: 2px; /* inputs, small chips — use sparingly */
--radius-md: 4px; /* maximum radius in the system */
/* No large radius. No pills. Buttons are square-cornered (0px). */
```

---

## Layout

### Common Patterns

- **Sidebar:** 220px fixed, `--bg-surface`, right border `--border`
- **Top bar:** Sticky, `--bg-surface`, bottom border. Title (uppercase, letter-spaced) + date (italic) + avatar
- **Bottom nav (mobile):** Use dot + label pattern from sidebar nav items
- **Main content:** flex-1, `--bg-base`, padding 40px
- **Reading column:** `max-width: 68ch` for optimal EB Garamond readability

### Navigation States

- Section labels: 9px, uppercase, `letter-spacing: 0.22em`, `--text-muted`
- Nav items: 14px body font, `--text-secondary`. Hover → `--bg-muted` bg. Active → `--text-primary` bg + `--bg-base` text
- Active dot indicator: 5px circle in `--gold`

### Mobile / Small Viewport

- Sidebar collapses to bottom tab bar (dot + label)
- Cards stack single-column, full width
- Display type reduces to 28px, value type to 28px
- Grid columns collapse to 1

---

## Components

### Card

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  display: flex;
  flex-direction: column;
}
.card-header {
  padding: 24px 24px 16px;
  border-bottom: 1px solid var(--border);
}
.card-body {
  padding: 24px;
  flex: 1;
}
.card-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--border);
}
```

**Variants:** none — cards are always `--bg-surface` with `--border`. No shadows ever.

**Interactive states:** hover is color/background only — never move or transform elements.

### Value Card

Card with: label (Label style, uppercase), emphasized value (Large Value style, weight 300), optional trend text (Body Italic, `--sage` for up, `--burgundy` for down). For stat rows: use a grid with 1px `--border` gap background to create ruled-line separation.

### Button

```css
.btn {
  font-family: var(--font-display);
  font-size: 11px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  padding: 9px 20px;
  border-radius: 0;
  transition: all 0.15s ease;
}
```

| Variant   | Background       | Text             | Border                    |
| --------- | ---------------- | ---------------- | ------------------------- |
| Primary   | `--text-primary` | `--bg-base`      | none                      |
| Secondary | transparent      | `--text-primary` | `1px solid var(--border)` |
| Ghost     | transparent      | `--text-muted`   | none                      |

Primary: only one per view. Ghost: for inline navigation actions ("View Detail →"). No icons unless text alone is insufficient.

### Badge

`padding: 2px 10px; font-size: 9px; letter-spacing: 0.18em; uppercase; border: 1px solid`. Always outlined — background tint is 6% opacity of accent color, never solid fill. Variants: default (`--border`/`--text-muted`), active (`--sage`), warning (`--gold`), critical (`--burgundy`).

### Input

Underline-style — bottom border is the primary affordance. `border: 1px solid var(--border); border-bottom: 2px solid var(--text-secondary); background: var(--bg-base); font-family: var(--font-body); font-size: 15px`. Focus: `border-bottom-color: var(--text-primary)`. Placeholder: italic, `--border` color. Labels: always present, uppercase display font.

### Table

Header row: `border-bottom: 2px solid var(--text-primary)`. Header cells: 9px uppercase label style, weight 400. Data cells: 14px body font, `--text-secondary`. Hover → `--bg-muted`. Primary column and numbers: `--text-primary`, weight 500.

### Tag / Chip

`font-size: 11px; letter-spacing: 0.1em; padding: 4px 12px; border: 1px solid var(--border); background: transparent`. Selected/hover → `--text-primary` bg + `--bg-base` text.

### Progress Bar

Track: 3px height, `--bg-muted`, no rounded ends. Fill: `--text-primary` (default), or accent color. Animate: `width 0.8s cubic-bezier(0.4, 0, 0.2, 1)`.

### Tooltip

`background: --text-primary; color: --bg-base; font-size: 12px; padding: 8px 14px`. No border-radius. Trigger text: dashed underline in `--burgundy`.

---

## Motion

```css
--transition-base: 150ms ease; /* all hover states and interactions */
```

No bouncy or springy animations. Ease only. No animations on text — only containers. Staggered fade-up on page load:

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
/* animation: fadeUp 0.5s ease both; delay: n * 0.07s */
```

Respect `prefers-reduced-motion` by disabling all animations.

---

## Checklist

- [ ] Background is `#F4EFE4` parchment — never white, never grey, never #000
- [ ] No box-shadows anywhere — borders and background contrast only
- [ ] All corners are square or max 4px radius — no pills, no rounded buttons
- [ ] Cormorant Garamond for all UI chrome; EB Garamond only for prose
- [ ] Labels are uppercase with letter-spacing 0.2em+
- [ ] Italic is used meaningfully (metadata, dates) — not decoratively
- [ ] Accent colors appear only as text/borders/thin fills — no large color fills
- [ ] Font-weight never exceeds 500
- [ ] Badges are outlined with 6% opacity tint — never solid
- [ ] Hover states are color/background only — elements never move

## Anti-patterns

- Don't reach for box-shadows to add depth — hairline borders are the
  vocabulary; shadows turn the page into a dashboard.
- Don't round corners. A 12-or-larger radius makes the system read as
  consumer/lifestyle, not editorial.
- Don't flood backgrounds with the accent colors; they earn their
  presence by being scarce.
- Don't push display weights above 500. Heavy weights destroy the
  graceful restraint that defines the system.
