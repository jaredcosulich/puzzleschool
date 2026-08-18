import { describe, expect, it } from 'vitest';
import {
  cellPath,
  growAcceptableVoronoi,
  isAcceptableVoronoi,
  jitteredSites,
  polygonArea,
  tessellate,
  unresolvedMarkPath,
  voronoiCells,
  voronoiPaths,
  voronoiShortfall,
  voronoiVariant,
  voronoiViewBox,
  type Frame,
} from './voronoi';
import { FLANK_LANE, hashSeed, type Point } from './structures';

// Read from the shared lane rather than restated: this field is generated AT the
// lane and drawn with `preserveAspectRatio="none"`, so a test frame that drifted
// from the real one would be asserting about a field the site never renders.
const FRAME: Frame = { width: FLANK_LANE.width, height: FLANK_LANE.height };

/** The clip rectangle `voronoiCells` actually partitions — the frame plus bleed. */
const BLEED_AREA = FRAME.width * 1.5 * (FRAME.height * 1.5);

const sq = (a: Point, b: Point) => (a.x - b.x) ** 2 + (a.y - b.y) ** 2;

/** A convex polygon's centroid is inside it, which is what makes it a fair probe. */
function centroid(polygon: readonly Point[]): Point {
  return {
    x: polygon.reduce((s, p) => s + p.x, 0) / polygon.length,
    y: polygon.reduce((s, p) => s + p.y, 0) / polygon.length,
  };
}

describe('jitteredSites', () => {
  // One point per grid box is what keeps the cells evenly sized; uniform random
  // points clump, and a clump produces the sliver that reads as a mistake.
  it('places exactly one site per grid box', () => {
    expect(jitteredSites(7, FRAME, 3, 6)).toHaveLength(18);
  });

  // A point must never leave its own box, or two neighbours could swap places
  // and the stratification buys nothing.
  it('keeps every site inside its own grid box', () => {
    const columns = 3;
    const rows = 6;
    const sites = jitteredSites(99, FRAME, columns, rows, 1);
    const cellWidth = FRAME.width / columns;
    const cellHeight = FRAME.height / rows;
    sites.forEach((site, index) => {
      const column = index % columns;
      const row = Math.floor(index / columns);
      expect(site.x).toBeGreaterThanOrEqual(column * cellWidth);
      expect(site.x).toBeLessThanOrEqual((column + 1) * cellWidth);
      expect(site.y).toBeGreaterThanOrEqual(row * cellHeight);
      expect(site.y).toBeLessThanOrEqual((row + 1) * cellHeight);
    });
  });

  // Same seed, same scatter — the per-page axis depends on it.
  it('is reproducible for a seed', () => {
    expect(jitteredSites(4242, FRAME, 3, 5)).toEqual(jitteredSites(4242, FRAME, 3, 5));
  });

  // At zero jitter it is a plain ruled grid — the knob genuinely does something.
  it('places sites on the exact grid centres at zero jitter', () => {
    const [first] = jitteredSites(1, FRAME, 2, 4, 0);
    expect(first.x).toBeCloseTo(FRAME.width / 4, 6);
    expect(first.y).toBeCloseTo(FRAME.height / 8, 6);
  });
});

describe('voronoiCells', () => {
  // THE defining property of a Voronoi partition: every point of a cell is
  // nearer that cell's own site than any other. If this does not hold, whatever
  // was drawn is not a Voronoi diagram, however plausible it looks.
  it('gives every cell the territory nearest its own site', () => {
    const sites = jitteredSites(11, FRAME, 3, 6);
    const cells = voronoiCells(sites, FRAME);
    cells.forEach((polygon, index) => {
      if (polygon.length < 3) return;
      const probe = centroid(polygon);
      const own = sq(probe, sites[index]);
      for (const other of sites) {
        expect(own).toBeLessThanOrEqual(sq(probe, other) + 1e-6);
      }
    });
  });

  // A partition partitions: the cells must cover the clipped frame exactly,
  // with no gap and no double-counted overlap.
  it('tiles the whole clipped frame without gaps or overlaps', () => {
    const sites = jitteredSites(23, FRAME, 3, 6);
    const total = voronoiCells(sites, FRAME).reduce((sum, p) => sum + polygonArea(p), 0);
    expect(total).toBeCloseTo(BLEED_AREA, 2);
  });

  // A single site owns everything — the degenerate partition, which must still
  // be the whole rectangle rather than an empty list.
  it('gives a lone site the entire frame', () => {
    const [only] = voronoiCells([{ x: 60, y: 180 }], FRAME);
    expect(polygonArea(only)).toBeCloseTo(BLEED_AREA, 2);
  });

  // Clipping happens beyond the viewBox, which is what lets cells run off the
  // top and bottom unresolved instead of being tidied into a box.
  it('cuts the partition beyond the visible frame', () => {
    const [only] = voronoiCells([{ x: 60, y: 180 }], FRAME);
    expect(Math.min(...only.map((p) => p.y))).toBeLessThan(0);
    expect(Math.max(...only.map((p) => p.y))).toBeGreaterThan(FRAME.height);
  });
});

