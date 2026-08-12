# Midnight Command Center — Design System

Self-contained guidelines for reproducing the Midnight Command Center design language. The system applies across surfaces; structure should follow the brief, not a fixed template.

---

## Theme

A sophisticated, focused dark-mode experience reminiscent of a command center dashboard. Deep charcoal base, subtle layered surfaces for depth, distinctive muted text colors, and a single vivid lime accent applied selectively to primary actions. Theme: **dark only**.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Inter + IBM Plex Mono with `cv01, ss03` features), color tokens, surface layering, spacing, radii, and motion. Every surface inherits these.
2. **Essential components** (use as the brief requires) — cards (default/elevated/nested), buttons (primary lime + secondary graphite + ghost), inputs, status pills, severity badges, tags, chips, avatars, basic nav, tables. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on marketing and hero surfaces. For this system, the showcase patterns include: **the kicker pill on landings, the hero grid mask, the blue glow halo background, the mono build-string footer (`v2.4.1 · build 38c1e7a · ALL SYSTEMS NOMINAL`), the event log / activity stream as its own section, big italic + storm-cloud emphasis headlines, and the marketing-CTA section with mesh background.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal header (brand mark, plus basic nav only if the brief implies it)
- The requested content (grid of cards, single form, table) using the standard component recipes
- A filter row only if filtering is implied
- An optional single-line footer

That is the whole page. Do **not** add hero sections with marketing copy, KPI/stat strips, activity feeds, release-note bands, pull quotes, numbered feature rows, illustrated characters, footer signatures, or any showcase pattern unless the brief explicitly asks for it. Lime stays one-per-screen as the primary action regardless of how stripped-down the page is.

### Example compositions are examples

Any reference dashboards, websites, or marketing recipes shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it this system's voice.

---

## 1. Tokens

### Colors

```css
:root {
  /* Surfaces — layered from deepest to most elevated */
  --color-pitch-black: #08090a;     /* page canvas, deepest level */
  --color-graphite: #0f1011;        /* primary cards on the canvas */
  --color-deep-slate: #161718;      /* elevated cards, hover states, active rows */
  --color-charcoal-grey: #23252a;   /* borders, 1px dividers between cells */
  --color-muted-ash: #323334;       /* tertiary borders, subtle separators */
  --color-gunmetal: #383b3f;        /* tertiary backgrounds, input fills */

  /* Text */
  --color-porcelain: #f7f8f8;       /* primary text, headlines, key data values */
  --color-light-steel: #d0d6e0;     /* secondary text, body copy */
  --color-storm-cloud: #8a8f98;     /* tertiary text, labels, descriptive */
  --color-fog-grey: #62666d;        /* metadata, timestamps, axis labels */

  /* Accents */
  --color-neon-lime: #e4f222;       /* PRIMARY ACTIONS ONLY — see rules below */
  --color-aether-blue: #5e6ad2;     /* decorative highlights, blue glows */
  --color-cyan-spark: #02b8cc;      /* informational accents, P3 severity, secondary data */
  --color-emerald: #27a644;         /* healthy, resolved, success */
  --color-warning-red: #eb5757;     /* firing, critical, P1, regressions */
  --color-amethyst: #8b5cf6;        /* decorative data series (3rd line in charts) */
}
```

**Custom additions (not in original spec but used consistently):**
- Amber `#f6b94e` — the warning-amber for acknowledged states, P2 severity, degraded. The original spec didn't include a true amber, so this was introduced and should be used everywhere "between" red and emerald is needed.

### Color rules

