# Console

> a quiet system for loud products

A developer-first design system for shipping landing pages, dashboards, and mobile apps that feel like they were built inside a really good editor. Quiet by default. Loud where it counts.

```
// surface    warm black + cream
// type       geist + geist mono
// accents    violet · teal · amber · coral
// posture    minimal, dense, scannable
```

---

## Principles

The five rules every screen has to pass before it ships.

1. **Quiet by default.** Warm-black surfaces. Color earns its place. If a screen looks calm at a glance, it's done its first job.
2. **Status dots are the vocabulary.** A single 8px circle says more than a badge, a progress bar, or a sentence. Use them everywhere and users learn the language once.
3. **Mono carries the data.** Anything quantitative, anything you'd `cat` to a terminal (numbers, timestamps, hashes, filenames, statuses) lives in Geist Mono.
4. **Keyboard first.** Every interactive surface ships with a shortcut. Power users feel at home in 30 seconds.
5. **One accent per surface.** Never mix violet and teal as primaries in the same view. Pick a lane.

---

## How to use this system

### Minimum viable composition

A warm-black surface, monospace data (numbers, timestamps, statuses in Geist Mono), 8px status dots encoding state, and a single accent per surface. If those four exist on the screen, it reads as Console.

### Example compositions are examples

Editorial heroes with one accent-colored word, sparkline stat cards, services tables with color-coded latency, code blocks with syntax tokens, phone shells with status dots that translate 1:1 from desktop. Reach for these when the content calls for it — opt-in showcase, not signatures.

---

## 01 // foundations · color

Six syntax accents on a warm-black surface.

### Surface

| Token            | Hex       | Role                           |
|------------------|-----------|--------------------------------|
| `--bg-base`      | `#16161a` | App canvas                     |
| `--bg-surface`   | `#1c1c20` | Cards, panels                  |
| `--bg-elevated`  | `#232328` | Buttons, badges, code blocks   |
| `--bg-input`     | `#1a1a1e` | Form fields                    |
| `--bg-hover`     | `#26262c` | Interactive hover state        |
| `--bg-selected`  | `#2c2c34` | Active row, selected nav item  |

### Accent (syntax-derived)

| Token       | Hex       | Semantic role                              |
|-------------|-----------|--------------------------------------------|
| `--violet`  | `#b09ef0` | Primary action, brand, file icons          |
| `--teal`    | `#5fd9c8` | Links, strings, secondary brand            |
| `--amber`   | `#e6a558` | Warning, building, modified state          |
| `--coral`   | `#e57373` | Error, degraded, destructive, untracked    |
| `--sage`    | `#88c87a` | Success, healthy, added                    |
| `--azure`   | `#7eb6ff` | Info, numerics, neutral state              |

Each accent ships with a `--{name}-soft` variant at `rgba(_, 0.12)` for fills and tints.

### Text + line

| Token              | Hex       | Role                          |
|--------------------|-----------|-------------------------------|
| `--text-primary`   | `#e6e2d6` | Headlines, body emphasis      |
| `--text-secondary` | `#9c9a90` | Body, descriptions            |
| `--text-tertiary`  | `#66645c` | Labels, captions, timestamps  |
| `--text-disabled`  | `#44423c` | Inactive elements             |
| `--border-faint`   | `#1f1f24` | Card edges, table rows        |
| `--border`         | `#2a2a31` | Buttons, inputs               |
| `--border-strong`  | `#3a3a43` | Hover, focused chrome         |

### Status dot semantics

```
● sage    healthy, succeeded, online
● amber   building, pending, warning
● coral   error, degraded, blocked
● violet  active, primary action
● azure   info, link, neutral state
● muted   inactive, off
```

---

## 02 // foundations · typography

Two families. One accent treatment.

| Family           | Use                                                 |
|------------------|-----------------------------------------------------|
| **Geist**        | Body, headlines, UI labels                          |
| **Geist Mono**   | Labels, metadata, code, timestamps, anything numeric|

There is no third family. Accent words in headlines stay in Geist at the parent weight and pick up an accent color (usually violet or teal). That's the entire editorial system.

### Scale

| Style    | Family     | Weight | Size  | Line  | Tracking  | Used for                       |
|----------|------------|--------|-------|-------|-----------|--------------------------------|
| display  | Geist Mono | 600    | 56px  | 1.0   | -0.03em   | Logotype, hero number          |
| h1       | Geist      | 600    | 32px  | 1.1   | -0.02em   | Page titles                    |
| h2       | Geist      | 600    | 22px  | 1.2   | -0.01em   | Section titles                 |
| body     | Geist      | 400    | 14px  | 1.55  | 0         | Default                        |
| mono     | Geist Mono | 400    | 12px  | 1.6   | 0.01em    | Labels, metadata, code         |
| accent   | Geist      | 600    | 32px  | 1.1   | -0.02em   | Accent word in colored hue     |

