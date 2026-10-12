# codeyam-audit procedure — align, finalize, present, drive to merge-ready

The authoritative, version-controlled body of the `/codeyam-audit` skill:
**bring this repo into full codeyam alignment, finalize it whole-repo, clean it
for presentation, and drive it to merge-ready — aggressively on deterministic
drift, but supervised on every judgment call.**

This file is the *procedure*; the sibling `SKILL.md` is the thin, stable
*contract* that points here. Durable knowledge accrues in this file so the
skill's "Reflect & self-improve" step can propose edits to **this file**
(never a silent edit to `SKILL.md`) through the standard editor workflow.

It is **self-contained**: a client project has no `CLAUDE.md` to lean on, so
every command, default, and gotcha needed to converge is written here. Read it
top to bottom on first use; on later runs, recalled memories supply the deltas.

---

## What this skill is (and is not)

- **It is the one comprehensive "finalize outside the editor workflow" entry.**
  Run it when you have accumulated deferred-finalize commits, made manual
  commits outside the workflow, or just want to bring whatever HEAD currently
  is into full alignment and merge-readiness.
- **It is aggressive on deterministic drift.** Mechanical alignment fixes
  (registry reconcile, test/evidence/description refresh, capture-script sync,
  screenshot recapture, import-graph refresh) are applied autonomously.
- **It is supervised on judgment.** A bulk unregistered-entity wall, an
  ambiguous classification (fixture vs real, testable vs untestable), and
  anything that would delete or rewrite content **stop and ask** — never an
  unsupervised mass-registration or mass-deletion.
- **It is idempotent and resumable.** Every run makes progress; re-running
  picks up where the last left off. A run ends **either** at merge-ready
  **or** at a specific, answerable question whose answer advances the next
  run. It never bails-and-abandons mid-way, and never leaves the repo
  half-aligned. "Aggressive" means *relentless toward done*, not *reckless*.
- **Outward actions stay human-gated.** Pushing the branch, opening the PR,
  and merging the PR each require explicit user confirmation — they are
  irreversible and are gated by this procedure's own logic.

There is also a **report-only mode** (see the last section): the cheap "just
tell me what's misaligned, don't touch anything" path, including the
deferred-commit attribution report. The headline behavior is the aggressive
drive; report-only is an explicit opt-in.

---

## 0. Preflight — initialized project + supported stack

**Confirm the project is initialized for codeyam-editor.**

```bash
codeyam-editor editor config-show >/dev/null 2>&1 || {
  echo "Project is not initialized for codeyam-editor. Run /codeyam-onboard first."
  exit 1
}
```

If it fails, tell the user to run `/codeyam-onboard` and stop. Do not proceed.

**Read the stack up front and gate on it.** The audit engine aligns and
finalizes per stack; on a stack it does not yet support, a partial sync would
report a half-aligned repo as clean — a false green. So fail loud and
actionable instead:

```bash
codeyam-editor editor capabilities-list --format json   # what this binary supports
cat .codeyam/stack.json                                  # this repo's declared stack
```

- **Supported stack** → drive to full sync (the rest of this procedure).
- **Unsupported stack** → stop with a precise, actionable message naming the
  stack and the supported set, e.g.:
  `/codeyam-audit does not yet fully support stack 'X'. Supported: <list>.`
  Do **not** proceed into a partial sync that would mislabel the repo as clean.

> This mirrors the engine's own stack-agnosticism contract: generalize from
> config where you can, and where you genuinely can't, **fail loud** rather
> than silently producing a false-green on an unsupported stack.

---

## The one unrecoverable rule (read before any commit)

**NEVER rebase, amend, or force-push a branch that may be shared.** A
concurrent session (or a teammate) may have committed under you at any moment.
Integrate a moved primary branch by **merging it in**, never by rebasing onto
it. Every other mistake in this procedure is recoverable; this one rewrites
history other people may be building on and cannot be undone.

**Assume shared unless told otherwise.** On a genuinely private branch the
only cost of merging is a slightly less-clean merge commit — which is never
*wrong*. So default to merge; the user can override only by explicitly saying
the branch is private.

Because a sibling can commit between any two of your commands:

- Re-check `git branch --show-current` before *every* commit — a merged-PR
  auto-switch can move you off the branch you think you're on.
- Re-check `git rev-list --count origin/<branch>..HEAD` and
  `HEAD..origin/<branch>` before committing, so you see divergence the moment
  it appears and merge it in rather than discovering it at push.

> **Fleet block** (active only when the repo participates in a shared commit
> queue — sibling sessions, a per-branch push queue). The push/finalize tail
> prints `Commit queue: ...` lines; these are normal serialization, not
> errors. Every queue bail names its own recovery command — read the bail body
> and run exactly what it says; do not hand-stitch a workaround. On a solo
> branch with no upstream the queue is disabled and this block is inert.

---

## 1. ORIENT — branch, debt, and the whole-repo preview

Establish where you are before changing anything.

```bash
git branch --show-current                     # safe default: the current branch
git fetch origin                              # see siblings' work without integrating yet
git rev-list --count origin/<branch>..HEAD    # commits you have that origin doesn't
git rev-list --count HEAD..origin/<branch>    # commits origin has that you don't
codeyam-editor editor finalize-debt show --format json
```

`finalize-debt show` lists the deferred commits owed a full `session-finalize`.
**Zero deferred and no divergence** → the branch may already be merge-ready;
jump to step 5's `verify-full-finalize` check and short-circuit if it passes
("nothing to finalize").

**Preview the whole-repo finalize debt, not just the diff-only gate.** Any
per-step Fast-Commit gate you have been passing is **diff-scoped** — it only
sees the current diff. `session-finalize` runs the *strict, whole-repo* audit,
which can surface inherited debt (e.g. a `SOURCE_HAS_UNREGISTERED` wall) that
was invisible all session. Surface that count *now* so the size of the run is
known up front rather than discovered at the finalize wall.

> GOTCHA — **diff-scoped gate vs whole-repo finalize.** Passing every
> per-step gate does **not** mean `session-finalize` will pass. Treat a green
> session as "the diff is clean," never as "the branch is finalize-ready."

**Converge the binary AND the server before anything routed through the
server.** These are two build surfaces, not one. `rebuild-self` rebuilds and
swaps the *binary*, so your next CLI invocation runs new code; the editor
**server** is a separate long-lived process that keeps executing whatever build
it booted with until it is restarted. Test runs, gate runs and preview captures
are routed through the server, so a stale server does not make them slow — it
makes their conclusions **invalid**. Measured: a 25-minute `refresh-tests` warm
produced a completely void result because the server was running a build that
predated 61 edited files.

Read the state before you spend anything on it — the probe never builds, swaps,
or restarts:

```bash
codeyam-editor editor rebuild-self --check
```

Treat any verdict other than `current` as **blocking for server-routed work**:

| Verdict | What it means here |
|---|---|
| `current` | Binary and aliases agree with the source. Proceed. |
| `stale` | A source edit (or a failed post-swap restart) is not in the binary. Run `rebuild-self` — read the stderr guidance, which names the recovery that fits. |
| `rebuild-in-flight` | A detached worker is still building. Run `rebuild-self` to re-attach; do not start a second build. |
| `aliases-diverged` | The binary is current but the role hardlinks point at a previous generation — usually after a bare `cargo install --force`. A plain `rebuild-self` relinks them on its already-current fast path without recompiling. |

> GOTCHA — **`rebuild-in-flight` can be checked, so check it before you
> re-attach.** The probe now verifies that the recorded pid is actually a
> `rebuild-self` worker, not just that some process holds that pid. When it throws out
> a leftover record, its stderr says `ignoring a stale rebuild job record` and
> why. If you still doubt the verdict, the two signatures are opposite:
> - **No worker:** `pgrep -f rebuild-self` finds nothing, and
>   `.codeyam/state/rebuild-self-restart.json` reads
>   `"outcome":"succeeded"` with a `buildSha` equal to HEAD. There is nothing to
>   attach to. Report it as a bug rather than waiting.
> - **Genuinely mid-restart:** `pgrep` finds the worker,
>   `codeyam-editor editor server-identity` returns nothing (the server is
>   bouncing), and the restart record is absent. Waiting is correct here.

Then make sure the *server* picked the new binary up:

```bash
codeyam-editor editor restart-server
```

> GOTCHA — **`--defer-restart` is the wrong choice whenever the next step
> routes through the server.** It swaps the binary and deliberately skips the
> bounce, which is exactly the state that yields a void warm. It exists to
> protect a session *hosted by the PTY broker* — i.e. one that would be dropped
> by the bounce. A laptop session usually is not hosted that way, so check
> whether this session actually descends from the server before assuming it
> needs protecting. Choosing `--defer-restart` to be safe, on a session that was
> never at risk, guarantees the one outcome you were trying to avoid.

---

## 2. See the whole failure set at once — no fail-fast

Before fixing anything, get the *complete* list of what is broken, not the
first failure:

```bash
codeyam-editor editor audit --format json
```

Read every `failures[]` entry and the `attribution[]` array together. Each
attribution row is `{invariantId, item, introducedIn, causedByHead,
causedByBranchDrift, causedByForeignClone}` and joins back to a finding on
`(invariantId, item)`. Rows appear only for items whose introducing commit
resolved, so an item with no row is "not attributable", not "attributed to
nothing" — the same thing the text renderer means when it omits the `★`
marker. Note `--findings-only` deliberately omits the array; the default
`--format json` is what carries it.

**Read `cacheFreshness` BEFORE you quote the user a number.** The same
document carries a `cacheFreshness` sibling —
`{green, stale, red, nonGreenPartitions[], nonGreenCauses{}, cacheDependentFindings}`
— and it is present on every projection (`--format json`, `--findings-only`,
`--summary-only --format json`), green or not, so its absence means an old
binary, never a green cache.

