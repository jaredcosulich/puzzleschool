---
name: codeyam-manual-tests
description: Generate manual tests from recent commits — short, human-executable checks for the things an automated test cannot settle. Reads the commits since tests were last generated (or an explicit `range:` you hand it), maps them to the scenarios that demonstrate them, and writes 3–5 tests ranked by what no automated test can reach — discarding anything a unit test already asserts. Also handles a freeform "write me tests for X" request, seeded from chat. Read-only on git; additive under .codeyam/.
---

# CodeYam — Generate Manual Tests

You author **manual tests**: short, human-executable checks recorded in the
repo at `.codeyam/manual-tests/`. Each one names something a person has to
confirm with their own eyes, and points at the scenario that puts the app in
the state the check needs.

This flow is safe to run:

- **Read-only on git.** You read history and diffs — never commit, amend,
  checkout, or reset.
- **Additive under `.codeyam/`.** Every write goes through
  `codeyam-editor editor manual-test-add`. You never edit application source.
- **Append-only.** Generation may deliberately re-cover ground. If a newer
  commit range touches something an older completed test already covered, you
  write a *fresh* test for the new range — you never reopen the old one. The
  old test stays a true record of what was verified then; the new one is what
  needs verifying now.

**Two entry points, one body.** Invoked bare, you cover everything not yet
covered. Invoked with an argument (a freeform request typed in chat), that
argument is a *focus filter* over phases 2–5 — you still establish the range
and read the diff, but you author against what the user asked about, and you
say so in the report if their request falls outside the changed set.

## Phase 1 — Establish the range

An argument beginning **`range:`** names the range explicitly — everything
after it, up to the first whitespace, is a git revision range
(`range:HEAD~20..HEAD`, `range:main..HEAD`, `range:abc1234..def5678`). Any text
after that range is still a focus filter, so
`range:HEAD~20..HEAD the Testing section` means both.

Resolve it with `git rev-list --count <range>` before using it. If it does not
resolve, say so and ask — never silently fall back to the marker, because the
whole point of an explicit range is that the user is overriding the marker on
purpose and a silent fallback would hand them results from a different range
than the one they asked for while looking like it worked.

An explicit range **does not stamp the marker.** Phase 7 is skipped entirely:
the marker records what has been covered from the anchor forward, and moving it
on the back of a hand-picked range would drop every commit between the marker
and that range's base. Say in the report that the marker was left where it is.

With no `range:` prefix, run
`codeyam-editor editor manual-test-status --format json`.

- **`lastGeneratedSha` present and resolvable** → that is your base. This is
  what makes "generate" mean "cover everything not yet covered", which is the
  only reading that keeps the commits-since counter honest.
- **`neverGenerated: true`** → there is no anchor. Ask the user what to cover,
  offering the merge-base with the primary branch ("everything on this branch")
  and a last-N-commits range. Confirm before proceeding.
- **`lastGeneratedShaUnreachable: true`** → the recorded commit is gone, almost
  always a rebase or squash. Say that plainly and ask for a base the same way.
  Do NOT silently fall back to a default range; the count the user sees depends
  on this choice.

## Phase 2 — Read the change

- `codeyam-editor editor changed-surfaces --base <sha> --format json` —
  partitions the change into `covered` (an existing scenario demonstrates it),
  `uncovered` (a renderable surface with no scenario yet), and `noUiImpact`
  (pure backend/util). Do NOT re-derive this mapping by hand; it walks the
  dependency graph and a second copy would drift.
- `git log --oneline <sha>..HEAD` — the commit subjects that ride in each
  test's `generatedFrom.commits`.

## Phase 3 — Read what already exists

`codeyam-editor editor manual-tests --format json`.

This is **context, not a filter**. An existing test over similar ground is a
*model* for the new one — same surface, same shape of steps. What it prevents
is authoring a second test for a range already generated.

## Phase 4 — Read the project's shape

`codeyam-editor editor project-info` for the app type and stack, so a
`noUiImpact` test is written against this project's real interface — its CLI,
its API, its library surface — rather than an assumed web page.

## Phase 5 — Author the tests

**One test per verifiable behavior.** Not one per commit, not one per changed
file. A commit renaming a variable across nine files is zero tests. Write
nothing for changes with no human-observable consequence, and say so in the
report rather than padding.

### 5a — Disqualify before you author

**A behavior an automated test already asserts does not get a manual test.**
This is the first question, asked before any authoring, and it is mechanical
rather than a judgement: the diff you read in phase 2 **contains the test
files**. A commit that touched `Foo.tsx` and `Foo.test.tsx` together is telling
you the behavior is settled. Grep that test file for the behavior before
writing anything about it.

Concretely, this disqualifies — always, with no subjective override:

- The presence, absence, or wording of a rendered element. `expect(screen
  .getByText(/renders this state directly/i))` is the whole test; a human
  re-reading that caption verifies nothing.
