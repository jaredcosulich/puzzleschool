// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import codeyamCms from '@codeyam/cms';
import { realpathSync } from 'node:fs';
import path from 'node:path';

import { linkedPathForRealFile } from './src/lib/linkedCmsPath.ts';

// Local-CMS development mode: on whenever `node_modules/@codeyam/cms` is a
// symlink to a checkout of the codeyam-cms repo (`npm run dev:cms` makes it
// one, `npm run cms:unlink` puts the published package back). Detected rather
// than flagged so every command — dev, check, build — does the right thing in
// whichever state node_modules happens to be in, with nothing to remember. The
// package ships raw TS through its `exports`, so linking is the entire job;
// there is no CMS build step to run first.
const CMS_LINK = path.resolve('node_modules/@codeyam/cms');
const CMS_REAL = realpathSync(CMS_LINK);
const CMS_LOCAL = CMS_REAL !== CMS_LINK;

// Make an edit inside the linked codeyam-cms checkout land in this dev server.
// Three separate caches sit between that file and the browser, and all three
// have to be dealt with or the edit is invisible until a dev-server restart:
//
//  1. The BROWSER cache. `preserveSymlinks` (below) parks actively-edited source
//     behind a `/node_modules/` URL, and Vite serves node_modules `immutable`
//     (year-cacheable). The middleware rewrites that header to `no-cache`.
//     Installs pre, not post: a `configureServer` that does NOT return a function
//     runs before Vite's internal middlewares, which is required here — the
//     header has to be patched before the transform middleware writes it.
//  2. The WATCHER. Vite watches the project root; the link resolves to a checkout
//     *outside* it, so no file event ever fires. `watcher.add(real)` subscribes
//     to the real directory. (The `server.watch.ignored` negation below is
//     necessary too but not sufficient on its own — it only un-ignores a path
//     that is already being watched.)
//  3. The MODULE GRAPH. Watcher events arrive under the real checkout path,
//     while `preserveSymlinks` keys every module under the `node_modules` path,
//     so Vite's own invalidation misses. We translate real → linked, invalidate
//     the matching modules by hand, and full-reload.
//
// A first reload that still looks broken is a browser holding the old
// `immutable` entry — `immutable` is reused WITHOUT revalidation even on an
// ordinary reload, so that one tab needs a single cache-bypassing reload
// (Chrome: "Empty cache and hard reload"). Every load after that is normal.
/** @returns {Promise<import('vite').Plugin>} */
async function liveLinkedCms() {
  // Dynamic so the published package — which may predate this lib — is never
  // asked for it outside local-CMS mode.
  const { isLinkedCmsModuleUrl, forceRevalidateHeader } = await import(
    '@codeyam/cms/lib/devModuleCache'
  );
  return {
    name: 'codeyam:live-linked-cms',
    apply: 'serve',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (isLinkedCmsModuleUrl(req.url)) forceRevalidateHeader(res);
        next();
      });

      server.watcher.add(CMS_REAL);
      /** @param {string} file */
      const bridge = (file) => {
        const linked = linkedPathForRealFile(file, CMS_REAL, CMS_LINK);
        if (linked === null) return;
        const mods = server.moduleGraph.getModulesByFile(linked);
        if (mods) for (const mod of mods) server.moduleGraph.invalidateModule(mod);
        server.ws.send({ type: 'full-reload' });
      };
      server.watcher.on('change', bridge);
      server.watcher.on('add', bridge);
      server.watcher.on('unlink', bridge);
    },
  };
}

