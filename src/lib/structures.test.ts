import { describe, expect, it } from 'vitest';
import {
  dragonPoints,
  fibonacciTiling,
  growAcceptableTree,
  growTree,
  hashSeed,
  isAcceptableTree,
  kochPoints,
  lsystem,
  morseLine,
  openRectPath,
  outOfBand,
  pointBounds,
  randomTreeSeed,
  resolveTreeSeed,
  seededRandom,
  sinePath,
  toPath,
  treeSegments,
  treeVariant,
  treeViewBox,
  turtle,
  TREE_ENVELOPE,
  type TreeGrowth,
} from './structures';

describe('toPath', () => {
  // An empty point list has no path to draw, and must not emit a bare "M".
  it('returns an empty string for no points', () => {
    expect(toPath([])).toBe('');
  });

  // A single point is a move with no line — the degenerate but valid case.
  it('emits only a moveto for one point', () => {
    expect(toPath([{ x: 3, y: 4 }])).toBe('M3,4');
  });

  // Float noise is rounded so generated paths stay readable in devtools.
  it('rounds coordinates to two decimals', () => {
    expect(toPath([{ x: 1.23456, y: 9.87654 }])).toBe('M1.23,9.88');
  });
});

describe('sinePath', () => {
  // The wave starts on its baseline: sin(0) is 0, so no vertical offset.
  it('starts on the baseline', () => {
    expect(sinePath({ width: 100, amplitude: 10, period: 50, baseline: 21 })).toMatch(/^M0,21/);
  });

  // fraction is the incompleteness dial — below 1 the wave stops short of the frame.
  it('stops short of the full width when fraction is below 1', () => {
    const half = sinePath({ width: 100, amplitude: 5, period: 40, baseline: 10, fraction: 0.5 });
    const points = half.split(' L');
    const lastX = Number(points[points.length - 1].split(',')[0]);
    expect(lastX).toBe(50);
  });

  // Whatever the step leaves over, the path lands exactly on its endpoint.
  it('lands exactly on the end even when step does not divide the width', () => {
    const path = sinePath({ width: 99, amplitude: 5, period: 40, baseline: 10, step: 10 });
    expect(path.endsWith(',10')).toBe(false);
    const segments = path.split(' L');
    expect(Number(segments[segments.length - 1].split(',')[0])).toBe(99);
  });

  // A smaller step samples more finely and yields more points.
  it('samples more densely with a smaller step', () => {
    const coarse = sinePath({ width: 100, amplitude: 5, period: 40, baseline: 10, step: 10 });
    const fine = sinePath({ width: 100, amplitude: 5, period: 40, baseline: 10, step: 2 });
    expect(fine.split(' L').length).toBeGreaterThan(coarse.split(' L').length);
  });
});

describe('fibonacciTiling', () => {
  // Below two squares there is no tiling to build.
  it('returns nothing for a count under two', () => {
    expect(fibonacciTiling(1)).toEqual({ rects: [], open: null, width: 0, height: 0 });
  });

  // Sides follow the sequence itself: each is the sum of the previous two.
  it('grows each square as the sum of the previous two', () => {
    const sizes = fibonacciTiling(6, 13, false).rects.map((r) => r.size);
    expect(sizes).toEqual([13, 13, 26, 39, 65, 104]);
  });

  // This is the geometry the design handoff exported, reproduced from the rule.
  it('reproduces the handoff geometry for six squares', () => {
    const tiling = fibonacciTiling(6, 13);
    expect(tiling.width).toBe(169);
    expect(tiling.height).toBe(104);
    expect(tiling.rects.map((r) => [r.x, r.y, r.size])).toEqual([
      [39, 65, 13],
      [52, 65, 13],
      [39, 78, 26],
      [0, 65, 39],
      [0, 0, 65],
    ]);
    expect(tiling.open).toEqual({ x: 65, y: 0, size: 104 });
  });

  // openLast is the incompleteness: the largest square is drawn as three sides.
  it('keeps the largest square closed when openLast is false', () => {
    const tiling = fibonacciTiling(6, 13, false);
    expect(tiling.open).toBeNull();
    expect(tiling.rects).toHaveLength(6);
  });

  // The tiling is normalised to the origin, so nothing sits at a negative offset.
  it('normalises the tiling to the origin', () => {
    const tiling = fibonacciTiling(7, 13);
    const all = [...tiling.rects, ...(tiling.open ? [tiling.open] : [])];
    expect(Math.min(...all.map((r) => r.x))).toBe(0);
    expect(Math.min(...all.map((r) => r.y))).toBe(0);
  });
});

