import { describe, expect, it } from 'vitest';
import {
  CMS_BODY_ATTR,
  CMS_ENTRY_ATTR,
  CMS_FIELD_ATTR,
  CMS_NAV_ITEM_ATTR,
  CMS_SETTING_ATTR,
  CMS_SETTING_HREF_ATTR,
} from '@codeyam/cms/lib/stagedPreview';
import {
  cmsBody,
  cmsEntry,
  cmsField,
  cmsNavItem,
  cmsSetting,
  cmsSettingHref,
} from './cmsMarkers';

// These assert against the CMS's own exported constants rather than literal
// `data-cms-*` strings on purpose. Hardcoding the strings here would let the
// test keep passing after an upstream rename while the site silently stopped
// matching — the exact failure the implementation imports the constants to
// avoid. What is worth pinning is the SHAPE and the naming discipline, so the
// one place a literal appears is the guard below that proves the helpers are
// not accidentally all writing the same attribute.

describe('cmsEntry', () => {
  // marks the entry root with the collection/slug key it was given
  it('returns the entry attribute keyed by collection and slug', () => {
    expect(cmsEntry('pages/about')).toEqual({ [CMS_ENTRY_ATTR]: 'pages/about' });
  });

  // a page that renders no single entry must emit no attribute at all
  it('returns an empty object when no key is supplied', () => {
    expect(cmsEntry()).toEqual({});
  });

  // an empty-string key is still "no entry" — it must not emit an empty attribute
  it('returns an empty object for an empty key rather than an empty attribute', () => {
    expect(cmsEntry('')).toEqual({});
  });

  // spreading the no-key result must add nothing to an element's attributes
  it('adds no attributes when spread with no key', () => {
    expect(Object.keys({ class: 'page', ...cmsEntry(undefined) })).toEqual(['class']);
  });
});

describe('cmsField', () => {
  // marks a field element with the frontmatter key the patcher looks up
  it('returns the field attribute valued with the frontmatter key', () => {
    expect(cmsField('kicker')).toEqual({ [CMS_FIELD_ATTR]: 'kicker' });
  });

  // the frontmatter key differs from the prop name for the quote attribution
  it('carries the frontmatter key even when it differs from the prop name', () => {
    expect(cmsField('quoteAttribution')).toEqual({ [CMS_FIELD_ATTR]: 'quoteAttribution' });
  });

  // every call is a fresh object, so spreading one cannot mutate another site
  it('returns a new object on each call', () => {
    expect(cmsField('title')).not.toBe(cmsField('title'));
  });
});

describe('cmsBody', () => {
  // the body marker is valueless in the contract, so it emits the empty string
  it('returns the body attribute with an empty value', () => {
    expect(cmsBody()).toEqual({ [CMS_BODY_ATTR]: '' });
  });

  // the attribute must be PRESENT, since the selector matches on presence alone
  it('emits the attribute rather than omitting it', () => {
    expect(Object.keys(cmsBody())).toHaveLength(1);
  });
});

describe('cmsNavItem', () => {
  // nav items are keyed by url so reordering the menu does not break the match
  it('returns the nav-item attribute valued with the url', () => {
    expect(cmsNavItem('/about')).toEqual({ [CMS_NAV_ITEM_ATTR]: '/about' });
  });

  // the site root is a legitimate nav url and must not be treated as empty
  it('marks a root url', () => {
    expect(cmsNavItem('/')).toEqual({ [CMS_NAV_ITEM_ATTR]: '/' });
  });

  // a NavItem that only groups children has no url, and the url IS the match
  // key — so it gets no marker rather than one valued "undefined"
  it('returns an empty object for an item with no url', () => {
    expect(cmsNavItem(undefined)).toEqual({});
  });

  // never stringify a missing url into the attribute value
  it('never emits the literal string undefined as a url', () => {
    expect(Object.values(cmsNavItem(undefined))).not.toContain('undefined');
  });
});

describe('cmsSetting and cmsSettingHref', () => {
  // a setting rendered as visible text
  it('marks an element whose text is a setting value', () => {
    expect(cmsSetting('footerText')).toEqual({ [CMS_SETTING_ATTR]: 'footerText' });
  });

  // a link whose href comes from a setting while its label stays fixed
  it('marks a link whose href is derived from a setting', () => {
    expect(cmsSettingHref('contactEmail')).toEqual({ [CMS_SETTING_HREF_ATTR]: 'contactEmail' });
  });

  // the text and href markers must stay distinct — collapsing them would let a
  // staged contact-email edit overwrite the visible "Contact" label with a URL
  it('uses different attributes for the text and href cases', () => {
    expect(Object.keys(cmsSetting('contactEmail'))[0]).not.toBe(
      Object.keys(cmsSettingHref('contactEmail'))[0],
    );
  });
});

describe('cmsMarkers attribute naming', () => {
  // every marker is a distinct data-cms-* attribute, so no two helpers collide
  it('gives each helper its own data-cms attribute', () => {
    const names = [
      Object.keys(cmsEntry('pages/home'))[0],
      Object.keys(cmsField('title'))[0],
      Object.keys(cmsBody())[0],
      Object.keys(cmsNavItem('/'))[0],
      Object.keys(cmsSetting('siteTitle'))[0],
      Object.keys(cmsSettingHref('contactEmail'))[0],
    ];
    expect(names.every((n) => n.startsWith('data-cms-'))).toBe(true);
    expect(new Set(names).size).toBe(names.length);
  });
});
