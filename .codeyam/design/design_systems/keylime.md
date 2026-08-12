# KeyLime

*A warm editorial design system anchored in lime, paper, and ink.*

## Origin

KeyLime takes its name from the chartreuse accent color (`#D5F560`) that sits at the center of every surface decision. The name nods to the *key* in keystone: lime is the hinge that connects the warm cream paper grounds, the deep ink type, and the muted sage workspace tones. Take lime away and the system collapses to neutrals.

KeyLime is built for products that want editorial confidence without leaning on serifs. It pairs warm paper-toned backgrounds with a single sans-serif voice (Manrope), introduces controlled drama through chamfered corner cuts, and grounds imagery in a halftone bitmap treatment that makes photos read as printed onto the page rather than placed on top of it.

## When to use

KeyLime fits products that need to feel:
- Considered, slow, gallery-adjacent
- Editorial without being precious
- Confident across both marketing pages and product surfaces (it spans both)
- Distinct from typical SaaS dashboard aesthetics

KeyLime is the wrong fit when the product needs neon brand expression, strict accessibility-first muted palettes, or display serif personality. The lime accent is bold, and there is no muted alternative.

---

## How to use this system

This document describes a design *language*, not a fixed page sequence. It has three layers — apply them in order:

1. **Core language** (always applies) — typography (Manrope only, with the 700+400 weight pairing for editorial emphasis, the eyebrow with leading dash), color tokens, the limited radius ladder (6/10/24/100), the photo treatment recipe (B&W + multiply + bitmap grain), and the workspace sage canvas. Every surface inherits these.
2. **Essential components** (use as the brief requires) — default cards (paper, 24px radius, no shadows), pills (cream/paper backgrounds, 100px radius), tag-with-status-dot, primary lime CTA, icon buttons, sidebar navigation with active pill, avatars with grain, data tables. The everyday vocabulary needed to render almost any page.
3. **Showcase patterns** (opt-in, only when the brief calls for them) — the iconic flourishes that define this system's voice on hero and marketing surfaces. For KeyLime, the showcase patterns include: **the chamfered hero/anchor card (with the black star corner-mark), the lime hero card built as a marketing block with bracketed CTAs, the anchor-dark featured card as a "gravitational center," the marquee strip on mobile, the AI assistant gradient card, and large editorial display headlines with the 700/400 weight contrast as a hero device.** Do not add these just to "represent" the system; include them only when the brief explicitly asks for that kind of moment.

### Minimum viable composition

For a basic product surface — e.g. a listing page that shows a grid of items, each with a few fields — the entire page is:

- A minimal sidebar or top header (workspace nav, plus basic links only if the brief implies them)
- The requested content (grid of standard cards using the photo treatment for any imagery, single form, or data table) using the standard component recipes
- A filter row only if filtering is implied (pills with status dots)
- An optional profile pin / single-line footer

That is the whole page. Do **not** add chamfered hero cards, lime hero marketing blocks, anchor-dark featured cards, marquees, or any showcase pattern unless the brief explicitly asks for it. The B&W photo treatment + bitmap grain always applies to imagery — that's the core, not a showcase. The chamfer + star corner-mark is reserved for moments of importance the brief specifically calls for.

### Example compositions are examples

Any reference dashboards or marketing pages shown elsewhere in this file are **one** way to compose the system — not the template. **Structure follows the brief, not the examples.** Render only what the brief names; lean on the core language and essential components to give it KeyLime's voice.

---

## 1. Color

### Primary tokens (light)

| Token | Value | Role |
|-------|-------|------|
| `--paper` | `#F1EFEA` | Warm cream page background |
| `--cream` | `#ECEAE3` | Slightly darker subtle inner surface |
| `--ink` | `#0F0F0F` | Primary text and high-contrast surfaces |
| `--ink-soft` | `#1F1F1F` | Secondary near-ink |
| `--muted` | `#6E6E6E` | Secondary text on light surfaces |
| `--line` | `rgba(15,15,15,0.08)` | Hairlines and dividers |

### Workspace tokens (dashboard contexts only, light)

| Token | Value | Role |
|-------|-------|------|
| `--sage` | `#D2D6C5` | Workspace canvas / page bg |
| `--sage-deep` | `#9DA48F` | Darker sage for accent cards |
| `--sage-light` | `#E0E3D5` | Optional lighter sage |

### Brand accent (constant, never flips)

| Token | Value | Role |
|-------|-------|------|
| `--lime` | `#D5F560` | The keystone accent |
| `--lime-deep` | `#C6EC44` | Hover/pressed state for lime CTAs |

