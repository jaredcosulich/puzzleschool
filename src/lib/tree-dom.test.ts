import { describe, expect, it } from 'vitest';
import { applyTreeGrowth } from './tree-dom';
import type { Segment } from './structures';

const SVG_NS = 'http://www.w3.org/2000/svg';

/** An SVG holding `count` styled paths, standing in for the server render. */
function svgWithPaths(count: number): SVGSVGElement {
  const svg = document.createElementNS(SVG_NS, 'svg') as SVGSVGElement;
  svg.setAttribute('viewBox', '0 0 1 1');
  for (let i = 0; i < count; i += 1) {
    const path = document.createElementNS(SVG_NS, 'path');
    path.setAttribute('d', 'M0 0 L1 1');
    path.setAttribute('stroke', 'var(--gold)');
    path.setAttribute('stroke-linecap', 'round');
    path.setAttribute('vector-effect', 'non-scaling-stroke');
    svg.appendChild(path);
  }
  return svg;
}

function segment(x1: number, y1: number, x2: number, y2: number, width = 2): Segment {
  return { from: { x: x1, y: y1 }, to: { x: x2, y: y2 }, depth: 1, width };
}

describe('applyTreeGrowth', () => {
  // The new tree has its own extents, so the frame has to move with it.
  it('reframes the viewBox around the new segments', () => {
    const svg = svgWithPaths(1);
    applyTreeGrowth(svg, [segment(0, 0, 10, 20)]);
    // treeViewBox pads by one unit on each side.
    expect(svg.getAttribute('viewBox')).toBe('-1 -1 12 22');
  });

  // Same count: the existing elements are rewritten, not replaced, so the
  // styling that lives on them survives.
  it('reuses the existing path elements when the counts match', () => {
    const svg = svgWithPaths(2);
    const before = Array.from(svg.querySelectorAll('path'));
    applyTreeGrowth(svg, [segment(0, 0, 1, 1), segment(1, 1, 2, 2)]);
    const after = Array.from(svg.querySelectorAll('path'));
    expect(after).toHaveLength(2);
    expect(after[0]).toBe(before[0]);
    expect(after[1]).toBe(before[1]);
    expect(after[0].getAttribute('d')).toBe('M0,0 L1,1');
  });

  // A bigger tree needs more paths, and the new ones must carry the styling —
  // this is why they are cloned from the server's path rather than built here.
  it('clones extra paths, carrying the styling, when the tree grew', () => {
    const svg = svgWithPaths(1);
    applyTreeGrowth(svg, [segment(0, 0, 1, 1), segment(1, 1, 2, 2), segment(2, 2, 3, 3)]);
    const paths = Array.from(svg.querySelectorAll('path'));
    expect(paths).toHaveLength(3);
    for (const path of paths) {
      expect(path.getAttribute('stroke')).toBe('var(--gold)');
      expect(path.getAttribute('vector-effect')).toBe('non-scaling-stroke');
    }
  });

  // Left in place, surplus paths would still be drawn — the old tree's outer
  // branches hanging off the new one.
  it('removes surplus paths when the tree shrank', () => {
    const svg = svgWithPaths(5);
    applyTreeGrowth(svg, [segment(0, 0, 1, 1), segment(1, 1, 2, 2)]);
    expect(svg.querySelectorAll('path')).toHaveLength(2);
  });

  // Stroke width carries the taper, so it has to be rewritten per segment.
  it('writes each segment stroke width', () => {
    const svg = svgWithPaths(2);
    applyTreeGrowth(svg, [segment(0, 0, 1, 1, 3.2), segment(1, 1, 2, 2, 1.4)]);
    const paths = Array.from(svg.querySelectorAll('path'));
    expect(paths[0].getAttribute('stroke-width')).toBe('3.2');
    expect(paths[1].getAttribute('stroke-width')).toBe('1.4');
  });

  // With no path to clone the styling from, the honest move is to leave the
  // server's render alone rather than restate the styling in this module.
  it('leaves the element untouched and reports false with no template path', () => {
    const svg = document.createElementNS(SVG_NS, 'svg') as SVGSVGElement;
    svg.setAttribute('viewBox', '0 0 1 1');
    expect(applyTreeGrowth(svg, [segment(0, 0, 10, 20)])).toBe(false);
    expect(svg.getAttribute('viewBox')).toBe('0 0 1 1');
    expect(svg.querySelectorAll('path')).toHaveLength(0);
  });

  // An empty growth would otherwise blank the lane entirely.
  it('reports false and changes nothing when there are no segments', () => {
    const svg = svgWithPaths(3);
    expect(applyTreeGrowth(svg, [])).toBe(false);
    expect(svg.querySelectorAll('path')).toHaveLength(3);
    expect(svg.getAttribute('viewBox')).toBe('0 0 1 1');
  });
});
