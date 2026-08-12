# Marquee

> Brutalist editorial UI for live culture. Oversized condensed type, hard edges, one fearless accent. If a design feels safe, it is wrong.

## Philosophy

MARQUEE is loud where it counts and quiet everywhere else. Three commitments:

1. **One fearless color** that does all the heavy lifting. Everything else is neutral.
2. **Type as architecture.** Headlines are oversized, condensed, and unapologetic. Body type stays out of the way.
3. **Hard edges.** No rounded corners on cards or surfaces. Pills and avatars are the only exception.

## How to use this system

### Minimum viable composition

Oversized condensed display headline (Bricolage Grotesque, weight 800, `font-stretch: 75%`), uppercase letter-spaced mono labels, hard-cornered surfaces, and the single accent used in exactly one spot. If those four exist on the screen, it reads as Marquee.

### Example compositions are examples

Marquee tickers, perforated ticket cards, hairline 1px-gap event grids, full-bleed accent hero/poster blocks, `01 / SECTION` mono section numbers. Reach for these when the content calls for it — opt-in flourishes, not signatures.

---

## Color System

### Structure

Every palette is built on a four-token core: a warm neutral base, a deep ink, one high-voltage accent, and a counter-color that sits on top of the accent. Each palette ships with a light and a dark variant.

### Token reference

| Token | Role |
|---|---|
| `--bg` | Page background |
| `--surface` | Subtle elevation (cards, hovers) |
| `--surface-2` | Deeper elevation |
| `--panel` | Sidebar, dashboard panels |
| `--ink` | Primary text, hard borders |
| `--ink-soft` | Secondary text, descriptions |
| `--ink-muted` | Tertiary text, metadata, labels |
| `--line` | Hairline dividers |
| `--line-strong` | Visible borders |
| `--accent` | The fearless color |
| `--on-accent` | Text and icons placed on `--accent` |
| `--success` | Positive deltas, sold-out states |

### Palette 01 / EMBER (default)

Cream, ink, red. The original. Reads like a newspaper that just got punched.

```css
:root[data-theme="light"] {
  --bg: #E8E5DD;
  --surface: #DDD9CD;
  --surface-2: #D2CEC0;
  --panel: #F0EDE4;
  --ink: #0A0908;
  --accent: #FF3B1F;
  --on-accent: #E8E5DD;
  --success: #2D5F3F;
}
:root[data-theme="dark"] {
  --bg: #0F0E0C;
  --surface: #1A1815;
  --surface-2: #221F1B;
  --panel: #15140F;
  --ink: #E8E5DD;
  --accent: #FF3B1F;
  --on-accent: #0A0908;
  --success: #6BB089;
}
```

### Palette 02 / VOLTAGE

Bone, ink, chartreuse. Electric. Use when the product needs to feel like it just plugged itself in.

```css
:root[data-theme="light"] {
  --bg: #EAE8E0;
  --surface: #DFDDD2;
  --surface-2: #D3D1C5;
  --panel: #F1EFE5;
  --ink: #0B0A08;
  --accent: #D5F560;
  --on-accent: #0B0A08;
  --success: #2D5F3F;
}
:root[data-theme="dark"] {
  --bg: #0C0D08;
  --surface: #15170F;
  --surface-2: #1E2117;
  --panel: #10110B;
  --ink: #EAE8E0;
  --accent: #D5F560;
  --on-accent: #0B0A08;
  --success: #6BB089;
}
```

### Palette 03 / COBALT

Cream, ink, electric blue. Editorial and cool. The serious-money palette. Reads like a financial paper that secretly throws good parties.

```css
:root[data-theme="light"] {
  --bg: #E6E4DD;
  --surface: #DAD8CF;
  --surface-2: #CECCC2;
  --panel: #EEEBE3;
  --ink: #0A0B14;
  --accent: #2E4BFF;
  --on-accent: #E6E4DD;
  --success: #2D5F3F;
}
:root[data-theme="dark"] {
  --bg: #08090F;
  --surface: #111319;
  --surface-2: #1A1D26;
  --panel: #0D0F15;
  --ink: #E6E4DD;
  --accent: #4D67FF;
  --on-accent: #08090F;
  --success: #6BB089;
}
```

