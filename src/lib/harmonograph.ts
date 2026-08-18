// The harmonograph — the trace of two coupled pendulums.
//
// A Victorian drawing machine: a pen on one pendulum, the paper on another,
// swinging at right angles. What it draws is the same maths that makes two tones
// a musical interval. When the two frequencies sit at a small whole-number ratio
// the figure closes into a standing Lissajous knot; DETUNE one of them slightly
// and the knot precesses, each pass landing a little rotated from the last, and
// the result is the drifting rosette the machine is actually known for. The
// detune is not noise added to make it look organic — it IS the figure.
//
// Each axis is driven by two pendulums summed, which is what the four-pendulum
// machine does mechanically:
//
//   x(t) = A1·sin(f1·t + p1)·e^(−d1·t) + A2·sin(f2·t + p2)·e^(−d2·t)
//   y(t) = A3·sin(f3·t + p3)·e^(−d3·t) + A4·sin(f4·t + p4)·e^(−d4·t)
//
// The incompleteness — every structure on this site is deliberately unfinished —
// is `fraction`: the pen LIFTS before friction brings the pendulums to rest, so
// the stroke stops mid-swing with its envelope still open, rather than spiralling
// tidily into a dot at the centre. A finished harmonograph is a decoration; one
// stopped mid-swing is somebody's work in progress.
//
// Everything here is pure: numbers in, points out. No DOM, no Astro.
import {
  FLANK_LANE,
  outOfBand,
  pointBounds,
  seededRandom,
  toPath,
  type Bounds,
  type Point,
} from './structures';

/** One pendulum's contribution to one axis. */
export interface Pendulum {
  amplitude: number;
  /** Cycles per unit `t`. The RATIO between axes is what shapes the figure. */
  frequency: number;
  /** Radians. Two pendulums in phase on the same axis collapse into one. */
  phase: number;
  /** Exponential decay per unit `t` — the friction that eventually stops it. */
  damping: number;
}

export interface HarmonographOptions {
  /** The two pendulums driving horizontal motion. */
  x: readonly [Pendulum, Pendulum];
  /** The two driving vertical motion. */
  y: readonly [Pendulum, Pendulum];
  /** How long the machine is allowed to swing, in units of `t`. */
  duration: number;
  /** Sampling interval; smaller is smoother and produces a longer path. */
  step: number;
  /**
   * How much of that swing the pen actually draws, 0–1. Below 1 it lifts before
   * the pendulums settle — the incompleteness knob, and the reason the figure's
   * envelope never closes.
   */
  fraction: number;
  /** The seed this option set was drawn from, carried for reproducibility. */
  seed?: number;
}

/**
 * The sampled trace, plus the three facts acceptance needs that the point list
 * cannot answer at a glance.
 */
export interface HarmonographTrace {
  points: Point[];
  /** Local extrema along the trace — how busy the figure is. */
  turningPoints: number;
  /**
   * How much of its own bounding box the stroke actually visits, 0–1, measured
   * on a coarse grid. This is the degeneracy test: a collapsed draw is a
   * DIAGONAL LINE, which fills its bounding box corner to corner and so passes
   * every aspect-ratio check while looking nothing like a harmonograph. Only
   * occupancy tells a line from a rosette.
   */
  coverage: number;
  /**
   * Gap between the pen's first and last point, as a fraction of the bounding
   * box diagonal. The open-end measure: a trace that happens to stop where it
   * started reads as CLOSED, and a closed harmonograph is a finished one.
   */
  endGap: number;
  /**
   * Share of the sampled points falling in the middle fifth of the figure — how
   * much ink piles up at the centre.
   *
   * Damping pulls every pass inward, so a pen left running spirals down to a
   * point and lays pass on pass in the same small area. The maths is still
   * correct and every other measure here still passes: the aspect is right, the
   * turns are in band, the coverage is fine. What it looks like is a blot with a
   * figure around it. Nothing that reasons about the figure's OUTLINE can see
   * that, so the middle has to be measured on its own.
   */
  coreDensity: number;
}

/** Displacement of one axis at time `t` — two damped sinusoids summed. */
function axisAt(pendulums: readonly [Pendulum, Pendulum], t: number): number {
  return pendulums.reduce(
    (sum, p) => sum + p.amplitude * Math.sin(p.frequency * t + p.phase) * Math.exp(-p.damping * t),
    0,
  );
}

/**
 * Sample the pen's path. The pen lifts at `duration × fraction`, so what comes
 * back is a stroke stopped mid-swing rather than a settled figure.
 */
