# Bureau North

> Editorial-magazine UI. Mono labels, plate numbers, hairline rules, pastel accents, and lavender-duotone photography — light and dark.

## Philosophy

Bureau North borrows the conventions of independent print magazines — mono labels, plate numbers, hairline rules, generous white space — and applies them to digital interfaces. The voice is confident but not loud. Typography does most of the work; color is a soft, considered accent, never a UI dictator.

Cream is the canvas. Pastels are the accents. Black is reserved for ink (text). The brand never uses pure white or pure black — every neutral has warmth or coolness baked in.

## How to use this system

### Minimum viable composition

A mono uppercase eyebrow label with a leading hairline rule (`— PLATE 01`), a DM Sans headline that mixes weight 500 and 700 within one line, body text capped to a `ch` reading width, and 1px hairline borders doing the dividing instead of shadows. If those four exist on the screen, it reads as Bureau North.

### Example compositions are examples

Lavender-duotone photography with mono plate captions, the 12-column asymmetric card grid, rotating-pastel card rows, dashboard status pills, editorial side rows, and the grain overlay. Reach for these when the content calls for it — opt-in flourishes, not signatures.

---

## Color

### Philosophy

The palette is deliberately restrained: four pastels (lavender, rose, pale blue, sage) plus two warm neutrals (cream, tan) plus ink. Anything beyond this set is a mistake.

### Light palette

```css
:root {
  /* Ink (text) */
  --ink: #0E0E0F;            /* primary text */
  --ink-soft: #1B1B1E;       /* secondary text */
  --ink-mid: #4B4B4F;        /* tertiary text, dashboard */
  --ink-low: #76767A;        /* placeholder, disabled, dashboard */

  /* Paper (surfaces) */
  --paper: #FAF8F1;          /* page background */
  --paper-2: #FAF8F1;        /* card background, default */
  --paper-3: #E5E0D2;        /* warm tan accent */
  --paper-card: #FFFEF8;     /* elevated card (dashboard) */

  /* Sage (feature color) */
  --sage: #C2D2BC;           /* feature section bg */

  /* Lavender (primary accent) */
  --ultra: #7C82C4;          /* primary accent */
  --ultra-deep: #5A5FA0;     /* deeper, for buttons hover */
  --ultra-tint: #C8CBE8;     /* card bg, contact section */
  --ultra-soft: #E8EAF5;     /* status pill bg */

  /* Rose (secondary accent) */
  --rose: #F2C8CC;           /* card bg, charts */
  --rose-tint: #F8DEE2;      /* lighter card bg */

  /* Pale blue (tertiary accent) */
  --pale: #CFD9DC;           /* card bg, charts */
  --pale-tint: #E0E7E9;      /* lighter card bg */

  /* Functional */
  --green: #19A36A;          /* success, positive delta */
  --amber: #B85C00;          /* warning, in-review status */
  --rose-deep: #C2185B;      /* error, negative delta */

  /* Hairlines */
  --rule: rgba(14,14,15,.12);     /* default border */
  --rule-soft: rgba(14,14,15,.07); /* lighter border */
}
```

### Dark palette

Dark mode is not a simple inversion. Pastels are kept but desaturated. Surfaces use a near-black with a faint green undertone (`#0F1310`) so it feels intentional rather than pure black. Lavender becomes brighter (`#9CA0DD`) for legibility on dark.

```css
[data-theme="dark"] {
  /* Ink (text) */
  --ink: #F0EBE0;            /* primary text, warm off-white */
  --ink-soft: #C5C0B4;       /* secondary text */
  --ink-mid: #8A8579;        /* tertiary text */
  --ink-low: #6E695E;        /* disabled, placeholder */

  /* Paper (surfaces) */
  --paper: #0F1310;          /* page bg, near-black w/ green undertone */
  --paper-2: #161A18;        /* card bg, default */
  --paper-3: #2A2826;        /* warm tan accent */
  --paper-card: #1B1F1D;     /* elevated card */

  /* Sage */
  --sage: #4A5C46;           /* smoky sage feature bg */

  /* Lavender (primary) */
  --ultra: #9CA0DD;          /* brighter for dark legibility */
  --ultra-deep: #5A5FA0;     /* hover state, deeper accent block */
  --ultra-tint: #3A3D58;     /* deep dusty card bg */
  --ultra-soft: #25283D;     /* status pill bg */

  /* Rose */
  --rose: #C68A8E;           /* muted rose */
  --rose-tint: #4A2D31;      /* deep dusty rose card bg */

  /* Pale blue */
  --pale: #3D4548;           /* deep blue-grey */
  --pale-tint: #2A3032;

  /* Functional, brighter for dark */
  --green: #5DDC9D;
  --amber: #E8A552;
  --rose-deep: #E58AAB;

  /* Hairlines */
  --rule: rgba(240,235,224,.12);
  --rule-soft: rgba(240,235,224,.07);
}
```

