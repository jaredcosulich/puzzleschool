import { describe, expect, it } from 'vitest';

import { copyrightLabel } from './copyright';

describe('copyrightLabel', () => {
  // The shape the footer actually renders. If the glyph, the spacing or the
  // four-digit year ever changes, both the server render and the browser
  // correction change with it — this is the one place that decides.
  it('formats the year of the given date as a copyright notice', () => {
    expect(copyrightLabel(new Date(2026, 5, 14))).toBe('© 2026');
  });

  // The date is a parameter precisely so the answer follows it rather than the
  // clock. A version that ignored its argument and read `new Date()` would pass
  // the case above on this machine today and fail here.
  it('reads the year from the date it is given rather than the clock', () => {
    expect(copyrightLabel(new Date(2019, 0, 2))).toBe('© 2019');
    expect(copyrightLabel(new Date(2031, 10, 30))).toBe('© 2031');
  });

  // The rollover this whole feature exists for. Two instants one second apart
  // must produce different labels — that gap is exactly the window in which a
  // build-time-only year is wrong, and the client correction closes it.
  it('changes label across the New Year boundary one second apart', () => {
    const eve = new Date(2026, 11, 31, 23, 59, 59);
    const day = new Date(2027, 0, 1, 0, 0, 0);

    expect(day.getTime() - eve.getTime()).toBe(1000);
    expect(copyrightLabel(eve)).toBe('© 2026');
    expect(copyrightLabel(day)).toBe('© 2027');
  });

  // The visitor's own calendar is the one their footer should show, so the
  // helper reads local time, not UTC. Both boundary instants are constructed in
  // LOCAL time: on any machine with a non-zero offset — which is every visitor's
  // browser, the case that matters — a `getUTCFullYear` implementation puts one
  // of these in the wrong year and fails. On a machine running UTC, as CI does,
  // the two calendars coincide and this degenerates into the rollover case above
  // rather than reporting a false pass for a distinction it cannot observe.
  it('reads the local calendar year rather than the UTC one', () => {
    expect(copyrightLabel(new Date(2026, 11, 31, 23, 59, 59))).toBe('© 2026');
    expect(copyrightLabel(new Date(2027, 0, 1, 0, 0, 1))).toBe('© 2027');
  });
});