`green` counts only partitions nothing has invalidated, which includes
invalidation a partition did not cause itself: a partition whose own sources
never moved is still not green when it shares a runner with one that drifted,
because a single runner invocation wrote both of their caches. `nonGreenCauses`
maps each attributed partition to which check named it — `own-hash-drift`,
`runner-coupled`, or `aggregate-behind` — so you can tell the drift you just
caused from the drift you inherited without re-deriving it. Treat all of them
as equally untrustworthy for pricing: they differ in what they say about the
edit, not in how much doubt they cast. (Before this split, runner-coupled
partitions were counted green here, so this sibling read `19 green / 1 stale`
on a tree where `editor test-status` reported 8 stale — and the refresh that
ratio priced as unnecessary removed 35 of 36 findings.)

When `nonGreenPartitions` is non-empty, the
finding count is an **upper bound, not a debt estimate**:
`cacheDependentFindings` of the total are derived from runner output or
coverage those partitions produce, and they dissolve on a refresh. Measured
on `editor-improvements-73` (2026-08-17): 39 findings on a cold cache — 112
`REGISTRY_ENTRY_RUNNER_OUTPUT_EMPTY`, 114 `REGISTRY_TEST_NOT_WIRED`, 22
`PLATFORM_GATE_MISMATCH`, 106 `UNCOVERED_GLOSSARY_ENTRY`, 111
`GLOSSARY_ENTRY_LACKS_TEST` — became **5** after a flag-free `refresh-tests`
and nothing else.

So: if `nonGreenPartitions` is non-empty, warm the cache with
`codeyam-editor editor refresh-tests` and re-run the audit before sizing the
run in front of the user. Quoting the cold number mis-prices the spend the
user is being asked to authorize — which is the whole point of surfacing a
count here. The text renderer says the same thing in a banner at the top and
bottom of the body; `cacheFreshness` is the machine-readable form so you
never have to parse the prose.

Budget for it: on a scenario-heavy repo this run takes minutes, not seconds.
It is a backgrounded long command like any other; wait on the completion
sentinel rather than assuming it hung.

**Finish your source edits BEFORE you warm the cache.** The warm is only
durable until the next source edit: touching one tracked file re-stales the
partition that owns it, and a stale partition is what step 4a's
`reconcile-registry --auto-apply` pre-flight pays a full package test run to
rediscover. That makes the warm **order-sensitive with respect to step 4**,
which nothing above says and the natural reading gets backwards — warm, size
the run, *then* start fixing is the expensive sequence. Measured on
`editor-improvements-78` (2026-08-31): a 31-minute warm left all 20
partitions green, **one** added comment line in
`crates/codeyam-editor/src/commands/editor/pre_commit_sync.rs` invalidated
it, and the next `--auto-apply` spent 55 minutes re-running partitions to
learn nothing had changed.

Keep warming before you quote a count — that instruction is correct and
load-bearing, and a cold count mis-prices the run. Just do the step-4b
judgment edits you already know you are making first, so the warm you pay
for is the warm that survives. When an edit after the warm is unavoidable,
re-check freshness before the pre-flight rather than assuming the warm
still holds:

```bash
codeyam-editor editor test-status
```

**A warm can false-redden a partition under its own fan-out — recover that one
partition, never the workspace.** The flag-free warm runs runners in parallel,
and under that contention a runner can exit non-zero while its own parsed
results report zero failures. The summary names it — *"the runner contradicts
its own output"* — marks that partition deliberately red, and calls the run
UNVERIFIED. Measured on `editor-improvements-87` (2026-09-16): the `ui` runner
exited 1 with 6,470 parsed results and no failures, then exited 0 with 6,471
when run alone, no code change — and the whole ~28-minute warm was failed by a
runner that was fine.

The warm now re-runs such a runner once, serially, before reporting it, and
says so: `runners_recovered_by_retry` in the summary JSON, plus a `NOTE:` line
in the human output. A non-zero count is a rescued run, not a clean one — the
host saturated. A runner that contradicts itself on the serial retry too keeps
its red, and its diagnostic says the retry already happened; that one is a
genuine setup/hook/crash failure, not contention.

If you still need to recover by hand, scope it to the red partition:

```bash
codeyam-editor editor refresh-tests --partition <name> --write-cache
```

**Not `--force`.** It re-runs the whole workspace and embeds the single cargo
output blob into every cargo partition, which manufactures a fake
multi-failure wall out of one runner's trouble.

**`--findings-only` is a smaller ANSWER, not a faster run — do not reach for
it to save time.** It skips the per-file `git log` attribution walk and the
per-entity evidence projection, and that is genuinely all it skips. Measured
on codeyam-editor itself (1745 scenarios, a ~21-minute audit), attribution was
**5s — 0.4% of the run**. An agent that picks `--findings-only` expecting a
fast path waits essentially the full time and learns to distrust the docs,
which costs more than the minutes. Pick it when you want the compact
projection: the verdict, the missing-\* arrays, and a name+count summary.

**To read ONE finding's detail, use `--only <INVARIANT_ID>`.** It narrows both
the work and the document. A scope that names no coverage-derived finding gets
a `coverage` block holding only the totals and per-classification counts
(`rostersOmitted: true`), not the per-entry rosters. On this repo those rosters
alone took an `--only` document to 11.2 MB for a 13-item finding, which is big
enough that the harness saves it to a file instead of showing it inline. An
`--only` naming a coverage finding (`UNCOVERED_GLOSSARY_ENTRY`,
`UNRESOLVABLE_GLOSSARY_ENTRY`, `STALE_LCOV_COVERAGE`, …) still carries the full
rosters, and so does the unfiltered document.

The lever that actually moves wall-clock is `--concurrency`, because the bulk
of an audit is the per-scenario screenshot scan — one PNG decoded and
perceptually hashed per captured scenario. It defaults to one thread per core;
pass `--concurrency 1` to force the sequential path when you are debugging a
run whose findings look wrong. Findings are identical at every setting.

Which stage is slow is not a thing to guess at — `--timings` reports it:

```
codeyam-editor editor audit --timings --format text     # table on stderr
codeyam-editor editor audit --timings --format json     # `timings` block in the document
```

Read the `unattributed` row as well as the named stages: a large one means the
instrumentation is pointed at the wrong place, which is itself the finding.
A stage reporting `calls: 2` is doing its work twice.

Group findings by invariant id and by the commit that introduced them. Fixing
blind, one failure at a time, wastes finalize cycles — each full
`session-finalize` is the expensive loop you are trying to run *once*.

---

## 3. Don't chase deterministic churn (the stale-cache band)

Several "dirty" signals are deterministic retention churn, **not** edits to
revert:

- Deleted `.codeyam/plans/completed/*` files — the rolling completed-plan
  archive trims to a fixed cap. Every session prunes the *same* files; they
  reconcile to a no-op on merge. Do **not** `git checkout` them.
- `DEPENDENCY_GRAPH_STALE` / `PARTITION_NEEDS_REFRESH` staleness-sweep
  warnings — deferred work, discharged by `session-finalize`'s reconcile, not
  something to fix by hand mid-session.
- Every finding under a non-green partition — see `cacheFreshness` in step 2.
  `REGISTRY_ENTRY_RUNNER_OUTPUT_EMPTY`, `REGISTRY_TEST_NOT_WIRED`,
  `PLATFORM_GATE_MISMATCH`, `UNCOVERED_GLOSSARY_ENTRY` and
  `GLOSSARY_ENTRY_LACKS_TEST` are computed from runner emission, so a cold
  cache manufactures them by the hundred. Warm the cache; do not fix them by
  hand.

**A cost being documented is not evidence the cost is correct.** Everything
in this band is churn you should stop chasing — but the inverse error is
just as expensive, and it wears the docs as camouflage: you recognise a slow
command's shape from `CLAUDE.md`, confirm it is healthy, and let it run,
because the duration was written down as *expected* rather than as a
*symptom*. Documentation records what a command does today, not that today's
behaviour is right. When a command's own progress output says the work it
just did was unnecessary — a partition reporting `already fresh` after
paying a multi-minute test run for it — that is a defect to report, not a
duration to absorb. This file already makes the argument one layer down for
the RSS runaway (two sessions let `reconcile-registry` reach 2 GB because
"this one is slow" was in the docs); it holds for wall-clock too.

> GOTCHA — **`UNCOVERED_GLOSSARY_ENTRY` has TWO causes, and they want
> opposite actions.** A zero-hit reading means the entity's own instrumented
> lines recorded no hits. That happens when nothing tests it — the real debt
> — and it *also* happens when LLVM **inlined** a small function into its
> callers, so the hits landed on the caller's lines and the entity's own
> symbol reads zero even though its code ran and its tests passed.
>
> The discriminator is in the same LCOV the finding came from: **did a test
> that references this entity itself record hits?** If yes, the entity was
> inlined. Measured 2026-09-04 on `session_finalize_log.rs` — `last_run_slice`
> read zero hits beside four tests that each ran, as did `run_id_of`,
> `format_warm_note`, `build_finalize_log_document` and
> `reject_impossible_combination`. The coverage data was healthy: 68.5% of
> functions project-wide carried hits.
>
> The audit now draws this distinction for you and lists the inlined entries
> in their own `— inlining-suspect (a covering test ran; not debt) —` group,
> excluded from the zero-hit count. That group is **not** part of
> `failures[]` and never affects `passed`; under `--format json` it is the
> sibling `inliningSuspects` array, so every entry left in `failures[]` is
> something to fix. **Neither resolution for a genuinely
> uncovered entry applies to that group:** do not write a duplicate test for
> something already tested, and — the expensive one — do not record an
> `untestabilityReason`. A `trivial-wrapper` / `platform-glue` claim
> permanently marks a *tested* function as owing no test, and nothing
> downstream ever revisits it. One session came within a step of doing that
> to eight entries before noticing their tests had run.
>
> Entries outside that group are unchanged and are the real debt. If you are
> triaging by hand on an older binary, check for a covering test that ran
> before you choose between "write a test" and "mark untestable".

