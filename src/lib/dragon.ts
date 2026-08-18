/**
 * The fold-word family the dark band's curve is drawn from.
 *
 * The Heighway dragon is a SINGLE fixed fractal — there is nothing in it to
 * sample, which is why this band's curve was the one structure on the site that
 * never varied. So the figure is generalised one level up, to the family the
 * dragon is a member of.
 *
 * A dragon curve is a strip of paper folded in half repeatedly and then opened
 * out: every crease becomes a right angle, and the order of the creases is what
 * draws the figure. Folding always the same way gives the classic dragon; the
 * FOLD WORD — one direction per fold — is the free parameter. Drawing each fold
 * from the seed gives 2^n curves that are all still orthogonal lattice walks at
 * the same complexity, so the figure genuinely RESTRUCTURES between visits
 * rather than being the same fractal rotated. That distinction is the whole
 * point: rotation is a costume, a different fold word is a different curve.
 *
 * `dragonPoints` in `lib/structures.ts` is deliberately NOT replaced by this.
 * The all-right fold word must reproduce it point for point, and a test asserts
 * exactly that — it is the reference specimen this generalisation is measured
 * against, and the envelope below is calibrated to ADMIT it.
 */
import {
  outOfBand,
  pointBounds,
  seededRandom,
  turtle,
  type Bounds,
  type Point,
} from './structures';

/** One crease: +1 turns right, -1 turns left. */
export type Fold = 1 | -1;

/**
 * The turn sequence a fold word unfolds into.
 *
 * The recurrence is the paper itself: opening one more fold reproduces every
 * crease you already had, adds the new one, then repeats them BACKWARDS and
 * INVERTED — because the far half of the strip arrives at each old crease from
 * the other side. `n` folds give `2^n - 1` turns, and so `2^n` straight runs.
 *
 * With every fold the same direction this is the regular paperfolding sequence
 * and the walk is the Heighway dragon.
 */
export function foldTurns(folds: readonly Fold[]): Fold[] {
  let turns: Fold[] = [];
  for (const fold of folds) {
    const mirrored: Fold[] = [];
    for (let i = turns.length - 1; i >= 0; i -= 1) mirrored.push(-turns[i] as Fold);
    turns = [...turns, fold, ...mirrored];
  }
  return turns;
}

/**
 * The turn sequence as a turtle command string: a forward move, then a turn and
 * a forward move per crease.
 *
 * Emitted for the EXISTING `turtle` rather than walked here, so `fraction`,
 * `heading` and `origin` keep exactly the semantics they already have and the
 * cut-off behaviour stays the one that is already tested. A second walker would
 * fork that and the two would drift.
 */
export function foldCommands(turns: readonly Fold[]): string {
  return `F${turns.map((turn) => (turn === 1 ? '+F' : '-F')).join('')}`;
}

export interface DragonOptions {
  /** One direction per fold. Its length IS the iteration depth. */
  folds: readonly Fold[];
  /** Distance per forward move. Invisible in the output — see `DRAGON_ENVELOPE`. */
  step: number;
  /**
   * Fraction of the forward moves actually walked, 0–1. Below 1 the curve stops
   * before it closes, which is this figure's stated character.
   */
  fraction?: number;
  /** Initial heading in degrees; 0 points along +x. */
  heading?: number;
  origin?: Point;
  /** The seed this option set was drawn from, carried for reporting. */
  seed?: number;
}

/** Walk a fold word: creases to turns, turns to commands, commands to points. */
export function dragonTrace(options: DragonOptions): Point[] {
  const { folds, step, fraction = 1, heading = 0, origin } = options;
  return turtle(foldCommands(foldTurns(folds)), { angle: 90, step, fraction, heading, origin });
}

interface DragonRange {
  readonly min: number;
  readonly max: number;
  /** Rounded to a whole number after sampling. */
  readonly integer?: boolean;
}

/**
 * The bounds every generated curve is drawn from — the variation envelope, as
 * one readable object, mirroring `TREE_ENVELOPE`'s `ranges`/`fixed` split.
 *
 * `iterations` stays narrow because it is an exponent: 11 is 2048 straight runs
 * and 13 is 8192, already a four-fold swing in how dense the lattice reads.
 *
 * `step` is FIXED, and that is not an oversight. The viewBox is derived from the
 * walk's own bounds and stretched to the band with `preserveAspectRatio="none"`,
 * so `step` cancels out entirely — every curve is scaled to the same rectangle
 * whatever it was walked at. Sampling it would be a variation costume over an
 * output that never changes.
 */
