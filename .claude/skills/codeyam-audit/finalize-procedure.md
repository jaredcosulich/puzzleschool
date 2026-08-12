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

---

## 2. See the whole failure set at once — no fail-fast

Before fixing anything, get the *complete* list of what is broken, not the
first failure:

```bash
codeyam-editor editor audit --format json
```

Read every `failures[]` entry and the `attribution[]` array together. Group
findings by invariant id and by the commit that introduced them. Fixing blind,
one failure at a time, wastes finalize cycles — each full `session-finalize`
is the expensive loop you are trying to run *once*.

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
> **Size the wall with `editor finalize-preview`** — it reports the true
> comprehensive count that `verify-full-finalize` will block on. Do NOT size it
> with the mid-session `editor audit-gate` / `audit --findings-only` count: that
> one downgrades inherited debt and will **under-report** the obligation, which
> is exactly how a run gets mis-priced and then re-scoped in front of the user.
>
> This makes the stop-and-ask above *more* important, not less: the user is
> authorizing real, required spend. Quote them the `finalize-preview` number.

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
final images, and *before* the finalize (step 7) so the suite validates the
cleanup. For a branch built entirely via Fast Commit, the per-cycle finalize
bodies rendered terse (no polish), so this is where the repo finally polishes
before merge.

```bash
# Read-only: surface stale docs + non-essential debug logging. Never deletes.
codeyam-editor editor presentability-scan

# Refresh the README how-to + scenario gallery (idempotent).
codeyam-editor editor readme-sync
```

Then **assertively** remove the clearly-dead docs and debug log lines the scan
surfaces — but **ask the user about anything uncertain** before deleting it.
The scan only ever *lists* candidates; the judgment (and the deletion) is
yours, and deletion is a judgment call (step 4b): when in doubt, ask. The
step-7 finalize re-runs the suite, so a debug line a test asserted on will fail
there — revert that one removal and re-run.

> `session-finalize` also emits a self-contained presentability advisory naming
> these same two commands, so a client with no copy of this procedure is still
> covered.

---

## 7. Commit → finalize → the merge-ready gate

This is the one expensive loop; run it *once*, cleanly.

```bash
# Stop fast-intent so finalize stamps the real marker, not a deferred one.
codeyam-editor editor fast-commit-stop

# Integrate any sibling commits by MERGING (never rebasing) — see rule 0.
codeyam-editor editor pre-commit-sync          # claims the commit queue; --recover if it bails

# The full, whole-repo finalize. Stamps lastFullFinalizeSha.
codeyam-editor editor session-finalize 2>&1 | tee /tmp/codeyam-audit-finalize.log
```

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
message — not just on the subject line. Plan commits always carry `[skip ci]`,
correctly, because a plan file changes no source. So the default
`gh pr merge --squash` lands that token on the primary branch and silently skips
the entire `cicd` workflow for the merge commit.

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

**Do NOT stop `/codeyam-plan` emitting `[skip ci]`.** The token is right on the
original plan-only commit. The defect is it *escaping into a squash body*.

**After merging, confirm the merge commit actually got a run:**

```bash
codeyam-editor editor verify-primary-branch-ci
```

Exit `0` means a run exists. Exit `2` names the sha and the one command that
recovers it (`gh workflow run cicd --ref main`). A `gh` that cannot answer, or a
non-GitHub remote, reports unknown/not-applicable and exits `0` — this check
never turns a network hiccup into a red gate.

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
