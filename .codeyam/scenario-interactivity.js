// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  build: 6ea55943b1b98a49b87de465f4129750d75dcac1  source-sha256: 8ad1de7e5385d8af7889b9884831d134e90ebd5dee2717b179e62e13186bdb30
const fs = require("fs");
const path = require("path");
const { createIssue } = require("./scenario-issues");

// Hydration / interactivity probe for the headless capture browser.
//
// Background: a page can return HTTP 200, render visible content, log no
// console errors, and still be completely dead — the client framework never
// hydrated, so every button and handler is inert. The status / render /
// console / image gates all pass and the broken page sails through to the
// user (the catalog whose filter buttons did nothing). This probe asserts the
// page actually became interactive before the capture gate reports success,
// so a non-hydrating page can no longer pass `client-errors`.
//
// Stack assumption: WHICH framework's hydration we look for is data-driven
// from `.codeyam/stack.json` (or an explicit override) — never hardcoded into
// the capture flow. Stacks with no client runtime (backend services, CLIs,
// static HTML) are a documented no-op pass. Frameworks for which we have no
// reliable in-page attachment signal are ALSO a conservative pass: we never
// flag a page we cannot prove is dead, so a healthy Svelte / Solid / vanilla
// page is never a false negative. A new framework detector is a new entry in
// `detectors` below plus a `KNOWN_FRAMEWORKS` mapping — not an edit here; a
// meta-framework that hydrates an already-detected runtime is a new row in
// `META_FRAMEWORK_ALIASES`.

// Frameworks we have an in-page attachment detector for. Inference only
// resolves to one of these; an unrecognised framework yields `null`, which
// the caller treats as "cannot determine" (conservative pass).
const KNOWN_FRAMEWORKS = ["react", "vue"];

// The same-origin mount the editor's reverse proxy serves the preview under.
// Two places in this module need it — the counterpart probe's origin map, and
// the hydration message's "are we under the prefix?" test — and they must never
// disagree about the spelling, since a message that fails to recognise the
// mount is exactly the misdiagnosis this constant supports fixing.
//
// Agreeing on the spelling is necessary and NOT sufficient: the consumers must
// also agree on the TEST. Both gates once asked `url.includes(PREVIEW_SUBPATH)`,
// which is a scan of the whole URL rather than of the route, and that is what
// `isUnderPreviewSubpath` below exists to replace.
const PREVIEW_SUBPATH = "/__codeyam_preview";

// Is this URL under the preview mount? Judged on the PATHNAME, never as a
// substring of the whole URL.
//
// A substring scan finds the mount wherever it appears — including
// percent-encoded inside a query parameter — and that silently disabled this
// entire escalation path for every isolated-component capture. Those load
// through the iframe harness, whose document URL is
// `/__codeyam_harness?src=…%2F__codeyam_preview%2F…`: the literal prefix is
// absent, so both gates below answered "no" and the answer was decided by
// encoding rather than by the route. Testing the pathname makes the harness
// document correctly not-under-the-mount and the decoded preview URL correctly
// under it, in both directions.
//
// Fails CLOSED on a non-string, empty, or unparseable (e.g. relative) URL: this
// runs inside a capture whose finding is already recorded, so it must never
// throw.
function isUnderPreviewSubpath(url) {
  if (typeof url !== "string" || !url) return false;
  let pathname;
  try {
    pathname = new URL(url).pathname;
  } catch (_) {
    return false;
  }
  return (
    pathname === PREVIEW_SUBPATH || pathname.startsWith(`${PREVIEW_SUBPATH}/`)
  );
}

// Meta-frameworks mapped to the underlying runtime whose hydration detector
// applies. These do not carry their runtime's name in their stack identity: a
// Next.js app is `id: "nextjs-prisma-sqlite"`, `name: "Next.js + Prisma +
// SQLite"` — nothing contains the literal "react". Without this map the
// substring scan below returns `null`, the capture skips the hydration gate,
// and a genuinely un-hydrated page is reported as an inert control rather than
// as hydration never having run.
//
// Saying "Next hydrates React" is a fact about the runtime, not a framework
// assumption, so this stays consistent with the data-driven design above: a new
// meta-framework is a new row here, not a new branch in the capture flow.
//
// Matched with word boundaries rather than bare substrings so an unrelated name
// like "NextGen CLI" or "Remixer" cannot masquerade as a meta-framework.
const META_FRAMEWORK_ALIASES = [
  { pattern: /\bnext(\.js|js)?\b/, framework: "react" },
  { pattern: /\bremix\b/, framework: "react" },
  { pattern: /\bgatsby\b/, framework: "react" },
  { pattern: /\bnuxt(\.js|js)?\b/, framework: "vue" },
];

