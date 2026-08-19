# Content Management Setup

This site stores content as typed markdown in `src/content/`. A browser-based
editing UI is wired in at **`/admin`**. It commits markdown straight to your
content collections, so editors never touch code and the static-hosting model is
unchanged: GitHub Pages still serves plain HTML, and codeyam can still seed the
same files per scenario through the `content-collection` seed adapter.

## The admin app

The dashboard is **injected from `node_modules` by the `codeyamCms()` Astro
integration** in `astro.config.mjs` — there are no admin files in this repo to
maintain, and `npm update @codeyam/cms` picks up improvements. It builds to
static routes under `/admin` like any other page, so it works on GitHub Pages
with no server.

> The package can optionally scaffold a Decap/Sveltia bridge at `public/admin/`
> (`npx codeyam-cms integrate --with-sveltia`). **This project does not use it** —
> there is no `public/admin/`, and no `config.yml`. Ignore Sveltia/Decap docs;
> the fields the dashboard renders come from `src/data/collections.json` (below).

## Configuration — `src/data/cms.json`

```json
{
  "repo": { "owner": "jaredcosulich", "repo": "puzzleschool", "branch": "main" },
  "siteUrl": "https://puzzleschool.org/",
  "authEndpoint": "/auth",
  "auth": { "token": true, "worker": false }
}
```

- **`repo.branch` must be the branch that actually deploys** (`main` — see
  `.github/workflows/deploy.yml`). Point it at a non-deploying branch and the CMS
  keeps reporting successful saves for edits that can never go live.
- **`siteUrl` is required here because this site uses a custom domain.** Without
  it the CMS assumes `https://<owner>.github.io/<repo>/`. That URL does redirect
  to `puzzleschool.org`, but the redirect carries no `Access-Control-Allow-Origin`
  header, so the admin's cross-origin fetch of `/deploy-status.json` fails and
  publish verification silently degrades to "unverifiable". Same-origin, it
  actually confirms a change went **Live**.

## Signing in

**Token (what this project uses).** `auth.token: true` — an editor pastes a
GitHub token at `/admin` and it is stored only in their own browser's
`localStorage`. Nothing is deployed, and **no credential ships in the build**.
Anyone can load `/admin`, but committing requires a token with write access to
this repo, so the gate is GitHub's own permissions.

Editors should create a **fine-grained personal access token** at
<https://github.com/settings/personal-access-tokens/new>, scoped to **only this
repo** with **Contents: Read & Write**.

**Worker (scaffolded, currently off).** `cms-auth-worker/` holds a Cloudflare
Worker giving a shared-password or "Sign in with GitHub" popup instead. It is
**not deployed and not in use** (`auth.worker: false`) — nothing needs to run for
the CMS to work today. To enable it, deploy the Worker, set its secrets, and flip
`auth.worker` to `true`. Note the trade-off documented at the top of
`cms-auth-worker/worker.js`: every editor commits as one shared identity, with no
per-user attribution.

## Keeping the schema honest

Two files describe the same markdown and must stay in sync:

- **`src/content.config.ts`** — the Zod schema. The build validates against it,
  and a Zod object **strips keys it does not declare**, so a field missing here is
  silently thrown away rather than failing loudly.
- **`src/data/collections.json`** — the field registry the admin UI renders
  (`builtins.pages` for the `pages` collection: label, type, `optional`, hint).

When you add a content field, add it in **both**. A field in the schema but not
the registry is invisible to editors; a field in the registry but not the schema
is discarded on the next build.

Mark optional fields consistently: `.optional()` in `config.ts` ↔
`"optional": true` in `collections.json`.

## Publishing

Edits commit to `repo.branch` (`main`), which triggers
`.github/workflows/deploy.yml`. The build writes `deploy-status.json` carrying
the commit SHA and run id; the admin polls it to report a change as **Live**.

## Developing against a local codeyam-cms checkout

To test unreleased `@codeyam/cms` changes here instead of the published package:

```sh
npm run dev:cms     # link the local checkout, then start dev against it
npm run cms:unlink  # go back to the published package
```

Register the checkout once with `npm link` from `codeyam-cms/packages/cms`;
after that `dev:cms` links it here and starts the dev server. There is no CMS
build step — the link *is* the build.

Since `@codeyam/cms@0.9.0` that last part takes one line of config to stay true.
The package now ships half of itself prebuilt: `./components/*`, `./layouts/*`,
`./pages/*`, `./styles/*` and `./content` are still raw `.ts`/`.tsx`, but `.`,
`./lib/*`, `./client/*` and `./server/*` resolve to a compiled `dist/`. Left
alone, a linked checkout would serve that stale `dist/` and an edit to a lib
module would show up only after rebuilding the CMS. The package keeps the source
reachable behind a `codeyam-source` export condition, and `astro.config.mjs`
opts into it (client *and* SSR) whenever local-CMS mode is on — so raw source
still wins while linked, and installed builds still get the compiled half.

Everything else is automatic. `astro.config.mjs` turns on local-CMS mode by
checking whether `node_modules/@codeyam/cms` is a symlink, so `npm run dev`,
`check` and `build` all behave correctly in whichever state you left
`node_modules` — `dev:cms` is just `dev` with the link step in front of it.

Edits in the checkout hot-reload here: the `codeyam:live-linked-cms` plugin
bridges the symlink for Vite's watcher, module graph, and browser cache (see the
comment there for why all three are needed). The scripts also carry
`NODE_OPTIONS=--preserve-symlinks`, the Node-side half of
`vite.resolve.preserveSymlinks`; without it CMS source resolves `react` from the
checkout's own `node_modules` and the admin islands hydrate against a second
React copy with no error explaining why.

## Editing without the CMS

You can always skip the CMS and edit content directly:

1. Create or edit a `.md` file under `src/content/pages/`.
2. Give it frontmatter matching `src/content.config.ts`.
3. Run `npm run dev`; the page renders through the `[...slug]` catch-all.