export const DRAGON_ENVELOPE = {
  ranges: {
    iterations: { min: 11, max: 13, integer: true },
    fraction: { min: 0.6, max: 0.95 },
    /** Multiplied to 0/90/180/270 — the lattice has no other headings. */
    quarterTurn: { min: 0, max: 3, integer: true },
  },
  fixed: {
    step: 7,
  },
} as const satisfies {
  ranges: Record<string, DragonRange>;
  fixed: Record<string, number>;
};

/**
 * Map an arbitrary seed onto one bounded option set — same seed, same curve,
 * forever.
 *
 * The draw ORDER is fixed and load-bearing: it is what makes a seed
 * reproducible. The fold word is drawn last, one bit per iteration, so the three
 * scalar parameters land identically whatever depth was chosen.
 */
export function dragonVariant(seed: number): DragonOptions {
  const rand = seededRandom(seed);
  const draw = (range: DragonRange): number => {
    const value = range.min + rand() * (range.max - range.min);
    return range.integer ? Math.round(value) : value;
  };
  const r = DRAGON_ENVELOPE.ranges;

  const iterations = draw(r.iterations);
  const fraction = draw(r.fraction);
  const quarterTurn = draw(r.quarterTurn);

  const folds: Fold[] = [];
  for (let i = 0; i < iterations; i += 1) folds.push(rand() < 0.5 ? -1 : 1);

  return { folds, fraction, heading: quarterTurn * 90, ...DRAGON_ENVELOPE.fixed, seed };
}

/**
 * The viewBox that frames a drawn curve, with a 1-unit margin so the outermost
 * stroke is not clipped.
 *
 * Extracted for the reason `treeViewBox` was: BOTH the server render and the
 * client redraw need it, and leaving it inline would duplicate it into the
 * browser script where the two could silently drift into framing the same curve
 * differently.
 */
export function dragonViewBox(points: readonly Point[]): string {
  const { minX, minY, width, height } = pointBounds(points);
  return `${minX - 1} ${minY - 1} ${width + 2} ${height + 2}`;
}

/**
 * A lattice point as a string key, rounded off the float noise.
 *
 * `Math.cos(Math.PI / 2)` is 6.1e-17 rather than 0, so an axis-aligned walk
 * accumulates a few picounits of drift over 8192 steps. Two decimals is orders
 * of magnitude above that drift and orders of magnitude below `step`, so points
 * that ARE the same lattice site always collide and points that are not never do.
 */
function latticeKey(point: Point): string {
  return `${Math.round(point.x * 100)},${Math.round(point.y * 100)}`;
}

/**
 * The fraction of walked edges that had already been walked.
 *
 * This term was added expecting it to be the SAMPLER's main filter — the guess
 * being that the Heighway dragon's famous non-self-intersection was special to
 * the all-right word, and that random fold words would cross themselves into a
 * blot. Measured, that is simply false: every one of the 1024 fold words at
 * depth 10 retraces exactly zero edges. Non-self-intersection is a property of
 * the WHOLE paperfolding family, not of the classic dragon, so no draw from
 * `dragonVariant` can ever trip this.
 *
 * It is kept, deliberately, as a STRUCTURAL INVARIANT guard rather than a
 * variation filter — which is the more valuable of the two. Retracing is exactly
 * what `foldTurns` produces when its recurrence is wrong: dropping the negation
 * on the mirrored half retraces 99.9% of its edges, and a turn sequence that is
 * not a fold word at all retraces 43%. Both draw as the heavy overinked blot the
 * term was written to reject, and both would otherwise reach the page looking
 * merely busy. This is the check that says the curve is still a member of the
 * family, and it costs one pass over the points.
 *
 * Keyed on the unordered endpoint pair, so an edge and its reverse are one edge —
 * walking a corridor back out is exactly the retrace being measured.
 */
export function measureRetrace(points: readonly Point[]): number {
  if (points.length < 2) return 0;

  const seen = new Set<string>();
  let repeats = 0;
  for (let i = 1; i < points.length; i += 1) {
    const a = latticeKey(points[i - 1]);
    const b = latticeKey(points[i]);
    const edge = a < b ? `${a}|${b}` : `${b}|${a}`;
    if (seen.has(edge)) repeats += 1;
    else seen.add(edge);
  }
  return repeats / (points.length - 1);
}

/**
 * Distinct lattice sites visited, over the sites the bounding box contains.
 *
 * In the spirit of `measureCoverage` in `lib/harmonograph.ts`, but measured on
 * the figure's OWN grid rather than an arbitrary sampling resolution, because
 * this walk really is on a lattice.
 *
 * Catches the two things aspect and retrace both miss: a walk packed so tightly
 * that the hairlines merge into a grey field (the broken recurrence scores 1.0
 * here — every lattice site in its box visited), and a walk so sparse it reads
 * as a few strokes rather than a figure.
 */
