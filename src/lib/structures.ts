// The line structures, generated from the rules that define them.
//
// The design handoff is explicit that these must be GENERATED, not pasted as
// path data, and the reason is not tidiness. Every structure is deliberately
// left incomplete — a limb ends bare, a curve stops before it closes — because
// incompleteness carries the school's "one piece is always missing" idea. Frozen
// path data can only ever be missing the piece it was exported missing. Here the
// cut is a parameter (`fraction`, `openLast`, `bareLimb`), so the idea stays
// adjustable and, more importantly, stays legible to the next person reading it.
//
// Everything below is pure: numbers in, path strings out. No DOM, no Astro, no
// framework — so these are unit-testable on their own.

/** A point in SVG user space. */
export interface Point {
  x: number;
  y: number;
}

/** Join points into an SVG polyline `d` attribute. */
export function toPath(points: readonly Point[]): string {
  if (points.length === 0) return '';
  const [first, ...rest] = points;
  return `M${round(first.x)},${round(first.y)}${rest
    .map((p) => ` L${round(p.x)},${round(p.y)}`)
    .join('')}`;
}

/** Trim float noise so generated paths stay readable in devtools. */
function round(n: number): number {
  return Math.round(n * 100) / 100;
}

// ---------------------------------------------------------------------------
// Sine field — the rule under the home masthead
// ---------------------------------------------------------------------------

export interface SineOptions {
  /** Full width of the field in user units. */
  width: number;
  /** Peak displacement from the baseline. */
  amplitude: number;
  /** Horizontal distance of one full cycle. */
  period: number;
  /** Vertical centre. */
  baseline: number;
  /**
   * How much of the width to actually draw, 0–1. Below 1 the wave stops short
   * of the frame — the incompleteness knob. Defaults to a full traverse, which
   * the frame itself then truncates mid-cycle.
   */
  fraction?: number;
  /** Sampling interval; smaller is smoother and produces a longer path. */
  step?: number;
}

/**
 * One sine wave sampled across the width. Phase is fixed so every wave starts on
 * the baseline heading upward — that shared origin is what makes three waves of
 * different amplitude and period read as one instrument rather than three.
 */
export function sinePath({
  width,
  amplitude,
  period,
  baseline,
  fraction = 1,
  step = 2,
}: SineOptions): string {
  const end = width * fraction;
  const points: Point[] = [];
  for (let x = 0; x <= end; x += step) {
    points.push({ x, y: baseline - amplitude * Math.sin((2 * Math.PI * x) / period) });
  }
  // Always land exactly on the end, whatever the step leaves over.
  if (points[points.length - 1]?.x !== end) {
    points.push({ x: end, y: baseline - amplitude * Math.sin((2 * Math.PI * end) / period) });
  }
  return toPath(points);
}

// ---------------------------------------------------------------------------
// Fibonacci square tiling — the structure growing out of the Contact card
// ---------------------------------------------------------------------------

export interface Rect {
  x: number;
  y: number;
  size: number;
}

export interface FibonacciTiling {
  /** Closed squares, smallest first. */
  rects: Rect[];
  /** The final square, drawn as three sides — the piece left open. */
  open: Rect | null;
  /** Bounding box of the whole tiling. */
  width: number;
  height: number;
}

/**
 * The Fibonacci square spiral, built the way the sequence itself is built: each
 * square's side is the sum of the previous two, and each is attached to the
 * growing bounding box on a rotating side. Starting from two equal unit squares
 * side by side, the attachment cycle is below → left → above → right, repeating.
 *
 * The last square is returned separately because the design draws it as an open
 * three-sided rectangle. That is the missing piece at the largest scale: the
 * spiral's own frame never closes.
 */
