<!--
  The combinatorial axes in "The axes" below are adapted from the Combinatorial
  Variation Engine in Leonxlnx/taste-skill (`skills/image-to-code-skill`, MIT,
  read 2026-09-23), and the slop lists are condensed from that skill's
  anti-AI-slop rules. Its surrounding workflow — generate images with an image
  model first, then code from them — does not apply here: a design round writes
  static HTML into a scriptless sandbox and has no image model in the loop. Only
  the direction-picking machinery was taken.

  Everything else in this file is CodeYam's, including the whole of "How to use
  this" and "The reading of a collision."
-->

# The variation engine

A set of mockups fails when its slots differ in *color* and agree in everything
else. That is what a reader means by "these all look the same," and it is what
happens when each slot is designed by asking "what would look good for this
brief?" — because that question has one best answer, and every slot converges on
it.

This file replaces that question. Before writing any HTML, each slot commits to
an explicit combination of the axes below. The axes are chosen so that two slots
differing on three of them cannot read as variants of each other, no matter how
close their palettes end up.

## How to use this

1. **Assign each slot its combination before writing any file.** Write them down
   as a small table, one row per slot. Doing this after the fact is doing it
   never.
2. **No two slots in a set share more than two axis values.** Three shared
   values is a near-variant; that is the line. Check the table against itself
   before you start, not after.
3. **Commit to the combination.** A slot that hedges between two hero
   architectures has neither. Pick, then execute cleanly. Range lives *across*
   the set; each individual slot is disciplined.
4. **The combination serves the brief, not the other way around.** If an axis
   value would actively fight what the product is (a scattered-polaroid hero on
   a clinical medical dashboard), do not take it just to fill the table. Take a
   different value and note why.
5. **Do not mash axes together for novelty.** The engine exists to spread a set,
   not to make any one slot strange.

## The axes

**Theme paradigm** — pristine light · deep dark · bold studio solid · quiet
premium neutral.

**Background character** — technical grid or dotted field · solid field with
ambient gradient depth · full-bleed imagery · tactile textured surface.

**Typography character** — clean grotesk · refined grotesk · expressive display ·
compressed statement type · editorial serif paired with sans · Swiss rational
hierarchy.

**Primary composition** — centered minimalist · asymmetric split · scattered
card arrangement · oversized inline typography · editorial offset · image-first
with restrained text.

**Section system** — modular bento rhythm · alternating editorial blocks ·
poster-like stacked storytelling · gallery cadence · Swiss grid discipline ·
asymmetric marketing flow.

**Signature components** — pick exactly three, and let them be the slot's
recognizable furniture: staggered masonry · cascading card deck · accordion
slice layout · gapless bento grid · marquee strip · vertical rhythm rules ·
off-grid editorial placement · product UI panel stack · quote wall · layered
image crop frames · ranked list with rank as a typographic element · ledger
table with tabular figures.

**Density** — airy · measured · dense. This axis is not decoration: it is
usually the fastest way to make two otherwise-similar slots read as genuinely
different products.

**Implied motion** — pick at most two, and remember `frontend-design.md`'s rule
that motion is spent once, deliberately: scrubbing text reveal · pinned
narrative · staggered float-up · parallax drift · accordion expansion ·
cinematic fade-through. In a mockup these are *implied* by composition and
static state, never animated, because the sandbox blocks scripts.

## The reading of a collision

Two slots that share theme paradigm and typography character will read as the
same design even with different accent colors, because those two axes carry most
of a page's identity. If a set needs both slots, separate them hard on
composition, section system, and density.

The inverse is also true and more useful: a slot that keeps the brief's palette
but moves composition, section system, and density is unmistakably a different
direction while still obviously belonging to the same product. That is the shape
of a good set — one product, several convictions about it.

## Slop, which is what the engine is really guarding against

Every item below is a thing that shows up when a slot is designed by default
rather than by decision. They are not style preferences; they are the tells.

**Layout** — endless centered sections · identical card rows repeated down the
page · cloned left-text/right-image blocks · cards inside cards inside cards ·
one giant rounded wrapper around everything · empty space with no job ·
compartment framing on content that is not compartmentalized.

**Visual** — default purple-to-blue gradients · glowing edges · floating blobs ·
stacked glassmorphism with no reason · noise that hides the layout rather than
supporting it.

**Typography** — a huge heading over weak tiny subcopy · more than two type
moods · all-caps used as a substitute for hierarchy · gradient-filled headline
text.

**Density** — over-packed sections · card overload · major sections separated by
minor spacing · walls of content with no rest.

**Copy** — unleash · elevate · revolutionize · next-gen · seamless ·
transformative platform. And fake-brand filler: Acme, Nexus, Flowbit,
Quantumly, NovaCore. Use the product's real vocabulary; if the brief has not
supplied one, the discovery interview in `brand-discovery.md` should have.

**Fake complexity** — pseudo-enterprise control labels, decorative system
markers, filler status microcopy, invented operator or runtime jargon. A mockup
that pretends to more machinery than the product has is lying about the product.

## Section rhythm

Within a single slot, a page that repeats one block down its length reads as
cheap regardless of how good that block is. Vary, across the page: density,
image-to-text ratio, alignment, scale, whitespace, grouping, background
intensity. This is the intra-slot counterpart of what the axes do between slots.
