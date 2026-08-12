# Plinth

> Architectural, structured, quiet. Editorial type on monochrome surfaces, B&W photography, parchment-light and deep-ink dark.

## Principles

1. **Quiet by default, dense when needed.** Whitespace is the primary spatial tool. Density only appears where data demands it (tables, ledgers, metric strips). Cards with shadows are forbidden; structure is communicated with hairline rules instead.

2. **Type does the work.** One sans (Manrope) and one mono (JetBrains Mono). Hierarchy comes from size, weight, and tracking, not color or chrome. Display type is always uppercase with tight negative tracking. Metadata and labels are always mono.

3. **Monochrome is the discipline.** No accent colors. The only colors in product UI are ink, mute, fade, and rule. A single optional positive/negative pair (deep green, deep oxide) is reserved for financial deltas only. All photography is forced to grayscale with a contrast bump.

4. **Brackets are punctuation.** Every label that names a zone, action, or category is wrapped in spaced brackets: `[ Reach out ]`, `[ 06 records ]`, `[ Active ]`. This is the signature of the system.

5. **Sections are numbered.** Every major section gets a section numeral: `01 /`, `02 /`, `03 /`. The slash and the trailing space are part of the mark.

6. **Three-zone metadata bar.** The top of every landing-style surface carries a three-zone mono bar: brand on the left, page subject in the center, location and date on the right. A theme toggle sits to the far right.

7. **Photography is the only image.** No illustrations, no icons-as-content. Decorative imagery is always black-and-white documentary or architectural photography. UI icons are 1.5px stroke line work.

---

## How to use this system

### Minimum viable composition

Bracket labels (`[ Reach out ]`), section numerals (`01 /`), a three-zone
mono metadata bar at the top, monochrome surfaces divided by hairline
rules, and black-and-white photography. If those exist on the screen, it
reads as Plinth.

### Example compositions are examples

Metric strips with vertical-rule cells, hairline-bordered data tables,
asymmetric editorial grids (50% indents, floating `©` marks), phone-framed
mobile previews, slide-out panels. Reach for these when the content calls
for it — opt-in flourishes, not signatures.

---

## Foundations

### Color tokens

Pure monochrome. Two themes. Implemented as CSS custom properties under `[data-theme]` on `:root`.

#### Light (parchment)

```css
:root[data-theme="light"] {
  --bg:        #EFECE5;          /* warm parchment, primary surface */
  --bg-alt:    #E7E3DA;          /* secondary surface */
  --bg-deep:   #DCD7CB;          /* tertiary, image frame */
  --ink:       #0E0E0C;          /* primary text, near-black warm */
  --ink-mute:  #6B6862;          /* secondary text */
  --ink-fade:  #A8A49C;          /* tertiary text, brackets, hints */
  --rule:      rgba(14,14,12,0.14);   /* hairline divider */
  --rule-soft: rgba(14,14,12,0.06);   /* even softer divider */
  --img-tint:  #C9C5BC;          /* image placeholder background */
  --pos:       #1F3A2E;          /* positive delta (optional, ledger only) */
  --neg:       #5A2018;          /* negative delta (optional, ledger only) */
}
```

#### Dark (deep ink)

```css
:root[data-theme="dark"] {
  --bg:        #0A0A09;
  --bg-alt:    #131312;
  --bg-deep:   #1C1C1A;
  --ink:       #EFECE5;
  --ink-mute:  #8E8A82;
  --ink-fade:  #5A574F;
  --rule:      rgba(239,236,229,0.16);
  --rule-soft: rgba(239,236,229,0.07);
  --img-tint:  #2A2926;
  --pos:       #B8D4C5;
  --neg:       #D9A097;
}
```

#### Theme toggle

A 32 to 40px square button with a 1px rule border. The icon is a half-filled circle (◐). On hover, the border darkens to `--ink` and the icon rotates 180deg over 400ms. Theme state persists to `localStorage` under `plinth-theme`. Every surface transitions `background` and `color` over `380ms ease` when the theme switches, so the change feels deliberate rather than instant.

