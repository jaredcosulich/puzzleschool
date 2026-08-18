---
title: "Upgrade Astro 5 to 6"
mode: ui
createdAt: "2026-08-18T00:11:18Z"
source: manual
---

## Summary

The repo is on `astro@5.18.2`, which is the newest 5.x that will ever exist —
every fix for the eight open Astro Dependabot alerts landed in 6.x or later, so
there is no patch-in-place available and the only route off them is the major
upgrade. This plan does the first half: Astro 5 → 6. Landing on **6.4.6 or
newer clears five of the eight alerts, including both highs** (#118 host-header
SSRF, #117 slot-name XSS, plus #119, #115, #114); the remaining three need 7.x
and are the follow-up plan's job. None of the eight is exploitable against the
deployed site today — it is `output: 'static'` on GitHub Pages with no adapter,
no SSR route and no server island, so there is no request-time render to inject
into — which is why this is scheduled work rather than an incident.

The v6 surface that actually touches this repo is small and known: the content
config file must move and stop importing `z` from `astro:content`, Zod goes to
4, Vite goes to 7 (which is where the linked-CMS dev plugin in
`astro.config.mjs` is at risk), and Node 22.12+ must be pinned in CI.

**This plan is blocked on a `@codeyam/cms` release that supports Astro 6** —
see the prerequisite section below. Do not start it until that release is
published; the peer range alone is not enough.

## Prerequisite: what @codeyam/cms must ship first

Recorded here because the CMS work is happening in parallel, and these are the
exact things this repo will break on otherwise. Verified against the installed
`@codeyam/cms@0.8.0`:

1. **Peer range widened.** `package.json` currently declares
   `"astro": "^5.2.0"`. Needs `^6` (and ideally `^6 || ^7`, so the follow-up
   plan does not need a second CMS release).
2. **`z` must stop coming from `astro:content`.**
   `node_modules/@codeyam/cms/src/content-helpers.ts:31` does
   `import { z } from 'astro:content'`, and v6 removed that export. It has to
   become `import { z } from 'astro/zod'`. This is a hard build failure, not a
   warning — and it is in the module this repo's content config imports
   `collectionLoader`, `draftField`, `previewFields` and `seoFields` from.
3. **Zod 4 compatibility for the shared field groups.** `draftField`,
   `previewFields` and `seoFields` are spread into this repo's schema, so any
   Zod-3-only idiom in them (`.default()` semantics, top-level string formats)
   surfaces here as a schema error on a page that did not change.
4. **Integration hooks confirmed on v6.** The integration uses
   `astro:config:setup` with `injectRoute` / `injectScript` / `updateConfig` /
   `logger`, all of which survive v6. What was removed is the `routes` param on
   `astro:build:done` and `entryPoints` on `astro:build:ssr` — worth a grep on
   the CMS side before release.
5. **`astro/loaders` `glob` still used by `collectionLoader`** — unchanged in
   v6, but v6 removed the loader *schema function* signature in favour of a
   `createSchema()` property. `collectionLoader` passes a plain schema object
   through, so this should be a no-op; confirm rather than assume.

## Key Decisions

- **One major at a time, two plans.** This is Astro's own upgrade guidance and
  it keeps the blast radii separate: v6 is content collections + Zod 4 + Vite 7,
  while v7 is a new Rust compiler, a new markdown engine and Vite 8. Landing v6
  on its own is independently shippable, clears both high-severity alerts, and
  gives the v7 work a known-good starting point instead of one twelve-variable
  debugging session.
- **Use `npx @astrojs/upgrade` rather than hand-pinning versions.** It resolves
  `astro`, `@astrojs/react`, `@astrojs/sitemap` and `@astrojs/check` as a
  compatible set. Hand-picking majors across four packages is how you end up
  with a peer-dep tree that installs but does not build.
- **Verification is the scenario captures, not the test suite.** `vitest.config.ts`
  deliberately excludes `.astro` files — the unit tests cover pure library code
  (`structures`, `harmonograph`, `voronoi`, `proseLayout`, `site`, `mailto`) and
  will pass whether or not the site renders correctly. Every regression this
  upgrade can cause is a rendering regression, so the codeyam screenshot diff
  across all ~37 scenarios is the actual gate.
- **Expect the captures to churn, and read every diff.** v6 stabilises
  `preserveScriptOrder` (scoped `<style>` blocks now emit in declaration order),
  which can reorder the cascade on a site built almost entirely from scoped
  component styles. A screenshot diff here is signal, not noise.
- **`sharp` (#87, high) is explicitly out of scope.** It is an *optional*
  dependency of astro that this site never invokes — there is no `astro:assets`,
  `<Image>`, `<Picture>` or `getImage()` anywhere in `src/`. It is one line of
  `overrides` and should not be held behind a two-major upgrade. Re-check it
  after the bump anyway: v6 may widen astro's own `sharp` range to `^0.35` and
  close it for free.

## Implementation

### 1. Bump the toolchain

**File**: `package.json`

**File**: `package-lock.json`

Run `npx @astrojs/upgrade` and let it resolve `astro` to latest 6.x (must be
≥ 6.4.6 for the security fixes), along with `@astrojs/react`,
`@astrojs/sitemap` and `@astrojs/check`. Then re-run `npm install` so the
lockfile is the resolver's, not a hand-edit.

Confirm the resolved `astro` version is ≥ 6.4.6 before going further — an
upgrade that lands on 6.2 does the work without collecting the payoff.

### 2. Move the content config to its v6 location

**File**: `src/content/config.ts` → `src/content.config.ts` (new path)

v6 removed the legacy content-collections API entirely and requires the config
at `src/content.config.ts`. This is a pure `git mv` — the collection itself
already uses the modern API (an explicit `loader:` via `collectionLoader`, and
the route already calls the standalone `render()` and reads `page.id` rather
than the removed `entry.render()` / `entry.slug`), so nothing inside the file
changes for this step.

Two references to fix afterwards:

- `src/pages/index.astro:3` — a comment pointing at `src/content/config.ts`.
- `.codeyam/deps-index.txt:47` — carries the old path; regenerates on the next
  codeyam reindex rather than being hand-edited.

### 3. Import `z` from `astro/zod` and check the schema against Zod 4

**File**: `src/content.config.ts` (new)

v6 removed the `z` re-export from `astro:content`, so
`import { defineCollection, z } from 'astro:content'` becomes
`import { defineCollection } from 'astro:content'` plus
`import { z } from 'astro/zod'`.

Then audit the schema for the Zod 4 changes. The locally-declared fields are
`z.string()`, `z.number()`, `z.boolean()`, `z.enum()`, `z.array()`, `z.object()`
and `.optional()` — none of which moved — so the exposure is entirely in the
three spread field groups from `@codeyam/cms/content`, which is why they are
prerequisite item 3.

### 4. Bring the linked-CMS dev plugin onto Vite 7

**File**: `astro.config.mjs`

`liveLinkedCms()` is the most upgrade-fragile code in the repo, because it
reaches into Vite server internals rather than using a public plugin API. Three
things to check against Vite 7:

- **`server.moduleGraph`** (in `bridge()`) — deprecated when Vite 6 introduced
  the Environment API, in favour of `server.environments.client.moduleGraph`.
  If the back-compat shim is gone in 7, the linked-CMS module invalidation
  silently stops working: the watcher still fires and the page still
  full-reloads, so the failure looks like "my edit needs two saves" rather than
  an error. Move to the environment-scoped graph.
- **`server.middlewares` / `server.watcher` / `server.ws.send`** — expected to
  be stable, but exercise them: `npm run dev:cms`, edit a file in the linked
  checkout, confirm one save lands.
- **`optimizeDeps.include` / `exclude` and `resolve.preserveSymlinks`** — the
  `debug` / `micromark` pre-bundling workaround exists because of how Vite's
  scanner reaches the CMS's raw-TS exports. Vite 7's scanner may make it
  unnecessary or may need it adjusted; verify the `/admin` EntryEditor island
  still accepts keystrokes, which is the symptom that workaround fixes.

This is dev-mode-only code — it cannot affect the deployed site — so if it
proves stubborn, ship the upgrade and fix it in a follow-up rather than blocking
the security fixes on it.

### 5. Pin Node 22.12+ in CI

**File**: `.github/workflows/deploy.yml`

v6 requires Node ≥ 22.12.0 and drops 18 and 20. The workflow currently uses
`withastro/action@v3` with `node-version` commented out at line 33, so the build
runs on whatever default that action ships. Uncomment it and pin `node-version: 22`
so a change in the action's default cannot silently drop the build onto an
unsupported runtime. (Local dev is already fine — Node 22.21.1.)

### 6. Re-verify the rendered site and recapture

Run `codeyam-editor editor refresh-tests` and the scenario capture pass, then
read every screenshot diff. Specific things v6 changes that this site can show:

- **Scoped style/script declaration order** — see Key Decisions.
- **Markdown heading IDs keep trailing hyphens** now. Page bodies use `h3`
  section headings; nothing links to those anchors today, so this should be
  invisible, but it will show up in captured HTML.
- **Endpoints with a file extension reject a trailing slash** — the site emits
  `sitemap-index.xml` via `@astrojs/sitemap`. Fetch it both ways after the
  build and confirm the canonical form still resolves.

### 7. Confirm the alerts actually closed

Re-run `gh api repos/jaredcosulich/puzzleschool/dependabot/alerts` after the
merge deploys. Expect #114, #115, #117, #118 and #119 to close. #120, #121 and
#122 will remain — they need 7.x and belong to the follow-up plan. If #116
(esbuild) is still open, check whether astro 6 resolves esbuild ≥ 0.28.1; if
not, note it for the v7 plan rather than forcing an override here.

## Reused existing code

This is a dependency upgrade, so the "reuse" is mostly *not changing* things
that already sit on the modern API:

- `routableEntries` from `@codeyam/cms/content`, used in
  `src/pages/[...slug].astro` — v6-safe as written; the CMS side is prerequisite
  item 2.
- `getCollection` / `getEntry` / `render` from `astro:content` in
  `src/pages/[...slug].astro` and `src/pages/index.astro` — already the v6 shape
  (standalone `render()`, `entry.id`), so no call-site changes.
- `GetStaticPaths` in `src/pages/[...slug].astro` (glossary entry: the internal
  page route) — its `getStaticPaths` returns string `params` and does not touch
  the `Astro` global, so both v6 `getStaticPaths` restrictions are already
  satisfied.
- `proseLayoutFor` and `sectionCount` from `src/lib/proseLayout.ts` (glossary
  entries: `proseLayoutFor`, `sectionCount`) — pure functions over Astro's
  `headings`, unaffected by the upgrade, and their tests are the one part of the
  suite that would catch a `render()` contract change.

**Existing-implementation survey.** Grepped before writing this. The repo's
entire Astro API surface is four import sites: `astro:content` in
`src/content/config.ts`, `src/pages/index.astro` and `src/pages/[...slug].astro`,
plus `import type { GetStaticPaths } from 'astro'`. There is no `Astro.glob()`,
no `<ViewTransitions />`, no `import.meta.env` usage anywhere in `src/`, no
Container API, no `astro:assets`, no `experimental` block in `astro.config.mjs`,
no `.cjs`/`.cts` config, and no server islands or `prerender = false` routes —
so the large majority of the v6 breaking-change list does not apply here. What
does apply is enumerated above.

## Scenarios to Demonstrate

- **Home, About and Contact at full design** — the three real pages, proving
  content collections still load and the markdown bodies still render through
  the same templates.
- **A CMS-created page and a minimal-fields page** — the dynamic `[...slug]`
  route, which is where a `getStaticPaths` or loader regression would surface.
- **The one-section page (Contact) and the blank page** — `proseLayoutFor`
  reading `render()`'s `headings`, the one place this repo depends on the shape
  of an `astro:content` return value.
- **/admin dashboard and the EntryEditor island** — the React island plus the
  `debug`/`micromark` pre-bundling path, under both `npm run dev` and
  `npm run dev:cms`.
- **A linked-CMS edit landing in one save** — the `liveLinkedCms()` plugin on
  Vite 7, which no capture can prove and has to be exercised by hand.
- **Narrow viewport (mobile) home** — the responsive shape, as the control that
  the style-order stabilisation did not reorder the cascade.