### Color rules

1. **Text on cream uses ink.** Never use lavender or any accent for body text. Lavender is for accent only (links, hover states, brand mark).
2. **Headlines are always ink** (black in light, off-white in dark). Never colored display type.
3. **Pastels rotate, never repeat in a row.** Service cards run cream, lavender-tint, rose-tint, pale, cream — not lavender, lavender, lavender.
4. **Sage is the feature color.** Use sparingly, in one or two specific sections per page. Never as default body bg.
5. **Functional colors (green/amber/rose-deep) only signal state.** Never decorative.
6. **In dark mode, "ink-on-paper" buttons become "lavender-on-paper" buttons.** The primary button color in dark is `--ultra`, not `--ink` (which would be a glaring off-white block).

### Surface hierarchy

| Depth | Light | Dark |
|---|---|---|
| Page (deepest) | `--paper` cream | `--paper` near-black |
| Card (default) | `--paper-2` cream (same as page) | `--paper-2` slightly lighter near-black |
| Card (elevated) | `--paper-card` warm white | `--paper-card` lighter dark |
| Feature section | `--sage` / `--ultra-tint` / `--ink` | `--ultra-tint` / `--ultra-deep` / `--ink` |

In light mode the difference between page and default cards is tiny — they read as the same surface, separated only by hairline borders. The "elevated" surface is for dashboards needing card affordance. In dark mode, surfaces step up in lightness clearly: page → card → elevated card → accent.

---

## Typography

### Stack

```css
--font-display: 'DM Sans', sans-serif;     /* headlines, big numbers */
--font-body: 'Geist', system-ui, sans-serif; /* paragraphs, UI labels, button text */
--font-mono: 'JetBrains Mono', monospace;  /* tags, codes, metadata, dates */
```

- **DM Sans** is the display workhorse — variable, but use **only weights 500 and 700**. Geometric without being clinical.
- **Geist** handles all body and UI text. Weights 400, 500, 600.
- **JetBrains Mono** is reserved exclusively for editorial labels (`PLATE 01`, `ISSUE 14`, version numbers, timestamps). Always uppercase, always letter-spacing `.08em` to `.14em`. Never mono for body text or buttons.

### Type scale

| Token | Use | Size |
|---|---|---|
| Display XL | Hero h1 | `clamp(56px, 8.4vw, 132px)` |
| Display L | Section h2 | `clamp(34px, 4vw, 56px)` |
| Display M | Card h3 | 24px |
| Display S | Subsection h4 | 22px |
| Body L | Lead paragraph | 17px |
| Body M | Default body | 13.5px |
| Body S | Captions, metadata | 12.5px |
| Mono | Labels, tags, codes | 10px to 11px |

### Display (DM Sans)

Headlines mix weight 500 (regular emphasis) and weight 700 (strong emphasis) within the same line. The contrast does the visual work — the reader's eye lands on the bold word.

```css
/* Hero h1 */
font-family: 'DM Sans', sans-serif;
font-weight: 500;
font-size: clamp(56px, 8.4vw, 132px);
line-height: 0.96;
letter-spacing: -0.04em;
color: var(--ink);

/* Bold em inside the h1 */
em {
  font-style: normal;
  font-weight: 700;
}
```

**Headlines must break cleanly on meaning.** Three short lines with a clear semantic unit on each beats one long line with awkward orphans. Read the breaks aloud — if you stumble, the break is in the wrong place.

```
Good:                       Bad:
Strategy                    We help ambitious
and design                  teams turn complex strategy
that ships.                 into systems that ship.
```

### Body (Geist)