// Read `.codeyam/stack.json` relative to the capture script's cwd (the project
// dir — `scenario_check.rs` sets `.current_dir(project_dir)`). Never throws: a
// missing or malformed file yields `null` so the probe degrades to a no-op
// rather than breaking a capture.
function readStackJson() {
  try {
    const raw = fs.readFileSync(path.join(".codeyam", "stack.json"), "utf8");
    return JSON.parse(raw);
  } catch (_) {
    return null;
  }
}

// Scan a stack descriptor's identity fields for a framework we can probe.
// Pure — no I/O — so the matching rules are unit-tested without a stack.json.
function inferFramework(stack) {
  if (!stack) return null;
  const haystack = [
    stack.id,
    stack.name,
    ...(Array.isArray(stack.technologies) ? stack.technologies : []),
  ]
    .filter((s) => typeof s === "string")
    .join(" ")
    .toLowerCase();
  for (const { pattern, framework } of META_FRAMEWORK_ALIASES) {
    if (pattern.test(haystack)) return framework;
  }
  for (const fw of KNOWN_FRAMEWORKS) {
    if (haystack.includes(fw)) return fw;
  }
  return null;
}

// Decide, from a stack descriptor, whether the capture should expect a
// hydrated client runtime and which framework to probe for. Pure.
//
// `capture.interactivity === false` is an explicit opt-out for stacks that
// render no client runtime. `capture.interactivity.framework` is an explicit
// override when inference can't see the framework in the identity fields.
// Otherwise we infer: a known client framework, or `routing.type ===
// "client-side"`, implies a runtime that must hydrate; backend / static / CLI
// stacks match neither and no-op.
function resolveInteractivityExpectation(stack) {
  const capture = (stack && stack.capture) || {};
  if (capture.interactivity === false) {
    return { expectInteractive: false, framework: null };
  }
  const explicit =
    capture.interactivity && typeof capture.interactivity === "object"
      ? capture.interactivity.framework
      : null;
  if (typeof explicit === "string" && explicit.length > 0) {
    return { expectInteractive: true, framework: explicit.toLowerCase() };
  }
  const framework = inferFramework(stack);
  const routingType =
    stack && stack.routing && typeof stack.routing.type === "string"
      ? stack.routing.type
      : null;
  const expectInteractive = framework != null || routingType === "client-side";
  return { expectInteractive, framework };
}

