// Writing a freshly generated figure into an SVG that is already on the page.
//
// This is the general form of what `applyTreeGrowth` used to do alone. Three
// structures now regrow themselves per visit — the branching tree, the
// harmonograph and the Voronoi field — and every one of them faces the same
// three cases: the new figure has FEWER paths than the server drew, MORE, or the
// same number. All three look fine until one is off by one, which is exactly the
// kind of bug that ships.
//
// It lives outside the components' `<script>` blocks for the reason `tree-dom`
// already gave: logic inside an Astro script tag is unreachable from vitest, and
// this is the part of the per-visit regrow most likely to break quietly.

/** One drawn path: its `d`, and the stroke width it should carry (if it varies). */
export interface FigurePath {
  d: string;
  /** Omitted when every path in the figure shares the stroke width from markup. */
  width?: number;
}

/**
 * Rewrite `svg` to draw `paths`, reframing its viewBox to `viewBox`.
 *
 * Existing `<path>` elements are REUSED rather than replaced. That is what keeps
 * the stroke, linecap and vector-effect correct without this module restating
 * them: the server-rendered path already carries the styling, so surplus paths
 * are cloned from it and the styling stays defined in exactly one place — the
 * component's markup.
 *
 * Returns false and leaves the element untouched when there is no path to use as
 * a template, since inventing one here would mean duplicating that styling.
 * Callers treat false as "keep the figure the server drew".
 */
export function applyFigure(
  svg: SVGSVGElement,
  viewBox: string,
  paths: readonly FigurePath[],
): boolean {
  const existing = Array.from(svg.querySelectorAll('path'));
  if (existing.length === 0 || paths.length === 0) return false;

  svg.setAttribute('viewBox', viewBox);

  const template = existing[0];
  paths.forEach((path, index) => {
    const el = existing[index] ?? svg.appendChild(template.cloneNode(false) as SVGPathElement);
    el.setAttribute('d', path.d);
    // Only written when the figure actually varies its stroke — otherwise the
    // width stays whatever the markup set, which is the single source of truth
    // for a figure drawn at one weight throughout.
    if (path.width !== undefined) el.setAttribute('stroke-width', String(path.width));
  });

  // Anything the new, smaller figure does not need. Left in place these would
  // still be drawn — the old figure's outer parts hanging off the new one.
  for (const surplus of existing.slice(paths.length)) surplus.remove();

  return true;
}