- Prop wiring, callback plumbing, and which handler a button calls.
- The order of DOM nodes.
- Anything a contract test over generated output already pins (a step-template
  shape, a slug set, a copy budget).

A test whose steps are "open the scenario, read the label, confirm it says X"
is an assertion someone has to perform by hand. Delete it and say in the report
that it is covered by `<the test file>` — naming the file is what makes the
smaller count trustworthy rather than lazy.

One more disqualifier, short because it is really a pointer to 5a2: **a
behavior a scenario *can* demonstrate still gets a test, but it gets a
`scenario` surface — never `no-ui-surface`.** Falling back when rung 1 or 2 of
the triage would have worked is the specific error the next section exists to
prevent.

### 5a2 — Simulate before you fall back

**A manual test is a cost.** Before writing one, establish that the state it
needs genuinely cannot be put on screen in Live Preview with mock data.

"The change was classified `noUiImpact`" is **not** that establishment. That
classification is a statement about which files moved. It is not a statement
about what can be rendered, and treating it as one is how every test in a run
can land on `no-ui-surface` without the question ever being asked once.

Run this ladder on **every** candidate, in order, stopping at the first rung
that works. Every rung is reachable from **every** partition, `noUiImpact`
included — that reachability is the whole point, because a partition was
previously allowed to short-circuit straight past all of it.

1. **An existing scenario already renders the state.** → surface `scenario`.
   Confirm with `codeyam-editor editor scenario-explain <slug>` that the frame
   really shows it; a slug that sounds right is not evidence.
2. **A surface exists but not in this state.** → propose capturing it:
   `register` for a missing state, `preview-interact` for a state one action
   away, `preview-flow` for a round trip. Proposed to the user and run only on
   confirmation, exactly as the capture paragraph in phase 5 already specifies.
3. **Split the candidate.** If the behavior mixes an irreducible mechanism
   with an observable output — a race *and* the message it produces — those are
   two candidates. Take the output half down rungs 1–2; take the mechanism half
   to rung 5. Both may ship, and neither drags the other down. This is the rung
   most often skipped, because a candidate arrives feeling like one thing.
4. **Ask whether the state is a value.** Is what the test needs something a
   surface *receives* — props, an API response, a file under `.codeyam/`? If
   yes it is mockable in principle, and what is missing is only a seam to
   inject it. That is `no-mock-seam`, and you must say which seam. Do not
   record it as though the behavior were inherently un-simulatable; those are
   different findings and only one of them is fixable.
5. **Only now, `no-ui-surface`** — with a required `barrier` and a
   `barrierDetail` sentence.

**Rungs 1–3 of the value ladder in 5b are claims about today's tooling, not
laws.** "Crosses a process", "a cache one command writes and another reads",
"needs a real restart" describe the seams that exist right now. Only rung 4
(perceptual) is inherent. So each of 5b's rungs 1–3 must be *challenged* here
before it is accepted — and when the challenge fails, the reason is recorded as
a barrier rather than assumed.

**The four barriers.** They split on one question: **is this codeyam's fault?**

| barrier | means | codeyam gap? |
|---|---|---|
| `no-surface` | Nothing in the app renders this behavior at all. A surface would have to exist before any scenario could show it. | **Yes** |
| `no-mock-seam` | A surface exists and the state is a value, but nothing can inject it. Name the seam. | **Yes** |
| `real-process` | Needs two live processes, a real re-exec, a real clock, a real crash. | No |
| `real-external` | Needs a real third party, network, or device. | No |

The first two are a **backlog**. The last two never will be. Recording them
identically — which a free-text note cannot avoid doing — is what makes a list
of simulation gaps unactionable.

`manual-test-add` **refuses** a `no-ui-surface` without both fields. That
refusal is deliberate: this section is a document, and a document cannot make
the triage happen. Do not work around it by picking a barrier that will be
accepted — an unconsidered `real-process` is worse than the free-text note it
replaced, because it claims a triage was done.

**The barrier is now checked, not trusted.** Naming one was never evidence it
is true, and the 2026-09-13 run proved it: five tests, five fallbacks — three
`real-process`, two `real-external` — while
`buildtabterminalsession-blocked-on-approval` and
`buildtabsessioncontent-many-queued-plans` sat on disk rendering nearly the
exact states those tests described. Rung 1 would have hit; rung 3 would have
saved the rest. So the claim is now falsified in code, at the run boundary:

- `manual-test-add` prints an **advisory on stderr** when a fallback's own
  commit range touches a file an existing scenario renders, naming the slugs.
  The write still succeeds — act on it before phase 7.
- `manual-test-mark-generated` **refuses** (exit `2`, nothing stamped) a run in
  which any fallback's changed files are already rendered by an existing
  scenario, and names each test and the slugs that show it.