// Run the in-page detection inside the loaded frame. Read-only: it inspects
// DOM-node properties left by a framework's hydration but never clicks or
// mutates anything, so it is safe to run before the screenshot is taken.
//
// Returns `{ controlCount, frameworkAttached, hasPasswordInput, credentialForm,
// formIsThePage }` where `frameworkAttached` is `true` (runtime demonstrably
// attached), `false` (framework-owned controls exist but no attachment signal —
// the dead-hydration case), or `null` (no detector for this framework, OR every
// interactive control is delegated to a terminal/canvas widget with no hydration
// marker → cannot judge).
//
// The last three are the password census — the un-declared auth-gate signal,
// read only by the auth-gate guard and deliberately never by the hydration
// verdict. `hasPasswordInput` is whether the census contains a `type="password"`
// input; `credentialForm` and `formIsThePage` are the two corroborating shapes
// that separate a password GATE from a page that merely owns a password FIELD.
// They travel together: a caller that reads one without the others is back to
// the bare-boolean inference the corroboration exists to narrow.
async function collectHydrationState(frame, { framework } = {}) {
  return frame.evaluate((fw) => {
    const SELECTOR =
      'button, [role="button"], a[href], input:not([type="hidden"]), select, textarea, summary, [onclick]';
    // Roots of third-party terminal/canvas widgets that mount imperatively and
    // wire their own (non-framework) event handlers — xterm's `.xterm`, any
    // `<canvas>`, or an element a component explicitly flags terminal-backed.
    // Interactive controls inside these (e.g. xterm's hidden helper
    // `<textarea>`) never carry framework attachment keys even on a fully
    // hydrated page, so judging hydration from them yields a false "not
    // interactive" verdict. Stack assumption: `.xterm` is xterm-specific; the
    // `<canvas>` and `[data-terminal-backed]` entries are framework-agnostic
    // escape hatches any widget-embedding component can use.
    const WIDGET_ROOT_SELECTOR = ".xterm, canvas, [data-terminal-backed]";

    const controls = Array.from(document.querySelectorAll(SELECTOR));
    const inWidget = (el) =>
      !!el &&
      typeof el.closest === "function" &&
      el.closest(WIDGET_ROOT_SELECTOR) != null;
    // Framework-owned controls: those NOT delegated to a terminal/canvas
    // widget. Only these can prove or disprove that the framework hydrated.
    const frameworkControls = controls.filter((el) => !inWidget(el));

    // Per-framework attachment detectors. Each returns true when the framework
    // has demonstrably attached its client runtime to a live node. The
    // presence of a detector for `fw` is itself the signal that we CAN judge
    // this framework; the default (no detector) means "cannot determine".
    const detectors = {
      react: (els) =>
        els.some(
          (el) =>
            !!el &&
            Object.keys(el).some(
              (k) =>
                k.startsWith("__reactFiber$") ||
                k.startsWith("__reactProps$") ||
                k.startsWith("__reactContainer$"),
            ),
        ),
      vue: (els) =>
        els.some(
          (el) =>
            !!el &&
            (el.__vue__ != null ||
              el.__vnode != null ||
              el.__vueParentComponent != null),
        ) || !!document.querySelector("[data-v-app]"),
    };

    const detector = detectors[fw];

    // Terminal/canvas scenarios prove hydration with an explicit, framework-
    // rendered `data-codeyam-hydrated` marker. It counts only when the
    // framework actually attached to it — a marker that exists in static HTML
    // but never hydrated fails the same detector and does not count.
    const markerEl = document.querySelector("[data-codeyam-hydrated]");
    const markerAttached = detector
      ? detector(markerEl ? [markerEl] : [])
      : false;

    let frameworkAttached;
    if (!detector) {
      // No detector for this framework — cannot judge (conservative pass).
      frameworkAttached = null;
    } else if (detector(frameworkControls) || markerAttached) {
      // A genuinely framework-owned control attached, or an explicit hydration
      // marker proves the framework ran — definitively hydrated.
      frameworkAttached = true;
    } else if (frameworkControls.length === 0) {
      // Controls exist but every one lives inside a terminal/canvas widget and
      // there is no marker — we cannot prove the page is dead, so never flag.
      frameworkAttached = null;
    } else {
      // Framework-owned controls rendered but none attached — the dead-island
      // signal the gate exists to catch.
      frameworkAttached = false;
    }

    // The password census: a separate concern from hydration detection above,
    // sharing only the `controls` array. Declared INSIDE this closure and not at
    // module scope on purpose — `frame.evaluate` serializes its callback to the
    // browser, so the body cannot reference anything outside itself. An inner
    // function is the whole decomposition available here; hoisting it would make
    // the collector throw a ReferenceError in the page.
    //
    // Derived from the already-collected `controls` rather than a second
    // `querySelectorAll`, so the gate reasons about exactly the set the census
    // counted — a separate query is free to disagree with it. `SELECTOR` already
    // admits password inputs via `input:not([type="hidden"])`.
    function collectPasswordCensus(controls) {
      // Attributes are matched case-insensitively because `type="PASSWORD"` is
      // valid HTML.
      const attr = (el, name) =>
        String((el && el.getAttribute(name)) || "").toLowerCase();
      // `autocomplete` is a space-separated TOKEN LIST, not a single value:
      // `autocomplete="section-login username"` is valid and must match.
      const hasToken = (el, name, token) =>
        attr(el, name).split(/\s+/).includes(token);
      const isPassword = (el) =>
        !!el && el.tagName === "INPUT" && attr(el, "type") === "password";
      const passwordInputs = controls.filter(isPassword);
      const passwordInput = passwordInputs[0] || null;
      if (!passwordInput) {
        return {
          hasPasswordInput: false,
          credentialForm: false,
          formIsThePage: false,
        };
      }

      // A password FIELD is not a password GATE: a change-password card, a
      // set-password pair and an API-key form all own one legitimately, and
      // reporting each as a gate is what pushed a downstream project into
      // declaring `expectedAuthGate: true` on scenarios that depict no gate.
      //
      // `credentialForm` reads the page's OWN credential semantics rather than a
      // threshold: the web platform already has a vocabulary for "this is a
      // sign-in form". A change-password card declares `new-password` and
      // carries no identity field; an API-key form is a lone password input. No
      // magic numbers and nothing stack-specific — it is HTML semantics, so it
      // holds on Next.js, Svelte, Astro or plain HTML alike.
      //
      // `formIsThePage` is the weaker disjunct that keeps the original
      // motivating case working: a bare password-protected admin route may be a
      // single password input with no username and no `autocomplete`, which
      // credential semantics alone would stop detecting. "The form IS the page"
      // — the census found nothing beyond the form's own controls — is that
      // shape. It is deliberately imprecise, and affordable only because the
      // inferred signal is now an advisory rather than a capture failure.
      const nearestForm = (el) =>
        el && typeof el.closest === "function" ? el.closest("form") : null;
      const passwordForm = nearestForm(passwordInput);
      // Two controls share a form when their nearest `<form>` ancestor is the
      // same node — including when both have none, which is the ordinary
      // div-based login markup on component frameworks.
      const sharesPasswordForm = (el) => nearestForm(el) === passwordForm;
      const isIdentityField = (el) =>
        !!el &&
        el.tagName === "INPUT" &&
        (attr(el, "type") === "email" ||
          hasToken(el, "autocomplete", "username") ||
          hasToken(el, "autocomplete", "email"));

      return {
        hasPasswordInput: true,
        credentialForm:
          passwordInputs.some((el) =>
            hasToken(el, "autocomplete", "current-password"),
          ) ||
          controls.some((el) => isIdentityField(el) && sharesPasswordForm(el)),
        // With no `<form>` ancestor there is no form to be the page, so the
        // shape only qualifies when the password input is the ONLY control —
        // otherwise every formless page carrying a password field would match.
        formIsThePage: passwordForm
          ? controls.every(sharesPasswordForm)
          : controls.every((el) => el === passwordInput),
      };
    }

    return {
      controlCount: controls.length,
      frameworkAttached,
      ...collectPasswordCensus(controls),
    };
  }, framework || null);
}

