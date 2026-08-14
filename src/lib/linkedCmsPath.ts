// Translate a file path under a linked package's REAL checkout into the
// symlinked `node_modules` path the dev server keys its modules under.
//
// This exists because the two halves of local-CMS mode disagree about which
// path a file has. The watcher reports events under the real checkout
// (`/Users/…/codeyam-cms/packages/cms/src/…`), while `preserveSymlinks` keys
// every module under the link (`<project>/node_modules/@codeyam/cms/src/…`).
// Vite's own invalidation looks up the watcher's path, finds nothing, and the
// edit never reaches the browser. Translating real → linked is what makes the
// lookup hit.
//
// Kept separate from the plugin in `astro.config.mjs` so the decision — does
// this file belong to the linked package, and what is its linked path — is
// testable without a running dev server.
import path from 'node:path';

/**
 * The linked-path equivalent of `file`, or `null` when `file` is not inside
 * `realRoot` and therefore none of the linked package's business.
 *
 * Containment is checked with a trailing separator so a sibling directory that
 * merely shares a prefix (`…/codeyam-cms-fork/src/x.ts` against a
 * `…/codeyam-cms` root) is not mistaken for a child. `realRoot` itself returns
 * null: the directory is not a module, and invalidating on it would full-reload
 * the browser for an event that changed no file the graph holds.
 */
export function linkedPathForRealFile(
  file: string,
  realRoot: string,
  linkRoot: string,
): string | null {
  if (!file.startsWith(realRoot + path.sep)) return null;
  return linkRoot + file.slice(realRoot.length);
}
