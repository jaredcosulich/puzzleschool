---
title: "Upgrade Astro 6 to 7"
mode: ui
createdAt: "2026-08-18T00:12:25Z"
source: manual
dependsOn: ["upgrade-astro-5-to-6"]
---

## Summary

The second half of the move off the Astro security alerts. With Astro 6 landed,
three alerts remain open — #122 (moderate, XSS via unescaped spread attribute
names, patched 7.0.6), #121 (low, XSS via unescaped `transition:*` directive
values, patched 7.0.4) and #120 (moderate, reflected XSS via unescaped View
Transition animation properties, patched 7.1.0). All three need 7.x, so this
plan takes the repo to latest 7 (7.2.2 today) and closes the set.

The v7 surface is smaller in count than v6's but heavier in kind. Two of its
changes rewrite machinery this whole site is built on: the **Rust compiler is
now the default**, and it errors on unclosed tags and no longer auto-corrects
semantically invalid HTML — against 60 `.astro` files, 35 of which hand-write a
full `<html>` document; and **markdown moves from remark/rehype to Sätteri**,
which is how every page body on this site becomes HTML. A third, `compressHTML`
defaulting to `'jsx'` instead of `true`, changes whitespace handling in the
emitted HTML. None of these is hard to fix; all of them are easy to *miss*,
because they degrade rendering rather than failing the build.

## Key Decisions

- **Sätteri parity is the real work, not the version bump.** Page bodies are
  markdown rendered through content collections, and `@codeyam/cms` renders its
  own staged preview with `micromark` + `micromark-extension-gfm`. Today those
  two paths agree closely enough that a staged preview looks like the built
  page. Swapping Astro's engine moves one side of that comparison. Decide
  deliberately: accept Sätteri and verify parity, or install
  `@astrojs/markdown-remark` to keep the unified pipeline and defer the question.
  The plan's recommendation is **accept Sätteri and verify**, because pinning the
  old engine means carrying a compatibility package indefinitely for a site whose
  markdown is four constructs wide (`h3`, paragraphs, emphasis, links).
- **Audit the compiler surface up front, not at build time.** 35 hand-written
  document pages under `src/pages/isolated-components/` exist to be screenshotted
  in isolation, and they are exactly the files most likely to carry a stray
  unclosed tag that Astro 5 quietly corrected. `npm run build` will name the
  first failure only; a deliberate pass over the 60 files is cheaper than 35
  build-fix-build cycles.
- **Pin `compressHTML: true` only if a diff demands it.** The new `'jsx'` default
  is the better behaviour for a JSX-flavoured template language, and pinning the
  old value to avoid reading a diff is how a codebase accumulates settings nobody
  can justify later. Read the captures first.
- **Same verification model as the v6 plan.** `vitest` does not import `.astro`
  files, so the unit suite cannot see any of this. The codeyam screenshot diff
  across all scenarios is the gate, and markdown-heavy pages (About, with two
  full prose sections) are the ones to read most carefully.

## Prerequisite

`@codeyam/cms` must declare Astro 7 in its peer range. If the release made for
the v6 plan already declares `^6 || ^7`, this is satisfied and nothing further
is needed — that is why the v6 plan asks for the wider range up front.

Beyond the peer range, one CMS-side question belongs to this plan rather than
that one: whether the CMS's `micromark`-rendered staged preview should be
reconciled with Sätteri's output, or whether the small divergences are
acceptable. That is a judgement to make once the two can be compared side by
side, which is only possible after the upgrade.

## Implementation

### 1. Bump to Astro 7

**File**: `package.json`

**File**: `package-lock.json`

