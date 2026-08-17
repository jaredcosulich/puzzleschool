---
title: "Restore Content Form After CMS Block-Scalar Fix"
mode: ui
createdAt: "2026-08-17T10:37:34Z"
source: manual
---

## Summary

`@codeyam/cms@0.7.0`'s `parseEntry` has no support for YAML block scalars
(`>-`, `>`, `|`, `|-`). Because this repo's page entries were hand-authored with
folded scalars for their long fields, every CMS code path that reads them —
staged preview and the admin's save path — sees corrupted data. We are landing a
temporary workaround now: normalizing `src/content/pages/*.md` frontmatter to the
CMS's canonical single-line serialization so `parseEntry` round-trips it
losslessly. This plan is the follow-up to run **once a fixed `@codeyam/cms` is
published**: confirm the upstream fix, bump the dependency, decide whether to
keep the normalized frontmatter or restore readable block scalars, and leave a
regression guard behind so a future CMS version that reintroduces the bug is
caught here rather than in production content.

The defect, precisely. `parseEntry` walks the frontmatter line by line and treats
any non-empty text after the first `:` as the value. On `intro: >-` that value is
the literal string `">-"`, and the folded continuation lines beneath it are then
re-read as top-level lines — so one containing a colon becomes a bogus key.
Parsing `src/content/pages/about.md` today yields `intro`, `bandBody` and `quote`
all equal to `">-"`, plus a synthesized key
`"about everything else. We are building the other half": "thirteen years of"`.
`src/content/pages/home.md` loses `quote` the same way.

It is not merely a display bug. `serializeEntry(parseEntry(raw))` is not an
identity: it emits `intro: ">-"` and the three field bodies are gone.
`EntryEditor.tsx:131` builds the saved content with exactly that call, so saving
any entry containing a block scalar from `/admin` writes the mangled version back
to disk. The published site is unaffected throughout, because Astro's own content
loader parses the YAML correctly — which is precisely why this stayed invisible.

It surfaced while adding staged-preview markers to the site templates. Before the
markers, internal pages had no `<article>` or `<main>`, so `applyStagedContent`
returned `fidelity: 'none'` and patched nothing; the bad values were parsed but
never displayed. With the markers in place the patch lands and the standfirst
renders the literal `>-`.

## Key Decisions

- **This plan is gated on an upstream release, and the gate is a test rather
  than a changelog.** The `## Reproduction Test` below asserts that `parseEntry`
  handles a folded scalar. It is RED against 0.7.0 and turns green only when a
  fixed version is installed, so running it is the check for "has the fix
  shipped yet?". Do not start the rest of this plan until it goes green with the
  dependency bumped.

- **Default to KEEPING the normalized single-line frontmatter, even after the
  fix.** The tempting move once both parsers agree is to restore the readable
  folded scalars. Resist it unless the upstream fix also taught `serializeEntry`
  to *emit* block scalars, because of the failure mode commit `1bd3a70f` already
  fixed for the site singletons: the CMS's drift check compares its staged
  baseline (which is `serializeEntry` output) against the raw file on the branch.
  A file that is not a fixed point of `serializeEntry` is never byte-equal to its
  own baseline, so every publish reports a phantom "changed on the site since you
  started editing it" conflict. Restoring block scalars against a serializer that
  emits single-line values would reintroduce exactly that bug for page entries —
  trading a parse defect for a publish defect. Only restore them if round-tripping
  the restored file through `parseEntry` → `serializeEntry` is verified to be an
  identity.

- **The regression guard lives in this repo, not just upstream.** Even after the
  CMS is fixed, this repo's content is the thing that gets damaged when it
  regresses. A test here that round-trips the real `src/content/pages/*.md` files
  through the CMS's own parser and serializer is cheap, reads as a contract
  against the dependency, and fails loudly on a bad version bump.

- **Guard the real content files, not a synthetic fixture.** The bug only bit
  because the actual entries used a construct the parser did not cover. A guard
  over a hand-written fixture would have passed while `about.md` was broken.
  Globbing the real entries means any future entry an author writes is covered
  the moment it lands.

## Implementation

### 1. Confirm the upstream fix is available

**File**: `package.json`

Check the published `@codeyam/cms` versions for one carrying the `parseEntry`
block-scalar fix. Bump the `@codeyam/cms` dependency (currently `^0.7.0`) to it
and reinstall.

Before touching anything else, re-run the two probes that characterized the bug
(they were left in `.codeyam/tmp/` during the original investigation and are
gitignored; recreate them if pruned):

- parse `src/content/pages/about.md` with `parseEntry` and confirm `intro`,
  `bandBody` and `quote` come back as their real prose, with no synthesized
  `"about everything else…"` key
- confirm `serializeEntry(parseEntry(raw))` is byte-identical to `raw` for a file
  that still contains block scalars

If either still fails, stop — the fix has not shipped and the rest of this plan
does not apply yet.

### 2. Decide the frontmatter form

**File**: `src/content/pages/about.md`

