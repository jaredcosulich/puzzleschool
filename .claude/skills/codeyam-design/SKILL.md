---
name: codeyam-design
description: |
  Inline design-exploration helper. Reads the user's product description
  and any uploaded design assets, derives a brief-specific design read,
  and generates a diverse, numbered set of HTML mockups spanning three
  tiers — anchored (faithful to a curated design system), exploratory (a
  system used as a springboard), and off-catalog (bespoke from the brief
  + assets) — into .codeyam/design/project_mockups/, then listens for
  "Let's use N" to lock the choice in.
---

# Design exploration

You are helping the user pick a design direction inside the new-project questionnaire's chat substep. The project files do not exist yet — **do not scaffold, install dependencies, or run any `codeyam-editor editor` command**. Your only job is to read the brief and assets, read the bundled design systems, write mockup HTML, and (on the user's pick) POST a single API call.

## Round mode — designing against an app that already exists

This skill has two modes. Everything above and below assumes **questionnaire mode** (project does not exist yet). When a **design round** is active — the file `.codeyam/design/rounds/.active` exists, naming a round id — you are in **round mode**, running against an app that already exists, and the following overrides apply. Everything else in this skill (the companions and how each binds, the design read, the Step 2a match test and variation-engine assignment, imagery/typography rules, atomic writes, the Step 3b lint self-correction loop) is reused verbatim.

- **Active round + directory.** Read the active round id from `.codeyam/design/rounds/.active`; the round directory is `.codeyam/design/rounds/<round-id>/`. It already holds `current-state.md`, written by the grounding step.
- **`current-state.md` is a primary input, alongside `projectDescription`.** It describes the surface being modified as it looks TODAY — the scenarios that render it, their data states, and what this round is trying to change. Read it before deriving the design read; the mockups are **variations on that real screen**, not a fresh invention.
- **The existing `.codeyam/design/design_system.md` (if any) is the anchored tier's reference** instead of a freshly-chosen catalog system.
- **Step 1 changes.** "Which page to mock up" is already answered by grounding — **do NOT re-ask it.** The count question (2/4/6/8, default 6) and the assets question stay.
- **Tier semantics gain the existing-app reading.** The **anchored** tier means "the app as it looks today, with the requested change applied" — the safe, minimally-disruptive direction — not a fresh catalog system. Exploratory and off-catalog keep their meaning. **The Step 2a match test does not run in round mode**: the app's existing design system is the anchor by definition, so `M = 1` and the allocation table's `M = 1` row applies. The never-as-a-skin rule, the anchored-archetype rule, and the variation-engine assignment all still apply unchanged.
- **The `codeyam-editor` command prohibition is LIFTED in round mode.** The project exists and you legitimately need `codeyam-editor editor plan-show`, `... scenarios`, and the capture commands to ground and iterate. (The prohibition stays in questionnaire mode.)
- **Output paths are round-relative.** `target.json` and every `NN-*-mockup.html` go in the round directory, NEVER `.codeyam/design/project_mockups/`. The mockup/tab/lint API calls take a `?round=<round-id>` scope; the project-wide directory is left untouched.
- **Selection is handled by the WORKFLOW, not the Step 6 POST.** In round mode do NOT POST `/api/editor-design-select`. The user's pick is recorded by the design workflow's iterate/apply steps (`codeyam-editor editor branch-outcome design-iterate use` then `... design-round --select <mockup>`), which synthesizes an off-catalog token document automatically — closing the handoff gap the questionnaire flow leaves open. Your job in round mode ends at generating and iterating on the mockups; the workflow carries the selection.

**The brief drives; the systems are a floor, not a ceiling.** The user's product description and any uploaded design assets are the primary signal — every mockup must feel like *their* product, not a stock template. The curated design systems in `.codeyam/design/design_systems/` are a quality floor: a vocabulary of robust, internally-consistent languages you can adhere to, stretch, or set aside depending on a mockup's *tier* (Step 2). Your goal across a set is **genuine range** — diverse directions — anchored by at least one safe, on-brief option, and (when the set is large enough) reaching all the way to a fully bespoke, off-catalog direction.

## Inputs

- **`frontend-design.md` — required reading, before anything else.** It sits next to this file, in this skill's own directory (`.claude/skills/codeyam-design/frontend-design.md`). It is Anthropic's `frontend-design` skill, vendored verbatim, and it is the aesthetic authority for every mockup you write. **Read it in full before you derive the design read in Step 2** — not as background, as instructions. This file and it divide the work cleanly: `frontend-design.md` decides *what makes a design good* (palette, typography, layout, motion, copy, restraint, and the list of generated-looking defaults to avoid); this file decides *what the exploration is* (how many mockups, which tiers, where files land, how a pick is recorded). Where they touch, the rules below say which wins — and unless a rule below says otherwise, `frontend-design.md` wins.
- **Project description** — read it from `.codeyam/editor.json`, key `projectDescription`. If the file or the key is missing, ask the user briefly to describe the product before continuing.
- **Design assets (if any)** — uploaded files live in `.codeyam/design/user_files/`, with a manifest at `.codeyam/design/user_files/manifest.json` listing `{ filename, description }`. **Do not just read the filenames — actually open and *look at* each visual asset.** A logo, screenshot, or brand reference carries a palette, a type personality, and a mood. View the image, extract its dominant colors (as hex), note its type feel (geometric / humanist / serif / mono / hand-drawn) and overall mood, and let those **shape the tokens** of your mockups — not merely sit embedded as decoration. (Rules for *embedding the asset itself* are in Step 3; this bullet is about *deriving design signal* from it.) Raster images (PNG, JPG, GIF, WebP), SVG, and PDF all open directly — a PDF renders page by page. **If an asset will not open** (an unsupported format, or the renderer reports a missing tool), **do not derive the design read without it**: tell the user which file you could not see and ask for a PNG or JPG export. A palette or brand asset you never looked at is the most valuable signal in the round, and skipping it silently is the one outcome this bullet exists to prevent.
- **`brand-discovery.md`, `variation-engine.md`, `web-interface-guidelines.md`, `taste-skill.md`** — the skill's other companions, in this same directory. Each belongs to a step and is read there, not up front: **`brand-discovery.md`** at Step 1, when the brief names no visual direction; **`variation-engine.md`** at the end of Step 2, to give every slot its combination; **`web-interface-guidelines.md`** at Step 3b, as the checkable quality floor; **`taste-skill.md`** at Step 2 (right after `frontend-design.md`, for the per-slot dials and the list of AI tells) and again at Step 3b (its pre-flight check). Read each when its step arrives.
- **Design references** — every `.md` file in `.codeyam/design/design_references/` (skip `README.md`): 74 analyses of how existing products build their interfaces, carrying real palettes, type scales and component anatomy. They are a **reading library, not a catalog**: read them for craft, never apply one as a skin (Step 2a). Read that folder's `README.md` once before you draw on any of them.
- **Design systems** — every `.md` file in `.codeyam/design/design_systems/` (skip `README.md`). Each is a self-contained design language with sections like `## How to use this system`, `## Foundations`, `## Components`. Read the systems you pick carefully; *how closely you obey them depends on the tier.*
- **Reference example mockups (some systems only)** — `<system>-example-<surface>.html` files (`dashboard`, `landing`, `mobile`) are pre-built reference screens showing how a system renders in practice. They are NOT runtime project mockups (those use `NN-<...>-mockup.html` naming). When you anchor on or springboard off a system in Step 2, **open every matching `<system>-example-*.html` and skim the one closest to your page** — it locks in spacing, type weights, and color application the markdown underspecifies. Systems without example files still work; lean on the markdown.

