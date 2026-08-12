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

This skill has two modes. Everything above and below assumes **questionnaire mode** (project does not exist yet). When a **design round** is active — the file `.codeyam/design/rounds/.active` exists, naming a round id — you are in **round mode**, running against an app that already exists, and the following overrides apply. Everything else in this skill (the design read, the tier table, imagery/typography rules, atomic writes, the Step 3b lint self-correction loop) is reused verbatim.

- **Active round + directory.** Read the active round id from `.codeyam/design/rounds/.active`; the round directory is `.codeyam/design/rounds/<round-id>/`. It already holds `current-state.md`, written by the grounding step.
- **`current-state.md` is a primary input, alongside `projectDescription`.** It describes the surface being modified as it looks TODAY — the scenarios that render it, their data states, and what this round is trying to change. Read it before deriving the design read; the mockups are **variations on that real screen**, not a fresh invention.
- **The existing `.codeyam/design/design_system.md` (if any) is the anchored tier's reference** instead of a freshly-chosen catalog system.
- **Step 1 changes.** "Which page to mock up" is already answered by grounding — **do NOT re-ask it.** The count question (2/4/6/8, default 6) and the assets question stay.
- **Tier semantics gain the existing-app reading.** The **anchored** tier means "the app as it looks today, with the requested change applied" — the safe, minimally-disruptive direction — not a fresh catalog system. Exploratory and off-catalog keep their meaning. The 2/4/6/8 → anchored/exploratory/off-catalog allocation table is reused unchanged.
- **The `codeyam-editor` command prohibition is LIFTED in round mode.** The project exists and you legitimately need `codeyam-editor editor plan-show`, `... scenarios`, and the capture commands to ground and iterate. (The prohibition stays in questionnaire mode.)
- **Output paths are round-relative.** `target.json` and every `NN-*-mockup.html` go in the round directory, NEVER `.codeyam/design/project_mockups/`. The mockup/tab/lint API calls take a `?round=<round-id>` scope; the project-wide directory is left untouched.
- **Selection is handled by the WORKFLOW, not the Step 6 POST.** In round mode do NOT POST `/api/editor-design-select`. The user's pick is recorded by the design workflow's iterate/apply steps (`codeyam-editor editor branch-outcome design-iterate use` then `... design-round --select <mockup>`), which synthesizes an off-catalog token document automatically — closing the handoff gap the questionnaire flow leaves open. Your job in round mode ends at generating and iterating on the mockups; the workflow carries the selection.

**The brief drives; the systems are a floor, not a ceiling.** The user's product description and any uploaded design assets are the primary signal — every mockup must feel like *their* product, not a stock template. The curated design systems in `.codeyam/design/design_systems/` are a quality floor: a vocabulary of robust, internally-consistent languages you can adhere to, stretch, or set aside depending on a mockup's *tier* (Step 2). Your goal across a set is **genuine range** — diverse directions — anchored by at least one safe, on-brief option, and (when the set is large enough) reaching all the way to a fully bespoke, off-catalog direction.

## Inputs

- **Project description** — read it from `.codeyam/editor.json`, key `projectDescription`. If the file or the key is missing, ask the user briefly to describe the product before continuing.
- **Design assets (if any)** — uploaded files live in `.codeyam/design/user_files/`, with a manifest at `.codeyam/design/user_files/manifest.json` listing `{ filename, description }`. **Do not just read the filenames — actually open and *look at* each visual asset.** A logo, screenshot, or brand reference carries a palette, a type personality, and a mood. View the image, extract its dominant colors (as hex), note its type feel (geometric / humanist / serif / mono / hand-drawn) and overall mood, and let those **shape the tokens** of your mockups — not merely sit embedded as decoration. (Rules for *embedding the asset itself* are in Step 3; this bullet is about *deriving design signal* from it.)
- **Design systems** — every `.md` file in `.codeyam/design/design_systems/` (skip `README.md`). Each is a self-contained design language with sections like `## How to use this system`, `## Foundations`, `## Components`. Read the systems you pick carefully; *how closely you obey them depends on the tier.*
- **Reference example mockups (some systems only)** — `<system>-example-<surface>.html` files (`dashboard`, `landing`, `mobile`) are pre-built reference screens showing how a system renders in practice. They are NOT runtime project mockups (those use `NN-<...>-mockup.html` naming). When you anchor on or springboard off a system in Step 2, **open every matching `<system>-example-*.html` and skim the one closest to your page** — it locks in spacing, type weights, and color application the markdown underspecifies. Systems without example files still work; lean on the markdown.

