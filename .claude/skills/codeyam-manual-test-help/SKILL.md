---
name: codeyam-manual-test-help
description: Answer a question about ONE manual test, and fix what's wrong. Opened from a test row's "Ask about this test" button with that test's id. Explains how to actually perform the test against the surface it really has, corrects the test in place when the steps are what's wrong, and captures the missing app state when the state the test needs does not exist yet. Never edits application source.
---

# CodeYam — Ask About a Manual Test

You are answering a question about **one** manual test. Its id is
`$ARGUMENTS`.

A manual test is otherwise a one-way instruction sheet: it tells someone what
to verify and hands them a button. When the test is wrong — steps describing a
click-through against a surface that is a static component state, or a state
nothing captures yet — the reader's only exits are to guess, to skip it, or to
check it off dishonestly. You are the fourth exit, and you can actually resolve
what you find.

## What you may and may not touch

- **Never edit application source.** Not `.ts`, `.tsx`, `.rs`, `.py`, `.swift`
  — none of it. If the app itself is broken, that is a different job (see
  *Outcome 4*).
- **Never `manual-test-add` over an existing id.** That command writes the file
  unconditionally and would erase `completion` — the receipt naming who
  verified this test and when. Use `manual-test-revise`.
- **Never `manual-test-complete` on the user's behalf.** Checking the box is
  the human's act; that is the entire point of the store.
- **Append-only is a rule about COVERAGE, not a bar on correcting a
  document.** The generator never reopens a completed test for a newer commit
  range — it writes a fresh one. That is unrelated to fixing steps that were
  never followable. A test that failed to say what it meant is a broken
  document, and leaving it broken forever is not what append-only asks for.
- **Confirm before every write.** Revising a test and capturing a scenario both
  change files the audit gates read. Say exactly what you are about to run and
  wait for a yes.

## Step 1 — Read the test

```
codeyam-editor editor manual-tests --id <id> --format json
```

`entries` holds the test. `count: 0` with a non-zero `total` means no test has
that id — say so plainly and stop; do not guess at a nearby one.

Read `title`, `intent`, `steps`, `expected`, and `surface`. `intent` is the
field that says *why a human is needed*, and it is usually what tells you
whether the steps are asking for the right thing.

## Step 2 — Read the surface the test actually has

`surface.kind` decides where you look:

- **`scenario`** — run `codeyam-editor editor scenario-explain <surface.slug>`.
  It reports what the scenario seeds, the URL a capture hits, and where its
  screenshot is. **Read the screenshot too.** `surface.scenarioType` is the
  field that most often explains a bad test: `application` is a real route you
  can walk, `component` is one isolated state rendered directly and there is
  nothing to click *to*.
- **`uncovered`** — the surface exists but nothing captures it. Read the file
  at `surface.file` to see what the named component or route actually renders.
- **`no-ui-surface`** — there is nothing to render; `surface.note` says what
  the change was. The steps ARE the instruction, and they are usually a CLI or
  API check.

## Step 3 — Say which of the four this is, before you do anything

Name the outcome first, in one sentence, so the user can redirect you before
you write anything.

### Outcome 1 — the test is performable, the path just was not spelled out

Spell out the concrete path against the surface it really has.

For a **component** scenario this is the common case and the common confusion:
the scenario renders that state *directly*, so the steps are things to **look
at**, not a route to walk. Say that plainly — "the picker is already expanded
in this capture; step 2 is describing what you should see, not a click you
make" — rather than leaving the reader to reconcile it themselves.

Write nothing. This outcome is an explanation.

### Outcome 2 — the steps are wrong

Propose a corrected document, **show the diff**, and on confirmation run:

```
codeyam-editor editor manual-test-revise <id> --file <path-to-corrected.json>
```

Build the corrected document from the one you read in step 1: change only
`title`, `intent`, `steps`, `expected`, `surface`, and copy everything else
through byte-for-byte. `manual-test-revise` copies `id`, `status`,
`completion`, `generatedFrom`, and `schemaVersion` from the stored test and
**refuses** a document that tries to change one of them, naming the field — so
a refusal here means your document edited provenance, not that the command is
broken.

A completed test can be revised. Its receipt survives, which is the whole
reason this is a separate command.

### Outcome 3 — the state the test needs does not exist

The test is asking for something real that nothing captures. Close the gap:

- **A missing scenario** → `codeyam-editor editor register` with the scenario
  document. Then revise the test's `surface` to point at the new slug.
- **An interactive state** (an open menu, a filled field, an active tab) →
  `codeyam-editor editor preview-interact` drives the real interaction and
  captures the result. Do not fake it by editing a component's initial state.
- **A genuine click-through** — the verification really is a sequence, not a
  frame → `codeyam-editor editor preview-flow`, which produces an ordered
  filmstrip.

Capturing writes to `.codeyam/scenarios/` and to screenshots the audit reads,
so confirm the specific capture with the user before running it.

### Outcome 4 — the app itself is wrong

The test is right, the surface is right, and the behavior is broken. Say so,
hand off to `/codeyam-plan`, and **write nothing**. Do not revise the test to
describe the bug — that would turn a correct test into a wrong one and hide
the defect behind a green check.

## Step 4 — Report

Report in the user's terms: what you found, what you changed, and what they
should do next with the test in front of them. Never tell them to run a
`codeyam-editor editor` command — you have those tools, they are looking at a
button.

If you revised the test, say which fields changed and confirm the completion
receipt is intact. If you captured something, say what the new state shows and
that the row's button now opens it.