The honest way through is **the split**, not a different barrier value: keep
the narrow mechanism test on `no-ui-surface`, and add a sibling test in the same
run whose `scenario` surface points at one of the named slugs. That sibling is
what clears the gate — there is no flag to assert a split happened. A project
with no scenarios is never refused, because nothing can already show its
change.

### 5b — The value ladder

Rank every surviving candidate, highest first, and spend the budget from the
top:

1. **Crosses a process, a session, or a real external dependency.** A real
   OAuth round trip, a real CLI binary, a device, a browser tab. Nothing else
   can reach it.
2. **A sequence whose danger is what a *later* command believes.** A cache
   written by one command and read as a verdict by the next. The bug is in the
   join, so no single-command test sees it.
3. **Timing, recovery, and crash behavior** — needs a real clock, a real
   restart, a real dropped connection.
4. **Perceptual** — layout at real widths and real fonts, animation, crowding,
   anything jsdom has no layout engine to see.

Below rung 4 there is nothing. If a candidate does not sit on one of those four
rungs, it is not a manual test.

### 5c — `intent` is the gate

`intent` must name **something concrete a machine cannot reach**. If you cannot
write that sentence, the test does not ship.

Reject these phrasings in your own draft — they are the tell that a static
render check is being dressed up as a human judgement:

- "whether it *reads well* / *lands* / *feels right*"
- "whether it *actually* helps the reader"
- "is a judgement about wording that no assertion settles"

Those describe a **design review**, not a verification. A design review belongs
in a scenario walkthrough where the whole surface is on screen and the answer
can change the design — not in a pending checklist, where it can only ever be
ticked off. Wanting an opinion on copy is legitimate; a manual test is the
wrong instrument for it.

### 5d — Budget: 3–5 tests per run

**Write at most five, and treat three as the normal answer.** The cap is not a
formatting preference — it is what forces the ladder to be used. An uncapped
run authors everything that survives 5a, which on a large range is twenty
tests, and a twenty-item checklist is not executed at all; the four that
mattered are read at the same weight as the sixteen that did not.

A large range does not raise the cap. Fifty commits with four qualifying
behaviors get four tests. If more than five survive, **rank them and write the
top five**, then name the ones you cut and their rung in the report so the user
can ask for them explicitly.

Two consequences worth stating plainly. Reporting "3 of 41 commits produced a
test" is a **good** outcome, not an apology — most commits should produce
none. And a run that qualifies zero candidates writes zero tests and says so;
generating something rather than nothing is exactly the padding this budget
exists to prevent.

Per partition:

- **`covered`** → surface `scenario`, carrying the slug, name, `scenarioType`
  (`application` or `component`) and a one-line reason. Step one is always
  opening that scenario — the row's button does it for the reader. What the
  remaining steps may say depends on which kind it is, and the two are not
  interchangeable:
  - **`scenarioType: application`** — the scenario boots the seeded app. Steps
    may navigate, click, and fill within it. A click-through is exactly right.
  - **`scenarioType: component`** — the scenario renders the component in the
    state the test needs, in isolation. The remaining steps are what to *look
    at* in that frame, plus only those interactions the isolated render
    actually supports. Never write a route to navigate, a preceding screen to
    pass through, or a sequence of states: the frame is already the end state,
    so "open the prompt screen and expand the picker" is unfollowable there.

  Some isolated components genuinely respond to clicks in their render, so the
  rule is not "component scenarios take no interaction" — it is **take no step
  the isolated render cannot support**. When you cannot tell which applies, run
  `codeyam-editor editor scenario-explain <slug>`: it reports what the scenario
  seeds and which URL it renders, and its screenshot shows what the reader will
  see. If the steps you are about to write are not performable against that,
  they are the wrong steps or it is the wrong surface.
- **`uncovered`** → surface `uncovered`, carrying `uncoveredKind`
  (`component` or `route`), the name, and the file. **Still write the test.**
  Silently skipping surfaces with no scenario hides exactly the gaps that
  matter most; the UI renders it as "no scenario yet" with a route to capture
  one.
- **`noUiImpact`** → **run the 5a2 ladder first — this partition is not a
  verdict.** It says which files moved, not what can be rendered, and a
  `noUiImpact` change frequently has an output half that a scenario shows
  perfectly well (rung 3 splits it out). Only when all four rungs have failed
  does this become surface `noUiSurface`, carrying a note, a `barrier`, and a
  `barrierDetail`, with steps describing a CLI or API verification. Write
  nothing only when the change genuinely has no observable effect.

  This bullet used to end at "with a note", and that made the three
  surface-creating moves below reachable only from `covered` and `uncovered` —
  so a backend-classified change could never reach them however simulatable it
  actually was. The ladder is what removes that dead end; do not reintroduce it
  by treating the partition as the answer.

