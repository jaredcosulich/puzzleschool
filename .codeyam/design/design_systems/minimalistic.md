# Minimalistic

> Quiet, editorial UI. Monospace metadata against clean sans, hairline borders, a single warm terracotta accent. For any web or mobile app.

## Philosophy

Minimal, structured, editorial — closer to a logbook or museum catalogue than a SaaS app. Copy and UI both behave the same way: quiet and deliberate.

**Rules:**

1. Quiet. Never shout — no exclamation marks, no "Wow!" empty states, no rainbow gradients
2. Specific. Always prefer a concrete noun over a vague abstraction. "12 entries, 3 threads, 2 citations" beats "your activity"
3. Metadata first. Labels, dates, IDs, weeks, counts — visible everywhere, in mono
4. Lowercase mono labels for UI section headers; display headings (page titles) are sentence-case sans
5. Semicolons over em dashes. Replace `—` with `;` `,` `:` or `/`. Never use em dashes in UI copy, marketing copy, or code comments
6. Arrows are punctuation: `→` forward / open, `↗` external, `↘` branch / sub item

## How to use this system

### Minimum viable composition

Mono metadata (IDs, dates, counts) on the left, sans content on the
right, separated by a hairline `1px` border, with a single terracotta
accent moment somewhere on the screen. If those exist, it reads as
minimalistic.

### Example compositions are examples

Asymmetric three-column shells, day-grouped entry lists with mono
dividers, stat strips of hairline-separated cells, live-dot status
indicators, inline sparklines. Reach for these when the content calls
for it — opt-in flourishes, not signatures.

---

## Colors

Two themes, one accent. Both themes are warm, never neutral gray.

### Light theme

| Token            | Hex       | Use                                                       |
| :--------------- | :-------- | :-------------------------------------------------------- |
| `--bg`           | `#FAFAF7` | Default surface. Warm paper.                              |
| `--bg-elev`      | `#F2F1EC` | Elevated card, capture box, hover state on rows.          |
| `--bg-sunk`      | `#EEEDE7` | Recessed, code blocks, terminals, scroll track.           |
| `--ink`          | `#0A0A09` | Primary text, primary border on hover.                    |
| `--ink-strong`   | `#000000` | Display text only. Use sparingly.                         |
| `--ink-muted`    | `#6E6E6A` | Secondary text, labels, metadata.                         |
| `--ink-faint`    | `#A8A8A2` | Placeholder, disabled, decorative dividers.               |
| `--ink-inverse`  | `#FAFAF7` | Text on dark fills.                                       |
| `--line`         | `#E5E4DE` | Default hairline border.                                  |
| `--line-strong`  | `#C8C7C0` | Stronger border, used on buttons, dividers between major sections. |
| `--accent`       | `#C44536` | Terracotta. THE accent. Citations, active state, "live" indicators, primary hover. |
| `--accent-soft`  | `#F5E2DD` | Accent background fill (tag pills, highlighted cards).    |
| `--accent-ink`   | `#FAFAF7` | Text on accent fills.                                     |
| `--signal-go`    | `#4A6B3A` | Positive deltas, "done", focus going up.                  |
| `--signal-wait`  | `#8B6914` | Pending, in progress.                                     |
| `--signal-stop`  | `#C44536` | Errors, regressions. Same as accent on purpose.           |

### Dark theme

| Token            | Hex       |
| :--------------- | :-------- |
| `--bg`           | `#0E0E0D` |
| `--bg-elev`      | `#1A1A18` |
| `--bg-sunk`      | `#060605` |
| `--ink`          | `#F5F4F0` |
| `--ink-strong`   | `#FFFFFF` |
| `--ink-muted`    | `#8A8985` |
| `--ink-faint`    | `#5A5957` |
| `--ink-inverse`  | `#0E0E0D` |
| `--line`         | `#2A2A27` |
| `--line-strong`  | `#3D3D39` |
| `--accent`       | `#E27968` |
| `--accent-soft`  | `#2E1E1A` |
| `--accent-ink`   | `#0E0E0D` |
| `--signal-go`    | `#88B070` |
| `--signal-wait`  | `#C9A14A` |
| `--signal-stop`  | `#E27968` |

