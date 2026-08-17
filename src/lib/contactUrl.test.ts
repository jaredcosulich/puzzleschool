import { describe, expect, it } from 'vitest';

import { resolveContactUrl } from './contactUrl';
import type { SiteNav } from './site';

const nav = (items: SiteNav['items']): SiteNav => ({ items });

describe('resolveContactUrl', () => {
  // The shipped nav. This is the case the footer hits on every page of the
  // real site, so if it ever stops resolving, every footer link breaks at once.
  it('resolves the default About + Contact nav to the contact page', () => {
    expect(
      resolveContactUrl(
        nav([
          { label: 'About', url: '/about' },
          { label: 'Contact', url: '/contact' },
        ]),
      ),
    ).toBe('/contact');
  });

  // The whole reason this reads the nav instead of hardcoding a path: an editor
  // who moves the page in the CMS must move the footer link with it. Hardcoding
  // '/contact' passes every other test here and fails this one.
  it('follows a Contact item that has been moved to a different url', () => {
    expect(
      resolveContactUrl(
        nav([
          { label: 'About', url: '/about' },
          { label: 'Contact', url: '/get-in-touch' },
        ]),
      ),
    ).toBe('/get-in-touch');
  });

  // The opposite edit — the page stays put but the label is reworded. The label
  // pass misses it, so the url pass has to catch it or the footer falls back to
  // a path that happens to be right for the wrong reason.
  it('falls back to matching on the url when the label was reworded', () => {
    expect(
      resolveContactUrl(
        nav([
          { label: 'About', url: '/about' },
          { label: 'Get in touch', url: '/contact' },
        ]),
      ),
    ).toBe('/contact');
  });

  // Label beats url, and only a nav containing BOTH kinds of edit can prove it.
  // A single-pass implementation in item order would return '/contact' here,
  // which is the entry the editor renamed AWAY from the contact page.
  it('prefers the label match over a url match when the nav contains both', () => {
    expect(
      resolveContactUrl(
        nav([
          { label: 'Archive', url: '/contact-archive' },
          { label: 'Contact', url: '/get-in-touch' },
        ]),
      ),
    ).toBe('/get-in-touch');
  });

  // Menus nest. A Contact page filed under an "About" dropdown is an ordinary
  // shape, and a resolver that only walked the top level would silently fall
  // back and point the footer somewhere the editor did not choose.
  it('finds a Contact item nested under a dropdown parent', () => {
    expect(
      resolveContactUrl(
        nav([
          {
            label: 'About',
            children: [
              { label: 'Our story', url: '/about' },
              { label: 'Contact', url: '/contact' },
            ],
          },
        ]),
      ),
    ).toBe('/contact');
  });

  // A dropdown parent has no url, so a naive `find` on the label would return
  // it and put href="undefined" in every footer. The parent is a heading; the
  // answer is the child beneath it.
  it('skips a url-less dropdown parent rather than returning undefined', () => {
    expect(
      resolveContactUrl(
        nav([
          {
            label: 'Contact',
            children: [{ label: 'By email', url: '/contact' }],
          },
        ]),
      ),
    ).toBe('/contact');
  });

  // Removing the nav item must not empty the href. The page is not nav-gated,
  // so '/contact' is still a live route even with nothing in the menu.
  it('falls back to the contact page when no nav item matches', () => {
    expect(resolveContactUrl(nav([{ label: 'About', url: '/about' }]))).toBe('/contact');
  });

  // The degenerate singleton — an editor who cleared the menu entirely. Same
  // fallback, but it exercises the empty-array path rather than the no-match one.
  it('falls back to the contact page for an empty nav', () => {
    expect(resolveContactUrl(nav([]))).toBe('/contact');
  });

  // Case is the editor's business, not ours: "CONTACT" in a shouty menu and
  // "contact" in a lowercase one both mean the same page.
  it('matches the label case-insensitively', () => {
    expect(resolveContactUrl(nav([{ label: 'CONTACT', url: '/reach-us' }]))).toBe('/reach-us');
  });
});