## Step 1 — greet the user and gather inputs before generating anything

### Questionnaire mode: ask through the questions form, not the terminal

In questionnaire mode the user sees a **design session**: your terminal on the left and a canvas on the right. **Everything Step 1 asks (the brand-discovery interview, clarifying questions, which page, how many mockups, whether the product shows real photos) goes into ONE questions form on the canvas, never into the terminal.** The editor renders it with clickable options, a "write your own" field and an "I don't know" button on every question. (Round mode is unchanged: keep asking in the terminal.)

**The user reads you in a chat, not a terminal.** The session's left pane shows your conversation as a friendly chat for people who are not technical: of each of your turns it shows **only your last message**, and folds everything before it (your thinking out loud, files read, commands run) behind a "Show steps" link. So in questionnaire mode:

- **End every turn with one message written for that reader.** Two to four short sentences: what you did, what they can look at on the right, and what they can do next. Plain words, like a designer talking to a client.
- **Keep the machinery out of that message.** No file paths, commands, tool names, token or CSS names, and no process jargon such as "anchored", "exploratory", "off-catalog", "tier", "match test" or "variation engine". Say "a safe version close to a proven style" or "a bolder take", and name each direction by what it looks like ("soft and warm, like a paper notebook").
- **Narrate the work as little as you can** between tool calls; nobody sees it unless they open the steps. The last message is what counts.
- The Step 4 key follows the same rule in questionnaire mode: one line per design, its number, a plain name and what makes it different, no tier labels.

1. **Read first.** The project description (`.codeyam/editor.json` → `projectDescription`) and every file in `.codeyam/design/user_files/` (the user attached them on the prompt screen before this session started; see Inputs). Your questions must reflect what you read: never ask something a file already answers.
2. **Write the form** to `.codeyam/design/questions.json` with your file tools (write to a temp file and rename, so the editor never reads half a file):

   ```json
   {
     "title": "Quick questions before I design this",
     "lede": "One sentence, in your words, on what you understood the project to be.",
     "questions": [
       { "id": "page", "type": "single", "title": "Which screen should I design first?",
         "why": "Why this matters, in one sentence. Cite the section when it comes from an attached file, e.g. \"The spec lists 20+ screens (6.8).\"",
         "options": [ { "label": "Participant dashboard", "detail": "What teachers see first" }, { "label": "Admin home" } ],
         "ownPlaceholder": "Optional hint for the write-your-own field" },
       { "id": "lead", "type": "multi", "max": 3, "title": "What should the screen lead with?", "why": "…",
         "options": [ { "label": "Next action" }, { "label": "Progress" }, { "label": "Shipping" } ] },
       { "id": "count", "type": "single", "title": "How many directions should I design?", "why": "More directions, more range; fewer, faster to compare.",
         "options": [ { "label": "2" }, { "label": "4" }, { "label": "6", "detail": "Recommended" }, { "label": "8" } ] },
       { "id": "extra", "type": "free", "title": "Anything else I should know?", "why": "Optional.", "placeholder": "e.g. …" }
     ],
     "defaults": { "page": "Participant dashboard", "lead": ["Next action"], "count": "6" }
   }
   ```

   - `type` is `single` (option cards, for options that need a `detail` line), `multi` (compact chips, capped at `max`) or `free` (a text box; put it last, it is optional). **The user can pick more than one card on a `single` question too**, so write options that can combine, and expect an array back.
   - Three richer types, for the questions that need them:
     - `palette`: which color should lead. Options carry a hex and show as swatches: `{ "id": "accent", "type": "palette", "title": "…", "why": "…", "options": [ { "label": "Sprout green", "hex": "#4E8A2A", "detail": "Matches the logo mark" } ] }`. Offer 2 to 4 colors taken from the user's files when they have a brand; the answer is an array of labels like `single`.
     - `personality`: how it should feel. `{ "id": "look", "type": "personality", "title": "What should it feel like?", "why": "…", "sliders": [ ["Playful", "Serious", 40], ["Soft", "Clinical", 50] ], "moreSliders": [ ["Warm", "Cool"], ["Airy", "Dense"] ], "words": ["Calm", "Private", "Bold"], "moreWords": ["Cozy", "Sleek"], "maxWords": 6, "textPlaceholder": "e.g. Like a journal I want to open" }`. Use it instead of a plain "which mood?" question when the brief does not settle the visual style. Answer: `{ "sliders": { "Playful|Serious": 20 }, "words": ["Calm"], "text": "…" }`. Only moved sliders appear (0 is all the way left, 100 all the way right), and the summary spells out the leanings.
     - `refs`: only when the user attached reference images. One row per image: `{ "id": "refs", "type": "refs", "title": "What should I take from each reference?", "why": "…", "images": [ { "file": "ref-1.png", "label": "School dashboard", "sees": "A left sidebar, big numbers on white cards" } ], "parts": ["Layout", "Colors", "Type", "Illustrations", "Mood"] }`. `file` is the path inside `.codeyam/design/user_files/`; `sees` is one line on what you noticed. Answer: `{ "picks": { "ref-1.png": ["Layout"] }, "notes": { "ref-1.png": "only the big numbers" } }`. Borrow only the parts the user picked.
   - Defaults for these: a palette label, `{ "words": [..] }` for personality, and `{ "<file>": ["Layout"] }` for refs.
   - **3 to 6 questions.** Every question has a `why`. Ask only what you cannot infer; skip what the brief or the files already settle. The brand-discovery interview's questions become questions in this same form, not a separate message.
   - `defaults` holds your best guess for each question (by `label`); the form's "Decide for me" button fills them in.
3. **Tell the user in the terminal**, in two or three sentences: what you read (name the files), what you understood, and that you put a few questions on the right. Then **end your turn and wait.** Do not write any mockup HTML yet.
4. **When the user replies "I answered the questions in the preview"**, read `.codeyam/design/answers.json`:

   ```json
   { "answers": { "page": ["Participant dashboard", "Admin home"], "lead": ["Next action", "Progress"], "count": "__idk", "extra": "free text" },
     "own": { "page": "their own words, when they wrote some" },
     "summary": [ { "id": "page", "title": "Which screen should I design first?", "answer": "Participant dashboard, Admin home, their own words" } ] }
   ```

   `summary` is the readable version; read it first. Choice answers are arrays of picked labels (possibly several, possibly empty when the user only wrote their own words in `own[id]`); `"__idk"` means **decide yourself** and say which way you went in the Step 4 key. When a `single` question comes back with two picks (two screens, two moods), honor both: split the directions between them or combine them, and say which in the Step 4 key. Then continue with Step 2. If the user answers in the terminal instead, that works too: use what they wrote.

The rest of Step 1 below describes **what** to find out. In questionnaire mode, it all arrives through that form.

**First message — introduce yourself and the flow.** Open with a short, warm greeting that explains exactly what's about to happen so the user is oriented before answering. One short paragraph — friendly, not corporate. Use your own words, but the gist must be along the lines of:

> "Hi! I'm here to help with your design exploration. I'll generate a few mockups of one page of your product — some playing it safe and on-brief, some pushing in bolder directions — so you can compare directions side-by-side and pick the one that fits. Before I start, I have a couple of quick questions."

Then in the same message (or the next — your call), do all of the following, batched together so the user isn't ping-ponged:

**Read the project description first.** Open `.codeyam/editor.json` and read `projectDescription`. Note anything you genuinely don't understand: surface type (mobile / web / desktop), primary user (consumer / professional / internal), the one or two screens that matter most, the tone (playful / serious / clinical / editorial).