### Primary tokens (dark)

| Token | Value | Role |
|-------|-------|------|
| `--paper` | `#25251F` | Elevated dark surface (was page bg in light) |
| `--cream` | `#2F2F28` | More elevated inner surface |
| `--ink` | `#F1EFEA` | Primary text on dark |
| `--muted` | `#8a8a85` | Secondary text on dark |
| `--line` | `rgba(255,255,255,0.08)` | Hairlines on dark |

### Workspace tokens (dark)

| Token | Value | Role |
|-------|-------|------|
| `--sage` | `#14160F` | Very dark workspace canvas |
| `--sage-deep` | `#4D5247` | Muted sage accent |

### Token semantic flip rule

When dark mode toggles, the **role** of each token stays constant; only the **value** flips. `--paper` is always *the primary surface* (cream in light, near-black in dark). `--ink` is always *the primary text on that surface* (black in light, cream in dark). Components reference roles, not values.

**Exception:** `--lime` and `--lime-deep` never flip. Lime is the brand mark across themes.

### Contrast non-negotiables

1. **Lime always wears dark text.** Dark text on lime is a constant of this system. Light text on lime is a violation in every mode and every state.
2. **Anchor-dark cards stay dark in dark mode.** Cards meant as a maximum-contrast accent (efficiency cards, primary CTA buttons) hardcode `#0F0F0F` backgrounds and do not flip. They become the system's dark counterweight even when the page itself is dark.
3. **Lime cards are local light-mode islands.** Any card with a lime background must locally re-override `--ink`, `--paper`, and `--muted` back to their light-mode values, so descendant text and inner surfaces stay readable regardless of theme.

---

## 2. Typography

### Family

Manrope, single source of truth. No serif partner. No display alternative. No monospace exception. Weights used: 400, 500, 600, 700, 800.

```css
font-family: 'Manrope', sans-serif;
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
```

### Type scale and rhythm

| Role | Size | Weight | Tracking | Notes |
|------|------|--------|----------|-------|
| Hero | `clamp(56px, 8vw, 124px)` | 700 | `-0.05em` | Tight, near-crashing |
| Page title | 32 to 36px | 700 | `-0.04em` | Line height 0.95 |
| Card title | 24 to 32px | 700 | `-0.03em` | Line height 1.0 |
| Body | 14 to 16px | 400 to 500 | `-0.01em` | Line height 1.5 to 1.7 |
| Eyebrow | 10px | 500 | `0.20em` | UPPERCASE always |
| Numerals | match parent | 700 | `-0.04em` | Tight, never default tracking |

### Editorial accent rule

Where editorial moments call for a softer voice, drop weight (not family). A 700 + 400 pairing within the same line creates the bold/regular rhythm that classical serif italics would normally provide.

```html
<h2>Innovative <span class="accent">ideas</span> in Berlin.</h2>
<style>.accent { font-weight: 400; }</style>
```

### Eyebrow convention

Eyebrows lead with a leading dash glyph followed by uppercase tracked text:

```
— Featured
— Our team
— Connect with us
```

The leading mark provides a quiet visual anchor and reinforces the editorial voice. It is part of the system, not a typo.

---

## 3. Surfaces and shapes

### Radii

| Token | Value | Use |
|-------|-------|-----|
| `sm` | 6px | Small icon backgrounds, value chips |
| `md` | 10px | Image wrappers, secondary cards |
| `lg` | 24px | Primary cards (default) |
| `pill` | 100px | Pills, tags, oval buttons |
| `circle` | 50% | Avatars, icon buttons |

There are no in-between radii. 8px, 12px, 16px do not exist in KeyLime. This deliberate sparsity is what makes the system feel composed.

### Chamfer system

The signature shape language of KeyLime is a top-corner diagonal cut. It marks moments of importance (hero accents, anchor cards) without leaning on shadows or glow.

**Pure chamfer (square other corners):**
```css
--chamfer-tl: polygon(22% 0, 100% 0, 100% 100%, 0 100%, 0 28%);
--chamfer-tr: polygon(0 0, 78% 0, 100% 28%, 100% 100%, 0 100%);
--chamfer-bl: polygon(0 0, 100% 0, 100% 100%, 22% 100%, 0 78%);
```

**Chamfer with rounded other corners (the dashboard variant):**

A 21-point polygon that approximates a 24px arc on three corners while keeping the chamfered top-left. Use this when a chamfered card needs to live in a grid of standard rounded cards (the bento) so corner languages stay consistent.

### Star corner-mark