export function harmonographPoints({
  x,
  y,
  duration,
  step,
  fraction,
}: HarmonographOptions): Point[] {
  const end = duration * Math.min(Math.max(fraction, 0), 1);
  const points: Point[] = [];
  for (let t = 0; t <= end; t += step) {
    points.push({ x: axisAt(x, t), y: axisAt(y, t) });
  }
  // Land exactly where the pen lifted, whatever the step leaves over — the
  // stopping point is the whole feature, so it must not be rounded away.
  if (points.length > 0 && points[points.length - 1].x !== axisAt(x, end)) {
    points.push({ x: axisAt(x, end), y: axisAt(y, end) });
  }
  return points;
}

interface Range {
  readonly min: number;
  readonly max: number;
}

/**
 * The bounds every harmonograph is drawn from — the variation envelope, stated
 * as one readable object next to `TREE_ENVELOPE`'s precedent.
 *
 * `ratios` is a small SET rather than a range because the interesting figures
 * live at small whole-number ratios and nowhere in between: a sweep across
 * continuous frequency would spend nearly all of its mass on irrational ratios,
 * which never close and just silt up into a ball of thread. These are the
 * intervals — an octave, a fifth, a fourth, a major sixth.
 *
 * `amplitude` is deliberately ANISOTROPIC: the lane this figure stands in is
 * `FLANK_LANE`, 200×365, so a figure drawn square would be letterboxed to just
 * over half the lane's height (the same problem `BranchingTree` documents).
 * Swinging the vertical pendulums roughly twice as far as the horizontal ones
 * draws a genuinely tall figure instead of stretching a square one, which is the
 * honest way to fill a tall lane.
 */
export const HARMONOGRAPH_ENVELOPE = {
  /**
   * Frequency ratios between the horizontal and vertical pendulums.
   *
   * `1:1` is the one that makes this figure look like a harmonograph rather than
   * like a tangle, and it is also the one that can collapse. At unison the pen
   * traces an ELLIPSE — a single closed curve — and the detune then rotates that
   * ellipse a little on every pass, which is the nested rosette the machine is
   * actually famous for: strokes that nest instead of crossing. The higher
   * ratios draw lobed Lissajous figures whose lobes cross as they precess, which
   * is legible but busy, so they earn their place as variety rather than as the
   * default.
   *
   * The catch is that unison IN PHASE degenerates: the ellipse flattens to a
   * diagonal line. That is not a reason to exclude the ratio, because the
   * `coverage` floor already rejects exactly that draw on the geometry that came
   * out — which is the whole argument for checking the RESULT rather than only
   * the inputs. Excluding 1:1 to avoid a case acceptance already handles would
   * throw away the best figures to dodge one bad one.
   */
  ratios: [
    [1, 1],
    [1, 2],
    [2, 3],
    [3, 4],
  ] as ReadonlyArray<readonly [number, number]>,
  ranges: {
    /**
     * How far the second pendulum on an axis is detuned from the first.
     *
     * Sized against the PASS COUNT, not chosen for its own sake: the figure only
     * precesses by `2π × passes × detune` in total, so a detune that reads
     * beautifully over fifty passes is invisible over ten. This lane holds about
     * ten, which puts the useful range an order of magnitude above the textbook
     * "slight" mistuning — below it the passes retrace each other and the figure
     * is one oval drawn many times.
     */
    detune: { min: 0.02, max: 0.06 },
    phase: { min: 0, max: Math.PI * 2 },
    damping: { min: 0.014, max: 0.026 },
    /**
     * The second pendulum's amplitude relative to the first on the same axis.
     *
     * Kept SMALL. The second pendulum is a perturbation — it is what makes each
     * pass land rotated from the last. Given a comparable amplitude to the first
     * it stops perturbing and starts competing, and the sum of two near-equal
     * sinusoids at different frequencies is a beat: the envelope swells and
     * collapses, passes cross at every scale, and the figure silts into a knot
     * with wisps coming off it rather than a drawing you can follow.
     */
    balance: { min: 0.16, max: 0.36 },
    amplitudeX: { min: 0.85, max: 1.15 },
    /**
     * The vertical swing, and the compromise this figure turns on.
     *
     * A harmonograph is naturally isotropic — the rosette is legible precisely
     * because the pen has comparable room on both axes. Swinging vertically ~3×
     * the horizontal, which is what filling the OLD 123×365 lane edge-to-edge
     * would have demanded, squeezes every pass into a column narrower than the
     * gaps between them and the figure reads as a scribble. That is why the lane
     * was widened to `FLANK_LANE` instead: at 200×365 a roughly 1:2 draw — which
     * is where this range puts it, and where the figure is at its most legible —
     * now sits at or under the lane's own 0.548 aspect, so it fills the lane top
     * to bottom without being flattened to do it. The figure keeps its shape AND
     * the lane keeps its height; before, one had to pay for the other.
     */
    amplitudeY: { min: 1.6, max: 2.2 },
    /**
     * Where the pen lifts, as a share of the swing.
     *
     * Low, and that is the point rather than a saving. Damping is exponential,
     * so the last third of the swing contributes almost no new outline — the pen
     * is just tightening onto the centre, laying ink where there is already ink.
     * Lifting between a third and half way through is where the figure has all
     * of its shape and none of the blot, and it is the most literal reading of
     * the school's idea available here: the drawing stops while it is still
     * going somewhere.
     */
    fraction: { min: 0.3, max: 0.5 },
  },
  fixed: {
    duration: 220,
    step: 0.08,
  },
} as const satisfies {
  ratios: ReadonlyArray<readonly [number, number]>;
  ranges: Record<string, Range>;
  fixed: Record<string, number>;
};

