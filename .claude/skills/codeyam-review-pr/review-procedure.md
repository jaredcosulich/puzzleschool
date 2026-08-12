# Incoming PR digest & review — procedure

Follow these phases top to bottom. The goal is a **digest**: the maintainer
understands the change first and judges it second. Every phase reuses
existing stack-agnostic `codeyam-editor editor` commands — you are grounding
Claude's judgment in codeyam evidence, not inventing a new review engine.

The canonical artifact is `.codeyam/reviews/pr-<number>/review.json`, with
`before/` and `after/` PNG subdirectories. The `gh` comment markdown is
rendered *from* that JSON at post time, so there is no second stored format
to drift.

---

## Phase 1 — Preflight

1. Confirm a git repo and that `gh auth status` succeeds.
2. Identify the PR. Accept a number or URL:
   ```bash
   gh pr view <number-or-url> \
     --json number,title,author,headRefName,baseRefName,url
   ```
3. Require a **clean working tree** (`git status --porcelain` empty). If
   dirty, stop and ask the user to commit or stash — the skill checks out
   the PR in place and must be able to return cleanly.
4. Record the original branch (`git branch --show-current`). You will return
   to it on every exit path.

## Phase 2 — Consent gate

Reviewing runs the contributor's code. Present three choices via
`AskUserQuestion`:

- **Full digest** — checks out the PR and runs its tests + scenario capture.
- **Static-only** — digests the diff + context with no checkout, no
  after-captures, no test run. Choose this when the user won't run
  untrusted code.
- **Abort.**

Do not check out anything until the user picks Full.

## Phase 3 — Checkout + impact map (Full only)

1. `gh pr checkout <number>`.
2. Compute the merge-base: `git merge-base <baseRefName> HEAD`.
3. Impacted-scenario set (the digest's backbone) — the tiered resolver, not
   the diff alone:
   ```bash
   codeyam-editor editor scenario-for-changes --diff-from <merge-base> --format json
   ```
   This tiers own-source-changed → route-renders-changed-page → transitive
   import-graph dependency, so the digest includes scenarios the contributor
   never thought about.
4. Uncovered surfaces:
   ```bash
   codeyam-editor editor changed-surfaces --base <merge-base> --format json
   ```
   Covered / uncovered / no-UI-impact buckets. The uncovered bucket is where
   you propose new `pr-review-` captures.
5. Blast radius: `codeyam-editor editor deps-query` subcommands over the
   changed files (transitive dependents).
6. Test delta with descriptions — diff `.codeyam/test-registry.json` between
   merge-base and head:
   ```bash
   git show <merge-base>:.codeyam/test-registry.json > /tmp/registry-base.json
   ```
   Compare against the working-tree registry to list the tests the PR
   **adds/changes with their parsed descriptions** — they read like a
   behavior changelog.
7. Glossary lookups (`codeyam-editor editor glossary-find <name>`) for
   touched entries, so findings can name the entry that should have been
   reused.

## Phase 4 — Before extraction (Full, UI-impacting)

For each impacted scenario with a committed capture, extract the
merge-base PNG **without a base checkout**:

```bash
git show <merge-base>:<screenshotPath> > .codeyam/reviews/pr-<number>/before/<slug>.png
```

If the capture was already stale at the merge-base (per scenario-coverage
staleness semantics), set `beforeStale: true` on that scenario in the
artifact — do not silently compare against a stale frame.

## Phase 5 — After captures (Full, UI-impacting)

1. Navigate each covered impacted scenario and capture on the PR head:
   `codeyam-editor editor preview-nav` then the capture path.
2. For high-value **uncovered** surfaces from Phase 3, register scenarios
   with a `pr-review-` slug prefix (surgical teardown, exactly like
   `recent-change-` in `/codeyam-see-recent-change`) and capture them.
3. `codeyam-editor editor recapture-stale --skip-when-clean --prefer-touched` to
   refresh what the edit actually moved — `--prefer-touched` orders the
   PR-touched surfaces first so the budget captures them before any unrelated
   environmentally-drifted screenshot (pure reordering, never expands the set).
4. Copy the resulting PNGs into `.codeyam/reviews/pr-<number>/after/`.

**Backend-only / CLI / library PRs:** skip this phase. Record the change in
the no-UI-impact bucket honestly — the digest will lead with tests and blast
radius instead of before/after pairs.

## Phase 6 — Classification (Full, UI-impacting)

For each before/after pair:

```bash
codeyam-editor editor image-diff <before.png> <after.png> --format json
```

→ `{classification: changed|unchanged, diffRatio}`. Record it on the
scenario. A scenario with an after-capture but no before is `new`. Note
`unchanged` is real signal — "this PR touches the checkout flow and these
four downstream scenarios rendered identically" is exactly what makes a PR
digestible.

## Phase 7 — Tests

```bash
codeyam-editor editor refresh-tests --changed
```

Runs only the runners the diff touches. Join the totals-per-runner with the
Phase 3 registry diff so the digest shows both *what ran green* and *what
new behavior the tests describe*.

## Phase 8 — Narrative digest + review

1. Write "what this PR actually does" grounded in the impact map:
   per-scenario impact notes, tests-as-behavior-spec, blast-radius summary.
2. Then findings. Every `blocker`/`concern` cites a concrete file/line; a
   reuse-miss names the glossary entry that should have been reused. Use
   `praise` for genuinely good moves — the digest is for a maintainer
   deciding whether to merge, not a gauntlet.

## Phase 9 — Alignment (report-only)

```bash
codeyam-editor editor audit --format json
```

on the PR head. Summarize the findings the PR *introduces* relative to
base. A contributor who didn't maintain the registry is an alignment
finding (surface the `reconcile-registry` diff output, never
`--auto-apply`), not a blocker. **Never fix the contributor's branch.**

## Phase 10 — Write artifact

Write `.codeyam/reviews/pr-<number>/review.json`:

```jsonc
{
  "pr": { "number", "title", "author", "url", "baseRef", "headRef", "mergeBase" },
  "narrative": "<markdown: what this PR does>",
  "scenarios": [
    { "slug", "status": "changed|unchanged|new",
      "beforePath?", "beforeStale?", "afterPath", "diffRatio?", "note" }
  ],
  "tests": { "byRunner": { "<runner>": { "passed", "failed" } },
             "added": [ { "name", "description", "file?" } ] },
  "blastRadius": { "changedFiles": [...], "transitiveDependents": [...] },
  "findings": [ { "severity": "blocker|concern|nit|praise", "file", "line?", "comment" } ],
  "alignment": { "summary", "introducedFindings": [...] },
  "postedCommentUrl": null
}
```

Print a chat summary that **leads with the impact map**, then tests, then
findings.

## Phase 11 — Optional post (human-gated)

Render digest markdown *from* `review.json`, show it, and only on explicit
confirmation:

```bash
gh pr comment <number> --body-file <rendered.md>
```

Record the returned comment URL back into `review.json` (`postedCommentUrl`).

## Phase 12 — Teardown

The follow-up editor screen's live walkthrough works while the PR is still
checked out. So **before** teardown, offer: "stay on the PR branch for a
live walkthrough" vs "tear down now".

When the user is done:

1. Remove the `pr-review-`-prefixed scenarios you registered.
2. Return to the original branch (recorded in Phase 1).
3. Confirm the working tree is clean.

Idempotent: re-running the review overwrites
`.codeyam/reviews/pr-<number>/`. `.codeyam/reviews/` is gitignored — the
durable public output is the posted comment, not the local artifact.