// Astro static-site config for free GitHub Pages hosting.
//
// `output: 'static'` pre-renders every route to plain HTML at build time —
// nothing runs on a server, so the whole `dist/` folder drops onto GitHub
// Pages (or any static host) as-is. When you outgrow static and need
// server-rendered routes, this stays an in-framework upgrade: add an adapter,
// flip `output` to `'server'`, and opt individual routes into SSR with
// `export const prerender = false`. Content collections survive that move
// unchanged, so the codeyam data/scenario model built on them keeps working.
//
// Two base modes, chosen at setup:
// - For a custom domain (e.g., harvardintech.com), use base: '/'
// - For a default project site (e.g., user.github.io/repo), use base: '/<repo-name>/'
export default defineConfig({
  output: 'static',
  // Custom domain (public/CNAME), so the site lives at the domain root and
  // `base` stays at its default '/'.
  site: 'https://puzzleschool.org',
  integrations: [
    codeyamCms(),
    react(),
    // Keep the sitemap to the actual public site. The build also emits the CMS
    // admin app and one harness page per component (codeyam's isolated-component
    // scenarios); both are real routes, but advertising them to search engines
    // would bury the three pages that matter under ~40 that don't.
    sitemap({ filter: (page) => !/\/(admin|isolated-components)\//.test(page) }),
  ],
  vite: {
    plugins: CMS_LOCAL ? [await liveLinkedCms()] : [],
    server: CMS_LOCAL
      ? {
          // Vite's watcher ignores `**/node_modules/**` by default, so an edit to
          // the linked CMS never invalidated the module graph — the server
          // re-served the old text under an unchanged ETag and only a restart
          // picked it up. The negation un-ignores just this one package, so
          // ordinary deps stay unwatched (watching all of node_modules is the
          // file-descriptor blowup that default exists to prevent).
          watch: { ignored: ['!**/node_modules/@codeyam/cms/**'] },
        }
      : {},
    resolve: CMS_LOCAL
      ? {
          // Keep resolved ids on the symlinked `node_modules/@codeyam/cms` path
          // instead of realpathing them back into the codeyam-cms checkout. Two
          // reasons: Astro stamps the resolved path into each island's
          // `component-url`, and a `/Users/…/codeyam-cms/…` island URL is outside
          // anything the dev server will serve; and realpathed CMS source resolves
          // `react` from the codeyam-cms checkout's own node_modules, giving the
          // page two React copies and dead hooks. This governs imports made *from*
          // the injected admin entrypoints; the entrypoints themselves are resolved
          // by Node's `require.resolve`, which needs the
          // `NODE_OPTIONS=--preserve-symlinks` prefix carried by the `dev`,
          // `build` and `check` scripts. Both halves are required — either alone
          // leaves half the module graph on the other path, which in a build
          // means the same module bundled twice under two identities. (The
          // scripts carry the prefix unconditionally: with no linked package
          // there are no symlinks for it to preserve, so it costs nothing, and
          // that is what lets every command work in either state. `build` runs
          // two commands and so repeats it — a `VAR=x a && b` prefix applies
          // only to `a`.)
          preserveSymlinks: true,
        }
      : {},
    optimizeDeps: {
      // `micromark`'s development build (which Vite resolves under `astro dev`)
      // does `import createDebug from 'debug'`, and `debug` is CJS. Vite's
      // scanner never reaches it — it lives behind @codeyam/cms's raw-TS
      // exports — so it gets served unconverted, with no `default` export, and
      // the /admin EntryEditor island throws on hydration. A dead island still
      // renders its SSR HTML, so the symptom is a form that looks fine but
      // ignores every keystroke. Pre-bundling `debug` restores the interop.
      //
      // The micromark entries are the same lazy-discovery problem one level up:
      // discovered on first render they trigger a mid-session re-optimization
      // ("optimized dependencies changed. reloading"), which invalidates
      // already-loaded island module URLs. Optimizing up front keeps the dep hash
      // stable for the life of the dev server.
      include: ['debug', 'micromark', 'micromark-extension-gfm'],
      // Bare-specifier CMS modules (the integration injects the staged-preview
      // gate as `import '@codeyam/cms/client/stagedPreview'`) are dependencies by
      // definition, so Vite pre-bundles them into `.vite/deps/` — a cache neither
      // the revalidate plugin nor the un-ignored watch reaches, since both act on
      // the `/node_modules/@codeyam/cms/` source path. Excluding puts them back on
      // that path so edits land like every other CMS edit. Only correct while
      // linked; for the published package pre-bundling is the right behaviour.
      exclude: CMS_LOCAL
        ? [
            '@codeyam/cms/client/stagedPreview',
            '@codeyam/cms/client/stagedPreviewRuntime',
            '@codeyam/cms/lib/stagedPreview',
          ]
        : [],
    },
  },
});