describe('openRectPath', () => {
  // Three sides only — down the left, across the bottom, back up the right.
  it('draws three sides and never closes the shape', () => {
    expect(openRectPath({ x: 65, y: 0, size: 104 })).toBe('M65,0 V104 H169 V0');
  });
});

describe('lsystem', () => {
  // Zero iterations is the axiom untouched.
  it('returns the axiom unchanged for zero iterations', () => {
    expect(lsystem('F', { F: 'F+F' }, 0)).toBe('F');
  });

  // Each pass rewrites every matching symbol.
  it('applies the production rule once per iteration', () => {
    expect(lsystem('F', { F: 'F+F' }, 2)).toBe('F+F+F+F');
  });

  // Symbols with no rule survive verbatim — the dragon's X and Y rely on this.
  it('passes through symbols that have no rule', () => {
    expect(lsystem('FX', { F: 'FF' }, 1)).toBe('FFX');
  });
});

describe('turtle', () => {
  // Forward moves advance along the heading; +x at heading zero.
  it('walks forward along its heading', () => {
    const points = turtle('FF', { angle: 90, step: 10 });
    expect(points).toEqual([
      { x: 0, y: 0 },
      { x: 10, y: 0 },
      { x: 20, y: 0 },
    ]);
  });

  // Bookkeeping symbols carry no geometry and must not move the turtle.
  it('ignores symbols that are not moves or turns', () => {
    expect(turtle('FXY', { angle: 90, step: 5 })).toHaveLength(2);
  });

  // fraction stops the walk partway — this is what makes a fragment a fragment.
  it('walks only part of the moves when fraction is below 1', () => {
    expect(turtle('FFFF', { angle: 90, step: 1, fraction: 0.5 })).toHaveLength(3);
  });

  // Even at fraction zero at least one move is walked, so nothing renders empty.
  it('always walks at least one move', () => {
    expect(turtle('FFFF', { angle: 90, step: 1, fraction: 0 })).toHaveLength(2);
  });
});

describe('kochPoints', () => {
  // Iteration n replaces each segment with four, so 4^n moves.
  it('produces four segments per segment per iteration', () => {
    expect(kochPoints(2, { step: 1 })).toHaveLength(17);
  });
});

describe('dragonPoints', () => {
  // The curve is generated, non-empty, and respects its cut-off.
  it('stops early when fraction is below 1', () => {
    const full = dragonPoints(6, { step: 1 });
    const cut = dragonPoints(6, { step: 1, fraction: 0.5 });
    expect(cut.length).toBeLessThan(full.length);
    expect(cut.length).toBeGreaterThan(1);
  });
});

describe('seededRandom', () => {
  // Same seed, same sequence — this is what keeps the static build reproducible.
  it('produces the same sequence for the same seed', () => {
    const a = seededRandom(42);
    const b = seededRandom(42);
    expect([a(), a(), a()]).toEqual([b(), b(), b()]);
  });

  // Different seeds diverge, so the seed is a real dial.
  it('produces a different sequence for a different seed', () => {
    expect(seededRandom(1)()).not.toBe(seededRandom(2)());
  });

  // Values stay in the unit interval, which the jitter maths assumes.
  it('stays within zero and one', () => {
    const rand = seededRandom(7);
    for (let i = 0; i < 50; i += 1) {
      const value = rand();
      expect(value).toBeGreaterThanOrEqual(0);
      expect(value).toBeLessThan(1);
    }
  });
});