### Palette 04 / SULFUR

Bone, jet, acid yellow. Aggressive poster energy. Loud and unfiltered. Best for music, nightlife, and rave-adjacent products.

```css
:root[data-theme="light"] {
  --bg: #E9E5D8;
  --surface: #DDD9CB;
  --surface-2: #D0CCBE;
  --panel: #F0ECDE;
  --ink: #050505;
  --accent: #F2D900;
  --on-accent: #050505;
  --success: #2D5F3F;
}
:root[data-theme="dark"] {
  --bg: #0A0A06;
  --surface: #13130D;
  --surface-2: #1C1C13;
  --panel: #0E0E08;
  --ink: #E9E5D8;
  --accent: #F2D900;
  --on-accent: #050505;
  --success: #6BB089;
}
```

### Palette 05 / BLOOM

Rose, oxblood, coral. Warm and romantic without losing the edge. Good for cultural programming, performance, talks.

```css
:root[data-theme="light"] {
  --bg: #F2E4DD;
  --surface: #E8D8D0;
  --surface-2: #DCCBC2;
  --panel: #F7EBE5;
  --ink: #2A0F12;
  --accent: #E84A3D;
  --on-accent: #F2E4DD;
  --success: #4A5D2D;
}
:root[data-theme="dark"] {
  --bg: #14080A;
  --surface: #1F0E11;
  --surface-2: #2A1418;
  --panel: #180A0D;
  --ink: #F2E4DD;
  --accent: #FF6354;
  --on-accent: #14080A;
  --success: #8FA66B;
}
```

### Usage rules

- Pick **one palette per product**. Do not mix.
- The accent color is for emphasis, never decoration. It marks the one thing on a screen that matters most.
- Body text is always `--ink`. Never use the accent for paragraphs.
- A block of pure accent (full-bleed colored card, sticky CTA, hero card) should appear at most once per viewport.
- Backgrounds, surfaces, and panels create depth through tonal stepping, not shadows.

---

## Typography

### Families

| Family | Role |
|---|---|
| **Bricolage Grotesque** (variable, 200 to 800, opsz 12 to 96) | Everything. Headlines, body, UI. |
| **JetBrains Mono** (400, 500, 700) | Metadata, labels, timestamps, badges, status text. |

Two fonts only. No serif italic fallback. No script. No display-only fonts.

### Scale

```
Display XL    clamp(110px, 22vw, 360px)  weight 800  letter -0.045em  line 0.82  stretch 75%
Display L     clamp(48px, 7vw, 96px)     weight 800  letter -0.035em  line 0.90  stretch 75%
Display M     clamp(36px, 5vw, 64px)     weight 800  letter -0.030em  line 0.95  stretch 75%
Heading L     22 to 28px                 weight 700  letter -0.020em  line 1.10
Heading M     16 to 18px                 weight 700  letter -0.015em  line 1.20
Heading S     13 to 14px                 weight 600  letter -0.010em  line 1.30
Body L        15 to 16px                 weight 400  line 1.50
Body M        13 to 14px                 weight 400  line 1.50
Body S        11 to 12px                 weight 400  line 1.50
Mono          10 to 11px                 weight 500  letter 0.05em    uppercase
```

### Rules

- All display sizes use **`font-stretch: 75%`** for the condensed brutalist poster feel. Without it, the system loses its character.
- Display headlines are always `font-weight: 800`.
- Mono is always uppercase, always letter-spaced (`0.05em` minimum).
- Body copy never gets uppercased.
- Numbers in stats use display weight (800) at smaller sizes (28 to 44px) with the same negative letter-spacing.

---

## Spacing and Layout

### Spacing scale

```
xs   4px
sm   8px
md   12px
lg   16px
xl   24px
2xl  32px
3xl  48px
4xl  64px
5xl  96px
6xl  140px  (section top/bottom on landing)
```

### Layout primitives

- **Page padding (desktop):** 32px horizontal on landing, 40px on dashboard, 20px on mobile.
- **Section vertical:** 120px top/bottom on landing, 60px on dashboard.
- **Hero vertical:** 140px top, 80px bottom, minimum 92vh.