```css
/* Lead paragraph */
font-size: 17px;
line-height: 1.45;
letter-spacing: -0.005em;
color: var(--ink-soft);
max-width: 42ch;

/* Body */
font-size: 13.5px;
line-height: 1.55;
color: var(--ink-soft);

/* Small UI text */
font-size: 12.5px;
line-height: 1.5;
color: var(--ink-soft);
```

Always cap reading-width with `max-width` in `ch`. Lead paragraphs at `42ch`, regular body at `36ch` to `40ch`. Lines wider than 65 characters are illegible.

### Mono (JetBrains Mono)

```css
/* Eyebrow / mono label */
font-family: 'JetBrains Mono', monospace;
font-size: 10px to 11px;
font-weight: 500;
letter-spacing: 0.08em to 0.14em;
text-transform: uppercase;
color: var(--ink-soft);
```

Mono labels often have a leading rule (`— PLATE 01`) drawn with a 16px `::before`:

```css
.eyebrow::before {
  content: '';
  width: 16px;
  height: 1px;
  background: currentColor;
  display: inline-block;
  margin-right: 8px;
  vertical-align: middle;
}
```

### Mono label conventions

| Use | Example |
|---|---|
| Issue / version | `ISSUE 14, SPRING 2026` |
| Plate / figure | `PLATE 01` |
| Status | `BOOKING Q3 2026` |
| Date | `06 MAY 2026 · WEEK 19` |
| Location | `BUE / NYC` |
| Section index | `SERVICES, 01 / 05` |
| Time | `2 WEEKS, FIXED SCOPE` |

---

## Spacing & layout

### Container

```css
max-width: 1440px;
margin: 0 auto;
padding: 64px;  /* desktop */
padding: 40px;  /* tablet (max-width: 1100px) */
padding: 24px;  /* mobile (max-width: 900px) */
```

### Vertical rhythm

Sections breathe. Use generous padding top and bottom.

```css
/* Default section */
padding: 128px 64px;

/* Feature / manifesto / contact (more dramatic) */
padding: 144px 64px;

/* Hero */
padding: 88px 64px 120px;
```

### Internal section spacing

```css
/* Section header */
margin-bottom: 72px;
padding-bottom: 22px;
border-bottom: 1px solid var(--rule);

/* Group spacing within a section */
gap: 32px;  /* card grids */
gap: 16px;  /* tight grids */
gap: 56px;  /* between hero headline and CTAs */
```

### Grid

A 12-column grid for service cards and work tiles. Cards span 4, 5, 6, or 7 columns to create asymmetric rhythm.

```css
.svc-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 16px;
}

.svc:nth-child(1) { grid-column: span 4; }
.svc:nth-child(2) { grid-column: span 4; }
.svc:nth-child(3) { grid-column: span 4; }
.svc:nth-child(4) { grid-column: span 5; }
.svc:nth-child(5) { grid-column: span 7; }
```

### Hairlines

The interface relies on 1px hairlines for division. Always use `var(--rule)` or `var(--rule-soft)`, never raw black. No box-shadows for separation — hairlines instead.

```css
border-top: 1px solid var(--rule);
border-bottom: 1px solid var(--rule);
```

---

## Border radius

| Element | Radius |
|---|---|
| Pills, buttons, tags | `999px` (fully rounded) |
| Cards (large) | `14px` to `18px` |
| Cards (compact) | `8px` to `10px` |
| Image containers | `4px` to `6px` (nearly square) |
| Avatars (square) | `4px` |
| Avatars (round) | `50%` |

Images use a tight `4px` radius rather than rounded corners — the goal is "framed plate in a magazine," not "rounded card."

---

## Components

### Eyebrow / mono label

```html
<span class="eyebrow">Issue 14, Spring 2026</span>
```

```css
.eyebrow {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--ink);
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
.eyebrow::before {
  content: '';
  width: 16px;
  height: 1px;
  background: currentColor;
  display: inline-block;
}
```

### Pill button (primary)

```html
<a class="btn" href="#">Start a project <span class="btn-arrow">↗</span></a>
```

```css
/* Light mode: ink pill */
.btn {
  background: var(--ink);
  color: var(--paper);
  padding: 14px 22px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 500;
}
.btn:hover { background: var(--ultra); }
.btn:hover .btn-arrow { transform: translate(2px, -2px); }

/* Dark mode: lavender pill */
[data-theme="dark"] .btn {
  background: var(--ultra);
  color: var(--paper);
}
[data-theme="dark"] .btn:hover { background: var(--ultra-deep); }
```