Run `npx @astrojs/upgrade` again, targeting latest 7.x (must be ≥ 7.1.0 to close
#120, which is the last of the three). It will carry `@astrojs/react`,
`@astrojs/sitemap` and `@astrojs/check` along with it.

Then check `astro.config.mjs` for an `experimental` block: v7 stabilised
`logger`, `queuedRendering`, `rustCompiler`, `advancedRouting` and `cache`, and
leaving any of them under `experimental` is now an error. The config has no
`experimental` block today, so this should be a no-op — confirm after the bump,
since the v6 upgrade may have introduced one.

### 2. Audit all 60 `.astro` files against the Rust compiler

**File**: `src/pages/isolated-components/` (35 hand-written document pages)

**File**: `src/components/` (the shared components and structures)

The new default compiler errors on unclosed tags and stops auto-correcting
semantically invalid HTML. A first pass found no bare void elements
(`<br>`, `<hr>`, unclosed `<img>`), which is the most common source — so the
expected failure mode here is nesting rather than closing: a block element
inside a `<p>`, or a `<div>` somewhere the HTML spec does not allow one.

Work it as one deliberate pass over the tree, then let `npm run build` confirm.
Fix by correcting the markup, not by reverting to the old compiler — the
compiler is the default now and the escape hatch will not outlive this major.

### 3. Decide and verify the markdown engine

**File**: `astro.config.mjs`

**File**: `src/content/pages/about.md`

**File**: `src/content/pages/contact.md`

**File**: `src/content/pages/home.md`

Take the recommended path: accept Sätteri, add nothing, and diff the rendered
prose. The repo configures no remark or rehype plugins, so nothing needs porting
— the risk is entirely in output differences on the four constructs these bodies
actually use.

Check specifically, against the built HTML:

- `h3` section headings — element, generated `id`, and surrounding whitespace.
  `proseLayoutFor` counts `depth === 3` headings out of `render()`'s `headings`
  to choose the page's layout, so a change in how headings are reported would
  silently flip About to the one-section shape.
- Paragraph splitting and the `—`/`’`/`“` typographic characters already present
  in `about.md` and `contact.md`.
- The literal `contact@puzzleschool.org` in `contact.md`, which must keep
  rendering as text and not become an autolink.

If the diff is unacceptable, fall back to `npm i @astrojs/markdown-remark` and
wire it in `astro.config.mjs`, and record why in the config comment.

### 4. Re-check staged-preview parity

**File**: `src/components/page/ProseColumns.astro`

The CMS patches `.prose`'s `innerHTML` with its own `micromark` output while
staged preview is on; the built page renders the same markdown through Astro.
After step 3, edit a body in `/admin` and compare the staged preview against the
built page for the same content. Divergence here is not a build failure — it is
an editor seeing one thing and shipping another, which is worse.

Record the outcome in the plan's follow-up notes even if it is "no visible
difference"; that is the answer the CMS-side question needs.

### 5. Bring the linked-CMS dev plugin onto Vite 8

**File**: `astro.config.mjs`

v7 moves to Vite 8. `liveLinkedCms()` was already brought onto Vite 7 in the
previous plan, so this is a re-verification rather than a rewrite: exercise
`npm run dev:cms`, edit a file in the linked checkout, confirm the edit lands in
one save and the `/admin` EntryEditor island still takes keystrokes. Dev-mode
only — it cannot affect the deployed site.

### 6. Read the whitespace diff and settle `compressHTML`

**File**: `astro.config.mjs`

`compressHTML` now defaults to `'jsx'` rather than `true`, stripping whitespace by
JSX rules. On a site this typography-driven the visible risk is a lost or gained
space between inline elements. Read the scenario captures; if something moved,
either fix the template or pin `compressHTML: true` with a comment saying which
diff justified it.

### 7. Recapture and confirm the alerts closed

Run the full capture pass and read every diff — this upgrade changes the
compiler, the markdown engine and the HTML compressor at once, so expect churn
and treat each one as signal.

Then re-run `gh api repos/jaredcosulich/puzzleschool/dependabot/alerts` after the
deploy. Expect #120, #121 and #122 to close, taking the Astro set to zero. If
#116 (esbuild, dev-server file read on Windows) is still open, decide it here:
either astro 7 resolves esbuild ≥ 0.28.1 and it closes for free, or it is worth
a one-line `overrides` entry now that nothing else is in flight.

## Reused existing code

- `proseLayoutFor` and `sectionCount` from `src/lib/proseLayout.ts` (glossary
  entries: `proseLayoutFor`, `sectionCount`) — the only code on the site that
  reads a value derived from markdown *structure* rather than markdown output,
  which makes their existing tests in `src/lib/proseLayout.test.ts` the one
  automated check that a markdown-engine swap keeps its contract.
- `ProseColumns` from `src/components/page/ProseColumns.astro` (glossary entry:
  `ProseColumns`) — the `.prose` element is both the markdown render target and
  the CMS's staged-preview patch target, so it is where a Sätteri divergence
  becomes visible.
- `cmsBody` and `cmsField` from `src/lib/cmsMarkers.ts` (glossary entries:
  `cmsBody`, `cmsField`) — the marker attributes staged preview patches against.
  Unchanged by the upgrade, but they are the reason step 4 is a real check
  rather than a formality.
- The unit suites under `src/lib/` — `src/lib/structures.test.ts`,
  `src/lib/harmonograph.test.ts`, `src/lib/voronoi.test.ts`,
  `src/lib/proseLayout.test.ts`, `src/lib/site.test.ts` — all pure TypeScript,
  all unaffected by the Astro majors, and all worth running as the cheap first
  signal that the toolchain still resolves.

**Existing-implementation survey.** Grepped before writing. There is no
`@astrojs/db` dependency, no `src/fetch.ts` (the newly-reserved filename), no
`astro:transitions` usage anywhere in `src/`, no `getContainerRenderer()` or
Container API usage in `src/` or `vitest.config.ts`, and no `experimental` block
in `astro.config.mjs` — so four of v7's breaking changes are inapplicable here.
No remark or rehype plugin is configured, so the Sätteri migration has nothing
to port; the exposure is output parity only. The `.astro` inventory is 60 files,
35 of which contain `<html>`.

## Scenarios to Demonstrate

- **About at full design** — two full prose sections, the most markdown-dense
  page on the site and the best read on Sätteri's output.
- **Contact (one section) and the blank page** — the layouts chosen by counting
  `h3` headings, which is where a change in how headings are reported would show
  up as the wrong layout rather than as wrong text.
- **Home at full design** — the statement block, card grid and quote band, none
  of which come from markdown, as the control for compiler and `compressHTML`
  changes independent of the markdown swap.
- **All 35 isolated-component pages** — the hand-written documents, which after
  step 2 double as the proof that the Rust compiler accepts every one of them.
- **/admin with staged preview on** — the parity check from step 4, comparing an
  edited body's preview against the same body built.
- **Narrow viewport (mobile) home** — whitespace and inline spacing under the
  new `compressHTML` default, where a lost space between inline elements is most
  legible.