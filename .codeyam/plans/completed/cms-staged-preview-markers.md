---
title: "CMS Staged-Preview Markers"
mode: ui
createdAt: "2026-08-15T19:36:43Z"
source: manual
---

## Summary

The CMS ships a staged-preview script (injected automatically by the integration
since `@codeyam/cms@0.6.0`) that patches the site's own pages in the editor's
browser when a page is opened with `?cms-preview=1`. It finds what to patch
through inert `data-cms-*` attributes the consuming site puts on its own
templates. This site carries none, so every entry preview falls through to
`patchByShape` — "the first `<h1>` in the article, and the article's last block"
— and the banner says *"matched by shape, so this is an approximation"* every
time. On this design that fallback is worse than approximate: `patchByShape`
scopes to `document.querySelector('article') ?? document.querySelector('main')`,
and the only `<article>` on the home page is the first `ActionCard`, so a staged
home edit rewrites a card's body with the page's markdown. Internal pages have
neither an `<article>` nor a `<main>`, so they patch nothing at all
(`fidelity: 'none'`).

Mark up the templates so the preview is exact: the two chrome components
(footer settings, nav items, site title) and the page templates plus the
home/internal section components (entry root, one marker per frontmatter field,
one for the markdown body). The markers are inert — they add an attribute and
nothing else: no styling, no behaviour, no element added, moved, or removed.

One addition beyond the marker work, included because without it the markers
are never reached: `src/data/collections.json` declares no `paths`, so
`entryPagePath` falls back to `/<collection>/<slug>` and a staged `about` edit
resolves to `/pages/about`. This site serves that page at `/about`, so
`matchTarget` returns `null`, the banner reads "Nothing staged for this page",
and `applyStagedContent` never runs. One line of site-authored routing config
fixes it, it is the same review, and the plan's own acceptance check cannot pass
without it.

## Key Decisions

- **Import every attribute name from `@codeyam/cms/lib/stagedPreview` and spread
  it** — `{...{ [CMS_FIELD_ATTR]: 'title' }}` — never a hardcoded `data-cms-*`
  string. The attribute names are the CMS's public contract; a literal in this
  repo is a copy that silently stops matching if the contract moves. The site
  already imports across this seam (`@codeyam/cms/content` in
  `src/content/config.ts`), so the export map (`"./lib/*": "./src/lib/*.ts"`)
  is a proven path.

- **The entry root goes on `div.page` in `BaseLayout.astro`, via a new optional
  `entryKey` prop.** `patchByMarkers(root, …)` finds fields with
  `root.querySelectorAll('[data-cms-field]')`, so every marked field must be a
  DESCENDANT of the `[data-cms-entry]` element. On both templates the marked
  sections (`PageHeader` / `ProseColumns` / `ExploratoryBand`, or `Masthead` /
  `StatementBlock` / `QuoteBand`) are siblings inside `BaseLayout`'s `<slot />`,
  and their only common ancestor already in the markup is `div.page`. A prop
  adds no element and reorders nothing, which a new wrapper would; pages that
  pass no `entryKey` (the isolated-component pages) render exactly as they do
  today.

- **Field markers carry the FRONTMATTER key, not the component's prop name.**
  `patchByMarkers` looks the value up as `data[field]` against parsed
  frontmatter. `BandQuote` and `QuoteBand` both take a prop called
  `attribution`, but the frontmatter key is `quoteAttribution` — that is what
  the marker must say.

- **The action cards are deliberately NOT marked.** `ActionCard`'s `title` and
  `body` come from a row of the `cards` array, not from top-level frontmatter.
  Marking them `data-cms-field="title"` would make the preview write the PAGE's
  title into a card heading. `fieldText` returns `null` for arrays, so `cards`
  has no single text form and is not previewable at all — leaving the published
  cards in place is the correct behaviour, and the CMS already chose it.

- **`data-cms-setting` vs `data-cms-setting-href` on the footer, exactly as the
  contract splits them.** `settingText` would overwrite the visible "Contact"
  label with a URL; `settingHref('contactEmail')` instead rebuilds the mailto
  through `buildMailto({ to, subject: 'Hello from <siteTitle>' })` — the same
  construction `BaseLayout` uses, so a staged change to either the address or
  the site title previews correctly.

- **The site-title marker goes on the `<span>`, not the brand `<a>`.**
  `patchSettings` sets `el.textContent`, which on the anchor would delete the
  `Mark` SVG beside the wordmark.

