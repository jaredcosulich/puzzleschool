# Manifesto

> Heavy condensed display type does the talking; quiet mono chrome labels everything; warm paper is the canvas, and one sharp accent earns its place as punctuation.

## Operating Principles

1. **Type carries weight.** Hierarchy is built with size and weight, not with boxes, shadows, or borders. Display headlines are MASSIVE. Mono labels are tiny and tracked. The contrast between the two is the whole personality.
2. **Chrome stays quiet.** Buttons, inputs, and nav use mono caps at 10-12px. They never compete with display headlines.
3. **One accent, used like punctuation.** The Pulse color (orange) appears as period marks, button fills, live indicators, and progress fills. Never decorative. Never gradients of itself.
4. **Warm paper, never gray.** The base is a warm off-white that reads like printed stock. Never pure white. Never cool gray.
5. **Sentence case in body, UPPERCASE in chrome.** Headlines are uppercase too. Mid-sentence emphasis is avoided.
6. **Hairlines over shadows.** Use 1px solid `--mist` borders for division. Drop shadows are reserved for floating cards (phones, modals).

## How to use this system

### Minimum viable composition

A massive condensed display headline, tiny tracked mono caps labeling its
chrome, warm paper as the background, and a single orange Pulse mark acting
as punctuation (a period, a live dot, a button fill). If those four exist on
the screen, it reads as Manifesto.

### Example compositions are examples

Inverted "dark moment" stat bands, vertical corner stamps, editorial
underline-only input fields, marquees of scrolling mono services, numbered
section heads. Reach for these when the content calls for it — opt-in
flourishes, not signatures.

---

## Color Tokens

Define both light and dark in the same `:root` and switch via `[data-theme="dark"]`. All surface and text tokens flip between themes. Accent tokens (`pulse`, `highlight`) and the static `white` do not flip.

```css
:root {
  /* Surfaces (flip in dark mode) */
  --paper:       #E8E6E1;  /* page background */
  --paper-card:  #F2F0EB;  /* raised surface, cards */
  --paper-deep:  #DBD8D2;  /* table headers, recessed */

  /* Text + ink (flip in dark mode) */
  --ink:         #0A0A0A;  /* primary text, primary buttons */
  --ink-soft:    #1A1A1A;  /* body paragraphs */
  --ash:         #6B6864;  /* secondary text, mono labels */
  --ash-soft:    #908C86;  /* tertiary text */
  --mist:        #C9C5BE;  /* hairlines, dividers, placeholders */

  /* Static (do NOT flip) */
  --white:       #FAF9F6;  /* text on accent buttons */
  --pulse:       #FF6B1F;  /* primary accent: CTAs, period marks, live dots */
  --pulse-soft:  rgba(255, 107, 31, 0.08);
  --highlight:   #FFCB47;  /* secondary accent: urgent pills, featured chips */
}

[data-theme="dark"] {
  --paper:       #0F0E0C;
  --paper-card:  #1A1815;
  --paper-deep:  #252320;
  --ink:         #E8E6E1;
  --ink-soft:    #D8D6D1;
  --ash:         #908C86;
  --ash-soft:    #6B6864;
  --mist:        #3A3833;
}
```

### Color Usage Rules

- **Primary CTAs:** `--ink` background, `--paper` text. The most common button style.
- **Pulse CTAs:** `--pulse` background, `--white` text. Reserved for the most important action on a screen (Send, Submit, New). Only one per view.
- **Ghost buttons:** transparent, `--ink` border + text. Secondary actions.
- **Body text:** `--ink-soft`, not `--ink`. The slight reduction softens long paragraphs.
- **Mono labels:** `--ash`. Never `--ink` for label-style chrome.
- **Hairlines:** `--mist`. Always 1px solid (or 1px dashed for "soft" divisions inside cards).
- **Live indicators (dots):** `--pulse`.
- **Urgent / featured states:** `--highlight` (yellow) background with locked `#0A0A0A` text. See "Locked Literals" below.

### Locked Literals

When tokens flip with dark mode, MOST text and surfaces should flip with them. But some elements are "fixed visual moments" that should look the same in both themes. For those, use literal hex values instead of theme tokens.

**Use locked literals when:**