// The census as "no claim was made" — every fact `null`, never `false`. Returned
// whenever no census was taken at all: a non-interactive stack, or a probe that
// threw. One definition rather than a literal at each of the four seams, because
// the three facts must be `null` TOGETHER; a seam that nulls one and defaults
// another to `false` hands the gate a corroboration it never observed.
const NO_PASSWORD_CENSUS = {
  hasPasswordInput: null,
  credentialForm: null,
  formIsThePage: null,
};

// Project the three census facts out of a `collectHydrationState` result, so
// both probe seams pass through exactly the same set. `state` may be the
// null-census placeholder, in which case this is a no-op projection.
function passwordCensusOf(state) {
  return {
    hasPasswordInput: state.hasPasswordInput,
    credentialForm: state.credentialForm,
    formIsThePage: state.formIsThePage,
  };
}

// Map a capture URL to the SAME route on the OTHER preview origin.
//
// A preview route reaches the browser one of two ways: through the editor's
// same-origin subpath proxy (`<proxyOrigin><previewPrefix>/foo`) or directly at
// the app's own origin (`<appOrigin>/foo`). Given either, return the other, so
// the hydration gate can re-probe the IDENTICAL route across the origin
// boundary — the control experiment that tells "this ORIGIN cannot hydrate"
// apart from "this PAGE is dead". Two sessions built this probe by hand before
// concluding their own change was innocent; building it once is cheaper than
// every session rebuilding it.
//
// Returns `null` when the URL belongs to neither origin (an external scenario
// URL has no counterpart) or when the origin inputs are incomplete — a probe we
// cannot aim is simply not run, never a guess.
function counterpartOriginUrl(url, { appOrigin, proxyOrigin, previewPrefix }) {
  if (!url || !appOrigin || !proxyOrigin || !previewPrefix) return null;
  const proxyRoot = `${proxyOrigin}${previewPrefix}`;
  const rejoin = (base, rest) =>
    `${base}${rest.startsWith("/") ? rest : `/${rest}`}`;
  if (url.startsWith(proxyRoot)) {
    return rejoin(appOrigin, url.slice(proxyRoot.length) || "/");
  }
  if (url.startsWith(appOrigin)) {
    return rejoin(proxyRoot, url.slice(appOrigin.length) || "/");
  }
  return null;
}