**Settle the surface from the questionnaire answers before you ask about it.** Read `.codeyam/state/questionnaire-draft.json` and look at `answers.appFormats`. It records the product types the user actually picked, and `"mobile"` is one of them — a stated answer, strictly better than re-inferring the surface from the free-text idea. If it names `"mobile"` and nothing else, this is a **mobile round**: compose for a phone (Step 3) and do not ask the clarifier below. Read the file directly and **fail quiet** — it is per-machine runtime state, written only while someone is mid-questionnaire and removed when onboarding ends, so a missing or unreadable file is normal and simply means fall through to asking. Use a plain file read; do **not** shell out to `codeyam-editor editor` here.

**Then decide whether the brief carries a visual direction at all — this is a gate, and it changes what you ask.** Read `projectDescription` and ask whether it constrains *any* of palette, type personality, tone, density, or reference points. "A dark, minimal wellness tracker in Spanish and English" constrains several. "An app to track my cycle" constrains none: it says what the product does and nothing about how it should look.

- **No visual direction → run the discovery interview.** Open `brand-discovery.md` and run it as written. It is five questions, asked in one message, and it exists because a functional brief hands you nothing to design *from* — so the agent picks the safest available direction and every mockup converges on it. That is the repetition complaint at its source, and this is the fix. The interview is skippable by the user and must never block: if they say go, proceed on your own reading and state the assumptions in the Step 4 key.
- **Direction already present → skip the interview entirely** and do not mention it. Asking a user to describe what they already described is the fastest way to make the step feel like it isn't listening. Skip per-question, too: a brief that says "dark and minimal" but nothing about audience gets the audience question and not the tone question.

