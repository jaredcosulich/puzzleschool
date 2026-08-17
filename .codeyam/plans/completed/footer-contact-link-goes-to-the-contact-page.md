---
title: "Footer Contact link goes to the contact page"
mode: ui
createdAt: "2026-08-17T01:29:25Z"
source: manual
---

## Summary

The footer's "Contact" link opens the visitor's mail client instead of going to
the site's Contact page. `BaseLayout.astro` builds the href with
`buildMailto({ to: settings.contactEmail, ... })` and hands it to `SiteFooter`,
so every page footer emits `<a href="mailto:hello@puzzleschool.org?subject=...">`.
The `/contact` page already exists (`src/content/pages/contact.md`, listed in
`src/data/nav.json`) and carries the real "write to us" call to action, so the
footer should point at that page and let the page own the mailto. This is not
fixable from the CMS: the Settings singleton's editable fields are fixed by the
`@codeyam/cms` package (siteTitle, siteUrl, description, contactEmail,
footerText, socials) and `src/data/collections.json` can only shape the `pages`
collection — there is no field anywhere that controls where the footer link
points.

Rather than hardcode `/contact` in the layout, resolve the destination from the
editable nav singleton, so an editor who renames or moves the Contact page in
the CMS retargets the footer with it.

## Key Decisions

- **Derive the destination from `src/data/nav.json`, not a literal path.** The
  nav singleton is already CMS-editable and already holds `{ label: "Contact",
  url: "/contact" }`. Reading it keeps the footer link and the nav entry from
  drifting apart, and gives the CMS indirect control over the footer link
  without needing a new settings field the CMS package does not support.
- **Fall back to the literal `/contact`.** If an editor removes the Contact nav
  item, the footer must still link somewhere real rather than render an empty
  `href`. The page itself is not nav-gated, so the fallback is always valid.
- **Put the lookup in a new pure module, not in `src/lib/site.ts`.** `site.ts`
  resolves the data root at module scope via `fs`, which makes it awkward to
  unit test in isolation. A pure `resolveContactUrl(nav)` mirrors the existing
  `buildMailto` / `linkedCmsPath` pattern — a small pure helper with its own
  vitest file — and is directly testable.
- **Leave `buildMailto` and the page-level contact button alone.** The mailto
  is still correct where it belongs: `src/pages/[...slug].astro` builds it for
  `ContactButton`, which is what the Contact page renders via
  `showContactButton: true`. Only the footer changes.
- **Match the nav item case-insensitively by label, then by url prefix.** The
  label is what an editor sees and edits; matching on the url as a second pass
  keeps the link working if the label is reworded to something like "Get in
  touch".

## Implementation

### 1. Add the nav-to-contact-url helper

**New file**: `src/lib/contactUrl.ts`

Export `resolveContactUrl(nav: SiteNav): string`. Walk the nav items (top level
and any `children`), and return the first `url` whose item either has a label
matching `contact` case-insensitively, or whose `url` starts with `/contact`.
Ignore items with no `url` (dropdown parents). Return `'/contact'` when nothing
matches. Import the `SiteNav` / `NavItem` types from `src/lib/site.ts` so there
is one definition of nav shape.

Keep the module free of `fs` and of any `src/data` import so it stays pure and
testable — the caller passes the already-loaded nav.

### 2. Cover the helper with unit tests

**New file**: `src/lib/contactUrl.test.ts`

Follow the shape of `src/lib/linkedCmsPath.test.ts`. Each test needs the
mandatory `//` description comment above it. Cases:

- the default nav (About + Contact) resolves to `/contact`
- a relabelled item ("Get in touch" → `/contact`) still resolves via its url
- a Contact item moved to a different url (`/get-in-touch`) resolves to that url
- a nested Contact item under a dropdown parent resolves
- a nav with no contact entry falls back to `/contact`
- a dropdown parent with no `url` is skipped rather than returning `undefined`

### 3. Point the footer at the contact page

**File**: `src/layouts/BaseLayout.astro`

Replace the `buildMailto` call (currently at lines 45-48) with
`resolveContactUrl(nav)`, and drop the now-unused `buildMailto` import. Update
the file's header comment, which currently promises that header and footer are
CMS data edits — that stays true, and the footer link now joins it.

### 4. Correct the footer prop documentation

**File**: `src/components/chrome/SiteFooter.astro`

The `contactHref` prop doc (line 15) says "a mailto built from settings" — that
is no longer what it receives. Reword to describe a page url resolved from the
nav singleton. The markup at line 27 is unchanged: the component still just
renders whatever href it is handed. Consider renaming the prop to `contactUrl`
for clarity; if renamed, update all three call sites listed below in the same
change.

### 5. Update the isolated-component capture pages

**File**: `src/pages/isolated-components/SiteFooter.astro`

**File**: `src/pages/isolated-components/SiteFooterHome.astro`

Both pass `contactHref="mailto:hello@puzzleschool.org"` literally, so the
SiteFooter scenarios would keep screenshotting the old shape. Change both to
`contactHref="/contact"` so the captures exercise the real value. While in
`src/pages/isolated-components/SiteFooter.astro`, the stale TODO comment at the
top referencing the mailto prop can be dropped — the props are real now.

## Reused existing code

- `getNav` from `src/lib/site.ts` — already loaded in `src/layouts/BaseLayout.astro`;
  no new data read is needed, the nav object is already in scope.
- `SiteNav` / `NavItem` types from `src/lib/site.ts` — reused by the new helper
  rather than redeclared.
- `SiteFooter` from `src/components/chrome/SiteFooter.astro` — unchanged markup;
  only its prop doc (and optionally its prop name) moves.
- `buildMailto` from `src/lib/mailto.ts` (glossary entry: `buildMailto`) — kept,
  and still used by `src/pages/[...slug].astro` for the page-level contact
  button. Not deleted.
- `linkedPathForRealFile` from `src/lib/linkedCmsPath.ts` — the structural model
  for the new helper: a small pure function with a colocated vitest file.

**Existing-implementation survey.** There is no existing footer-link or
contact-url field anywhere to extend. `src/data/settings.json` has no link
field; the CMS settings form is hardcoded in
`node_modules/@codeyam/cms/src/lib/settingsEditor.ts` to siteTitle, siteUrl,
description, contactEmail, footerText and socials, and `src/data/collections.json`
declares builtins only for the `pages` collection. Nothing equivalent to
`resolveContactUrl` exists in `src/lib/` today — `buildMailto` is the only
link-construction helper and it builds mailto URLs only.

## Reproduction Test

The buggy behavior is that the footer's Contact anchor emits a mailto: URL
instead of the /contact page path.

No unit-level reproduction is writable: the defect lives in the .astro layout
wiring, and this project's vitest setup only covers pure modules under
src/lib/ (there is no Astro component render harness — the four existing test
files are all lib helpers). The new helper tests in step 2 are forward coverage
on new code, not a red-first repro of the current bug.

Demonstrate the fix through the scenario captures instead: the SiteFooter
isolated-component scenarios and any full-page scenario show the anchor's
destination, and the contact-email-only scenario confirms the page-level mailto
button is untouched.

## Scenarios to Demonstrate

- `SiteFooter - Default` — internal-variant footer, Contact link resolving to `/contact`
- `SiteFooter - Home Variant` — home-variant footer, same destination on the wide gutter
- `home-full-design` — footer in place on the home page
- `about-full-design` — footer in place on an internal page
- `contact-email-only` — the Contact page itself, confirming the page-level mailto button still opens the mail client
- Nav with the Contact item relabelled ("Get in touch") — footer still resolves to the page
- Nav with the Contact item removed entirely — footer falls back to `/contact`