The arrow `↗` always animates up-and-right on hover (`translate(2px, -2px)`) — a consistent micro-interaction.

### Pill button (ghost)

```css
.btn-ghost {
  background: transparent;
  border: 1px solid var(--rule);
  color: var(--ink);
  padding: 14px 22px;
  border-radius: 999px;
}
.btn-ghost:hover { border-color: var(--ink); }
```

### Tag pill

```css
.tag {
  font-family: 'JetBrains Mono', monospace;
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  border: 1px solid var(--rule);
  color: var(--ink);
  border-radius: 999px;
  padding: 5px 11px;
  background: rgba(255,255,255,.5);  /* light mode */
  background: rgba(15,19,16,.4);     /* dark mode */
}
```

### Status pill

For dashboards. Each variant has a tinted bg, colored border, and matching text. Always a leading dot AND text AND color — never color alone.

```css
.status-pill {
  font-family: 'JetBrains Mono', monospace;
  font-size: 10px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  padding: 4px 9px;
  border-radius: 999px;
  border: 1px solid currentColor;
  display: inline-flex;
  align-items: center;
  gap: 5px;
}
.status-pill::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}

.status-pill.in-progress { color: var(--ultra); background: var(--ultra-soft); }
.status-pill.review { color: var(--amber); background: rgba(184,92,0,.07); }
.status-pill.shipped { color: var(--green); background: rgba(25,163,106,.07); }
.status-pill.draft { color: var(--ink-low); background: var(--paper-2); }
```

### Card (default)

```css
.card {
  background: var(--paper-2);
  border: 1px solid var(--rule);
  border-radius: 14px;
  padding: 28px 26px 24px;
  position: relative;
}
```

### Card (rotating pastels)

When showing a row of cards, rotate background colors:

```css
.card:nth-child(1) { background: var(--paper-2); }   /* cream */
.card:nth-child(2) { background: var(--ultra-tint); } /* lavender */
.card:nth-child(3) { background: var(--rose-tint); }  /* rose */
.card:nth-child(4) { background: var(--pale); }       /* pale blue */
.card:nth-child(5) { background: var(--paper-2); }   /* cream */
```

### Editorial side row

For "spec sheet" style metadata blocks (Studio / Now / Selected).

```html
<div class="hero-side-row">
  <span class="mono-label">Studio</span>
  <p>A nine person studio for product, brand, and the connective tissue in between.</p>
</div>
```

```css
.hero-side-row {
  display: grid;
  grid-template-columns: 72px 1fr;
  gap: 16px;
  align-items: start;
  padding-top: 16px;
  border-top: 1px solid var(--rule);
}
```

The 72px label column never changes width. The label is mono uppercase; the description is regular body.

---

## Patterns

### Imagery & duotone

All photography is treated with a lavender duotone filter. This is the brand's signal — every image passes through it.

```html
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <defs>
    <filter id="duotone-blue" color-interpolation-filters="sRGB">
      <feColorMatrix type="matrix" values="
        .33 .56 .11 0 0
        .33 .56 .11 0 0
        .33 .56 .11 0 0
        0 0 0 1 0"/>
      <feComponentTransfer>
        <feFuncR type="table" tableValues="0.26 0.86"/>
        <feFuncG type="table" tableValues="0.24 0.84"/>
        <feFuncB type="table" tableValues="0.42 0.93"/>
      </feComponentTransfer>
    </filter>
  </defs>
</svg>
```

```css
img {
  filter: url(#duotone-blue) contrast(1.05);
  -webkit-filter: url(#duotone-blue) contrast(1.05);
}
```

For dark mode, retune the table values to map dark pixels deeper:

```xml
<feFuncR type="table" tableValues="0.08 0.62"/>
<feFuncG type="table" tableValues="0.06 0.60"/>
<feFuncB type="table" tableValues="0.20 0.78"/>
```

**Subjects:** botanical and editorial — peonies, poppies, single florals, abstract close-ups. Avoid stock people, office shots, technology product photos. The duotone treatment alone is not enough; the subject matter must support the editorial aesthetic.

