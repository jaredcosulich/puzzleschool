// Resolve the content/data roots the site reads from.
//
// In a real production `astro build` (GitHub Pages deploy) neither override is
// present, so the site reads its committed `src/content`/`src/data`. During a
// codeyam session the editor seeds a sandbox copy under `.codeyam/tmp/` and
// points the app at it — either via the `CODEYAM_CONTENT_ROOT` /
// `CODEYAM_DATA_ROOT` env vars (programmatic launches) or, when the dev server
// is launched in a PTY where env injection isn't guaranteed, via the
// `.codeyam/tmp/content-root` / `.codeyam/tmp/data-root` sidecar files the
// editor writes. So scenario seeding never touches committed source.
//
// Resolution order (first match wins): env override → sidecar file → default.
import * as fs from 'fs';
import * as path from 'path';

function resolveRoot(
  envVar: string,
  sidecarName: string,
  defaultRel: string,
  projectRoot: string,
): string {
  const fromEnv = process.env[envVar];
  if (fromEnv && fromEnv.length > 0) return fromEnv;

  try {
    const sidecar = fs
      .readFileSync(path.join(projectRoot, '.codeyam', 'tmp', sidecarName), 'utf-8')
      .trim();
    if (sidecar.length > 0) return sidecar;
  } catch {
    // No sidecar — fall through to the committed-source default.
  }

  return path.join(projectRoot, defaultRel);
}

/** Absolute content root: `CODEYAM_CONTENT_ROOT` → sidecar → `src/content`. */
export function resolveContentRoot(projectRoot: string = process.cwd()): string {
  return resolveRoot('CODEYAM_CONTENT_ROOT', 'content-root', 'src/content', projectRoot);
}

/** Absolute data root: `CODEYAM_DATA_ROOT` → sidecar → `src/data`. */
export function resolveDataRoot(projectRoot: string = process.cwd()): string {
  return resolveRoot('CODEYAM_DATA_ROOT', 'data-root', 'src/data', projectRoot);
}