> GOTCHA — **a git hook invoking a flag the binary doesn't have.** When a
> commit or push dies on something like `error: unexpected argument '--check'
> found`, or a hook calls a subcommand that no longer exists, the cause is a
> **stale managed hook fragment written by an older binary**. Git hooks are not
> tracked in the tree, so nothing refreshes them on a branch switch or pull.
> Fix it with `codeyam-editor editor install-hooks`, which reconciles the
> managed fragments — adding what's missing, rewriting a body that drifted from
> the current binary's, and removing an orphaned fragment whose name has left
> the managed set (including in hook files codeyam no longer manages). It
> prints what it added / updated / removed, so an empty report genuinely means
> "already current". `git commit --no-verify` is the stopgap only; it blunt-skips
> *every* hook, not just the broken one, so never leave it as the resolution.

> GOTCHA — **coverage-dir graph pollution.** Coverage output directories
> (`coverage/`, `*/coverage/`, `coverage-seed/`, `*/lcov-report/`) can pollute
> the dependency graph with nodes for files that aren't real source. A current
> binary handles this; on an older one, `rm -rf` the coverage dirs before the
> staleness sweep so they stop seeding phantom nodes — but prefer upgrading the
> binary to repeating the `rm -rf` loop.

> GOTCHA — **`rebuild-self` on a freshly reset/switched branch.** After a
> `git reset --hard` / branch-switch under the session, do NOT trust a *mtime*
> read of binary staleness: a reset rewrites every source file's mtime to
> checkout-time, so an mtime heuristic can call a genuinely-old binary "current"
> or a freshly-rebuilt one "stale". The **build stamp** is authoritative —
> `rebuild-self --check` now compares the binary's embedded commit sha against
> HEAD (a plain `rebuild-self` rebuilds when they differ, `--force` overrides).
> Trust that verdict, not mtimes. And a post-swap "server did not become reachable
> within the restart budget" message *after* a `build stamp verified` line means
> the swap **SUCCEEDED** — the new binary is installed and was not rolled back;
> just run `codeyam-editor start` (or raise `CODEYAM_RESTART_START_TIMEOUT_SECS`)
> to bring the server up. It is not a rebuild failure.

---

## 4. Align — mechanical fixes first, then judgment calls

### 4a. Mechanical fixes (autonomous, deterministic, no judgment)

Apply the failures whose fix is unambiguous and scripted. These have a
`fixCommand` in the audit JSON or a named recovery:

- Registry drift → `codeyam-editor editor reconcile-registry --auto-apply`
- Import / dependency-graph staleness → `codeyam-editor editor analyze-imports`
- Post-merge drift after integrating origin →
  `codeyam-editor editor pre-commit-sync --recover` (runs
  `git pull --rebase --autostash` → `post-merge-drift-sweep` →
  `plan-cleanup-duplicates` in one shot — do **not** hand-stitch these, and do
  **not** `git add` a deleted queue-plan copy by hand).
- Duplicate plan slug on merge → the same `--recover` path handles it.

Re-run `codeyam-editor editor audit --format json` after the mechanical pass so
the remaining set is only the judgment calls.