- **`paths: { "pages": "/:slug" }` in `collections.json`, and the home entry's
  residual gap is documented rather than worked around.** `entryPagePath` takes
  one template per collection, so `home` resolves to `/home` — a URL this site
  does not serve, since `[...slug].astro` skips `home` and `index.astro` serves
  it at `/`. A home ENTRY edit is therefore verified with the contract's own
  shell override, `/?cms-preview=1&as=pages/home`, which makes `matchTarget`
  select by key rather than by path. Settings and nav changes are unaffected —
  they resolve as `mode: 'site'` at `SITE_ROOT_PATH` (`/`) already. Worth
  raising upstream as a per-entry path override; not worth restructuring this
  site's routes for.

## Implementation

### 1. Declare where the `pages` collection appears

**File**: `src/data/collections.json`

Add a sibling `paths` key to the existing `{ "collections": [] }`:

```json
{
  "collections": [],
  "paths": { "pages": "/:slug" }
}
```

`readCollectionsRegistry()` passes this through untouched, and
`serializeRegistry` explicitly preserves `paths` as site-authored config the
admin never edits, so a later collection edit from `/admin` will not drop it.
Without this key nothing else in this plan is observable.

### 2. Accept an entry key on the layout

**File**: `src/layouts/BaseLayout.astro`

Add `entryKey?: string` to `Props` (documented as the `<collection>/<slug>`
identity of the entry this page renders), and spread the entry marker onto the
existing `div.page`:

```astro
<div class="page" {...(entryKey ? { [CMS_ENTRY_ATTR]: entryKey } : {})}>
```

Omitting the prop must emit no attribute at all, so `404.astro` (which does not
use this layout anyway) and every `src/pages/isolated-components/*.astro` page
are byte-identical to today.

### 3. Pass the entry key from both page templates

**File**: `src/pages/index.astro`

Pass `entryKey={`pages/${home.id}`}` to `BaseLayout`. `home.id` is `home`, so
the marker reads `pages/home` — the same key `targetKey()` builds.

**File**: `src/pages/[...slug].astro`

Pass `entryKey={`pages/${page.id}`}` to `BaseLayout`.

### 4. Mark the home page's fields

**File**: `src/components/home/Masthead.astro`

`h1.wordmark` → `CMS_FIELD_ATTR: 'title'`; `p.kicker` → `CMS_FIELD_ATTR:
'kicker'`. The kicker is conditional today and stays conditional — a field the
page does not render is a field the preview leaves alone.

**File**: `src/components/home/StatementBlock.astro`

`h2` → `CMS_FIELD_ATTR: 'heading'`; `p.lead` → `CMS_FIELD_ATTR: 'lead'`;
`div.statement__body` (the wrapper holding `<slot />`, which is the rendered
markdown) → `CMS_BODY_ATTR`. The body marker is valueless, so spread it as
`{...{ [CMS_BODY_ATTR]: '' }}` — Astro emits `data-cms-body=""`, which the
`[data-cms-body]` selector matches.

**File**: `src/components/home/QuoteBand.astro`

`blockquote` → `CMS_FIELD_ATTR: 'quote'`; `p.attribution` → `CMS_FIELD_ATTR:
'quoteAttribution'` (the frontmatter key, not the `attribution` prop name).

### 5. Mark the internal page's fields

**File**: `src/components/page/PageHeader.astro`

`p.kicker` → `'kicker'`; `h1` → `'title'`; `p.intro` → `'intro'`.

**File**: `src/components/page/ProseColumns.astro`

`div.prose` → `CMS_BODY_ATTR`. Mark `div.prose`, not `div.prose-grid`: the grid
also holds `BranchingTree`, and `patchByMarkers` sets `bodyEl.innerHTML`, which
would delete the structure SVG.

**File**: `src/components/page/ExploratoryBand.astro`

`h2` → `'heading'`; the `<p>` beside it → `'bandBody'`.

**File**: `src/components/page/BandQuote.astro`

`p.quote` → `'quote'`; `p.attribution` → `'quoteAttribution'`.

### 6. Mark the nav

**File**: `src/components/chrome/SiteNav.astro`

Each menu `<li>` → `CMS_NAV_ITEM_ATTR: item.url`. `patchNav` resolves the marked
element's link itself (`item.matches('a') ? item : item.querySelector('a')`), so
the `<li>` is a valid marker target and is the one that survives a removal —
`plan.removed` calls `.remove()` on the marked element, and marking the `<a>`
would leave an empty bullet behind.