describe('treeSegments', () => {
  // Same seed, same tree — otherwise every build would redraw the artwork.
  it('is deterministic for a given seed', () => {
    const options = { depth: 4, length: 100, seed: 3 };
    expect(treeSegments(options)).toEqual(treeSegments(options));
  });

  // A different seed grows a visibly different tree.
  it('grows a different tree for a different seed', () => {
    const a = treeSegments({ depth: 4, length: 100, seed: 1 });
    const b = treeSegments({ depth: 4, length: 100, seed: 2 });
    expect(a).not.toEqual(b);
  });

  // The trunk is always walked, so the figure is never empty.
  it('always draws the trunk', () => {
    const segments = treeSegments({ depth: 1, length: 60, segmentsPerLimb: 3, seed: 5 });
    expect(segments).toHaveLength(3);
    expect(segments.every((s) => s.depth === 1)).toBe(true);
  });

  // Limbs taper as they divide, so the trunk reads heavier than its branches.
  it('tapers stroke width with depth', () => {
    const segments = treeSegments({
      depth: 3,
      length: 100,
      seed: 9,
      branchChance: 1,
      stopChance: 0,
      baseWidth: 4,
      taper: 0.5,
    });
    const trunk = segments.filter((s) => s.depth === 1)[0];
    const child = segments.filter((s) => s.depth === 2)[0];
    expect(trunk.width).toBeGreaterThan(child.width);
  });

  // With no chance of branching, only the trunk exists.
  it('grows no side branches when branchChance is zero', () => {
    const segments = treeSegments({ depth: 4, length: 80, seed: 4, branchChance: 0 });
    expect(segments.every((s) => s.depth === 1)).toBe(true);
  });

  // The named bare limb carries no children — the deliberate missing piece.
  it('leaves the named limb bare', () => {
    const withBare = treeSegments({
      depth: 3,
      length: 80,
      seed: 6,
      branchChance: 1,
      stopChance: 0,
      bareLimb: 0,
    });
    // Limb 0 is the trunk; bare means nothing at all grows from it.
    expect(withBare.every((s) => s.depth === 1)).toBe(true);
  });

  // Depth bounds the recursion, so a deeper tree is never smaller.
  it('never shrinks as depth increases', () => {
    const shallow = treeSegments({ depth: 2, length: 80, seed: 8, branchChance: 1, stopChance: 0 });
    const deep = treeSegments({ depth: 4, length: 80, seed: 8, branchChance: 1, stopChance: 0 });
    expect(deep.length).toBeGreaterThan(shallow.length);
  });
});

describe('hashSeed', () => {
  // The per-page tree must be the same on every build, so the hash has to be
  // stable rather than merely unique within one run.
  it('returns the same number for the same string', () => {
    expect(hashSeed('about')).toBe(hashSeed('about'));
  });

  // If two slugs collided, those two pages would grow the identical tree — the
  // exact thing this feature exists to stop.
  it('separates the slugs the site actually uses', () => {
    const seeds = ['about', 'contact', 'a-day-in-the-life', 'notes', 'home'].map(hashSeed);
    expect(new Set(seeds).size).toBe(seeds.length);
  });

  // A one-character difference must not land nearby, or neighbouring slugs
  // would grow near-identical trees.
  it('separates strings that differ by one character', () => {
    expect(hashSeed('notes')).not.toBe(hashSeed('note'));
  });

  // The seed feeds unsigned 32-bit arithmetic downstream.
  it('stays within unsigned 32-bit range', () => {
    for (const text of ['', 'a', 'about', 'a-very-long-page-slug-written-by-an-editor']) {
      const seed = hashSeed(text);
      expect(Number.isInteger(seed)).toBe(true);
      expect(seed).toBeGreaterThanOrEqual(0);
      expect(seed).toBeLessThan(2 ** 32);
    }
  });
});