> GOTCHA — **`reconcile-registry --auto-apply` is order-sensitive with your
> source edits, and getting the order wrong costs the better part of an
> hour.** Read-only `reconcile-registry` is a ~20-second command here. Under
> `--auto-apply` *only*, it first runs a stale-partition pre-flight, and in
> its eviction shape that is **one package-scoped `cargo test` per stale
> partition, run one at a time** — so its cost is set by how many partitions
> are stale when it starts, which is set by which files you edited since the
> warm.
>
> Measured on `editor-improvements-78` (2026-08-31): all 20 partitions green
> after a 31-minute warm, then a single one-line description comment added to
> one file, then `--auto-apply` spent **55 minutes** in the pre-flight — and
> **10 of the 11 partitions it ran reported "already fresh"** after paying
> 144–429 seconds each. One edited file re-invalidated the cache and bought
> nearly a whole-workspace re-run to rediscover that nothing had changed.
>
> Two orderings avoid it entirely, and at least one is always available:
> run reconcile **before** you make step-4b judgment edits, or finish those
> edits **before** the step-2 warm (see "Finish your source edits BEFORE you
> warm the cache"). When neither is possible, make the price visible before
> you pay it rather than after — `codeyam-editor editor test-status` is
> cheap and answers "is the warm still valid?" directly, and the count of
> non-green partitions it reports is the number of package test runs the
> pre-flight is about to spend.
>
> While it runs, the pre-flight announces its run count and prints
> per-partition progress with elapsed time. Read that output as a claim to
> check, not a progress bar to wait out: a partition reporting `already
> fresh` after a full run is the tool telling you the run was wasted.

> GOTCHA — **Finish every REGISTRY change before the warm, for the same
> reason you finish every SOURCE edit before it — and this one is the more
> expensive of the two, because it is self-sustaining.** The rule above is
> about the source Merkle hash; a registry change is a second, independent
> way to invalidate a partition, and `reconcile-registry` producing one is
> not an accident but its normal output. Any add, remove, or line-drift
> update moves the affected runner's **registry digest**, and Phase 1
> refuses cache reuse for every partition whose stamped digest no longer
> matches — no source file need be touched, so `test-status` can report the
> partition green while Phase 1 re-runs it anyway.
>
> The loop is what makes it costly. A broad registry change invalidates many
> partitions at once, which collapses Phase 1 from a scoped re-run into a
> **full-suite** one — and in a full-suite run the `cargo-ignored` runner
> reliably exceeds its 1800s floor, because it owns tests that spawn real
> editor servers and they stretch badly under fan-out. A killed runner
> stores no results, so the finalize fails having proved nothing. The
> natural next move — fix what the audit found, re-run — changes the
> registry again and re-enters the loop.
>
> Measured on this repo, 2026-09-08: the loop's lap was a **4584s failure**.
> Finishing all registry changes first, re-warming so the digests matched,
> and only then finalizing was a **695.7s pass** — Phase 1 scoped itself to
> the single partition whose digest had moved, and `cargo-ignored` was never
> re-run at all. Same branch, same work, one seventh the wall-clock.
>
> The cheap pre-check is `codeyam-editor editor verify-test-cache`, which
> answers "do the digests still line up?" before you pay for a run.
> `codeyam-editor editor test-status` prices it: it reports the digest-
> invalidated partitions as a fraction of the total (`1 of 20` is a scoped
> re-run; `9 of 20` is the full-suite run that times out), so the cost of
> the next finalize is visible in advance rather than discovered at 4584s.
>
> Do NOT respond to the timeout by raising `cargo-ignored`'s timeout. The
> floor is already 1800s, raising a number to escape a contention problem is
> what `scripts/check-ci-timeout-floors.sh` exists to stop, and the runner's
> `auto` timeout cannot adapt its way out either — it is
> `lastSuccessfulRunSecs + headroom`, and a persistently-failing advisory
> test in that runner means no run is ever recorded successful, so only the
> floor is ever in play. Fix the ordering instead.

> GOTCHA — **Platform-gate drift can only be reconciled AFTER a full
> `refresh-tests`, so do not hand-run `reconcile-registry` for it here.**
> `REGISTRY_HAS_FOREIGN_HOST_GATED_TEST` fires when a test's registry
> `platform_gate` disagrees with the `#[cfg(...)]` its source declares — the
> shape you get the moment you add a `#[cfg(unix)]` to an already-registered
> test. `reconcile-registry --auto-apply` re-infers the gate from source, but
> it reads the **per-partition test cache**, so run before a full refresh it
> sees the pre-edit cache and reports clean. The finding then surfaces in
> `session-finalize` Phase 2 — after Phase 1's full suite has already run —
> costing a `--start-from-phase 2` round trip of roughly 15 minutes.
>
> You do not need to sequence this by hand: `session-finalize` heals it
> itself, in a Phase 1.5 pass between the refresh and the audit (whenever
> Phase 2 is about to run, `--start-from-phase 2` included). It logs
> `Phase 1.5/5: re-inferred platform_gate from source cfg for N registry
> entr…` naming every rewritten key, and stays silent when nothing drifted.
> If it ever fails it warns and continues, and Phase 2 reports the finding
> with its usual recovery — so the only action left to you is reading that
> line to understand a registry change in the resulting diff.
>
> One case the heal deliberately does NOT repair: an entry whose recorded
> `line` no longer points at the item its key names. The inference verifies
> that anchor before reading any `#[cfg]`, because a drifted line sitting
> under a neighbouring attribute is exactly how a *false* gate gets stamped —
> and a false gate is worse than a missing one, since it tells the audit to
> expect the test not to run on a platform where it silently stopped running.
> Those entries are named in the Phase 1.5 line as declined (with the token
> that would have been stamped), and `reconcile-registry --auto-apply` exits
> 2 rather than 0 when gate drift was detected and none of it was repaired.
> Fix the anchor (a full `refresh-tests` re-derives `line` from runner
> output), then reconcile — or repair the single entry with
> `register-test … --clear-platform-gate` to drop a gate the source does not
> declare.
>
> Note `backfill-platform-gates` is **not** the recovery for this: it is
> fill-only (`None → Some`) and deliberately never overwrites a concrete
> gate, which is exactly what a drifted entry carries.

> **An unanchorable shell/TAP add whose key is a bare suite path is the
> suite ROLLUP, not a phantom.** A TAP suite emits a parent result line
> (`ok 48 - scripts/x.test.sh`) beside its per-case lines
> (`scripts/x.test.sh › some case`), and the rollup is a real, runnable entry
> of its own — so a path-shaped key with no ` › ` is still a genuine
> `RUNNER_HAS_UNREGISTERED_TEST` even when every per-case key of that suite is
> already registered. It is registered at `line: 1` with `file` equal to the
> key, the same shape the registry's other rollups already carry, and
> `register-test` needs `--line 1` for it (a rollup has no per-case line to
> resolve, so the form without it fails with `pass --line <N>`).
> `reconcile-registry` names this case in its skipped-add reason and prints
> the exact command; copy that. Only when the suite file no longer exists is
> the name residue — then clear it with a plain `refresh-tests`, not
> `--force`.

### 4b. Judgment fixes (STOP and ask — never mass-apply)

What's left needs a decision, not a script. **Surface the count and the items,
present concrete options, and wait** — do not autonomously pay these down:

- **Bulk inherited debt (`SOURCE_HAS_UNREGISTERED` and friends).** Discharging
  a whole-repo wall of unregistered entities is the expensive workflow-fan-out
  path, and the user owns that token spend. Surface the count and entities and
  **ask** before registering. No unsupervised mass-registration.
- **Ambiguous classifications** — is this a test fixture? derive-generated?
  testable pure logic or an untestable shim? Apply the project's glossary
  discipline; **ask when truly unsure** rather than guessing.
- **Anything that deletes or rewrites content** — see step 6. Ask first.

> GOTCHA — **`reconcile-glossary` proposals ARE merge-blocking. Size them
> before you quote the user a number.**
> `editor reconcile-glossary` can print a long `add` list (we've seen 100+).
> That list is real, merge-required work — not polish. Two facts:
> 1. The underlying invariant, `SOURCE_HAS_UNREGISTERED_ENTITY`, carries no
>    `_ADVISORY` suffix, so `audit_failure_is_advisory` does not exempt it: it
>    reaches the **strict** gate and blocks `session-finalize` /
>    `verify-full-finalize`. Every `add` needs a `glossary-add` (or a
>    `glossary-skip-add` for a genuine test-fixture / derive-generated
>    artifact) before the branch is merge-ready.
> 2. `reconcile-glossary` walks the **same source scope** the invariant
>    consumes (`discover_source_rel_paths` → `collect_source_entities_for_files`,
>    which excludes `ALWAYS_EXCLUDED_DIRS` like `.codeyam/`). It previously
>    walked the broader dependency graph and proposed adds for
>    `.codeyam/`-internal capture scripts/hooks the gate never touches — pure
>    noise that inflated the wall. Post-fix, the list is not inflated: what it
>    shows is what you owe.
>
> **Size the Phase 2 wall with `editor audit --format json`** — the default
> JSON projection is the STRICT comprehensive gather, the same one
> `session-finalize` Phase 2 blocks on. Measured on this repo it reported
> exactly the 25 `SOURCE_HAS_UNREGISTERED_ENTITY` items Phase 2 later stopped
> at. Do NOT size it with the mid-session `editor audit-gate` /
> `audit --findings-only` count: that one downgrades inherited debt and will
> **under-report** the obligation, which is exactly how a run gets mis-priced
> and then re-scoped in front of the user.
>
> **`editor finalize-preview` is the richer projection** when you also need
> the walls beyond Phase 2: it runs the same strict gather, then adds the
> Phase 3.5 screenshot-recapture obligation and the Phase 3.6
> glossary-reconciliation ambiguity count, kept disjoint from Phase 2 so the
> totals do not double-count. It is the costlier of the two (it also runs the
> static checks and a full dependency-graph rebuild), so launch it
> backgrounded; it heartbeats, prints a `[Ns] finalize-preview: <pass>` line
> as each pass starts, and `command-status finalize-preview` reads its verdict
> back. A run whose RSS keeps climbing past ~2 GB is a regression to report,
> not a large project — the per-entry re-parse that once made it run 19
> minutes silent now trips a `BLOCKED:` memory ceiling instead.
>
> This makes the stop-and-ask above *more* important, not less: the user is
> authorizing real, required spend. Quote them the measured number, and say
> which projection it came from.

> GOTCHA — **`SLUG_FILE_EXCEEDS_BUDGET`: lift or split, never reflow.** The
> finding names a step-library slug over its line budget, and the obvious
> remedy — reword the prose until it fits — is the one that breaks the build.
> The pre-split slug bodies are frozen as fixtures under
> `crates/codeyam-editor/tests/fixtures/legacy/` and compared **line for line**
> by `assert_lines_preserved`, so a reflowed line reads as a *dropped* line and
> fails; `step_audit_guidance_contract.rs`, which pins literal phrases inside
> the step files, is the second guard the same edit trips. Both are invisible
> until the suite runs, which is precisely what step 6a exists to surface early.
>
> Two sanctioned mechanisms, both line-preserving:
> 1. **Lift a block into a fragment.** The budget is measured on the RAW slug
>    file, while `step.rs` injects the fragment at render time — so the text is
>    authored once and still reaches the agent verbatim. This is the way the
>    decomposition guard itself documents ("the established way to keep a slug
>    under the ratchet is to lift a block into a fragment"):
>    ```bash
>    codeyam-editor editor new-step-fragment <name> --slug <slug>
>    ```
>    It writes the fragment body, adds the `include_str!` substitution, inserts
>    the `{<name>_block}` placeholder into each named slug, and prints the
>    placeholder-leak test to add.
> 2. **Split the slug** into a companion slug, moving whole lines across.
>
> The rule is about the *frozen* lines, not about every line in the file. A line
> your own branch added is absent from the legacy fixture, so nothing pins it and
> you are free to condense it. That distinction is what makes this usable rather
> than absolute — check the fixture before assuming a line is untouchable.

This is the convergence contract in practice: each run fixes all the mechanical
drift it can, then stops at the **first** genuine judgment call with a specific,
answerable question. The user's answer advances the next (resumed) run.

---

## 5. Refresh evidence + screenshots (in the right order)

If the branch carries surfaces with visual or scenario output, the finalize
wants current evidence and screenshots.

> GOTCHA — **reconcile/evidence ordering.** Record test evidence on reconcile,
> *then* capture/refresh screenshots — not the reverse. A current binary
> records evidence for you during reconcile; the old manual sequence
> double-refreshed. Don't re-introduce the double-refresh.

> GOTCHA — **deleted-screenshot recovery.** If screenshots were pruned
> (retention, a clean checkout, a sibling's reconcile), **recapture** them
> rather than reverting the deletion — the capture is the source of truth; the
> file on disk is derived.

> A pure-backend / non-visual stack has no screenshots to refresh; this step is
> a no-op there. Don't fabricate visual evidence for a stack that has none.

> **A large sweep is not necessarily a two-hour sweep — `--concurrency` is the
> knob.** `recapture-stale` dispatches one capture at a time by default, which
> on a 1,700-scenario corpus measured ~7,400s (just over two hours) at ~4.4s
> each. Pass `codeyam-editor editor recapture-stale --concurrency <N>` to keep
> N in flight (or set `scenarios.recaptureConcurrency` in `.codeyam/editor.json`
> as a project default, since the right value is a property of the machine's
> cores and memory, not of any one run).
>
> Raising it is safe because the editor server takes its capture gate
> EXCLUSIVELY for any capture that mutates shared state — one that seeds,
> restarts the dev server, resets a sandbox or container, drives a shared
> simulator, **or scripts streams or transcripts** (those overlay the scenario's
> script onto the server's single shared mock engine for the whole render). Such
> captures never overlap however many are dispatched; only captures that mutate
> nothing share the gate.
>
> That list is exhaustive rather than illustrative, and it is worth knowing why:
> the stream/transcript channel was MISSING until 2026-08-30, and its absence is
> what let a `--concurrency 4` sweep screenshot one scenario showing a different
> scenario's scripted transcript. So do not reason from "my scenarios don't
> seed, therefore concurrency is free" — reason from the list. If you add a
> capture path that touches server-side shared state, it needs a channel in
> `crates/control-api/src/capture_lock_mode.rs::CaptureMutationInputs` before it
> is safe to run concurrently.
>
> The real cost of too high a value is memory — every capture spawns its own
> browser — so raise it in steps and watch. Native-simulator stacks are pinned
> to 1 (one shared device) and ignore the flag, and a content-collection stack
> sees little gain because nearly every capture there is exclusive either way.
>
> **A capture the server leaves unanswered under concurrency is retried once,
> serially, before it is ever reported — so do NOT read a timeout at the end of
> a sweep as a broken scenario.** Both unanswered shapes are retried: a transport
> failure (the server did not answer, or not with the capture contract) and a
> per-slug timeout (the budget elapsed before it answered). Neither is a verdict
> about the scenario; a budget elapsing says the server was too slow. The re-ask
> is sequential on purpose, because the likeliest cause is the sweep's own
> fan-out — measured on a 1,740-scenario sweep, three slugs timed out at
> `--concurrency 4` and all three captured in 37s when re-run serially, with no
> code or config change. A slug that goes unanswered TWICE keeps its outcome and
> is reported honestly, so a genuinely uncapturable scenario is never masked.
>
> The JSON reports `captures_recovered_by_retry` for exactly this. Non-zero means
> the run hit that saturation and absorbed it — the signal that a lower
> `--concurrency` would have captured the same corpus in one pass. Without it, a
> rescued run looks identical to one that never needed rescuing.
>
> Two consequences for reading the output. The JSON reports `concurrency`
> (requested) and `effective_concurrency` (used) — read the latter, since a
> native stack reports a request it did not honor. And it reports the cost in
> two parts, which is the part worth internalizing:
>
> - `capture_seconds` — the capture loop alone. **This is the only number that
>   shrinks when you raise concurrency.**
> - `elapsed_seconds` — the whole invocation, which also includes the
>   collision-isolation post-pass. That post-pass re-hashes every screenshot in
>   the project, so it is a FIXED whole-project cost regardless of how many
>   scenarios this run captured. A measured 4-scenario run spent ~40s capturing
>   and ~1,090s there.
>
> So when you re-price a quoted estimate (e.g. `finalize-preview`'s "budget
> roughly N minute(s) from this project's last M capture(s)" — derived from
> *serial* timings), divide the **capture** portion by the effective
> concurrency and leave the fixed portion alone. Dividing `elapsed_seconds`
> wholesale is the same class of mis-pricing this reporting exists to stop.
>
> **`--concurrency` is not the only wall. `recapture-stale` also carries a
> default 300-second budget, and on a large sweep that is the one you hit
> first.** Concurrency changes how much gets captured *before* the budget
> elapses; it does not change *whether* the sweep finishes. Reading the
> paragraphs above and tuning only `--concurrency` therefore still leaves you
> short — measured: 1,789 stale, **132 captured**, exit `2`. A sweep you intend
> to complete wants the budget lifted explicitly:
>
> ```bash
> codeyam-editor editor recapture-stale --concurrency <N> --max-seconds 0
> ```
>
> `--max-seconds 0` disables the wall. Set both together — they are one decision
> about a large sweep, not two independent knobs.
>
> Distinguish the two outcomes rather than guessing: a budget bail sets
> **`budget_expired: true`** on the stdout JSON and lists every uncaptured slug
> under `skipped`. That is an *unfinished* run, not a failed one — the captures
> it did make are good, and nothing was left worse than it was found. Do not
> investigate it as a capture failure (which is what the GOTCHA below covers);
> re-run it with the budget lifted.

> **`--concurrency` and `--max-seconds` bound different things, and a large
> sweep needs you to get both right.** Concurrency shrinks how long the captures
> take; the budget bounds how long the run is ALLOWED to take. They are easy to
> read as one lever and they are not: under a budget too small for the work,
> raising concurrency changes only how many scenarios get captured before the
> same wall, never whether the sweep finishes. Following the concurrency advice
> above and no more is exactly how a reader still gets cut off.
>
> The budget used to be a flat 300 seconds whenever you did not name one —
> chosen before the command had any idea how much work it had found. Measured
> 2026-09-03 on this repo: 1,789 scenarios stale, a default-budget run captured
> **132** and skipped **1,657**, printing
> `⏱ Budget expired after 300s — skipping 1657 remaining slug(s)` and exiting
> `2`. The same set drained in one pass with `--max-seconds 0`. Five minutes
> bought nothing but the number.
>
> **Omitting `--max-seconds` is now the right default**, and it is no longer the
> trap: the budget is sized from the stale set the run discovers, at this
> project's measured capture rate, divided by the concurrency actually in use —
> with headroom, and never below 300s, so a small touch-up behaves exactly as it
> did. The startup line names the budget and where it came from:
>
> ```
>   ▶ 1789 scenario(s) to recapture (budget 2952s, derived from 1789 stale
>     scenario(s) at 4.4s each across 4 concurrent capture(s))
> ```
>
> Read that line. It is there so a mis-sized run can be stopped in its first
> seconds rather than discovered at the wall.
>
> The derived number is a starting estimate, not a wall. The run re-checks it
> against the pace it is actually achieving, and when it is slower but still
> capturing it extends the budget — up to 3x the original — printing a
> `⏱ Budget extended …` line with the observed and assumed pace. So a slow
> machine no longer bails 83% done and costs a second full pass (measured
> 2026-09-24: 1,947 stale, 335 skipped at a 9,054s derived budget, 195 minutes
> across two runs). The observed pace is recorded as the next run's estimate. A
> run that stops producing frames is not extended, and an explicit
> `--max-seconds` is never extended.
>
> A value you pass is still authoritative — an explicit `--max-seconds 300`
> still stops at 300 and still exits `2`, because a caller who names a budget
> means it. So prefer omitting the flag on a full sweep, and reach for an
> explicit budget only when you deliberately want a time-boxed partial paydown
> (which is what the `finalize-debt` advice offers it for). `--max-seconds 0`
> remains unlimited.

> GOTCHA — **a recapture that fails everything is ONE cause, not N.** When
> `recapture-stale` fails every capture (or most of them), treat it as a single
> environmental cause until proven otherwise — unrelated scenarios do not
> spontaneously break together. The command now does this grouping for you: it
> normalizes each failure (stripping the per-scenario slug and URL), and when
> two or more agree it leads the bail with one shared-cause diagnosis and puts
> the same string on the JSON's `shared_failure_cause` key. Read that first.
> Do NOT open the per-scenario failures one at a time, and do NOT hand-write a
> `grep -o … | sort -u` over the output to discover how many distinct errors
> there really are. The usual culprit is an error the app emits while loading
> the page, which the capture guard rejects on; such errors are normally
> suppressed in the app's own dev-server configuration, so read that file
> first — a project that documented its own escape hatch is one read away.

> GOTCHA — **`env.*` overrides do not reach a running app.** `codeyam-editor
> editor config-override env.FOO bar` writes the value and live-reloads the
> *editor's* config, but the app is a long-lived child process that read its
> environment when it booted. The override does not take effect until that
> process restarts, so a recapture run in between just re-proves the old
> failure — minutes wasted. `config-override` now says so and prints
> `Next valid action: codeyam-editor editor restart-dev-server` for these keys;
> run it before re-capturing. Non-`env.` keys are genuinely live-reloaded and
> owe no restart.

---

## 6. Presentability pass — treat the branch as open-source

Placed *after* screenshots are refreshed (step 5) so the gallery embeds the
final images, and *before* step 6a so the narrowed suite validates the cleanup
while that is still cheap — not at the finalize, which is where this used to be
discovered. For a branch built entirely via Fast Commit, the per-cycle finalize
bodies rendered terse (no polish), so this is where the repo finally polishes
before merge.

```bash
# Read-only: surface stale docs + non-essential debug logging. Never deletes.
codeyam-editor editor presentability-scan

# Refresh the README how-to + scenario gallery (idempotent).
codeyam-editor editor readme-sync
```

**A `readme-sync` that exits `2` with `BLOCKED:` is a finding to act on, not a
step to skip past.** It means the README's gallery or how-to block holds content
codeyam-editor did not write — someone curated by typing between the markers —
and the sync refused rather than destroying it. Do NOT work around it by
reverting their edit or by deleting the markers (removing them makes the next
sync *append* a second, generated gallery). Read the `Next valid action:` line
and follow it: move that prose outside the markers, or move the curation into
`.codeyam/readme-gallery.json` — scaffold one with `codeyam-editor editor
readme-gallery-init`, which names scenarios by slug so their screenshots keep
refreshing. Surface it to the user when the right home for their words is not
obvious; it is their writing, and this refusal exists because a routine sync
once destroyed a hand-curated gallery with no warning.

**`Debug logging: not scanned` is NOT a pass.** It means this stack declared no
`debugLogPatterns` and has no built-in default, so the logging pass never ran
and an empty candidate list is an absence of evidence, not evidence of
cleanliness. Configure `debugLogPatterns` in `.codeyam/stack.json` (or add a
built-in default for the stack's framework token) and re-run before treating
presentability as clean. `Debug logging: none` is the line that means clean;
under `--format json` the same distinction is `debug_log_patterns_source`.

Then **assertively** remove the clearly-dead docs and debug log lines the scan
surfaces — but **ask the user about anything uncertain** before deleting it.
The scan only ever *lists* candidates; the judgment (and the deletion) is
yours, and deletion is a judgment call (step 4b): when in doubt, ask. A debug
line a test asserted on will fail once the suite runs — step 6a catches that in
seconds, so revert that one removal there rather than discovering it at Phase 1
prices.

> `session-finalize` also emits a self-contained presentability advisory naming
> these same two commands, so a client with no copy of this procedure is still
> covered.

---

## 6a. Verify the edits before the finalize pays for them

Steps 4 and 6 both **edit source** — 4b's judgment fixes, 6's assertive removals
— and nothing between them and step 7 ever executes what they changed. Without
this step the finalize is the first thing to run the pass's own edits, and it
charges Phase 1 prices to tell you a test went red.

```bash
# Narrowed to this pass's diff — the cheap scope, not the finalize's.
codeyam-editor editor refresh-tests --changed
```

Fix every red **here**, before entering step 7. The asymmetry is the whole
argument, and it is measured: on `editor-improvements-88` a step-4 trim of three
step-library slug files broke two cargo tests. The finalize surfaced them at
`CODEYAM_FINALIZE_PHASE1_FAILED` after **2986 seconds**; running the two affected
test files directly afterwards took about **50 seconds**. Add the
`pre-commit-sync` re-claim, the rebuild the edit forced, and the re-finalize, and
a verdict available in under a minute cost about an hour.

`--changed` is the point: it runs only the tests for the files this pass touched,
which is exactly the set steps 4 and 6 edited. The flag-free form already has two
jobs in this procedure — warming a cold cache in step 2, and the finalize's own
Phase 1 — and paying for either one here would spend the cheapness that makes
this step worth taking.

This is a different failure class from the hoisted strict audit in step 7's
`Phase 0.5/5` / `Phase 0.6` pre-flights. Those catch *audit findings* early; a
plain red test is invisible to them, because only a test run can see it.

---

## 7. Commit → finalize → the merge-ready gate

This is the expensive loop; still aim to run it *once*, cleanly — but two
properties now make its cost proportional to the change rather than flat.

**The cheap gates fail fast.** `verify-build` and the cross-target build run
as a hoisted `Phase 0.5/5` pre-flight, ahead of the ~35-minute full suite,
and their positions at Phase 4 / 4b become a no-op re-check. So a
cargo-fmt, clippy, tsc, windows-portability, shell-tests, date-rot or
cross-target failure surfaces in minutes instead of surfacing at minute 57
of an otherwise-passing run.

**A re-run after a small fix is no longer full price.** Each phase records a
fingerprint of the inputs it actually consumes, and a later run skips a
phase whose fingerprint is unchanged, logging `Phase N/5: skipped (inputs
unchanged since <sha> at <time>)`. A one-file post-CI test fix therefore
re-runs the phases that file affects and re-stamps the marker, instead of
paying the whole hour again purely to move `lastFullFinalizeSha`. A
fingerprint that cannot be computed counts as *changed*, so the failure
direction is always "do the work".

This does **not** relax the marker-stamp trap below — `verify-full-finalize`
remains the only authority on merge-readiness. It also does not change what
`--start-from-phase` means: that still skips by operator assertion rather
than by evidence, and still cannot advance the marker.

Nor is it a licence to run the loop repeatedly. The saving is per *phase*; the
cost is per *cycle*, and a cheaper re-run is still a whole cycle — a
`pre-commit-sync` claim, a finalize, and a push. What keeps the count at one is
batching the fixes that trigger it: see 8a's *land the whole set in ONE commit*
before you fix the first red check.

```bash
# Stop fast-intent so finalize stamps the real marker, not a deferred one.
codeyam-editor editor fast-commit-stop

# Integrate any sibling commits by MERGING (never rebasing) — see rule 0.
codeyam-editor editor pre-commit-sync          # claims the commit queue; --recover if it bails

# The full, whole-repo finalize. Stamps lastFullFinalizeSha.
codeyam-editor editor session-finalize 2>&1 | tee /tmp/codeyam-audit-finalize.log
```

> **A Phase 0.6 block is the CHEAP failure, and on a branch carrying audit
> debt it is the one to expect.** The finalize runs the strict audit *twice*:
> once as a pre-audit before Phase 1's full suite (~45-50 min here), and again
> as Phase 2 in its own position. The pre-audit blocks immediately on every
> finding Phase 1 could not have changed — the not-cache-derived invariants
> (`SOURCE_HAS_UNREGISTERED_ENTITY`, `SLUG_FILE_EXCEEDS_BUDGET`, the glossary
> ones) plus any cache-derived finding whose partitions Phase 1 is going to
> reuse anyway. So a `Phase 0.6/5:` block costs ~3 minutes, not ~52, and the
> fix-then-rerun loop after it is minutes per turn rather than an hour.
> Measured on `editor-improvements-88` before this existed:
> `phase1=passed, phase2=failed, elapsed=3128.2s` for a verdict a standalone
> `audit --only` reached in 100-190s.
>
> Findings it *cannot* settle — ones derived from runner output a partition
> Phase 1 will re-run produces — are reported as deferred and left to Phase 2,
> which remains the authority. A clean pre-audit therefore proves nothing about
> merge-readiness on its own; only Phase 2 advances the marker. Budget one extra
> ~3 min audit (~6%) on a run where nothing is wrong: the asymmetry is 3 minutes
> against 52.

> GOTCHA — **the marker-stamp trap.** A `session-finalize` that *skips* the
> comprehensive whole-repo phase can leave `lastFullFinalizeSha` unstamped even
> though it exited 0 — and then the merge-readiness gate still fails. Always
> confirm the marker actually advanced:
>
> ```bash
> codeyam-editor editor verify-full-finalize   # exit 0 == HEAD is covered
> ```
>
> If it exits 1 after a "successful" finalize, you hit the trap — re-run the
> finalize forcing the comprehensive pass; don't trust the green exit code
> alone.

> GOTCHA — **redirection + completion token.** Use `2>&1 | tee <file>` to capture
> both streams to a file you can read back. The finalize prints its terminal status
> as a JSON line carrying `CODEYAM_CMD_COMPLETE` on **both** success and failure.
> When the harness backgrounds the finalize, **await its completion notification**
> (the re-invocation when the task exits) — or block once with `codeyam-editor editor
> wait-for <task-id>`, run BARE. Then read the `status` off that sentinel line in the
> `tee`'d file. Do NOT hand-roll an `until grep … sleep` poll loop, and don't regex
> English success strings. (Same wait-for-the-notification model as the editor
> SKILL.md and the step hook's background-work block — one model, not two.)

> GOTCHA — **the on-disk log spans EVERY run, so grepping it answers the wrong
> question.** Separately from the `tee`'d file above, finalize always writes
> `.codeyam/logs/session-finalize.log`. That file is deliberately append-only —
> the history is useful, and comparing this run's phase timings against the last
> one is a real workflow — so a `grep BLOCKED:` or `grep 'Next valid action:'`
> over it returns **the union of every run this branch has ever done**, most of
> it historical and none of it labelled as such. This is the same shape as the
> `<cmd>.txt` warning in CLAUDE.md, where a narrower re-run replaces a wider
> one's output: in both cases the file you get is not the file you meant.
>
> It reads exactly like a live problem. A previous run's `fleet-ready.test.sh
> mutated the repository under test` bail — carrying a repository-state delta
> naming a branch that no longer existed — was once read as live damage to the
> current checkout, and several minutes went into verifying `core.bare`, the
> reflog, and every ref before it turned out to predate the session by days.
>
> Ask for the run you actually mean:
>
> ```bash
> codeyam-editor editor finalize-log --last-run      # just the newest run
> ```
>
> Read-only, exits `0` on an absent or empty log, and takes `--format text|json`
> like the other query surfaces. Under JSON, `count` is the slice's line count
> and `total` the whole log's, and the `runId` sibling is the join key — it
> matches the `runId` on
> `.codeyam/state/command-output/session-finalize.status.json`, so you can prove
> the slice and the verdict describe the same run rather than trusting a bare
> `status`. Every run that started emits a closing `CODEYAM_FINALIZE_RUN_END`
> marker carrying `ok`, `failed`, or `refused` (a blocked precondition, such as
> the dirty-tree gate, that returns before the phases run). So a slice with NO
> closing marker means the run never finished at all — still in flight, or
> killed.

> GOTCHA — **the per-test-evidence union-clobber.** If the finalize's evidence
> phase reports a large `per-test-evidence` "missing" / "out of sync" count
> (thousands of rows) that appeared *right after* a `pre-commit-sync` pulled
> sibling commits, suspect the union-clobber, not a real evidence gap: a
> non-driver merge (a `git pull --rebase` autostash pop) dropped local rows.
> `origin` retains the intact file, so recover in one line —
> `git checkout origin/<branch> -- .codeyam/per-test-evidence.json` — instead of
> paying a full flag-free `refresh-tests`. The normal `pre-commit-sync` now
> integrates through the union-safe transient-commit rebase and re-asserts a
> post-integration shrink guard, so a fresh clobber should no longer occur; this
> recovery is for a file already damaged by an older sync.

> GOTCHA — **a red test during the coverage bootstrap is a test failure, not a
> tooling failure.** On a Rust project the finalize runs `cargo llvm-cov` before
> Phase 1 whenever source has moved. With `--no-fail-fast` the whole suite still
> runs past a red test, but cargo-llvm-cov then exits 101 and writes **no** LCOV
> file. An older binary reported that as `LCOV bootstrap failed: cargo llvm-cov
> exited with status exit status: 101`, every phase `pending`, and the failing test
> was one line in a 25,000-line transcript (search it for ` ... FAILED`). A current
> binary rebuilds the LCOV from the run's profile data, marks the failing test's
> partition red in the test cache, prints `the coverage run had N failing test(s):
> <names>`, and continues. Phase 1 then re-runs that partition instead of reusing a
> cached pass, so a test that is still red fails the finalize there, by name. That
> red mark survives a finalize that stops earlier, for example on a Phase 0.5 static
> gate. So a re-run that skips the (now fresh) coverage step still re-checks the
> test. Treat the named test as the finding. Do not turn off
> `audit.coverageBootstrap.enabled`, because that removes coverage gating, not the
> red test. When no usable LCOV can be rebuilt (a build error, a crate the host
> cannot build, an OOM kill) the bootstrap still bails with its original message
> and remedies (`excludedWorkspaceCrates` first), plus a `Failing tests:` line
> when the output named any.

> GOTCHA — **infra crashes, not code bugs.** A finalize can die on a full disk
> or an OOM. If it crashes non-deterministically, check `df -h` / free memory
> before assuming the branch is broken.

Only after `verify-full-finalize` exits 0 is the branch **merge-ready**.
**Stop here and report unless the user explicitly authorized the push.** When
authorized:

```bash
codeyam-editor editor push                     # the wrapper runs the deferred-finalize gate
```

`editor push` works **directly** here even though this branch never walked the
guided workflow — the wrapper proceeds past its workflow-step precondition once
`verify-full-finalize` is green (HEAD is full-finalize-covered), so there is no
need to fall back to a plain `git push`. A mid-workflow branch that is *not*
full-finalize-covered is still refused, with a message naming both routes
(advance the workflow, or run a whole-repo `session-finalize`).

If the pre-push gate complains of deferred commits, do **not** override with
`--allow-deferred`; it means finalize didn't cover the range — go back to the
marker-stamp trap above.

### Publishing a release AFTER the finalize

If this branch publishes a versioned artifact, the ordering is:

**bump → publish → commit → finalize → push** — never bump → publish → commit → push.

A version-bump / release-metadata commit (a manifest version field, a lockfile,
a changelog stamp) is a **source change like any other**. It falls outside the
stamped `lastFullFinalizeSha`, so a branch driven to `verify-full-finalize`
exit 0 and pushed silently stops being merge-ready the moment that commit
lands — and the ordinary push gates do not catch it, because they classify
manifests and lockfiles as owing no finalize. You then pay a second
`session-finalize` plus a second push to get back.

Put the release commit *inside* the finalize instead: bump and publish first,
commit the version metadata, and only then run `session-finalize` and push.

`editor push` now blocks on this rather than letting it through silently — a
`BLOCKED:` with `Next valid action: codeyam-editor editor session-finalize`
when the branch was stamped merge-ready and has drifted off it. On a feature
branch under fast intent it warns instead of blocking, matching how the same
gate treats ordinary post-finalize source commits there.

---

## 8. PR → CI → mergeability

With the branch pushed and merge-ready:

- Open or update the PR (`gh pr create` / `gh pr view`), **only on explicit
  user confirmation**.
- Track CI. Any red check is handled by 8a below — there is no shortcut.
- Drive to `gh pr view --json mergeable` → `MERGEABLE` /
  `mergeStateStatus: CLEAN`. A `CONFLICTING` state means origin moved again —
  merge it in (never rebase) and re-run the finalize gate.
- Merging the PR is the final outward action — confirm with the user.
- **Merge with a stripped body — never let a squash inherit `[skip ci]`.** See
  8b below; this is not optional polish, it is the difference between the merge
  publishing a binary and publishing nothing.

**A 5xx from an outward write is not evidence the write failed. Read the
resource back before retrying.** A `502` says the *response* did not make it
back to you; it says nothing about whether the server acted. Every outward
action this section gates — opening a PR, merging one, pushing a tag, creating a
release — is one where a blind retry is more expensive than the original
failure, because the retry is not idempotent.

Both halves of that happened in a single session, and both writes had **already
succeeded**:

| Write | What it returned | What a blind retry would have done |
|---|---|---|
| `gh pr create` | HTTP 502 | Opened a **duplicate PR** for the same branch |
| `gh pr merge --squash` | HTTP 502 | Attempted a **second merge** on a just-merged branch |

So the rule, for any write this procedure gates:

```bash
# Do NOT re-run the write. Read the resource back first.
gh pr list --head "$(git branch --show-current)" --json number,state,url
gh pr view <n> --json state,mergedAt,mergeCommit
```

If the resource is already in the state the write intended, the write
succeeded — report it as done and move on. Only retry once a read has actually
confirmed the write did not land. This generalizes past `gh`: treat *any* 5xx on
an outward action as "verdict unknown, go and look", never as "it failed, do it
again".

### 8a. Red CI is not done — investigate before you classify

**A red test is a red test. `verify-full-finalize` exiting 0 locally is
necessary but NEVER sufficient — local green does not clear red CI.** When any
CI check is red, root-cause it at the source *before* any
"known/flaky/infra/environmental" label is even considered.

**The contract — investigate-then-classify, never classify-then-defer.** For
**every** red check, in this order:

1. **Pull the actual failing-job log.** Do not reason from the check name.
   ```bash
   gh pr checks <pr>                       # list checks + buckets
   gh run view --job <job-id> --log-failed # the specific failure
   ```
2. **Extract the specific assertion or build error** — the failing test name,
   the exact `assertion failed: ...` / compile error / panic, the line. Write
   it down.
3. **Only now classify**, against the flake bar below. A classification with no
   log evidence behind it is forbidden.

**FORBIDDEN:** presenting a stop/defer question whose justification is an
un-investigated "known infra" or "known flake" label. A queued plan or a flakes
memory is **not** evidence that *this* red check is that issue — confirm the
failure signature matches first.

**Default toward fixing, not stopping.** Red CI after a push is *inside* this
skill's job, not an outward action — the default is "root-cause and fix."
Surface to the user only a genuine fork (approach A vs B with real ripple), as a
real decision, never as a defer.

**Land the whole set in ONE commit — a post-finalize commit un-stamps the
branch.** A CI run reports *every* failure it found, so the complete set is in
front of you before you fix the first one. Investigate all of them (steps 1–3
above, per red check), then land the fixes together. The reason is mechanical
rather than stylistic: `session-finalize` stamps `lastFullFinalizeSha` at the
HEAD it verified, and a commit made after that stamp moves HEAD past it — the
branch stops being merge-ready and `editor push` blocks with `Next valid action:
codeyam-editor editor session-finalize`. One fix per commit therefore buys one
whole finalize cycle per fix. Measured on `editor-improvements-76`: that loop
ran five times, 35–47 minutes each even with section 7's phase fingerprinting
skipping unchanged phases, for three fixes a single CI run had already reported
and that could have shipped in one commit.

**What a cycle actually costs, so the advice above is a price rather than an
exhortation.** On `editor-improvements-80` the same loop ran five times and cost
roughly **34, 85, 50, 87 and 50 minutes** — call it an hour a fix, with the
worst case near an hour and a half. Two things follow.

The spread is not noise, and it is the reason the cheap runs were cheap: phase
fingerprinting skipped the phases nothing had touched. On the 34-minute run,
Phase 1 reused **20 green partition caches** instead of re-running **35,841
tests**. So a batched fix set does not merely save you *n − 1* runs — it keeps
the runs it does cost in the cheap band, because a commit that touches one area
leaves the other phases' fingerprints intact. Interleaving unrelated fixes
across separate commits is what dirties every phase and prices each cycle at the
top of that range.

And an hour is long enough that the batching decision is worth making
deliberately *before* the first fix, not discovered at the second. When CI hands
you three failures, the choice is between roughly one hour and roughly four.

**The case batching cannot cover: a diagnose-then-fix loop.** The advice above
assumes CI handed you the complete failure list. Sometimes it cannot: the first
commit exists only to make a failure *visible* (upload a log artifact, add a CI
diagnostic step), and the fix is written from what that run reveals. The two
commits cannot share one finalize, because the second does not exist yet. On
`editor-improvements-94` that loop cost two whole re-stamp finalizes, ~45
minutes each, neither of which changed a single verdict. Two things now keep it
cheap — lean on them rather than fighting the ordering:

- **A commit touching only CI provider config re-proves only the static
  checks.** `.github/workflows/**` (and the other CI config locations) is linted
  by the static checks and read by nothing else a finalize runs, so the audit,
  the dependency-graph rebuild, and the screenshot guard keep their recorded
  passes across it, and the re-finalize re-stamps the marker after re-running
  the static checks and the cheap whole-tree guards — minutes, not the audit's
  ~45. Keep the visibility commit to CI config alone and it lands
  in that cheap band; mix a source edit into it and every phase that reads that
  source re-runs, as it must. The audit's skip still requires the static checks
  to have passed on the current tree, so a broken workflow edit cannot slip
  through on the audit's old pass.
- **The fix commit pays for what it touched, not for the whole branch.** Phase
  fingerprinting re-runs only the phases whose inputs moved; that is the
  mechanism the price above already reflects.

> GOTCHA — **the queue tenure does not survive the push.** Every re-finalize
> needs a fresh `codeyam-editor editor pre-commit-sync` first. The tenure claimed
> for the previous finalize was released when `editor push` completed, so
> `session-finalize` bails immediately with `Commit queue: finalize ran without
> holding the queue head`. That message says what it is — *"this is a recovery,
> not an error"* — so re-claim and re-run instead of investigating it as a
> failure.

**The flake bar — "flake" requires proof of non-determinism.** A check may be
labeled a flake ONLY when it **passed on a re-run with no code change**, OR it
**exactly matches a documented flake by test name AND failure signature**. A
check that fails on two consecutive runs with the same signature is **by
definition not a flake — it is a real bug. Fix it.** Build/compile errors and
assertion mismatches are never flakes.

**Documented flake family — the port/process TOCTOU.** A single test in the
real-port / real-process family (`port_reclaim` first-free, broker restart /
survival, reverse-proxy controller boot, a git-tree-oid `finalize_debt` check)
that fails in the ~21k-test parallel finalize Phase 1 but is **green via
`test-on-base` / in isolation**, with the *failing test rotating run-to-run*, is
this environmental family — a sibling test stealing a just-freed ephemeral port
in a bind→drop→reacquire window. Do NOT weaken the E2E assertion. Harden it
through `free_local_port_retry(|port| …)` (the bindable-direction helper beside
`unbound_local_port` in each crate's `test_net` / `test_support`), which retries
on a fresh port when the drawn one was stolen; new offenders are caught at
`verify-build` by the `test-port-races` static check. A *new* racy test the lint
flags is a real bug to fix now, not a flake.

**Settling "was this already failing?" — `test-on-base`, and when it cannot
answer.** `codeyam-editor editor test-on-base <test or file> --ref <base>`
re-runs the target in a throwaway checkout of the base and records the verdict,
so `inherited-failures --unsettled` stops re-reporting it. It shares the
project's installed dependency directories into that checkout (at the root and
at the runner's `workingDir`), and runs a single vitest/jest file by naming it
rather than through the runner's git-diff `--changed` mode, which selects
nothing in a clean checkout. When it still collects nothing for a target that exists on the base, it reports
**`COULD NOT RUN`** (exit `2`, nothing recorded) — the filter is right and the
checkout could not run the runner. Do not re-check the name. Settle it with the
two-read fallback instead: run the test directly in the working tree, and read
`git log <base>..HEAD -- <test file> <file under test>` to see whether this
branch touched either. A genuine **`NO MATCH`** is still the filter-miss answer.

**Clear `REGISTRY_HAS_FOREIGN_HOST_GATED_TEST` mechanically, never by hand.** A
test that gains a `#[cfg(target_os = …)]` / `#[cfg(unix)]` (or whose enclosing
module/file does) drifts its registry `platform_gate` from source and raises this
finding. The remedy is `codeyam-editor editor reconcile-registry --auto-apply`,
which now re-infers the source cfg for **existing** entries and rewrites a
disagreeing (or missing) gate in place — in either direction, including
*clearing* a stale gate when source verifiably declares no cfg — or
`backfill-platform-gates` for the fill-only bulk case (`None → Some`, never
overwriting a concrete gate). Do NOT hand-edit with a per-test
`register-test --platform-gate`; the finding's `fix_command` names the
mechanical path.

**It is mechanical, not unconditional — and it now tells you when it did
nothing.** The inference only trusts an entry whose recorded `line` still
points at the item its key names; a drifted line is declined rather than
stamped from a neighbouring attribute. So a run can legitimately repair zero
entries. It no longer hides that: each declined entry is printed with the
token it would have stamped, and the command exits **2** (not 0) when gate
drift was detected and none was repaired — a `fix_command` that exits 0
having changed nothing is indistinguishable from one that worked. Recover by
re-anchoring (`refresh-tests` re-derives `line` from runner output) and
re-running, or repair one entry with `register-test … --clear-platform-gate`.

### 8b. A squash merge must not inherit a plan commit's `[skip ci]`

A squash merge concatenates **every** branch commit message into the merge
commit's body, and GitHub Actions honors a skip token **anywhere** in that
message — not just on the subject line. So ANY branch commit carrying `[skip ci]`
— a plan commit made on `main` before the branch was cut, a cherry-pick, a
hand-written one — makes the default `gh pr merge --squash` land that token on
the primary branch and silently skip the entire `cicd` workflow for the merge
commit.

Nothing announces it. On 2026-08-09 PR #100 merged as `6baba063b` with no CI run
at all: no `codeyam-editor-binary:main-6baba063b` was published, no cloud image
was built, and `fleet-advance-to.sh`'s retag resolved its source to a tag that
exists nowhere — the newest `main-*` tag stayed ~130 commits stale.

**Compose the body explicitly, with the token stripped:**

```bash
gh pr view <n> --json body -q .body > /tmp/pr-body.md
bash scripts/lib/ci-skip-token.sh --strip < /tmp/pr-body.md > /tmp/pr-body.stripped.md
gh pr merge <n> --squash --body-file /tmp/pr-body.stripped.md
```

Use the script rather than a hand-written `sed`: it knows every token GitHub
honors (`[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]`,
`***NO_CI***`), and it avoids `sed -i`, whose in-place flag differs between BSD
and GNU — the merge is run from laptops and cloud VMs alike.

**Do NOT stop `/codeyam-plan` emitting `[skip ci]`.** The token is right on a
plan-only commit that targets `main`, which is the only case that emits it —
`/codeyam-plan` and `/review-session` both OMIT it on a branch, where it would
suppress the open PR's own run. The defect is it *escaping into a squash body*.

**That branch exception does not make the strip step above unnecessary.** It
narrows who emits the token, not who can carry one: a branch commit that picked
one up from any source must still not reach a squash body, so compose the merge
body with `ci-skip-token.sh --strip` regardless.

**After merging, confirm the merge commit actually got a run:**

```bash
codeyam-editor editor verify-primary-branch-ci
```

Exit `0` means a run exists. Exit `2` names the sha and the one command that
recovers it (`gh workflow run cicd --ref main`). A `gh` that cannot answer, a
non-GitHub remote, or a repo that defines no workflows at all reports
unknown/not-applicable and exits `0` — this check never turns a network hiccup,
or a project that simply has no CI, into a red gate.

---

## Cross-platform pitfalls

> **Cross-platform block** — active only when the branch carries
> platform-specific surface (multiple target OSes, conditional-compilation, a
> desktop crate, CI/container build files, OS-dependent networking/error
> classification). On a single-platform stack with none of these, this section
> is inert. `session-finalize` itself prints a cross-platform advisory only
> when it detects such surface.

A green local finalize on **one** OS does not prove the branch is CI-green when
it carries platform-specific surface. The categories to watch, and the concrete
footguns behind each (all observed in real CI-fix rounds):

- **Conditional-compilation code** (`cfg(target_os …)`, `cfg(windows)`, and
  equivalents). The other platform's branch never compiled on your host, so a
  dead-code/type error there fires only in CI. A cross-target compile/lint pass
  (`codeyam-editor editor cross-check`) re-evaluates every config for a
  cross-target triple locally, in seconds.
- **A desktop GUI member** (e.g. a Tauri crate). It links platform GUI
  libraries, so a change can break a headless workspace build in a GUI-less
  container though it is clean on a developer laptop. The CI/image build must
  also *copy* the desktop dir even when the build excludes it, or the image
  build breaks on a missing directory.
- **CI / container build files** (`.github/workflows/*.yml`, `Dockerfile*`).
  The build invocation itself changed; local build success says nothing about
  the CI or image build. The CI workflow is the authority on which invocations
  CI actually runs.
- **Networking error classification** (connect-vs-timeout, refused-vs-reset).
  Socket semantics diverge by OS: a connection to an unbound localhost port is
  *refused* (RST) on Unix but *times out* on Windows, and an HTTP response
  written without reading the request gets an RST on Windows. A classifier or
  assertion verified on one OS can misbehave on another.
- **Phase/error assertions bound to a platform-dependent message.** An
  assertion matching the exact text of an OS-specific error passes on the host
  that produces that text and fails elsewhere. Make errors name their phase
  explicitly rather than asserting on incidental wording.
- **Assertions against the raw spelling of a value the code escapes.** When
  production code escapes a path before emitting it (into TOML, JSON, a shell
  string, a URL), a test that builds its expectation from the path's raw
  display spelling passes on POSIX — no backslashes, so escaping is a no-op —
  and fails on Windows. Build the expectation through the same escaping helper
  the code uses. Fix the TEST: un-escaping the emitted value turns the test
  green by making the real output wrong.
- **The skipped-platform-test-job trap** — a *false* green. A CI matrix runs
  each platform's TEST job only after that platform's BUILD job succeeds. When
  the build fails (e.g. an unguarded `std::os::unix::*` in a test breaks the
  windows-gnu build with `E0433`), the dependent test job is **skipped** — so a
  matrix where every *run* job is green can have skipped a whole platform, and
  any pre-existing failures on that platform stay invisible. A green CI run is
  not proof a platform was exercised; a *skipped* build's tests never ran.

**MANDATE — when this surface is present, run the local repros BEFORE the first
push, not after CI tells you:**

- `codeyam-editor editor cross-check` — compile/lint every cross-target locally,
  in seconds. This is also now **enforced**: `session-finalize` runs the
  cross-target checks as a gating phase (Phase 4b) whenever it detects
  compile-affecting platform surface, and FAILS on a real cross-target
  compile/clippy error (missing toolchains SKIP with an install hint, never
  block). So the gate and this guidance reinforce each other — do not treat
  `cross-check` as optional when the branch touches platform surface.
- `codeyam-editor editor session-finalize --linux` — run the actual suite on
  Linux before merge, so a Linux-only test failure gates locally instead of in
  CI.

When a cross-target build fails, expect the skipped-platform-test-job trap:
finalize names it explicitly, and you must treat that platform's tests as
UNVERIFIED until the build is fixed and its suite actually runs.

---

## Report-only mode (the cheap, touch-nothing path)

When the user just wants "tell me what's misaligned, don't touch anything,"
run the report and stop:

1. **Summarize the debt.** `codeyam-editor editor finalize-debt show --format
   json` → the `deferred[]` list.
2. **Run the audit read-only.** `codeyam-editor editor audit --format json` →
   `failures[]` + `attribution[]`.
3. **Attribute and report.** Intersect each `attribution[].introducedIn` SHA
   with the `deferred[].sha` list. Group findings by the deferred commit that
   introduced them, present the grouped report, and **stop** — apply nothing.

This preserves the old report-only audit value (and its deferred-commit
attribution) as an explicit early-exit. The default headline path is the
aggressive align→finalize→present→merge-ready drive above.

---

## Reflect & self-improve (the last step every run)

After the branch reaches merge-ready (or the run stops at a judgment call), run
a **bounded, honest** reflection. The skill gets better every time it runs —
but it must never silently rewrite its own `SKILL.md`.

Enumerate the friction this run actually hit: every workaround you had to
invent, every GOTCHA that bit, every step whose guidance was stale or missing,
every CLI whose real behavior differed from this procedure. Then route each
genuinely-new, non-obvious lesson through one of two channels — never a silent
self-edit:

1. **Durable lesson → persistent memory** (ungated, auto-recalled). Write a
   memory file: one fact per file, update an existing file rather than
   duplicate, add the one-line index pointer, and skip anything already
   captured by the repo, this procedure, or an existing memory.
2. **Structural gap → a proposed plan/diff the user approves.** When the lesson
   is bigger than a memory — this procedure is wrong, a step is missing — draft
   a plan (or a concrete diff) against **this file**
   (`.claude/skills/codeyam-audit/finalize-procedure.md`) and surface it for
   approval. Because the change flows through the standard editor workflow, the
   skill never edits its own `SKILL.md` unseen.

If the run was clean, say **"nothing new learned"** and write nothing. Do not
manufacture busywork edits.

---

## See also

- `docs/fast-commit.md` — the deferred-tail mechanics this procedure finalizes.
- `docs/finalize-deferral.md` — `verify-no-deferred-finalize`, the deferred
  trailer, and the emergency-override audit trail.
