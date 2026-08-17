// The Voronoi tessellation — space partitioned by nearest neighbour.
//
// Give a plane a scatter of points and ask, for every position, which point is
// closest: the answer carves the plane into cells, one per point, and the walls
// between them are the perpendicular bisectors. It is not a decorative pattern —
// it is how territory actually gets divided when things grow outward at the same
// rate from where they started. Soap froth settles into it. So do crystal grains
// in cooling metal, a giraffe's coat, and the crowns of trees in a closed canopy,
// which stop exactly where they meet a neighbour.
//
// Built by CLIPPING rather than by triangulation: each cell starts as the whole
// frame and is cut back by the half-plane of the bisector against every other
// site (Sutherland–Hodgman). That is O(n²), which at the fifteen-odd sites this
// lane holds is nothing, and it keeps the module free of a Delaunay dependency
// for a figure that is decorative.
//
// The incompleteness — every structure on this site is deliberately unfinished —
// is carried two ways, and the second is the stronger:
//
//   - `openCell`: one cell is drawn one edge short, the same idea as
//     `openRectPath`'s three-sided square. A boundary somebody has not closed.
//   - `unresolvedSites`: one or two points are placed and marked but EXCLUDED
//     from the partition entirely, so the cells around them have visibly not
//     accounted for them. A partition that does not yet know about some of its
//     own points is the clearest way to say "still being worked out" — the cells
//     nearby are simply wrong, and they are wrong in a way you can check.
//
// Everything here is pure: numbers in, geometry out. No DOM, no Astro.
import { outOfBand, round, seededRandom, type Point } from './structures';
import type { FigurePath } from './figure-dom';

/** The rectangle the partition is cut out of. */
export interface Frame {
  width: number;
  height: number;
}

export interface VoronoiCell {
  /** The point this cell is the territory of. */
  site: Point;
  /** Its corners, in order. */
  polygon: Point[];
  /** True when this cell is drawn one edge short — the boundary left open. */
  open: boolean;
}

export interface VoronoiTessellation {
  cells: VoronoiCell[];
  /**
   * Sites placed but deliberately left OUT of the partition. Drawn as bare
   * marks; the cells around them do not know they exist.
   */
  unresolved: Point[];
  /**
   * Whether the open cell actually landed. A deliberate feature that silently
   * failed to apply is invisible in a geometry list — the `bareLimbApplied`
   * lesson — so acceptance has to be told rather than left to infer.
   */
  openCellApplied: boolean;
  /** Whether any site was actually left unresolved, for the same reason. */
  unresolvedApplied: boolean;
  frame: Frame;
}

// ---------------------------------------------------------------------------
// Sites
// ---------------------------------------------------------------------------

/**
 * A jittered grid of points — stratified sampling, not uniform random.
 *
 * Uniform random points clump, and a clump produces SLIVER cells: long thin
 * shards between two sites that happened to land close together. A sliver reads
 * as a mistake in the drawing rather than as a partition, which is the opposite
 * of what this figure is for. Dividing the frame into equal boxes and jittering
 * one point inside each keeps the cells recognisably the same size while still
 * looking placed rather than ruled.
 */
export function jitteredSites(
  seed: number,
  frame: Frame,
  columns: number,
  rows: number,
  jitter = 0.7,
): Point[] {
  const rand = seededRandom(seed);
  const cellWidth = frame.width / columns;
  const cellHeight = frame.height / rows;
  const sites: Point[] = [];

  for (let row = 0; row < rows; row += 1) {
    for (let column = 0; column < columns; column += 1) {
      // Centred in its box, then displaced by up to half a box times `jitter` —
      // so at jitter 1 a point may reach its box's edge but never cross it, and
      // two neighbours can never swap places.
      sites.push({
        x: (column + 0.5) * cellWidth + (rand() - 0.5) * cellWidth * jitter,
        y: (row + 0.5) * cellHeight + (rand() - 0.5) * cellHeight * jitter,
      });
    }
  }
  return sites;
}

// ---------------------------------------------------------------------------
// The partition
// ---------------------------------------------------------------------------