describe('treeVariant', () => {
  // The constraint claim of the whole feature: a seed can never sample a
  // parameter outside the declared envelope. A sweep is the only honest way to
  // assert it — one seed proves nothing about the range.
  it('keeps every sampled parameter inside TREE_ENVELOPE', () => {
    for (let seed = 0; seed < 400; seed += 1) {
      const options = treeVariant(seed);
      for (const [key, range] of Object.entries(TREE_ENVELOPE.ranges)) {
        const value = options[key as keyof typeof options] as number;
        expect(value).toBeGreaterThanOrEqual(range.min);
        expect(value).toBeLessThanOrEqual(range.max);
      }
    }
  });

  // depth and bareLimb index things, so a fractional draw would be meaningless.
  it('rounds the integer ranges to whole numbers', () => {
    for (let seed = 0; seed < 50; seed += 1) {
      const { depth, bareLimb } = treeVariant(seed);
      expect(Number.isInteger(depth)).toBe(true);
      expect(Number.isInteger(bareLimb)).toBe(true);
    }
  });

  // Same seed, same options — this is what makes a page's tree stable.
  it('is deterministic for a given seed', () => {
    expect(treeVariant(12345)).toEqual(treeVariant(12345));
  });

  // The fixed parameters set the figure's weight and scale, not how it grew.
  it('holds the fixed parameters constant across seeds', () => {
    const a = treeVariant(1);
    const b = treeVariant(999);
    expect(a.length).toBe(TREE_ENVELOPE.fixed.length);
    expect(b.length).toBe(TREE_ENVELOPE.fixed.length);
    expect(a.baseWidth).toBe(b.baseWidth);
    expect(a.segmentsPerLimb).toBe(b.segmentsPerLimb);
  });
});

describe('growTree', () => {
  // Acceptance needs to know the bare limb actually landed, and the segment
  // list cannot answer that.
  it('reports bareLimbApplied when the named limb is reached', () => {
    const growth = growTree({
      depth: 3,
      length: 80,
      seed: 6,
      branchChance: 1,
      stopChance: 0,
      bareLimb: 0,
    });
    expect(growth.bareLimbApplied).toBe(true);
  });

  // A seed that grows fewer branches than the index never reaches it, so the
  // tree has no bare limb however the options were written.
  it('reports bareLimbApplied false when the index is past the branches grown', () => {
    const growth = growTree({
      depth: 4,
      length: 80,
      seed: 4,
      branchChance: 0,
      bareLimb: 50,
    });
    expect(growth.bareLimbApplied).toBe(false);
  });

  // Counts limbs grown, not sub-segments walked — a stick and a tree can carry
  // the same number of segments.
  it('counts the trunk as the first branch', () => {
    const growth = growTree({ depth: 4, length: 80, seed: 4, branchChance: 0 });
    expect(growth.branches).toBe(1);
  });

  // The compatibility guarantee that keeps the existing treeSegments tests
  // meaningful after the return type changed.
  it('returns exactly what treeSegments returns', () => {
    const options = { depth: 4, length: 100, seed: 3 };
    expect(treeSegments(options)).toEqual(growTree(options).segments);
  });
});

describe('isAcceptableTree', () => {
  // A single unbranched limb is the degenerate case the whole acceptance layer
  // exists to reject.
  it('rejects a single unbranched limb', () => {
    const growth = growTree({ depth: 4, length: 80, seed: 4, branchChance: 0, bareLimb: 2 });
    expect(isAcceptableTree(growth)).toBe(false);
  });

  // A bare limb the tree never reached is not a bare limb.
  it('rejects a tree that never reached its bare limb', () => {
    const growth: TreeGrowth = { ...growTree(treeVariant(7)), bareLimbApplied: false };
    expect(isAcceptableTree(growth)).toBe(false);
  });

  // Nothing to draw is never acceptable.
  it('rejects an empty growth', () => {
    expect(isAcceptableTree({ segments: [], branches: 0, bareLimbApplied: true })).toBe(false);
  });

  // The tree the site shipped before this feature is the one piece of ground
  // truth about what reads correctly in the lane, so the window must admit it.
  it('accepts the originally shipped tree', () => {
    const growth = growTree({
      depth: 4,
      length: 300,
      shrink: 0.62,
      spread: 34,
      bareLimb: 4,
      seed: 11,
      jitter: 0.45,
      stopChance: 0.14,
      segmentsPerLimb: 5,
      branchChance: 0.5,
      wander: 6,
      baseWidth: 3.2,
      taper: 0.7,
    });
    expect(isAcceptableTree(growth)).toBe(true);
  });
});

