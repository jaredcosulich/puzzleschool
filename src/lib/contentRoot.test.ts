import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
import { resolveContentRoot, resolveDataRoot } from './contentRoot';

// Clear the overrides BEFORE each case, not only after.
//
// These tests run inside a codeyam session, which injects CODEYAM_CONTENT_ROOT
// and CODEYAM_DATA_ROOT into the process so the app reads the sandbox. The
// ambient environment therefore already carries the very override the "no
// override is present" cases exist to assert the absence of — and because the
// env branch wins first, those cases never reach the code they mean to test.
// Clearing only in afterEach leaves the first case of each describe reading the
// injected value.
beforeEach(() => {
  delete process.env.CODEYAM_CONTENT_ROOT;
  delete process.env.CODEYAM_DATA_ROOT;
});

describe('resolveContentRoot', () => {
  afterEach(() => {
    delete process.env.CODEYAM_CONTENT_ROOT;
    vi.restoreAllMocks();
  });

  // The env override wins outright — this is the programmatic-launch path
  // where the editor injects the absolute sandbox content dir.
  it('prefers the CODEYAM_CONTENT_ROOT env override', () => {
    process.env.CODEYAM_CONTENT_ROOT = '/tmp/sandbox/content';
    expect(resolveContentRoot('/proj')).toBe('/tmp/sandbox/content');
  });

  // With no env var, the sidecar file the editor writes is the load-bearing
  // override for a PTY-launched dev server that didn't inherit the env.
  it('falls back to the .codeyam/tmp/content-root sidecar', () => {
    // A REAL sidecar under a real temp root. `vi.spyOn(fs, 'readFileSync')`
    // cannot patch an ESM namespace import, so the mock this test used to rely
    // on never took effect and the assertion was measuring the un-mocked path.
    const projectRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'codeyam-root-'));
    fs.mkdirSync(path.join(projectRoot, '.codeyam', 'tmp'), { recursive: true });
    fs.writeFileSync(
      path.join(projectRoot, '.codeyam', 'tmp', 'content-root'),
      '/tmp/sandbox/content\n',
    );
    expect(resolveContentRoot(projectRoot)).toBe('/tmp/sandbox/content');
  });

  // With neither override present (a real production build), the site reads
  // its committed `src/content` — so deploys are unaffected.
  it('defaults to _projectRoot_/src/content when no override is present', () => {
    // An empty temp root genuinely has no sidecar, so the read fails for real
    // rather than through a mock that cannot patch an ESM namespace import.
    const projectRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'codeyam-root-'));
    expect(resolveContentRoot(projectRoot)).toBe(path.join(projectRoot, 'src/content'));
  });
});

describe('resolveDataRoot', () => {
  afterEach(() => {
    delete process.env.CODEYAM_DATA_ROOT;
    vi.restoreAllMocks();
  });

  // The data root resolves with the same env → sidecar → default precedence
  // as the content root, defaulting to committed `src/data` in production.
  it('defaults to _projectRoot_/src/data when no override is present', () => {
    const projectRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'codeyam-root-'));
    expect(resolveDataRoot(projectRoot)).toBe(path.join(projectRoot, 'src/data'));
  });
});