export function fibonacciTiling(count: number, unit = 13, openLast = true): FibonacciTiling {
  if (count < 2) return { rects: [], open: null, width: 0, height: 0 };

  // Two seed squares, side by side.
  const rects: Rect[] = [
    { x: 0, y: 0, size: unit },
    { x: unit, y: 0, size: unit },
  ];
  let box = { minX: 0, minY: 0, maxX: unit * 2, maxY: unit };
  let [prev, curr] = [unit, unit];

  const SIDES = ['below', 'left', 'above', 'right'] as const;

  for (let i = 2; i < count; i += 1) {
    const size = prev + curr;
    [prev, curr] = [curr, size];

    const side = SIDES[(i - 2) % SIDES.length];
    let rect: Rect;
    if (side === 'below') {
      rect = { x: box.minX, y: box.maxY, size };
      box = { ...box, maxY: box.maxY + size };
    } else if (side === 'left') {
      rect = { x: box.minX - size, y: box.maxY - size, size };
      box = { ...box, minX: box.minX - size };
    } else if (side === 'above') {
      rect = { x: box.minX, y: box.minY - size, size };
      box = { ...box, minY: box.minY - size };
    } else {
      rect = { x: box.maxX, y: box.minY, size };
      box = { ...box, maxX: box.maxX + size };
    }
    rects.push(rect);
  }

  // Normalise so the tiling sits at the origin.
  const shifted = rects.map((r) => ({ x: r.x - box.minX, y: r.y - box.minY, size: r.size }));
  const open = openLast ? (shifted.pop() ?? null) : null;

  return {
    rects: shifted,
    open,
    width: box.maxX - box.minX,
    height: box.maxY - box.minY,
  };
}

/** The three drawn sides of an open square: down the left, across, back up. */
export function openRectPath(rect: Rect): string {
  const { x, y, size } = rect;
  return `M${round(x)},${round(y)} V${round(y + size)} H${round(x + size)} V${round(y)}`;
}

// ---------------------------------------------------------------------------
// L-systems — Koch and the dragon curve
// ---------------------------------------------------------------------------

export type LSystemRules = Record<string, string>;

/** Expand an axiom by applying the production rules `iterations` times. */
export function lsystem(axiom: string, rules: LSystemRules, iterations: number): string {
  let s = axiom;
  for (let i = 0; i < iterations; i += 1) {
    s = [...s].map((ch) => rules[ch] ?? ch).join('');
  }
  return s;
}

export interface TurtleOptions {
  /** Turn angle in degrees for `+` and `-`. */
  angle: number;
  /** Distance travelled per forward command. */
  step: number;
  /** Initial heading in degrees; 0 points along +x. */
  heading?: number;
  /** Starting point. */
  origin?: Point;
  /**
   * Fraction of the forward moves to actually walk, 0–1. Below 1 the curve stops
   * before it closes — this is what makes a fragment a fragment.
   */
  fraction?: number;
}

/**
 * Walk an L-system string as turtle graphics and return the points visited.
 * `F` and `G` move forward, `+`/`-` turn, everything else (the dragon's `X`/`Y`)
 * is a bookkeeping symbol with no geometry.
 */
export function turtle(commands: string, options: TurtleOptions): Point[] {
  const { angle, step, heading = 0, origin = { x: 0, y: 0 }, fraction = 1 } = options;

  const forwards = [...commands].filter((c) => c === 'F' || c === 'G').length;
  const limit = Math.max(1, Math.floor(forwards * fraction));

  const points: Point[] = [{ ...origin }];
  let { x, y } = origin;
  let dir = heading;
  let walked = 0;

  for (const ch of commands) {
    if (ch === '+') dir += angle;
    else if (ch === '-') dir -= angle;
    else if (ch === 'F' || ch === 'G') {
      if (walked >= limit) break;
      const rad = (dir * Math.PI) / 180;
      x += step * Math.cos(rad);
      y += step * Math.sin(rad);
      points.push({ x, y });
      walked += 1;
    }
  }
  return points;
}

