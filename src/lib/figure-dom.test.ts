import { describe, expect, it } from 'vitest';
import { applyFigure } from './figure-dom';

const SVG_NS = 'http://www.w3.org/2000/svg';

/** An SVG holding `count` styled paths, standing in for the server render. */
function svgWithPaths(count: number): SVGSVGElement {
  const svg = document.createElementNS(SVG_NS, 'svg') as SVGSVGElement;
  svg.setAttribute('viewBox', '0 0 1 1');
  for (let i = 0; i < count; i += 1) {
    const path = document.createElementNS(SVG_NS, 'path');
    path.setAttribute('d', 'M0 0 L1 1');
    path.setAttribute('stroke', 'var(--gold)');
    path.setAttribute('stroke-width', '1');
    path.setAttribute('vector-effect', 'non-scaling-stroke');
    svg.appendChild(path);
  }
  return svg;
}

describe('applyFigure', () => {
  // The new figure has its own extents, so the frame moves with it. Unlike the
  // tree wrapper, this module is handed the box rather than computing one —
  // three structures frame themselves differently.
  it('writes the viewBox it is given', () => {
    const svg = svgWithPaths(1);
    applyFigure(svg, '-2 -3 20 30', [{ d: 'M0,0 L1,1' }]);
    expect(svg.getAttribute('viewBox')).toBe('-2 -3 20 30');
  });

  // Same count: the existing elements are rewritten, not replaced, so the
  // styling that lives on them survives.
  it('reuses the existing path elements when the counts match', () => {
    const svg = svgWithPaths(2);
    const before = Array.from(svg.querySelectorAll('path'));
    applyFigure(svg, '0 0 2 2', [{ d: 'M0,0 L1,1' }, { d: 'M1,1 L2,2' }]);
    const after = Array.from(svg.querySelectorAll('path'));
    expect(after).toHaveLength(2);
    expect(after[0]).toBe(before[0]);
    expect(after[1]).toBe(before[1]);
    expect(after[1].getAttribute('d')).toBe('M1,1 L2,2');
  });

  // A bigger figure needs more paths, and the new ones must carry the styling —
  // which is why they are cloned from the server's path rather than built here.
  it('clones extra paths, carrying the styling, when the figure grew', () => {
    const svg = svgWithPaths(1);
    applyFigure(svg, '0 0 3 3', [{ d: 'M0,0' }, { d: 'M1,1' }, { d: 'M2,2' }]);
    const paths = Array.from(svg.querySelectorAll('path'));
    expect(paths).toHaveLength(3);
    for (const path of paths) {
      expect(path.getAttribute('stroke')).toBe('var(--gold)');
      expect(path.getAttribute('vector-effect')).toBe('non-scaling-stroke');
    }
  });

  // Left in place, surplus paths would still be drawn — the old figure's outer
  // parts hanging off the new one. The Voronoi field changes cell count between
  // draws, so this is the ordinary case for it rather than an edge one.
  it('removes surplus paths when the figure shrank', () => {
    const svg = svgWithPaths(5);
    applyFigure(svg, '0 0 2 2', [{ d: 'M0,0' }, { d: 'M1,1' }]);
    expect(svg.querySelectorAll('path')).toHaveLength(2);
  });

  // Stroke width carries the tree's taper, so it is written when supplied.
  it('writes stroke width when a path supplies one', () => {
    const svg = svgWithPaths(2);
    applyFigure(svg, '0 0 2 2', [{ d: 'M0,0', width: 3.2 }, { d: 'M1,1', width: 1.4 }]);
    const paths = Array.from(svg.querySelectorAll('path'));
    expect(paths[0].getAttribute('stroke-width')).toBe('3.2');
    expect(paths[1].getAttribute('stroke-width')).toBe('1.4');
  });

  // The harmonograph and the Voronoi field draw at ONE weight throughout, set in
  // markup. Writing a width for them would move that decision into this module
  // and out of the component that owns it.
  it('leaves the markup stroke width alone when a path omits one', () => {
    const svg = svgWithPaths(1);
    applyFigure(svg, '0 0 2 2', [{ d: 'M0,0' }]);
    expect(svg.querySelector('path')?.getAttribute('stroke-width')).toBe('1');
  });

  // With no path to clone the styling from, the honest move is to leave the
  // server's render alone rather than restate the styling in this module.
  it('leaves the element untouched and reports false with no template path', () => {
    const svg = document.createElementNS(SVG_NS, 'svg') as SVGSVGElement;
    svg.setAttribute('viewBox', '0 0 1 1');
    expect(applyFigure(svg, '-1 -1 12 22', [{ d: 'M0,0 L1,1' }])).toBe(false);
    expect(svg.getAttribute('viewBox')).toBe('0 0 1 1');
    expect(svg.querySelectorAll('path')).toHaveLength(0);
  });

  // An empty figure would otherwise blank the lane entirely.
  it('reports false and changes nothing when there are no paths', () => {
    const svg = svgWithPaths(3);
    expect(applyFigure(svg, '0 0 9 9', [])).toBe(false);
    expect(svg.querySelectorAll('path')).toHaveLength(3);
    expect(svg.getAttribute('viewBox')).toBe('0 0 1 1');
  });

  // The success signal callers branch on to decide whether to keep the SSR figure.
  it('reports true when it drew', () => {
    expect(applyFigure(svgWithPaths(1), '0 0 1 1', [{ d: 'M0,0' }])).toBe(true);
  });
});
