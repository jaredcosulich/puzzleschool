// The site's one point of contact with the CMS's staged-preview marker
// contract.
//
// `@codeyam/cms`'s preview script patches a page exactly where the page SAYS
// what it renders, via inert `data-cms-*` attributes. Those attribute names are
// the CMS's public contract, so this module imports them rather than spelling
// them out — a string literal here would be a copy that silently stops matching
// if the contract moves, and the failure mode is a preview that quietly falls
// back to guessing by shape rather than an error anyone would notice.
//
// Everything returns a plain object meant to be SPREAD onto an element
// (`<h1 {...cmsField('title')}>`), because Astro has no other way to set an
// attribute whose name comes from a constant. Each is inert by construction:
// it adds an attribute and nothing else — no styling, no behaviour, no element
// added, moved or removed.
//
// The setting text/href split is deliberate and mirrors the contract's own: some
// elements render a setting as their TEXT (the nav's site title, the footer
// line), others render fixed text over a setting-derived HREF. One helper taking
// a flag would re-open exactly the guess the CMS split the attributes to prevent
// — guessing wrong overwrites a visible label with a URL.
//
// `cmsSettingHref` currently has no call site in markup. It used to mark the
// footer's Contact link, back when that href was a mailto built from
// `settings.contactEmail`; the link now points at the Contact PAGE, resolved
// from the nav, so marking it would let a staged contact-email edit patch a raw
// address back over `/contact`. The helper stays because the attribute is part
// of the CMS's contract, not because this site happens to use it today.
import {
  CMS_BODY_ATTR,
  CMS_ENTRY_ATTR,
  CMS_FIELD_ATTR,
  CMS_NAV_ITEM_ATTR,
  CMS_SETTING_ATTR,
  CMS_SETTING_HREF_ATTR,
} from '@codeyam/cms/lib/stagedPreview';

/** A spreadable set of HTML attributes. */
export type MarkerAttrs = Record<string, string>;

/**
 * Mark the element that renders one entry, valued `<collection>/<slug>`.
 *
 * Returns NOTHING for a missing key, which is the whole reason this takes an
 * optional argument: pages that render no single entry (the isolated-component
 * pages) must emit no attribute at all rather than an empty one, so their
 * markup is byte-identical to what it was before any of this existed. An empty
 * `data-cms-entry=""` would still match `[data-cms-entry]` and make those pages
 * look like entry roots to the patcher.
 */
export function cmsEntry(key?: string): MarkerAttrs {
  return key ? { [CMS_ENTRY_ATTR]: key } : {};
}

/**
 * Mark an element rendering one frontmatter field.
 *
 * `field` is the FRONTMATTER key, not the component's prop name — the patcher
 * looks the value up as `data[field]` against parsed frontmatter. The two drift
 * apart in practice: `BandQuote` and `QuoteBand` both take a prop called
 * `attribution`, but the frontmatter key is `quoteAttribution`.
 */
export function cmsField(field: string): MarkerAttrs {
  return { [CMS_FIELD_ATTR]: field };
}

/**
 * Mark the element rendering the entry's markdown body.
 *
 * Valueless in the contract, so this emits the empty string; Astro renders that
 * as a bare `data-cms-body`, which `[data-cms-body]` matches either way.
 */
export function cmsBody(): MarkerAttrs {
  return { [CMS_BODY_ATTR]: '' };
}

/**
 * Mark one nav entry, valued with the url it points at.
 *
 * Keyed by url rather than position so reordering the menu does not break the
 * match. Put this on the `<li>`, not the `<a>`: removing a menu item calls
 * `.remove()` on the marked element, and marking the anchor would leave an
 * empty bullet behind.
 *
 * A `NavItem`'s url is OPTIONAL — an item that only groups `children` has none
 * — and such an item gets no marker at all, because the url IS the key the
 * patcher matches on. Emitting one anyway would put `data-cms-nav-item="undefined"`
 * in the markup: an attribute that matches no staged item but still reads as a
 * marker, which is strictly worse than its absence.
 */
export function cmsNavItem(url?: string): MarkerAttrs {
  return url ? { [CMS_NAV_ITEM_ATTR]: url } : {};
}

/**
 * Mark an element whose TEXT is one `settings.json` value.
 *
 * The patcher sets `textContent`, so this belongs on the element that holds the
 * text and nothing else — on a wrapper it would delete the wrapper's siblings.
 */
export function cmsSetting(key: string): MarkerAttrs {
  return { [CMS_SETTING_ATTR]: key };
}

/** Mark a link whose HREF comes from a setting. The visible label is left alone. */
export function cmsSettingHref(key: string): MarkerAttrs {
  return { [CMS_SETTING_HREF_ATTR]: key };
}