- **Text sits on a hardcoded gradient or photo.** Example: a tile with a dark gradient background. The title text should be a literal light color (`#E8E6E1`), regardless of theme. If you use `var(--paper)`, it will invert to dark in dark mode and disappear.
- **Text sits on a fixed accent color.** Yellow `--highlight` pills always need dark text. Use `color: #0A0A0A`, not `var(--ink)`.
- **A device frame or chrome that mimics a physical object.** Phone bezels, monitor frames, etc. Stay dark in both modes for realism.

**Lift placeholders in dark mode.** Form placeholders use `--mist` (`#C9C5BE` light, `#3A3833` dark). The dark value is too dark to read against the dark page. Lift it:

```css
input::placeholder { color: var(--mist); opacity: 1; }
[data-theme="dark"] input::placeholder { color: #6B6864; }
```

**Flip button text on hover.** When a button's background swaps to `var(--ink)` on hover, also flip the text. Otherwise in dark mode you get light-on-light:

```css
.btn-pulse:hover {
  background: var(--ink);
  color: var(--paper);   /* required */
}
```

---

## Typography

Three faces. They never compete.

```css
:root {
  --display: "Big Shoulders Display", "Arial Narrow", sans-serif;
  --mono:    "JetBrains Mono", "SF Mono", monospace;
  --body:    "Geist", -apple-system, BlinkMacSystemFont, sans-serif;
}
```

Load from Google Fonts:
```html
<link href="https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@400;700;800;900&family=Geist:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
```

### Type Scale

| Role | Family | Weight | Size | Tracking | Case |
|---|---|---|---|---|---|
| Hero display | display | 900 | clamp(72px, 14vw, 232px) | -0.035em | UPPER |
| Section title | display | 900 | clamp(64px, 9vw, 144px) | -0.025em | UPPER |
| Page H1 | display | 900 | clamp(56px, 7vw, 96px) | -0.025em | UPPER |
| Subsection H2 | display | 800 | 40-56px | -0.02em | UPPER |
| Card title | display | 800 | 28-32px | -0.01em | UPPER |
| List item title | display | 700-800 | 18-22px | -0.005em | UPPER |
| Stat number | display | 900 | 56-64px | -0.025em | (numeric) |
| Body large | body | 400 | 17-18px | normal | sentence |
| Body | body | 400 | 14-15px | normal | sentence |
| Mono label | mono | 500 | 10-12px | 0.08-0.14em | UPPER |
| Mono nav | mono | 500 | 12px | 0.04-0.05em | UPPER |
| Mono caption | mono | 400 | 9-10px | 0.1em | UPPER |

### Type Rules

- Display always uses `line-height: 0.82` for hero, `0.85` for page H1, `0.9` for card titles. Tight stacking is the whole point.
- Body is `line-height: 1.5-1.55`, never tighter for readability.
- Mono uses uppercase + positive letter-spacing. Body never uses tracking.
- Period marks at the end of display headlines often render in `--pulse`. Use a `<span style="color: var(--pulse)">.</span>` pattern.
- No mid-sentence bold. No emphasis underlines unless requested. Period marks do the work.

---

## Spacing + Radius

```css
/* Spacing scale (use rem or these literal px values) */
--s-1:  4px;
--s-2:  8px;
--s-3:  12px;
--s-4:  16px;
--s-5:  24px;
--s-6:  32px;
--s-7:  48px;
--s-8:  64px;
--s-9:  96px;
--s-10: 128px;

/* Radius */
--r-1:    4px;   /* buttons, chips */
--r-2:    8px;   /* stat cards, tables */
--r-3:    12px;  /* feature cards */
--r-4:    20px;  /* device frames */
--r-pill: 999px; /* tag pills */
```

**Vertical rhythm:** sections are `padding: 96px 32px` on desktop. Section heads have `margin-bottom: 48-64px`. Sub-blocks inside sections use `gap: 32-40px`.

---

## Components

### Buttons

```css
.btn {
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-weight: 500;
  padding: 12px 18px;
  border: none;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s;
}

.btn-primary {
  background: var(--ink);
  color: var(--paper);
}
.btn-primary:hover {
  background: var(--pulse);
  color: var(--white);
}

.btn-pulse {
  background: var(--pulse);
  color: var(--white);
}
.btn-pulse:hover {
  background: var(--ink);
  color: var(--paper);  /* CRITICAL: flip text when bg becomes ink */
}

.btn-ghost {
  background: transparent;
  color: var(--ink);
  border: 1px solid var(--ink);
}
.btn-ghost:hover {
  background: var(--ink);
  color: var(--paper);
}

.btn-link {
  background: transparent;
  color: var(--ink);
  padding: 8px 0;
  border-bottom: 1px solid var(--ink);
  border-radius: 0;
}
```