describe('growAcceptableTree', () => {
  // The property the entire feature rests on: any seed a page slug can hash to
  // must end up growing a tree that passes the envelope.
  it('returns an acceptable tree across a sweep of seeds', () => {
    for (let seed = 0; seed < 300; seed += 1) {
      expect(isAcceptableTree(growAcceptableTree(seed))).toBe(true);
    }
  });

  // Per-page trees have to survive a rebuild unchanged, or every committed
  // screenshot churns on every deploy.
  it('is deterministic for a given seed', () => {
    expect(growAcceptableTree(4242)).toEqual(growAcceptableTree(4242));
  });

  // Different pages must not quietly share a tree.
  it('grows different trees for the slugs the site uses', () => {
    const shapes = ['about', 'contact', 'a-day-in-the-life', 'notes'].map((slug) =>
      JSON.stringify(growAcceptableTree(hashSeed(slug)).segments),
    );
    expect(new Set(shapes).size).toBe(shapes.length);
  });

  // A blank lane is worse than a slightly off tree, so exhausting the budget
  // still has to return something drawable.
  it('returns a drawable tree even when the attempt budget is exhausted', () => {
    const growth = growAcceptableTree(1, 1);
    expect(growth.segments.length).toBeGreaterThan(0);
  });
});

describe('treeViewBox', () => {
  // The frame has to enclose the figure with room for the outermost stroke.
  it('frames the segments with a one unit margin', () => {
    expect(
      treeViewBox([{ from: { x: 0, y: 0 }, to: { x: 10, y: 20 }, depth: 1, width: 2 }]),
    ).toBe('-1 -1 12 22');
  });

  // The server render and the browser regrow both call this; if they disagreed
  // the regrown tree would be framed differently from the one it replaced.
  it('frames a grown tree identically on repeat calls', () => {
    const { segments } = growAcceptableTree(77);
    expect(treeViewBox(segments)).toBe(treeViewBox(segments));
  });
});

describe('pointBounds', () => {
  // The ordinary case: the box that encloses a scatter of points.
  it('encloses every point', () => {
    expect(
      pointBounds([
        { x: 2, y: -3 },
        { x: 10, y: 4 },
        { x: -5, y: 1 },
      ]),
    ).toEqual({ minX: -5, minY: -3, width: 15, height: 7 });
  });

  // Three structures frame themselves from this, so it has to be exact rather
  // than padded — each adds its own margin, and the tree's is a different size
  // from the harmonograph's.
  it('adds no margin of its own', () => {
    expect(
      pointBounds([
        { x: 0, y: 0 },
        { x: 1, y: 1 },
      ]),
    ).toEqual({ minX: 0, minY: 0, width: 1, height: 1 });
  });

  // A single point has no extent at all, and every caller DIVIDES by these to
  // normalise something. Collapsing to 1 rather than 0 is what keeps a flat
  // figure reaching the acceptance checks as a bad score instead of as a NaN
  // that poisons the comparison it was supposed to lose.
  it('reports a unit extent for a degenerate figure rather than zero', () => {
    expect(pointBounds([{ x: 5, y: 5 }])).toEqual({ minX: 5, minY: 5, width: 1, height: 1 });
  });

  // A figure perfectly flat on ONE axis is the realistic degenerate case — a
  // collapsed harmonograph — and only that axis should be substituted.
  it('substitutes only the axis that collapsed', () => {
    expect(
      pointBounds([
        { x: 0, y: 7 },
        { x: 12, y: 7 },
      ]),
    ).toEqual({ minX: 0, minY: 7, width: 12, height: 1 });
  });
});