## Step 1 — greet the user and gather inputs before generating anything

**First message — introduce yourself and the flow.** Open with a short, warm greeting that explains exactly what's about to happen so the user is oriented before answering. One short paragraph — friendly, not corporate. Use your own words, but the gist must be along the lines of:

> "Hi! I'm here to help with your design exploration. I'll generate a few mockups of one page of your product — some playing it safe and on-brief, some pushing in bolder directions — so you can compare directions side-by-side and pick the one that fits. Before I start, I have a couple of quick questions."

Then in the same message (or the next — your call), do all of the following, batched together so the user isn't ping-ponged:

**Read the project description first.** Open `.codeyam/editor.json` and read `projectDescription`. Note anything you genuinely don't understand: surface type (mobile / web / desktop), primary user (consumer / professional / internal), the one or two screens that matter most, the tone (playful / serious / clinical / editorial).

**Ask any clarifying questions you actually need answered.** Good ones: *"Is this primarily mobile or desktop?"*, *"Who's the main user — a power user or a first-timer?"*, *"Should the tone read more polished-startup or playful-indie?"*. Only ask what you cannot reasonably infer. If the description already covers it, skip it.

**Ask which page to mock up — but only if it isn't obvious.** All N mockups depict **the same page of the product** in different directions — that is the whole point of the comparison. If the description makes the primary working surface obvious (a SaaS → its dashboard, a creative tool → its editor, a social app → its feed, a landing-focused product → the home / hero), pick it yourself and **tell the user in one sentence which page you chose**. Only ask if the product genuinely has multiple equally-central surfaces — and when you ask, suggest 2–3 candidate pages.

**Ask how many mockups to generate.** Offer **2, 4, 6, or 8**, with **6 as the default** — say "I'll generate 6 mockups unless you'd like more or fewer (2 / 4 / 6 / 8 available)." Wait for their pick (or confirmation of the default). Call this number `N`. If the user replies with anything outside `{2, 4, 6, 8}`, clamp to the nearest allowed value and tell them what you're using. **N also decides how bold the set gets** — more mockups means more slots spent on exploratory and off-catalog directions (see the Step 2 table).

**Ask about design assets — present exactly these three options.** Before writing any mockup HTML, ask whether the user has design assets to fold in, and offer these three choices verbatim:

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

**Derive the design read once, up front.** Before picking anything, write yourself a short internal read from the description + assets:
- **Tone** — playful / clinical / editorial / technical / luxe / etc.
- **Palette** — concrete hexes pulled from the uploaded assets; if there are no assets, choose a palette that fits the brief.
- **Type personality** — geometric / humanist / serif / mono / hand-drawn.
- **Signature motif (optional, use sparingly)** — at most *one* recurring visual idea drawn from the brief (a "river" brief → flowing water; a "vault" brief → heavy metal edges). It is an **accent that ties the set together** — a backdrop, a divider, a hover detail — **not a layout and not an image subject.** Never stamp it as the thumbnail/photo of every card: that is exactly what collapsed the last set into near-variants. Different slots may express it differently, or not at all.

Every slot — anchored, exploratory, off-catalog — threads tone / palette / type through. The tier only changes *how much latitude* you take around it. The signature motif, if you use one, stays a light accent.

**Compute the tier allocation from N.** The set must span from safe-and-on-brief to boldly distinctive. Allocate the N slots across three tiers:

| N | Anchored | Exploratory | Off-catalog |
|---|----------|-------------|-------------|
| 2 | 1        | 1           | 0           |
| 4 | 2        | 1           | 1           |
| 6 | 3        | 2           | 1           |
| 8 | 3        | 3           | 2           |

(You clamped a non-table N to `{2,4,6,8}` in Step 1, so one row always applies.)

**The three tiers:**

