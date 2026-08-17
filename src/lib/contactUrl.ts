// Where the footer's "Contact" link points, derived from the editable nav
// singleton rather than hardcoded.
//
// The footer used to emit a `mailto:` built from `settings.contactEmail`, which
// meant the one link labelled "Contact" skipped the Contact page entirely and
// opened a mail client. The page already exists and already carries the real
// call to action, so the footer's job is to get the visitor there.
//
// The destination is READ FROM THE NAV, not written as a literal `/contact`,
// because the nav is the one place an editor can already move that page from —
// `src/data/nav.json` is a CMS-editable singleton. Hardcoding the path would
// let the footer link and the menu entry drift apart the moment someone renames
// or relocates the page, and nothing in the CMS could fix it: the Settings
// singleton's fields are fixed by the `@codeyam/cms` package, so there is no
// field anywhere that controls this link directly.
//
// Deliberately free of `fs` and of any `src/data` import, unlike `site.ts`,
// which resolves the data root at module scope. The caller passes the nav it has
// already loaded, so this stays a pure function with a colocated unit test —
// the same shape as `buildMailto` and `linkedPathForRealFile`.
import type { NavItem, SiteNav } from './site';

/** Where the Contact page lives when the nav names no contact entry at all. */
const FALLBACK_CONTACT_URL = '/contact';

/**
 * Every nav item, parents before their own children, flattened depth-first.
 *
 * A dropdown parent groups `children` and has no `url` of its own, so items are
 * kept here rather than filtered: the caller decides what a url-less item means
 * (it can never be the answer, but its children still can).
 */
function flatten(items: NavItem[]): NavItem[] {
  return items.flatMap((item) => [item, ...flatten(item.children ?? [])]);
}

/**
 * The url the footer's Contact link should point at, resolved from `nav`.
 *
 * Matching runs in two passes, and the order is the point. The LABEL is what an
 * editor sees and edits, so it wins first: an item labelled "Contact" that has
 * been moved to `/get-in-touch` should retarget the footer, not be ignored in
 * favour of some other item that merely sits under `/contact`. The URL pass is
 * the fallback for the opposite edit — a page left at `/contact` but relabelled
 * to something like "Get in touch", where the label no longer says "contact"
 * but the destination is still right.
 *
 * A single pass in item order cannot express that: it would resolve whichever
 * of the two edits happened to appear first in the menu, which is arbitrary.
 *
 * Items with no `url` are skipped — a dropdown parent labelled "Contact" is a
 * heading, not a destination, and returning its (absent) url would put
 * `href="undefined"` in the footer. Returns `/contact` when nothing matches, so
 * removing the nav item degrades to the page's real path rather than an empty
 * href. The page is not nav-gated, so that fallback is always a live route.
 */
export function resolveContactUrl(nav: SiteNav): string {
  const linked = flatten(nav.items ?? []).filter(
    (item): item is NavItem & { url: string } => Boolean(item.url),
  );

  const byLabel = linked.find((item) => item.label?.toLowerCase().includes('contact'));
  if (byLabel) return byLabel.url;

  const byUrl = linked.find((item) => item.url.startsWith(FALLBACK_CONTACT_URL));
  if (byUrl) return byUrl.url;

  return FALLBACK_CONTACT_URL;
}
