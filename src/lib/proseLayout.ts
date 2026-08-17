// Which prose shape a page gets, decided from the page's own body.
//
// An internal page has two shapes. Two or more sections get the two-column
// layout with the branching structure standing in the gap. One section — or
// none — gets a centred single column with a different structure in a lane
// either side, because a one-section page written into two columns leaves a
// half-empty second column with the tree stranded beside it.
//
// DERIVED, NOT DECLARED, and that is the whole point. A `proseLayout`
// frontmatter field would put the decision somewhere the writer has to remember,
// and the promise of this template is that a page created from /admin gets the
// site's design without anyone touching code. Astro's `render()` already returns
// `headings`, so counting them costs nothing and a CMS editor gets the right
// layout by WRITING: split a body into a second section and the tree comes back,
// with no field to find and no deploy to ask for.
//
// It lives in its own module rather than inline in the route's frontmatter for
// the reason `tree-dom` gives for existing at all: logic inside an `.astro`
// frontmatter block is unreachable from vitest. This is the rule that decides
// the shape of every page on the site, so it is the last thing that should go
// untested.

/** The subset of Astro's heading records this rule reads. */
export interface HeadingRef {
  depth: number;
}

export type ProseLayout = 'columns' | 'single';

/**
 * `h3` is the section heading in this site's bodies — `h1` is the page title,
 * rendered by the header rather than the body, and `h2` is unused. Counting a
 * specific depth rather than "any heading" is deliberate: a body that uses a
 * deeper heading inside one section has not thereby become a two-section page.
 */
const SECTION_DEPTH = 3;

/** Two or more sections keep the two-column shape; fewer get the flanked one. */
const COLUMNS_FROM = 2;

/** How many sections a body actually has. */
export function sectionCount(headings: readonly HeadingRef[]): number {
  return headings.filter((heading) => heading.depth === SECTION_DEPTH).length;
}

/**
 * The prose shape for a body with these headings.
 *
 * A body with NO sections counts as one, not as a special case. `/blank` — a
 * page an editor created but has not written into yet — then renders as two
 * structures with nothing between them, which is the honest reading of an empty
 * page rather than an exception the next reader has to look up.
 */
export function proseLayoutFor(headings: readonly HeadingRef[]): ProseLayout {
  return sectionCount(headings) >= COLUMNS_FROM ? 'columns' : 'single';
}