Append `→` to button labels that trigger forward motion (Send, Continue, Open). The arrow is text, not an icon.

### Tag Pills

```css
.tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: var(--paper-deep);
  color: var(--ink);
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  border-radius: 999px;
  border: 1px solid var(--mist);
}

.tag-dot::before {
  content: "";
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--pulse);
}

.tag-pulse {
  background: var(--pulse);
  color: var(--white);
  border-color: var(--pulse);
}

.tag-highlight {
  background: var(--highlight);
  color: #0A0A0A;        /* locked literal */
  border-color: var(--highlight);
  font-weight: 600;
}
```

### Field (Editorial Input)

The signature input style. Display-weight type as the value, mono caps as the label, hairline underline. No box, no shadow.

```css
.cf-field {
  display: grid;
  grid-template-columns: 140px 1fr 60px;
  gap: 32px;
  align-items: baseline;
  padding: 22px 0;
  border-bottom: 1px solid var(--mist);
  transition: padding-left 0.3s, background 0.3s;
}
.cf-field:hover,
.cf-field:focus-within {
  padding-left: 16px;
  background: var(--paper-card);
}

.cf-label {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--ash);
}

.cf-input {
  background: transparent;
  border: none;
  outline: none;
  font-family: var(--display);
  font-weight: 800;
  font-size: 32px;
  color: var(--ink);
  text-transform: uppercase;
  letter-spacing: -0.015em;
  width: 100%;
  line-height: 1;
  padding: 0;
}
.cf-input::placeholder {
  color: var(--mist);
  opacity: 1;
}
[data-theme="dark"] .cf-input::placeholder {
  color: #6B6864;  /* locked: mist is too dark to read in dark mode */
}
```

### Card

```css
.card {
  background: var(--paper-card);
  border: 1px solid var(--mist);
  border-radius: 12px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--ash);
}

.card-title {
  font-family: var(--display);
  font-weight: 800;
  font-size: 32px;
  line-height: 0.95;
  text-transform: uppercase;
  letter-spacing: -0.01em;
}

.card-body {
  font-size: 14px;
  color: var(--ink-soft);
  line-height: 1.5;
}
```

### Stat Card

```css
.stat {
  background: var(--paper-card);
  border: 1px solid var(--mist);
  border-radius: 8px;
  padding: 18px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.stat:hover { border-color: var(--ink); }

.stat .label {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--ash);
}

.stat .value {
  font-family: var(--display);
  font-weight: 900;
  font-size: 64px;
  line-height: 0.85;
  letter-spacing: -0.025em;
}

.stat .delta {
  font-family: var(--mono);
  font-size: 11px;
  display: flex;
  justify-content: space-between;
  padding-top: 10px;
  border-top: 1px dashed var(--mist);
}
.stat .delta .up { color: var(--pulse); }
.stat .delta .neutral { color: var(--ash); }
```

### Filter Chip (Toggle)

```css
.cf-chip {
  padding: 8px 14px;
  background: var(--paper-card);
  border: 1px solid var(--mist);
  border-radius: 999px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink);
  cursor: pointer;
  transition: all 0.15s;
}
.cf-chip:hover { border-color: var(--ink); }
.cf-chip.on {
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
}
.cf-chip.featured {
  background: var(--highlight);
  color: #0A0A0A;  /* locked literal */
  border-color: #0A0A0A;
  font-weight: 600;
}
```

### Vertical Badge (Corner Stamp)

For "Nominee", "Live Build", "In Review" markers in corners.

```css
.badge-vert {
  writing-mode: vertical-rl;
  transform: rotate(180deg);
  background: var(--ink);
  color: var(--paper);
  padding: 24px 8px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  border-radius: 4px;
}
```

### Progress Bar

