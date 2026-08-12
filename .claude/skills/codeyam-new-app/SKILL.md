---
name: codeyam-new-app
description: >-
  Scaffold a brand-new codeyam-native app inside an EXISTING repo — in its own
  subdirectory, registered as a second apps[] entry, optionally sharing the
  repo's existing database. The "build something new the codeyam way, against
  real data" onramp. Isolated so it cannot destabilize the existing app, with
  the full scenario + preview + TDD loop from line one.
---

# CodeYam — New Companion App in an Existing Repo

You are helping the user add a **brand-new app** to an existing repository the
codeyam way: greenfield scaffold + scenarios + live preview + TDD, but pointed
at the data the team already has. The new app lives in its **own
subdirectory** with its **own `apps[]` entry**, so it has *zero blast radius* —
the existing app is never touched.

This is the right onramp when retrofitting the existing app would be a poor fit
(see `editor assess`) but the team still wants codeyam's full strength on a new
surface.

## The one command that does the work

```bash
codeyam-editor editor scaffold-app --into <subdir> --stack <stack-id> [--name <name>] [--share-db] [--port <n>]
```

It validates everything **before writing anything** (unknown stack, colliding
subdir, or an unsatisfiable `--share-db` all fail loud with nothing on disk),
then: extracts the chosen stack template into `<subdir>/`, registers a second
`apps[]` entry in `.codeyam/editor.json` (appended — the existing entries are
preserved verbatim), and wires persistence per `--share-db`.

## Flow

1. **Understand the new app.** Ask the user a one-line description of what the
   new app is. Keep it short — it drives the stack recommendation.

2. **Recommend a stack.** Run `codeyam-editor editor stacks-recommend --format json`
   against the description and present the top recommendation (and 1–2
   alternatives) to the user. Confirm their pick — this becomes `--stack`.

3. **Decide on the database.** Check whether the repo has a database codeyam
   can share (Prisma SQLite/Postgres, Supabase Postgres, or Drizzle
   SQLite/Postgres are auto-detected). If it does and the new app should use
   the same data, pass `--share-db` so the companion talks to the existing
   schema. If the repo has no supported database, or the new app should own its
   own state, omit `--share-db` for a standalone scaffold. Never invent a
   database — if `--share-db` can't be satisfied the command tells the user
   exactly what is supported.

4. **Pick a subdirectory.** Confirm a dedicated `--into <subdir>` that does not
   collide with an existing app's directory. `.` is rejected (it would clobber
   the existing app).

5. **Scaffold.** Run the command. On success it prints the new app's subdir,
   stack, chosen port, and whether the DB was shared.

6. **Hand off to the build loop.** The new app is now a first-class `apps[]`
   entry. Switch to it in the editor and build features against it with the
   normal `/codeyam-editor` workflow — scenarios, live preview, and tests all
   work immediately.

## Guardrails

- **Isolation is the safety story.** The companion lives in its own subdir with
  its own `apps[]` entry. Do not edit the existing app's source or its
  `editor.json` entry — the scaffold is purely additive.
- **Stack-gated, fail loud.** If the requested stack or `--share-db` can't be
  satisfied, surface the command's actionable error to the user verbatim rather
  than working around it.
- **Reuse, don't reinvent.** This command builds on the same template / stack /
  seed-adapter machinery as a top-level scaffold, so the companion's config
  matches what a fresh project of that stack would get.