**When no surface can demonstrate the behavior, capture one — never write the
unfollowable steps anyway.** Generation otherwise only ever *reads* the scenario
set, which is what forces the bad trade: a verification the existing frames
cannot show gets written as navigation against a frame that cannot be navigated.
Three moves, each **proposed to the user and run only on confirmation**, because
each writes into `.codeyam/scenarios/` and produces screenshots the audit gates
read:

- A **missing state**, with a component or route that already exists →
  `codeyam-editor editor register` to capture it, then point the test at the new
  slug.
- An **interactive state** reachable by one action →
  `codeyam-editor editor preview-interact`, which drives the click and
  re-captures without editing application source.
- A **sequence** — the verification is a round trip, not a frame ("choose one,
  then clear it, and see the field return to its empty line") →
  `codeyam-editor editor preview-flow`, whose ordered captioned filmstrip is
  what such a test should point at.

The boundary stays where it was: you still never edit application source.
Capture is **offered, never mandatory** — if the user declines, say in the
test's `intent` that the surface does not exist yet rather than writing steps
against one that does not.

What does *not* stay where it was is the old clause that a `noUiImpact` change
"has nothing to capture". That was the assumption 5a2 exists to retire: the
partition describes the diff, not the renderable world, and the ladder is run
before any of these three moves is ruled out.

Writing the fields:

- **`steps`** — imperative, short, one action each.
- **`expected`** — what the person *sees*, never what the code does.
- **`intent`** — why a human is needed: what changed, and what an automated
  test cannot settle about it.
- **`title`** — one line naming what is being verified.

## Phase 6 — Write them

One `codeyam-editor editor manual-test-add --file <path>` per test, from a
scratch JSON under `.codeyam/tmp/`. Use a unique filename per call.

Omit `id` and let the command derive it from the title — it de-duplicates a
collision with a numeric suffix rather than clobbering, which matters because
two tests from different commit ranges legitimately share a title.

## Phase 7 — Stamp the marker

`codeyam-editor editor manual-test-mark-generated`, **exactly once, and only
after every add has succeeded.**

A partial run must not stamp. Stamping resets the commits-since counter, so
stamping after a failed add silently drops the commits those tests would have
covered — they would never be offered again.

On success it prints this run's **surface tally** — how many tests landed on
`scenario`, `uncovered`, and `no-ui-surface`, with the fallbacks split into
codeyam gaps, inherent barriers, and unclassified legacy records (a `tally`
object under `--format json`). Read it: an all-fallback run is allowed, but it
is the tell 5a2 names, and it must not pass unnoticed. Put the tally in the
phase-8 report.

It may also **refuse** (exit `2`) and name tests whose changed surface an
existing scenario already renders. A refusal means going back to rung 1 or
rung 3 of 5a2 for exactly the named tests — revise them onto the scenario, or
split them and add the `scenario`-surface sibling — then re-running this
command. **Never re-label a barrier to get past it**; the gate does not read
the barrier value, only whether a frame already exists.

**Skip this phase entirely on an explicit `range:`** — see phase 1. A run that
stamps the marker after covering a hand-picked range drops everything between
the marker and that range's base.

Note what the cap does NOT change: a capped run that covered its range still
stamps. The commits you declined to write tests for were *considered and
rejected*, not deferred — that is the whole claim the budget makes — so leaving
the marker behind to re-offer them would re-litigate the same rejection on
every subsequent run.

## Phase 8 — Report

Tell the user:

- How many tests you wrote, and against which commit range. **Lead with the
  ratio** — "4 tests from 41 commits" — so the number reads as a filter having
  been applied rather than as thin coverage.
- What you deliberately did **not** cover, and why. Three groups, named
  separately because they mean different things: changes with no observable
  consequence (renames, refactors); behaviors **already asserted**, naming the
  test file that covers each; and candidates that **survived but lost the
  budget**, with their ladder rung, so the user can ask for one by name.
- Any surface that got a test but has no scenario yet, so they can decide
  whether to capture one.
- **The manual tests, in two groups — never as one list.** They mean different
  things and only one of them is work:
  - **Manual because codeyam cannot simulate it yet** — every test whose
    barrier is `no-surface` or `no-mock-seam`, each with its `barrierDetail`.
    This is a gap list the user can act on: a surface to build, a seam to add.
    Say plainly that these would stop needing a human if codeyam could show
    the state.
  - **Irreducibly manual** — `real-process` and `real-external`. These need a
    person no matter what gets built, and presenting them as a backlog would
    be a standing to-do that can never be closed.

  Reporting them as one undifferentiated list is what the barrier field exists
  to end; collapsing them again in the report throws away the distinction at
  the last step.

Never tell the user to run `codeyam-editor editor` commands; they are internal.
Just tell them what you found and ask what they want next.