```js
document.querySelector('[data-theme-toggle]').addEventListener('click', () => {
  const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
  root.dataset.theme = next;
  localStorage.setItem('plinth-theme', next);
});
```

### Palette alternatives (pigment swaps)

The system is monochrome by structure, not by color. The defining decision is *one tinted-neutral pair for paper and ink, plus muted/faded steps in the same hue family.* Swap the pigment pair and the entire system retones without losing its character.

Five palettes are defined. Graphite is the default (documented above). The other four follow the same token structure: replace the values under `[data-theme="light"]` and `[data-theme="dark"]` and nothing else changes.

The `--pos` and `--neg` tokens (financial deltas, the system's only color exception) stay constant across all palettes since they carry semantic weight that should not be re-tinted per brand. If `--neg` clashes with an ink hue (Oxide, Madder), the per-palette override at the bottom of each block fixes it.

#### 01 · Graphite (default)

Warm parchment paper, near-black ink. Quiet, architectural, the most photo-friendly base. Defined in the color tokens above.

#### 02 · Indigo (blue)

Pale ice paper, deep navy ink. Cool, technical, blueprint-adjacent without being literal. Good for engineering and finance-leaning products.

```css
:root[data-theme="light"] {
  --bg:        #EAEBF0;
  --bg-alt:    #E0E2EA;
  --bg-deep:   #D2D5E0;
  --ink:       #0C152A;
  --ink-mute:  #5E6680;
  --ink-fade:  #9CA3B5;
  --rule:      rgba(12,21,42,0.16);
  --rule-soft: rgba(12,21,42,0.07);
  --img-tint:  #BFC3D0;
}
:root[data-theme="dark"] {
  --bg:        #07091A;
  --bg-alt:    #0F1226;
  --bg-deep:   #181C33;
  --ink:       #EAEBF0;
  --ink-mute:  #8488A0;
  --ink-fade:  #55596E;
  --rule:      rgba(234,235,240,0.18);
  --rule-soft: rgba(234,235,240,0.08);
  --img-tint:  #232843;
}
```

#### 03 · Oxide (red)

Warm bone paper, deep oxide-red ink. Earthy, sanguine, leans toward print on aged paper. Use when the product wants a humanist, hand-pressed feel rather than a corporate one.

```css
:root[data-theme="light"] {
  --bg:        #EFE7E3;
  --bg-alt:    #E7DDD7;
  --bg-deep:   #DCCFC8;
  --ink:       #2A0D08;
  --ink-mute:  #6B5550;
  --ink-fade:  #A89B96;
  --rule:      rgba(42,13,8,0.16);
  --rule-soft: rgba(42,13,8,0.07);
  --img-tint:  #C9B9B0;
  /* --neg override: shift away from ink to stay legible */
  --neg:       #8A1A0A;
}
:root[data-theme="dark"] {
  --bg:        #150604;
  --bg-alt:    #1E0B08;
  --bg-deep:   #2A140F;
  --ink:       #EFE7E3;
  --ink-mute:  #8E807A;
  --ink-fade:  #5A4E48;
  --rule:      rgba(239,231,227,0.18);
  --rule-soft: rgba(239,231,227,0.08);
  --img-tint:  #382018;
  --neg:       #E8A89E;
}
```

#### 04 · Verdant (green)

Sage-cream paper, deep forest ink. Botanical without being soft. Reads natural, calm, considered. Suits sustainability, agriculture, and slower-pace consumer products. Since the ink itself is green, `--pos` is overridden to a deep umber so positive deltas remain readable; `--neg` stays at the default red.

```css
:root[data-theme="light"] {
  --bg:        #E9ECE3;
  --bg-alt:    #DEE3D6;
  --bg-deep:   #CFD6C5;
  --ink:       #0E1F10;
  --ink-mute:  #5F6B5A;
  --ink-fade:  #9DA697;
  --rule:      rgba(14,31,16,0.16);
  --rule-soft: rgba(14,31,16,0.07);
  --img-tint:  #BCC4B0;
  /* --pos override: shift away from ink to stay legible */
  --pos:       #4A2410;
}
:root[data-theme="dark"] {
  --bg:        #060B07;
  --bg-alt:    #0C140D;
  --bg-deep:   #131F15;
  --ink:       #E9ECE3;
  --ink-mute:  #858F7E;
  --ink-fade:  #535A4D;
  --rule:      rgba(233,236,227,0.18);
  --rule-soft: rgba(233,236,227,0.08);
  --img-tint:  #1E2D22;
  --pos:       #D4B89C;
}
```

#### 05 · Madder (pink)

Dusty rose paper, deep madder ink. Named for the rose madder pigment. Romantic but disciplined. Works for editorial, fashion, hospitality, and beauty products without veering into sweetness.

```css
:root[data-theme="light"] {
  --bg:        #ECE3E5;
  --bg-alt:    #E3D7DA;
  --bg-deep:   #D5C5C9;
  --ink:       #200810;
  --ink-mute:  #6B555A;
  --ink-fade:  #A8979C;
  --rule:      rgba(32,8,16,0.16);
  --rule-soft: rgba(32,8,16,0.07);
  --img-tint:  #C2B0B5;
  /* --neg override: deeper crimson to clear the rose ink */
  --neg:       #7A0815;
}
:root[data-theme="dark"] {
  --bg:        #100406;
  --bg-alt:    #18080A;
  --bg-deep:   #221012;
  --ink:       #ECE3E5;
  --ink-mute:  #8E7E82;
  --ink-fade:  #5A4D50;
  --rule:      rgba(236,227,229,0.18);
  --rule-soft: rgba(236,227,229,0.08);
  --img-tint:  #321A1E;
  --neg:       #F0A0AA;
}
```

#### Selecting a palette

The choice follows the product, not the trend:

- **Graphite** if the product handles dense data and the brand wants to feel neutral, professional, infrastructure-like.
- **Indigo** if there's an engineering, technical-drawing, or finance association to lean into.
- **Oxide** if the brand wants warmth without sweetness, or a hand-made, monograph, editorial register.
- **Verdant** if there's a connection to nature, sustainability, or slow consumption.
- **Madder** if the audience is editorial, beauty, or hospitality and the brand wants to feel considered rather than commercial.

A single product picks one palette and commits. The system is not designed for palette switching as a user feature; the theme toggle (light / dark) is the only chromatic control exposed to end users.

#### What never changes across palettes

Even when swapping pigments, these stay constant:

- All typography (Manrope + JetBrains Mono, all sizes and tracking).
- All layout, spacing, and component structures.
- The bracket label punctuation, section numerals, and three-zone metadata bar.
- Hairline rule weights (1px) and opacities (0.14 to 0.18 for `--rule`, 0.06 to 0.08 for `--rule-soft`).
- Photography treatment: still grayscale via CSS filter.
- Border-radius rules (square everywhere except the mobile device frame).
- The `--pos` / `--neg` semantic intent (positive = green family, negative = red family).

If a palette swap requires changing anything in that list, the system has been broken, not extended.

### Typography

**Families:** `Manrope` (300–800) for all display, body, and UI text. `JetBrains Mono` (400, 500) for labels, metadata, section numerals, table headers, status pills, kbd hints. Both from Google Fonts. Exactly two families — no script, no decorative accent face. Manrope ligatures `ss01`, `ss02`, `cv11` are enabled; tabular numerals (`tnum`) are enabled body-wide.

| Token         | Size                            | Weight | Tracking  | Use                                  |
|---------------|---------------------------------|--------|-----------|--------------------------------------|
| display-xl    | `clamp(80px, 18vw, 280px)`      | 700    | -0.055em  | Landing hero wordmark                |
| display-lg    | `clamp(48px, 9vw, 140px)`       | 700    | -0.05em   | Landing CTA, big inline display      |
| display-md    | `clamp(40px, 5vw, 64px)`        | 700    | -0.04em   | Page title, mobile hero              |
| heading-lg    | 22 to 26px                      | 600    | -0.02em   | Panel titles, featured project       |
| heading-md    | 18px                            | 600    | -0.02em   | Section heads                        |
| heading-sm    | 15 to 16px                      | 600    | -0.015em  | Card titles, profile name            |
| body-lg       | 18px                            | 400    | -0.005em  | Marketing lead paragraphs            |
| body          | 13.5 to 15px                    | 400    | -0.005em  | Default body                         |
| body-sm       | 12.5 to 13px                    | 400    | -0.005em  | Activity items, dense text           |
| mono-label    | 11px                            | 500    | 0.08em    | Bracket labels, top bar metadata     |
| mono-sm       | 9 to 10px                       | 500    | 0.06em    | Statuses, table headers, timestamps  |

Display sizes are always uppercase with negative tracking. Mono sizes are always uppercase with positive tracking. Tracking rule of thumb: display (40px+) `-0.04em` to `-0.055em`; headings `-0.015em` to `-0.02em`; body `-0.005em`; mono uppercase `+0.06em` to `+0.08em`.

**Label casing:** Title Case for human-readable names (`Reach out`, `In Use`), UPPERCASE for navigation and zone labels (`STUDIO OPERATIONS`, `WORKSPACE`). The `©` mark follows the wordmark in mono treatments and floats top-right of the headline in display type.

```css
.mono {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-weight: 500;
}
.tnum { font-variant-numeric: tabular-nums; }
```

### Spacing

Base unit 4px. Common stops: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 120, 160.

- **Side margins:** 48px desktop, 24px mobile. Use `.wrap { max-width: 1440px; padding: 0 48px; }`.
- **Section padding:** 120px top desktop, 72px top mobile. Sections separate via vertical rhythm, not by background changes.
- **Card / panel internal padding:** 16 to 28px depending on density.

### Layout

```css
.wrap { max-width: 1440px; margin: 0 auto; padding: 0 48px; }
@media (max-width: 720px) { .wrap { padding: 0 24px; } }
```

**Top bar (3-zone metadata).** Always at the top of marketing surfaces. Brand on the left, page subject in the middle, geo + date on the right, theme toggle far right.

```html
<header class="topbar">
  <div class="mono brand">PLINTH<sup>©</sup></div>
  <div class="mono">STUDIO OPERATIONS<br/>PLATFORM</div>
  <div class="mono">BUENOS AIRES<br/>NOV 2026</div>
  <button class="toggle" data-theme-toggle>◐</button>
</header>
```

```css
.topbar {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
  align-items: center;
  padding: 28px 48px;
}
.topbar > *:nth-child(2) { text-align: center; }
.topbar > *:nth-child(3) { text-align: right; }
```

**Section head.** Two-column baseline: numeral on the left, label on the right. The slash and trailing space in `01 /` are intentional. The slash is `--ink-fade`; the number itself is `--ink-mute`.

```html
<div class="section-head wrap">
  <span class="section-num"><span>01 /</span> </span>
  <span class="mono">About the platform</span>
</div>
```

**Hairline rules.** Section separators are 1px solid `--rule`. Internal dividers drop to `--rule-soft`. No double rules ever.

```css
hr.rule { border: none; border-top: 1px solid var(--rule); }
```

**Grid breakage.** The system prefers asymmetric grids over balanced ones: hero tagline takes the left half, the floating `©` mark takes the right; CTA blocks push to 50% indent (`padding-left: 50%`) to mirror editorial layouts; section heads keep the numeral on one side and the label on the other, with the headline below spanning full width.

---

## Components

### Bracket label

The signature element. Always mono, always uppercase, always with non-breaking spaces inside the brackets.

```html
<span class="mono bracket">Reach out</span>
```

```css
.bracket::before { content: "[ \00a0"; color: var(--ink-fade); }
.bracket::after  { content: "\00a0 ]"; color: var(--ink-fade); }
```

The brackets are `--ink-fade`. The text inside inherits color from the parent. Use for: nav labels, status indicators, section labels, filter values, table counts, footer marks.

### Section number

```html
<span class="section-num"><span>01 /</span> </span>
```

```css
.section-num {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  letter-spacing: 0.06em;
  color: var(--ink-mute);
}
.section-num span { color: var(--ink-fade); }
```

### Theme toggle

```html
<button class="toggle" data-theme-toggle aria-label="Toggle theme">
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
    <circle cx="12" cy="12" r="9" />
    <path d="M12 3 V21" />
    <path d="M12 3 A9 9 0 0 1 12 21" fill="currentColor" stroke="none" />
  </svg>
</button>
```

```css
.toggle {
  width: 36px; height: 36px;
  border: 1px solid var(--rule);
  background: transparent;
  display: inline-flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: border-color 200ms, transform 400ms;
}
.toggle:hover { border-color: var(--ink); transform: rotate(180deg); }
```

### Metric cell

Used inside dashboard metric strips and mobile stat strips. Always bordered together as a row, separated by vertical rules.

```html
<div class="metric">
  <div class="head">
    <span class="mono">Active projects</span>
    <span class="mono">/ 01</span>
  </div>
  <div class="value">12</div>
  <div class="delta pos">+ 02 vs Q3</div>
</div>
```

The value uses `display-md` weight 600. Deltas use mono with the optional `--pos` / `--neg` color tokens (one of the only places color leaks in).

### Status pill

```html
<span class="status active">Active</span>
<span class="status review">Review</span>
<span class="status hold">On hold</span>
```

Mono 10px, 3px vertical / 8px horizontal padding, 1px rule border. `active` uses `--ink` border. `review` is muted. `hold` uses a dashed border.

### Table

Tabular data uses an explicit `table.list`. No zebra striping. Header row in mono, body rows separated by `--rule-soft` hairlines. Numeric columns right-aligned with tabular numerals.

### Progress bar

A thin 2 to 4px hairline-bordered bar. The fill is solid `--ink`. The percentage label sits to the right in mono.

```html
<div class="bar" style="--p: 72%"></div>
<span class="bar-pct">72 %</span>
```

```css
.bar {
  width: 80px; height: 4px;
  background: var(--rule-soft);
  border: 1px solid var(--rule);
  position: relative;
}
.bar::after {
  content: ""; position: absolute; inset: 0;
  width: var(--p, 50%);
  background: var(--ink);
}
```

### Card (project / capability)

A vertical stack: image, hairline-separated label row, title, supporting paragraph. Never inside a bordered box. The image is the visual weight; everything below is text.

```html
<article class="cap-card">
  <div class="img" style="background-image: url(...)"></div>
  <div class="label mono">
    <span class="name bracket">Intake</span>
    <span class="id">01</span>
  </div>
  <h4>Structured client intake from first inquiry.</h4>
  <p>Capture briefs, qualify scope, route to the right lead.</p>
</article>
```

---

## Photography

The whole system runs on B&W documentary or architectural photography. To enforce it regardless of source:

```css
img { filter: grayscale(100%) contrast(1.05); }
.hero-image { filter: grayscale(100%) contrast(1.06) brightness(1.02); }

:root[data-theme="dark"] .hero-image,
:root[data-theme="dark"] .cap-card .img {
  filter: grayscale(100%) contrast(0.95) brightness(0.8);
}
```

Dark mode reduces brightness so bright photography does not punch holes in the surface. The image placeholder background (`--img-tint`) renders before the photo loads, so grayscale tonality is preserved even on slow networks.

Image containers never have rounded corners. Aspect ratios: `21/9` for landing hero, `4/5` for capability cards, `4/3` for dashboard previews, `1/1` for mobile thumbnails.

---

## Motion

Restrained. Three patterns total:

1. **Entrance fade-up.** On page load, key elements fade up 8 to 20px over 600 to 900ms with `cubic-bezier(0.2, 0.6, 0.2, 1)`. Stagger delays: 50, 120, 220, 340ms.

   ```css
   @keyframes fadeUp {
     from { opacity: 0; transform: translateY(8px); }
     to   { opacity: 1; transform: translateY(0); }
   }
   .fade { opacity: 0; animation: fadeUp 600ms cubic-bezier(0.2,0.6,0.2,1) forwards; }
   ```

2. **Hover rule reveal.** Underlines on big CTA text reveal via opacity, not width. Image contrast lifts subtly on hover (`filter` transition over 380ms).

3. **Theme transition.** `background` and `color` transition over 380ms across the whole document. The toggle icon rotates 180deg on hover.

No spring animations. No parallax. No scroll-jacking.

---

## Voice and copy

- **Quiet, deliberate, slightly architectural.** Sentences are short. Paragraphs are 2 to 4 sentences.
- **Avoid agency jargon.** No "empower", no "synergy", no "elevate". Yes: "intake", "ledger", "phase", "record".
- **Verbs lean concrete.** "Capture", "route", "log", "archive".
- **Numbers in mono, prose in sans.** Any quantitative label belongs in mono.
- **Use numerals throughout.** No spelled-out numbers, no editorial cuteness.

---

## Patterns

The same tokens, components, and voice carry across surface types; they differ only in density and emphasis.

### Landing surface

- Edge-to-edge hero image after the wordmark.
- Generous 120px section padding.
- CTA section uses paired mono labels (one bracket label on each side) for visual balance, never a script flourish.
- Footer is a single hairline-bordered row with three mono zones (brand mark, rights statement, issue number).

### Dashboard surface

- 240px left sidebar, sticky top bar.
- Page head includes section number, headline, and a right-aligned metadata column (Updated / Week / Quarter).
- Metric strips, tables, and panels are all hairline-bordered grids. No cards.
- A search input sits in the top bar with a `⌘K` mono kbd hint.
- Two-column main area: dense table + featured preview.

### Mobile surface

- Phone-framed on desktop (390 x 844, 48px radius, 12px frame), full-bleed under 480px.
- Same top metadata pattern, compressed: brand + menu icon row, then hero, then a strip of three stats.
- Bottom tab bar with 4 mono labels. The bar sits on a 1px `--rule` top hairline; individual tabs have **no borders or fill**. Active tab is indicated by (1) a small 18px x 1px ink tick mark centered above the tab, (2) icon and label color shifted to `--ink`, and (3) label weight 600 instead of 500. Icons are 17px, drawn with 1.25px stroke and `stroke-linecap: square` / `stroke-linejoin: miter`.
- Critical: `<button>` defaults must be reset (`appearance: none; border: none; background: none; font: inherit;`) or browsers will draw a chrome border around every tab.
- Theme toggle floats outside the device on desktop, accessible inside on mobile.

---

## Anti-patterns

- Don't reach for a drop shadow — all depth is hairline rules; a shadow means you skipped a structural decision.
- Don't round corners on data UI — borders are square (the mobile device frame is the only exception, because phones are).
- Don't use gradients — none, anywhere.
- Don't add a color accent — the `--pos` / `--neg` financial tokens are the only deviation, and only for deltas.
- Don't use color photography — always grayscale via CSS filter, or the monochrome discipline breaks.
- Don't type em dashes (`—`) — use commas, periods, parentheses, or a middle dot `·`.
- Don't introduce a third type family — one sans (Manrope), one mono (JetBrains Mono); no script, no handwritten, no decorative accent.
- Don't draw icon-driven empty states — use a mono `[ no records ]` label instead of an illustration.
- Don't set display type in sentence case — display is always UPPERCASE.
- Don't center body text — body is always left-aligned.