### Grid

- **Events grid:** 3 columns, 1px gap (gap color `--line`, background `--bg`) — the brutalist hairline grid look.
- **Stats:** 4 columns, same 1px gap pattern.
- **Talent:** 4 columns desktop, 2 columns mobile, 32px row gap.
- **Footer:** 2fr / 1fr / 1fr / 1fr.

### Corners

**Zero radius on everything** except:
- Avatars and icon buttons: `999px` (full pill)
- Phone frame: `44px` (mobile only)
- Status bar notch: `18px`

If it has content inside it, it has hard corners.

---

## Components

### Buttons

```
.btn               1px solid line-strong, transparent bg, ink text
.btn:hover         surface bg
.btn.primary       accent bg, on-accent text, no border
.btn.primary:hover filter brightness(1.05)
```

Padding: `10px 16px`. Font: 13px, weight 500 (600 on primary). No rounded corners.

### Cards

- Background `--panel`
- 1px border `--line` (or `--line-strong` for emphasis)
- 24px padding (desktop) / 18 to 20px (mobile)
- No shadow except for the floating accent card (`0 30px 80px rgba(0,0,0,0.18)`)
- The featured/hero card flips to `--accent` background and `--on-accent` text

### Status pills

```
.status            10px mono, uppercase, 0.06em tracking, 3px 8px padding
.status.live       accent bg, on-accent text
.status.upcoming   ink bg, bg text
.status.draft      transparent bg, dashed line-strong border, ink-muted text
.status.sold       transparent bg, success border + text
```

### Marquee ticker

Horizontal scrolling band, accent background, on-accent text. 45 second loop on landing, 30 second on mobile. Separator: `✱` glyph. Duplicate content inline for a seamless loop.

```css
@keyframes scroll {
  from { transform: translateX(0); }
  to   { transform: translateX(-50%); }
}
```

### Event card

Three states:

1. **Default:** `--bg` background, hover to `--surface`.
2. **Featured:** `--accent` background, `--on-accent` text. One per grid.
3. **Compact (mobile row):** date block on left in `--surface`, info middle, accent price on right.

### Hero/poster block

The signature treatment, for featured events and event detail screens.

- Full-bleed `--accent` background
- Stacked oversized type (Display M to L) in `--on-accent`
- Mono metadata in `--on-accent` at 60% opacity above title
- Hairline divider before bottom metadata row (`1px solid rgba(255,255,255,0.25)`)
- Optional small bordered badge in top-right

### Tickets

Perforated card pattern (mobile only):

- Border `--line-strong`
- Active/upcoming ticket flips to `--accent` background
- Perforated divider: 1px dashed line with two filled circles (in page bg color) overlapping the card edges
- QR placeholder: repeating linear gradients in `currentColor` at 4px tile size

---

## Patterns

### Section headers

```
[Big display heading]                 [01 / SECTION-NAME in mono]
```

Always left-aligned heading, right-aligned mono section number in the `01 / EVENTS` format.

### Greeting blocks

Dashboard and mobile app entry screens.

```
[mono date string]                    [right-aligned mono date / location]
[Display M greeting with name]        [city / time]
```

### Stat cards

```
[label in mono, opacity 0.7]
[huge condensed number, weight 800, stretch 75%]
[delta with arrow icon]
```

One stat card per group gets the `--accent` treatment — always the most important metric.

### Activity feed

Vertical list, each item:
- 8px square dot (accent or muted)
- Body text with bold names and accent-colored links
- Mono timestamp below

No avatars in activity feeds. The dot does the work.

### Empty states

- Mono label at the top
- Display heading explaining the state
- One primary button to fix it
- Zero illustrations

---

## Iconography

Unicode glyphs and minimal monoline icons. Never filled, never multi-color.

Common glyphs:
```
◉  Active / current
◊  Talent / contact
⌗  Calendar
⊙  Tickets
≋  Audience
⌬  Reports
⚙  Settings
⌥  Integrations
↗  External link / outbound
→  Forward
←  Back
↑  Up / increase
↓  Down / decrease
✱  Ticker separator
●  Status dot
⌕  Search
```