/**
 * Map an arbitrary seed onto one bounded option set — same seed, same figure,
 * forever. Values are drawn in a FIXED ORDER; the sequence is what makes a seed
 * reproducible.
 */
export function harmonographVariant(seed: number): HarmonographOptions {
  const rand = seededRandom(seed);
  const draw = (range: Range): number => range.min + rand() * (range.max - range.min);
  const r = HARMONOGRAPH_ENVELOPE.ranges;

  const ratio =
    HARMONOGRAPH_ENVELOPE.ratios[
      Math.floor(rand() * HARMONOGRAPH_ENVELOPE.ratios.length) %
        HARMONOGRAPH_ENVELOPE.ratios.length
    ];
  const [numerator, denominator] = ratio;

  const ampX = draw(r.amplitudeX);
  const ampY = draw(r.amplitudeY);
  const balanceX = draw(r.balance);
  const balanceY = draw(r.balance);
  const detuneX = draw(r.detune);
  const detuneY = draw(r.detune);

  // Only the RATIO between the axes and the detune within each axis change the
  // SHAPE; the absolute frequency sets how many times the pen goes round before
  // damping stops it, which is the figure's DENSITY — and density is the whole
  // problem in a lane this narrow. Calibrated against the lane rather than
  // reasoned: at a third, the pen makes some forty passes across the lane's
  // width, which is a few pixels apart and reads as a scribble however good the
  // maths is. A sixth puts it around ten passes, which is what lets the eye
  // follow one pass to the next and see the figure precess. The widened
  // `FLANK_LANE` gives each of those passes more room, not more passes.
  const baseX = numerator / 6;
  const baseY = denominator / 6;

  return {
    x: [
      { amplitude: ampX, frequency: baseX, phase: draw(r.phase), damping: draw(r.damping) },
      {
        amplitude: ampX * balanceX,
        frequency: baseX * (1 + detuneX),
        phase: draw(r.phase),
        damping: draw(r.damping),
      },
    ],
    y: [
      { amplitude: ampY, frequency: baseY, phase: draw(r.phase), damping: draw(r.damping) },
      {
        amplitude: ampY * balanceY,
        frequency: baseY * (1 + detuneY),
        phase: draw(r.phase),
        damping: draw(r.damping),
      },
    ],
    fraction: draw(r.fraction),
    ...HARMONOGRAPH_ENVELOPE.fixed,
    seed,
  };
}

/** How many cells of a `RESOLUTION`² grid over the bounding box the stroke visits. */
const COVERAGE_RESOLUTION = 24;

function measureCoverage(points: readonly Point[], box: Bounds): number {
  const visited = new Set<number>();
  for (const p of points) {
    const col = Math.min(
      COVERAGE_RESOLUTION - 1,
      Math.floor(((p.x - box.minX) / box.width) * COVERAGE_RESOLUTION),
    );
    const row = Math.min(
      COVERAGE_RESOLUTION - 1,
      Math.floor(((p.y - box.minY) / box.height) * COVERAGE_RESOLUTION),
    );
    visited.add(row * COVERAGE_RESOLUTION + col);
  }
  return visited.size / (COVERAGE_RESOLUTION * COVERAGE_RESOLUTION);
}