**Captions:** always include a mono caption beneath the image — `PLATE 01 / FIELD STUDY, LAVENDER. 2025.` This grounds the duotone as an intentional editorial choice rather than a gimmick.

### Texture

A subtle grain overlay sits on every page. It does not draw attention, but removes digital flatness.

```css
body::before {
  content: '';
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 100;
  opacity: .06;  /* light mode */
  opacity: .08;  /* dark mode */
  mix-blend-mode: multiply;  /* light mode */
  mix-blend-mode: screen;    /* dark mode */
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.92' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>");
}
```

### Voice & copy

The studio writes plainly. Sentences are short. Jargon is rare. When in doubt, cut a clause.

- Bad: *"We leverage cutting-edge methodologies to architect transformative brand ecosystems for forward-thinking enterprises."*
- Good: *"We help ambitious teams turn strategy into systems that ship."*

**Punctuation & case:**

- **No em dashes.** Replace with commas, periods, or parentheses.
- **Use the Oxford comma.**
- **Full sentences with periods**, even in card descriptions.
- **Headlines in sentence case**, not title case. Mono labels are ALL CAPS.

**Numerals:**

- Spell out numbers under 10 in body copy ("nine people, four time zones") unless they're statistics.
- Use numerals in mono labels and metrics ("9 PEOPLE, 4 TIME ZONES").
- Use numerals with units ("6 to 10 weeks") in spec sheets.

### Accessibility

- Text on cream uses `--ink` (~21:1 contrast). Body text on lavender-tint or rose-tint uses `--ink-soft` (still 11:1+).
- Every interactive element has a hover state with at least a hairline change.
- Buttons need a clear focus ring — ghost buttons add `outline: 2px solid var(--ultra); outline-offset: 2px;` on `:focus-visible`.
- Mono labels at 10px are always uppercased with letter-spacing — case matters for legibility at this size.
- Never use color alone to communicate state. Status pills always carry a leading dot AND text AND color.

---

## Motion

Movement is restrained. The interface should feel calm, never distracting.

```css
transition: background .25s, transform .25s;  /* most elements */
transition: all .25s ease;                     /* buttons */
transition: transform .35s ease;               /* large hover lifts (work tiles) */
```

**Hover lift** — cards and tiles lift slightly:

```css
.svc:hover { transform: translateY(-2px); }
.work-item:hover .work-frame { transform: translateY(-6px); }
```

**Arrow animation** — buttons with `↗` translate up-and-right on hover:

```css
.btn-arrow { transition: transform .25s ease; }
.btn:hover .btn-arrow { transform: translate(2px, -2px); }
```

**Reveal stagger** — hero text rises in:

```css
.reveal > * {
  opacity: 0;
  transform: translateY(14px);
  animation: rise .9s cubic-bezier(.2,.7,.2,1) forwards;
}
.reveal > *:nth-child(1) { animation-delay: .05s; }
.reveal > *:nth-child(2) { animation-delay: .15s; }
.reveal > *:nth-child(3) { animation-delay: .25s; }

@keyframes rise {
  to { opacity: 1; transform: none; }
}
```

---

## Anti-patterns

- Don't use pure white (`#FFF`) — use `--paper-2`; pure white breaks the warm-cream canvas.
- Don't use pure black (`#000`) — use `--ink`; the only exception is phone notches in mobile mockups.
- Don't add drop shadows beyond a hairline — this interface uses borders, not depth, for separation.
- Don't add gradients beyond the duotone filter and the manifesto/contact radial wash — extra gradients muddy the flat editorial surface.
- Don't pull in icon libraries with their own visual language — use `↗` for outbound links, `→` for inline forward, mono symbols for editorial moments; Lucide-react is acceptable only for dashboards.
- Don't introduce fonts beyond DM Sans, Geist, and JetBrains Mono — three families hold the whole identity.
- Don't color display headlines — headlines are always ink, because colored display type breaks the typographic discipline.
- Don't use any accent for body text — lavender is for accent only; body on cream must be ink.
- Don't repeat a pastel in adjacent cards — pastels rotate so the row stays editorial, not branded.
- Don't reach for box-shadows to separate sections — hairline rules carry all division in this system.
- Don't let line length run past ~65 characters — cap reading width with `ch` or the body becomes illegible.
- Don't add bounce, spring physics, parallax, scroll-jacking, or unprovoked animation — motion only on user action or page entry.