**Ask any remaining clarifying questions you actually need answered.** Good ones: *"Is this primarily mobile or desktop?"* (only when the questionnaire draft above didn't settle it), *"Who's the main user — a power user or a first-timer?"*. Only ask what you cannot reasonably infer, and fold them into the same message as the interview so the user answers everything once. If the description already covers it, skip it.

**Ask which page to mock up — but only if it isn't obvious.** All N mockups depict **the same page of the product** in different directions — that is the whole point of the comparison. If the description makes the primary working surface obvious (a SaaS → its dashboard, a creative tool → its editor, a social app → its feed, a landing-focused product → the home / hero), pick it yourself and **tell the user in one sentence which page you chose**. Only ask if the product genuinely has multiple equally-central surfaces — and when you ask, suggest 2–3 candidate pages.

**Ask how many mockups to generate.** Offer **2, 4, 6, or 8**, with **6 as the default** — say "I'll generate 6 mockups unless you'd like more or fewer (2 / 4 / 6 / 8 available)." Wait for their pick (or confirmation of the default). Call this number `N`. If the user replies with anything outside `{2, 4, 6, 8}`, clamp to the nearest allowed value and tell them what you're using. **N sets the size of the set, not its boldness** — how many slots go bespoke is decided in Step 2a by how many catalog systems genuinely match the brief, not by N.

**Design assets — in questionnaire mode, do NOT ask.** The user attached their files on the prompt screen, and there is no "Add design assets" panel in the design session. If `.codeyam/design/user_files/` holds files, treat it exactly as option 1 below (view them, derive the tokens, embed them); if it is empty, treat it as option 3. If the user later says they added more files, re-read the manifest. The three-option question below is for **round mode** only.

**Ask about design assets (round mode) — present exactly these three options.** Before writing any mockup HTML, ask whether the user has design assets to fold in, and offer these three choices verbatim:

1. **"I've added the design assets to the right-hand panel (under 'Add design assets')."** — Proceed: read the manifest at `.codeyam/design/user_files/manifest.json`, then **open and view each visual asset** and derive its palette/type/mood (per Inputs). Fold that derived read into the tokens of *every* mockup, and embed the asset itself verbatim and inline:
   - For raster assets (`.png`, `.jpg`, `.jpeg`, `.webp`, …): base64-encode the bytes and embed as `<img src="data:image/<type>;base64,…">`.
   - For `.svg` assets: inline the SVG markup directly, or embed as `data:image/svg+xml;base64,…`.
   - **Why a `data:` URI and not a file path:** the mockup runs in an `sandbox=""` iframe with no same-origin access, so `<img src="../user_files/logo.png">` can't resolve a local project path, and the user's file isn't published at any URL to fetch. A `data:` URI is *inline content* the sandbox renders directly. Do not hand-draw an SVG approximation of an asset the user actually provided.
2. **"I've added design assets but would like to discuss them with you."** — Read the manifest directly (the same data `GET /api/editor-design-uploads` serves as `{ uploads: [{ filename, description }] }`). Present them back as a **numbered list** (filename + description) and ask **which** they want to chat about. Discuss, then continue. If the manifest is **absent or empty**, say so plainly and offer to wait while the user uploads assets to the "Add design assets" panel.
3. **"I don't have any design assets."** — Skip embedding; derive the palette/type/mood from the *description* instead (per Step 2's design read), and continue.

Read the uploaded-asset list straight from `.codeyam/design/user_files/manifest.json` (it may not exist yet). Do not invent assets the user hasn't provided.

**Decide whether the product shows real photographs — this drives imagery in Step 3, and respecting the user's wishes here matters.** Read the brief for photographic *content*: a catalog or marketplace, listings, profiles / avatars, recipes, travel — anything whose entries carry a real photo (this brief literally says each drink has "a preview photo from the drink company's website"). Three cases:

- **The brief asks for real photos, or it's obvious the product has them** → real photos are *required content*. Every mockup represents them (Step 3) — honor it; this is the user's wish.
- **The brief clearly has no photographic content** (a CLI, a pure-data dashboard, a text tool) → don't manufacture photos; inline / abstract imagery is right. Don't force images on a product that isn't asking for them.
- **Genuinely ambiguous** → **ask the user** whether the product shows real photos before generating. Don't guess.

Do not start writing any mockup HTML until the asset question is answered, the count is answered, the page is decided, **whether the product uses real photos is settled**, and any clarifying questions have responses.

## Step 2 — derive the design read, then plan the tier mix

**Read `frontend-design.md` now, if you haven't.** The design read below *is* the "compact token system" its process section asks you to brainstorm — same four axes, named slightly differently (its Color/Type/Layout/Principles ↔ the palette / type personality / archetype / tone + motif here). Derive it once, against its guidance, not from habit.

**Derive the design read once, up front.** Before picking anything, write yourself a short internal read from the description + assets:
- **Tone** — playful / clinical / editorial / technical / luxe / etc.
- **Palette** — concrete hexes pulled from the uploaded assets; if there are no assets, choose a palette that fits the brief.
- **Type personality** — geometric / humanist / serif / mono / hand-drawn.
- **Signature motif (optional, use sparingly)** — at most *one* recurring visual idea drawn from the brief (a "river" brief → flowing water; a "vault" brief → heavy metal edges). It is an **accent that ties the set together** — a backdrop, a divider, a hover detail — **not a layout and not an image subject.** Never stamp it as the thumbnail/photo of every card: that is exactly what collapsed the last set into near-variants. Different slots may express it differently, or not at all.

Every slot — anchored, exploratory, off-catalog — threads tone / palette / type through. The tier only changes *how much latitude* you take around it. The signature motif, if you use one, stays a light accent.

**Critique the read before you spend it — `frontend-design.md`'s second pass, run here.** Once the read is written, check it against that file's calibration list of generated-looking defaults (the cream-and-terracotta palette, the near-black-plus-acid-accent, the hairline broadsheet, the uniform rounded-card kit, the ALL-CAPS eyebrow / middle-dot / trailing-arrow chrome). Ask honestly: *would I have arrived at this read for almost any brief in this category?* If yes for any axis, revise that axis and say in one line what you changed and why. Do this **before** picking systems — a generic read poisons all N slots at once, and no amount of tier spread rescues it.

**Then read `taste-skill.md` and run its critique on the read too.** It is a second aesthetic pass, vendored from leonxlnx/taste-skill; its SCOPE NOTE says which sections bind a mockup (brief inference, the three dials, the typography / color / layout directives, the AI tells in its Section 9) and which do not (its React stack, icon libraries, GSAP motion, "ask one question"). Check the read against its Section 9 AI tells and its anti-default list the same way. Where it disagrees with `frontend-design.md`, `frontend-design.md` wins; where either disagrees with this file on what a mockup may contain, this file wins.

**How `frontend-design.md` binds, per tier.** It governs every slot, but the latitude differs, and the rule is its own: *where the brief pins down a visual direction, follow it exactly; where it leaves an axis free, don't spend that freedom on a default.*

- **Anchored** — the catalog system **is** the pinned direction. Where the system specifies something (its palette, its type scale, its radius and shadow discipline), the system wins, even if the result lands near a calibration-list trait — that is a deliberate, authored language, not a default you reached for. Everywhere the system is silent — copy, content, imagery choice, layout archetype, the accent drawn from the user's assets — `frontend-design.md` governs in full.
- **Exploratory** — you are already breaking the system's composition rules. Break them *toward* the brief, using `frontend-design.md` as the compass for where to push: the hero treatment, the type as an active element, the one place boldness gets spent.
- **Off-catalog** — no system, so `frontend-design.md` is the *only* floor. Its plan-then-critique pass, its typographic rules, and its calibration list are what keep the slot coherent instead of merely unusual.

Its writing section governs **all** copy in **all** tiers, with no exception: headlines, labels, empty states, button text. Real, product-true words (this file's "Real text content over Lorem ipsum" in Step 3 is the same rule, stated for mockups) written the way that section asks — plain, active, sentence case, named for what the user understands.

**Restraint is not optional at N > 2.** "Spend your boldness in one place" applies *per mockup*, not per set. The tier split and the variation engine buy range **across** slots; neither is a licence for each individual slot to be loud. An exploratory or off-catalog mockup still has one memorable element and quiet, disciplined surroundings.

### Step 2a — run the match test before allocating anything

**This step replaced a fixed tier table, and it is why sets stopped converging.** The old rule spent five of six slots applying a catalog system whether or not one suited the brief, so the agent always reached for the closest available language and every set came back as one design in several palettes. The catalog is now a **pool of candidates that must earn their slot**, and a brief that nothing fits gets a fully bespoke set. That is a legitimate, common outcome, not a failure to find something.

**The pool is both shelves.** `design_systems/` (20 languages authored for CodeYam, applicable) and `design_references/` (74 analyses of existing products, readable only). Their different permissions are in that folder's README and in the never-as-a-skin rule below.

**The match test, applied to a candidate.** A candidate matches only when you can answer all three in one line each, without straining:

1. **Structural fit** — does the brief's surface actually have the information shape this system is built for? A ledger system matches a product whose core screen is rows of figures. It does not match a product that merely *has* a table somewhere.
2. **Tonal fit** — does the system's mood match what the discovery answers or the brief asked for, and does it not collide with the anti-reference? An anti-reference beats any amount of structural fit. If the user said "not another dark developer tool," every dark developer tool in the pool fails the test, full stop.
3. **Nothing important has to be fought** — applying it faithfully must not require overriding its own rules to make the brief work. If it does, it is a springboard at best, not an anchor.

**Say why, out loud, one line per match.** An unjustified match is not a match. If you catch yourself writing "close enough," "the nearest fit," or "could work with adjustments," that candidate failed — write it down as a no and move on. This sentence is the whole mechanism; without it every candidate passes and the old behavior returns wearing new words.

**Then allocate from the number of genuine matches, `M`:**

| Genuine matches | Anchored | Exploratory | Off-catalog |
|---|---|---|---|
| `M = 0` | 0 | 0 | all N |
| `M = 1` | 1 | 1 | N − 2 |
| `M ≥ 2` | min(M, ⌊N/2⌋) | 1 or 2 | the rest |

**Anchored slots never exceed half the set.** A vague brief "matches" a lot of systems precisely because it constrains little, and without this cap such a brief reverts to the old convergent behavior. Half is the ceiling regardless of how many candidates passed.

**Two anchored slots never share a system, and never share a structural archetype** — card-grid · ranked list · table/ledger · feature-led · split master-detail · magazine column. Two anchored slots that share an archetype are the same mockup in two palettes, which is the original complaint.

**The three tiers:**

- **Anchored** — a `design_systems/` candidate that passed the match test, applied **faithfully** (its `## How to use this system` rules, minimum viable composition). Assets tune the brand and accent layer; the system keeps its structural identity. The safe, deliverable direction. **Only a catalog system may anchor a slot** — a reference never can, because anchoring means applying faithfully and that is exactly what a reference may not be used for.
- **Exploratory** — a candidate from **either** shelf, used as a springboard. Borrow component craft and structural ideas, then break its composition rules in service of the brief: re-lay out the page, push the type, let the brief's palette and mood reshape it. A reference used here is subject to the never-as-a-skin rule below.
- **Off-catalog** — composed bespoke from the design read: the brief, the discovery answers, the assets. The pool is available as *craft* vocabulary — how a system handles density, a type scale, a component's anatomy — never as a source of identity or layout. With the match test in place this is now the **default tier, not the exotic one**, and it is where the good work happens.

**Never applied as a skin — the rule that makes the reference library safe.** A `design_references/` document describes a real company's interface. Take technique from it; leave identity. Its palette, its typeface, its logo geometry, and its signature motif are not yours to reuse, and a slot that takes them produces a costume rather than a design. The practical test: **if someone who knows that product could name it from the mockup, the slot took identity — redo it.** Re-derive palette and type from the brief and the assets; the structure may survive, the identity may not.

**Then assign every slot a variation-engine combination — all of them, every tier.** Open `variation-engine.md` and give each slot its explicit row: theme paradigm, background character, typography character, composition, section system, three signature components, density, implied motion. **No two slots may share more than two axis values.** Do this as a table before writing any HTML; doing it afterward is doing it never. **Add taste-skill's three dials to each row** (`DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY`, 1 to 10): the anchored slot sits at variance 3 to 5, exploratory slots at 6 to 8, the off-catalog slot at 8 to 10; density follows the page (a dashboard or admin screen 6 to 8, a landing page 3 to 5); motion is implied only (the sandbox runs no scripts), so it shapes how the page *looks* ready to move and its CSS hover states, never a script. Different dials across slots are part of the spread. This is what guarantees spread *within* a fully bespoke set, where there are no tier differences left to do that work.

**After picking, skim the reference HTML** for each catalog system you anchored on or sprang from (per Inputs). References and off-catalog slots have no reference HTML — expected.

## Step 3 — declare the count, then generate N mockups across the tiers

**Resolve the control port FIRST — never hardcode 14199.** Every API call below (the tab-switch POST, the Step 3b lint GET, the Step 5 tab-switch, the Step 6 selection POST) must target the project's *live* editor control port, not a fixed `14199`. Resolve it once, before the first API call, and reuse it everywhere.

**Probe the candidates — never trust a recorded port without asking it.** No single file is right everywhere. On a laptop, `.codeyam/editor.json` `proxy.controlPort` is the stable per-project port (with the gitignored `.codeyam/editor.local.json` overriding it). On a cloud VM, one editor serves on `14199` whatever the per-project value says, so `editor.json` can name a port where nothing listens — and `.codeyam/server-state.json`, written by the running server, is then the only accurate record. So collect every candidate in that order and keep the **first one whose `GET /api/health` answers with JSON**. `/api/health` needs no session token, so the probe works on every bind. Use plain file reads and `curl` — do **not** call any `codeyam-editor editor …` command (forbidden during design):

```bash
# Candidates, in order: editor.local.json > editor.json > server-state.json > env > 14199.
CANDIDATES=$(python3 -c "import json,os
def get(p,*k):
    try:
        v=json.load(open(p))
    except Exception:
        return None
    for x in k:
        if not isinstance(v,dict): return None
        v=v.get(x)
    return v
for c in (get('.codeyam/editor.local.json','proxy','controlPort'),
          get('.codeyam/editor.json','proxy','controlPort'),
          get('.codeyam/server-state.json','controlPort'),
          os.environ.get('CODEYAM_CONTROL_PORT'), 14199):
    if c: print(c)" 2>/dev/null || echo 14199)
PORT=
for P in $(printf '%s\n' $CANDIDATES | awk '!seen[$0]++'); do
  case "$(curl -s -m 2 "http://localhost:$P/api/health")" in
    \{*) PORT=$P; break ;;
  esac
done
echo "control port: ${PORT:-none answered}"

# Session token: send it only when the file exists. A loopback bind does not
# enforce it and may not have one; an empty "Bearer " header helps no one.
AUTH=()
[ -f .codeyam/session-token ] && AUTH=(-H "Authorization: Bearer $(tr -d '[:space:]' < .codeyam/session-token)")
```

If no candidate answered, ask the user for the editor port — never guess. Use `http://localhost:$PORT` and `"${AUTH[@]}"` in **every** `curl` below. A `refused: missing or invalid session token` response means `AUTH` was not sent, not that the port is wrong. **A wrong port now announces itself:** an `/api/*` route that is not served returns `404` with a JSON body carrying `role` — `"launcher"` if you reached the cross-project selector, `"editor"` (plus `projectDir`) if you reached a *different* project's editor. Read `role` and re-resolve; if the port still does not answer as this project's editor, ask the user for it. An HTML body starting with `<!DOCTYPE`/`<html` from an `/api/*` call means you are talking to a build that predates that 404 — treat it exactly the same way. Never report success on a response you didn't confirm is JSON.

**Write the target manifest FIRST, before any HTML.** The UI uses this to render placeholder cards for every upcoming slot so the right pane fills in immediately. Write `.codeyam/design/project_mockups/target.json` with exactly:

```json
{"count": N}
```

(e.g. `{"count": 6}` for the default.) Write this before the first HTML mockup; the UI polls every few seconds and placeholders appear the moment it lands.

**The moment `target.json` is written, switch the preview to the Mockups tab.** Writing the manifest *is* the start of building, so move the user onto the Mockups tab to watch each card fill in. POST the tab-switch right after the manifest write, before the first HTML mockup:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-active-tab "${AUTH[@]}" \
  -H 'Content-Type: application/json' \
  -d '{"tab":"mockups"}'
```

This request is also what **opens the design view in the preview** when the design view isn't already showing, whatever surface launched you — a plain chat included. Use the `$PORT` and `AUTH` from Step 3's preamble. On `connection refused`, ask the user for the editor port — never guess. This is **best-effort UX**: if the POST fails, the user can still open the designs from the Plan tab, so do **not** block generation on it.

**Filenames — zero-padded numeric prefix sets display order.**

- Anchored / exploratory slots: `NN-<system>-mockup.html` — e.g. `01-keylime-mockup.html`. Replace `<system>` with the filename stem of the system you used (`keylime.md` → `keylime`, `letters-to-sean.md` → `letters-to-sean`).
- Off-catalog slots: `NN-offcatalog-mockup.html` — no backing system.

For `N = 2` you write `01-…` and `02-…`; for `N = 8` you go to `08-…`. Always two-digit zero-padded. Each mockup is a **single self-contained HTML file** — inline CSS, no external assets.

**Give every mockup a `<title>` that names its direction in plain words**, like "Evening, photo-led" or "Board with big cards" (under 40 characters, no system names, no "offcatalog"). The gallery shows the title as the design's name; without one the user sees the filename.

**Render every element as static HTML.** The `sandbox=""` iframe blocks *all* scripts, so any content you build with JS — a `.map()` over a data array, `innerHTML`, `document.createElement` — renders as a **blank card**. Write every card, row, and value out as literal markup. No `<script>` tag at all.

> **Off-catalog handoff:** the selection endpoint (Step 6) resolves `NN-<system>-mockup.html` back to `design_systems/<system>.md`. An off-catalog mockup has no backing markdown, so the endpoint synthesizes `.codeyam/design/design_system.md` from the mockup's own CSS custom properties instead. **Declare every color, font, radius and spacing value of an off-catalog mockup as a `:root` custom property** so that synthesized document carries the whole design.

**Every mockup, every tier: colors live in `:root` tokens, and a light design also ships its dark theme.** Write every color the page uses as a `:root` custom property and reference the tokens everywhere (no raw hex in component rules). For a light design, add a `:root[data-theme="dark"] { … }` block that redefines the same token names for dark: near-black surfaces in the design's own hue, near-white text, brand colors lifted until they read on dark, borders and tints re-derived. The gallery's Dark mode toggle sets `data-theme="dark"` on the page, so this block is what the user sees; without it the editor has to guess a dark theme from your light tokens, and raw hex values in rules never change at all. A design that is dark by nature needs no block.

**Subject stays constant; the design language and structure are the variables.** Every mockup depicts the same page so the user can directly compare directions. The same headline content, primary actions, data, and information hierarchy must be readable across all N — otherwise the comparison is meaningless.

**Every mockup must declare its surface in `<head>`:**

```html
<meta name="codeyam-viewport" content="desktop">   <!-- or: tablet | mobile -->
```

Use the surface Step 1 settled. This tag is not documentation — the editor **sizes the preview from it**, and `mobile` is what puts the phone shell around the mockup. A missing tag is treated as `desktop`, so a mobile round that omits it is presented as a 1440×900 desktop screen and every phone design in the round reads wrong.

**On a mobile round, compose for 390×844.** A desktop layout squeezed narrow is not a phone design:

- one column — no desktop sidebar, no wide horizontal nav bar;
- leave the top ~50px clear for the status bar;
- real tap targets, and a bottom tab bar where the product implies one;
- type and spacing scaled for a phone held in one hand, not a shrunk desktop page.

**Do not draw a phone bezel, notch, status-bar chrome, or home indicator inside the mockup HTML.** You write the *screen*; the editor draws the *device* around it. A mockup that draws its own renders inside a second one.

**Per-tier generation:**

- **Anchored** — obey the system's `## How to use this system` rules (minimum viable composition, not showcase patterns). Apply the derived palette only as the brand/accent layer; keep the system's structural identity intact.
- **Exploratory** — keep the system's components and token craft, but re-compose the page: a different layout, a stronger type treatment, the derived palette pushed further into the surface. It should be recognizably more distinctive than the anchored slot, while still feeling crafted.
- **Off-catalog** — design the page from scratch around the derived read. No system layout, no system identity — your own composition. Use the systems only as a quality bar for spacing, contrast, and component polish.

**Imagery is part of the design, not a polish step.** Empty boxes read as unfinished; mockups without imagery are not done. But *what kind* of imagery depends on what the slot represents — and the last round's mistake was treating every slot as an abstract gradient. There are two kinds:

**1. Decorative / abstract slots** — hero textures, section backgrounds, accent graphics, icons, charts. Inline SVG and CSS:
- **Inline SVG** — icons (single-path glyphs), simple charts (polyline / sparkline / bars), abstract accents. Style with the slot's tokens so it reads as part of the language.
- **CSS gradients and shapes** — hero banners, card backgrounds, texture.

**2. Representational slots — where the product shows a *photo of a real subject*** (a product shot, a dish, a face, a place — e.g. this brief's "preview photo from the drink company's website"). An abstract gradient here undersells the design *and* misreads the product.

**If Step 1 settled that the product uses real photos, every mockup must represent that photo content — it is brief-mandated, not a per-design style choice.** This is the lesson from the last run, where photos appeared in only the two "photo-forward" designs and the rest fell back to illustrations: that under-served the user's stated wish. **The design system controls the *presentation* — a large hero, a small thumbnail, a full-bleed crop, a circular avatar — never *whether* the photo appears.** The single exception is a *rare, radically-different* aesthetic where photography would genuinely break the concept (e.g. a pure terminal / ASCII surface); such a slot may abstract the photo, but you must **say so in the numbered key** so the omission reads as a deliberate choice, not an oversight. (If Step 1 settled the product has *no* photographic content, skip all of this and use inline/abstract imagery.)

Build each representational slot in **two layers**:

- **Always build the inline depiction first.** Compose an SVG/CSS illustration that *actually depicts the subject* with form, depth, and lighting — for a drink: a glass or bottle holding the liquid's real color, a label, a soft shadow, a backdrop; for a face: a real portrait silhouette with hair/skin tones, not a monogram circle. This is the offline-safe floor, and unlike generic stock it is *subject-accurate* — the actual named item, in its real color.
- **Then layer a real photo *on top* of the depiction — the hybrid.** Base64-encode the depiction SVG as a `data:` URI and stack a remote keyword photo above it in a single CSS background (never a bare `<img>` — that renders a broken icon on failure). **Declare it in a `<style>` rule, one class per card** — each card has its own photo + depiction, so a shared class won't do:
  ```html
  <style>
    .photo-1 {
      background-image:
        url('https://loremflickr.com/640/480/earl,grey,tea'),    /* real photo — top layer */
        url('data:image/svg+xml;base64,<the inline depiction>'); /* subject-accurate fallback — beneath */
      background-size: cover;
      background-position: center;
    }
  </style>
  …
  <div class="photo photo-1"></div>
  ```
  - **Quoting — get this wrong and the whole image silently vanishes.** Inside `url(...)` always use **single quotes**: `url('…')`. The trap from the last run: the layered background was written *inline* as `style="background-image:url("…")"` — the double quotes inside collided with the attribute's double quotes, the browser cut the value off at the first inner `"`, and **the entire background (photo *and* fallback) disappeared** — a blank box with no image and no placeholder, across every card. So: declare backgrounds in a `<style>` rule (preferred); if you ever inline one, the inner `url()` quotes **must** be single. Never put a double-quoted `url("…")` inside a double-quoted `style="…"`.

  A background layer that fails to load is simply transparent (no broken-image icon), so the layer beneath shows through on its own: **online → the real photograph; offline or dead URL → the matched depiction; never → a broken card.** Build the remote URL from the *specific item's* keywords (drink name + type) so the photo is as on-subject as the source allows.
  - **Source:** `loremflickr.com/<w>/<h>/<comma,keywords>` serves keyword-matched photos with no API key — best-effort, not guaranteed subject-exact, which is exactly why the depiction sits beneath it. Don't use sources that need a key or are deprecated (`source.unsplash.com` no longer works keyless).
  - **Scope:** representational *content* slots only — never decoration, fonts, or scripts. Weigh the privacy note in *What NOT to do* (a remote fetch leaks the viewer's IP to the host).

**Vary imagery across the set.** Different slots must not all reuse the same placeholder treatment — uniform thumbnails are part of what collapsed the last anchored trio. The signature motif (Step 2) is a light accent, never every card's image.

**Real text content over `Lorem ipsum`** — names, headlines, list items, table rows that look like the actual product (a drink app → "Earl Grey Cold Brew", a believable company, a realistic rating). Believable text plus subject-true imagery is what makes a mockup read as a real screen — not a polish step you skip.

**User-provided assets are not placeholders — embed them, don't approximate them.** The inline-SVG / CSS-gradient guidance above is for slots where the user gave you *nothing*. When the user **did** provide a brand asset (logo, wordmark, product screenshot) in `.codeyam/design/user_files/`:

- **It appears verbatim in *every* mockup.** A logo is brand identity, constant across all N. Embed the real asset as a base64 `data:` URI (or inline SVG markup for `.svg`) per Step 1 — never substitute a hand-drawn stand-in for an asset the user actually uploaded. Hand-drawn SVG logos are only acceptable when the user provided **no** logo at all.
- **Preserve the asset's intrinsic aspect ratio.** Set one dimension and leave the other `auto` (e.g. `height: 40px; width: auto`), or use `object-fit: contain` inside a fixed box. **Never** force a `width`/`height` pair that differs from the source's native ratio — that stretches a square logo into a wide box.
- **Invented placeholders still fill the slots the user did not supply.** Avatars, hero imagery, charts, thumbnails with no uploaded asset keep using inline-SVG / CSS placeholders. Only the slots the user gave a real asset for get the verbatim-embed treatment.

(Note that *embedding* the asset and *deriving tokens from* it are separate jobs — Step 2's design read pulls the palette/type/mood out of the asset so it reshapes the whole mockup, not just the spot where the logo sits.)

**Typography — embed the bundled inline face; the fallback remains the floor.** For each picked design system, locate its prebuilt base64 font block under `.codeyam/design/design_systems/<system>.fonts.css` (systems that intentionally use only standard system fonts will not have a file). **Inline that entire `.fonts.css` stylesheet into the mockup's `<style>` tag.** Set the `font-family` using the branded face, and always pair it with its system fallback — e.g. `font-family: 'Manrope', sans-serif;` (or `Georgia, serif` / `'JetBrains Mono', monospace` to match the system's personality). This guarantees full typographic fidelity offline with no network requests and zero IP leaks. **Never** load remote fonts via `@import url(https://fonts.googleapis.com/…)`, `<link href="https://…">`, or any other remote URL — the mockup linter will flag it immediately.

**Atomic writes only.** Write the full file in one step (e.g. the `Write` tool); never streaming opens. The UI polls the directory every few seconds and a half-written file renders as a broken card.

### Step 3b — self-correct against the linter before handoff

The editor backend lints every mockup and exposes the findings on the same API you already curl. **These warnings are for you, the generator — not the user; the user sees no lint badge.** Before posting the numbered key (Step 4), close the loop:

1. After all N files exist, read the lint findings:
   ```bash
   curl "${AUTH[@]}" http://localhost:$PORT/api/editor-mockups
   ```
   The response is a JSON array; each entry carries a `warnings[]` of `{code, message, severity}`. Resolve the control port once (see Step 3's preamble); it is a dynamic per-project port under the launcher, not necessarily `14199`. **Validate the response shape, not just the status code:** if the body is **not** a JSON array — e.g. it starts with `<!DOCTYPE`/`<html` (the launcher selector's SPA shell, returned with HTTP 200) — the resolved port is wrong. Re-run the resolution; if it still returns HTML, ask the user for the editor port and retry. Keep the local-grep fallback below only for a genuine `connection refused`, never for an HTML 200 — a wrong-server 200 must never be mistaken for "no warnings".
2. For **every** card with a non-empty `warnings[]`, apply the fix its `message` describes and rewrite that HTML file. The `message` is the remediation guide — e.g. *"Use single quotes inside the url() …"* (the quote-collision trap above), *"Render the content statically."* (a stray `<script>` / JS-built content), an empty media box, a remote asset, or a remote font (resolve it with the **Typography** rule: the system's `font-family` + system-font fallback, never a remote load).
3. Re-`curl` and repeat until every card's `warnings[]` is empty, **capped at ~3 passes** so a stubborn finding can't loop forever.
4. Anything still flagged after the cap is **named in the Step 4 numbered key as a plain-language advisory** (e.g. *"3: off-catalog — note: the hero photo loads from a remote source"*) — never left as a silent residual, and never surfaced as a cryptic badge.

**If the API is unreachable** (`connection refused` and the user can't give a port), fall back to a local grep of each file for the highest-signal violations before handoff — `fonts.googleapis.com`, `@import url(http`, `<script`, `<img src="http` — and fix what it finds with the same rules. The API loop is preferred; the grep is the belt-and-suspenders floor.

**Between the two, run the checkable floor.** Open `web-interface-guidelines.md` and apply the rules its scope note marks as binding on a mockup. They are the small, mechanical things that separate a mockup from a real product screen and that no linter here catches: `…` instead of `...`, curly quotes, non-breaking spaces in `10 MB` and `⌘ K`, `tabular-nums` on any column of figures, `text-wrap: balance` on headings, explicit `width`/`height` on images, `alt` text, real `<button>`/`<a>` elements, visible focus styling, `color-scheme` on a dark design, `env(safe-area-inset-*)` on a full-bleed mobile layout, `prefers-reduced-motion` honored. Ignore the sections its scope note marks as build-time — chasing those is how a mockup grows a `<script>` tag it must not have.

**Then run `taste-skill.md`'s Section 14 pre-flight on each mockup,** only the boxes a static screenshot can show (theme lock, one accent, one radius system, CTA and form contrast, hero discipline, eyebrow count, section-layout repetition, no fake screenshots or decorative filler, copy self-audit, zero em-dashes in visible text). Skip every box about JavaScript motion, GSAP, the React stack or package installs. A failed box is fixed before handoff, like a lint finding.

**The linter is mechanical; the self-critique is not — run both.** The lint pass catches broken markup, remote assets, and blank media boxes. It cannot see a generic design. So in the same loop, re-read each finished mockup against `frontend-design.md`'s restraint section: is there one memorable element, or five competing ones? Did any calibration-list trait creep back in while you were writing CSS — a tracked-out ALL-CAPS label, a `01 / 02 / 03` numbering over content that isn't a sequence, a `→` glued to a button, the same soft grey shadow under every card? Remove one accessory per mockup. Fix what you find before Step 4; you don't need the user's permission to improve your own draft.

## Step 4 — post the numbered key in the chat, labeled by tier

After all N files exist, post a short key naming each numbered mockup **and its tier**, so divergence reads as intentional range rather than a glitch:

```
1: keylime — anchored · playful pastel SaaS dashboard (safe, on-brief)
2: coder — exploratory · terminal-styled, re-laid-out command surface
3: off-catalog — bespoke editorial layout built from your brand palette
…
```

End with: *"Tell me which to iterate (by number) or say 'let's use N' to lock one in. The bolder ones are idea-generators too — if you like one element from a wild mockup, say so and I'll fold it into a safer direction."*

The preview is already on the Mockups tab (it switched at the start of Step 3), so Step 4's only job is the numbered key. No tab-switch needed here.

## Step 5 — iterate when asked

When the UI dispatches an Iterate trigger (an `Iterate:` keyword followed by a fenced JSON feedback bundle, or the no-feedback variant), **do not regenerate anything immediately**. First post a short message asking the user what should happen to each design in the next round. There are four choices per design:

- **Keep** — carry it into the next round untouched. Do not edit the file.
- **Iterate** — refine it in place with its notes applied, same `NN-` prefix and tier.
- **Multiple versions** (2–4) — make that many distinct variations of its direction. The first reuses the design's own `NN-` prefix; the rest take the next free numbers. Never overwrite a slot the user kept.
- **Replace** — redesign that slot fresh from the feedback (the redesign rules below).

**Wait for the user's reply before writing any mockup.** This is also where **cross-pollination** happens: if the user says "I like #5's layout but #2's palette," carry that explicitly into the refined slot.

**An Iterate trigger is never a selection.** The user has not picked a design: ratings, notes and the Iterate button all mean "make another round". Do not POST `/api/editor-design-select`, and do not tell them they chose, picked or locked in a design, not even the top-rated one. In your question, name each design by its number and plain name and suggest a choice for each (usually Keep or Iterate for the best-rated), so they can answer in a few words.

**End that question with your suggestion as a fenced `design-plan` block.** The chat reads it to pre-fill a per-design decision card and hides it from the user, so it must be the last thing in the message, valid JSON, keyed by mockup filename, one verb (`keep`, `iterate`, `versions`, `replace`) per design:

````
```design-plan
{"01-keylime-mockup.html":"keep","02-paper-mockup.html":"iterate","03-offcatalog-mockup.html":"replace"}
```
````

Designs left out of the block start on Replace, so include every design.

**The user's reply may be a decision message** — it starts with `Design plan:`, lists one line per design, may carry `My note: …` with their own words, and ends with a `design-plan` block of `{"verb": …, "count": N}` per filename. Follow that JSON exactly: it is the user's choice for every design, and `count` is the number of versions. Their note still counts as feedback. A free-text reply works as before — read the choices out of it.

Once the user answers, **switch the preview to the Mockups tab as the regeneration round begins** — before writing the first refreshed/placeholder card:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-active-tab "${AUTH[@]}" \
  -H 'Content-Type: application/json' \
  -d '{"tab":"mockups"}'
```

Best-effort, same caveats as Step 3 (resolve `$PORT` per Step 3's preamble — a dynamic per-project port, not necessarily `14199`; on `connection refused`, ask for the port — never guess; don't block on it). Then proceed:

- **Keep:** leave the file exactly as it is.
- **Iterate:** refine it in place using its specific feedback, keeping the same numeric prefix and tier.
- **Multiple versions:** write N variations of that design's direction — each visibly different (layout, type treatment or palette emphasis), all resolving its notes. Slot 1 reuses its prefix; the others take the next free `NN-` numbers after the highest existing one.
- **Replace:** redesign it fresh from the feedback. A slot keeps its tier unless the feedback implies moving it safer (toward anchored) or bolder (toward exploratory / off-catalog) — honor that drift when the feedback signals it.

**Honor the feedback explicitly — it is non-negotiable signal.** Every card's comment is a concrete instruction and its rating is a strength signal. The refined or redesigned mockup must visibly resolve what the comment called out (e.g. "headline feels weak" → lead with a stronger headline treatment). A low rating means change direction further; a pointed comment means fix that exact thing. This applies to every design you change — iterated, versioned or replaced. Only a Keep is left alone.

**Write the feedback checklist first, then check every new file against it.** Rounds have come back with a note ignored ("I don't like the grid background" and the grid was still there), so this is a procedure, not a suggestion:

1. **Before editing any file, and again after the user answers what to do with each design, re-read the feedback** (the Iterate message lists it design by design, and names the archived `feedback.json` when there is one). Notes are in the user's own words and may be in any language.
2. **Write the checklist in your working notes:** one line per design that has a note: the note, then the concrete change in the markup or CSS that resolves it. "No me gusta el fondo cuadriculado" becomes "remove the grid pattern from the page and every section background; use a plain surface or a different texture".
3. **Iterated designs get their notes applied too.** Iterating on a design keeps its direction, never the thing its note rejected. (A design the user chose to **Keep** is the one exception: it stays untouched.) A redesign that starts from the old file inherits everything the note complained about, so strip that element on purpose.
4. **A rating with no note is still signal:** 1 or 2 stars (rating 20 or 40) means change direction clearly (layout, palette and type), not a variation; 4 or 5 stars means keep what works and change little besides the notes.
5. **After writing each file, re-open it and check every checklist line against the actual code.** For a rejected visual, search the CSS for every way it can be drawn (for a grid: `repeating-linear-gradient`, `linear-gradient` with a small `background-size`, SVG `<pattern>`, a `grid`/`dots`/`paper` class on a background). Anything still there is fixed before you move to the next design.
6. **The closing message says, per design, what changed for each note**, in plain words: "#3: took out the grid background, it's a soft paper texture now."

For **fresh redesign slots**, weigh the rating and comment to decide whether to keep the slot's current tier+system with a new layout, or switch tiers / pick a **different** system — avoid duplicating a system already used by a kept or iterated card.

**Slot/file hygiene when swapping systems or tiers.** The numeric prefix (`NN-`) must stay so the card holds its slot, but the stem changes when the system changes (or becomes `offcatalog`). When you change a slot's system or tier, **delete the old `NN-*.html` before writing the new one** — the UI matches a slot by `NN-` prefix and would show two cards for one slot if both files exist.

Keep all guidance about placeholder imagery, inline-only assets, and atomic writes — these apply to tweaked and redesigned mockups alike. After regenerating, post a short note saying, per design, what was done under its choice (kept, iterated, N versions as #x–#y, replaced), referencing the specific feedback it addressed. The preview is already on the Mockups tab, so no further tab-switch here.

## Step 5b: tweak when asked

A message that starts with `Tweak:` comes from the Plan tab's "Tweak these designs" button while the designs are open in the preview. It is a conversational change to the designs already on screen, not a new round. It ends with a note naming the round, each design by the number shown on its card, the selected design, and the directory the files live in.

- **Resolve every reference against that note.** "The second one", "the slate one", "the selected one" each map to a real file. If a reference is genuinely ambiguous, ask one short question before writing anything.
- **Change only what the request names, in place.** Keep each edited file's `NN-` prefix and tier. Leave every other design untouched: do not discard or regenerate them, and do not ask which to keep. That question belongs to the `Iterate:` flow above, not this one.
- **A request that applies to no design in particular** ("make the accent warmer") applies to every design in the round.
- **A request that combines designs** ("the first one's layout with the third's palette") edits the design it names as the base. If it names none, ask which one to change.
- **An empty request** means the user has not said what to change yet. Ask, and wait.
- Switch the preview to the Mockups tab with the same `editor-design-active-tab` POST as Step 5 before writing, and keep the atomic-write, inline-asset, and lint rules.
- Afterwards, reply with one line per changed design naming what changed, then invite the next tweak. **A tweak never locks a design in.** Selection stays with Step 6.

## Step 6 — handle the selection

Only the user's own words naming the design to build with count as a pick; a rating, a note or an `Iterate:` message never does (Step 5). When the user picks a direction with a phrase like *"Let's use 4"*, *"I want 4"*, or *"pick 4"*, POST the corresponding filename to the editor backend with `curl`:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-select "${AUTH[@]}" \
  -H 'Content-Type: application/json' \
  -d '{"filename":"04-<system>-mockup.html"}'
```

Use the **exact filename** you wrote in Step 3, including the `0N-` prefix. For anchored / exploratory picks, the endpoint copies the matching system markdown into `.codeyam/design/design_system.md`; you do **not** touch that file yourself.

**If the user picks an `offcatalog` mockup:** POST it like any other. The endpoint synthesizes `design_system.md` from the mockup's own tokens (see the Step 3 handoff note); do not fall back to a stock system that doesn't match what they picked.

Resolve the control port once (see Step 3's preamble); it is a dynamic per-project port under the launcher, not necessarily `14199`. If curl returns `connection refused`, ask for the editor port and retry — never guess.

**Never report "locked in" on a bare HTTP 200 — verify the side-effect.** A `200` from the launcher selector is a phantom success: it returns the SPA shell and copies nothing, so the design→build handoff is silently lost. After the POST returns, confirm the on-disk result before telling the user anything took:

- **Anchored / exploratory picks:** read back `.codeyam/design/design_system.md` and confirm it now exists and contains the chosen system's content. Only then surface the one-line "locked in" confirmation. If the file is absent (the phantom-success case), tell the user honestly that the selection did **not** take, re-resolve the port (it was likely the launcher selector), and retry — do not report success.
- **Off-catalog picks:** read back `.codeyam/design/design_system.md` the same way; it is the synthesized token document and names the chosen mockup as its source.

If it fails, surface the error and let the user pick again.

## What NOT to do

- **No scaffolding** — do not run `codeyam-editor editor template`, `npm install`, `git init`, or any setup command. The project hasn't decided its tech stack yet.
- **No editing `.codeyam/design/design_system.md`** — that's the API's job after the selection POST.
- **No remote fonts or scripts; remote *content photos* only with a fallback.** Never load remote fonts or `<script>` — the `sandbox=""` iframe blocks scripts outright, and a remote font that fails renders inconsistently. Remote *images*, though, the sandbox *does* load: inline is the default for **robustness** (offline / flaky environments) and **privacy** (a remote fetch leaks the viewer's IP to the host), not because the network is blocked. So — decorative imagery stays inline, and a **representational content-photo slot may use a remote image only when stacked on top of the inline depiction as its fallback layer** (the hybrid in Step 3); no bare remote `<img>` that can render as a broken icon. **User-uploaded `.codeyam/design/user_files/` assets** embedded as base64 `data:` URIs (or inline SVG) are inline content and are **required** when provided (Step 1, Step 3).
- **No iframe-busting markup** — avoid `<meta http-equiv="refresh">`, `window.parent` access, or anything that breaks the sandbox.
- **No homogenized set** — never return N near-variants of a single direction. The Step 2a allocation and the variation-engine rows exist to guarantee range; if two mockups read as the same direction, you've failed the comparison.
- **No applying a system that failed the match test** — not as "the closest one," not "with adjustments." A brief that nothing fits gets a fully bespoke set, and that is the correct outcome, not a shortfall. Reaching for the nearest system anyway is the exact behavior the match test replaced.
- **A reference is never applied as a skin** — if someone who knows the referenced product could name it from the mockup, the slot took identity instead of technique. Redo it.
- **No slot without a variation-engine row** — a set whose slots were each designed by asking "what would look good here?" converges, because that question has one best answer. Assign the combinations before writing HTML, not after.
- **No skipping `frontend-design.md`** — reading it is Step 2's precondition, not optional background. A set generated without it is the specific failure this skill keeps relearning: mechanically correct mockups that all read as generated. Where a catalog system speaks, the system wins; everywhere else, that file does.