describe('outOfBand', () => {
  // Inside the band there is nothing to answer for.
  it('reports zero within the band', () => {
    expect(outOfBand(5, 1, 10)).toBe(0);
  });

  // The band is inclusive at both ends, so a value sitting exactly on a limit
  // is acceptable rather than marginally out.
  it('treats both limits as inside', () => {
    expect(outOfBand(1, 1, 10)).toBe(0);
    expect(outOfBand(10, 1, 10)).toBe(0);
  });

  // Distance below, and distance above — the magnitude is what lets a shortfall
  // score RANK its failures rather than merely detect them.
  it('reports how far outside the band a value fell', () => {
    expect(outOfBand(0.5, 1, 10)).toBeCloseTo(0.5, 10);
    expect(outOfBand(13, 1, 10)).toBe(3);
  });
});

describe('resolveTreeSeed', () => {
  // An explicit seed is how the variations sheet pins specific trees.
  it('prefers an explicit seed over the key', () => {
    expect(resolveTreeSeed(42, 'about')).toBe(42);
  });

  // This is the per-page axis: the key decides the tree.
  it('hashes the key when no seed is given', () => {
    expect(resolveTreeSeed(undefined, 'about')).toBe(hashSeed('about'));
  });

  // An unseeded component should be stable across builds, not random.
  it('falls back to one shared default tree when given nothing', () => {
    expect(resolveTreeSeed()).toBe(hashSeed('default'));
    expect(resolveTreeSeed()).toBe(resolveTreeSeed(undefined, undefined));
  });

  // Zero is a legitimate seed and must not be treated as absent.
  it('treats a zero seed as explicit', () => {
    expect(resolveTreeSeed(0, 'about')).toBe(0);
  });
});

describe('randomTreeSeed', () => {
  // Must occupy the same space hashSeed produces, or visit trees would be
  // drawn from a different population than page trees.
  it('stays within unsigned 32-bit range', () => {
    for (let i = 0; i < 200; i += 1) {
      const seed = randomTreeSeed();
      expect(Number.isInteger(seed)).toBe(true);
      expect(seed).toBeGreaterThanOrEqual(0);
      expect(seed).toBeLessThan(2 ** 32);
    }
  });

  // A constant would make every visit grow the same tree, defeating the point.
  it('varies between calls', () => {
    const seeds = new Set(Array.from({ length: 50 }, randomTreeSeed));
    expect(seeds.size).toBeGreaterThan(1);
  });
});

describe('morseLine', () => {
  // A single dot is one unit wide and starts at the origin.
  it('encodes a single dot at the origin', () => {
    const line = morseLine(['e'], 3);
    expect(line.symbols).toEqual([{ kind: 'dot', x: 0, width: 3, word: 'e' }]);
  });

  // A dash is three units wide — the classic proportion.
  it('makes a dash three times a dot', () => {
    const line = morseLine(['t'], 3);
    expect(line.symbols[0]).toMatchObject({ kind: 'dash', width: 9 });
  });

  // Letters are separated by three units, wider than the one-unit symbol gap.
  it('separates letters by three units', () => {
    // "ee" is dot, gap, dot.
    const line = morseLine(['ee'], 3);
    expect(line.symbols.map((s) => s.x)).toEqual([0, 12]);
  });

  // Words are separated by seven units, wider still.
  it('separates words by seven units', () => {
    const line = morseLine(['e', 'e'], 3);
    expect(line.symbols[1].x).toBe(3 + 21);
  });

  // Unencodable characters are skipped rather than guessed at.
  it('skips characters with no morse encoding', () => {
    expect(morseLine(['e!e'], 3).symbols).toHaveLength(2);
  });

  // Every symbol records the word it came from, for labelling and centring.
  it('tags each symbol with its word', () => {
    expect(morseLine(['sos'], 1).symbols.every((s) => s.word === 'sos')).toBe(true);
  });
});