```css
.progress { display: flex; align-items: center; gap: 8px; }
.progress .track {
  flex: 1;
  height: 4px;
  background: var(--paper-deep);
  border-radius: 2px;
  overflow: hidden;
}
.progress .fill {
  height: 100%;
  background: var(--ink);
  border-radius: 2px;
}
.progress .fill.live { background: var(--pulse); }
.progress .pct {
  font-family: var(--mono);
  font-size: 10px;
  color: var(--ash);
}
```

### Meta Chip (kbd-style)

```css
.meta-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  border: 1px dashed var(--mist);
  border-radius: 4px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--ash);
}
```

Use for `⌘ K`, `Last sync · 2m ago`, version stamps, anything that lives in negative space.

---

## Patterns

### Sticky Top Chrome

Every page starts with a fixed top bar. Three columns: brand, nav, action.

```html
<div class="top-bar">
  <div class="left">STUDIO NAME</div>
  <div class="center">
    <a>Work</a><a>About</a><a>Contact</a>
  </div>
  <div class="right">
    <a onclick="toggleTheme()"><span class="theme-toggle-label">DARK MODE</span></a>
    <a>Let's Talk! →</a>
  </div>
</div>
```

```css
.top-bar {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 100;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 32px;
  background: var(--paper);
  border-bottom: 1px solid var(--mist);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}
```

### Editorial Baseline (Footer Caption)

Mono caps line at the bottom of hero sections or pages. Location + ticking clock + tagline.

```html
<div class="baseline">
  <span>WE CRAFT BOLD DESIGN</span>
  <span>BUENOS AIRES · 13:53:21</span>
</div>
```

### Section Head

Two-column grid: number on the left, title and lede on the right.

```html
<div class="section-head">
  <div class="section-num">03 / Components</div>
  <div>
    <h2 class="section-title">Parts.</h2>
    <p class="section-lede">A small, opinionated kit. Buttons are short and sharp...</p>
  </div>
</div>
```

### Inverted Block

A "dark moment" in a light page. Used for stats bands, focus cards, hero details. Uses `var(--ink)` as background and `var(--paper)` as text, so it auto-flips in dark mode (becoming a "light moment" in a dark page). This is intentional, the inversion preserves itself.

```css
.inverted {
  background: var(--ink);
  color: var(--paper);
}
.inverted .caption { color: var(--ash-soft); }
```

### Sidebar Nav (Dashboard)

```html
<aside class="side">
  <div class="brand">Manifesto<span class="pulse-dot"></span></div>
  <div class="search">
    <span>⌕</span>
    <span>Search projects</span>
    <span class="kbd">⌘ K</span>
  </div>
  <div class="nav-group">
    <div class="nav-label">Workspace</div>
    <a class="nav-item active">Dashboard <span class="count">·</span></a>
    <a class="nav-item">Projects <span class="count">14</span></a>
  </div>
</aside>
```

Active item gets `background: var(--ink); color: var(--paper)`. Counts on the right in `--ash`.

### Phone Frame (Mobile Screens)

```css
.phone {
  background: #1a1a1a;        /* locked literal, real phones have dark bezels */
  border-radius: 44px;
  padding: 8px;
  box-shadow: 0 40px 80px -40px rgba(0,0,0,0.4);
}
.phone-screen {
  background: var(--paper);
  border-radius: 36px;
  overflow: hidden;
  aspect-ratio: 9 / 19.5;
}
```

Inside the screen, use the full design system normally. Phone-internal nav uses 28x28 buttons, 9px mono labels, smaller padding (16-18px instead of 32px).

### Layout Anatomy by Surface

Describe surfaces by type, not by file. Three recurring shapes:

**Marketing / landing surface.** Sticky top bar → centered hero (display headline, eyebrow tag, footer caption with clock) → scrolling mono marquee → large display manifesto quote → 2-column work grid (aspect-ratio 4/3 tiles) → numbered approach list → inverted stats band (dark bg, stat cards in `--paper`) → editorial multi-field contact form → 4-column footer (brand + link columns + baseline).

**Dashboard / app surface.** 240px sidebar (brand + search + nav groups + user) → topbar (breadcrumbs + filter chips + a single primary CTA) → content (display H1 hero stat + meta, then a stats row with `gap: 12px`, then a 2:1 chart + activity grid in panels, then a table with filter chips above and rows carrying progress + status) → optional 320px right rail (focus card + deadlines + status).

