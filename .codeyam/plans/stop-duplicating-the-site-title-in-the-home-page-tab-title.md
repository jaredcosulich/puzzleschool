---
title: "Stop duplicating the site title in the home page tab title"
mode: ui
createdAt: "2026-08-17T01:39:05Z"
source: manual
---

## Summary

Every page's `<title>` is composed in `src/components/SEO.astro` as `` `${title} · ${settings.siteTitle}` ``, with the bare site title used only when a page passes no `title` at all. The home page does pass one — `src/content/pages/home.md` has `title: The Puzzle School`, which is character-for-character the `siteTitle` in `src/data/settings.json` — so the browser tab, the OG title, and the Twitter card title all read **"The Puzzle School · The Puzzle School"**. The suffix exists to give a page context ("About · The Puzzle School"); when the page title already *is* the site title there is no context to add and the suffix is pure duplication. Fix it by making the composition itself dedupe: extract the rule into a small pure helper, `src/lib/pageTitle.ts` (new), and have `src/components/SEO.astro` call it. Doing it in the composition rather than at the home page's call site means it also holds when a CMS editor renames the site or titles some other page to match — neither of which is a source change anyone would think to re-check.

## Key Decisions

- **Dedupe inside the title composition, not at the home page's call site.** The alternative — dropping the `title` prop from `src/pages/index.astro` so `src/components/SEO.astro` falls back to the bare site title — is a smaller diff but fixes exactly one page. Both titles involved are CMS-editable content (`home.md` frontmatter and `settings.json`), so the collision can reappear from a pure data edit with no code review in the loop. Home keeps passing `title`, which also keeps it available for `og:title`/`twitter:title`.
- **Extract to `src/lib/pageTitle.ts` (new) rather than inlining the condition in the `.astro` frontmatter.** The project's vitest setup covers `src/lib/*.ts` only; there is no component-rendering test harness, so logic left inside `src/components/SEO.astro` is untestable by construction. `src/lib/mailto.ts` is the established precedent — a pure string-building helper pulled out of a component and consumed from the layout.
- **Compare trimmed and case-insensitively.** `title: the puzzle school` or a stray trailing space in the CMS is the same collision to a reader, and an exact `===` would miss it. Whitespace-only and absent titles collapse to the bare site title through the same path.
- **Separator stays `·` and stays in the helper.** It is the only place the site composes a title, so the character lives with the rule instead of being duplicated at the call site.
- **No visual change.** `Masthead` on home and `PageHeader` on inner pages receive `title` directly from their page's frontmatter and are untouched — this is a `<head>` fix only.

## Implementation

### 1. Add the title-composition helper

**New file**: `src/lib/pageTitle.ts`

Export `composePageTitle(pageTitle: string | undefined, siteTitle: string): string`:

- Return `siteTitle` when `pageTitle` is `undefined`, empty, or whitespace-only.
- Return `siteTitle` when the two match after `trim()` + case-insensitive compare — the deduplication case.
- Otherwise return `` `${pageTitle} · ${siteTitle}` ``, using the trimmed page title.

Head-comment it in the register the rest of `src/lib` uses: say what the suffix is *for* (per-page context in a tab strip / search result), and that home hits the dedupe branch because its content title and the site title are the same editable string.

### 2. Use the helper in the SEO component

**File**: `src/components/SEO.astro`

Import `composePageTitle` and replace the inline `pageTitle` expression:

```ts
const pageTitle = composePageTitle(title, settings.siteTitle);
```

`pageTitle` already feeds `<title>`, `og:title`, and `twitter:title`, so all three are corrected by this one substitution. The existing comment above the expression documents the old `"Page · Site"` rule — update it to name the dedupe branch too.

## Reused existing code

- `getSettings` from `src/lib/site.ts` — already imported by `src/components/SEO.astro`; supplies `siteTitle`. Read per call by design (see that file's comment), so scenario seeding that varies `siteTitle` flows through the new helper without extra wiring.
- `src/lib/mailto.ts` (`buildMailto`) — the structural precedent this change follows: a pure, dependency-free string builder in `src/lib`, consumed from a layout/component. The new helper should match its shape and comment density.
- `src/lib/linkedCmsPath.test.ts` — the test-file convention to mirror: `describe` named for the function, a `//` comment above each `it` explaining what would break if the case regressed.
- Existing-implementation survey: no title-composition helper exists anywhere in `src/lib` today, and `codeyam-editor editor glossary-find SEO --substring` returns zero entries — the composition lives only as the inline expression in `src/components/SEO.astro`, which is the single site-wide `<title>` seam. `src/pages/index.astro` and the bracketed catch-all route file beside it (the dynamic slug route under src/pages/) are its only two upstream callers (both via `BaseLayout`).

## Reproduction Test

Pins the head-title composition so a page whose title equals the site title renders one title, not two.

**Target**: `src/lib/pageTitle.test.ts` (new) — run with `codeyam-editor editor refresh-tests --test composePageTitle`.

```ts
import { describe, expect, it } from 'vitest';

import { composePageTitle } from './pageTitle';

describe('composePageTitle', () => {
  // The bug: home's content title IS the site title, so the generic
  // "Page · Site" rule rendered "The Puzzle School · The Puzzle School" in the
  // tab, the OG card, and the Twitter card. There is no context to add when the
  // page already names the site.
  it('does not append the site title when the page title already is it', () => {
    expect(composePageTitle('The Puzzle School', 'The Puzzle School')).toBe('The Puzzle School');
  });

  // The suffix has to survive for every other page — that is what makes a tab
  // strip readable when several pages of the site are open at once.
  it('appends the site title for an ordinary page', () => {
    expect(composePageTitle('About', 'The Puzzle School')).toBe('About · The Puzzle School');
  });

  // Both titles are CMS-editable, so the collision can arrive with different
  // casing or a stray trailing space from a content edit no reviewer sees.
  it('treats a differently-cased or padded match as the same title', () => {
    expect(composePageTitle('  the puzzle school ', 'The Puzzle School')).toBe('The Puzzle School');
  });

  // A page that passes no title at all falls back to the bare site title —
  // the behavior the old `title ? ... : siteTitle` ternary already had.
  it('falls back to the site title when the page passes none', () => {
    expect(composePageTitle(undefined, 'The Puzzle School')).toBe('The Puzzle School');
    expect(composePageTitle('   ', 'The Puzzle School')).toBe('The Puzzle School');
  });
});
```

Status: PROPOSED — confirm red at execution. Expected failure: `src/lib/pageTitle.ts` does not exist yet, so the suite fails to resolve the import before any assertion runs. Once the helper exists but before the dedupe branch is added, the first and third cases fail with `"The Puzzle School · The Puzzle School"` received where `"The Puzzle School"` was expected.

## Scenarios to Demonstrate

- **Home page** — the fix in place: one "The Puzzle School" in the tab title and in the OG/Twitter title tags.
- **An inner page (`/about`)** — the suffix still applied: "About · The Puzzle School".
- **Site title renamed via settings** — seed `settings.json` with a different `siteTitle` while `home.md` keeps `title: The Puzzle School`; home should now legitimately read "The Puzzle School · <new site title>", proving the dedupe is a match test rather than a hardcoded home-page exception.
- **A CMS-authored collision on an inner page** — a page whose frontmatter title matches the site title renders the bare site title, no suffix.
- **Page with no title** — falls back to the bare site title, unchanged from today.