/**
 * Clip a convex polygon to the half-plane where `edge` is negative, cutting new
 * corners where the boundary crosses it. `edge` is any linear function of the
 * point; its zero set is the cutting line.
 */
function clipHalfPlane(polygon: readonly Point[], edge: (p: Point) => number): Point[] {
  const output: Point[] = [];

  for (let i = 0; i < polygon.length; i += 1) {
    const current = polygon[i];
    const next = polygon[(i + 1) % polygon.length];
    const dCurrent = edge(current);
    const dNext = edge(next);

    if (dCurrent <= 0) output.push(current);
    // Sign change means the boundary crosses the line between these two
    // corners, so the crossing becomes a new corner.
    if (dCurrent * dNext < 0) {
      const t = dCurrent / (dCurrent - dNext);
      output.push({
        x: current.x + t * (next.x - current.x),
        y: current.y + t * (next.y - current.y),
      });
    }
  }
  return output;
}

/**
 * The cell belonging to `site`: the frame cut back by the perpendicular bisector
 * against every other site.
 *
 * The bisector between `site` and `other` is where the two squared distances are
 * equal. Expanded, that difference is LINEAR in the point — the quadratic terms
 * cancel — which is why a half-plane clip is enough and no curve fitting is
 * involved.
 */
function cellFor(site: Point, others: readonly Point[], rect: readonly Point[]): Point[] {
  let polygon = [...rect];
  for (const other of others) {
    if (other === site) continue;
    polygon = clipHalfPlane(polygon, (p) => {
      const toSite = (p.x - site.x) ** 2 + (p.y - site.y) ** 2;
      const toOther = (p.x - other.x) ** 2 + (p.y - other.y) ** 2;
      return toSite - toOther;
    });
    if (polygon.length === 0) break;
  }
  return polygon;
}

/**
 * How far past the visible frame the partition is actually cut.
 *
 * The lane's own frame is NOT stroked, and this is how: cells are clipped to a
 * rectangle larger than the viewBox, so the straight edges where the clipping
 * happened fall outside what is drawn. What the visitor sees is cells running
 * off the top and bottom unresolved, rather than a tessellation tidied into a
 * box — a partition of somewhere larger, seen through a window.
 */
const BLEED = 0.25;

/** Every cell of the partition of `frame` by `sites`. */
export function voronoiCells(sites: readonly Point[], frame: Frame): Point[][] {
  const padX = frame.width * BLEED;
  const padY = frame.height * BLEED;
  const rect: Point[] = [
    { x: -padX, y: -padY },
    { x: frame.width + padX, y: -padY },
    { x: frame.width + padX, y: frame.height + padY },
    { x: -padX, y: frame.height + padY },
  ];
  return sites.map((site) => cellFor(site, sites, rect));
}

/**
 * Area of a simple polygon, via the shoelace formula.
 *
 * Exported because it is how the partition's DEFINING property is checked: the
 * cells must tile the frame, so their areas must sum to it. Kept private, that
 * check could only be approximated by counting cells, which a slivered field
 * passes just as happily as a good one.
 */
export function polygonArea(polygon: readonly Point[]): number {
  let sum = 0;
  for (let i = 0; i < polygon.length; i += 1) {
    const a = polygon[i];
    const b = polygon[(i + 1) % polygon.length];
    sum += a.x * b.y - b.x * a.y;
  }
  return Math.abs(sum) / 2;
}

// ---------------------------------------------------------------------------
// The envelope
// ---------------------------------------------------------------------------

interface Range {
  readonly min: number;
  readonly max: number;
  readonly integer?: boolean;
}

export interface VoronoiOptions {
  columns: number;
  rows: number;
  jitter: number;
  /** How many sites to leave out of the partition entirely. */
  unresolvedCount: number;
  frame: Frame;
  seed: number;
}

/**
 * The bounds every field is drawn from — the variation envelope, in the shape
 * `TREE_ENVELOPE` established.
 *
 * The grid is deliberately tall and narrow: the lane is 123×365, and a partition
 * whose cells are roughly square needs about three times as many rows as
 * columns to fill it without stretching.
 */
