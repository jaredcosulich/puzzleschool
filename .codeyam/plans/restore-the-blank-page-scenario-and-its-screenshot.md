---
title: "Restore the Blank-Page Scenario and Its Screenshot"
mode: ui
createdAt: "2026-08-17T22:22:25Z"
source: manual
---

## Summary

The `page-title-without-body` application scenario — `/blank`, "a page an editor
created but has not written into yet" — was temporarily removed from the project
because its screenshot could not be refreshed. It is the one scenario that proves
the internal-page template survives a page with NO body at all, and under the
one-section layout rule that state is now visually interesting rather than merely
degenerate: an empty body counts as one section, so `/blank` renders as two
generated structures with nothing between them. Restore the scenario and capture a
frame that shows that, once the codeyam-editor defect blocking the capture is
fixed.

This plan is BLOCKED on a tool fix and should not be started until that fix has
shipped. Step 1 of the implementation is a gate that checks for it.

## Key Decisions

- **Restore from git rather than re-author.** Both the scenario definition and its
  screenshot were committed before removal, so the exact curated seed — including
  the deliberately empty `body`, the `title`, and the `home` entry alongside it —
  can be recovered byte-for-byte instead of being reconstructed from memory. The
  removal commit is the only thing that has to be found; `git log --diff-filter=D`
  finds it without needing a SHA recorded here.

- **The old screenshot must NOT be restored as-is.** The committed frame shows the
  page under the previous two-column layout, with the branching tree standing
  alone under the sine rule. That rendering no longer exists. Restoring the JSON
  and the PNG together would put a stale, actively misleading capture back into
  the project — the file has to come back and then be recaptured, and the
  recapture has to be confirmed by eye.

- **The blocking defect is in the tool, not in this project's seed.** The seed
  lands correctly; it was verified against the capture server itself, which served
  `/blank` at HTTP 200 with both seeded strings present in the HTML. The
  seed-landed check searches VISIBLE text for markers derived from the seed, and
  for this scenario every marker is unreachable: three belong to the `home` entry,
  which `/blank` never renders, and the fourth is `blank.description`, which Astro
  emits into `<meta name="description">`. The only seeded string `/blank` renders
  visibly is its `title`, and titles are not in the marker list. So the fix has to
  come from codeyam-editor — do NOT "fix" it here by giving the page body text,
  which would delete the very state the scenario exists to demonstrate.

- **Do not weaken the scenario to make the check pass.** Adding an `intro`, a
  `kicker`, or a line of body copy to the seeded `blank` entry would satisfy the
  marker search and destroy the point of the scenario in the same edit. If the
  tool fix turns out to be unavailable, the correct outcome is to leave the
  scenario absent and say so, not to ship a diluted one.

- **Removal was safe to do temporarily.** Five other scenarios exercise the same
  route (`src/pages/[...slug].astro`), no glossary entry cites this scenario as a
  satisfier, and `page-minimal-fields` (`/notes`) independently covers the
  one-section flanked layout with real prose. The only coverage genuinely lost is
  the empty-body edge case, which is exactly what this plan restores.

## Implementation

### 1. Confirm the blocking defect is fixed before doing anything else

Do not proceed past this step until the codeyam-editor seed-landed check can be
satisfied by a page whose seeded body is empty. The shipped fix should either
include the seeded entry's `title` among the expected markers, match markers
against the served HTML rather than visible text, or provide a per-scenario way to
declare the string that proves the seed landed.

Verify against the running editor rather than assuming, using the restored
scenario itself as the probe (step 2 first, then this check):

```
codeyam-editor editor recapture-stale --target page-title-without-body --force
```

If it still reports `seed-not-landed`, STOP and report that the tool fix has not
landed. Everything below depends on this.

### 2. Restore the scenario definition from git

**New file**: `.codeyam/scenarios/page-title-without-body.json` (restored, not authored)

Find the commit that removed it and recover the file from its parent:

```
git log --oneline --diff-filter=D -- .codeyam/scenarios/page-title-without-body.json
git show <removal-sha>^:.codeyam/scenarios/page-title-without-body.json \
  > .codeyam/scenarios/page-title-without-body.json
```

Do not hand-edit the recovered seed. In particular the `blank` entry's `body` must
stay `""` — that empty string is the scenario.

### 3. Recapture the screenshot and CONFIRM IT BY EYE

**New file**: `.codeyam/scenarios/screenshots/page-title-without-body--desktop.png` (recaptured)

The stale frame must not simply be restored alongside the JSON. Recapture:

```
codeyam-editor editor recapture-stale --target page-title-without-body --force
```

Then open the resulting PNG and confirm it shows the CURRENT rendering, not the
old one. The frame is correct when it shows the page title, the morse rule and the
sine rule, and then a harmonograph in a lane at the left and a Voronoi field in a
lane at the right with nothing between them — an empty page framed by two
structures that are themselves unfinished. If it instead shows a single branching
tree centred under the sine rule, the capture is the stale committed frame and the
recapture did not take.

Note the Astro content-layer rescan race while working here: the first request
after a seed write serves the pre-seed content index and 404s, and the next
succeeds. A capture that fails once immediately after a scenario switch is worth
retrying once before being treated as a real failure.

### 4. Re-verify project coverage

Confirm the restored scenario is registered, captured, and clean:

```
codeyam-editor editor scenarios --slug page-title-without-body
codeyam-editor editor audit --format json
```

The audit should report no new findings attributable to this scenario.

## Reused existing code

- `proseLayoutFor` from `src/lib/proseLayout.ts` (glossary entry: `proseLayoutFor`),
  covered by `src/lib/proseLayout.test.ts` — the rule that makes an empty body
  render the flanked shape. Its `treats a body with no sections as one` test is the
  unit-level counterpart of what this scenario shows visually, and it already
  passes; this plan restores the VISUAL evidence, not the logic.
- `ProseColumns` from `src/components/page/ProseColumns.astro` (glossary entry:
  `ProseColumns`) — renders the `single` shape the restored frame must show.
- `Harmonograph` from `src/components/structures/Harmonograph.astro` (glossary
  entry: `Harmonograph`) and `VoronoiField` from
  `src/components/structures/VoronoiField.astro` (glossary entry: `VoronoiField`)
  — the two figures that must both appear in the recaptured frame.
- `src/pages/[...slug].astro` — the route the scenario exercises; five other
  scenarios already cover it, which is what made the temporary removal safe.

**Existing-implementation survey.** Nothing in this project works around the
seed-landed check today, and nothing should: no scenario declares a custom seed
marker, and no seed carries filler text added to satisfy a capture. This plan adds
no config field, no gate dimension and no new mechanism — it restores one JSON file
and one PNG.

## Reproduction Test

No unit-level reproduction is writable in this repository: the defect is in
codeyam-editor's capture-time seed-landed check, not in this project's source, and
the behaviour it breaks is a screenshot capture rather than anything a test in this
tree can observe. The logic that makes `/blank` render the flanked shape is already
pinned by `proseLayoutFor` — its `treats a body with no sections as one` case — and
that test passes today. Demonstrate the fix via the restored scenario
`page-title-without-body` instead, per step 3's by-eye confirmation.

## Scenarios to Demonstrate

- **`/blank`, restored.** An empty page: title, morse rule, sine rule, then a
  harmonograph at the left and a Voronoi field at the right with nothing between
  them. The whole point — a page still being written, framed by two structures
  still being worked out.
- **`/notes` unchanged.** The other one-section page keeps its existing frame, so
  the restoration is visibly scoped to `/blank` alone.
- **`/about` unchanged.** Still two columns with the branching tree, proving the
  restore touched nothing about the two-section shape.