### Rules

- Background and ink are always *warm*. Never pure `#FFF` or `#000`.
- Accent is used sparingly. No more than 5% of any screen is accent colored.
- Hover and active states almost never change the color of body content; they change borders, backgrounds, or marginal indicators.
- Both themes must be available everywhere. Toggle persists via `localStorage` under the key `idx-theme`.

---

## Typography

One superfamily, used in two registers.

**Font stack:** **IBM Plex Sans** (body, headings, display, button labels, navigation labels), **IBM Plex Mono** (IDs, dates, times, weeks, counts, section labels, tags, kbd, code, file paths). No serif. No third family — the contrast comes from mono vs sans, not a third typeface.

### Scale

| Token         | px    | Line height | Use                                       |
| :------------ | :---- | :---------- | :---------------------------------------- |
| `--t-micro`   | 10    | 1.5         | Stamps, micro labels, kbd glyphs.         |
| `--t-mono`    | 11    | 1.6         | Mono labels, tags, nav items, badges.     |
| `--t-meta`    | 12    | 1.6         | Mono body, metadata rows, dates.          |
| `--t-body`    | 14    | 1.5         | Default UI body text.                     |
| `--t-body-lg` | 16    | 1.5         | Long form reading body.                   |
| `--t-lead`    | 18    | 1.45        | Lede paragraphs, marketing intros.        |
| `--t-h4`      | 22    | 1.3         | Section titles within a page, hero copy.  |
| `--t-h3`      | 28    | 1.2         | Page titles in dashboard.                 |
| `--t-h2`      | 38    | 1.1         | Marketing section heads.                  |
| `--t-h1`      | 56    | 1.05        | Page hero on landing.                     |
| `--t-display` | 88    | 0.95        | Wordmark and biggest moments only.        |

Headings use `letter-spacing: -0.01em` to `-0.03em` (tighter as size goes up). Mono labels use `letter-spacing: 0.02em` to `0.08em` (looser as size goes down).

### Conventions

- IDs always look like `E.0247`. Mono. Muted gray. Accent color when the entry is cited.
- Times always look like `13:42` (24h). Mono. Faint gray.
- Dates always look like `13.05.26` or `Wed, 13.05.26`. Mono.
- Weeks always look like `week 19` or `wk 19`. Mono.
- Tags always look like `#atlas`, `#reading`. Mono. `§` prefix for citations, `¶` prefix for threads, `†` for drafts.
- Wordmarks are all-caps, mixed case in body copy. Workspace nouns are lowercase (`studio`, `desk`, `archive`).

---

## Spacing

4px base scale. Always use the tokens.

```
--s-1   4px
--s-2   8px
--s-3   12px
--s-4   16px
--s-5   24px
--s-6   32px
--s-7   48px
--s-8   64px
--s-9   96px
--s-10  128px
```

### Rules

- Default gutter between sections on a page: `--s-9` (96px).
- Default gutter between cards in a grid: `--s-5` (24px).
- Default vertical rhythm inside a card: `--s-3` (12px) between rows, `--s-4` (16px) for outer padding.
- Generosity over density. When in doubt, add space.

---

## Borders, radii, shadows

- **Borders.** Always `1px solid var(--line)` or `1px solid var(--line-strong)`. Never thicker.
- **Radii.** `0` (default), `2px` (`--r-1`, used on buttons, inputs, tags), `4px` (`--r-2`, used on capture boxes and mobile cards). Never larger than 4px in the UI.
- **Shadows.** None. Depth is communicated by the warm bg/elev/sunk surfaces, not blur.

---

## Iconography

This system does not use an icon library. Symbols come from the typeface.