**File**: `src/content/pages/home.md`

Apply the second Key Decision. Keep the normalized single-line frontmatter
unless the upstream fix also made `serializeEntry` emit block scalars for long
values. If it did, restoring the folded form is safe and more readable — but only
after verifying that each restored file round-trips through `parseEntry` →
`serializeEntry` unchanged, so it stays a fixed point of the serializer and the
publish drift check stays quiet.

Whichever way this lands, record the reason in the commit message. The next
person to open these files will wonder why the frontmatter looks the way it does.

### 3. Add the regression guard

**New file**: `src/lib/cmsFrontmatterRoundTrip.test.ts`

A vitest suite that, for every file matched by `src/content/pages/*.md`:

- parses it with the CMS's `parseEntry` and asserts no key or value is the bare
  block-scalar indicator (`>-`, `>`, `|`, `|-`) — the signature of the 0.7.0 bug
- asserts every key in the parsed frontmatter is a known field name from
  `src/data/collections.json`, which catches the synthesized-key half of the
  defect
- asserts `serializeEntry(parseEntry(raw))` equals `raw`, pinning each entry as a
  fixed point of the serializer and so guarding the publish drift check

Read the files from disk with `fs` and resolve their directory the way
`src/lib/contentRoot.ts` already does, rather than hardcoding a path.

### 4. Remove the workaround note

**File**: `src/content/pages/about.md`

If the workaround left an explanatory comment or note in the content or nearby
docs pointing at this plan, remove it once the guard is in place — the test now
carries the constraint, so a stale comment claiming a workaround is active would
be misleading.

## Reused existing code

- `parseEntry` and `serializeEntry` from
  `node_modules/@codeyam/cms/src/lib/frontmatter.ts` — the exact functions under
  test. The guard imports them through the package's export map
  (`"./lib/*": "./src/lib/*.ts"`), the same seam
  `src/layouts/BaseLayout.astro` already uses for the staged-preview attribute
  names.
- `resolveContentRoot` from `src/lib/contentRoot.ts`, already covered by
  `src/lib/contentRoot.test.ts` — use it to locate the entries directory instead
  of hardcoding `src/content/pages`.
- `src/data/collections.json` — the field descriptors it declares for the pages
  collection are the authoritative list of valid field names, so the guard's "no
  synthesized keys" assertion reads from it rather than duplicating a list.
- Existing vitest setup — `npm test` runs `vitest run`, and
  `src/lib/contentRoot.test.ts` is the nearest example of a suite that touches
  the filesystem.
- No existing test covers CMS frontmatter parsing in this repo today; this is
  genuinely new coverage, not a duplicate.

## Reproduction Test

Pins the `@codeyam/cms` parser defect that makes a folded YAML scalar parse as
the literal block indicator instead of its content.

**Target**: `src/lib/cmsFrontmatterRoundTrip.test.ts` — run with
`codeyam-editor editor refresh-tests --test cmsFrontmatterRoundTrip`.

```ts
// parseEntry reads a folded block scalar as its content, not the ">-" indicator
it('parses a folded block scalar into its folded text', () => {
  const raw = ['---', 'intro: >-', '  first line', '  second line', '---', '', 'body'].join('\n');
  expect(parseEntry(raw).data.intro).toBe('first line second line');
});
```

Status: PROPOSED — confirm red at execution. Against `@codeyam/cms@0.7.0` this
fails with `parseEntry(raw).data.intro` equal to `">-"` rather than
`"first line second line"`. Unlike an ordinary reproduction test, it does not go
green by editing this repo — it goes green only when a fixed `@codeyam/cms` is
installed, which is what makes it this plan's readiness gate.

## Scenarios to Demonstrate

- **The gate, before the fix.** On `@codeyam/cms@0.7.0`, the reproduction test is
  red and reports `">-"` — the signal that this plan is not yet actionable.
- **The gate, after the bump.** With the fixed version installed, the same test
  passes untouched.
- **Round-trip over the real entries.** The guard parses and re-serializes every
  `src/content/pages/*.md` and gets each file back byte-for-byte.
- **A regression is caught.** Pinning the dependency back to `0.7.0` turns the
  guard red on `about.md`, proving it actually watches the dependency rather than
  the content.
- **Staged preview of an internal page, exact.** Stage a `kicker` + `intro` +
  body change on `about`, open `/about?cms-preview=1`. All three update, the
  standfirst shows real prose rather than `>-`, the branching structure between
  the prose columns survives, and the banner carries no approximation note.
- **Staged preview of the home quote.** Stage a `quote` change on `home` and
  view it via `/?cms-preview=1&as=pages/home`; the pull quote shows the staged
  text rather than `>-`.
- **Admin save preserves content.** Edit one field of `about` in `/admin` and
  publish; the other long fields are unchanged on disk — the data-loss path is
  closed.
- **Publish reports no phantom drift.** Editing and publishing a page entry does
  not raise "has changed on the site since you started editing it", confirming
  the entries are fixed points of the serializer.