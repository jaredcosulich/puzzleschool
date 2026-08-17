// Site-wide data loaded from editable JSON singletons under `src/data/`.
//
// `settings.json` and `nav.json` are content, not code: the CMS edits them as
// Sveltia "file" collections, and every layout reads them through this module.
// Changing the contact email, a social link, or a menu item is therefore a
// data edit (a commit the CMS makes), never a source change. codeyam's
// `content-collection` seed adapter rewrites these same files per scenario, so
// a scenario can render "site with 3 socials and a chapters dropdown" vs a
// minimal nav without touching markup.
//
// The singletons are read at build/render time with `fs` (rather than a static
// `import ... from '../data/settings.json'`) so the data root can be
// redirected: in production it resolves to `src/data`, but during a codeyam
// session it points at the `.codeyam/tmp` sandbox so seeding never mutates
// committed source. A static import is bundled from a fixed path and cannot be
// redirected. This runs in Node at build/render time, so `fs` is available for
// both the dev server and the production GitHub Pages build.
import * as fs from 'fs';
import * as path from 'path';
import { resolveDataRoot } from './contentRoot';

const dataRoot = resolveDataRoot();
const readSingleton = <T>(name: string): T =>
  JSON.parse(fs.readFileSync(path.join(dataRoot, `${name}.json`), 'utf-8')) as T;

export interface SocialLink {
  label: string;
  url: string;
  icon?: string;
}

export interface SiteSettings {
  siteTitle: string;
  description: string;
  contactEmail: string;
  footerText: string;
  socials: SocialLink[];
}

export interface NavItem {
  label: string;
  url?: string;
  children?: NavItem[];
}

export interface SiteNav {
  items: NavItem[];
}

// Read PER CALL, not once at module scope.
//
// These files are read through `fs` at runtime, so Vite has no idea they are a
// dependency of this module and cannot invalidate it when they change. Bound to
// a module-level `const`, the values freeze at first import for the life of the
// dev server — which silently breaks the scenario model: seeding a scenario that
// varies the nav or the site title rewrites the JSON on disk, the adapter
// reports success, and the preview keeps rendering the previous scenario's
// chrome until someone restarts the dev server. A scenario that cannot be seen
// is worse than one that fails loudly.
//
// Reading per call costs one small synchronous `readFileSync` per render. These
// are static builds — the cost lands at build time, not on a visitor.

/** The editable site-wide settings singleton, re-read on every access. */
export function getSettings(): SiteSettings {
  return readSingleton<SiteSettings>('settings');
}

/** The editable navigation singleton, re-read on every access. */
export function getNav(): SiteNav {
  return readSingleton<SiteNav>('nav');
}

// Matching a nav item against the current page is not string equality, because
// the two sides come from different places and disagree about trailing slashes.
// `nav.json` is hand-edited content — an author writes `/about`. Astro's default
// `build.format: 'directory'` emits `dist/about/index.html`, so the rendered
// `Astro.url.pathname` is `/about/`. A strict compare fails and no link is ever
// marked current in the built site. Normalizing BOTH sides (rather than
// stripping one) also covers the mirror case, where a CMS author types
// `/about/` and the dev server renders `/about`.

/**
 * Reduce a path to a canonical form for comparison: no query string or hash, no
 * trailing slash, lowercased. The site root stays `/` rather than collapsing to
 * the empty string, which would otherwise match every path.
 */
export function normalizeNavPath(path: string): string {
  const withoutSuffix = (path ?? '').trim().split(/[?#]/, 1)[0];
  const trimmed = withoutSuffix.replace(/\/$/, '');
  return (trimmed === '' ? '/' : trimmed).toLowerCase();
}

/**
 * Whether a nav item points at the page currently being rendered. A `NavItem`
 * may be a parent with only `children` and no `url` of its own; such an item is
 * never current.
 */
export function isCurrentNavPath(
  itemUrl: string | undefined,
  currentPath: string,
): boolean {
  if (itemUrl === undefined) return false;
  return normalizeNavPath(itemUrl) === normalizeNavPath(currentPath);
}
