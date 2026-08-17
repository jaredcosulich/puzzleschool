---
title: "Highlight the current page in the header nav"
mode: ui
createdAt: "2026-08-17T10:40:28Z"
source: manual
---

## Summary

The header nav is supposed to highlight the page you are on — `SiteNav.astro`
already carries an `.is-current` rule that inks the label and draws a 2px teal
underline — but the highlight never appears on the live site. The active-link
test is a raw string equality, `item.url === currentPath`, and the two sides
disagree about trailing slashes: `nav.json` stores `/about`, while Astro's
default `build.format: 'directory'` emits `dist/about/index.html`, so at render
time `Astro.url.pathname` is `/about/`. The comparison fails and both links stay
muted. Confirmed in the built output: `dist/about/index.html` and
`dist/contact/index.html` both render `class="nav__link"` with no `is-current`
on either link. Fix the comparison (not the styling) by normalizing both sides
before matching, and add `aria-current="page"` so the active item is announced
to screen readers, not only drawn.

## Key Decisions

- **Normalize both sides, don't just strip one.** The mismatch can appear from
  either direction: a CMS editor could equally type `/about/` into `nav.json`
  and break the match in dev (where the pathname is `/about`). A shared
  normalizer makes the comparison insensitive to how either value is written.
- **Put the comparison in a pure, tested helper in `src/lib/site.ts`.**
  `.astro` files are not imported by vitest (see the note in `vitest.config.ts`)
  — they are covered by captured scenarios. Extracting the predicate is what
  makes this bug unit-testable at all, and `site.ts` already owns the `NavItem`
  type the helper operates on.
- **Keep the existing visual treatment.** The ink + teal underline already in
  `SiteNav.astro` is the intended design; the bug is that it never applies. No
  style change.
- **Add `aria-current="page"` alongside the class.** The visual highlight and
  the semantic one should land together; a purely visual current-page marker is
  an accessibility gap, and adding it costs one attribute.
- **Treat the site root specially.** Normalizing `/` must not collapse it to the
  empty string, or a future `Home` nav item would match every path.

## Implementation

### 1. Add a tested current-path predicate

**File**: `src/lib/site.ts`

Add two exports beside the existing `getNav` / `getSettings`:

- `normalizeNavPath(path: string): string` — trim whitespace, drop any query
  string or hash, strip a single trailing `/` unless the result would be empty
  (so `/` stays `/`), and lowercase the result. Returns `'/'` for an empty or
  missing input.
- `isCurrentNavPath(itemUrl: string | undefined, currentPath: string): boolean`
  — `false` when `itemUrl` is undefined (a `NavItem` may be a parent with only
  `children`), otherwise `normalizeNavPath(itemUrl) === normalizeNavPath(currentPath)`.

Keep both pure — no `fs`, no Astro globals — so they are unit-testable.

### 2. Use the predicate in the nav, and mark it semantically

**File**: `src/components/chrome/SiteNav.astro`

- Import `isCurrentNavPath` from `../../lib/site`.
- Replace the inline `item.url === currentPath` in the `class:list` with
  `isCurrentNavPath(item.url, currentPath)`.
- Compute the flag once per item and use it for both the class and a new
  `aria-current={isCurrent ? 'page' : undefined}` on the `<a>`.
- Update the comment above the `.is-current` CSS rule to note that matching is
  trailing-slash insensitive, so the next reader doesn't reintroduce a strict
  compare.

No change to the `.is-current` CSS block itself.

### 3. Cover the isolation page for the "no match" state

**File**: `src/pages/isolated-components/SiteNav.astro`

The existing isolation page passes `currentPath="/about"`, which matched even
under the bug, so the captured `SiteNav - Default` scenario looks correct and
hid the regression. Change it to pass `currentPath="/about/"` — the trailing-slash
form the real build actually produces — so the captured scenario exercises the
path that was broken. The scenario `.codeyam/scenarios/sitenav-default.json`
needs no edit; only the props change.

## Reused existing code

- `getNav` and `NavItem` from `src/lib/site.ts` (glossary entries: `getNav`,
  `readSingleton`) — the new helpers live in this same module and operate on
  the `NavItem` shape it already exports.
- The existing `.is-current` CSS rule and `class:list` binding in
  `src/components/chrome/SiteNav.astro` — reused as-is; only the boolean feeding
  them changes.
- The current pathname, already threaded from `src/layouts/BaseLayout.astro`
  into `SiteNav` as `currentPath` — no new plumbing needed.
- The `SiteNav - Default` scenario (`.codeyam/scenarios/sitenav-default.json`)
  and its isolation page — reused to demonstrate the fix visually.
- **Existing-implementation survey**: grepped `src/` for any other
  active/current-link logic. There is none — `src/components/chrome/SiteFooter.astro`
  renders links with no current-page state, and the home masthead
  (`src/components/home/Masthead.astro`) has no nav. The strict equality on
  line 31 of `src/components/chrome/SiteNav.astro` is the only such comparison
  in the repo, so there is no
  existing normalizer to reuse and nothing this duplicates.

## Reproduction Test

Pins that a nav item whose stored URL has no trailing slash is still recognized
as current when the rendered pathname has one — the exact mismatch that leaves
About and Contact unhighlighted in the built site.

**Target**: `src/lib/site.test.ts` (new file) — run with
`codeyam-editor editor refresh-tests --test isCurrentNavPath`.

```ts
import { describe, it, expect } from 'vitest';
import { isCurrentNavPath, normalizeNavPath } from './site';

describe('isCurrentNavPath', () => {
  // Matches a nav URL stored without a trailing slash against the trailing-slash
  // pathname Astro's directory build actually renders.
  it('treats /about and /about/ as the same page', () => {
    expect(isCurrentNavPath('/about', '/about/')).toBe(true);
  });

  // The mismatch can come from either side: a CMS editor may store the slashed form.
  it('matches when the stored nav URL is the slashed form', () => {
    expect(isCurrentNavPath('/contact/', '/contact')).toBe(true);
  });

  // Different pages must not collide once slashes are normalized away.
  it('does not mark a different page as current', () => {
    expect(isCurrentNavPath('/about', '/contact/')).toBe(false);
  });

  // A parent nav item with only children carries no URL and is never current.
  it('is false for a nav item with no url', () => {
    expect(isCurrentNavPath(undefined, '/about/')).toBe(false);
  });

  // The site root must not normalize to the empty string, or it would match everything.
  it('keeps the site root as /', () => {
    expect(normalizeNavPath('/')).toBe('/');
    expect(isCurrentNavPath('/', '/about/')).toBe(false);
  });
});
```

Status: PROPOSED — confirm red at execution. Expected failure: the module has no
`isCurrentNavPath` or `normalizeNavPath` export yet, so the import fails and the
whole file errors before any assertion runs. If the helpers are stubbed first,
the first case fails with `expected false to be true`.

## Scenarios to Demonstrate

- On `/about/`: the About link inked with the teal underline, Contact muted.
- On `/contact/`: the Contact link inked, About muted.
- On `/` (home): no nav bar at all — home passes `showNav={false}`, so the fix
  must not introduce one.
- A nav item pointing at a path not currently rendered (e.g. a third CMS-added
  page while on About): nothing highlighted but the one true current item.
- Nav data stored with trailing slashes (`/about/` in `nav.json`) against a
  non-slashed pathname: still highlights, proving the match is symmetric.