Icons inside circular buttons use the avatar pill pattern (34px mobile, 36px desktop).

---

## Voice and Tone

### Headlines

Short, declarative, occasionally provocative. Lowercase when there's emotional weight. Uppercase when it's a poster.

Good: "Tonight in the city." / "What's next?" / "The internet has enough noise."

Avoid: "Welcome to MARQUEE!" / "Discover Amazing Events Near You" / "Your one-stop shop for live entertainment"

### Body copy

Direct, specific, concrete. Names places. Names numbers. No marketing-speak.

Good: "Friday morning brief. Three events worth your weekend, one essay, zero filler."

Avoid: "Subscribe to our newsletter for curated content."

### Labels and microcopy

Mono labels are always 1 to 3 words, uppercased: `LIVE`, `SOLD OUT`, `12 WEEKS`, `BUENOS AIRES / LISBOA / BERLIN`.

Forward slashes are the workhorse separator — between cities, dates, times, and metadata. Avoid hyphens for separation. Never use em dashes.

---

## Motion

Restrained. Animation serves clarity, never decoration.

- **Hover transitions:** 0.15 to 0.2s ease, color and background only.
- **Theme toggle:** 0.3s ease on `background` and `color`.
- **Fade-up entrance:** 0.8s ease, 20px translateY, used sparingly on hero elements with 0.1s stagger.
- **Ticker scroll:** 30 to 45s linear infinite.
- **Card hover scale:** never. Use background or opacity changes instead.
- **Calendar row hover:** subtle padding shift (16px left/right inset) plus surface bg.

No spring animations. No bounce. No parallax.

---

## Theme switching

Every surface ships with a `data-theme` attribute on `<html>` (`light` or `dark`). All colors are CSS custom properties driven off this attribute; components never hardcode color values.

Toggle button is a 34 to 36px circle with `◐` / `◑` glyph, placed in nav (landing), sidebar foot (dashboard), or top-right of stage (mobile).

```js
toggle.addEventListener('click', () => {
  const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
  root.dataset.theme = next;
});
```

Both themes must feel equally intentional. Dark mode is not just an inverted light mode:

- Surface stepping in dark mode is tighter (5 to 8 points of lightness between steps, not 12).
- The accent stays the same hex in most palettes (it works on both).
- The accent's counterpart (`--on-accent`) usually flips: cream on light, deep ink on dark.

---

## Responsive breakpoints

```
mobile          < 700px
tablet          700px to 1100px
desktop         > 1100px
```

Specific overrides:
- Events grid collapses to 1 column under 900px
- Talent grid collapses to 2 columns under 900px
- Dashboard sidebar stacks above main under 1100px
- Featured card becomes full-width under 900px
- Hero bottom 3-column becomes 1 column under 900px

---

## Checklist

- [ ] Both themes defined and tested — dark mode equally intentional
- [ ] Only one palette used throughout
- [ ] Display headlines use `font-stretch: 75%` at weight 800
- [ ] No rounded corners except pills and phone frame
- [ ] Accent appears at most once per viewport as a full block
- [ ] Mono labels are uppercase with 0.05em+ tracking
- [ ] Hover states use color, not transform
- [ ] Forward slashes used for metadata separators
- [ ] No em dashes, no italic, no serif
- [ ] Theme toggle is present and functional

---

## Anti-patterns

- Don't mix two palettes in one product — the discipline comes from committing to one.
- Don't round corners on cards, panels, or buttons — hard edges are the system's spine.
- Don't add drop shadows except on the floating featured card — depth comes from tonal stepping, not shadows.
- Don't use the accent for body text — it marks the single most important thing, and loses that power when spread.
- Don't use gradients except in placeholder portrait fills — they soften the brutalist edge.
- Don't use serif typefaces or italic — the two-font discipline carries the identity.
- Don't use em dashes — forward slashes are the only metadata separator.
- Don't use illustrations or stock photography — type and color do the work.
- Don't animate beyond the motion list — extra motion reads as decoration, which the system rejects.
