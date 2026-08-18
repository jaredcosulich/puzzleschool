---
title: "Current-Year Copyright in the Footer"
mode: ui
createdAt: "2026-08-17T23:37:47Z"
source: manual
---

## Summary

The site footer currently ends at the "Contact" link. Add a `© <year>` notice to
the right of that link, in both footer variants, showing the **current** year
rather than a literal. The site is `output: 'static'` and deploys only on push to
`main` (`.github/workflows/deploy.yml`), so a build-time year would be frozen at
the last deploy — correct today, wrong for however long January runs without a
push. The year is therefore rendered at build time (so no-JS visitors and the
first paint both get a real year) and corrected on load by a small client script
when the visitor's year differs, using one shared pure helper so the two paths
can never format the label differently.

## Key Decisions

- **Build-time render + client correction**, chosen over build-time alone and
  over a scheduled CI rebuild. Build-time alone goes stale (the deploy workflow
  fires on `push` and `workflow_dispatch` only — there is no `schedule`); a cron
  rebuild fixes staleness but makes the footer's correctness depend on CI
  running on time, and still leaves a window. The client correction makes the
  year right for the visitor, whenever they visit, with no deploy.
- **One pure helper, `copyrightLabel(now: Date)`, used by both paths.** The
  server frontmatter and the browser script call the same function, so the
  format (`© 2026`) is stated once. This is also what makes the behaviour
  testable — the same shape as `resolveContactUrl` in `src/lib/contactUrl.ts`
  and `applyTreeGrowth` in `src/lib/tree-dom.ts`: a pure function in `src/lib`
  with a colocated vitest file, no `fs` and no `src/data` import.
- **The date is a parameter, not read inside the helper.** `copyrightLabel` takes
  a `Date`; the callers pass `new Date()`. That is what lets the unit tests pin a
  year boundary without mocking a global clock.
- **The notice is derived, not CMS-editable.** `settings.footerText` stays exactly
  as it is and keeps its `cmsSetting('footerText')` marker. The copyright is
  computed from the clock, so giving it a marker would let a staged edit write a
  literal year over a self-updating one — the same failure mode the Contact link
  was deliberately left unmarked to avoid (see the comment at
  `src/components/chrome/SiteFooter.astro:33`).
- **The link and the notice become one right-hand group.** `.footer` is
  `justify-content: space-between`, so adding a third direct child would
  redistribute the row into three evenly-spaced items and move the brand line.
  Wrapping the link and the notice in a single element keeps the row a
  two-ended layout, which is what both designs specify.
- **No capture-freeze escape hatch.** The branching tree needs `?tree=static`
  because its client script draws a *different* figure than the server did. This
  script writes the same string the server wrote in every case except an actual
  year rollover, so there is no swap for a screenshot to race.

## Implementation

### 1. The pure helper

**New file**: `src/lib/copyright.ts`

Export `copyrightLabel(now: Date): string` returning `` `© ${now.getFullYear()}` ``.
Document why the date is a parameter (testability, and one formatting site shared
by the server render and the browser correction) and that `getFullYear` is
deliberately local-time: the visitor's own year is the one their footer should
show, and the build machine's local year is the right default to ship.

### 2. Unit tests for the helper

**New file**: `src/lib/copyright.test.ts`

Colocated vitest, matching `src/lib/contactUrl.test.ts` in shape — each `it()`
preceded by a `//` description comment explaining what the case proves, not
restating the assertion. Cover:

- formats the year of the given date as `© 2026`
- reads the year from the date it is given, not from the clock (pass a date in a
  different year and assert the label follows it)
- a New Year's Eve date and a New Year's Day date one second apart produce
  different labels — the rollover this whole feature exists for
- uses local time rather than UTC, so a visitor in a timezone where it is already
  next year sees next year

Register the tests with `codeyam-editor editor refresh-tests` so they land in
`.codeyam/test-registry.json` alongside the other `src/lib` suites.

### 3. Render the notice in the footer

**File**: `src/components/chrome/SiteFooter.astro`

- Import `copyrightLabel` from the helper module added in step 1 and compute the
  build-time label in the frontmatter.
