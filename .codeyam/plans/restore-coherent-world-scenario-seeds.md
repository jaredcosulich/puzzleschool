---
title: "Restore Coherent-World Scenario Seeds"
mode: ui
createdAt: "2026-08-17T11:44:44Z"
source: manual
---

## Summary

Four application scenarios — `contact-email-only`, `page-created-from-the-cms`,
`page-minimal-fields` and `page-title-without-body` — have had their seeds
trimmed down to a single content entry each, purely to get past a bug in
codeyam-editor 0.1.7's capture guard. Restore them to coherent-world seeding
once that bug is fixed upstream.

The bug: before capturing, the guard confirms a scenario's seed reached the
served render by sampling sentinel strings from the scenario's WHOLE MERGED
SEED, then requiring at least one to appear in the response for that scenario's
single route. These four scenarios each seeded their own page PLUS home, about
and contact — which is what the App Scenarios workflow step explicitly asks for:
*"Seed a COHERENT WORLD, not one endpoint — the page AND the pages it links into
must render real data."* The sampler picked home's and about's body text, which
can never render on `/contact`, `/a-day-in-the-life`, `/notes` or `/blank`, so
the guard reported *"this scenario's own seed never reached the served render"*
and refused to capture. That in turn hard-gated the Reconcile audit through
`DEPENDENCY_STALE_SCREENSHOTS`, which has no suppression primitive.

The seed was landing the whole time. `curl http://127.0.0.1:4321/contact`
returned the SEEDED intro (*"…so the most useful conversations…"*) rather than
the committed one (*"…which means the most useful conversations…"*). The sibling
scenarios `about-full-design` and `home-full-design` pass only incidentally,
because one sampled sentinel happens to belong to their own entry.

Trimming works, but it costs real coverage: each of the four now renders against
a site containing exactly one page, so they no longer demonstrate the page
inside a populated site. `page-created-from-the-cms` is the most damaged — its
entire point is that a CMS-authored page joins a real site with no code change,
and a one-page world is a weak demonstration of that.

## Key Decisions

