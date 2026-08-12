---
name: codeyam-onboard
description: Onboard a project to codeyam-editor — greenfield, legacy migration, or repair. Drives end-to-end autonomously and writes an onboarding report.
---

# CodeYam Onboard

You are running an **autonomous onboarding** of the current project to codeyam-editor. No per-phase confirmation prompts — drive through end-to-end, then write a single report the user can review.

## What "done" means

Two binary signals when you finish:

1. `codeyam-editor editor health-status --format json` returns `passed: true`.
2. `.codeyam/onboarding-report.md` exists and summarizes every translation decision you made.

If health-status fails, write the report anyway with the failing checks listed under "Pending" so the user knows what to do next.

## Phase 0 — Don't manually delete legacy state

If migration-status (phase 1) reports `legacy_artifacts` outside `.codeyam/`, `editor archive-legacy` will handle them. **Do not `rm` anything by hand** — the archive command is idempotent and moves everything (including `.claude/skills/codeyam-*`-named legacy directories and the legacy rules tree) into `.codeyam/_legacy/` with paths preserved. Manual deletion is unrecoverable; the archive is the safe path.

## Phase 1 — Assess

Run, **once**:

```
codeyam-editor editor migration-status --format json
```

The `schema` field tells you which branch:

- `none`    → **greenfield branch** (skip phase 2)
- `legacy`  → **legacy branch** (do phase 2 first)
- `modern`  → **repair branch** (skip phase 2; phase 3 is idempotent and will heal missing assets)

Save the full JSON output — you'll quote `missing_assets` and `legacy_artifacts` in the report.

## Phase 2 — Legacy translation (legacy branch only)

The old codeyam tool wrote `.codeyam/config.json` with a different schema. Translate the useful bits into a draft for the new `editor.json`, **then archive everything**.

1. Read `.codeyam/config.json`. Extract:
   - `projectSlug` / `projectTitle` → `project_name`
   - `projectDescription` → `project_description`
   - `webapps[0].startCommand` (or `.command + .args`) → translate to a single `start_command` string. For `sh -c "npm run dev -- --port $PORT"` use the inner command as-is — the new editor sets `PORT` from `editor.json:port` so `$PORT` resolves to the configured port at spawn time. If the project's port is fixed and unlikely to change, prefer the literal form (`npm run dev -- --port 3000`) — it reads cleaner to humans and is robust to env_builder regressions.
   - `webapps[].appDirectory`, `framework` → an entry in `apps[]` (existing config docs in the codeyam-editor source).
   - `screenSizes`, `defaultScreenSize` → carry over verbatim.
   - `provider` → carry over (defaults to `claude`).
   - `techStack` → informational only; mention in the onboarding report but do not write into `editor.json`.
2. Run:
   ```
   codeyam-editor editor archive-legacy
   ```
   This moves `config.json`, `editor-scenarios/`, `db.sqlite3*`, `llm-calls/`, `rules/`, `proxy-config.json`, `server.json`, `queue.json`, `tmp/`, `bin/`, `editor-mode-context.md`, `design-system.md`, `data-structure.json`, `seed-adapters/`, `seed-adapter.ts`, and the legacy `glossary.json` into `.codeyam/_legacy/`. Re-runs are safe.
3. **Translate the archived legacy scenarios (phase 2b).** The legacy `editor-scenarios/` files use UUID filenames + `_metadata` wrappers, a different shape than the new schema. Translate them in place rather than asking the user to re-register hundreds of scenarios by hand:
   ```
   codeyam-editor editor translate-legacy-scenarios --dry-run
   ```
   The dry-run prints a summary (`translated`, `skipped`, `failed`) plus a per-scenario report. Show the user the summary, then ask: "Translate now (recommended)" / "Skip — leave legacy scenarios in `_legacy/` for manual review" / "Cancel and inspect the report first." On the run path, drop `--dry-run` and re-execute. The report at `.codeyam/translation-report.json` lists every translated scenario, every skip (with reason: `ambiguous-type` / `component-not-found` / `missing-name`), and every failure. Fold the `skipped` and `failed` rows into the onboarding report so the user has a single artifact summarizing what needs manual triage.

   After `translate-legacy-scenarios` completes, run:

   ```
   codeyam-editor editor translate-legacy-browser-state
   ```

   This populates each translated scenario's `browserState.cookies` from the legacy `sessionCookies` data and merges legacy `externalApis` into the new scenario's `mocks.http` (where not already present). Auth-required scenarios (anything behind a login wall) NEED this — without it, the iframe loads without cookies and the app redirects to login. Idempotent; safe to re-run. The report at `.codeyam/browser-state-translation-report.json` lists every migrated / skipped / failed scenario plus the auto-generated `_default-authed` tier (if any). Fold the summary line into the onboarding report.

   The seed adapter writes live JWTs to `.codeyam/tmp/seed-session.json` at seed-time; the proxy overlays those over the scenario's static cookies (10-minute freshness gate). Static cookies (from this translation step) are the fallback; the adapter's fresh values win when present.
