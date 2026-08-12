# Design Systems

This folder ships with every new CodeYam project as
`.codeyam/design/design_systems/`. It is a curated catalog of design-system
documents the build agent can read directly. Whichever one becomes the
*active* design system gets copied to `.codeyam/design/design_system.md` —
the canonical source the build agent injects into its step context.

## When is the active design system written?

Set by the user's choice on questionnaire step 4 ("How should we approach
design?"):

- `files` — the build agent inspects uploaded reference files
  (`.codeyam/design/user_files/`) and writes a synthesized
  `design_system.md` during the first build session.
- `chat` — a post-scaffold mini-chat generates HTML mockups under
  `.codeyam/design/project_mockups/`. The user picks one in the Live
  Preview, and the editor copies the matching system's markdown from this
  folder into `design_system.md`.
- `skip` — no active system is written. The build agent runs without a
  design-system block in its handoff.

## File naming

`<kebab-case-name>.md` — for example `keylime.md`, `mono-brutalist.md`,
`letters-to-sean.md`. No `-design-system` suffix. The filename (minus
extension) is the canonical system *id*.

The mockup naming convention is `<system-id>-mockup.html` so the
mockup-selection endpoint can resolve a clicked card back to a doc in this
folder.

## Required structure

Every document in this folder must follow the section order below. The
`## How to use this system` section is required verbatim because the
Option-2 (`chat`) design-exploration prompt depends on it.

1. `# [Name]` — the system's display name. Plain heading, no suffix.
2. Blockquote tagline immediately under the title (`> one-line essence`).
3. `## Origin`, `## Theme`, or `## Philosophy` — short DNA paragraph
   that explains what the system is *for*.
4. `## How to use this system` — **required**. Two subsections:
   - `### Minimum viable composition` — components essential to making
     the system look like itself.
   - `### Example compositions are examples` — showcase patterns,
     explicitly opt-in.
5. `## Foundations` or `## Tokens` — color tokens (light + dark where
   applicable), typography (family + scale), spacing, radius, motion.
6. `## Components` — common UI atoms. Button, card, input, badge, table
   at minimum.
7. `## Patterns` — cross-context recipes (forms, lists, navigation, etc.).
8. `## Anti-patterns` — what *not* to do with this system. Each entry is
   a one-line "don't ... because ...".

A document that omits a required section may still ship, but the chat
prompt will degrade gracefully — it will skip systems whose "How to use
this system" block is missing.
