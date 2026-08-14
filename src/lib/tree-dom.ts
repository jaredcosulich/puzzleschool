// Writing a grown tree into an SVG that is already on the page.
//
// This lives in its own module rather than inline in BranchingTree.astro's
// <script> for one reason: logic inside an Astro script tag is unreachable from
// vitest, and this is the part of the per-visit regrow most likely to break
// quietly. The new tree rarely has the same number of segments as the one the
// server drew, so every call is reusing, adding, or removing <path> elements —
// three cases that all look fine until one is off by one.
import { toPath, treeViewBox, type Segment } from './structures';

/**
 * Rewrite `svg` to draw `segments`, reframing its viewBox to match.
 *
 * Existing `<path>` elements are REUSED rather than replaced. That is what
 * keeps the stroke, linecap and vector-effect correct without this module
 * restating them: the server-rendered path already carries the styling, so
 * surplus paths are cloned from it and the styling stays defined in exactly one
 * place — the component's markup.
 *
 * Returns false and leaves the element untouched when there is no path to use
 * as a template, since inventing one here would mean duplicating that styling.
 * Callers treat false as "keep the tree the server drew".
 */
export function applyTreeGrowth(svg: SVGSVGElement, segments: readonly Segment[]): boolean {
  const existing = Array.from(svg.querySelectorAll('path'));
  if (existing.length === 0 || segments.length === 0) return false;

  svg.setAttribute('viewBox', treeViewBox(segments));

  const template = existing[0];
  segments.forEach((segment, index) => {
    const path = existing[index] ?? svg.appendChild(template.cloneNode(false) as SVGPathElement);
    path.setAttribute('d', toPath([segment.from, segment.to]));
    path.setAttribute('stroke-width', String(segment.width));
  });

  // Anything the new, smaller tree does not need. Left in place these would
  // still be drawn — the old tree's outer branches hanging off the new one.
  for (const surplus of existing.slice(segments.length)) surplus.remove();

  return true;
}
