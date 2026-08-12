import { defineCollection, z } from 'astro:content';
import {
  collectionLoader,
  draftField,
  previewFields,
  seoFields,
} from '@codeyam/cms/content';

// The Puzzle School's content model.
//
// Every page on this site is a `pages` entry — including the home page. That is
// deliberate: the whole point of running on @codeyam/cms is that a new page can
// be created from /admin and go live without anyone touching code, and that only
// holds if the pages that already exist are made of the same stuff as the ones
// still to come. A home page hardcoded in .astro while everything else lives in
// markdown would be a special case that quietly re-invites hardcoding.
//
// Collections load through `collectionLoader` rather than a bare `glob` so their
// base directory follows the engine's content-root resolution: committed
// `src/content` in production, the `.codeyam/tmp` sandbox during a codeyam
// session, so scenario seeding never mutates source.
//
// Three shared field groups are spread into the schema. They are not optional
// bookkeeping — a Zod object STRIPS keys it does not declare, so omitting
// `draftField` makes the dashboard's Draft toggle write `draft: true` into
// frontmatter that this schema then throws away, with no build error to say so.
// `previewFields` has the same shape of failure for shareable preview links.

/**
 * One of the design's two action cards. The home page's card grid is three
 * columns wide and deliberately holds only two cards — the empty third column is
 * part of the design's "one piece is always missing" idea, so the layout gets its
 * emptiness from the grid, never from a placeholder entry here.
 */
const actionCard = z.object({
  title: z.string(),
  body: z.string(),
  href: z.string(),
  label: z.string(),
  /** Which accent paints the 6px top border and the button. */
  accent: z.enum(['teal', 'coral']),
});

const pages = defineCollection({
  loader: collectionLoader('pages'),
  schema: z.object({
    title: z.string(),
    /** Short summary; also the default SEO description when none is set. */
    description: z.string().optional(),
    /** Sort order when a page appears in a generated list. */
    order: z.number().optional(),

    // ---- Home-page-shaped fields -----------------------------------------
    // All optional, so an ordinary internal page (About, Contact, or anything
    // created later from /admin) declares none of them and renders through the
    // standard internal-page template.

    /**
     * Small uppercase line above the title. Teal under the home wordmark; muted
     * above an internal page's 76px heading, where it carries the long form of
     * the name ("About the school" above "About").
     */
    kicker: z.string().optional(),
    /**
     * The standfirst set beside the title in an internal page's two-column
     * header — the one paragraph a reader gets before the columns begin.
     */
    intro: z.string().optional(),
    /** The 56px statement heading. */
    heading: z.string().optional(),
    /** The 24px line that closes the home statement block. */
    lead: z.string().optional(),
    /** Body copy set beside the heading inside a dark band. */
    bandBody: z.string().optional(),
    /** The two action cards. */
    cards: z.array(actionCard).optional(),
    /** Pull quote shown in the dark band. */
    quote: z.string().optional(),
    /** Who said it. */
    quoteAttribution: z.string().optional(),

    /**
     * Render a mailto button on this page, addressed to `settings.contactEmail`.
     * A flag rather than a URL on purpose: the address then lives in exactly one
     * editable place, so changing it is one CMS edit instead of a hunt through
     * every page that happens to link to it.
     */
    showContactButton: z.boolean().optional(),

    ...draftField,
    ...previewFields,
    ...seoFields,
  }),
});

export const collections = { pages };