When a chamfered card has a chamfered cut, a black 4-point star is the canonical accent for that corner. The star sits **outside** the clipped element, anchored on top of the lime, never inside the clip-path (or it gets cropped). It is a stamp on the corner, not a decoration within it.

---

## 4. Imagery

KeyLime treats every photograph the same way: as a printed object on the paper surface, not a window cut into the layout.

### The four-step treatment

1. **Crop to abstraction.** Prefer fragments of paintings and sculptures over full scenes. A piece of marble drapery, a brushstroke close-up, a profile of a bust. Subject becomes texture.

2. **Reduce to grayscale.** All images are pure black-and-white. Color photography breaks the system.

3. **Bump contrast.** Apply `filter: grayscale(1) contrast(1.5) brightness(1.1)`. The high contrast lets the white parts of the image dissolve into the page surface during blending.

4. **Apply the blend.**
   - Light mode: `mix-blend-mode: multiply`. White pixels of the image become the page bg color (visually disappear into the paper).
   - Dark mode: `mix-blend-mode: screen` (no invert filter needed). Black pixels of the image become the page bg color in the dark.

### The bitmap grain overlay

Every image wrapper gets a fractal-noise SVG layered on top to add a printed/bitmap texture.

```css
.image-wrapper::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)' opacity='0.65'/></svg>");
  background-size: 160px 160px;
  mix-blend-mode: multiply;
  pointer-events: none;
  z-index: 1;
}
```

In dark mode the overlay needs `filter: invert(1)` plus `mix-blend-mode: screen` so the noise becomes light specks on the dark image rather than vanishing into it.

### Subject library

KeyLime's photo subjects, in priority order:

1. Marble sculpture profiles and details
2. Painting close-ups (brushwork, drapery, hands, cloth)
3. Architectural fragments (columns, gallery interiors, paper textures)
4. Abstract texture (stone, water, fabric)

Avoid: stock portraits, product photography, tech/office scenes, anything that reads as *a person looking at a camera*. Even when avatars are needed, use a sculpture profile or painted figure cropped to the face.

---

## 5. Components

### Card (default)

```css
background: var(--paper);
border-radius: 24px;
padding: 22px;
```

Primary surface for any content block. No shadows. Hierarchy comes from color contrast (paper vs. page bg), not depth.

### Lime card

```css
background: var(--lime);
color: #0F0F0F;
/* local overrides: light-mode-island */
--ink: #0F0F0F;
--paper: #F1EFEA;
--muted: rgba(15, 15, 15, 0.6);
--line: rgba(15, 15, 15, 0.15);
```

Used sparingly for hero moments. The local variable override turns the card into a "light-mode island" so descendant elements stay readable across themes.

### Anchor-dark card

```css
background: #0F0F0F !important;
color: #F1EFEA !important;
```

Cards that should feel like a deliberate maximum-contrast moment in the layout. These do not flip with theme: they stay black even on a black page, becoming the system's gravitational center.

### Pill

```css
background: var(--cream);
border-radius: 100px;
padding: 10px 18px;
font-size: 11px;
letter-spacing: 0.06em;
text-transform: uppercase;
```

Used for nav items, filters, tags, and stat chips. Hover state replaces background with paper or lime.

### Tag with status dot

A pill prefixed by a 6px colored dot indicating state. The dot color encodes status; the text label remains neutral. Status dots: lime for in-progress, amber for review, sage-deep for done, coral for blocked.

### CTA primary

```css
background: var(--lime);
color: #0F0F0F;        /* hardcoded, never flips */
border-radius: 100px;
padding: 14px 24px;
font-weight: 600;
letter-spacing: 0.06em;
text-transform: uppercase;
```

### Icon button

```css
width: 36 to 42px;
border-radius: 50%;
background: var(--paper);
border: none;
```

Round, no border. SVG inside uses `stroke="currentColor"` and inherits text color from parent. **In dark mode, icon buttons need an explicitly elevated background** (one shade lighter than `var(--paper)`, around `#2F2F28`) so they don't blend with the page bg.

### Avatar with grain

A circular image with the standard B&W treatment plus the bitmap grain overlay. Even at 26px in a table, avatars carry the same printed texture as larger images. This consistency at scale is what makes the system feel coherent.

### Data table

- Row dividers use `var(--line)`, never solid borders
- Hover state fills the row with `var(--cream)`
- Status pills + colored dots, never colored row backgrounds
- Avatar stacks overlap by -8px with a 2px paper-colored ring
- Project swatches at row-start in 28px rounded squares

### Sidebar navigation

