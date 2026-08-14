import path from 'node:path';
import { describe, expect, it } from 'vitest';

import { linkedPathForRealFile } from './linkedCmsPath';

const REAL = path.join('/Users/dev/workspace/codeyam-cms/packages/cms');
const LINK = path.join('/Users/dev/workspace/puzzleschool/node_modules/@codeyam/cms');

describe('linkedPathForRealFile', () => {
  // The core translation: a watcher event under the real checkout has to come
  // back as the node_modules path, because that is the only identity the module
  // graph holds under preserveSymlinks. Get this wrong and the lookup silently
  // misses — the edit is served stale with no error anywhere.
  it('rewrites a file under the real checkout onto the linked root', () => {
    expect(linkedPathForRealFile(path.join(REAL, 'src/lib/entrySource.ts'), REAL, LINK)).toBe(
      path.join(LINK, 'src/lib/entrySource.ts'),
    );
  });

  // Nested paths must survive whole. An early version that took a basename
  // would collapse two same-named files in different directories onto one
  // module, invalidating the wrong one.
  it('preserves the full subpath, not just the file name', () => {
    expect(
      linkedPathForRealFile(path.join(REAL, 'src/components/admin/StagingBar.tsx'), REAL, LINK),
    ).toBe(path.join(LINK, 'src/components/admin/StagingBar.tsx'));
  });

  // Every other file in the project also reaches the watcher. Returning a path
  // for those would invalidate unrelated modules and full-reload the browser on
  // every save anywhere in the repo.
  it('returns null for a file outside the real checkout', () => {
    expect(linkedPathForRealFile('/Users/dev/workspace/puzzleschool/src/pages/index.astro', REAL, LINK)).toBeNull();
  });

  // A prefix match is not containment. `…/codeyam-cms-fork` starts with
  // `…/codeyam-cms`, and without the separator guard its files would be
  // rewritten onto the linked root and invalidate modules that do not exist.
  it('does not match a sibling directory that shares a prefix', () => {
    expect(linkedPathForRealFile(`${REAL}-fork/src/lib/entrySource.ts`, REAL, LINK)).toBeNull();
  });

  // The root directory is not a module. chokidar reports directory events too,
  // and treating one as a file would trigger a full-reload for a change the
  // module graph has nothing to invalidate for.
  it('returns null for the real root itself', () => {
    expect(linkedPathForRealFile(REAL, REAL, LINK)).toBeNull();
  });
});