// Turn a collected state into a `hydration` issue, or `null` to pass. Pure, so
// every branch is unit-tested without a browser.
//
// Pass when: no client runtime expected (no-op stacks); no interactive control
// to probe (a static content page in a client app is legitimately inert); the
// framework attached; OR we couldn't determine attachment (`null` — never
// false-positive). Flag only the proven-dead case: controls exist AND the
// framework's runtime is demonstrably not attached.
//
// `crossOrigin` carries the control-probe verdict and changes only the
// ATTRIBUTION, never the detection above — the detector is deliberately
// conservative and stays exactly as strict:
//   "counterpart-hydrates" — the same route hydrates on the other origin, so
//     the finding is about THIS origin and the app is exonerated.
//   "dead-on-both"         — it fails on both, so the page really is dead and
//     the `diagnose-preview` proxy steer is a known dead end; don't offer it.
//   null/undefined         — no probe ran; the original message stands.
function interpretHydration({
  expectInteractive,
  controlCount,
  frameworkAttached,
  framework,
  url,
  crossOrigin,
  counterpartUrl,
}) {
  if (!expectInteractive) return null;
  if (!(controlCount > 0)) return null;
  if (frameworkAttached !== false) return null;
  return createIssue(
    "hydration",
    hydrationMessage({
      controlCount,
      framework,
      crossOrigin,
      counterpartUrl,
      url,
    }),
    {
      url: url ?? null,
      // The attribution travels as DATA alongside the prose. A consumer that
      // must act on `counterpart-hydrates` — the editor's preview-origin
      // escalation — reads this field rather than matching the message text.
      crossOrigin: crossOrigin ?? null,
      counterpartUrl: counterpartUrl ?? null,
    },
  );
}

// Compose the prose for a proven-dead hydration verdict. Split out of
// `interpretHydration` so the two concerns are separable: that function decides
// WHETHER this is a failure (three deliberately conservative guards that must
// not be weakened), this one decides HOW it is described. Pure and
// string-returning, so every attribution branch is asserted without
// constructing a verdict or a browser.
function hydrationMessage({
  controlCount,
  framework,
  crossOrigin,
  counterpartUrl,
  url,
}) {
  const fw = framework || "the client framework";
  const plural = controlCount === 1 ? "" : "s";
  const rendered =
    `Page rendered ${controlCount} interactive control${plural} but ${fw} never attached ` +
    `event handlers`;
  const counterpart = counterpartUrl || "the other preview origin";

  if (crossOrigin === "counterpart-hydrates") {
    // This used to end with "Re-run the capture against the origin that works",
    // which described a capability the editor did not have: no flag or command
    // re-aimed a capture, so the only way to act on it was to hand-edit
    // `previewOrigin` and restart the server — which blanks the user's pane and
    // drops their session. Now that the capture origin resolves independently
    // of the viewer's, say what actually happens and name the key that
    // overrides it, rather than prescribing a manual step. The
    // `diagnose-preview` steer is real and stays.
    return (
      `${rendered} on THIS preview origin — but the same route DOES hydrate at ` +
      `${counterpart}. The page is fine and your change did not break it; this ` +
      `ORIGIN is not serving working client JS. Captures resolve their own ` +
      `origin and aim at the app directly when the editor runs alongside it, so ` +
      `this usually needs no action; set \`captureOrigin\` in .codeyam/editor.json ` +
      `to aim them somewhere else. Run ` +
      "`codeyam-editor editor diagnose-preview --path <route>` to pinpoint what " +
      `the proxy hop is breaking.`
    );
  }

  if (crossOrigin === "dead-on-both") {
    return (
      `${rendered} — the page is not interactive (hydration did not run). The ` +
      `identical failure reproduces at ${counterpart}, so this is NOT the preview ` +
      `proxy and \`diagnose-preview\` will not explain it: client JS is genuinely ` +
      `not executing. Check the browser console for a module or runtime error.`
    );
  }

  // No counterpart probe ran, so nothing here is attributed — but the URL still
  // carries one strong, checkable suspect. Under `/__codeyam_preview` the
  // browser sits at a PREFIXED pathname while the app's server rendered for the
  // bare one, and a client router that reconciles `window.location.pathname`
  // against the route embedded in its SSR payload refuses to hydrate on exactly
  // that mismatch. Naming it is the difference between a lead and a dead end:
  // the generic "check the browser console" steer below sent a real session
  // hunting a module error on a page whose client JS was executing perfectly,
  // and which hydrated on the first try at the app's own origin.
  if (isUnderPreviewSubpath(url)) {
    return (
      `${rendered} — the page is not interactive (hydration did not run), and it was ` +
      `loaded under the \`${PREVIEW_SUBPATH}\` preview mount. That prefix is the prime ` +
      `suspect: the browser is at a prefixed pathname while the app rendered for the ` +
      `bare one, and a client-routed app that reconciles the two refuses to hydrate — ` +
      `client JS is running fine. Load the same route directly on the app's own origin ` +
      `to confirm, then run ` +
      "`codeyam-editor editor diagnose-preview --path <route>`, which probes exactly " +
      `this. Do NOT start with the browser console; the console is clean in this case.`
    );
  }

  return (
    `${rendered} — the page is not interactive (hydration did not run). Client JS may ` +
    `not be executing; check the preview proxy and the browser console. Run ` +
    "`codeyam-editor editor diagnose-preview --path <route>` to pinpoint a proxy " +
    `HTML-injection blocker.`
  );
}

