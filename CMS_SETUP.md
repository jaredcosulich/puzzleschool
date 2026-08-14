# Content Management Setup

This site stores content as typed markdown in `src/content/`. A friendly,
browser-based editing UI — **Sveltia CMS**, a modern Decap-compatible editor —
is wired in at **`/admin`**. It commits markdown straight to your content
collections, so editors never touch code and the static-hosting model is
unchanged: GitHub Pages still serves plain HTML, and codeyam can still seed the
same files per scenario through the `content-collection` seed adapter.

> **Build agent: ask first.** Before wiring auth, ask the user **which editing
> path(s) they want** — the three below can coexist (e.g. local for yourself +
> hosted OAuth for a teammate). Only the "Hosted + password" path adds a service
> outside GitHub Pages. Wire exactly what they pick; don't assume.

## The admin app

- `public/admin/index.html` loads Sveltia from its CDN and auto-mounts at
  `/admin` (Astro serves `public/` verbatim — works live and locally).
- `public/admin/config.yml` is the Decap/Sveltia config. Its `collections`
  block mirrors `src/content/config.ts`; see **Keeping the schema honest** below.

## Choosing an editing path

| Path | Editors need | Extra service | Best for |
| --- | --- | --- | --- |
| **GitHub OAuth** | a GitHub account with repo write | an OAuth relay (free) | teammates; per-user commit attribution |
| **Password** | the shared password | one free Cloudflare Worker | non-technical editors, no GitHub account |
| **Local** | the repo cloned locally | none | yourself / quick edits |

### 1. Hosted + GitHub OAuth

Editors visit `/admin` on the live site and click "Sign in with GitHub". GitHub
Pages can't run the OAuth callback itself, so point the CMS at an OAuth relay.

**Pre-flight:** a GitHub account with write access to this repo.

1. Register a GitHub OAuth App (Settings → Developer settings → OAuth Apps).
   Set the callback URL to your relay's callback (Sveltia's hosted helper, or a
   self-hosted relay such as `sveltia/sveltia-cms-auth` on Cloudflare Workers).
2. In `public/admin/config.yml`, under `backend:` add:
   ```yaml
   base_url: https://<your-oauth-relay>
   auth_endpoint: oauth/authorize   # match your relay's route
   ```
3. Store the OAuth App's **client secret** wherever the relay expects it (a
   Worker secret for the self-hosted relay) — never in this repo.

### 2. Hosted + password

The exact "password at the same domain" UX, backed by the minimal Cloudflare
Worker shipped in **`cms-auth-worker/`**. This is the one path that adds a
non-GitHub free service.

**Pre-flight:** a free Cloudflare account; a fine-grained GitHub PAT scoped to
**Contents: Read & Write on this repo only**.

1. Deploy the Worker:
   ```bash
   cd cms-auth-worker
   npx wrangler deploy
   npx wrangler secret put CMS_PASSWORD   # the shared editor password
   npx wrangler secret put GITHUB_TOKEN   # the fine-grained PAT
   ```
2. In `public/admin/config.yml`, under `backend:` add:
   ```yaml
   base_url: https://<name>.<subdomain>.workers.dev
   auth_endpoint: auth
   ```
3. Editors visit `/admin`, get a password prompt, and commit as the PAT's
   identity. See the security trade-off documented at the top of
   `cms-auth-worker/worker.js` (one shared identity, no per-user attribution).

### 3. Local

Always available, no auth, no server.

**Pre-flight:** the repo cloned locally.

1. `local_backend: true` is already set in `public/admin/config.yml`.
2. Run `npm run dev`, open `/admin`, and choose **"Work with Local Repository"**.
3. Edit posts; Sveltia writes straight to `src/content/`. Commit and push
   yourself — the change goes live on the next GitHub Pages deploy.

## Keeping the schema honest

`public/admin/config.yml` and `src/content/config.ts` describe the **same**
markdown files and must stay in sync: every field `name` in a collection must
exist in the matching Astro schema (the reserved `body` field is the markdown
body, not frontmatter, so it has no schema counterpart). codeyam's template test
`astro_cms_config_fields_subset_of_content_schema` enforces this for the shipped
template. When you add a content field, add it in **both** files.

**Required by default.** Sveltia/Decap treat every field as required unless you
set `required: false`. A field that is `.optional()` in `src/content/config.ts`
must be `required: false` in `config.yml`, and the reserved `body` markdown field
must be `required: false` on any collection whose entries can exist without prose
(e.g. a name-and-role-only `team` member, or a bare save-the-date `event`).
Leave a supplemental field implicitly required and saving a body-less entry fails
with a generic, hard-to-diagnose **"One field has an error"**. Two codeyam
template tests keep this honest: one asserts every shipped sample entry is
saveable under `config.yml`'s required rules, the other asserts every
`.optional()` schema field is `required: false` in the CMS config.

## Developing against a local codeyam-cms checkout

To test unreleased `@codeyam/cms` changes here instead of the published package:

```sh
npm run dev:cms     # link the local checkout, then start dev against it
npm run cms:unlink  # go back to the published package
```

Register the checkout once with `npm link` from `codeyam-cms/packages/cms`;
after that `dev:cms` links it here and starts the dev server. There is no CMS
build step — the package's `exports` point at raw `.ts`/`.tsx`, so the link *is*
the build.

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

1. Create or edit a `.md` file under `src/content/blog/`.
2. Give it frontmatter matching `src/content/config.ts` (`title`, `date`,
   optional `summary`, optional `coverImage`).
3. Run `npm run dev`; the post appears on the index automatically.