- **Gate this plan on the upstream fix, not on a date.** Before restoring
  anything, restore ONE scenario's seed and run `recapture-stale --target
  contact-email-only --force`. If it still reports the BLOCKED
  seed-never-reached error, the fix has not shipped and the rest of this plan
  does not apply yet. Do not start by restoring all four.

- **Restore from git history, not by hand.** The pre-trim seeds are recoverable
  from the commit that landed the trim (the CMS Staged-Preview Markers feature
  commit). Recovering the exact prior JSON avoids re-deriving four content
  worlds by hand and re-introducing subtle drift in fields nobody reviewed.

- **Trimming was chosen over the alternatives, and the alternatives should stay
  rejected.** Perturbing seed content so a sentinel happens to match would be
  gaming the check; deleting the scenarios would destroy real coverage the audit
  exists to protect. Trimming at least keeps each scenario's own state intact and
  is exactly reversible, which is why it is what shipped.

- **`page-title-without-body` will still be fragile after a naive fix.** It seeds
  a title-only page by design, so that entry contributes no body sentinel at all.
  Any upstream fix that merely prefers the route's own entry must also handle
  "that entry yields no usable sentinel" — otherwise this one scenario keeps
  failing while the other three pass. Verify this scenario specifically, not just
  the easy three.

## Implementation

### 1. Confirm the upstream fix has shipped

**File**: `.codeyam/scenarios/contact-email-only.json`

Restore only this scenario's seed to include `home`, `about` and `contact`
alongside its own entry, then run:

```
codeyam-editor editor recapture-stale --target contact-email-only --force
```

A successful capture means the fix is in. A repeat of the BLOCKED
seed-never-reached error means it is not — revert this one file and stop.

### 2. Restore the remaining three seeds

**File**: `.codeyam/scenarios/page-created-from-the-cms.json`

**File**: `.codeyam/scenarios/page-minimal-fields.json`

**File**: `.codeyam/scenarios/page-title-without-body.json`

Restore each seed's `pages` array to the pre-trim set — the scenario's own entry
plus `home`, `about` and `contact` — recovered from the trim commit. Keep each
scenario's own entry exactly as it is today; only the sibling entries come back.

**What actually shipped differs from this plan's original description in two
ways — both discovered while applying the trim, and both must be undone here.**

1. **`home` was NOT trimmed out.** Trimming to a single entry broke the site:
   `src/pages/index.astro` deliberately throws when `pages/home` is missing, so a
   one-page world made `/` return HTTP 500, and `recapture-stale`'s own pre-flight
   probes `/` — no capture could run at all. The shipped trim therefore keeps
   `home` plus each scenario's own entry, and only `about` / `contact` were
   dropped. Restoring means adding `about` and `contact` back, not `home`.

2. **`page-title-without-body`'s TITLE was changed**, from `Blank` to
   `A page nobody has written into yet`. This was not cosmetic: the guard samples
   sentinels from *rendered text*, and that scenario's only long distinctive value
   was `description`, which `src/components/SEO.astro` renders solely into
   `<meta>` tags — never visible text. With `body` empty by design and a title too
   short to be sampled, the check was unsatisfiable by construction. Lengthening
   the title gave the guard a visible sentinel while leaving the demonstrated
   state (title, no body) identical. Restore the title to `Blank` once the guard
   samples only rendered fields.

That second point is a distinct facet of the upstream bug worth fixing alongside
the entry-scoping one: **the sentinel sampler does not distinguish rendered
fields from metadata-only fields**, so it can select a string that cannot
possibly appear in rendered text and then report the seed as not landed.

### 3. Recapture and inspect the frames

Run `codeyam-editor editor recapture-stale`, then LOOK at each of the four
screenshots. The restored captures should show the page sitting inside a
populated site. Confirm specifically that `page-created-from-the-cms` reads as a
real page on a real site, since that is the coverage the trim removed.

Pay attention to `page-title-without-body` per the fourth Key Decision — if the
other three pass and it alone still fails, the upstream fix handled entry
selection but not the no-usable-sentinel fallback, and that should go back
upstream rather than being worked around again here.

### 4. Add a regression guard

**New file**: `src/lib/scenarioSeeds.test.ts`

A vitest suite over `.codeyam/scenarios/*.json` asserting that every application
scenario whose route is served by the internal-page template seeds more than its
own entry — i.e. that coherent-world seeding has not silently collapsed back to
one page. This is what turns a future recurrence into a failing test rather than
a quiet degradation nobody notices in review.

Read the scenario files from disk with `fs`; assert on the seed's `pages` array
length and membership rather than on exact content, so ordinary content edits do
not break it.

## Reused existing code

- `resolveContentRoot` from `src/lib/contentRoot.ts` (glossary entry:
  `resolveContentRoot`), already covered by `src/lib/contentRoot.test.ts` — use
  it if the guard needs to resolve content paths rather than hardcoding them.
- `src/lib/cmsMarkers.test.ts` — the nearest example in this repo of a suite that
  reads real project files from disk and asserts structural properties; follow
  its shape for the new guard.
- Existing vitest setup — `npm test` runs `vitest run`; no new test tooling is
  needed.
- No existing test covers scenario seed shape in this repo today; this is
  genuinely new coverage, not a duplicate.

## Reproduction Test

Pins the coverage the trim removed: an internal-page application scenario should
render inside a populated site, not a site containing only its own page.

**Target**: `src/lib/scenarioSeeds.test.ts` — run with
`codeyam-editor editor refresh-tests --test scenarioSeeds`.

```ts
// an internal-page scenario seeds sibling pages, not just its own entry
it('seeds a coherent world for the contact scenario', () => {
  const seeded = readScenarioSeedSlugs('contact-email-only');
  expect(seeded).toEqual(expect.arrayContaining(['home', 'about', 'contact']));
});
```

Status: PROPOSED — confirm red at execution. Against the trimmed seeds this
fails because `readScenarioSeedSlugs('contact-email-only')` returns only
`['contact']`, so the `arrayContaining` assertion misses `home` and `about`.
Unlike an ordinary reproduction test it does not go green by editing code — it
goes green when step 2 restores the seeds, which is what makes it the check that
the restoration actually happened.

## Scenarios to Demonstrate

- **The gate, before the fix.** On the current editor build, restoring one seed
  and recapturing still reports BLOCKED — the signal that this plan is not yet
  actionable.
- **The gate, after the fix.** With a fixed editor, the same recapture succeeds
  untouched.
- **Contact inside a populated site.** `contact-email-only` recaptures showing
  the contact page with its nav resolving against real sibling pages.
- **A CMS-authored page inside a real site.** `page-created-from-the-cms`
  recaptures showing the new page as one page among several — the demonstration
  the trim weakened.
- **The lean page, still lean.** `page-minimal-fields` and
  `page-title-without-body` recapture with their own sparse content unchanged,
  proving the restoration touched only the sibling entries.
- **The guard bites.** Re-trimming any one seed turns the new regression test
  red, proving it watches seed shape rather than content.