// Decide whether a hydration verdict proves the PREVIEW SUBPATH is what broke
// the page — the one shape that justifies escalating the preview onto the app's
// own origin. Returns the escalation payload, or `null` for every other verdict.
//
// Both halves are required and neither is sufficient:
//   - the failing load must have been UNDER `/__codeyam_preview`, and
//   - the counterpart (the app's own origin) must have HYDRATED.
//
// The direction matters and is easy to get backwards. `counterpartOriginUrl`
// maps both ways, so `counterpart-hydrates` also fires when a capture aimed at
// the app origin died and the *proxied* copy lived. Escalating on that would
// move the preview onto the origin that just failed. `dead-on-both` is excluded
// for the reason spelled out in `hydrationMessage`: the page is genuinely
// broken, and escalating would swap a false veto for a false pass.
//
// Pure, so every branch is asserted without a browser or a server.
function subpathHydrationEscalation({ crossOrigin, url, counterpartUrl }) {
  if (crossOrigin !== "counterpart-hydrates") return null;
  if (!isUnderPreviewSubpath(url)) return null;
  return { failedUrl: url, counterpartUrl: counterpartUrl ?? null };
}

// Build the hydration gate's cross-origin control probe, or `null` when this
// project has no second origin to probe.
//
// The gate's finding — "controls rendered but the framework never attached" —
// is real but says nothing about WHOSE fault it is. Loading the identical route
// on the other preview origin answers exactly that, and it is the experiment two
// sessions each ran by hand (against an untouched component with a committed
// passing screenshot) purely to establish that their own change was innocent.
//
// Lives here rather than in the capture orchestrator because its only two
// dependencies — `counterpartOriginUrl` and `collectHydrationState` — are both
// in this module, so co-locating them needs no new cross-module edge.
//
// Runs in a throwaway page in the SAME browser context, so it inherits the
// capture's cookies and storage and probes like-for-like. Fail-soft everywhere:
// any missing port, unmappable URL, or navigation error yields `null`, which
// leaves the reported message exactly as it was. `readServerState` is
// injectable so the port/origin wiring is unit-testable without disk.
function buildCounterpartProbe(page, { readServerState = null } = {}) {
  let state;
  try {
    state = readServerState
      ? readServerState()
      : JSON.parse(
          fs.readFileSync(
            path.join(process.cwd(), ".codeyam", "server-state.json"),
            "utf8",
          ),
        );
  } catch (_) {
    return null;
  }
  const appPort = state && state.appPort;
  const controlPort = state && state.controlPort;
  if (!(appPort > 0) || !(controlPort > 0)) return null;

  // These spellings must match what `resolve_dev_mode_preview_url` emits:
  // `browser_facing_origin` uses `localhost`, the proxy hop uses the
  // `PROXY_CAPTURE_LOOPBACK` dotted form.
  const origins = {
    appOrigin: `http://localhost:${appPort}`,
    proxyOrigin: `http://127.0.0.1:${controlPort}`,
    previewPrefix: PREVIEW_SUBPATH,
  };

  return async (currentUrl, { framework } = {}) => {
    const target = counterpartOriginUrl(currentUrl, origins);
    if (!target) return null;
    let probePage;
    try {
      probePage = await page.context().newPage();
      await probePage.goto(target, {
        waitUntil: "domcontentloaded",
        timeout: 15000,
      });
      // Give the counterpart the same chance to attach that the primary got,
      // rather than reading it the instant the document arrives.
      await probePage.waitForTimeout(2000);
      // Same framework detector as the primary read, so the two verdicts are
      // like-for-like and a difference means the ORIGIN, not the detector.
      const probed = await collectHydrationState(probePage.mainFrame(), {
        framework,
      });
      return { url: target, hydrated: probed.frameworkAttached };
    } catch (_) {
      return null;
    } finally {
      if (probePage) await probePage.close().catch(() => {});
    }
  };
}