- Wrap the existing `<a href={contactUrl}>Contact</a>` and a new
  `<span class="footer__copyright" data-current-year>{label}</span>` in a
  `<div class="footer__end">`, preserving the existing comment above the link
  that explains why it carries no CMS marker.
- Add a `<script>` (a bundled Astro script with a real import, the idiom used by
  `src/components/structures/BranchingTree.astro:88`, not `is:inline`) that
  imports `copyrightLabel`, finds `[data-current-year]`, and rewrites
  `textContent` from `new Date()`. Guard on the element existing. Assigning the
  same string when nothing changed is a no-op, so no equality check is needed —
  but say so in a comment rather than leaving it looking accidental.
- Styles: give `.footer__end` `display: flex; align-items: center;` with a gap
  that matches each variant's existing rhythm — the variant rules already set
  `.footer__brand` gaps of `12px` (home) and `11px` (internal); use
  `var(--space-xs)` (12px) for the end group in both, which reads as a
  deliberate separation between two distinct items rather than the tight
  mark-to-text pairing on the brand side. `.footer__copyright` inherits the
  footer's `--size-footer`, weight, tracking, uppercase and `--footer-text`
  colour, so it needs no colour or type rules of its own. The `<footer>` already
  sets `flex-wrap: wrap`; keep it, so the group drops to a second row at narrow
  viewports instead of crushing the brand line.

### 4. Re-capture the footer scenarios

**File**: `src/pages/isolated-components/SiteFooter.astro`
**File**: `src/pages/isolated-components/SiteFooterHome.astro`

No prop changes: the label is computed inside the component, so both isolation
pages keep their current `text` / `contactUrl` / `variant` props verbatim. They
are listed here because their captures will change — both scenarios need
re-screenshotting so the stored frames show the new right-hand group rather than
the bare link.

## Reused existing code

- `resolveContactUrl` from `src/lib/contactUrl.ts` (glossary entry:
  `resolveContactUrl`) — not called by this change, but its module comment states
  the pure-function-with-colocated-test convention the new helper follows.
- `SiteFooter` from `src/components/chrome/SiteFooter.astro` (glossary entry:
  `SiteFooter`) — the component being extended; its two-variant structure and
  `cmsSetting('footerText')` marker are preserved as-is.
- `cmsSetting` from `src/lib/cmsMarkers.ts` (glossary entry: `cmsSetting`) —
  deliberately NOT applied to the new element; noted so the omission reads as a
  decision rather than an oversight.
- `applyTreeGrowth` from `src/lib/tree-dom.ts` (glossary entry: `applyTreeGrowth`)
  — the precedent for a pure `src/lib` function that a client script imports;
  `src/components/structures/BranchingTree.astro` is the precedent for the
  bundled-`<script>`-with-imports idiom itself.
- Design tokens `--size-footer`, `--footer-text` and `--space-xs` from
  `src/styles/tokens.css`.
- **Existing-implementation survey**: nothing in the repo formats or renders a
  year today. `src/data/settings.json` has no year field, and `footerText` is the
  literal `"THE PUZZLE SCHOOL · K–12"`. There is no `src/lib` date or copyright
  helper — greps for year, copyright and the © glyph across `src/` and
  `.codeyam/glossary-index.txt` return nothing. This is genuinely new code, not a
  duplicate of an existing seam.

## Scenarios to Demonstrate

- Internal-page footer (`/isolated-components/SiteFooter`) — brand line left,
  `Contact  © <year>` right, on the 40px gutter and 30px band.
- Home footer (`/isolated-components/SiteFooterHome`) — same pairing on the wide
  gutter with the deeper foot and top-aligned rows.
- A full internal page (`/about`) and Home (`/`) so the footer is seen in the
  page it actually terminates, at the real page width.
- Narrow viewport (~380px) — `flex-wrap` drops the `Contact  © <year>` group to
  its own row without crushing the brand line or breaking between the `©` and
  the year.
- Year rollover — the build-time render says one year and the client script
  corrects it to the next; demonstrable by pointing the helper at a date one
  second either side of midnight on Dec 31.
- No-JS render — the build-time year is present in the served HTML, so the
  footer is complete before (and without) the script.