---
name: codeyam-review-pr
user-invocable: true
disable-model-invocation: false
description: |
  Digest an incoming PR: every impacted scenario with before/after
  captures classified changed/unchanged/new, the tests it adds with
  their registry descriptions, its blast radius, a grounded narrative of
  what the PR actually does, and — as one section, not the headline — AI
  review findings and a codeyam-alignment check. Writes a local digest
  artifact and, on explicit confirmation, posts a rendered digest as a PR
  comment. Reviewing runs contributor code, so checkout is consent-gated.
---

# Digest and review an incoming PR

This skill turns an incoming contributor PR into a **digest** a maintainer
can actually absorb: what changed, which scenarios it moves, what it
proves, and what to worry about — evidence first, verdict second.

It is a thin, stable entry point. The full phased procedure lives in the
version-controlled sibling so it can evolve through normal review instead
of silent self-edits:

**Read `.claude/skills/codeyam-review-pr/review-procedure.md` now and
follow it.** Everything below is the contract; the procedure is the body.

## Contract

- **Digest-first, verdict-second.** Compute the impact map (impacted
  scenarios, uncovered surfaces, test delta, blast radius) *before* any
  review judgment, and lead the artifact with it. Findings are one section.
- **Running contributor code requires explicit consent.** Before any
  checkout, state plainly that reviewing will execute the contributor's
  code (tests, scenario capture) and ask. A static-only fallback digests
  the diff + context with no checkout, no after-captures, no test run.
- **Always return to the original branch.** Record the branch on entry and
  guarantee return on every exit path, including errors and aborts. The
  skill requires a clean working tree before it starts.
- **Read-only on git history; additive on `.codeyam/` only.** Never commit,
  amend, rebase, or push. Never edit the contributor's branch to "fix"
  alignment — alignment findings are reported, not applied.
- **Posting is human-gated.** The digest is written locally by default. A
  PR comment is posted only on explicit confirmation, via `gh`.
- **Stack-agnostic by construction.** Before/after pairs are promised only
  when `changed-surfaces` reports UI impact. For backend-only / CLI /
  library PRs the digest leads with tests-as-behavior-spec, data/state
  scenarios, and blast radius, and says so honestly.

## Preflight

Confirm the project is initialized for codeyam-editor:

```bash
codeyam-editor editor config-show >/dev/null 2>&1 || {
  echo "Project is not initialized for codeyam-editor. Run /codeyam-onboard first."
  exit 1
}
```

If it fails, tell the user to run `/codeyam-onboard` and stop. Then confirm
`gh auth status` succeeds — the PR metadata, checkout, and optional comment
all go through `gh`.

## Run

Work through `.claude/skills/codeyam-review-pr/review-procedure.md` top to
bottom. The artifact lands at `.codeyam/reviews/pr-<number>/review.json`
(plus `before/` and `after/` PNGs); re-running a review overwrites it.