/** Share of points inside the middle fifth of the bounding box, by area. */
function measureCoreDensity(points: readonly Point[], box: Bounds): number {
  const midX = box.minX + box.width / 2;
  const midY = box.minY + box.height / 2;
  const halfW = box.width * 0.1;
  const halfH = box.height * 0.1;
  const inside = points.filter(
    (p) => Math.abs(p.x - midX) <= halfW && Math.abs(p.y - midY) <= halfH,
  ).length;
  return inside / points.length;
}

/** Direction reversals on either axis — a cheap proxy for how intricate the figure is. */
function countTurningPoints(points: readonly Point[]): number {
  let turns = 0;
  for (let i = 2; i < points.length; i += 1) {
    const dx0 = points[i - 1].x - points[i - 2].x;
    const dx1 = points[i].x - points[i - 1].x;
    const dy0 = points[i - 1].y - points[i - 2].y;
    const dy1 = points[i].y - points[i - 1].y;
    if (dx0 * dx1 < 0) turns += 1;
    if (dy0 * dy1 < 0) turns += 1;
  }
  return turns;
}

/** Sample a figure and measure everything acceptance asks about it. */
export function traceHarmonograph(options: HarmonographOptions): HarmonographTrace {
  const points = harmonographPoints(options);
  if (points.length < 3) {
    return { points, turningPoints: 0, coverage: 0, endGap: 0, coreDensity: 1 };
  }

  const box = pointBounds(points);
  const first = points[0];
  const last = points[points.length - 1];
  const diagonal = Math.hypot(box.width, box.height);

  return {
    points,
    turningPoints: countTurningPoints(points),
    coverage: measureCoverage(points, box),
    endGap: Math.hypot(last.x - first.x, last.y - first.y) / diagonal,
    coreDensity: measureCoreDensity(points, box),
  };
}

/**
 * Too few turns is a lazy oval; too many silts into a ball of thread. Calibrated
 * on the variations sheet, which is the only place a band like this can honestly
 * be judged.
 */
const TURNING_BAND = { min: 14, max: 60 };

/**
 * Framed with `meet`, which never distorts — it letterboxes — and anchored to
 * the bottom of the lane, so this band decides how much of the lane's HEIGHT the
 * figure claims, never how stretched it is.
 *
 * THE CEILING IS ARITHMETIC, NOT TASTE. Under `meet` the figure is scaled by
 * whichever axis binds first, so it fills the lane's full height exactly when its
 * own aspect is at or below the LANE's. At or under `FLANK_LANE.width / .height`
 * every accepted draw is height-bound and the vertical dead space is gone by
 * construction; the letterboxing that remains is horizontal, where `xMid` centres
 * it and nobody can see it. Above the ceiling the figure is width-bound instead,
 * and `xMidYMax` banks the entire height shortfall as a band of empty air ABOVE
 * the figure — which is precisely how the old 0.62 ceiling left harmonographs
 * sitting visibly lower than the Voronoi field opposite them.
 *
 * So the ceiling is not a number to tune: it is whatever the lane's aspect is,
 * and it moves when the lane moves. The FLOOR is still a judgement — below ~0.42
 * the passes crowd into a column narrower than the gaps between them and the
 * figure reads as a scribble. That is the trade the earlier version described:
 * chasing the old lane's 0.34 bought the last third of the height at the cost of
 * the figure. The answer was to widen the lane, not to flatten the figure.
 */
const ASPECT_BAND = { min: 0.42, max: FLANK_LANE.width / FLANK_LANE.height };

/**
 * Below this the stroke is a line or a thin ellipse, not a figure.
 *
 * Set from the measured distribution rather than reasoned: a healthy draw
 * occupies 0.47–0.85 of its box, a straight diagonal occupies about 0.04 (it
 * visits one cell per row of the grid and no more), and a lazy ellipse sits
 * around 0.1. A floor of a quarter sits in the empty gap between those two
 * populations, so it rejects the collapsed draws without trimming good ones.
 */
const COVERAGE_FLOOR = 0.25;

/** Below this the ends have effectively met and the figure reads as closed. */
const END_GAP_FLOOR = 0.12;

/**
 * Above this share of the ink sitting in the middle fifth, the centre reads as a
 * blot rather than as the place the passes happen to cross. Calibrated on the
 * variations sheet against the measured distribution, not reasoned from area.
 */
const CORE_DENSITY_CEILING = 0.15;