/** The Koch curve: every segment becomes four, turning ±60°. */
export function kochPoints(iterations: number, options: Omit<TurtleOptions, 'angle'>): Point[] {
  return turtle(lsystem('F', { F: 'F+F--F+F' }, iterations), { ...options, angle: 60 });
}

/** The dragon curve: a right-angle fold repeated, never self-intersecting. */
export function dragonPoints(iterations: number, options: Omit<TurtleOptions, 'angle'>): Point[] {
  return turtle(lsystem('FX', { X: 'X+YF+', Y: '-FX-Y' }, iterations), { ...options, angle: 90 });
}

// ---------------------------------------------------------------------------
// Binary branching tree — the structure standing between the About columns
// ---------------------------------------------------------------------------

export interface Segment {
  from: Point;
  to: Point;
  depth: number;
  /** Stroke width for this segment — limbs taper as they divide. */
  width: number;
}

/**
 * A small deterministic PRNG (mulberry32).
 *
 * The tree needs to look irregular, but this is a STATIC site: `Math.random()`
 * would redraw every structure on every build, so each deploy would churn every
 * committed screenshot and no scenario could ever be reported "unchanged". A
 * seeded generator gives the same irregularity every time — organic to look at,
 * reproducible to build. Change the seed to get a different tree; leave it and
 * the tree is a fixed asset.
 */