export function measureLatticeCoverage(points: readonly Point[], box: Bounds, step: number): number {
  const visited = new Set<string>();
  for (const point of points) visited.add(latticeKey(point));

  const cols = Math.round(box.width / step) + 1;
  const rows = Math.round(box.height / step) + 1;
  return visited.size / Math.max(1, cols * rows);
}

/**
 * How far apart the two ends of the walk are, as a fraction of the bounding
 * diagonal. 0 is a closed loop; 1 is opposite corners.
 */
export function measureOpenness(points: readonly Point[], box: Bounds): number {
  if (points.length < 2) return 0;
  const first = points[0];
  const last = points[points.length - 1];
  return Math.hypot(last.x - first.x, last.y - first.y) / Math.hypot(box.width, box.height);
}

/**
 * Where the walk's centre of mass sits inside its bounding box, as `[x, y]`
 * fractions. `[0.5, 0.5]` is dead centre.
 *
 * Named and exported alongside its three sibling terms rather than left inline
 * in the score, because this is the term calibrated by EYE against the
 * variations sheet rather than derived — so it is the one most worth being able
 * to measure on its own.
 */
export function measureBalance(points: readonly Point[], box: Bounds): [number, number] {
  if (points.length === 0) return [0.5, 0.5];

  let sumX = 0;
  let sumY = 0;
  for (const point of points) {
    sumX += point.x;
    sumY += point.y;
  }
  return [
    (sumX / points.length - box.minX) / box.width,
    (sumY / points.length - box.minY) / box.height,
  ];
}

/**
 * Acceptable retracing. Not exactly zero: a single doubled edge in a walk of
 * thousands is invisible. The margin is enormous in practice — a real fold word
 * scores 0 and the failures this catches score 0.43 and up — so the exact
 * ceiling is not load-bearing.
 */
const RETRACE_BAND = { min: 0, max: 0.02 };

/**
 * The one band here that genuinely FILTERS, and the only one that had to be set
 * by LOOKING rather than by measuring the specimen.
 *
 * The destination is a full-width strip about 430px tall — roughly 3.3:1 — and
 * `preserveAspectRatio="none"` stretches whatever it is given to fill that. So
 * the term that matters is not the curve's aspect but the STRETCH FACTOR it
 * implies: 3.3 divided by the curve's own aspect. The shipped specimen is 1.42,
 * a 2.3x horizontal stretch, and that is what the approved design looks like.
 *
 * Admitting the specimen is necessary and NOT sufficient, which a first pass at
 * this band (a floor of 0.55) got wrong. A curve at 0.65 passes that floor and
 * is then stretched 5x: every vertical run in the lattice smears into a long
 * horizontal streak and the figure reads as a barcode rather than a dragon. It
 * is not subtly worse, it is a different picture — and no measurement of the
 * shipped curve alone would have caught it, because the shipped curve is fine.
 *
 * So the floor is set just below the specimen instead: at 1.1 the worst stretch
 * any accepted curve suffers is 3.0x, against the specimen's 2.3x. That rejects
 * a little over half of raw draws, which is what the resample budget is for.
 */
const ASPECT_BAND = { min: 1.1, max: 3.0 };

/**
 * Density on the figure's own lattice, and — after aspect — the term that does
 * the most work. Both halves were set by reading the variations sheet.
 *
 * A first pass at this band ran 0.2–0.65, on the theory that only a collapse or
 * an ink-out was worth rejecting. Eight specimens at that setting spanned 0.355
 * to 0.648 and the two ends were both wrong in ways the geometry alone does not
 * announce: at 0.36 the curve reads as a low mound on a baseline with the top
 * half of the band empty, and at 0.65 it silts into a solid hatch with no
 * legible line in it. Neither is a degenerate walk — both are perfectly good
 * fold words at a density this band cannot carry.
 *
 * So the band is drawn CLOSE around the shipped specimen's 0.541 instead, which
 * is the only draw known to read correctly here. It costs a lower raw pass rate,
 * which is what the resample budget in `growAcceptableDragon` is for.
 */
const COVERAGE_BAND = { min: 0.4, max: 0.56 };

/**
 * How far apart the two ends must be, as a fraction of the bounding diagonal.
 *
 * The figure's stated character is "cut off before it closes". A draw that ends
 * where it started reads as RESOLVED — a closed emblem rather than a fragment
 * running off the edge — which is the one thing this curve must not be.
 *
 * Also below the family's own p01 (0.23), and for the same reason as the
 * coverage floor: `fraction` never cuts late enough to bring the ends together,
 * so this guards the character rather than enforcing it.
 */
const OPENNESS_FLOOR = 0.15;