export const VORONOI_ENVELOPE = {
  ranges: {
    columns: { min: 2, max: 3, integer: true },
    rows: { min: 5, max: 7, integer: true },
    jitter: { min: 0.5, max: 0.85 },
    unresolvedCount: { min: 1, max: 2, integer: true },
  },
  fixed: {
    width: 123,
    height: 365,
  },
} as const satisfies {
  ranges: Record<string, Range>;
  fixed: Record<string, number>;
};

/**
 * Map an arbitrary seed onto one bounded option set. Values are drawn in a FIXED
 * ORDER; the sequence is what makes a seed reproducible.
 */
export function voronoiVariant(seed: number): VoronoiOptions {
  const rand = seededRandom(seed);
  const draw = (range: Range): number => {
    const value = range.min + rand() * (range.max - range.min);
    return range.integer ? Math.round(value) : value;
  };
  const r = VORONOI_ENVELOPE.ranges;

  return {
    columns: draw(r.columns),
    rows: draw(r.rows),
    jitter: draw(r.jitter),
    unresolvedCount: draw(r.unresolvedCount),
    frame: { width: VORONOI_ENVELOPE.fixed.width, height: VORONOI_ENVELOPE.fixed.height },
    seed,
  };
}

/**
 * Build one field: place the sites, set some aside unresolved, partition what is
 * left, and open one cell.
 *
 * The unresolved sites are removed BEFORE the partition, not hidden after it.
 * That is the whole effect — their neighbours' cells are computed as though they
 * were never there, so the cells genuinely overrun where a boundary should be.
 * Excluding them afterwards would leave a correct partition with a dot on it,
 * which says nothing.
 */
export function tessellate(options: VoronoiOptions): VoronoiTessellation {
  const { columns, rows, jitter, unresolvedCount, frame, seed } = options;
  const all = jitteredSites(seed, frame, columns, rows, jitter);
  const rand = seededRandom(seed ^ 0x9e3779b9);

  // Chosen from the interior where possible: an unresolved site at the very edge
  // is half off-frame and its absence barely shows.
  const interior = all
    .map((site, index) => ({ site, index }))
    .filter(({ site }) => site.y > frame.height * 0.15 && site.y < frame.height * 0.85);
  const pool = interior.length >= unresolvedCount ? interior : all.map((site, index) => ({ site, index }));

  const unresolvedIndices = new Set<number>();
  for (let i = 0; i < unresolvedCount && unresolvedIndices.size < pool.length; i += 1) {
    let pick = pool[Math.floor(rand() * pool.length) % pool.length].index;
    // Linear probe rather than a reject-and-retry loop: bounded, and the pool is
    // small enough that a collision is common.
    let guard = 0;
    while (unresolvedIndices.has(pick) && guard < pool.length) {
      pick = pool[(pool.findIndex((p) => p.index === pick) + 1) % pool.length].index;
      guard += 1;
    }
    unresolvedIndices.add(pick);
  }

  const unresolved = all.filter((_, index) => unresolvedIndices.has(index));
  const partitioned = all.filter((_, index) => !unresolvedIndices.has(index));
  const polygons = voronoiCells(partitioned, frame);

  // The open cell is chosen from the ones actually VISIBLE in the frame — an
  // opened edge outside the viewBox is an opened edge nobody can see.
  const visible = polygons
    .map((polygon, index) => ({ polygon, index }))
    .filter(
      ({ polygon, index }) =>
        polygon.length >= 3 &&
        partitioned[index].y > frame.height * 0.12 &&
        partitioned[index].y < frame.height * 0.88,
    );
  const openIndex = visible.length > 0 ? visible[Math.floor(rand() * visible.length) % visible.length].index : -1;

  return {
    cells: polygons.map((polygon, index) => ({
      site: partitioned[index],
      polygon,
      open: index === openIndex,
    })),
    unresolved,
    openCellApplied: openIndex >= 0,
    unresolvedApplied: unresolved.length > 0,
    frame,
  };
}

// ---------------------------------------------------------------------------
// Acceptance
// ---------------------------------------------------------------------------

/** Fewer and the lane looks empty; more and the cells are too small to read. */
const CELL_BAND = { min: 8, max: 22 };

/**
 * A cell this far below the mean area is a sliver — the shard that reads as a
 * drawing mistake rather than as a boundary.
 */