/**
 * HOW FAR a trace is from acceptable, as a single number — 0 exactly when it
 * passes every rule. Same shape as `treeShortfall`, and for the same reason: a
 * boolean cannot rank the failures when no seed in the budget qualifies.
 */
export function harmonographShortfall(trace: HarmonographTrace): number {
  const { points, turningPoints, coverage, endGap, coreDensity } = trace;
  if (points.length < 3) return Infinity;

  const box = pointBounds(points);
  let shortfall = 0;

  shortfall += outOfBand(turningPoints, TURNING_BAND.min, TURNING_BAND.max) / TURNING_BAND.max;
  shortfall += outOfBand(box.width / box.height, ASPECT_BAND.min, ASPECT_BAND.max);

  // The degeneracy guard. Weighted heavily: a collapsed draw is not a figure
  // that is slightly off, it is the wrong thing entirely.
  shortfall += (Math.max(0, COVERAGE_FLOOR - coverage) / COVERAGE_FLOOR) * 2;

  // A missing deliberate feature, like the tree's unreached bare limb — the
  // whole point of `fraction` is that the stop is VISIBLE.
  shortfall += Math.max(0, END_GAP_FLOOR - endGap) / END_GAP_FLOOR;

  // The blot. A pen left running spirals into the middle and lays pass on pass
  // there; every outline-based measure above still passes while the figure reads
  // as a dark knot with loops around it.
  shortfall += Math.max(0, coreDensity - CORE_DENSITY_CEILING) / CORE_DENSITY_CEILING;

  return shortfall;
}

/** The envelope enforced on the RESULT, not just on the inputs. */
export function isAcceptableHarmonograph(trace: HarmonographTrace): boolean {
  return harmonographShortfall(trace) === 0;
}

/**
 * Draw a harmonograph for `seed` that passes `isAcceptableHarmonograph`,
 * resampling from a derived seed when it does not.
 *
 * Falls back to the CLOSEST attempt rather than throwing, exactly as
 * `growAcceptableTree` does: this runs inside a page render where there is
 * nobody to catch an exception, and a slightly-off figure beats a blank lane.
 *
 * `attempts` is 60 where the tree's is 20, and the difference is measured, not
 * cautious. A raw draw here passes only about a fifth of the time, because this
 * figure is checked on four independent things at once — aspect, busyness,
 * openness and the density of its middle — and a draw must satisfy all of them.
 * At 20 attempts roughly one page in a hundred would render a rejected figure;
 * 60 takes that under one in a thousand, which is the rate the tree holds, and
 * each attempt is a few thousand sine evaluations.
 */
export function growAcceptableHarmonograph(seed: number, attempts = 60): HarmonographTrace {
  let best: HarmonographTrace | null = null;
  let bestShortfall = Infinity;
  let current = seed >>> 0;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const trace = traceHarmonograph(harmonographVariant(current));
    const shortfall = harmonographShortfall(trace);
    if (shortfall === 0) return trace;
    if (shortfall < bestShortfall) {
      best = trace;
      bestShortfall = shortfall;
    }
    // Knuth's multiplicative hash, kept unsigned — a derived seed rather than
    // `seed + 1`, so a bad seed's neighbours are not tried next.
    current = (Math.imul(current, 2654435761) + attempt) >>> 0;
  }

  return best as HarmonographTrace;
}

/**
 * The viewBox that frames a trace, with a small margin so the stroke is not
 * clipped. Both the server render and the client regrow need it, so it lives
 * here rather than in the component — the two must frame the same figure the
 * same way or the regrow visibly jumps.
 *
 * The margin is PROPORTIONAL, where `treeViewBox`'s is a flat 1 unit, and the
 * difference is not a preference. A tree is drawn at a `length` of 300, so one
 * unit of margin is a third of a percent and invisible. A harmonograph is drawn
 * at amplitudes of about 1 by 3, so the same flat unit would add 80% to the
 * box's width and 30% to its height — inflating the frame, shrinking the figure
 * inside its lane, and (because it adds the same absolute amount to both axes)
 * changing the ASPECT the acceptance band was just checked against, so a draw
 * measured at 0.34 would render at 0.5.
 */
export function harmonographViewBox(points: readonly Point[]): string {
  const { minX, minY, width, height } = pointBounds(points);
  const margin = Math.max(width, height) * 0.02;
  return `${minX - margin} ${minY - margin} ${width + margin * 2} ${height + margin * 2}`;
}

/** The single continuous stroke, as an SVG `d`. */
export function harmonographPath(points: readonly Point[]): string {
  return toPath(points);
}