### Label conventions

Uppercase mono labels prefixed with `//` are the recurring sectioning device:

```
// SURFACE       // TYPE        // ACCENTS       // POSTURE
```

- Size: 10.5px
- Tracking: 0.12em
- Color: `--text-tertiary`
- Family: Geist Mono

---

## 03 // foundations · space, shape, motion

### Space scale

4px base unit. Multiples of 4 only.

| Token  | px  | Common use                          |
|--------|-----|-------------------------------------|
| `s-1`  | 4   | Icon spacing                        |
| `s-2`  | 8   | Inline gap                          |
| `s-3`  | 12  | Tight component padding             |
| `s-4`  | 16  | Default padding                     |
| `s-5`  | 20  | Card body                           |
| `s-6`  | 24  | Section gap                         |
| `s-8`  | 32  | Page gutter                         |
| `s-10` | 40  | Block separation                    |
| `s-12` | 48  | Section padding                     |
| `s-16` | 64  | Large section                       |
| `s-20` | 80  | Reserved for hero                   |
| `s-24` | 96  | Reserved for hero                   |

### Radius

Two families. Tight for chrome, soft for cards.

| Token  | px  | Used for                            |
|--------|-----|-------------------------------------|
| `r-1`  | 4   | Tags, inline kbd, file rows         |
| `r-2`  | 6   | Buttons, inputs, small chips        |
| `r-3`  | 10  | Cards, panels, code blocks          |
| `r-4`  | 14  | Frames, device bezels               |
| `pill` | 999 | Status pills, eyebrow badges        |

### Motion

Three durations, two eases.

```css
--ease:     cubic-bezier(.2, .7, .2, 1);   /* default */
--ease-out: cubic-bezier(.16, 1, .3, 1);   /* page enter */

--d-1: 120ms;   /* hover, focus, color change */
--d-2: 200ms;   /* reveal, drawer, slide */
--d-3: 320ms;   /* page enter, modal */
```

No spring physics. No bounce. No staggered choreography. The terminal feel comes from speed and silence, not animation.

---

## Components

24 primitives. The ones doing the real work are listed first.

### Status dot

The system's main vocabulary. 8px round, used to encode state.

```html
<span class="dot sage"></span>
```

Variants: `violet · teal · amber · coral · sage · azure · muted`

Use to encode state, not decoration. If it's not communicating status, it shouldn't be a dot.

### Tag pill (badge)

Single-letter tags borrowed from Git status conventions.

| Tag | Color | Meaning      |
|-----|-------|--------------|
| `M` | amber | modified     |
| `U` | coral | untracked    |
| `A` | sage  | added        |
| `i` | azure | info         |

```html
<span class="badge tag-m">M  modified</span>
```

Pills also come in `solid` (violet, for primary callouts) and unstyled (neutral metadata).

### Button

Quiet by default. Four variants:

- **Default** · neutral chrome, used for any secondary action
- **Primary** · cream fill on dark, only one per surface
- **Ghost** · no chrome until hover, for tertiary
- **Accent** · violet-soft tint, used for "connect" or similar one-off CTAs

Sizes: `sm · 26px`, `md · 32px (default)`, `lg · 40px`

Every primary button ships with a `<span class="kbd">⏎</span>` keyboard hint when it has one.

### Input

34px height, 12px padding, `--bg-input` background. Focus state switches to `--bg-elevated` and gets a violet border. Search inputs include an inline `kbd` on the right (`⌘K` for global, `/` for filter).

### File row

The pattern that runs through every sidebar in the system. 28px tall, three-column grid (icon · name · tag), monospace name, optional letter-tag on the right. Hover lifts to `--bg-hover`, active state uses `--bg-selected`.

```html
<div class="file-row active">
  <span class="icon violet">⬢</span>
  <span class="name">SKILL.md</span>
  <span class="tag m">M</span>
</div>
```

### Code block

Mono 12.5px on `--bg-input`. Optional line-number gutter (`<span class="ln">01</span>`). Syntax tokens: `k` violet (keyword), `s` amber (string), `f` teal (function), `n` azure (number), `c` tertiary italic (comment), `t` primary (text/identifier).

### Other primitives