The brand `<a>`'s inner `<span>{siteTitle}</span>` → `CMS_SETTING_ATTR:
'siteTitle'`. On the anchor it would erase the `Mark` SVG.

### 7. Mark the footer

**File**: `src/components/chrome/SiteFooter.astro`

`<span>{text}</span>` → `CMS_SETTING_ATTR: 'footerText'`. The Contact `<a>` →
`CMS_SETTING_HREF_ATTR: 'contactEmail'`.

### Explicitly out of scope

- `src/components/home/ActionCard.astro` and `ActionCards.astro` — per-row
  values from the `cards` array, unmarkable and unpreviewable by design.
- `showContactButton` (a boolean; `fieldText` would render the string `"true"`
  into the page) and `description` (SEO only, not rendered as visible text).
- `CMS_LIST_ATTR` / `CMS_LIST_SORT_ATTR` / `CMS_LIST_EMPTY_ATTR` — this site has
  no collection listing page, and `settings.socials` is empty and unrendered.
- `src/pages/404.astro` — does not use `BaseLayout` and renders no entry.
- No markup is restructured, and no styles change. The only rendered-output
  difference anywhere is the attributes themselves.

## Reused existing code

**Existing-implementation survey.** Grepped `src/` for `data-cms`, `cms-preview`
and every one of the six constant names before writing this: **nothing
equivalent exists today** — no marker, no local copy of the attribute strings,
no preview wiring of any kind. `src/data/collections.json` is
`{ "collections": [] }` with no `paths` key, and the CMS's entryPagePath
fallback (`/<collection>/<slug>`) is what currently applies. The site script is
injected by the integration itself, so no `astro.config.mjs` change is needed.

- `CMS_ENTRY_ATTR`, `CMS_FIELD_ATTR`, `CMS_BODY_ATTR`, `CMS_NAV_ITEM_ATTR`,
  `CMS_SETTING_ATTR`, `CMS_SETTING_HREF_ATTR` from
  `node_modules/@codeyam/cms/src/lib/stagedPreview.ts` — imported through the
  package's export map (`"./lib/*": "./src/lib/*.ts"`), so the import specifier
  the templates write is @codeyam/cms/lib/stagedPreview.
- `buildMailto` from `src/lib/mailto.ts` (glossary entry: `buildMailto`) — used
  unchanged by `src/layouts/BaseLayout.astro` and the internal-page template. It
  is byte-identical to the CMS's own copy in
  `node_modules/@codeyam/cms/src/lib/mailto.ts`, which
  `node_modules/@codeyam/cms/src/lib/stagedPreviewSettings.ts` calls when
  rebuilding a settings-derived href, so the previewed contact href and the
  built one agree exactly. Do not "consolidate" the two.
- `getSettings` and `getNav` from `src/lib/site.ts` (glossary entries:
  `getSettings`, `getNav`) — already supply `footerText`, `contactEmail`,
  `siteTitle` and the menu items the markers name. No reader changes.
- `routableEntries` from `node_modules/@codeyam/cms/src/content-helpers.ts`
  (imported through the @codeyam/cms/content export), used by the
  internal-page template's
  `getStaticPaths` — the entry id it yields is the slug half of the entry key,
  so the marker value needs no new derivation.

## Scenarios to Demonstrate

- **Footer text edit, exact.** Stage a `footerText` change in `/admin`, open
  `/?cms-preview=1`. The footer meta line shows the staged text; the banner
  carries no approximation note.
- **Contact address edit, href only.** Stage a `contactEmail` change. The
  Contact link's `href` becomes the rebuilt `mailto:`, and its visible label
  still reads "Contact" — the case `CMS_SETTING_HREF_ATTR` exists for.
- **Site title edit.** Stage a `siteTitle` change, open `/about?cms-preview=1`.
  The nav wordmark updates and the `Mark` SVG beside it is still there.
- **Menu item renamed and reordered.** Stage a `nav.json` change; the marked
  `<li>`s update in place, keyed by url rather than position.
- **Internal page entry edit, exact.** Stage a `kicker` + `intro` + body change
  on `about`, open `/about?cms-preview=1`. Kicker, standfirst and the two prose
  columns all update; the branching structure between the columns survives; the
  banner shows the entry label with no "matched by shape".
- **Home entry edit via the shell override.** Stage a `heading` + `lead` change
  on `home`, open `/?cms-preview=1&as=pages/home`. Statement heading and closing
  line update, the action cards are untouched.
- **Regression — the fallback this replaces.** Same home edit at
  `/?cms-preview=1` on the pre-change markup: the first `ActionCard` is the only
  `<article>`, so its body is overwritten with the page markdown and the banner
  admits the approximation. After the change, the marked path is taken instead.
- **Nothing staged.** Open any page with `?cms-preview=1` and an empty staging
  set: the page renders normally and the banner says nothing is staged.
- **Ordinary visit unchanged.** Load `/` and `/about` with no query flag —
  identical pixels to today; the only DOM difference is the inert attributes.
- **Isolated component captures unchanged.** `/isolated-components/QuoteBand`
  and `/isolated-components/SiteFooter` still render correctly with no entry
  root above them.

Verify with `npm run check` (which runs `astro check`) and `npm test`, then the
manual pass above in `/admin` → preview.