| Glyph | Meaning                              | Example                          |
| :---: | :----------------------------------- | :------------------------------- |
| `→`   | Forward, open, navigate              | Link arrows, "open this entry"   |
| `↗`   | External link                        | Footnotes, marketing CTAs        |
| `↘`   | Branch, sub item, indented           | List items in info columns       |
| `≡`   | All / list                           | Sidebar nav item for "All"       |
| `¶`   | Thread                               | Threads nav item                 |
| `§`   | Citation                             | Citations nav, citation prefix   |
| `†`   | Draft                                | Drafts nav, draft prefix         |
| `⌗`   | Archive                              | Archive nav                      |
| `◐ ◑` | View / filter                        | Weekly review, by tag            |
| `●`   | Live, active                         | Live dot, active thread          |
| `+`   | Capture, new                         | FAB on mobile, capture button    |
| `⌕`   | Search                               | Search input prefix              |
| `⌘K`  | Keyboard shortcut                    | Search hint, command palette     |

Status dots are 6 to 8px filled circles in `--signal-*` colors. They sit inside tag pills.

---

## Components

Each component is theme aware and adjusts automatically.

### Button

```html
<button class="btn">Default</button>
<button class="btn primary">Primary</button>
<button class="btn ghost">Ghost</button>
```

- Padding `10px 16px`. Mono label, uppercase, letter-spacing `0.04em`.
- Default: hairline border, transparent fill. On hover, fills with ink, inverts text.
- Primary: ink fill by default; on hover, fills with accent.
- No icon-only buttons unless 32x32 minimum.

### Theme toggle

```html
<button class="theme-toggle" id="themeToggle">
  <span class="dot"></span>
  <span id="themeLabel">Light</span>
</button>
```

Persists to `localStorage` under `idx-theme`. Same control on every surface, top right by convention.

### Tag

```html
<span class="tag go"><span class="dot"></span>active</span>
<span class="tag wait"><span class="dot"></span>pending</span>
<span class="tag stop"><span class="dot"></span>blocked</span>
<span class="tag accent"><span class="dot"></span>cited</span>
```

11px mono label, 1px hairline, 2px radius. Dot signals status.

### Input

```html
<input class="input" placeholder="A note, a line" />
```

Hairline border, no fill, mono placeholder color is `--ink-faint`, focus border darkens to `--ink`.

### Frame / card

```html
<div class="frame elev">...</div>
```

The universal container. `--bg-elev` background, hairline border, 2px radius, no shadow.

### Entry row (dashboard)

A 4 column grid: `[id 80px] [time 100px] [content 1fr] [actions auto]`. ID and time are mono and muted. Content is sans 14/1.45. Tags appear below the content in mono 11. Whole row darkens to `--bg-elev` on hover.

### Entry card (mobile)

A 2 column grid: `[meta 56px min] [content 1fr]`. Meta column stacks ID and time vertically in mono 10. Content is sans 14/1.45. Tags below content. Tap target is the entire row, minimum 44pt tall.

### Capture

```html
<div class="capture">
  <textarea placeholder="A note, a line, a citation,"></textarea>
  <div class="controls">
    <div class="left-controls">
      <span>#tag</span><span>§cite</span><span>¶thread</span>
    </div>
    <button>Save</button>
  </div>
</div>
```

Lives in the right rail of the dashboard. On mobile, collapses to a single 44pt bar with a `+` circle on the right.

### Sidebar nav item

- 28pt row height (`7px 16px` padding).
- Left side: 2px transparent border. Becomes `--accent` when active.
- Background goes to `--bg-elev` on hover and when active.
- Glyph is mono 11px, muted by default, accent when active.
- Count is mono 10px, right aligned, faint.

### Stat strip

A 4 column grid of stat cells, separated by hairlines, inside a frame. Each cell has a mono uppercase label (10px), a numeric value (22px, tabular nums), and a delta line in mono 10px tinted by signal color.

