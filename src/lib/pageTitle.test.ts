import { describe, expect, it } from 'vitest';

import { composePageTitle } from './pageTitle';

describe('composePageTitle', () => {
  // The bug: home's content title IS the site title, so the generic
  // "Page · Site" rule rendered "The Puzzle School · The Puzzle School" in the
  // tab, the OG card, and the Twitter card. There is no context to add when the
  // page already names the site.
  it('does not append the site title when the page title already is it', () => {
    expect(composePageTitle('The Puzzle School', 'The Puzzle School')).toBe('The Puzzle School');
  });

  // The suffix has to survive for every other page — that is what makes a tab
  // strip readable when several pages of the site are open at once.
  it('appends the site title for an ordinary page', () => {
    expect(composePageTitle('About', 'The Puzzle School')).toBe('About · The Puzzle School');
  });

  // Both titles are CMS-editable, so the collision can arrive with different
  // casing or a stray trailing space from a content edit no reviewer sees.
  it('treats a differently-cased or padded match as the same title', () => {
    expect(composePageTitle('  the puzzle school ', 'The Puzzle School')).toBe('The Puzzle School');
  });

  // A page that passes no title at all falls back to the bare site title —
  // the behavior the old `title ? ... : siteTitle` ternary already had.
  it('falls back to the site title when the page passes none', () => {
    expect(composePageTitle(undefined, 'The Puzzle School')).toBe('The Puzzle School');
    expect(composePageTitle('   ', 'The Puzzle School')).toBe('The Puzzle School');
  });

  // This is a match test, not a hardcoded home-page exception. Rename the site
  // in settings and home's title stops colliding, so the suffix comes back —
  // which is what keeps the rule correct after a CMS edit no one re-checks.
  it('appends again once the site is renamed out of the collision', () => {
    expect(composePageTitle('The Puzzle School', 'Puzzle School Labs')).toBe(
      'The Puzzle School · Puzzle School Labs',
    );
  });
});