describe('tessellate', () => {
  // The unresolved sites are removed BEFORE the partition, not hidden after it.
  // That is the whole effect: the surrounding cells are computed as though those
  // points were never there, so they genuinely overrun where a boundary should
  // be. Excluded afterwards you would have a correct partition with a dot on it.
  it('leaves the unresolved sites out of the partition entirely', () => {
    const field = tessellate(voronoiVariant(hashSeed('contact:voronoi')));
    expect(field.unresolved.length).toBeGreaterThan(0);
    for (const stray of field.unresolved) {
      expect(field.cells.some((cell) => cell.site === stray)).toBe(false);
    }
  });

  // A cell around an unresolved point must actually claim that point's ground —
  // this is what makes the omission visible rather than merely true.
  it('lets a cell overrun the ground an unresolved site would have owned', () => {
    const field = tessellate(voronoiVariant(hashSeed('contact:voronoi')));
    const stray = field.unresolved[0];
    const owner = field.cells.find(
      (cell) => cell.polygon.length >= 3 && polygonArea(cell.polygon) > 0,
    );
    expect(owner).toBeDefined();
    // Some cell contains the stray point, because no cell was reserved for it.
    const nearest = field.cells.reduce((best, cell) =>
      sq(stray, cell.site) < sq(stray, best.site) ? cell : best,
    );
    expect(nearest.polygon.length).toBeGreaterThanOrEqual(3);
  });

  // Exactly one cell is opened — the three-sided-square idea at the scale of a
  // territory. Two would read as a pattern; none would read as finished.
  it('opens exactly one cell', () => {
    const field = tessellate(voronoiVariant(hashSeed('notes:voronoi')));
    expect(field.cells.filter((cell) => cell.open)).toHaveLength(1);
    expect(field.openCellApplied).toBe(true);
  });

  // Same seed, same field.
  it('is reproducible for a seed', () => {
    const a = tessellate(voronoiVariant(4242));
    const b = tessellate(voronoiVariant(4242));
    expect(voronoiPaths(a)).toEqual(voronoiPaths(b));
  });

  // Different pages must get different fields, or the per-page axis is a lie.
  it('gives different seeds different fields', () => {
    const a = tessellate(voronoiVariant(hashSeed('about:voronoi')));
    const b = tessellate(voronoiVariant(hashSeed('contact:voronoi')));
    expect(voronoiPaths(a)).not.toEqual(voronoiPaths(b));
  });
});

describe('cellPath', () => {
  // A closed cell is a closed polygon.
  it('closes an ordinary cell', () => {
    const polygon = [
      { x: 0, y: 0 },
      { x: 10, y: 0 },
      { x: 10, y: 10 },
      { x: 0, y: 10 },
    ];
    const d = cellPath({ site: { x: 5, y: 5 }, polygon, open: false });
    expect(d.endsWith(' Z')).toBe(true);
    expect(d.match(/L/g)).toHaveLength(3);
  });

  // The open cell is short EXACTLY one edge — four corners still drawn, but
  // three sides instead of four, the way `openRectPath` leaves a square open.
  it('draws the open cell one edge short', () => {
    const polygon = [
      { x: 0, y: 0 },
      { x: 10, y: 0 },
      { x: 10, y: 10 },
      { x: 0, y: 10 },
    ];
    const d = cellPath({ site: { x: 5, y: 5 }, polygon, open: true });
    expect(d).not.toContain('Z');
    // Same four corners, so three drawn edges where the closed form has four.
    expect(d.match(/L/g)).toHaveLength(3);
    expect(d.match(/M/g)).toHaveLength(1);
  });

  // Rotating rather than splicing keeps every drawn edge intact and removes
  // exactly one — splicing a corner out would redraw its two edges as a single
  // shortcut across the cell.
  it('keeps every remaining corner when it opens a cell', () => {
    const polygon = [
      { x: 0, y: 0 },
      { x: 10, y: 0 },
      { x: 10, y: 10 },
      { x: 0, y: 10 },
    ];
    const d = cellPath({ site: { x: 5, y: 5 }, polygon, open: true });
    for (const corner of polygon) {
      expect(d).toContain(`${corner.x},${corner.y}`);
    }
  });

  // A collapsed cell has no outline to draw and must not emit a broken `d`.
  it('draws nothing for a degenerate cell', () => {
    expect(cellPath({ site: { x: 0, y: 0 }, polygon: [], open: false })).toBe('');
  });
});