// Orchestrator called from the capture flow: resolve the expectation (from the
// project's stack.json unless the caller injects a `stack`), short-circuit when
// no client runtime is expected, collect the in-page state, and interpret it.
// Never throws — a probe failure must not break an otherwise-good capture.
//
// Returns `{ hydrated, issue, hasPasswordInput, credentialForm, formIsThePage }`:
//   hydrated — `true` (runtime demonstrably attached), `false` (PROVEN dead:
//     framework-owned controls rendered but nothing attached), or `null`
//     ("cannot determine" — no client runtime expected, no control to probe, no
//     detector for the framework, or the probe threw).
//   issue — the `hydration` issue to surface, or `null` to pass.
//   hasPasswordInput / credentialForm / formIsThePage — the password census, or
//     `null` for ALL THREE when no census was taken at all. `null` is not
//     `false`: it is the absence of a claim, and only a `true`
//     `hasPasswordInput` corroborated by one of the other two may fire the
//     inferred auth-gate signal downstream. The three are `null` together or
//     populated together — a partially-threaded census is the bare-boolean
//     inference all over again.
//
// `hydrated` is deliberately three-valued rather than a bare boolean: the
// capture flow branches a page to `interactionEffect: "unhydrated"` ONLY on a
// proven `false`. A `null` must never be read as "dead" — that would turn every
// unknown-framework page into a false hydration failure.
async function probeHydrationState(frame, { url, stack } = {}) {
  const descriptor = stack !== undefined ? stack : readStackJson();
  const { expectInteractive, framework } =
    resolveInteractivityExpectation(descriptor);
  if (!expectInteractive)
    return { hydrated: null, issue: null, ...NO_PASSWORD_CENSUS };
  let state;
  try {
    state = await collectHydrationState(frame, { framework });
  } catch (_) {
    return { hydrated: null, issue: null, ...NO_PASSWORD_CENSUS };
  }
  const issue = interpretHydration({
    expectInteractive: true,
    controlCount: state.controlCount,
    frameworkAttached: state.frameworkAttached,
    framework,
    url,
  });
  // `frameworkAttached` is already the three-valued signal `hydrated` needs —
  // pass it through rather than re-deriving it from the presence of an issue,
  // which would conflate "no issue" (a pass) with "hydrated" (a positive).
  return {
    hydrated: state.frameworkAttached,
    issue,
    ...passwordCensusOf(state),
  };
}