- Width 232px on desktop
- Background `var(--paper)`, separating it from sage workspace bg
- Active state is a filled pill: `background: var(--ink); color: var(--paper);`
- Sections separated by uppercase eyebrow labels, never visible dividers
- Profile card pinned to the bottom with a cream background

### Marquee strip (mobile only)

- 56px tall horizontal strip pinned to the top of phone-frame contexts
- Continuous loop of a brand tagline at 30s linear infinite
- Animation never pauses on hover
- Used as a structural element, not a decoration

---

## 6. Theming

### Implementation

```js
const root = document.documentElement;
const stored = localStorage.getItem('theme');
if (stored === 'dark') root.dataset.theme = 'dark';

document.querySelector('.theme-toggle').addEventListener('click', () => {
  const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
  root.dataset.theme = next;
  localStorage.setItem('theme', next);
});
```

```css
[data-theme="dark"] {
  --paper: #25251F;
  --cream: #2F2F28;
  --ink: #F1EFEA;
  --muted: #8a8a85;
  --line: rgba(255, 255, 255, 0.08);
}
```

### What flips

- All semantic tokens (paper, cream, ink, muted, line)
- The workspace sage tokens (when present)
- Image blend mode (multiply to screen)
- Grain overlay filter (none to invert)

### What does not flip

- Lime, lime-deep
- Anchor-dark cards (they stay black)
- Lime card descendants (they stay light-mode-island)
- The black star corner-mark

### Required dark-mode adjustments

When the palette flips, three classes of element need explicit elevation bumps to avoid blending into the bg:

1. **Sidebars and topbar controls** that sit on the workspace canvas. Bump them from `var(--paper)` to `var(--cream)` or further (around `#2F2F28`).
2. **Bar fills and status indicators** with semi-transparent dark fills. Their alpha values must be inverted from `rgba(15,15,15,X)` to `rgba(255,255,255,X)`.
3. **Icon button backgrounds** in topbar context. Use a clearly elevated shade like `#2F2F28`, not `var(--paper)`, since the page bg in dark mode is already `var(--sage)` which sits very close to paper.

---

## 7. Motion

KeyLime motion is restrained. Three patterns total:

**Hover bg shift.** 200ms ease, background changes one shade. No transforms, no shadows.

**Pill stretch.** Menu items in oversized navigation slide right by 8px on hover (300ms ease). Used only on the largest typography in mobile menus.

**Marquee scroll.** A 30-second linear loop on long tagline text in mobile contexts. Never pauses, never speeds up. Unobtrusive.

That is the entire motion vocabulary. KeyLime does not bounce, parallax, fade-in on scroll, scale on hover, or reveal.

---

## 8. Rules

These rules are non-negotiable. Breaking them breaks the system.

1. **Manrope only.** No serif partner, no display alternative, no monospace exception.
2. **Lime always wears dark text.** Never light text on lime, in any theme, in any state.
3. **The grain overlay belongs on every image wrapper, every avatar, no exceptions.**
4. **Photos are art crops, never people-looking-at-cameras.**
5. **Cards have radii of 24px or chamfer.** No 8px, no 12px, no 16px in between.
6. **The bento grid does not mix square and round corners on the same level.** If one card is chamfered, others are either chamfered or rounded with the rounded-chamfer hybrid.
7. **Eyebrows are 10px uppercase with 0.20em tracking.** Never replaced with title-case "About" or sentence-case.
8. **No box-shadows.** Hierarchy comes from color, not depth.
9. **Anchor-dark cards do not flip with theme.** They stay black.
10. **In dark mode, never use light text on lime, and never use grey-on-grey for control surfaces.** If two adjacent elements share a similar luminance in dark mode, one must elevate.

---

## 9. Anti-patterns

These patterns break KeyLime:

- **Adding a serif accent font** (Instrument Serif, Garamond, Cormorant) for editorial moments. The system already does editorial through weight contrast, not family contrast.
- **Using lime for body text or hyperlinks.** Lime is a surface color, not a typography color.
- **Replacing the chamfer with a notch or fold-back illustration.** The chamfer is a clean polygon cut, never a graphic decoration.
- **Adding gradient fills to cards.** KeyLime is flat by religion. The single permitted gradient is the AI assistant card (paper-to-lime, 135deg).
- **Using the bitmap grain on flat color blocks.** The grain is a photo treatment exclusively.
- **Letting the page bg and the card surface have similar luminance in dark mode.** Always elevate.
- **Hover states that change icon color on icon buttons.** The button changes; the icon does not.
- **Using a generic dark grey card on lime.** When a card sits on a lime surface, it uses paper, not cream or grey.

---

*KeyLime / v1.0*