export function seededRandom(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/**
 * FNV-1a, 32-bit — a page slug turned into a tree seed.
 *
 * This is what makes the per-page axis free: `about`, `contact` and a page a CMS
 * editor writes next year each hash to their own number, so each grows its own
 * tree with no code change. It must be stable across builds and platforms —
 * hence an explicit algorithm rather than anything host-provided — because an
 * unstable hash would redraw every committed screenshot on every deploy.
 */
export function hashSeed(text: string): number {
  let hash = 0x811c9dc5;
  for (let i = 0; i < text.length; i += 1) {
    hash ^= text.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

/**
 * A fresh seed for the per-visit regrow.
 *
 * Deliberately the same unsigned 32-bit space `hashSeed` produces, so a tree
 * grown in the browser is drawn from exactly the same distribution as one grown
 * at build time from a page slug. If the two ranges drifted apart, the visit
 * trees would quietly become a different population from the page trees.
 */
export function randomTreeSeed(): number {
  return Math.floor(Math.random() * 2 ** 32);
}

/**
 * Which seed a tree should grow from, given what the caller supplied.
 *
 * The precedence is the whole point: an explicit `seed` wins (the variations
 * sheet pins specific ones), otherwise the key is hashed, and a caller that
 * names nothing falls back to a single shared `'default'` tree rather than a
 * random one — an unseeded component should be stable across builds, not
 * different every time.
 */
export function resolveTreeSeed(seed?: number, seedKey?: string): number {
  return seed ?? hashSeed(seedKey ?? 'default');
}

interface TreeRange {
  readonly min: number;
  readonly max: number;
  /** Rounded to a whole number after sampling. */
  readonly integer?: boolean;
}

/**
 * The bounds every generated tree is drawn from — the variation envelope, as one
 * readable object.
 *
 * The trees vary per page and per visit, but they must stay recognisably the
 * same species. Free-form randomisation of `TreeOptions` would eventually
 * produce a bald stick or a shrub; sampling from declared ranges makes "within
 * some constraints" a testable object rather than a hope.
 *
 * `fixed` is held constant deliberately: those four set the WEIGHT and SCALE of
 * the drawing. Varying them changes how the figure sits in its 123×365 lane
 * rather than how it grew, which is a layout change wearing a variation costume.
 */
export const TREE_ENVELOPE = {
  ranges: {
    depth: { min: 4, max: 5, integer: true },
    spread: { min: 28, max: 40 },
    shrink: { min: 0.58, max: 0.68 },
    branchChance: { min: 0.42, max: 0.58 },
    stopChance: { min: 0.1, max: 0.2 },
    jitter: { min: 0.35, max: 0.55 },
    wander: { min: 5, max: 8 },
    bareLimb: { min: 2, max: 6, integer: true },
  },
  fixed: {
    length: 300,
    segmentsPerLimb: 5,
    baseWidth: 3.2,
    taper: 0.7,
  },
} as const satisfies {
  ranges: Record<string, TreeRange>;
  fixed: Record<string, number>;
};

/**
 * Map an arbitrary seed onto one bounded parameter set — same seed, same
 * options, forever.
 */
export function treeVariant(seed: number): TreeOptions {
  const rand = seededRandom(seed);
  const draw = (range: TreeRange): number => {
    const value = range.min + rand() * (range.max - range.min);
    return range.integer ? Math.round(value) : value;
  };
  const r = TREE_ENVELOPE.ranges;

  // Drawn in a fixed order: the sequence is what makes a seed reproducible.
  return {
    depth: draw(r.depth),
    spread: draw(r.spread),
    shrink: draw(r.shrink),
    branchChance: draw(r.branchChance),
    stopChance: draw(r.stopChance),
    jitter: draw(r.jitter),
    wander: draw(r.wander),
    bareLimb: draw(r.bareLimb),
    ...TREE_ENVELOPE.fixed,
    seed,
  };
}

export interface TreeOptions {
  /** How many times to branch. */
  depth: number;
  /** Length of the trunk; each generation shrinks by `shrink`. */
  length: number;
  shrink?: number;
  /** Half-angle between siblings, in degrees. */
  spread?: number;
  origin?: Point;
  /** Initial heading in degrees; 90 grows downward in SVG coordinates. */
  heading?: number;
  /**
   * Leave one limb bare: the Nth branch encountered stops without growing its
   * children. The design calls for at least one such limb, and which one it is
   * should be a choice, not an accident of where the export happened to stop.
   */
  bareLimb?: number | null;
  /** Seed for the irregularity. Same seed, same tree, forever. */
  seed?: number;
  /**
   * How far angle and length may wander from the ideal, 0–1. At 0 the tree is a
   * perfect binary fractal — legible as a rule, but too mechanical to read as
   * something grown.
   */
  jitter?: number;
  /**
   * Chance that any given branch simply stops, 0–1. This is what makes the tree
   * feel unfinished rather than merely small: limbs end mid-reach, at different
   * depths, the way a real one does when something interrupted it.
   */
  stopChance?: number;
  /** How many sub-segments each limb is walked in — the branch points along it. */
  segmentsPerLimb?: number;
  /** Chance a side branch leaves at any one of those points, 0–1. */
  branchChance?: number;
  /** Degrees the limb may drift per sub-segment, keeping it from being a ruler line. */
  wander?: number;
  /** Stroke width of the trunk. Each generation is `taper` times its parent. */
  baseWidth?: number;
  taper?: number;
}

export interface TreeGrowth {
  segments: Segment[];
  /** How many limbs were actually grown — the trunk counts as the first. */
  branches: number;
  /**
   * Whether the limb named by `bareLimb` was ever reached. A seed that grows
   * fewer branches than that index leaves the tree with no bare limb at all,
   * which the design asks for — and which is invisible in the segment list.
   */
  bareLimbApplied: boolean;
}

/**
 * A binary tree grown by recursion: each branch spawns two shorter children at
 * ±`spread`, `depth` times over. One limb is deliberately left bare.
 *
 * Returns the geometry PLUS the two facts acceptance needs and the segment list
 * cannot answer: how many limbs grew, and whether the bare limb landed.
 */
export function growTree({
  depth,
  length,
  shrink = 0.72,
  spread = 22,
  origin = { x: 0, y: 0 },
  heading = 90,
  bareLimb = null,
  seed = 7,
  jitter = 0.55,
  stopChance = 0.16,
  segmentsPerLimb = 4,
  branchChance = 0.55,
  wander = 5,
  baseWidth = 2.6,
  taper = 0.72,
}: TreeOptions): TreeGrowth {
  const segments: Segment[] = [];
  const rand = seededRandom(seed);
  let branchIndex = 0;
  let bareLimbApplied = false;

  /** A multiplier around 1, wandering by up to `jitter` either way. */
  const wobble = () => 1 + (rand() - 0.5) * 2 * jitter;

  /**
   * Grow ONE limb, walking it in sub-segments and letting side branches leave
   * part-way ALONG it rather than only at its tip.
   *
   * That distinction is the whole character of the figure. A plain binary tree
   * forks only at limb ends, so every branch point sits at the same height as its
   * sibling and the result reads as a diagram of a rule. Letting a limb continue
   * past its own forks puts branch points at varying heights and gives the
   * organic, grown look — at a fraction of the line count, because the limb is
   * one continuing stroke instead of a doubling cascade.
   */
  const grow = (start: Point, heading0: number, len: number, level: number): void => {
    if (level > depth) return;

    const isBare = bareLimb !== null && branchIndex === bareLimb;
    if (isBare) bareLimbApplied = true;
    branchIndex += 1;

    const width = Math.max(0.9, baseWidth * taper ** (level - 1));
    const subLen = len / segmentsPerLimb;
    let from = start;
    let dir = heading0;
    // Count the branches actually SPAWNED, not the sub-segments walked. Keying
    // the side off the loop index instead means a skipped roll silently eats a
    // turn, and the survivors pile onto one side — the limb ends up combed over.
    let spawned = 0;

    for (let i = 0; i < segmentsPerLimb; i += 1) {
      // A limb below the trunk may stop part-way — that is the incompleteness,
      // and stopping mid-limb reads as interrupted rather than merely short.
      if (level > 1 && i > 0 && rand() < stopChance) return;

      // Wander, then lean back toward the limb's original heading. Without the
      // restoring pull this is a random walk: the drift compounds and the limb
      // curls away instead of holding its line.
      dir += (rand() - 0.5) * 2 * wander + (heading0 - dir) * 0.35;
      const rad = (dir * Math.PI) / 180;
      const to = { x: from.x + subLen * Math.cos(rad), y: from.y + subLen * Math.sin(rad) };
      segments.push({ from, to, depth: level, width });
      from = to;

      // The named bare limb carries no children at all.
      if (isBare) continue;

      // One side branch, alternating strictly left/right across the spawns so
      // the limb stays balanced however many rolls were skipped.
      if (level < depth && rand() < branchChance) {
        const side = spawned % 2 === 0 ? -1 : 1;
        spawned += 1;
        grow(to, dir + side * spread * wobble(), len * shrink * wobble(), level + 1);
      }
    }
  };

  grow(origin, heading, length, 1);
  return { segments, branches: branchIndex, bareLimbApplied };
}

/**
 * The geometry alone, for every caller that only ever wanted the lines.
 *
 * Kept exactly as `growTree(...).segments` so the signature the component and
 * the existing tests depend on does not move.
 */
export function treeSegments(options: TreeOptions): Segment[] {
  return growTree(options).segments;
}

interface TreeBounds {
  minX: number;
  minY: number;
  width: number;
  height: number;
}

function treeBounds(segments: readonly Segment[]): TreeBounds {
  const xs = segments.flatMap((s) => [s.from.x, s.to.x]);
  const ys = segments.flatMap((s) => [s.from.y, s.to.y]);
  const minX = Math.min(...xs);
  const minY = Math.min(...ys);
  return {
    minX,
    minY,
    width: Math.max(...xs) - minX || 1,
    height: Math.max(...ys) - minY || 1,
  };
}

/**
 * The viewBox that frames a grown tree, with a 1-unit margin so the outermost
 * stroke is not clipped.
 *
 * Extracted because BOTH the server render and the client regrow need it. Left
 * inline in the component it would be duplicated in the browser script, and the
 * two renders could then silently drift into framing the same tree differently.
 */
export function treeViewBox(segments: readonly Segment[]): string {
  const { minX, minY, width, height } = treeBounds(segments);
  return `${minX - 1} ${minY - 1} ${width + 2} ${height + 2}`;
}

/**
 * The envelope enforced on the RESULT, not just on the inputs.
 *
 * Sampling from bounded ranges is necessary but not sufficient: inside those
 * ranges a particular seed can still grow something degenerate — every branch
 * stopped early, the whole crown combed onto one side, or a bare limb the tree
 * never reached. These are the properties a reader would notice, checked on the
 * geometry that actually came out.
 */
export function isAcceptableTree(growth: TreeGrowth): boolean {
  return treeShortfall(growth) === 0;
}

/**
 * Acceptable segment counts: below is a stick, above silts up into a mass.
 *
 * The floor is calibrated against the tree the site shipped before this varied
 * — 39 segments at aspect 0.38. That specimen is the one piece of ground truth
 * about what reads correctly in this lane, so the window is set to admit it
 * rather than to a rounder number that would declare the approved design
 * degenerate.
 */
const SEGMENT_BAND = { min: 35, max: 110 };
const ASPECT_BAND = { min: 0.35, max: 1.1 };

/**
 * The fewest limbs that still read as a branching structure.
 *
 * Calibrated on the variations sheet rather than reasoned from the geometry: a
 * draw with nine limbs renders as a bare stick with a few twigs on it, while
 * every specimen with eleven or more reads as a tree. Segment count does not
 * catch this — the stick and a good sparse tree have nearly the same number of
 * segments, because a long unbranched limb is walked in just as many pieces.
 */
const BRANCH_FLOOR = 11;

/**
 * HOW FAR a tree is from acceptable, as a single number — 0 exactly when it
 * passes every rule.
 *
 * A boolean is what callers want, but it is not enough to CHOOSE with. When no
 * seed in the resample budget produces an acceptable tree, something still has
 * to be drawn, and ranking the failures needs a magnitude. Scoring once and
 * deriving the predicate from it also keeps the two definitions from drifting.
 */
function treeShortfall(growth: TreeGrowth): number {
  const { segments, branches, bareLimbApplied } = growth;
  if (segments.length === 0) return Infinity;

  let shortfall = 0;

  // A tree has to actually branch. This is the check the segment band cannot
  // make: a stick walked in many sub-segments counts the same as a tree.
  shortfall += Math.max(0, BRANCH_FLOOR - branches) / BRANCH_FLOOR;

  // A tree that never reached its named bare limb has no bare limb, which the
  // design explicitly asks for. Weighted heavily: it is a missing feature
  // rather than a proportion being slightly off.
  if (!bareLimbApplied) shortfall += 1;

  const { minX, minY, width, height } = treeBounds(segments);

  // Each term below is normalised to roughly "fraction of the way out of the
  // band", so no single rule silently dominates the ranking.
  shortfall += outOfBand(segments.length, SEGMENT_BAND.min, SEGMENT_BAND.max) / SEGMENT_BAND.max;

  // The lane stretches the figure with `preserveAspectRatio="none"`. Outside
  // this band that stretch is visible as distortion rather than as fit.
  shortfall += outOfBand(width / height, ASPECT_BAND.min, ASPECT_BAND.max);

  // The crown — the far half of the growth direction — must actually spread.
  // Measured against the full width, this is what rejects a narrow spike with
  // one long low branch setting the bounding box.
  const canopy = segments
    .flatMap((s) => [s.from, s.to])
    .filter((p) => p.y >= minY + height / 2);
  const canopyWidth = canopy.length
    ? Math.max(...canopy.map((p) => p.x)) - Math.min(...canopy.map((p) => p.x))
    : 0;
  shortfall += Math.max(0, width * 0.6 - canopyWidth) / width;

  // Balance: the mean of every endpoint sits in the middle third. A tree combed
  // onto one side passes every other check here and still looks wrong.
  const points = segments.flatMap((s) => [s.from, s.to]);
  const meanX = points.reduce((sum, p) => sum + p.x, 0) / points.length;
  shortfall += outOfBand(meanX, minX + width / 3, minX + (width * 2) / 3) / width;

  return shortfall;
}

/** Distance outside `[min, max]`, or 0 within it. */
function outOfBand(value: number, min: number, max: number): number {
  if (value < min) return min - value;
  if (value > max) return value - max;
  return 0;
}

/**
 * Grow a tree for `seed` that passes `isAcceptableTree`, resampling with a
 * derived seed when it does not.
 *
 * `attempts` is 20 rather than a handful because a raw draw from the envelope
 * only passes about a third of the time — `depth` 4 vs 5 swings the segment
 * count hard — so a short budget leaves a visible tail of pages rendering a
 * rejected tree. Twenty attempts takes the fall-through rate to roughly one in
 * a thousand, and each attempt is a few dozen line segments.
 *
 * Falls back to the CLOSEST attempt rather than throwing: this runs inside a
 * page render where there is nobody to catch an exception, and a slightly-off
 * tree beats a blank lane. Ranking by shortfall matters — ranking by segment
 * count would pick the most overgrown tree precisely when overgrowth was the
 * failure, which is the most common one.
 */
export function growAcceptableTree(seed: number, attempts = 20): TreeGrowth {
  let best: TreeGrowth | null = null;
  let bestShortfall = Infinity;
  let current = seed >>> 0;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const growth = growTree(treeVariant(current));
    const shortfall = treeShortfall(growth);
    if (shortfall === 0) return growth;
    if (shortfall < bestShortfall) {
      best = growth;
      bestShortfall = shortfall;
    }
    // Knuth's multiplicative hash, kept in unsigned 32-bit — a derived seed
    // rather than `seed + 1`, so a bad seed's neighbours are not tried next.
    current = (Math.imul(current, 2654435761) + attempt) >>> 0;
  }

  return best as TreeGrowth;
}

// ---------------------------------------------------------------------------
// Morse — the values rule across the top of internal pages
// ---------------------------------------------------------------------------

const MORSE: Record<string, string> = {
  a: '.-', b: '-...', c: '-.-.', d: '-..', e: '.', f: '..-.', g: '--.', h: '....',
  i: '..', j: '.---', k: '-.-', l: '.-..', m: '--', n: '-.', o: '---', p: '.--.',
  q: '--.-', r: '.-.', s: '...', t: '-', u: '..-', v: '...-', w: '.--', x: '-..-',
  y: '-.--', z: '--..',
};

export interface MorseSymbol {
  /** `.` or `-`. */
  kind: 'dot' | 'dash';
  /** Left edge in user units. */
  x: number;
  /** Width in user units — a dash is three dots wide. */
  width: number;
  /** Which word this symbol belongs to, for labelling and centring. */
  word: string;
}

export interface MorseLine {
  symbols: MorseSymbol[];
  width: number;
}

/**
 * Encode words as morse and lay them out left to right at classic proportions:
 * a dash is three units, the gap between symbols is one, between letters three,
 * between words seven. Unencodable characters are skipped rather than guessed at.
 */
export function morseLine(words: readonly string[], unit = 3): MorseLine {
  const symbols: MorseSymbol[] = [];
  let x = 0;

  words.forEach((word, wordIndex) => {
    if (wordIndex > 0) x += unit * 7;

    const letters = [...word.toLowerCase()].filter((ch) => MORSE[ch]);
    letters.forEach((ch, letterIndex) => {
      if (letterIndex > 0) x += unit * 3;
      [...MORSE[ch]].forEach((mark, markIndex) => {
        if (markIndex > 0) x += unit;
        const width = mark === '-' ? unit * 3 : unit;
        symbols.push({ kind: mark === '-' ? 'dash' : 'dot', x, width, word });
        x += width;
      });
    });
  });

  return { symbols, width: x };
}