// Sleep for `ms` — a promisified `setTimeout`, so the poll loop yields the
// event loop between ticks instead of spinning.
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Bounded WAIT for hydration — the polling generalization of
// `probeHydrationState`. Where the probe reads the attachment state once,
// this re-polls `collectHydrationState` until the framework demonstrably
// attaches, the state becomes unjudgeable, or a wall-clock cap elapses. It is
// the seam the capture flow calls so that every screenshot and every driven
// interaction happens AFTER the client runtime has attached, not on inert SSR
// markup (the bug where a fill/click landed before React hydrated, the handler
// never fired, yet the run reported success).
//
// Stack-agnostic by construction: it resolves the same expectation as the
// probe, so a non-interactive stack (backend/static/CLI, or an explicit
// `capture.interactivity === false`) returns immediately with `hydrated: null`
// and never waits. An unknown framework (no detector) reads
// `frameworkAttached === null` on the first poll and also passes instantly — we
// never block on a page we cannot judge.
//
// Never fails closed: a timeout yields `hydrated: false` and lets the existing
// `interpretHydration` path decide whether to surface the loud `hydration`
// issue; a thrown probe (detached frame mid-nav) is caught and treated as a
// pass. The wait can never hang a capture (hard cap) and never turns a page we
// cannot prove dead into a failure.
//
// Honest limitation: the poll can only judge a page that has already rendered
// framework-owned controls. `waitForStablePage` runs first (its `rootUnpainted`
// guard waits for the SPA root to paint), so by the time this runs, content is
// present for the SSR case this guards; a pure-CSR shell that renders zero
// controls reads `null` and passes instantly, unchanged from today.
//
// Returns `{ hydrated, issue, timedOut, waitedMs, hasPasswordInput,
// credentialForm, formIsThePage }` where `hydrated` is the same three-valued
// signal `probeHydrationState` returns and the last three are the same password
// census it passes through — `null` for all three whenever no census was taken
// (a non-interactive stack, or a probe that threw on its very first poll).
async function waitForHydration(
  frame,
  {
    url,
    stack,
    framework,
    timeoutMs = 10000,
    pollIntervalMs = 150,
    probeCounterpart,
  } = {},
) {
  let resolvedFramework;
  let expectInteractive;
  if (typeof framework === "string" && framework.length > 0) {
    expectInteractive = true;
    resolvedFramework = framework.toLowerCase();
  } else {
    const descriptor = stack !== undefined ? stack : readStackJson();
    const resolution = resolveInteractivityExpectation(descriptor);
    expectInteractive = resolution.expectInteractive;
    resolvedFramework = resolution.framework;
  }
  if (!expectInteractive) {
    return {
      hydrated: null,
      issue: null,
      timedOut: false,
      waitedMs: 0,
      ...NO_PASSWORD_CENSUS,
    };
  }

  const start = Date.now();
  let state = {
    controlCount: 0,
    frameworkAttached: null,
    ...NO_PASSWORD_CENSUS,
  };
  let timedOut = false;
  for (;;) {
    try {
      state = await collectHydrationState(frame, {
        framework: resolvedFramework,
      });
    } catch (_) {
      // Detached frame mid-navigation (or any probe throw): treat as "cannot
      // determine" and pass — a probe failure must never fail a capture.
      // A null census for the same reason: a throw means no census was taken,
      // which is not the claim that no password field is present.
      state = {
        controlCount: 0,
        frameworkAttached: null,
        ...NO_PASSWORD_CENSUS,
      };
      break;
    }
    // `true` (attached) and `null` (cannot judge) are both terminal — the
    // conservative "can't prove dead" signal the probe already trusts. Only a
    // proven `false` keeps us waiting.
    if (state.frameworkAttached !== false) break;
    // Stop before a sleep that would overrun the cap, so the wait stays bounded.
    if (Date.now() - start + pollIntervalMs >= timeoutMs) {
      timedOut = true;
      break;
    }
    await sleep(pollIntervalMs);
  }

  // Control experiment, run ONLY on a proven-dead verdict: re-probe the same
  // route on the other preview origin before reporting. This is the cheapest
  // moment to answer "is it my page or is it this origin?", and it costs a page
  // load only on a run that was already going to fail. Never throws and never
  // changes the verdict — a probe that cannot run leaves the message exactly as
  // it was.
  let crossOrigin;
  let counterpartUrl;
  if (
    state.frameworkAttached === false &&
    typeof probeCounterpart === "function"
  ) {
    try {
      const result = await probeCounterpart(url, {
        framework: resolvedFramework,
      });
      if (result && result.url) {
        counterpartUrl = result.url;
        if (result.hydrated === true) crossOrigin = "counterpart-hydrates";
        if (result.hydrated === false) crossOrigin = "dead-on-both";
      }
    } catch (_) {
      // A failed control probe is not evidence either way — fall through to the
      // original, un-attributed message.
    }
  }

  const issue = interpretHydration({
    expectInteractive: true,
    controlCount: state.controlCount,
    frameworkAttached: state.frameworkAttached,
    framework: resolvedFramework,
    url,
    crossOrigin,
    counterpartUrl,
  });
  return {
    hydrated: state.frameworkAttached,
    issue,
    timedOut,
    waitedMs: Date.now() - start,
    ...passwordCensusOf(state),
    crossOrigin: crossOrigin ?? null,
    counterpartUrl: counterpartUrl ?? null,
  };
}

module.exports = {
  KNOWN_FRAMEWORKS,
  PREVIEW_SUBPATH,
  isUnderPreviewSubpath,
  subpathHydrationEscalation,
  readStackJson,
  inferFramework,
  resolveInteractivityExpectation,
  buildCounterpartProbe,
  collectHydrationState,
  counterpartOriginUrl,
  hydrationMessage,
  interpretHydration,
  passwordCensusOf,
  probeHydrationState,
  waitForHydration,
};