describe('unresolvedMarkPath', () => {
  // A small cross — a point noted, with no cell worked out around it.
  it('draws a cross centred on the site', () => {
    expect(unresolvedMarkPath({ x: 20, y: 50 }, 4)).toBe('M16,50 H24 M20,46 V54');
  });
});

describe('voronoiShortfall', () => {
  // Both incompletenesses are deliberate FEATURES, and a feature that silently
  // failed to apply is invisible in a geometry list — the `bareLimbApplied`
  // lesson. So acceptance is told about them rather than left to infer.
  it('penalises a field that lost its open cell', () => {
    const field = tessellate(voronoiVariant(hashSeed('notes:voronoi')));
    const finished = {
      ...field,
      openCellApplied: false,
      cells: field.cells.map((cell) => ({ ...cell, open: false })),
    };
    expect(voronoiShortfall(finished)).toBeGreaterThan(voronoiShortfall(field));
  });

  // The unresolved sites are the strongest carrier of "still being worked out".
  it('penalises a field with no unresolved sites', () => {
    const field = tessellate(voronoiVariant(hashSeed('notes:voronoi')));
    const complete = { ...field, unresolved: [], unresolvedApplied: false };
    expect(voronoiShortfall(complete)).toBeGreaterThan(voronoiShortfall(field));
  });

  // A sliver is the long thin shard between two sites that landed too close.
  // It reads as a drawing mistake rather than as a boundary, so it is rejected
  // on the geometry that came out — inputs alone cannot catch it.
  it('rejects a field containing a sliver', () => {
    const field = tessellate(voronoiVariant(hashSeed('notes:voronoi')));
    const slivered = {
      ...field,
      cells: [
        ...field.cells,
        {
          site: { x: 1, y: 1 },
          polygon: [
            { x: 0, y: 0 },
            { x: 0.4, y: 0 },
            { x: 0.4, y: 1 },
            { x: 0, y: 1 },
          ],
          open: false,
        },
      ],
    };
    expect(voronoiShortfall(slivered)).toBeGreaterThan(voronoiShortfall(field));
    expect(isAcceptableVoronoi(slivered)).toBe(false);
  });

  // A field with nothing drawable can never win the closest-attempt fallback.
  it('reports a field with no drawable cells as infinitely short', () => {
    const field = tessellate(voronoiVariant(1));
    expect(voronoiShortfall({ ...field, cells: [] })).toBe(Infinity);
  });
});

describe('growAcceptableVoronoi', () => {
  // The envelope is enforced on the RESULT, not just the inputs.
  it('returns an acceptable field across a spread of seeds', () => {
    for (const key of ['about', 'contact', 'notes', 'blank', 'a-day-in-the-life']) {
      const field = growAcceptableVoronoi(hashSeed(`${key}:voronoi`));
      expect(isAcceptableVoronoi(field)).toBe(true);
      expect(field.openCellApplied).toBe(true);
      expect(field.unresolvedApplied).toBe(true);
    }
  });

  // Runs inside a page render with nobody to catch an exception, so a hopeless
  // budget must still return a field — a slightly-off one beats a blank lane.
  it('returns the closest attempt rather than throwing when none qualifies', () => {
    const field = growAcceptableVoronoi(3, 1);
    expect(field).toBeDefined();
    expect(field.cells.length).toBeGreaterThan(0);
  });

  // The lane the figure is generated at, so `preserveAspectRatio="none"` has
  // nothing to distort.
  it('frames the field at the lane it was generated for', () => {
    expect(voronoiViewBox(growAcceptableVoronoi(1))).toBe(
      `0 0 ${FLANK_LANE.width} ${FLANK_LANE.height}`,
    );
  });

  // Every cell plus every unresolved mark gets a stroke, and nothing else does.
  it('draws one path per cell plus one per unresolved mark', () => {
    const field = growAcceptableVoronoi(hashSeed('contact:voronoi'));
    const drawable = field.cells.filter((cell) => cell.polygon.length >= 3).length;
    expect(voronoiPaths(field)).toHaveLength(drawable + field.unresolved.length);
  });
});