/**
 * Where the curve's centre of mass sits inside its own bounding box, per axis.
 *
 * The term the variations sheet asked for last, and the one that separated the
 * specimens cleanly when nothing else did. A walk always FILLS its bounding box
 * by definition — that is what a bounding box is — so aspect and coverage both
 * read as healthy on a curve whose ink is all piled into one corner with a large
 * void opposite. In the band that void is not empty space, it is a visible hole
 * with the quote sitting in it.
 *
 * Measured across eight specimens: every draw that read correctly had both axes
 * between 0.44 and 0.55 (the shipped specimen is 0.45/0.52), and every draw that
 * read wrong had one axis outside — 0.31 and 0.39 with the mass against the top
 * edge, 0.67 and 0.69 with it against the bottom.
 *
 * Tighter than the tree's equivalent middle-third rule, because 0.39 is inside a
 * middle third and still visibly wrong here: this figure is one continuous line
 * across a wide strip, so an off-centre mass has nowhere to hide.
 */
const BALANCE_BAND = { min: 0.4, max: 0.6 };

/**
 * HOW FAR a curve is from acceptable, as a single number — 0 exactly when it
 * passes every rule.
 *
 * Same reasoning as `treeShortfall`: a boolean is what callers want, but it is
 * not enough to CHOOSE with. When no seed in the resample budget produces an
 * acceptable curve something still has to be drawn, and ranking failures needs a
 * magnitude. Scoring once and deriving the predicate from it also keeps the two
 * definitions from drifting apart.
 *
 * Every term is normalised to roughly "fraction of the way out of band", so no
 * single rule silently dominates the ranking.
 */
export function dragonShortfall(points: readonly Point[], step: number = DRAGON_ENVELOPE.fixed.step): number {
  if (points.length < 3) return Infinity;

  const box = pointBounds(points);
  let shortfall = 0;

  // The blot guard. Scaled so that retracing a quarter of the walk — thoroughly
  // ruined — contributes about 1, putting it on the same footing as the other
  // three terms rather than swamping them the moment it trips.
  shortfall += outOfBand(measureRetrace(points), RETRACE_BAND.min, RETRACE_BAND.max) / 0.25;

  shortfall += outOfBand(box.width / box.height, ASPECT_BAND.min, ASPECT_BAND.max);

  shortfall +=
    outOfBand(measureLatticeCoverage(points, box, step), COVERAGE_BAND.min, COVERAGE_BAND.max) /
    COVERAGE_BAND.min;

  shortfall +=
    Math.max(0, OPENNESS_FLOOR - measureOpenness(points, box)) / OPENNESS_FLOOR;

  // Balance is already a 0–1 position, so the distance out of band is its own
  // normalisation.
  const [balanceX, balanceY] = measureBalance(points, box);
  shortfall += outOfBand(balanceX, BALANCE_BAND.min, BALANCE_BAND.max);
  shortfall += outOfBand(balanceY, BALANCE_BAND.min, BALANCE_BAND.max);

  return shortfall;
}

/** Whether a drawn curve passes every acceptance rule. */
export function isAcceptableDragon(points: readonly Point[], step?: number): boolean {
  return dragonShortfall(points, step) === 0;
}

/**
 * Draw a curve for `seed` that passes `isAcceptableDragon`, resampling with a
 * derived seed when it does not.
 *
 * `attempts` is 40 rather than the 20 the tree uses, because this envelope is
 * tighter: aspect and coverage are both drawn close around the one specimen
 * known to read correctly in this band, and together they admit roughly a
 * quarter of raw draws. Twenty attempts would leave about one page in a hundred
 * rendering a rejected curve — visible, since there are only a handful of pages.
 * Forty takes that to about one in a million, and an attempt is one walk over a
 * few thousand points.
 *
 * Falls back to the CLOSEST attempt rather than throwing, for the reason
 * `growAcceptableTree` gives: this runs inside a page render where there is
 * nobody to catch an exception, and a slightly-off curve beats an empty band.
 */
export function growAcceptableDragon(seed: number, attempts = 40): Point[] {
  let best: Point[] | null = null;
  let bestShortfall = Infinity;
  let current = seed >>> 0;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const options = dragonVariant(current);
    const points = dragonTrace(options);
    const shortfall = dragonShortfall(points, options.step);
    if (shortfall === 0) return points;
    if (shortfall < bestShortfall) {
      best = points;
      bestShortfall = shortfall;
    }
    // Knuth's multiplicative hash, kept in unsigned 32-bit — a derived seed
    // rather than `seed + 1`, so a bad seed's neighbours are not tried next.
    current = (Math.imul(current, 2654435761) + attempt) >>> 0;
  }

  return best as Point[];
}