**Mobile screen surface.** Locked `#1a1a1a` phone bezel → screen with status bar (9:41, signal) → phone bar (menu button + title + action button) → content at 16-18px padding → bottom tab bar (4 items, mono caps 8-9px).

### Dark Mode Implementation

Toggle by setting `data-theme` on `<html>`, persisting to `localStorage`, and updating any visible toggle labels:

```html
<a href="#" onclick="event.preventDefault(); toggleTheme();">
  <span class="theme-toggle-label">DARK MODE</span>
</a>
```

```js
function toggleTheme() {
  const cur = document.documentElement.getAttribute('data-theme') || 'light';
  const next = cur === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  try { localStorage.setItem('manifesto-theme', next); } catch(e) {}
  document.querySelectorAll('.theme-toggle-label').forEach(el => {
    el.textContent = next === 'dark' ? 'LIGHT MODE' : 'DARK MODE';
  });
}

// Apply saved theme on load
(function() {
  let saved = 'light';
  try { saved = localStorage.getItem('manifesto-theme') || 'light'; } catch(e) {}
  document.documentElement.setAttribute('data-theme', saved);
  document.querySelectorAll('.theme-toggle-label').forEach(el => {
    el.textContent = saved === 'dark' ? 'LIGHT MODE' : 'DARK MODE';
  });
})();
```

Add a transition to `body` so theme swaps don't snap:

```css
body {
  transition: background 0.25s ease, color 0.25s ease;
}
```

**Grain texture.** In light mode the page can carry an SVG noise overlay at low opacity with `mix-blend-mode: multiply` for printed-paper texture. In dark mode, hide it — the noise renders as near-black pixels and disappears against a dark background.

```css
body::before {
  content: "";
  position: fixed; inset: 0;
  pointer-events: none;
  opacity: 0.32;
  mix-blend-mode: multiply;
  background-image: url("data:image/svg+xml;utf8,<svg ...");
}
[data-theme="dark"] body::before { display: none; }
```

---

## Voice & Tone

The system pairs with editorial copywriting. Conventions:

- **Headlines are declarations.** "Bold work." not "Bold work we make." Period ends on a `--pulse` mark.
- **Labels are nouns, single words.** "Name", "Email", "Brief", "Tags". Not "Your name", "Enter your email".
- **Numbered list items get caps:** "01 / Brief.", "02 / Direction.", "03 / Craft."
- **Timestamps live in the chrome:** `BUENOS AIRES · 13:53:21`.
- **Live indicators have a dot:** `● 014 · LIVE`.
- **Mono caps with separators:** `WORKSPACE / DASHBOARD`, `STUDIO NAMMA · 2026`.
- **Sentence case for body, UPPERCASE for chrome.** No Title Case anywhere.
- **Avoid the em dash.** Use periods, hyphens, or restructure.
- **Avoid quotation marks for emphasis.** Let display weight do the work.

---

## Anti-patterns

- Don't put drop shadows on surfaces (except phone frames) — use hairlines instead, or the editorial flatness collapses into generic card UI.
- Don't use gradients in UI chrome — reserve them for fixed visual posters (work tiles, hero details), or the accent stops reading as punctuation.
- Don't give buttons a radius larger than 4px — pills are for tags, not buttons, and rounded buttons soften the sharp editorial voice.
- Don't use em dashes in copy or labels — periods and hyphens keep the typographic discipline.
- Don't add mid-sentence bold — headlines do the emphasis, and inline bold competes with display weight.
- Don't put icons in chrome — use mono text labels (bezier arrows and `·` separators are fine), because icons dilute the all-type identity.
- Don't show more than one Pulse CTA per view — multiple orange fills destroy the "one accent as punctuation" rule.
- Don't set body text in the display face — display is for headlines and statement type only.
- Don't use mono in body paragraphs — mono is chrome only, and mono body text is unreadable at length.
- Don't run more than 3 simultaneous focus colors on screen — orange CTA, yellow highlight, ink primary is the max before the page reads as noisy.
- Don't use `var(--ink)` on backgrounds that don't flip — if the background is a literal hex, the text must also be a literal hex, or it inverts and vanishes in dark mode.
- Don't use `var(--mist)` for placeholders in dark mode — lift to a mid-gray, because the dark mist value is unreadable against the dark page.
