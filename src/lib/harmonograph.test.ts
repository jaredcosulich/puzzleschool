import { describe, expect, it } from 'vitest';
import {
  growAcceptableHarmonograph,
  harmonographPath,
  harmonographPoints,
  harmonographShortfall,
  harmonographVariant,
  harmonographViewBox,
  isAcceptableHarmonograph,
  traceHarmonograph,
  type HarmonographOptions,
} from './harmonograph';
import { hashSeed, pointBounds } from './structures';

/**
 * A hand-built option set, so a test can name the exact physics it is about
 * instead of hunting for a seed that happens to produce it.
 */
function options(overrides: Partial<HarmonographOptions> = {}): HarmonographOptions {
  return {
    x: [
      { amplitude: 1, frequency: 0.5, phase: 0, damping: 0.016 },
      { amplitude: 0.25, frequency: 0.5 * 1.04, phase: 1.1, damping: 0.016 },
    ],
    y: [
      { amplitude: 1.9, frequency: 0.5, phase: Math.PI / 2, damping: 0.016 },
      { amplitude: 0.4, frequency: 0.5 * 1.03, phase: 2.2, damping: 0.016 },
    ],
    duration: 220,
    step: 0.08,
    fraction: 0.4,
    ...overrides,
  };
}

/** How far apart the two ends of a trace are, as a share of its diagonal. */
function endGapOf(points: readonly { x: number; y: number }[]): number {
  const box = pointBounds(points);
  const first = points[0];
  const last = points[points.length - 1];
  return Math.hypot(last.x - first.x, last.y - first.y) / Math.hypot(box.width, box.height);
}

describe('harmonographPoints', () => {
  // The pen samples at a fixed step across the swing it is allowed.
  it('samples the whole allowed swing', () => {
    const points = harmonographPoints(options({ duration: 100, step: 1, fraction: 1 }));
    expect(points.length).toBeGreaterThanOrEqual(101);
  });

  // `fraction` is the incompleteness knob — it must actually shorten the stroke.
  it('draws a shorter stroke for a smaller fraction', () => {
    const full = harmonographPoints(options({ fraction: 0.8 }));
    const cut = harmonographPoints(options({ fraction: 0.4 }));
    expect(cut.length).toBeLessThan(full.length);
  });

  // The pen lifting mid-swing is the whole feature, so the stroke must not
  // close: a figure whose ends meet reads as finished.
  it('leaves the ends apart when the pen lifts early', () => {
    expect(endGapOf(harmonographPoints(options({ fraction: 0.4 })))).toBeGreaterThan(0.12);
  });

  // Damping is what makes the passes nest rather than retrace.
  it('draws later passes smaller than earlier ones', () => {
    const points = harmonographPoints(options({ fraction: 1 }));
    const early = Math.max(...points.slice(0, 200).map((p) => Math.abs(p.y)));
    const late = Math.max(...points.slice(-200).map((p) => Math.abs(p.y)));
    expect(late).toBeLessThan(early);
  });

  // A detuned pair precesses — each pass lands rotated, so the figure does NOT
  // retrace its own path. This is the property that makes it a harmonograph
  // rather than one oval drawn many times.
  it('does not retrace its own path when the pendulums are detuned', () => {
    const points = harmonographPoints(
      options({ duration: 400, fraction: 1, x: [
        { amplitude: 1, frequency: 0.5, phase: 0, damping: 0 },
        { amplitude: 0.25, frequency: 0.5 * 1.05, phase: 1.1, damping: 0 },
      ] }),
    );
    // One full period of the base frequency, in samples.
    const period = Math.round((2 * Math.PI) / 0.5 / 0.08);
    const drift = Math.abs(points[period * 4].x - points[0].x);
    expect(drift).toBeGreaterThan(0.05);
  });

  // A zero fraction cannot produce a usable figure, and must not throw either —
  // this runs inside a page render with nobody to catch it.
  it('returns a degenerate but valid trace at fraction zero', () => {
    const points = harmonographPoints(options({ fraction: 0 }));
    expect(points.length).toBeGreaterThanOrEqual(1);
  });
});

describe('harmonographVariant', () => {
  // Same seed, same figure, forever — this is what keeps a page's build-time
  // figure fixed across deploys and the committed screenshots from churning.
  it('is reproducible for a seed', () => {
    expect(harmonographVariant(4242)).toEqual(harmonographVariant(4242));
  });

  // Different pages must get different figures, or the per-page axis is a lie.
  it('gives different seeds different figures', () => {
    const a = traceHarmonograph(harmonographVariant(hashSeed('about:harmonograph')));
    const b = traceHarmonograph(harmonographVariant(hashSeed('contact:harmonograph')));
    expect(harmonographPath(a.points)).not.toBe(harmonographPath(b.points));
  });

  // Every draw must stay inside the declared envelope — that is what keeps the
  // figures recognisably the same machine.
  it('draws every value from inside the envelope', () => {
    for (let seed = 0; seed < 40; seed += 1) {
      const o = harmonographVariant(seed * 7919);
      expect(o.fraction).toBeGreaterThanOrEqual(0.3);
      expect(o.fraction).toBeLessThanOrEqual(0.5);
      for (const p of [...o.x, ...o.y]) {
        expect(p.damping).toBeGreaterThan(0);
        expect(p.amplitude).toBeGreaterThan(0);
      }
    }
  });

  // The two pendulums on an axis must never be at exactly the same frequency —
  // the detune IS the figure, and at zero it degenerates.
  it('always detunes the second pendulum on each axis', () => {
    for (let seed = 0; seed < 20; seed += 1) {
      const o = harmonographVariant(seed * 104729);
      expect(o.x[1].frequency).not.toBe(o.x[0].frequency);
      expect(o.y[1].frequency).not.toBe(o.y[0].frequency);
    }
  });
});