Panel · panel-head · kbd · brand · topbar · feed-item · stat card · table · chart card · tabs · chip · toggle · phone frame · phone tabs · profile row · group list · danger zone · empty state · ASCII divider · gutter

---

## Patterns

How recurring problems get solved with the primitives above.

### Surface types

The system spans three surface types, all built from the same tokens:

- **Landing** · sticky nav with mono links, editorial hero with one accent-colored word and soft radial accent washes, a working terminal preview as social proof, three-column feature grid divided by 1px lines, code-block + caption split sections, centered CTA with accent wash.
- **Dashboard** · persistent sidebar (org switcher, search, nav sections, user footer), sticky topbar with breadcrumbs and region status, page header with live metadata, tab row, stat cards with sparklines, a chart + activity-feed split, services table with chip filters and color-coded latency.
- **Mobile** · phone screens in device bezels — home (summary card, service list with status dots, tab bar), detail (stats grid, live sparkline, commit list, pinned bottom CTA), settings (profile card, grouped lists, toggles, danger zone). Same tokens, narrower rhythm. Status dots translate 1:1 from desktop.

### Status communication

In order of preference:

1. **Dot alone** when the surrounding text already labels the thing
2. **Dot + tag pill** when scanning a list (table rows, sidebar)
3. **Tag pill alone** in dense contexts where dots would crowd
4. **Full sentence** only in toasts, alerts, and onboarding

Never combine a colored dot with a colored tag of a different hue on the same row.

### Empty states

Mono single-line. No illustrations. No "oops!". Show the keyboard shortcut to create the missing thing.

```
// no incidents · ⌘N to create
```

### Loading

Skeleton blocks in `--bg-elevated` for known shapes. A single `pulse` dot in `--sage` for "live" indicators. Never use spinners. Never use percentages unless you actually know the percentage.

### Error states

`--coral` accent on the affected row only. Inline message in `--text-secondary`. If the error is recoverable, a `accent` variant button to retry. Toast lives in the top-right and uses `--bg-elevated` with a coral left border.

### Editorial accent

When a headline needs emphasis, color one or two words in `--violet` or `--teal`. Keep the same Geist family and weight as the rest of the headline. Don't italicize. Don't switch families. Don't gradient.

Good: `Build it like you mean it.` (with "mean" in violet)
Bad:  Italicized serif, gradient text, different font.

### Density modes

Two modes only:

- **Default** · generous padding, 14px body, used in landing and detail views
- **Dense** · 12px body, 8px gutters, used in tables and console views

There is no comfortable mode in between. Pick one per screen.

---

## Writing

The product talks like a developer who respects your time.

- **Short.** Sentences under 12 words wherever possible.
- **Mono punctuation.** `//` for section labels, `·` for inline separators, `→` for next-step indicators, `▲ ▼ ›` for deltas.
- **Lowercase metadata.** `production · us-east-1 · 2m ago`. Sentence case for human-facing copy.
- **No exclamation marks.** Ever.
- **No "oops" / "uh-oh" / "whoops".** Errors are stated, not apologized for.
- **No emoji** in product surfaces. The status dots are the emoji.
- **Time is relative.** `2m`, `just now`, `1h ago`, not full timestamps unless precision matters.

### Voice samples

```
// dashboard topbar
codeyam / production / overview

// activity feed
@dani deployed api-gateway · d753e150

// empty state
// no incidents · ⌘N to create

// error
billing-svc · p95 412ms · acknowledged

// CTA
Build it like you mean it.
```

---

## Anti-patterns

- Don't reach for color by default — Console is quiet first; color that doesn't earn its place breaks the calm-at-a-glance test.
- Don't mix two accents as primaries on one surface — one accent per surface keeps the lane clear.
- Don't combine a colored dot with a differently-hued tag on the same row — the status vocabulary stops being legible.
- Don't make a dot decorative — if it's not communicating status, it shouldn't be a dot.
- Don't set data in the body family — numbers, timestamps, hashes, and statuses live in Geist Mono so they stay scannable.
- Don't ship an interactive surface without a keyboard shortcut — power users lose the 30-second-at-home payoff.
- Don't italicize, switch families, or gradient an accent headline — keep the same Geist family and weight, just change the color.
- Don't use spinners or fake percentages — skeletons and a single pulse dot communicate loading without lying about progress.
- Don't apologize in error copy — no "oops" / "uh-oh" / "whoops"; state the error.
- Don't use exclamation marks or emoji in product surfaces — the status dots are the only emoji.
- No purple gradients.
