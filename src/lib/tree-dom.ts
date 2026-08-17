// Writing a grown tree into an SVG that is already on the page.
//
// The fiddly part — reusing, cloning and removing `<path>` elements so the new
// figure's path count matches the old one's — is no longer specific to trees:
// the harmonograph and the Voronoi field regrow the same way. It now lives in
// `figure-dom`, and this module is the tree's adapter onto it: segments in,
// `{ d, width }` out.
//
// Kept as its own named function rather than folded into the component because
// its behaviour is pinned by tests, and those tests are what prove the
// generalisation was faithful — they never changed.
import { toPath, treeViewBox, type Segment } from './structures';
import { applyFigure } from './figure-dom';

/**
 * Rewrite `svg` to draw `segments`, reframing its viewBox to match.
 *
 * Returns false and leaves the element untouched when there is no path to use
 * as a template. Callers treat false as "keep the tree the server drew".
 */
export function applyTreeGrowth(svg: SVGSVGElement, segments: readonly Segment[]): boolean {
  // Guarded before `treeViewBox`, which reduces over the segments and would
  // return an infinite box for an empty list.
  if (segments.length === 0) return false;

  return applyFigure(
    svg,
    treeViewBox(segments),
    segments.map((segment) => ({
      d: toPath([segment.from, segment.to]),
      width: segment.width,
    })),
  );
}
