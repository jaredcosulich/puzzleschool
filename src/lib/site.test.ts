import { describe, expect, it } from 'vitest';

import { isCurrentNavPath, normalizeNavPath } from './site';

describe('normalizeNavPath', () => {
  // The single transformation the whole fix rests on. `nav.json` stores
  // `/about`; the built site renders `/about/`. Both have to land on the same
  // string or no nav link is ever marked current.
  it('strips a trailing slash', () => {
    expect(normalizeNavPath('/about/')).toBe('/about');
  });

  // A path with no trailing slash is already canonical and must survive
  // untouched — otherwise normalizing twice would keep eating characters.
  it('leaves a path without a trailing slash alone', () => {
    expect(normalizeNavPath('/about')).toBe('/about');
  });

  // The site root is the one path where stripping the slash would be wrong:
  // it would collapse to the empty string, which compares equal to nothing
  // useful and would make a future Home item match every page.
  it('keeps the site root as a single slash', () => {
    expect(normalizeNavPath('/')).toBe('/');
  });

  // A NavItem written with an empty url, or a pathname that arrives blank,
  // should read as the root rather than as an empty string that silently
  // matches another empty string.
  it('treats an empty path as the site root', () => {
    expect(normalizeNavPath('')).toBe('/');
  });

  // Astro hands us `Astro.url.pathname`, but a hand-written nav url can carry
  // a fragment for an on-page anchor. The fragment picks a place within the
  // page; it does not change which page you are on.
  it('drops a hash fragment', () => {
    expect(normalizeNavPath('/about#team')).toBe('/about');
  });

  // Same reasoning for a query string: tracking parameters and filters do not
  // make it a different page, so they must not defeat the match.
  it('drops a query string', () => {
    expect(normalizeNavPath('/about/?ref=newsletter')).toBe('/about');
  });

  // Urls are case-insensitive in practice and a CMS author may capitalize a
  // path. Comparing case-sensitively would leave the link muted for a
  // difference the visitor cannot see.
  it('lowercases the path', () => {
    expect(normalizeNavPath('/About')).toBe('/about');
  });

  // Stray whitespace is exactly the kind of thing that survives a copy-paste
  // into a CMS text field, and it is invisible in the editing UI.
  it('trims surrounding whitespace', () => {
    expect(normalizeNavPath('  /about  ')).toBe('/about');
  });
});

describe('isCurrentNavPath', () => {
  // THE REPRODUCTION. `nav.json` stores `/about` while Astro's default
  // directory build renders the pathname as `/about/`. Under the old strict
  // equality this returned false, so About and Contact were both left muted on
  // the live site. This is the case the whole fix exists for.
  it('treats /about and /about/ as the same page', () => {
    expect(isCurrentNavPath('/about', '/about/')).toBe(true);
  });

  // The mirror image, and the reason both sides are normalized rather than
  // just stripping the pathname: a CMS author can equally type `/about/` into
  // nav.json, which would break the match in dev where the pathname is
  // `/about`. Stripping only one side fixes one direction and not the other.
  it('treats a stored trailing slash as the same page too', () => {
    expect(isCurrentNavPath('/about/', '/about')).toBe(true);
  });

  // The ordinary hit — both sides already written the same way.
  it('matches two identical paths', () => {
    expect(isCurrentNavPath('/about', '/about')).toBe(true);
  });

  // The ordinary miss. Every nav renders more than one item, so getting this
  // wrong would ink every link at once.
  it('does not match a different page', () => {
    expect(isCurrentNavPath('/contact', '/about/')).toBe(false);
  });

  // Normalizing must not turn the comparison into a prefix test. `/about-us`
  // shares an opening with `/about` but is a different page, and a sloppy
  // startsWith implementation would light up both.
  it('does not match a page whose path merely starts the same way', () => {
    expect(isCurrentNavPath('/about', '/about-us/')).toBe(false);
  });

  // A NavItem may be a dropdown parent carrying only children and no url of
  // its own. There is no page to be on, so it can never be current — and a
  // naive compare would risk matching it against an empty pathname.
  it('returns false for a nav item that has no url', () => {
    expect(isCurrentNavPath(undefined, '/about/')).toBe(false);
  });

  // The root has to match itself once a Home item exists in the menu.
  it('matches the site root against itself', () => {
    expect(isCurrentNavPath('/', '/')).toBe(true);
  });

  // The guard that makes the root special-case worth having: if `/` normalized
  // to the empty string, a Home item would be marked current on every page of
  // the site.
  it('does not mark the site root current on an inner page', () => {
    expect(isCurrentNavPath('/', '/about/')).toBe(false);
  });

  // Case differences between a CMS-authored url and the rendered pathname are
  // invisible to the visitor, so they must not decide the highlight.
  it('matches regardless of case', () => {
    expect(isCurrentNavPath('/About', '/about/')).toBe(true);
  });
});