4. **Repair stack layout (phase 2c).** Legacy projects ship `.codeyam/editor.json` but no `.codeyam/stack.json`, and the legacy `app/codeyam-isolate/` scaffold tree sits next to the modern `app/isolated-components/` tree. Without stack.json, the App tab fills with phantom routes. Phase 2c is **unconditional** on the legacy branch — run it even when its commands turn out to be no-ops, and always emit the report section so the user can see what happened. Before running, check that `editor.json:apps[]` is populated; if it is empty, back up to Phase 4 to populate it first, then return here.

   1. `codeyam-editor editor stack-from-apps` — writes `.codeyam/stack.json` from `editor.json:apps[].framework`. If the framework is unsupported the command bails with the known `--stack-id` values; re-run with `--stack-id <id>` (e.g. `nextjs-prisma-sqlite`) or ask the user.
   2. `codeyam-editor editor migrate-isolation-dir --dry-run` — prints the planned `moved` / `collisions_archived` / `unresolved` rows. Show the user the JSON and ask: "Apply (recommended)" / "Cancel and inspect first." On approval, re-run without `--dry-run`. Fold the resulting JSON (especially `collisions_archived`) into an "Isolation layout cleanup" section of the onboarding report. When `moved: []` and `removed_legacy_dir: false` (the project is already on the modern layout — Margo's case), the report section still gets written, recording "no changes — project already on modern layout".

## Phase 3 — Install (all branches)

```
codeyam-editor init
```

Note: `init` is a **top-level** subcommand, not under `editor`. If the user already ran `init` before invoking this skill (recommended path post-bootstrap-fix), `init` was idempotent — re-running it here is safe and just confirms the bundle is in place. On legacy projects, `init` deliberately skipped creating `editor.json` so this skill's Phase 1 classification stayed `legacy`; Phase 3 lets the legacy branch create `editor.json` after Phase 2 archived the legacy config.

This is mechanical and idempotent — installs `.claude/hooks/`, `.claude/skills/`, `.claude/settings.local.json`, `.codex/config.toml`, `.git/hooks/pre-commit`, and auto-detects a seed adapter (Prisma and Supabase are supported out of the box).

After it runs, read the current `.codeyam/editor.json`. If it has placeholder values (`start_command: ""`, no `apps[]`, missing `port`), proceed to phase 4. If you already drafted values in phase 2, merge them in now via Edit.

### Journal migration check (all branches)

After `editor init` runs, run:

```
codeyam-editor editor migrate-journal --format json
```

Idempotent and fast. On a modern project with `entries/` already populated, it returns `{"migrated_entries": 0, "pre": {"index_present": false, ...}, "result": "ok"}` in milliseconds. On a project shipping the older `{"entries":[...]}` envelope or pre-rename field names (`time` / `userPrompt` / scenarioScreenshot `path`), it converts everything into the per-entry `entries/<timestamp>.json` layout and removes `index.json`. Capture the JSON for Phase 7's report — the `pre.legacy_envelope` / `pre.legacy_field_names` / `pre.archive_shards` / `migrated_entries` numbers tell the user what was rewritten and how much.

If `migrate-journal` returns a non-zero exit (a malformed entry the lenient reader can't recover), surface its stderr verbatim into Phase 7's Pending section and recommend the user inspect `.codeyam/journal/index.json` by hand. The onboarding report is still written; Phase 6 health-status will surface `journal_readable: failed` until the journal is fixed.

### Adapter-template upgrade check (legacy + repair branches)

After `editor init` runs, if `.codeyam/seed-adapter.ts` already existed before init (typical for legacy / repair branches), check whether it carries the `// codeyam-adapter-version: N` marker. If the marker is missing or its `N` is less than the shipped current version, run:

```
codeyam-editor editor refresh-seed-adapter
```

The command compares the installed file against the shipped template + known prior versions. If the file is recognised (pristine prior version or matches the current shipped content), it upgrades automatically with no prompts. If it has been hand-edited, the command refuses and prints the `--force --accept-data-loss` re-run instruction. When the safe path doesn't apply, **surface the diff and refusal message to the user — do not pass `--accept-data-loss` autonomously.**

Every overwrite backs the previous content up to `.codeyam/seed-adapter.ts.pre-refresh-<timestamp>` first — the automatic upgrade as much as the forced one — so a refresh is always recoverable by diffing against that file. The only overwrite without a backup is one where the content was already byte-identical.

## Phase 3b — Install project dependencies (all branches)

If the project has a `package.json` AND (`node_modules/` is missing OR a direct dep listed in package.json isn't resolvable), run the project's package manager install command. Detect the manager from the lockfile:

- `package-lock.json` present → `npm install`
- `pnpm-lock.yaml` present → `pnpm install`
- `yarn.lock` present → `yarn install`
- `bun.lockb` present → `bun install`
- No lockfile → `npm install` (most projects' default)

In the **legacy branch**, dependencies are almost always stale relative to the post-migration codebase — always run install in this branch, even if `node_modules/` looks superficially present (the post-migration code may reference new deps).

For non-Node stacks (no `package.json`): if `stack.json` indicates a Rust / Python / Ruby project, suggest the user run `cargo build` / `pip install -r requirements.txt` / `bundle install` and continue past the install step. The plan for stack-aware install is a future follow-up; today, recommend and proceed.

## Phase 4 — Populate editor.json

Read the project's actual layout and fill in the holes. The agentic work lives here — be specific, not generic.

Inspect:
- `package.json` (scripts, framework dep) — `next` / `vite` / `astro` / `expo` / `remix` / etc.
- Framework markers (`next.config.*`, `vite.config.*`, `Cargo.toml`, `pyproject.toml`, `Gemfile`).
- App directory (`app/`, `pages/`, `src/`, `crates/`).
- README, top-level routes, glossary leftovers.

Fields to populate when missing:
- `project_name`, `project_description` (synthesize from README + package.json description + routes).
- `start_command` — match the project's `dev` script. For Next: `next dev --turbopack` or `npm run dev -- --port 3000` (literal port form — recommended when the project's port is stable). The shell-expansion form `npm run dev -- --port $PORT` also works: the editor sets `PORT` in the child env from `editor.json:port`, so `$PORT` resolves at spawn time. Prefer the literal form by default — it reads cleaner to humans and survives env_builder regressions.
- `port` — pick the project's customary dev port (Next defaults to 3000; Vite 5173).
- `apps[]` — at minimum one entry: `name`, `dir` (typically `.` for a single-app repo), `type: "web"`, `port`, optional `start_command` overrides.
- `test_runners[]` — derive from `package.json` scripts. Concrete vitest example:
  ```json
  {
    "name": "vitest",
    "command": "npx vitest run --reporter=json",
    "match": ["ui/**/*.test.ts", "ui/**/*.test.tsx"],
    "outputFormat": "vitest-json"
  }
  ```

  > **Reporter pair is load-bearing.** The vitest adapter only parses JSON. Pairing `--reporter=verbose` with `outputFormat: vitest|vitest-json` fails validation at config-load; pairing `--reporter=json` with anything else means the editor can't parse the output. Use `--reporter=json` + `outputFormat: vitest-json` for vitest, and `--json` + `outputFormat: vitest-json` for jest.

  > **Cargo runners must carry `--no-fail-fast`.** For a Rust/cargo runner, include `--no-fail-fast` (on the cargo side, before any ` -- ` separator) in **all four** command variants — `command`, `coverageCommand`, `changedCommand`, and `targetedCommand`. Without it, a single failing test halts `cargo test` and silently drops every *subsequent* crate's test capture, which the editor then mis-reads as deleted tests and phantom audit findings. Example base command: `cargo test --no-fail-fast --workspace`. (`codeyam-editor editor configure-test-commands` proposes the flag for any cargo command that's missing it.)
- `static_checks[]` — at minimum `tsc --noEmit` for TS projects; `eslint` if configured.
- `formatters[]` — `prettier` if configured.
- `screen_sizes`, `default_screen_size` — carry from legacy if present; else `{Desktop: 1440x900, Mobile: 375x667}`.

**Capability check (before you write `apps[]`).** Once you've detected the framework, run `codeyam-editor editor stack-support --framework <detected> --format json` (add `--app-type backend|cli` for non-web projects). Relay the verdict to the user before writing editor.json:
- `supported` / `fallback` — proceed; visual preview and scenario capture will work (fallback adapts the query-param isolation strategy).
- `unsupported` — state plainly which codeyam features are off (isolation scaffold, visual preview, scenario capture) and that editor.json + the test workflow still work, so the user decides with eyes open instead of hitting a dead end at isolate-time. Don't run `editor isolate` for an unsupported stack.

Write the changes via Edit on `.codeyam/editor.json`. Do **not** overwrite the whole file — preserve fields written by `editor init`.

## Phase 4b — Index the code (all branches)

By the end of this phase the editor UI is functional. Without it, the App tab fills with phantom routes and entity detail pages show zeros. Three commands; each is idempotent and safe to re-run.

1. **Dependency graph.** Required by the entity-detail page's "components used" list.

   ```
   codeyam-editor editor analyze-imports
   ```

   Reports `analyzed`, `entityCount`, `graphSize`, `totalImports`. Write the JSON summary into the report's "Code index" section.

2. **Glossary.** Required by the App tab's components/functions enumeration and by the audit gate. Auto-applies the unambiguous adds (entities with `///`/JSDoc + an auto-derivable test file); the rest land as skips with reasons.

   ```
   codeyam-editor editor reconcile-glossary --auto-apply
   ```

   Capture the `added` count and the full `skipped` list. Surface the skips in the report's Pending section as "Glossary entries needing manual `glossary-add`" with their file paths and reasons (`no /// rustdoc or JSDoc` / `no test file could be auto-derived`).

3. **Test registry.** Required by entity-detail page "tests for this function" and the audit's coverage check.

   ```
   codeyam-editor editor bootstrap-registry
   ```

   Self-warms the test cache via `refresh-tests --force` if cold. Long-running on large projects (a few minutes for ~400 tests). Capture the entries-written count. If `bootstrap-registry` fails (e.g. a project test was already broken before onboarding), the failure is **not** silently swallowed — propagate the full stderr to the report's Pending section, recommend the user fix the failing test, then re-run `editor bootstrap-registry` manually. Onboarding still completes (Phase 6 health-status will catch the missing registry as a hard fail until it's fixed).

Run all three even on a repair branch — they're idempotent, and a project that arrived at the repair branch may be missing them.

## Phase 5 — First scenarios

Two goals: (a) prove the registration pipeline works on this project, (b) leave the user with a non-empty starting point.

1. Identify ≤5 high-value scenarios:
   - The home/landing page.
   - Top 1–2 most-prominent components (look at imports across the app directory).
   - One auth or data-loaded page if applicable.
2. For each, register it. Component scenarios use isolation routes; application scenarios use real URLs. The exact invocation is:

   ```
   # write the scratch file first
   cat > .codeyam/tmp/register-home-<unique>.json <<'EOF'
   { "slug": "home", "kind": "application", "url": "/", "screen_size": "Desktop" }
   EOF
   codeyam-editor editor register --file .codeyam/tmp/register-home-<unique>.json
   ```

   `register` deletes the scratch file on success. Do NOT reuse the same filename across calls — each invocation needs a unique path.
3. If the dev server is running, attempt capture via `codeyam-editor editor recapture-stale --skip-when-clean --prefer-touched` (`--prefer-touched` orders the scenarios you just registered first so the budget captures them before any unrelated environmentally-drifted surface; pure reordering, never expands the set). If not running, skip and note it.

This phase is **best-effort**. If registration fails on a specific component, log it in the report and continue — do not block the whole onboarding on one bad scenario.

## Phase 6 — Verify

```
codeyam-editor editor health-status --format json
```

Capture the JSON. The report has **three** check arrays: `static_checks`, `smoke_checks`, and `functional_checks`. `passed: true` requires every check across all three to pass. Common causes (and the right fix):

- **Static layer**
  - `editor_json_parses` failed → your phase 4 edits broke JSON. Re-read, fix, re-run health-status.
  - `asset_present` failed → re-run `codeyam-editor init` once; if still failing, log it.
- **Smoke layer**
  - `dev_server_reachable` failed → user hasn't started the dev server. Note in report, don't fix.
  - `scenario_registered` failed → phase 5 produced nothing. Document why in report.
  - `journal_readable` failed → run `editor migrate-journal --format json` and inspect the JSON output. If it surfaces a malformed entry, fix `.codeyam/journal/index.json` by hand (see the marker file at `.codeyam/journal/.migration-failed.json` for the exact error and the failing entry index).
  - `dependencies_installed` failed → `node_modules/` missing or stale relative to `package.json`. Re-run Phase 3b (lockfile-driven install). If it still fails after install, the project may have an unusual setup (workspaces, postinstall scripts) — note in the report.
  - `clean_settings` failed → `.claude/settings.local.json` carries dead skill permissions or stale hook entries from a prior tool version. Run `codeyam-editor editor scrub-settings` (dry-run) to see findings; if everything reported is safe to remove (dead skills, stale hooks — never plaintext credentials), ask the user, then run `codeyam-editor editor scrub-settings --apply`. Plaintext-credential lookalikes flagged by scrub-settings are **never** auto-removable — surface them in the report and tell the user.
- **Functional layer** (new — these are blocking)
  - `workflow_manifest_parses` failed → `.codeyam/workflow.json` is missing or malformed. Re-run `codeyam-editor init`.
  - `agent_provider_on_path` failed → the configured agent CLI (`claude` / `codex` / `gemini`) isn't installed. The user has to install it; surface this in the report.
  - `start_command_runnable` failed → `editor.json:start_command` is empty or references a binary not on PATH. Fix `start_command` in `.codeyam/editor.json` (this is the typical "init scaffolded with `start_command: ""` then phase 4 never filled it in" case).
  - `seed_adapter_runnable` failed → `.codeyam/seed-adapter.ts` exists but `npx` isn't on PATH; the user needs Node.js.

Phase 6 is allowed to retry phase-3 init once, and may run `scrub-settings --apply` once after user confirmation. Don't loop.

If `$HOME/.codeyam/notify.env` does not exist, suggest `codeyam-editor editor notify-setup --topic <claude-$(whoami)-$(openssl rand -hex 4)>` once and continue. Don't block onboarding on it — the notify hooks are pre-installed and silently no-op until the developer opts in.

## Phase 7 — Write the report

Write `.codeyam/onboarding-report.md` with these sections:

```markdown
# CodeYam Onboarding Report

**Project:** <name>
**Branch taken:** greenfield | legacy | repair
**Started:** <ISO timestamp>
**Completed:** <ISO timestamp>

## Translation decisions
(legacy branch only: every field you mapped from .codeyam/config.json to .codeyam/editor.json, with before/after values)

## Archived to .codeyam/_legacy/
(list from `archive-legacy` output, with one-line note per item if non-obvious)

## editor.json — what you populated
(diff-style summary: which fields you filled in, what you inferred from)

## Code index
- `dependency-graph.json` — N files analyzed, M entities, K imports
- `glossary.json` — A entries auto-added, S skipped (see Pending for full skip list)
- `test-registry.json` — T entries across R runners

If any of these are zero, the editor UI for this project will not show components / functions / tests until the gap is filled. Phase 6 health-status confirms whether the indexes are non-empty.

## Journal migration
- `migrate-journal` result: ok | failed
- Pre-migration shape: modern | legacy-envelope | legacy-field-names | mixed
- Entries migrated: N (of M total in `entries/`)
- Archive shards: K

## Isolation layout cleanup
(legacy branch only: stack.json framework + the `moved` / `collisions_archived` / `unresolved` summary from `migrate-isolation-dir`. When the project was already on the modern layout, record "no changes — project already on modern layout".)

## Scenarios registered
(slug, type, URL, captured yes/no)

## Health checks
(paste health-status JSON, then plain-English summary)

## Pending / known gaps
(anything you noticed but didn't fix — explicit so the user can decide. Two specific categories Phase 4b feeds in here:
- Glossary entries skipped by `reconcile-glossary --auto-apply`, listed with their file paths and the reason (`no /// rustdoc or JSDoc` / `no test file could be auto-derived`) and the `glossary-add` invocation per entry.
- Per-runner failures from `bootstrap-registry` (full stderr verbatim) plus the recommended fix.)
```

## Constraints

- **Do not commit.** Write files and leave them uncommitted; the user decides when to commit.
- **Do not start the dev server.** If it's not running, phase 6 will note it; that's fine.
- **Do not edit `.codeyam/_legacy/`** after archiving — it's a frozen reference.
- **One log line per phase boundary** so the user can follow progress. Skip narration during a phase.
- **No tests written during onboarding.** Test registration is part of the per-feature workflow, not this skill.
