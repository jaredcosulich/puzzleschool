import { describe, expect, it } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { parseEntry, serializeEntry } from '@codeyam/cms/lib/frontmatter';
import { COLLECTION_FIELDS } from '@codeyam/cms/lib/entryEditor';

// A contract test against the @codeyam/cms dependency, not against this repo's
// own code.
//
// `@codeyam/cms@0.7.0`'s `parseEntry` had no YAML block-scalar support: it took
// any non-empty text after the first `:` as the value, so `intro: >-` parsed as
// the literal string ">-" and the folded continuation lines beneath it were
// re-read as top-level entries — one of which contained a colon and became a
// bogus key. `serializeEntry(parseEntry(raw))` was therefore not an identity,
// and `EntryEditor` builds its saved content from exactly that call, so saving
// any entry containing a block scalar from /admin wrote the mangled version
// back to disk. The published site never showed it, because Astro's own content
// loader parses the YAML correctly — which is why it stayed invisible.
//
// These assertions run over the REAL committed entries rather than a synthetic
// fixture on purpose. The bug only bit because the actual files used a
// construct the parser did not cover; a hand-written fixture would have passed
// while `about.md` was broken. Globbing the real entries covers any future
// entry an author writes the moment it lands.

// Resolve the committed content directory directly, NOT via
// `resolveContentRoot()`.
//
// That helper honours `CODEYAM_CONTENT_ROOT`, which a codeyam session injects so
// the app reads its seeded sandbox (see the same note in `contentRoot.test.ts`).
// Using it here would silently point this guard at scenario seed data during
// every in-session run — vacuous exactly where it runs most often. The files
// this guard exists to protect are the committed ones, so it names them.
const PAGES_DIR = path.join(process.cwd(), 'src', 'content', 'pages');

/** The bare block-scalar indicators — `>`, `|`, with optional chomp/indent. */
const BLOCK_INDICATOR = /^[|>][-+]?[0-9]*$/;

/**
 * Every frontmatter key the pages collection may legitimately carry.
 *
 * Two sources, because neither is complete alone: `collections.json` declares
 * this site's own fields, while `title`/`description`/`order`/`draft` and the
 * SEO group are the CMS's universal builtins and live in `COLLECTION_FIELDS`.
 * Reading only the former would fail every entry on the first run.
 */
function knownFieldNames(): Set<string> {
  const registry = JSON.parse(
    fs.readFileSync(path.join(process.cwd(), 'src', 'data', 'collections.json'), 'utf-8'),
  );
  const siteFields: string[] = (registry.builtins?.pages ?? []).map(
    (f: { name: string }) => f.name,
  );
  const cmsFields = COLLECTION_FIELDS.pages.map((f) => f.name);
  return new Set([...siteFields, ...cmsFields]);
}

function pageEntries(): { name: string; raw: string }[] {
  return fs
    .readdirSync(PAGES_DIR)
    .filter((n) => n.endsWith('.md'))
    .sort()
    .map((name) => ({ name, raw: fs.readFileSync(path.join(PAGES_DIR, name), 'utf-8') }));
}

describe('cmsFrontmatterRoundTrip', () => {
  // Guards against a regression producing an empty glob, which would make every
  // other case in this file pass by iterating over nothing.
  it('finds the committed page entries to check', () => {
    const entries = pageEntries();
    expect(entries.length).toBeGreaterThan(0);
    expect(entries.map((e) => e.name)).toContain('about.md');
  });

  // The direct signature of the 0.7.0 defect: a field whose value is the block
  // indicator itself rather than the prose the indicator introduces.
  it('parses every page entry without leaving a bare block-scalar indicator', () => {
    for (const { name, raw } of pageEntries()) {
      const { data } = parseEntry(raw);
      for (const [key, value] of Object.entries(data)) {
        expect(BLOCK_INDICATOR.test(key.trim()), `${name}: key ${JSON.stringify(key)}`).toBe(
          false,
        );
        if (typeof value === 'string') {
          expect(
            BLOCK_INDICATOR.test(value.trim()),
            `${name}: ${key} is the bare indicator ${JSON.stringify(value)}`,
          ).toBe(false);
        }
      }
    }
  });

  // The other half of the defect: folded continuation lines re-read as
  // top-level entries synthesize keys that were never in the file, e.g.
  // "about everything else. We are building the other half".
  it('parses no frontmatter key outside the declared field set', () => {
    const known = knownFieldNames();
    for (const { name, raw } of pageEntries()) {
      for (const key of Object.keys(parseEntry(raw).data)) {
        expect(known.has(key), `${name}: unexpected key ${JSON.stringify(key)}`).toBe(true);
      }
    }
  });

  // Pins each entry as a fixed point of the serializer. This is what keeps the
  // publish drift check quiet: the CMS compares its staged baseline (which is
  // `serializeEntry` output) against the raw file on the branch, so a file that
  // is not byte-equal to its own baseline reports a phantom "changed on the
  // site since you started editing it" conflict on every publish.
  it('round-trips every page entry through parse and serialize unchanged', () => {
    for (const { name, raw } of pageEntries()) {
      expect(serializeEntry(parseEntry(raw)), `${name} is not a fixed point`).toBe(raw);
    }
  });

  // Editing one field must not disturb the others. This is the data-loss path
  // itself: `EntryEditor` saves `serializeEntry` output, so under 0.7.0 saving
  // any single field wrote back an entry whose other block-scalar fields had
  // been replaced by ">-".
  it('preserves untouched block scalars when one other field is edited', () => {
    const raw = fs.readFileSync(path.join(PAGES_DIR, 'about.md'), 'utf-8');
    const parsed = parseEntry(raw);
    const saved = serializeEntry({
      ...parsed,
      data: { ...parsed.data, kicker: 'About the school, edited' },
    });

    expect(saved).toContain('About the school, edited');
    for (const field of ['intro', 'bandBody', 'quote'] as const) {
      expect(parseEntry(saved).data[field], `${field} lost its value`).toBe(parsed.data[field]);
    }
  });

  // The parser-level reproduction, isolated from this repo's content: a folded
  // scalar must yield its folded text. Red against 0.7.0, where it yields ">-".
  it('parses a folded block scalar into its folded text', () => {
    const raw = ['---', 'intro: >-', '  first line', '  second line', '---', '', 'body'].join(
      '\n',
    );
    expect(parseEntry(raw).data.intro).toBe('first line second line');
  });

  // The literal form is the other block style an author may reach for, and it
  // keeps its newlines where the folded form collapses them.
  it('parses a literal block scalar keeping its line breaks', () => {
    const raw = ['---', 'intro: |-', '  first line', '  second line', '---', '', 'body'].join(
      '\n',
    );
    expect(parseEntry(raw).data.intro).toBe('first line\nsecond line');
  });
});