### Live dot

```html
<span class="live-dot"></span>
```

8px circle in accent, with a 2s pulse. Used in footers, status bars, and active threads.

### Sparkline

Inline SVG, 1.2px stroke, ink color, with a 2.5r accent dot on the latest point. Width fills container, 32px tall.

---

## Layout

- **Asymmetric grids.** Avoid perfectly symmetric layouts. Prefer ratios like `1fr 1.4fr 1fr` or `1.2fr 1.4fr 1fr`. Never split a wide region 50/50.
- **Mono left, sans right.** Within a row, mono metadata sits on the left, sans content on the right.
- **Hairline only.** Use 1px borders to separate, never blocks of background color, never shadows.
- **Generous gutters.** Sections breathe with `--s-9` between them on landing; `--s-5` on the dashboard.
- **Top down rhythm.** Page title, then meta strip, then content list. Always in that order.

---

## Patterns

### Landing surface

- Three column info row up top (Currently / Lately / Featured).
- Hero is a single editorial paragraph, max 640px wide, set in `--t-h4` (22/1.35) sans.
- Each case section is wrapped in a top border, a centered uppercase title, a 2 column meta row (Category, Services), and a 3 column tile grid.
- Tiles are 4/5 aspect ratio frames. Vary their content: poster, product mock, glyph grid, terminal, table.
- Footer has the giant wordmark on the left, a one line credit center, and a live clock right.

### Dashboard surface

- Three column shell: `[sidebar 220px] [main 1fr] [rail 320px]`.
- Top bar 52px tall, spans all columns, brand on the left, search center, theme + avatar right.
- Main pane starts with a day head (large title, mono date, stats row right aligned), then a stat strip, then a list of entries grouped by day with mono dividers between days.
- Right rail holds quick capture, week sparkline, and active threads.

### Mobile surface

- Phone width 380pt on a desktop demo, fullscreen on actual mobile.
- Status bar (mono 13, 44pt), app head (brand + theme toggle), day strip (28pt title, mono meta, stats row), then a scroll region containing capture bar, week summary card, and entries grouped by day.
- Bottom tab bar: 4 tabs. Mono 10 labels, accent glyph on active tab.
- Minimum tap target 44pt everywhere.

---

## Motion

- **Durations.** `--dur-fast` 120ms, `--dur-med` 220ms, `--dur-slow` 420ms.
- **Easing.** Single curve: `cubic-bezier(0.2, 0.0, 0.0, 1.0)`. Token: `--ease`.
- **Reveal on load.** Use `.reveal` with delay modifiers `.d1` to `.d6` for staggered entrances on landing.
- **Hover.** Borders darken, backgrounds shift one step (`--bg` to `--bg-elev`). Avoid scale or translate hovers.
- **Arrow links.** Inline arrows nudge 3px right on hover.
- **Live dot.** 2s pulse, opacity 1 to 0.4 to 1.
- **Theme transitions.** Background and color transition `--dur-med`.

No spring physics. No parallax. No content reflow on hover.

---

## Anti-patterns

- Don't use em dashes — use `;` `,` `:` or `/`; the semicolon discipline is part of the voice.
- Don't add drop shadows, glassmorphism, or neumorphism — depth comes from warm surface steps, not blur.
- Don't round corners larger than 4px — the system reads flat and editorial, not soft.
- Don't add gradients except the one warm accent-soft surface — extra gradients break the quiet.
- Don't introduce purple, blue, neon, or rainbow charts — one terracotta accent enforces the discipline.
- Don't put emoji in UI labels — symbols come from the typeface instead.
- Don't use serif typefaces — the contrast is mono vs sans, nothing else.
- Don't reach for an icon library — typeface glyphs carry meaning.
- Don't write "Welcome back!" empty states — state the data, in mono.
- Don't use skeleton shimmer — render mono dashes in `--ink-faint` as the placeholder.
