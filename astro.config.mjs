// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import codeyamCms from '@codeyam/cms';

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
  // site: 'https://<user>.github.io',
  // base: '/',
  integrations: [codeyamCms(), react(), sitemap()],
});