const SLIVER_RATIO = 0.18;

/**
 * HOW FAR a field is from acceptable, as a single number — 0 exactly when it
 * passes every rule. Same shape as `treeShortfall`, and for the same reason.
 */
export function voronoiShortfall(field: VoronoiTessellation): number {
  const drawn = field.cells.filter((cell) => cell.polygon.length >= 3);
  if (drawn.length === 0) return Infinity;

  let shortfall = 0;

  shortfall += outOfBand(drawn.length, CELL_BAND.min, CELL_BAND.max) / CELL_BAND.max;

  // Both deliberate features, weighted heavily: a field that lost its open cell
  // or its unresolved sites is a finished diagram, which is the one thing this
  // figure must not be.
  if (!field.openCellApplied) shortfall += 1;
  if (!field.unresolvedApplied) shortfall += 1;

  const areas = drawn.map((cell) => polygonArea(cell.polygon));
  const mean = areas.reduce((sum, a) => sum + a, 0) / areas.length;
  const smallest = Math.min(...areas);
  shortfall += Math.max(0, SLIVER_RATIO - smallest / mean) / SLIVER_RATIO;

  return shortfall;
}

/** The envelope enforced on the RESULT, not just on the inputs. */
export function isAcceptableVoronoi(field: VoronoiTessellation): boolean {
  return voronoiShortfall(field) === 0;
}

/**
 * Build a field for `seed` that passes `isAcceptableVoronoi`, resampling from a
 * derived seed when it does not. Falls back to the CLOSEST attempt rather than
 * throwing, exactly as `growAcceptableTree` does.
 */
export function growAcceptableVoronoi(seed: number, attempts = 20): VoronoiTessellation {
  let best: VoronoiTessellation | null = null;
  let bestShortfall = Infinity;
  let current = seed >>> 0;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const field = tessellate(voronoiVariant(current));
    const shortfall = voronoiShortfall(field);
    if (shortfall === 0) return field;
    if (shortfall < bestShortfall) {
      best = field;
      bestShortfall = shortfall;
    }
    current = (Math.imul(current, 2654435761) + attempt) >>> 0;
  }

  return best as VoronoiTessellation;
}

// ---------------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------------

/**
 * A cell's outline. A closed cell is a polygon; the OPEN one is the same corners
 * rotated so the missing edge is the closing one, then left unclosed — three
 * sides of a square, at the scale of a territory.
 */
export function cellPath(cell: VoronoiCell, dropEdge = 0): string {
  const { polygon, open } = cell;
  if (polygon.length < 3) return '';

  const corners = open
    ? // Rotating rather than splicing keeps every EDGE that is drawn intact and
      // removes exactly one — splicing a corner out would silently redraw its two
      // edges as a single shortcut across the cell.
      polygon.slice((dropEdge + 1) % polygon.length).concat(polygon.slice(0, (dropEdge + 1) % polygon.length))
    : polygon;

  const d = corners.map((p, i) => `${i === 0 ? 'M' : 'L'}${round(p.x)},${round(p.y)}`).join(' ');
  return open ? d : `${d} Z`;
}

/** A site with no cell yet: a small cross, the way an unplotted point gets marked. */
export function unresolvedMarkPath(site: Point, size = 4): string {
  const { x, y } = site;
  return `M${round(x - size)},${round(y)} H${round(x + size)} M${round(x)},${round(y - size)} V${round(y + size)}`;
}

/**
 * Every stroke of the field, in draw order — cells first, then the unresolved
 * marks on top. Shared by the server render and the per-visit regrow so the two
 * cannot drift into drawing the same field differently.
 */
export function voronoiPaths(field: VoronoiTessellation): FigurePath[] {
  const cells = field.cells
    .map((cell) => cellPath(cell))
    .filter((d) => d.length > 0)
    .map((d) => ({ d }));
  const marks = field.unresolved.map((site) => ({ d: unresolvedMarkPath(site) }));
  return [...cells, ...marks];
}

/** The viewBox that frames the field: the lane itself, so cells run off its edges. */
export function voronoiViewBox(field: VoronoiTessellation): string {
  return `0 0 ${field.frame.width} ${field.frame.height}`;
}