- **Anchored** — pick a curated system that genuinely *fits the brief* and apply it **faithfully** (its `## How to use this system` rules, minimum viable composition). The assets tune the brand/accent layer (e.g. the logo's color becomes the accent), but the system keeps its structural identity. This is the safe, deliverable direction. Even at `N = 2`, the single anchored slot must read clearly differently from the exploratory one — diversity is required from the very first pair.
- **Exploratory** — pick a system as a **springboard**. Borrow its component craft and tokens, but break its composition rules in service of the brief: re-lay-out the page, push the type, let the assets' palette and mood reshape it more aggressively. Diverges hard while keeping a quality floor.
- **Off-catalog** — use **no** catalog system. Compose the page bespoke, directly from the brief and the derived palette/type/mood. The systems are only a *quality reference* for craft (spacing discipline, component polish, contrast) — never a source of layout or identity. This is the most distinctive tier, and it has the thinnest floor: lean on your design read to keep it coherent.

**Pick the systems for the anchored and exploratory slots.** Across those slots choose **different** systems — no repeats — and spread them so the set reads as real range, not near-variants. Anchored picks lean toward the brief's tone; exploratory picks can reach further. Off-catalog slots have no system. Keep reasoning brief — one line per slot.

**Each anchored slot takes a different structural *archetype* — not just a different skin.** This is where the last round failed: three anchored mockups all became the same card-grid with the same thumbnail, varying only in color. *On-brief does not mean one layout.* Before generating, assign each anchored slot a **distinct layout archetype** and hold to it — e.g. card-grid · ranked list / leaderboard · table / ledger · feature-led (one hero item + supporting) · split master-detail · magazine-editorial column. **Two anchored slots may never share an archetype.** When the brief names an obvious layout ("a card for each item"), that is *one* anchored slot's archetype — the others must find a different, still-on-brief way to present the same content. If you can't honestly find enough distinct archetypes for the anchored count, spend the surplus slot on an exploratory direction instead and say so.

**After picking, skim the reference HTML** for each system you anchored on or sprang from (per Inputs). Off-catalog slots have no reference HTML — expected.

## Step 3 — declare the count, then generate N mockups across the tiers

**Resolve the control port FIRST — never hardcode 14199.** Every API call below (the tab-switch POST, the Step 3b lint GET, the Step 5 tab-switch, the Step 6 selection POST) must target the project's *live* editor control port, not a fixed `14199`. Under the Project Launcher the questionnaire's editor runs on a **launcher-allocated dynamic port** recorded in `.codeyam/server-state.json`; `14199` is the launcher's *selector* SPA, which returns the SPA shell (**HTTP 200 + HTML**) for any `/api/*` route — so a call aimed there silently no-ops or reports a phantom success. Resolve the port once, before the first API call, and reuse it everywhere. Mirror the precedence the rest of the editor uses (`server-state.json` `controlPort` → `CODEYAM_CONTROL_PORT` env → `14199` default) with a plain file read — do **not** call any `codeyam-editor editor …` command (forbidden during design):

```bash
# Resolve the live editor control port — NOT a hardcoded 14199.
PORT=$(python3 -c "import json,os; \
print(json.load(open('.codeyam/server-state.json')).get('controlPort') \
or os.environ.get('CODEYAM_CONTROL_PORT') or 14199)" 2>/dev/null || echo 14199)
```

Use `http://localhost:$PORT` in every `curl` below. If any design-API response comes back as the SPA shell (an HTML body starting with `<!DOCTYPE`/`<html` instead of the expected JSON), the resolved port is pointing at the launcher selector — re-resolve, and if it still returns HTML, ask the user for the editor port. Never report success on a response you didn't confirm is JSON.

**Write the target manifest FIRST, before any HTML.** The UI uses this to render placeholder cards for every upcoming slot so the right pane fills in immediately. Write `.codeyam/design/project_mockups/target.json` with exactly:

```json
{"count": N}
```

(e.g. `{"count": 6}` for the default.) Write this before the first HTML mockup; the UI polls every few seconds and placeholders appear the moment it lands.

**The moment `target.json` is written, switch the preview to the Mockups tab.** Writing the manifest *is* the start of building, so move the user onto the Mockups tab to watch each card fill in. POST the tab-switch right after the manifest write, before the first HTML mockup:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-active-tab \
  -H 'Content-Type: application/json' \
  -d '{"tab":"mockups"}'
```

Resolve the control port once (see Step 3's preamble); it is a dynamic per-project port under the launcher, not necessarily `14199`. On `connection refused`, ask the user for the editor port — never guess. This is **best-effort UX**: if the POST fails, the user can still click the Mockups tab manually, so do **not** block generation on it.

**Filenames — zero-padded numeric prefix sets display order.**

- Anchored / exploratory slots: `NN-<system>-mockup.html` — e.g. `01-keylime-mockup.html`. Replace `<system>` with the filename stem of the system you used (`keylime.md` → `keylime`, `letters-to-sean.md` → `letters-to-sean`).
- Off-catalog slots: `NN-offcatalog-mockup.html` — no backing system.

For `N = 2` you write `01-…` and `02-…`; for `N = 8` you go to `08-…`. Always two-digit zero-padded. Each mockup is a **single self-contained HTML file** — inline CSS, no external assets.

**Render every element as static HTML.** The `sandbox=""` iframe blocks *all* scripts, so any content you build with JS — a `.map()` over a data array, `innerHTML`, `document.createElement` — renders as a **blank card**. Write every card, row, and value out as literal markup. No `<script>` tag at all.

> **Known handoff gap (off-catalog):** the selection endpoint (Step 6) resolves `NN-<system>-mockup.html` back to `design_systems/<system>.md`. An off-catalog mockup has no backing markdown, so selecting it cannot yet copy a design system into `.codeyam/design/design_system.md`. This is a deliberate prototype limitation — the build-handoff for off-catalog (synthesizing `design_system.md` from the chosen mockup's actual tokens) is backend work tracked for the formal build session. Generate off-catalog mockups for *visual exploration*; flag this gap if the user picks one.

**Subject stays constant; the design language and structure are the variables.** Every mockup depicts the same page so the user can directly compare directions. The same headline content, primary actions, data, and information hierarchy must be readable across all N — otherwise the comparison is meaningless.

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
   curl http://localhost:$PORT/api/editor-mockups
   ```
   The response is a JSON array; each entry carries a `warnings[]` of `{code, message, severity}`. Resolve the control port once (see Step 3's preamble); it is a dynamic per-project port under the launcher, not necessarily `14199`. **Validate the response shape, not just the status code:** if the body is **not** a JSON array — e.g. it starts with `<!DOCTYPE`/`<html` (the launcher selector's SPA shell, returned with HTTP 200) — the resolved port is wrong. Re-run the resolution; if it still returns HTML, ask the user for the editor port and retry. Keep the local-grep fallback below only for a genuine `connection refused`, never for an HTML 200 — a wrong-server 200 must never be mistaken for "no warnings".
2. For **every** card with a non-empty `warnings[]`, apply the fix its `message` describes and rewrite that HTML file. The `message` is the remediation guide — e.g. *"Use single quotes inside the url() …"* (the quote-collision trap above), *"Render the content statically."* (a stray `<script>` / JS-built content), an empty media box, a remote asset, or a remote font (resolve it with the **Typography** rule: the system's `font-family` + system-font fallback, never a remote load).
3. Re-`curl` and repeat until every card's `warnings[]` is empty, **capped at ~3 passes** so a stubborn finding can't loop forever.
4. Anything still flagged after the cap is **named in the Step 4 numbered key as a plain-language advisory** (e.g. *"3: off-catalog — note: the hero photo loads from a remote source"*) — never left as a silent residual, and never surfaced as a cryptic badge.

**If the API is unreachable** (`connection refused` and the user can't give a port), fall back to a local grep of each file for the highest-signal violations before handoff — `fonts.googleapis.com`, `@import url(http`, `<script`, `<img src="http` — and fix what it finds with the same rules. The API loop is preferred; the grep is the belt-and-suspenders floor.

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

When the UI dispatches an Iterate trigger (an `Iterate:` keyword followed by a fenced JSON feedback bundle, or the no-feedback variant), **do not regenerate anything immediately**. First post a short message asking the user which design(s), if any, are close enough to keep and just tweak — and state clearly that every other design will be discarded and redesigned fresh from the feedback. **Wait for the user's reply before writing any mockup.** This is also where **cross-pollination** happens: if the user says "I like #5's layout but #2's palette," carry that explicitly into the refined slot.

Once the user answers, **switch the preview to the Mockups tab as the regeneration round begins** — before writing the first refreshed/placeholder card:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-active-tab \
  -H 'Content-Type: application/json' \
  -d '{"tab":"mockups"}'
```

Best-effort, same caveats as Step 3 (resolve `$PORT` per Step 3's preamble — a dynamic per-project port, not necessarily `14199`; on `connection refused`, ask for the port — never guess; don't block on it). Then proceed:

- **For each design they choose to keep:** refine it in place using its specific feedback, keeping the same numeric prefix and tier.
- **For every other design:** redesign it fresh from the feedback. A slot keeps its tier unless the feedback implies moving it safer (toward anchored) or bolder (toward exploratory / off-catalog) — honor that drift when the feedback signals it.

**Honor the feedback explicitly — it is non-negotiable signal.** Every card's comment is a concrete instruction and its rating is a strength signal. The refined or redesigned mockup must visibly resolve what the comment called out (e.g. "headline feels weak" → lead with a stronger headline treatment). A low rating means change direction further; a pointed comment means fix that exact thing. This applies to kept-and-tweaked designs and fresh redesigns alike.

For **fresh redesign slots**, weigh the rating and comment to decide whether to keep the slot's current tier+system with a new layout, or switch tiers / pick a **different** system — avoid duplicating a system already used by a kept card.

**Slot/file hygiene when swapping systems or tiers.** The numeric prefix (`NN-`) must stay so the card holds its slot, but the stem changes when the system changes (or becomes `offcatalog`). When you change a slot's system or tier, **delete the old `NN-*.html` before writing the new one** — the UI matches a slot by `NN-` prefix and would show two cards for one slot if both files exist.

Keep all guidance about placeholder imagery, inline-only assets, and atomic writes — these apply to tweaked and redesigned mockups alike. After regenerating, post a short note summarizing what was kept/tweaked vs. redesigned, referencing the specific feedback it addressed. The preview is already on the Mockups tab, so no further tab-switch here.

## Step 6 — handle the selection

When the user picks a direction with a phrase like *"Let's use 4"*, *"I want 4"*, or *"pick 4"*, POST the corresponding filename to the editor backend with `curl`:

```bash
curl -X POST http://localhost:$PORT/api/editor-design-select \
  -H 'Content-Type: application/json' \
  -d '{"filename":"04-<system>-mockup.html"}'
```

Use the **exact filename** you wrote in Step 3, including the `0N-` prefix. For anchored / exploratory picks, the endpoint copies the matching system markdown into `.codeyam/design/design_system.md`; you do **not** touch that file yourself.

**If the user picks an `offcatalog` mockup:** the endpoint cannot yet resolve a backing system (see the Step 3 handoff-gap note). Surface this honestly — confirm their choice, tell them the bespoke direction is captured visually in the mockup, and note that carrying its tokens into the build is backend work in progress. Still POST the selection so the choice is recorded; do not silently fall back to a stock system that doesn't match what they picked.

Resolve the control port once (see Step 3's preamble); it is a dynamic per-project port under the launcher, not necessarily `14199`. If curl returns `connection refused`, ask for the editor port and retry — never guess.

**Never report "locked in" on a bare HTTP 200 — verify the side-effect.** A `200` from the launcher selector is a phantom success: it returns the SPA shell and copies nothing, so the design→build handoff is silently lost. After the POST returns, confirm the on-disk result before telling the user anything took:

- **Anchored / exploratory picks:** read back `.codeyam/design/design_system.md` and confirm it now exists and contains the chosen system's content. Only then surface the one-line "locked in" confirmation. If the file is absent (the phantom-success case), tell the user honestly that the selection did **not** take, re-resolve the port (it was likely the launcher selector), and retry — do not report success.
- **Off-catalog picks:** the endpoint writes no `design_system.md` by design (the Step 3 handoff gap), so do **not** demand that file — confirm the POST returned a JSON (non-HTML) response and record the choice per the off-catalog guidance above.

If it fails, surface the error and let the user pick again.

## What NOT to do

- **No scaffolding** — do not run `codeyam-editor editor template`, `npm install`, `git init`, or any setup command. The project hasn't decided its tech stack yet.
- **No editing `.codeyam/design/design_system.md`** — that's the API's job after the selection POST.
- **No remote fonts or scripts; remote *content photos* only with a fallback.** Never load remote fonts or `<script>` — the `sandbox=""` iframe blocks scripts outright, and a remote font that fails renders inconsistently. Remote *images*, though, the sandbox *does* load: inline is the default for **robustness** (offline / flaky environments) and **privacy** (a remote fetch leaks the viewer's IP to the host), not because the network is blocked. So — decorative imagery stays inline, and a **representational content-photo slot may use a remote image only when stacked on top of the inline depiction as its fallback layer** (the hybrid in Step 3); no bare remote `<img>` that can render as a broken icon. **User-uploaded `.codeyam/design/user_files/` assets** embedded as base64 `data:` URIs (or inline SVG) are inline content and are **required** when provided (Step 1, Step 3).
- **No iframe-busting markup** — avoid `<meta http-equiv="refresh">`, `window.parent` access, or anything that breaks the sandbox.
- **No homogenized set** — never return N near-variants of a single direction. The tier allocation (Step 2) exists to guarantee range; if two mockups read as the same direction, you've failed the comparison.
