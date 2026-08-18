// The footer's copyright notice, formatted once for both the places that render it.
//
// The site is `output: 'static'` and deploys only on push to `main`, so a year
// baked in at build time is correct on the day it ships and wrong for however
// long January runs without a push. The footer therefore renders the build
// machine's year (so the first paint and no-JS visitors get a real one) and a
// small client script rewrites it from the visitor's own clock. Both paths call
// THIS function, so the two can never disagree about the format.
//
// Deliberately free of `fs` and of any `src/data` import, the same shape as
// `resolveContactUrl` — a pure function in `src/lib` with a colocated unit test.

/**
 * The footer's copyright label for `now`, e.g. `© 2026`.
 *
 * The date is a PARAMETER rather than read from the clock inside here, which is
 * what lets the tests pin a New Year's rollover without mocking a global clock —
 * and what lets the server render and the browser correction differ only in
 * which `Date` they hand in, never in how the answer is written.
 *
 * `getFullYear` is local-time on purpose, not `getUTCFullYear`. The year the
 * visitor is living in is the year their footer should show, and on the build
 * machine the local year is the right thing to ship as the default.
 */
export function copyrightLabel(now: Date): string {
  return `© ${now.getFullYear()}`;
}
