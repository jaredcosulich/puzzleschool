import { describe, expect, it } from 'vitest';
import { proseLayoutFor, sectionCount } from './proseLayout';

/** Astro's `render()` hands back records shaped like this; only depth is read. */
const h = (...depths: number[]) => depths.map((depth) => ({ depth }));

describe('sectionCount', () => {
  // `h3` is the section heading in this site's bodies.
  it('counts the depth-3 headings', () => {
    expect(sectionCount(h(3, 3, 3))).toBe(3);
  });

  // The page title is rendered by the header, not the body, so an `h1` in the
  // markdown is not a section.
  it('ignores headings at other depths', () => {
    expect(sectionCount(h(1, 2, 4, 5, 6))).toBe(0);
  });

  // A deeper heading INSIDE a section does not make the page two sections.
  it('counts only the section depth in a mixed body', () => {
    expect(sectionCount(h(3, 4, 4, 3, 5))).toBe(2);
  });

  // The empty body — a page an editor created but has not written into.
  it('reports zero for a body with no headings at all', () => {
    expect(sectionCount([])).toBe(0);
  });
});

describe('proseLayoutFor', () => {
  // The About case: two sections keep the two-column shape with the tree.
  it('gives two sections the two-column shape', () => {
    expect(proseLayoutFor(h(3, 3))).toBe('columns');
  });

  // More than two is still the column shape — the rule is a floor, not equality.
  it('gives many sections the two-column shape', () => {
    expect(proseLayoutFor(h(3, 3, 3, 3))).toBe('columns');
  });

  // The Contact case, and the whole point of the feature.
  it('gives one section the flanked single-column shape', () => {
    expect(proseLayoutFor(h(3))).toBe('single');
  });

  // A body with no sections counts as one rather than as a special case, so
  // `/blank` renders as two structures with nothing yet between them.
  it('treats a body with no sections as one', () => {
    expect(proseLayoutFor([])).toBe('single');
  });

  // The boundary is between one and two, and it is the only place the answer
  // changes — worth pinning directly, since moving it by one silently reflows
  // every page on the site.
  it('switches shape exactly between one section and two', () => {
    expect(proseLayoutFor(h(3))).toBe('single');
    expect(proseLayoutFor(h(3, 3))).toBe('columns');
  });

  // A one-section body with sub-headings must NOT be promoted to two columns —
  // this is what makes counting `h3` specifically, rather than any heading, the
  // load-bearing choice.
  it('keeps a single section flanked even when it has sub-headings', () => {
    expect(proseLayoutFor(h(3, 4, 4, 5))).toBe('single');
  });
});