**The single most important rule of this system: `--color-neon-lime` (#e4f222) is never used as a decorative color. It marks one thing per screen, and that thing is the primary action.**

| Context | Where lime appears |
|---|---|
| Website | "Start observing" CTA, one feature tag, the pricing card halo, kicker pill tag |
| Dashboard | "New panel" CTA, the requests/sec sparkline, quota bar fill, one active card chip |
| App | "Resolve" button, the active-incident left edge marker |
| Mobile | "Resolve" button on detail screen, today's column outline, the user's avatar in lists |

Rule of thumb: if you can identify more than 3-4 lime elements on a single screen, remove some.

**Text color hierarchy**

Never use plain white (`#fff`). Porcelain is the white. The four-level text hierarchy (Porcelain → Light Steel → Storm Cloud → Fog Grey) is mandatory — pick a level for every piece of text based on its importance.

**Status semantics (memorize these)**

| Color | Meaning |
|---|---|
| `--color-warning-red` (#eb5757) | Firing alerts, critical errors, P1 severity |
| `#f6b94e` amber | Acknowledged, P2, degraded — between firing and healthy |
| `--color-emerald` (#27a644) | Healthy, resolved, success states |
| `--color-cyan-spark` (#02b8cc) | Informational data, P3 severity, secondary status |
| `--color-amethyst` (#8b5cf6) | Decorative data series in charts (3rd line, etc.) |

### Surface layering

Every screen uses at least three surface levels. A common pattern:

```
Page canvas         → Pitch Black (#08090a)
Primary cards       → Graphite (#0f1011)
Hover/active states → Deep Slate (#161718)
Borders/dividers    → Charcoal Grey (#23252a)
```

Elevation comes from layered surfaces, not shadows. When you need to elevate something, bump it up one surface level.

### Typography

```css
:root {
  --font-sans: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-mono: 'IBM Plex Mono', ui-monospace, SFMono-Regular, Menlo, monospace;
}

body {
  font-family: var(--font-sans);
  font-feature-settings: "cv01", "ss03";
  -webkit-font-smoothing: antialiased;
  line-height: 1.4;
  letter-spacing: -0.13px;
}
```

**Always include `font-feature-settings: "cv01", "ss03"` on `body`.** The `cv01` swaps the alternate `1`, and `ss03` is the alternate `g`. Subtle, but together they shift Inter from "generic system sans" to "Linear-flavored." Without them the brand feels off.

**Type scale**

| Role | Size | Line Height | Letter Spacing | When to use |
|---|---|---|---|---|
| caption | 10px | 1.4 | -0.1px | Smallest mono labels, table headers |
| body | 13-14px | 1.4 | -0.13px | All UI body text |
| heading | 24-26px | 1.25-1.33 | -0.022em | Section titles, detail-view H1s |
| heading-lg | 48px | 1.2 | -0.022em | Landing page section heads |
| display | 64-72px | 1.0-1.05 | -0.045em | Hero headlines |

**Mono usage**

The mono is more present than people expect. Use it for any data that feels "machine-emitted":
- IDs and codes (`INC-1247`, `7c2af1`)
- Versions (`v2.4.1`)
- Regions, environments (`eu-west-1`, `production`)
- Counts and units (`12.4K/s`, `2.14s`, `+792%`)
- Times and timestamps (`21:42 UTC`, `14m ago`)
- Short status labels (`P1`, `STATUS`, `FIRING`, `LIVE`)
- Section eyebrows (uppercase, letter-spacing 0.06-0.08em)

**Letter spacing — always tighten**

Inter at this size and weight needs negative tracking to feel right:
- Display (48px+): `-0.022em` to `-0.045em`
- Headlines (24px): `-0.022em`
- Body (13-15px): `-0.13px` (literal pixel, not em)
- Mono: `-0.15px`
- Mono uppercase eyebrows: `+0.06em` to `+0.08em` (these *expand*, not tighten)

### Spacing & layout

Base unit: **4px**. Density: compact (inside elements), generous (between blocks).

```css
:root {
  --spacing-4: 4px;    --spacing-8: 8px;
  --spacing-12: 12px;  --spacing-16: 16px;
  --spacing-20: 20px;  --spacing-24: 24px;
  --spacing-32: 32px;  --spacing-40: 40px;
  --spacing-48: 48px;  --spacing-64: 64px;
  --spacing-80: 80px;  --spacing-96: 96px;
  --spacing-128: 128px;
}
```

**The principle: compactness *inside* elements, generosity *between* them.**

Linear's "compact density" applies to information density within a card, not to the relationships between cards. After iteration, the sweet spot is:

- Inside small cells (incident cards, table rows): **12-16px** padding
- Inside large cards (summary blocks, charts): **20-22px** padding
- Section gaps inside a long page: **36-40px** between blocks
- Detail-view content padding: **40px 48px** (top/sides)
- Right metadata panel padding: **28px 24px**, with **30px** gap between blocks
- Timeline item gap: **24px**
- Element gap inside compact rows: **8px**

### Border radius

```css
:root {
  --radius-tag: 2px;     /* small chips, tags, table headers */
  --radius-md: 6px;      /* buttons, inputs, small cards */
  --radius-xl: 12px;     /* larger cards, modals, primary containers */
  --radius-pill: 9999px; /* hero kickers, mobile filter chips */
}
```

Mobile uses larger radii (10-16px on cards) without breaking the brand — feels more touch-native.

### Shadows

Elevation comes from layered surfaces, not shadows. Use shadows in only three cases:

```css
/* 1. Default card sitting on the canvas */
--shadow-sm: rgba(0, 0, 0, 0.4) 0px 2px 4px 0px;

/* 2. Inset border for elevated cards (looks like a hairline frame) */
--shadow-subtle: rgb(35, 37, 42) 0px 0px 0px 1px inset;

/* 3. Subtle bevel for secondary buttons (the "recessed button" look) */
--shadow-button:
  rgba(255, 255, 255, 0.03) 0 0 0 1px inset,
  rgba(255, 255, 255, 0.04) 0 1px 0 0 inset,
  rgba(0, 0, 0, 0.6) 0 0 0 1px,
  rgba(0, 0, 0, 0.1) 0 4px 4px 0;

/* 4. Heavy shadow for hero product mockups only */
--shadow-xl: rgba(8, 9, 10, 0.6) 0px 4px 32px 0px;
```

Don't add shadows to elevate things. If something needs to feel elevated, change its surface color (Graphite → Deep Slate).

---

## 2. Components

### Buttons

```html
<!-- Primary: lime, one per screen -->
<button class="btn btn-primary">Resolve</button>

<!-- Secondary: graphite with subtle bevel -->
<button class="btn btn-secondary">Acknowledge</button>

<!-- Ghost: text-only, for tertiary -->
<button class="btn btn-ghost">Snooze</button>
```

```css
.btn {
  height: 32px;
  padding: 0 12px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 6px;
  letter-spacing: -0.13px;
}
.btn-primary {
  background: var(--color-neon-lime);
  color: var(--color-pitch-black);
  font-weight: 510;
}
.btn-secondary {
  background: var(--color-graphite);
  color: var(--color-porcelain);
  box-shadow: var(--shadow-button);
}
.btn-ghost {
  color: var(--color-light-steel);
}
.btn-ghost:hover {
  color: var(--color-porcelain);
  background: var(--color-graphite);
}
```

**Mobile buttons** are 44px tall with 10px radius (Apple HIG minimum touch target).

### Cards

Three card variants, in increasing prominence:

```css
/* Default card — most common */
.card {
  background: var(--color-graphite);
  border: 1px solid var(--color-charcoal-grey);
  border-radius: 12px;
  padding: 16-22px;
}

/* Elevated card — for prominent groups */
.card-elevated {
  background: var(--color-deep-slate);
  border: 1px solid var(--color-charcoal-grey);
  border-radius: 12px;
  /* The inset 1px hairline */
  box-shadow: rgb(35, 37, 42) 0 0 0 1px inset;
}

/* Nested card — sub-content inside a larger card */
.card-nested {
  background: var(--color-pitch-black);
  border-radius: 8px;
  padding: 8-12px;
}
```

### Input fields

```css
.input {
  background: var(--color-graphite);
  border: 1px solid var(--color-charcoal-grey);
  color: var(--color-porcelain);
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 13px;
}
.input::placeholder {
  color: var(--color-storm-cloud);
}
```

### Status indicators

The signature live/firing pattern:

```html
<span class="status-pill">
  <span class="status-dot firing"></span>
  Firing
</span>
```

```css
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--color-storm-cloud);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}
.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}
.status-dot.firing {
  background: var(--color-warning-red);
  box-shadow: 0 0 6px var(--color-warning-red);
  animation: blink 1.6s ease-in-out infinite;
}
.status-dot.ack { background: #f6b94e; }
.status-dot.resolved {
  background: var(--color-emerald);
  box-shadow: 0 0 6px var(--color-emerald);
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}
```

**Live states glow + blink. Static states don't.** This is the difference between "happening right now" and "recorded state."

### Severity badges

```css
.sev { padding: 2px 6px; border-radius: 3px; font-family: var(--font-mono); font-size: 10px; }
.sev.p0 { background: var(--color-warning-red); color: var(--color-pitch-black); }
.sev.p1 { color: var(--color-warning-red); border: 1px solid rgba(235, 87, 87, 0.3); background: rgba(235, 87, 87, 0.10); }
.sev.p2 { color: #f6b94e; border: 1px solid rgba(246, 185, 78, 0.3); background: rgba(246, 185, 78, 0.10); }
.sev.p3 { color: var(--color-cyan-spark); border: 1px solid rgba(2, 184, 204, 0.3); background: rgba(2, 184, 204, 0.10); }
```

Only P0 is filled. Everything else is outlined-on-transparent. Visual weight scales with actual severity.

### Tags & chips

```css
/* Tag — small, mono, low-emphasis */
.tag {
  padding: 3px 8px;
  border-radius: 2px;
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--color-storm-cloud);
  background: var(--color-deep-slate);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

/* Filter chip — toggle-able */
.chip {
  padding: 4px 10px;
  border-radius: 2px;
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--color-storm-cloud);
  border: 1px solid var(--color-charcoal-grey);
}
.chip.active {
  color: var(--color-porcelain);
  background: var(--color-deep-slate);
  border-color: var(--color-gunmetal);
}
```

### Avatars

8px overlap on stacks, 1.5px border in the surrounding bg color (so the cutout looks clean):

```css
.av { width: 18px; height: 18px; border-radius: 50%; }
.av.a1 { background: linear-gradient(135deg, var(--color-amethyst), var(--color-aether-blue)); }
.av.a2 { background: linear-gradient(135deg, var(--color-cyan-spark), #1a5b8c); }
.av.a3 { background: linear-gradient(135deg, var(--color-emerald), #154d2a); }
.av.a4 { background: linear-gradient(135deg, #f6b94e, #8b5e22); }
```

**The user themselves (when they appear in their own UI) gets a lime avatar with pitch-black initials.**

### Inline `<code>`

```css
code {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--color-neon-lime);
  background: var(--color-pitch-black);
  padding: 1px 5px;
  border-radius: 3px;
  border: 1px solid var(--color-charcoal-grey);
}
```

This is the **only** non-action place lime appears with meaningful frequency. Used for: deploy hashes, file paths, code identifiers, query snippets in summary text.

### Section eyebrow (the section-break pattern)

```html
<div class="section-eyebrow">
  <span class="dot"></span>
  Six instruments. One night.
</div>
<h2 class="section-title">Everything between first light and final FITS.</h2>
```

```css
.section-eyebrow {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--color-storm-cloud);
  letter-spacing: 0.08em;
  text-transform: uppercase;
}
.section-eyebrow .dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  background: var(--color-neon-lime);
  border-radius: 50%;
  margin-right: 8px;
}
```

This is the system's way of "punctuating" a section without being decorative.

---

## 3. Cross-context patterns

### The "1px gap on charcoal" grid

Used for any row or grid of equal-weight items (features, KPIs, stats, services bar, pricing). Produces crisp 1px dividers without `border-right` conflicts:

```css
.grid {
  display: grid;
  grid-template-columns: repeat(N, 1fr);
  gap: 1px;
  background: var(--color-charcoal-grey);
  border: 1px solid var(--color-charcoal-grey);
  border-radius: 12px;
  overflow: hidden;
}
.grid > .cell {
  background: var(--color-pitch-black);  /* or graphite */
  padding: 28px;
}
```

### The blue glow halo

Used in: hero backgrounds, final-CTA backgrounds, "live now" cards on mobile.

```css
background:
  radial-gradient(ellipse at 50% 50%, rgba(94, 106, 210, 0.10), transparent 60%),
  var(--color-pitch-black);
```

### The hero grid mask

Faint dot/line grid that fades out at edges, used as background texture on hero sections:

```css
.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(var(--color-charcoal-grey) 1px, transparent 1px),
    linear-gradient(90deg, var(--color-charcoal-grey) 1px, transparent 1px);
  background-size: 64px 64px;
  opacity: 0.18;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 30%, #000 30%, transparent 75%);
}
```

### Charts (always SVG, never canvas)

Standard chart structure:
- 1px **dashed** grid for X-axis ticks (charcoal)
- 1px **solid** grid for Y-axis ticks (charcoal)
- Gradient fill underneath the line (color → transparent at 0% → 30%)
- Mono axis labels in fog-grey, 10-11px
- For incidents/anomalies: shaded vertical region with labeled vertical dashed line

```html
<svg viewBox="0 0 800 240" preserveAspectRatio="none">
  <!-- Y-axis grid -->
  <g stroke="#23252a" stroke-width="1">
    <line x1="0" y1="40" x2="800" y2="40"/>
    <!-- ... -->
  </g>
  <!-- X-axis grid (dashed) -->
  <g stroke="#23252a" stroke-width="1" stroke-dasharray="2 4">
    <!-- ... -->
  </g>
  <!-- Gradient fill -->
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#02b8cc" stop-opacity="0.18"/>
      <stop offset="100%" stop-color="#02b8cc" stop-opacity="0"/>
    </linearGradient>
  </defs>
  <path d="..." fill="url(#g)"/>
  <path d="..." fill="none" stroke="#02b8cc" stroke-width="1.6"/>
</svg>
```

### Tables

```css
.table th {
  font-family: var(--font-mono);
  font-size: 10px;
  font-weight: 500;
  color: var(--color-fog-grey);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  background: var(--color-graphite);
  padding: 10px 18px;
}
.table td {
  padding: 10px 18px;
  border-bottom: 1px solid var(--color-charcoal-grey);
  font-size: 12px;
}
.table tbody tr:hover { background: var(--color-deep-slate); }
```

### Event log / activity stream

Mono everywhere, fixed-width columns (time + level + message):

```css
.log-item {
  display: grid;
  grid-template-columns: 70px 14px 1fr;
  gap: 10px;
  padding: 8px 18px;
  font-family: var(--font-mono);
  font-size: 11.5px;
}
```

Level color-coding:
- `OK` / `ACK` → emerald
- `INFO` / `DEPLOY` → cyan
- `WARN` → amber
- `CRIT` / `FIRE` / `ERR` → red

### Timeline (vertical with dot markers)

```css
.timeline {
  border-left: 1px solid var(--color-charcoal-grey);
  margin-left: 8px;
  padding-left: 24px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.tl-item::before {
  content: "";
  position: absolute;
  left: -29px; top: 5px;
  width: 9px; height: 9px;
  border-radius: 50%;
  background: var(--color-graphite);
  border: 1.5px solid var(--color-storm-cloud);
}
.tl-item.lime::before { background: var(--color-neon-lime); border-color: var(--color-neon-lime); }
.tl-item.red::before  { background: var(--color-warning-red); border-color: var(--color-warning-red); }
.tl-item.green::before { background: var(--color-emerald); border-color: var(--color-emerald); }
```

---

## 4. Things that look like decoration but aren't

These details are easy to mistake for "designer flourish" but are load-bearing for the brand:

1. **The kicker pill on landings** — rounded pill with mono tag inside (e.g., `v2.4`) + descriptive copy + `›` arrow. This pattern marks "what's new / one-line teaser" content. Recurring component, not decoration.

2. **Inset shadows on elevated cards** — `rgb(35, 37, 42) 0 0 0 1px inset`. Looks like nothing, but it's what makes a card feel "set into" the surface rather than "floating on top of it."

3. **The mono build-string in footers** — every product surface ends with one (`v2.4.1 · build 38c1e7a · ALL SYSTEMS NOMINAL`). It's the system's way of signaling "this is engineering-grade software."

4. **The `cv01, ss03` font features on Inter** — subtle, but together they shift Inter from generic to Linear-flavored. Always include them.

5. **Status dot box-shadows** — live/firing states glow (`box-shadow: 0 0 6-8px [color]`). Static states don't.

6. **Italic + Storm Cloud color in headlines** — the "instrument-grade" treatment. One word per headline, always. It's how the system handles emphasis without bold.

7. **Mono uppercase eyebrows above section headlines** — short, all-caps, mono, with a tiny lime dot prefix. They're the system's chapter markers.

---

## 5. Anti-patterns

Things that will break the look:

- **Don't use lime as a decorative or hover color.** The moment lime shows up in more than one place per screen, the entire visual hierarchy collapses.
- **Don't use box-shadow for elevation.** Elevation comes from layered surfaces (Pitch Black → Graphite → Deep Slate). Shadows are reserved for the four cases listed above.
- **Don't introduce new colors.** Especially: no light mode, no purple/pink/orange except the existing amethyst/amber. The palette is closed.
- **Don't use Inter for code or data.** Counts, IDs, timestamps, regions, and code → mono.
- **Don't mix radii inconsistently.** A card has one radius. A button has one radius. Don't put 8px and 10px and 6px buttons on the same screen.
- **Don't add gradients to buttons.** The CTA is flat lime, secondaries are flat graphite. Gradients only appear in: avatar fills, chart area-fills, hero/CTA radial glows, and the subtle "halo" on featured pricing cards.
- **Don't use generic icon sets at default thickness.** Icons in this system are stroked, stroke-width 1.4-1.6, no fills (except tiny indicator dots). Lucide icons at default `stroke-width: 2` will look wrong — bring them to 1.5 or 1.6.
- **Don't use plain underlines for inline links.** Links inside running text should be Porcelain or Light Steel with no underline; if they need to be highlighted, use Aether Blue or Cyan Spark depending on context.
- **Don't use Title Case in mono labels.** Mono labels are either ALL CAPS (eyebrows, status, tags) or lowercase (code, paths). Never `Mixed Case`.
- **Don't crowd the page.** When in doubt, add more space *between* blocks. Compactness inside, generosity between.

---

## 6. Quick decision tree

When implementing a new component:

1. **Is it a primary action?** → Lime fill. (One per screen.)
2. **Is it a secondary action?** → Graphite background + the subtle button shadow.
3. **Is it a status indicator?** → Use the colored status dot pattern (with glow if live).
4. **Is it data/a count/a timestamp/an ID?** → Mono.
5. **Is it a section break?** → Eyebrow with lime dot + 24-32px headline.
6. **Is it a list of equal-weight items?** → 1px-gap-on-charcoal grid.
7. **Does it need elevation?** → Bump it up one surface level (Pitch Black → Graphite, or Graphite → Deep Slate). Don't add shadows.
8. **Is it a piece of running text that needs emphasis?** → Italic + Storm Cloud color. Don't bold.

---

The system is built to be consistent across surfaces — that's the point. Compose from the components and cross-context patterns above to fit whatever surface the brief asks for. The visual language carries the brand; the structure follows the content.
