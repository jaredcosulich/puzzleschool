---
title: "Recapture SVG screenshots after the upstream capture fix"
mode: ui
createdAt: "2026-08-12T18:18:45Z"
source: manual
---

## Summary

22 committed component screenshots on this branch are wrong: every SVG in them
is collapsed onto the origin. The logo captures as a single coral wedge instead
of an eight-piece compass rose, and all six generated line structures capture as
a single stroke. The cause is upstream in codeyam-editor 0.1.7 —
`forceFinalVisualState` injects `* { transform: none !important; opacity: 1
!important }` before every screenshot, and a CSS `transform` overrides the SVG
`transform` presentation attribute, so it erases the rotations that *construct*
the artwork rather than just stopping an entrance animation.

The site itself is correct — markup, build, and the live browser all render
properly. Only the captures lie, which is why nothing caught it: `verify-build`
passes, the audit passes, and the scenario system stores the wrong frame without
a warning.

A local fix was applied and then reverted (`sync-capture-scripts`) so the audit
could pass, on the understanding that the real fix lands upstream. This plan is
the cleanup owed in *this* repo once that ships.

## Key Decisions

- **The fix does not land here.** This is a client repo with no `npm/` source
  tree, so `.codeyam/scenario-playwright.js` is generated and any edit is
  reverted by the next `sync-capture-scripts` or scaffold. The upstream change
  belongs in codeyam-editor's own repo; this plan covers only what this repo
  owes afterwards. Do not re-apply the local patch.
- **Recapture is gated on the binary, not on a date.** Step 1 is a version
  check with a concrete pass/fail probe, so this plan cannot be run early and
  silently re-bake the same broken frames.
- **Verify with a control, not by eye.** A four-rect SVG whose expected output
  is unambiguous (a four-armed cross) distinguishes "transforms applied" from
  "transforms dropped" in one glance; judging the compass rose by eye at
  thumbnail size is what let this survive several captures.
- **The hand-pinned `pageFilePath` stays until the extractor is fixed.** All 25
  component scenarios carry a `pageFilePath` added by hand because the `.astro`
  entity extractor emits only `Props`, never component names, so
  `componentName` could not resolve to a source file and staleness detection was
  inert. That pin is load-bearing right now; remove it only if a later editor
  version resolves Astro components on its own.

## Implementation

### 1. Confirm the upstream fix is present before touching anything

**File**: `.codeyam/scenario-playwright.js`

Read the version banner on line 2. It currently reads `codeyam-editor: 0.1.7`.
Do not proceed while the installed binary is 0.1.7 or the injected stylesheet in
`forceFinalVisualState` still applies `transform: none` to a bare universal
selector — recapturing under either condition reproduces the corruption exactly.

The expected upstream shape keeps animation and transition suppression universal
(those are timing concerns, harmless inside an SVG) and scopes only the two
properties carrying static geometry out of SVG subtrees:

    *, *::before, *::after { animation: none !important; transition: none !important; }
    *:not(svg):not(svg *), *::before, *::after { opacity: 1 !important; transform: none !important; }

### 2. Prove the capture pipeline with a control before trusting it

**New file**: `public/transform-control.html` (temporary — delete after step 3)

A page whose correct output is unambiguous, so the verdict does not depend on
judging artwork:

    <svg width="200" height="200" viewBox="0 0 120 120">
      <rect x="50" y="10" width="20" height="50" fill="#1f7a72"/>
      <rect x="50" y="10" width="20" height="50" fill="#d4562f" transform="rotate(90 60 60)"/>
      <rect x="50" y="10" width="20" height="50" fill="#d9a01e" transform="rotate(180 60 60)"/>
      <g transform="rotate(270 60 60)"><rect x="50" y="10" width="20" height="50" fill="#16211e"/></g>
    </svg>

Capture it. A four-armed cross (teal up, coral right, gold down, ink left) means
transforms survive. A single ink bar means they are still being dropped — stop
and escalate upstream again rather than recapturing.

Note: a new file under `public/` needs a dev-server restart before it is served.

### 3. Recapture the corrupted screenshots

Run `codeyam-editor editor recapture-stale`. If it reports nothing stale (the
component sources will not have changed), force the issue by re-registering the
component scenarios so each is captured fresh.

Then verify the two that fail most visibly, at `Desktop`:

- `/isolated-components/Mark` — must show eight interlocking puzzle pieces:
  teal north/south, coral east/west, gold diagonals. A single coral wedge means
  the fix is not in effect.
- `/isolated-components/BranchingTree` — must show a tapered branching figure
  with limbs at varying heights, not one straight stroke.

Delete `public/transform-control.html` once the verdict is recorded.

### 4. Re-examine the hand-pinned `pageFilePath`

**File**: `.codeyam/scenarios/*.json` (25 component scenarios)

Each carries a `pageFilePath` pointing at its `.astro` source, added by hand
because the extractor could not resolve `componentName`. If a later editor
version emits Astro component names, drop the pins and confirm
`recapture-stale` still resolves each scenario's source; if it does not, leave
them and note the version checked.

### 5. Re-verify design fidelity against the handoff

**File**: `.codeyam/design/user_files/design_handoff_puzzle_school/index.html`

With correct captures available for the first time, compare the structures
against the design source rather than the README summary — specifically the
Fibonacci spiral rising out of the Contact card's rule at about half its width,
and the Koch fragment crossing the dark band's top edge. Both were tuned against
captures that were flattening SVG geometry, so their sizing and placement were
judged on unreliable evidence.

## Reused existing code

- `codeyam-editor editor recapture-stale` — the supported recapture path; do not
  hand-delete screenshot files.
- `codeyam-editor editor probe-isolation-routes` — parallel 200-check across
  every component scenario route, cheaper than a screenshot pass for triage.
- `.codeyam/journal/entries/2026-08-12T17-45-12Z.json` — the journalled record of
  the `source-unresolved` finding this plan's step 4 closes out.
- No equivalent capture-verification helper exists in this repo today; step 2's
  control page is genuinely new and deliberately temporary.

## Reproduction Test

No unit-level reproduction is writable here. The defect lives in the capture
pipeline of an external binary, not in this project's source, and it manifests
only as pixels in a screenshot — there is no function in this repo whose return
value changes. Demonstrate it instead with the control page in step 2: expected
a four-armed cross, actual a single bar. That comparison is the reproduction,
and it is unambiguous enough not to need a test harness.

## Scenarios to Demonstrate

- `Mark - Default` — the eight-piece compass rose, correctly rendered for the
  first time in a committed capture.
- `Mark - Missing Piece` — the dashed north piece, which is invisible while
  transforms are dropped because every piece stacks at the origin.
- `BranchingTree - Default` — tapered limbs branching at varying heights.
- `FibonacciStructure - Default` — nested squares with the largest drawn open.
- `Home - Full Design` — the whole page, confirming the mark and the sine field
  read correctly in situ rather than only in isolation.