describe('harmonographShortfall', () => {
  // The degenerate case the coverage guard exists for: both axes at the same
  // frequency and in phase collapses the ellipse to a diagonal LINE, which
  // fills its bounding box corner to corner and so passes every aspect check.
  it('scores a collapsed in-phase draw far worse than a healthy one', () => {
    const collapsed = traceHarmonograph(
      options({
        x: [
          { amplitude: 1, frequency: 1, phase: 0, damping: 0.016 },
          { amplitude: 0.25, frequency: 1, phase: 0, damping: 0.016 },
        ],
        y: [
          { amplitude: 1.9, frequency: 1, phase: 0, damping: 0.016 },
          { amplitude: 0.4, frequency: 1, phase: 0, damping: 0.016 },
        ],
      }),
    );
    expect(collapsed.coverage).toBeLessThan(0.1);
    expect(harmonographShortfall(collapsed)).toBeGreaterThan(1);
    expect(isAcceptableHarmonograph(collapsed)).toBe(false);
  });

  // The blot: a pen left running spirals into the middle and lays pass on pass
  // there. Every outline measure still passes, so the middle is measured alone.
  it('scores a figure whose ink piles up in the middle worse than one that stops', () => {
    const settled = traceHarmonograph(options({ fraction: 1, duration: 600 }));
    const stopped = traceHarmonograph(options({ fraction: 0.4 }));
    expect(settled.coreDensity).toBeGreaterThan(stopped.coreDensity);
  });

  // A trace that stops where it started reads as CLOSED, and a closed
  // harmonograph is a finished one — which this site's structures must not be.
  it('penalises a trace whose ends have met', () => {
    const trace = traceHarmonograph(options({ fraction: 0.4 }));
    const closed = { ...trace, endGap: 0 };
    expect(harmonographShortfall(closed)).toBeGreaterThan(harmonographShortfall(trace));
  });

  // An empty or near-empty trace is infinitely far from acceptable, so it can
  // never win the "closest attempt" fallback.
  it('reports an unusable trace as infinitely short', () => {
    expect(harmonographShortfall(traceHarmonograph(options({ duration: 0 })))).toBe(Infinity);
  });
});

describe('growAcceptableHarmonograph', () => {
  // The envelope is enforced on the RESULT, not just the inputs.
  it('returns an acceptable figure across a spread of seeds', () => {
    for (const key of ['about', 'contact', 'notes', 'blank', 'a-day-in-the-life']) {
      const trace = growAcceptableHarmonograph(hashSeed(`${key}:harmonograph`));
      expect(isAcceptableHarmonograph(trace)).toBe(true);
    }
  });

  // This runs inside a page render where there is nobody to catch an exception,
  // so a hopeless budget must still return a figure — a slightly-off one beats
  // a blank lane.
  it('returns the closest attempt rather than throwing when none qualifies', () => {
    const trace = growAcceptableHarmonograph(1, 1);
    expect(trace).toBeDefined();
    expect(trace.points.length).toBeGreaterThan(2);
  });

  // Same seed, same figure — the build-time axis.
  it('is reproducible for a seed', () => {
    const a = growAcceptableHarmonograph(hashSeed('contact:harmonograph'));
    const b = growAcceptableHarmonograph(hashSeed('contact:harmonograph'));
    expect(harmonographPath(a.points)).toBe(harmonographPath(b.points));
  });
});

describe('harmonographViewBox', () => {
  // The margin is PROPORTIONAL, where the tree's is a flat unit. A harmonograph
  // is drawn at amplitudes near 1, so a flat unit would add most of a box width
  // and change the aspect the acceptance band was just checked against.
  it('adds a margin proportional to the figure rather than a fixed unit', () => {
    const box = harmonographViewBox([
      { x: 0, y: 0 },
      { x: 1, y: 2 },
    ]);
    const [minX, minY, width, height] = box.split(' ').map(Number);
    // 2% of the larger extent, both sides.
    expect(width).toBeCloseTo(1 + 2 * 0.04, 5);
    expect(height).toBeCloseTo(2 + 2 * 0.04, 5);
    expect(minX).toBeCloseTo(-0.04, 5);
    expect(minY).toBeCloseTo(-0.04, 5);
  });

  // The framing must preserve the aspect the acceptance band measured, or a
  // figure accepted at 0.5 renders at something else.
  it('preserves the figure aspect it was measured at', () => {
    const points = growAcceptableHarmonograph(hashSeed('contact:harmonograph')).points;
    const raw = pointBounds(points);
    const [, , width, height] = harmonographViewBox(points).split(' ').map(Number);
    expect(width / height).toBeCloseTo(raw.width / raw.height, 1);
  });
});
