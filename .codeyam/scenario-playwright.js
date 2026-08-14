// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: b4c5dd5ba71c482b235f84e869d3e0d05ee4e62936386646d7910e726a9979a8
const {
  hasLoadingMarkers,
  shouldStopWaitingForImages,
} = require("./scenario-metrics");
const fs = require("fs");

// PROTOTYPE (improve35 capture diagnostics): append a per-phase timing line to
// a file so we can see WHERE a slow/timed-out capture spends its budget — even
// when the editor kills this script on timeout (stderr is lost then, but the
// file survives because each line is flushed synchronously). The cwd is the
// project dir (scenario_check.rs sets `.current_dir(project_dir)`), so this
// lands at `<project>/.codeyam/logs/capture-timing.log`. Diagnostics only —
// never throws, never affects the capture result.
function logCaptureTiming(phase, data) {
  try {
    const line = `[${new Date().toISOString()}] [capture-timing] phase=${phase} ${JSON.stringify(
      data,
    )}\n`;
    fs.appendFileSync(".codeyam/logs/capture-timing.log", line);
  } catch (_) {
    /* diagnostics must never break a capture */
  }
}

const net = require("net");

// Resolve a URL to the TCP {host, port} a pre-flight connect should target, or
// null when there is nothing to pre-check — an unparseable URL, or a non-http(s)
// target like `data:`/blank that the capture renders with no network origin.
// Pure (no socket) so the parse, protocol gate, and default-port rules are
// unit-tested without opening a connection.
function resolveTcpTarget(url) {
  let parsed;
  try {
    parsed = new URL(url);
  } catch (_) {
    return null;
  }
  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") return null;
  return {
    host: parsed.hostname,
    port: Number(parsed.port) || (parsed.protocol === "https:" ? 443 : 80),
  };
}

// Fast pre-flight (improve35): is anything accepting TCP on the app port? A
// refused connection (the editor's reverse proxy is down) fails in milliseconds;
// without this, the iframe's `waitForLoadState("load")` hangs the FULL 30s on a
// dead origin (the observed capture failure — capture-timing showed
// navigate-iframe elapsedMs=30004, status=null). A connection that ACCEPTS is
// good enough to proceed — a slow HTTP response *after* connect is a cold
// compile, handled by the normal load wait + the editor's retry. So we only bail
// on a hard refusal/timeout, never on slowness.
async function assertAppPortReachable(url, { timeoutMs = 2500 } = {}) {
  const target = resolveTcpTarget(url);
  if (!target) return; // non-http target (data:, blank) — nothing to pre-check
  const { host, port } = target;
  const started = Date.now();
  await new Promise((resolve, reject) => {
    const socket = net.connect({ host, port });
    const finish = (err) => {
      socket.destroy();
      const elapsedMs = Date.now() - started;
      logCaptureTiming("app-port-reachable", {
        host,
        port,
        reachable: !err,
        elapsedMs,
        error: err ? err.message : null,
      });
      if (err) reject(err);
      else resolve();
    };
    socket.setTimeout(timeoutMs, () =>
      finish(
        new Error(
          `app port unreachable: TCP connect to ${host}:${port} timed out after ${timeoutMs}ms — the editor's reverse proxy is not accepting connections (proxy down?)`,
        ),
      ),
    );
    socket.once("connect", () => finish());
    socket.once("error", (e) =>
      finish(
        new Error(
          `app port unreachable: ${host}:${port} ${e.code || e.message} — is the editor's reverse proxy up? (a capture cannot render a dead app port)`,
        ),
      ),
    );
  });
}

function escapeHtmlAttribute(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll('"', "&quot;");
}

// The harness background defaults to transparent so the iframe's own
// <body> background paints through — matching what users see in the Live
// Preview. Callers (via scenario-check.js) pass a concrete color when the
// UI has detected a background it wants the capture to paint behind the
// iframe, e.g. `var(--bg-deep)` from the editor shell.
function buildIframeHarness(url, { background = "transparent" } = {}) {
  const escapedUrl = escapeHtmlAttribute(url);
  const bg = String(background);
  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <style>
      html, body {
        margin: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: ${bg};
      }

      iframe {
        display: block;
        width: 100%;
        height: 100%;
        border: 0;
        background: ${bg};
      }
    </style>
  </head>
  <body>
    <iframe id="scenario-frame" title="Scenario Preview" src="${escapedUrl}"></iframe>
  </body>
</html>`;
}

const path = require("path");

// The reserved route the editor serves the secure-context iframe harness from.
// Mirrors `HARNESS_PATH` in crates/control-api/src/preview_proxy_route.rs — the
// canonical source of the harness markup now lives in that Rust handler; the
// `buildIframeHarness` template above survives only as the degraded fallback
// below for when the harness origin can't be resolved.
const HARNESS_PATH = "/__codeyam_harness";

// Read `.codeyam/server-state.json` (cwd is the project dir — see the timing
// log note above) and return its parsed object, or null when it is absent.
function defaultReadServerState() {
  const statePath = path.join(process.cwd(), ".codeyam", "server-state.json");
  if (!fs.existsSync(statePath)) return null;
  return JSON.parse(fs.readFileSync(statePath, "utf8"));
}

// Resolve the loopback origin that serves the iframe-harness route. The harness
// is mounted on the editor's control-api listener, whose port is recorded in
// `.codeyam/server-state.json` as `controlPort` (the same file the top-level
// loader already reads for `appPort`). Returns `http://127.0.0.1:<controlPort>`
// — a secure context the nested iframe inherits, exactly as `localhost` is — or
// null when the state file is missing/unreadable, in which case the caller falls
// back to the legacy in-page `setContent` harness. `readStateFile` is injectable
// so the resolver is unit-testable without disk.
//
// The HOST is taken from `targetUrl` — the URL the iframe will load — and only
// the port comes from server-state. That mirroring is load-bearing, because the
// two capture modes address the editor by different loopback spellings:
// `/__codeyam_preview` captures are pinned to `127.0.0.1` (PROXY_CAPTURE_LOOPBACK
// in handlers.rs, matching the forwarder's own pinning) while direct app-port
// captures use `localhost`. `localhost` and `127.0.0.1` are DIFFERENT sites to
// the cookie jar, so whenever the harness host and the iframe host disagree the
// nested load is cross-site — and the `cy_session` cookie is `SameSite=Lax`,
// which rides top-level navigations only. It is therefore withheld from the
// iframe request (and from the `/api/*` calls the framed page makes), and the
// token-gated routes answer 401 on a non-loopback bind.
//
// Hardcoding EITHER spelling only moves the failure between the two modes:
// `localhost` 401s every `/__codeyam_preview` capture, `127.0.0.1` 401s the
// framed page's own `/api/scenarios` + `/api/render-environment` calls. Raising
// the cookie to `SameSite=None` fixes neither — Chromium rejects `None` without
// `Secure`, and these origins are plain http. Mirroring the target's host is what
// keeps the harness same-site in both modes, which is also the same-origin model
// the `/__codeyam_preview` subpath proxy exists to provide.
//
// `targetUrl` omitted or unparseable falls back to `127.0.0.1`, the spelling the
// proxy-route capture (the token-gated one) uses.
function resolveHarnessOrigin({
  readStateFile = defaultReadServerState,
  targetUrl = null,
} = {}) {
  try {
    const state = readStateFile();
    const port = state && state.controlPort;
    if (typeof port === "number" && port > 0) {
      let host = "127.0.0.1";
      if (targetUrl) {
        try {
          host = new URL(targetUrl).hostname || host;
        } catch (_) {
          /* unparseable target — keep the proxy-route default */
        }
      }
      return `http://${host}:${port}`;
    }
  } catch (_) {
    /* missing/unreadable state — fall back to setContent */
  }
  return null;
}

// Build the top-level harness URL for a scenario `url` and background. The
// editor-served harness document embeds `src` as the iframe URL, so the nested
// scenario inherits the harness's secure context. The background rides along as
// `bg`. Pure — `URLSearchParams` does the percent-encoding so a scenario URL
// with its own query string survives intact. Pure.
function buildHarnessUrl(harnessOrigin, url, background) {
  const params = new URLSearchParams({ src: url });
  if (background != null && background !== "") {
    params.set("bg", String(background));
  }
  return `${harnessOrigin}${HARNESS_PATH}?${params.toString()}`;
}

async function collectContentState(target) {
  return target.evaluate(() => {
    const root = document.getElementById("root");
    const imgs = Array.from(document.images || []);
    const loadedImageCount = imgs.filter(
      (img) => img.complete && img.naturalWidth > 0,
    ).length;
    const mediaSelectors = ["svg", "canvas", "video"];
    let mediaBboxCount = 0;
    for (const selector of mediaSelectors) {
      const nodes = document.querySelectorAll(selector);
      for (const node of nodes) {
        const rect = node.getBoundingClientRect();
        if (rect.width > 0 && rect.height > 0) {
          mediaBboxCount += 1;
        }
      }
    }
    return {
      bodyTextLength: document.body ? document.body.innerText.trim().length : 0,
      rootChildCount: root ? root.childElementCount : 0,
      rootTextLength: root ? (root.textContent || "").trim().length : 0,
      imageCount: imgs.length,
      loadedImageCount,
      mediaBboxCount,
    };
  });
}

// Trip scroll-gated entrance animations before capture. Many web/visual
// stacks reveal sections with an IntersectionObserver that flips an
// `opacity:0` element to its final state once it scrolls into view. Captured
// in isolation — where the app shell that wires those observers is absent —
// or on a tall page captured at a fixed viewport, the observers never fire and
// the content stays invisible, so the screenshot is blank. Scroll the document
// end-to-end in steps to trip every observer, then return to the top so the
// captured frame starts where the app does. Stack-agnostic: it drives the same
// scroll a real user would, touching no framework API. A frame whose document
// fits in (or is shorter than) the viewport still gets a nudge-and-restore so a
// single-screen page's scroll-triggered reveal fires too. Returns the measured
// document height (0 when there is nothing to scroll).
async function scrollThroughDocument(target) {
  return target.evaluate(() => {
    const doc = document.scrollingElement || document.documentElement;
    const total = Math.max(
      (doc && doc.scrollHeight) || 0,
      document.body ? document.body.scrollHeight : 0,
    );
    if (typeof window.scrollTo !== "function") return total;
    const viewport = window.innerHeight || 0;
    if (total <= viewport || total === 0) {
      // Even a single-viewport page may gate a reveal on the first scroll
      // event; a nudge-and-restore fires those observers without moving the
      // captured frame off the top.
      window.scrollTo(0, 1);
      window.scrollTo(0, 0);
      return total;
    }
    const stride = Math.max(1, Math.floor((total - viewport) / 8));
    for (let y = 0; y <= total; y += stride) {
      window.scrollTo(0, y);
    }
    window.scrollTo(0, 0);
    return total;
  });
}

// Sum the length of text that is actually PAINTED to the frame — text whose
// element ancestor chain is not hidden by `display:none` / `visibility:hidden`
// and is not collapsed to `opacity:0`, and which occupies a non-zero box. This
// is the signal the blank-frame gate uses to catch a reveal-suppressed capture:
// a frame whose DOM rendered text (so `bodyTextLength > 0`) but whose every
// section is still sitting at the `opacity:0` start of an entrance animation
// that never fired, leaving the screenshot blank. Counts text mid-transition
// (any opacity above exactly 0) as visible, so a reveal that has begun is not
// flagged. Returns `undefined` when the DOM-walking / computed-style APIs are
// unavailable (e.g. a stubbed test target) so callers fall back to the legacy
// DOM-presence behavior rather than treating an un-measurable frame as blank.
async function collectVisibleTextLength(target) {
  return target.evaluate(() => {
    if (
      typeof document.createTreeWalker !== "function" ||
      typeof window.getComputedStyle !== "function" ||
      typeof NodeFilter === "undefined"
    ) {
      return undefined;
    }
    const root = document.body || document.documentElement;
    if (!root) return 0;
    const isHidden = (el) => {
      for (
        let node = el;
        node && node.nodeType === 1;
        node = node.parentElement
      ) {
        const style = window.getComputedStyle(node);
        if (!style) continue;
        if (style.display === "none" || style.visibility === "hidden")
          return true;
        if (parseFloat(style.opacity) === 0) return true;
      }
      return false;
    };
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    let total = 0;
    let node;
    while ((node = walker.nextNode())) {
      const text = (node.nodeValue || "").trim();
      if (!text) continue;
      const el = node.parentElement;
      if (!el || isHidden(el)) continue;
      const rect = el.getBoundingClientRect();
      if (rect.width <= 0 || rect.height <= 0) continue;
      total += text.length;
    }
    return total;
  });
}

// Inject a capture-only stylesheet that snaps entrance animations to their
// FINAL frame: remove animation/transition timing, then reveal the elements an
// entrance animation left INVISIBLE. This is the belt to
// `scrollThroughDocument`'s suspenders — it covers pure-CSS keyframe entrances
// that are mid-flight or stuck at an `opacity:0` start state even after the
// observers fired. It targets the generic CSS symptom, not any framework's
// reveal class, so it works for any stack. The caller gates this OFF when a
// scenario declares an interactive state, so an intentionally animated /
// collapsed interactive frame is never clobbered. Idempotent (a single injected
// style id) and best-effort. Returns true when the style is present after the
// call.
//
// The reveal is per-element and conditional ON THE ELEMENT BEING INVISIBLE,
// never a blanket `opacity: 1 !important` / `transform: none !important` over
// `*`. A blanket rule cannot tell an entrance animation's `opacity: 0` from
// DELIBERATE, resting state — a disabled control's dim, a muted row, a
// collapsed chevron's rotation — so it silently flattened every one of them out
// of every screenshot the capture pipeline produced. Two scenarios differing
// only in such a state then captured byte-identically and collided in the
// distinct-capture gate, and the collision was unfixable in the component: the
// state rendered correctly in a real browser (verified: computed opacity 0.4 vs
// 1) and was erased only at capture time. Anything already visible is now left
// exactly as the app rendered it.
//
// The reveal's TRANSFORM half additionally stops at the SVG boundary, because a
// CSS `transform` overrides the SVG `transform` presentation attribute: inside
// an `<svg>` it erases the static geometry that CONSTRUCTS the drawing instead
// of neutralizing an entrance animation, so a revealed SVG node lands on the
// origin. Invisible SVG nodes are therefore revealed in place — opacity forced,
// transform left alone. See the loop below for why the boundary is
// `ownerSVGElement` rather than `closest("svg")`.
async function forceFinalVisualState(target) {
  return target.evaluate(() => {
    const STYLE_ID = "__codeyam_force_final_state";
    if (
      typeof document.getElementById === "function" &&
      document.getElementById(STYLE_ID)
    ) {
      return true;
    }
    if (typeof document.createElement !== "function") return false;
    const style = document.createElement("style");
    style.id = STYLE_ID;
    // Temporal properties only — these carry no resting state, so removing
    // them cannot erase anything the app meant to show.
    style.textContent =
      "*, *::before, *::after {" +
      "animation: none !important;" +
      "transition: none !important;" +
      "}";
    const head = document.head || document.documentElement;
    if (!head || typeof head.appendChild !== "function") return false;
    head.appendChild(style);

    // With animations disabled above, an element held back by an entrance
    // animation now computes to its pre-animation resting state — typically
    // `opacity: 0`, often paired with a translate/scale that parks it offscreen.
    // Reveal exactly those, and only those: a fully transparent element shows
    // nothing either way, so forcing it can hide no real state, while an element
    // at any visible opacity is left untouched.
    //
    // The transform half of the reveal STOPS at the SVG boundary. A CSS
    // `transform` overrides the SVG `transform` presentation attribute, so
    // inside an `<svg>` a forced `transform: none` does not neutralize an
    // entrance animation — it erases the static rotate/translate/scale that
    // CONSTRUCTS the drawing, revealing the node collapsed on the origin. The
    // opacity half is still right there (a node at ~0 shows nothing either
    // way), so an invisible SVG node is revealed IN PLACE. The boundary test is
    // `ownerSVGElement` and NOT `closest("svg")`: HTML inside a
    // `<foreignObject>` is a real HTMLElement with no `ownerSVGElement`, so it
    // keeps the full reveal — `closest("svg")` would silently strand its
    // genuine CSS entrance transform.
    if (typeof document.querySelectorAll !== "function") return true;
    const INVISIBLE_EPSILON = 0.01;
    for (const el of document.querySelectorAll("*")) {
      let computed = null;
      try {
        computed = getComputedStyle(el);
      } catch (_) {
        continue;
      }
      if (!computed) continue;
      const opacity = parseFloat(computed.opacity);
      if (!Number.isFinite(opacity) || opacity > INVISIBLE_EPSILON) continue;
      if (!el.style || typeof el.style.setProperty !== "function") continue;
      const inSvg =
        el.ownerSVGElement != null ||
        (typeof el.tagName === "string" && el.tagName.toLowerCase() === "svg");
      el.style.setProperty("opacity", "1", "important");
      if (!inSvg) el.style.setProperty("transform", "none", "important");
    }
    return true;
  });
}

// Center the isolated-component wrapper in the viewport before the shot.
//
// The capture pipeline always shoots the full viewport (`page.screenshot({
// fullPage: false })`) and never an element clip, so an isolation page that
// does not center its own component strands it in the top-left corner of every
// frame. Next.js does this in its isolation layout and the query-param stacks
// do it in `.codeyam/harness/isolate.tsx`, but the server-rendered scaffolds
// historically did not — and neither do pages hand-authored before that was
// fixed. This pass closes the gap at capture time, for any stack.
//
// It MEASURES rather than assumes: a wrapper that is already centered is left
// alone, so pages that already do the right thing are byte-identical. The
// `#codeyam-capture` marker (the cross-stack isolation convention; expo emits
// it via `nativeID`) is the gate, so an ordinary route capture is never
// touched. Centering is applied to `<body>` and to each ancestor strictly
// between body and the wrapper — never to the wrapper itself, which frequently
// carries the component's own padding/background and must keep its own box.
// Each axis independently falls back to `flex-start` when the wrapper overflows
// the viewport, so an oversized component loses its bottom/right edge rather
// than being clipped symmetrically out of its top/left one.
//
// Idempotent (a single injected style id), best-effort, and returns a small
// result object describing what it did.
async function centerCaptureWrapper(target) {
  return target.evaluate(() => {
    const STYLE_ID = "__codeyam_center_capture";
    const ANCESTOR_CLASS = "__codeyam-center-ancestor";
    // Subpixel layout and fractional scrollbar widths make exact gap equality
    // unreliable; a couple of px of slop keeps already-centered pages on the
    // no-op branch.
    const TOLERANCE_PX = 2;

    if (typeof document.getElementById !== "function") {
      return { applied: false, reason: "no-dom" };
    }
    if (document.getElementById(STYLE_ID)) {
      return { applied: false, reason: "already-applied" };
    }
    const wrapper = document.getElementById("codeyam-capture");
    if (!wrapper || typeof wrapper.getBoundingClientRect !== "function") {
      return { applied: false, reason: "no-capture-marker" };
    }

    const rect = wrapper.getBoundingClientRect();
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    const leftGap = rect.left;
    const rightGap = viewportWidth - rect.right;
    const topGap = rect.top;
    const bottomGap = viewportHeight - rect.bottom;

    const fitsHorizontally = rect.width <= viewportWidth;
    const fitsVertically = rect.height <= viewportHeight;
    const centeredHorizontally =
      fitsHorizontally && Math.abs(leftGap - rightGap) <= TOLERANCE_PX;
    const centeredVertically =
      fitsVertically && Math.abs(topGap - bottomGap) <= TOLERANCE_PX;

    if (centeredHorizontally && centeredVertically) {
      return { applied: false, reason: "already-centered" };
    }

    const horizontal = fitsHorizontally ? "center" : "flex-start";
    const vertical = fitsVertically ? "center" : "flex-start";

    // Stamp the ancestor chain so the injected rule targets exactly the
    // elements between <body> and the wrapper and cannot leak elsewhere.
    let node = wrapper.parentElement;
    while (node && node !== document.body) {
      if (node.classList && typeof node.classList.add === "function") {
        node.classList.add(ANCESTOR_CLASS);
      }
      node = node.parentElement;
    }

    if (typeof document.createElement !== "function") {
      return { applied: false, reason: "no-dom" };
    }
    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent =
      "body, ." +
      ANCESTOR_CLASS +
      " {" +
      "margin: 0;" +
      "min-height: 100vh;" +
      "display: flex;" +
      "align-items: " +
      vertical +
      ";" +
      "justify-content: " +
      horizontal +
      ";" +
      "}";
    const head = document.head || document.documentElement;
    if (!head || typeof head.appendChild !== "function") {
      return { applied: false, reason: "no-dom" };
    }
    head.appendChild(style);
    return { applied: true, horizontal, vertical };
  });
}

async function collectImageStates(target) {
  return target.evaluate(() =>
    Array.from(document.images || []).map((img) => ({
      complete: img.complete,
      naturalWidth: img.naturalWidth,
      src: img.currentSrc || img.src || "",
    })),
  );
}

async function waitForImagesSettled(
  target,
  { overallTimeoutMs = 5000, pollIntervalMs = 100 } = {},
) {
  const started = Date.now();
  let images = await collectImageStates(target);
  while (
    !shouldStopWaitingForImages(images, {
      elapsedMs: Date.now() - started,
      overallTimeoutMs,
    })
  ) {
    await new Promise((r) => setTimeout(r, pollIntervalMs));
    images = await collectImageStates(target);
  }
  const elapsedMs = Date.now() - started;
  const allComplete = images.every((img) => img && img.complete === true);
  const incompleteSrcs = images
    .filter((img) => !img || img.complete !== true || !(img.naturalWidth > 0))
    .map((img) => (img && img.src) || "")
    .slice(0, 6);
  logCaptureTiming("images-settled", {
    elapsedMs,
    settled: allComplete,
    total: images.length,
    incompleteCount: incompleteSrcs.length,
    incompleteSrcs,
    overallTimeoutMs,
  });
  return { settled: allComplete, images, elapsedMs };
}

async function waitForAnimationsSettled(
  target,
  { timeoutMs = 2000, pollIntervalMs = 100 } = {},
) {
  const started = Date.now();
  while (Date.now() - started < timeoutMs) {
    const runningCount = await target.evaluate(() =>
      document
        .getAnimations()
        .filter((a) => a.playState === "running").length,
    );
    if (runningCount === 0) {
      return { settled: true, elapsedMs: Date.now() - started };
    }
    await new Promise((r) => setTimeout(r, pollIntervalMs));
  }
  return { settled: false, elapsedMs: Date.now() - started };
}

// Track in-flight network requests on a Playwright page so a capture can wait
// for client-side data fetches to settle before screenshotting. The
// resource-timing API (`performance.getEntriesByType("resource")`) only records
// COMPLETED requests, so it cannot see a fetch that is still in flight — the
// exact window where a client-fetch page shows a loading skeleton. We count
// request starts against finishes/failures instead. Returns a live view:
// `inFlight()` is the current outstanding count and `lastActivityMs()` is the
// timestamp of the most recent request start OR completion (0 when the page has
// made no requests since the tracker attached). Attach BEFORE navigation so
// every request is counted. Stack-agnostic — it observes raw HTTP activity, not
// any framework's fetch wrapper.
function createNetworkTracker(page) {
  let inFlight = 0;
  let lastActivityMs = 0;
  const bump = () => {
    lastActivityMs = Date.now();
  };
  if (page && typeof page.on === "function") {
    page.on("request", () => {
      inFlight += 1;
      bump();
    });
    const settle = () => {
      inFlight = Math.max(0, inFlight - 1);
      bump();
    };
    page.on("requestfinished", settle);
    page.on("requestfailed", settle);
  }
  return {
    inFlight: () => inFlight,
    lastActivityMs: () => lastActivityMs,
  };
}

// Bounded network-quiet wait: after the DOM is stable a client-side data fetch
// can still be in flight — the loading skeleton is gone but the fetched rows
// haven't replaced it yet, so a screenshot here catches the in-between frame.
// Wait until no request has been outstanding for `quietWindowMs`, hard-capped at
// `overallTimeoutMs`. Two properties matter:
//   - A page that made NO requests (lastActivityMs stays 0) is already quiet and
//     returns on the first poll, so server-rendered captures incur no extra wait.
//   - A streaming / long-poll endpoint that never goes idle hits the cap and the
//     caller captures anyway — the wait can never hang the capture.
async function waitForNetworkQuiet(
  tracker,
  { quietWindowMs = 500, overallTimeoutMs = 5000, pollIntervalMs = 100 } = {},
) {
  const started = Date.now();
  while (Date.now() - started < overallTimeoutMs) {
    const idleForMs = Date.now() - tracker.lastActivityMs();
    if (tracker.inFlight() === 0 && idleForMs >= quietWindowMs) {
      const elapsedMs = Date.now() - started;
      logCaptureTiming("network-quiet", { outcome: "quiet", elapsedMs });
      return { quiet: true, elapsedMs };
    }
    await new Promise((r) => setTimeout(r, pollIntervalMs));
  }
  const elapsedMs = Date.now() - started;
  logCaptureTiming("network-quiet", {
    outcome: "capped",
    elapsedMs,
    inFlight: tracker.inFlight(),
  });
  return { quiet: false, elapsedMs };
}

// `loadingMarkers` are the project's app-specific loading strings (from
// stack.json `capture.loadingMarkers`); they extend the codeyam-harness
// defaults so a stable-but-still-loading app screen counts as "not ready"
// and the loop keeps waiting instead of capturing the loading flash.
async function waitForStablePage(page, target, timeoutMs = 10000, loadingMarkers = []) {
  const started = Date.now();
  let lastHtml = "";
  let stableCount = 0;
  let lastHadLoadingMarkers = false;
  let lastHtmlChanged = false;

  while (Date.now() - started < timeoutMs) {
    await page.waitForTimeout(500);

    const pageState = await target.evaluate(() => {
      const getById = document.getElementById;
      const root =
        typeof getById === "function" ? document.getElementById("root") : null;
      return {
        bodyText: document.body?.innerText ?? "",
        html: document.body?.innerHTML ?? "",
        // Whether the SPA mount point exists AND has painted anything. An
        // existing-but-empty `<div id="root">` is the pre-paint window of a
        // slow-first-paint scenario (e.g. a live-session app that spends a few
        // seconds connecting before the gate UI mounts). `rootExists` lets us
        // distinguish that from a mid-redirect/teardown `null` body, where
        // there is no root to wait on and a stable-empty page is legitimately
        // settled.
        rootExists: !!root,
        rootChildCount: root ? root.childElementCount : 0,
      };
    });

    lastHadLoadingMarkers = hasLoadingMarkers(pageState.bodyText, loadingMarkers);
    lastHtmlChanged = pageState.html !== lastHtml;

    // A mounted-but-unpainted root is "still loading", not "settled": the HTML
    // can sit byte-stable for a second or two while the SPA boots, which would
    // otherwise satisfy the stability check and capture a blank frame before
    // first paint. Treat an existing root with zero children AND no body text
    // as not-ready so the loop keeps polling until the app actually paints (or
    // the overall timeout fires, by which point real content is present). A
    // `null` body (rootExists=false) is unaffected — it stays trivially stable.
    const rootUnpainted =
      pageState.rootExists &&
      pageState.rootChildCount === 0 &&
      (pageState.bodyText ?? "").trim().length === 0;

    if (!lastHadLoadingMarkers && !lastHtmlChanged && !rootUnpainted) {
      stableCount += 1;
      if (stableCount >= 2) {
        const remaining = () => Math.max(0, timeoutMs - (Date.now() - started));
        await waitForAnimationsSettled(target, {
          timeoutMs: Math.min(2000, remaining()),
        });
        await waitForImagesSettled(target, { overallTimeoutMs: remaining() });
        logCaptureTiming("stable-page", {
          outcome: "stabilized",
          elapsedMs: Date.now() - started,
        });
        return { stabilized: true, hadLoadingMarkers: false };
      }
    } else {
      stableCount = 0;
    }

    lastHtml = pageState.html;
  }
  // Hit the cap without stabilizing — record WHY: a persistent loading marker
  // (app stuck) vs HTML still mutating each poll (HMR / animation / re-render).
  // The returned `hadLoadingMarkers` is the signal the capture advisory keys
  // off: a marker still on screen at the cap means the page never finished its
  // (likely client-side) load, so the screenshot caught its loading state.
  logCaptureTiming("stable-page", {
    outcome: "timed-out",
    elapsedMs: Date.now() - started,
    timeoutMs,
    lastHadLoadingMarkers,
    lastHtmlStillChanging: lastHtmlChanged,
  });
  return { stabilized: false, hadLoadingMarkers: lastHadLoadingMarkers };
}

// `preflight` is injectable so unit tests that drive a mock page can stay
// network-free; production callers use the default real reachability check.
async function loadScenarioInIframe(
  page,
  url,
  { background, preflight = assertAppPortReachable, harnessOrigin } = {},
) {
  await preflight(url);
  // `undefined` (the default) means "resolve from server-state"; an explicit
  // value (including `null`) is honored as-is so tests can force either path.
  const resolvedHarnessOrigin =
    harnessOrigin !== undefined ? harnessOrigin : resolveHarnessOrigin();
  const navStarted = Date.now();
  const responsePromise = page
    .waitForResponse(
      (response) =>
        response.request().resourceType() === "document" &&
        response.url() === url,
      { timeout: 30000 },
    )
    .catch(() => null);

  if (resolvedHarnessOrigin) {
    // Navigate the page TOP-LEVEL to the harness document served from the
    // editor's `localhost` origin, so the ancestor document is a secure context
    // and the nested scenario iframe inherits it (the Sveltia-class fix). The
    // inner iframe `src` is still `url`, so the document-response probe above is
    // unchanged.
    const harnessUrl = buildHarnessUrl(resolvedHarnessOrigin, url, background);
    const harnessResponse = await page.goto(harnessUrl, {
      waitUntil: "domcontentloaded",
    });
    // Fail loudly on a fail-closed harness-auth rejection BEFORE the blind 30s
    // `#scenario-frame` wait below. On a non-loopback (0.0.0.0 / cloud) bind the
    // harness control-API route is session-token-gated; a generated
    // `.codeyam/capture.js` (or an editor binary) that predates the `cy_session`
    // cookie injection navigates without a token -> the server refuses the
    // request with 401 -> the harness document never renders -> every component
    // scenario times out on `#scenario-frame` with a generic Playwright error
    // that hides the real cause. Surfacing the 401 here turns that blind timeout
    // into a one-line root cause on the very first failing capture, naming both
    // fixes. (Route/page scenarios navigate top-level to the un-gated app proxy,
    // so they never hit this path.)
    if (harnessResponse && harnessResponse.status() === 401) {
      throw new Error(
        `Capture harness route ${harnessUrl} returned 401 (fail-closed ` +
          `session-token auth on a non-loopback bind). The capture script did not ` +
          `send the \`cy_session\` token — most often a generated ` +
          `\`.codeyam/capture.js\` (or an editor binary) that predates session-token ` +
          `injection. Fixes: refresh the editor binary on this VM, or set ` +
          `\`CODEYAM_INSECURE_BIND=1\` and restart the editor.`,
      );
    }
  } else {
    // Degraded fallback: no resolvable harness origin (server-state missing), so
    // use the legacy in-page harness. The top-level document is then
    // `about:blank` — NOT a secure context — so a secure-context-gated app may
    // refuse to mount, but every non-secure-context scenario captures exactly as
    // before.
    await page.setContent(buildIframeHarness(url, { background }), {
      waitUntil: "domcontentloaded",
    });
  }

  const frameHandle = await page.waitForSelector("#scenario-frame", {
    state: "attached",
    timeout: 30000,
  });
  const frame = await frameHandle.contentFrame();
  if (!frame) {
    throw new Error("Scenario iframe did not attach");
  }

  await frame.waitForLoadState("load", { timeout: 30000 });
  const response = await responsePromise;
  logCaptureTiming("navigate-iframe", {
    elapsedMs: Date.now() - navStarted,
    status: response ? response.status() : null,
    url,
  });
  return { frame, response };
}

// Load the scenario as a top-level navigation instead of embedding it in
// the iframe harness. A top-level document is a first-party context, so a
// `SameSite=Lax` session cookie is sent on the navigation — which is what
// auth-gated application routes need to render the authenticated page
// rather than redirecting to /login. The returned `frame` is the page's
// main frame so callers can treat it uniformly with the iframe path
// (`frame.url()`, `frame.evaluate(...)`, `waitForStablePage(page, frame)`).
async function loadScenarioTopLevel(
  page,
  url,
  { preflight = assertAppPortReachable } = {},
) {
  await preflight(url);
  const navStarted = Date.now();
  try {
    const response = await page.goto(url, {
      waitUntil: "load",
      timeout: 30000,
    });
    logCaptureTiming("navigate-toplevel", {
      elapsedMs: Date.now() - navStarted,
      status: response ? response.status() : null,
      url,
    });
    return { frame: page.mainFrame(), response };
  } catch (error) {
    if (error.message && error.message.toLowerCase().includes("timeout")) {
      let parsed = null;
      try {
        parsed = new URL(url);
      } catch (_) {}
      if (parsed) {
        let appPort = null;
        try {
          const path = require("path");
          const statePath = path.join(process.cwd(), ".codeyam", "server-state.json");
          if (fs.existsSync(statePath)) {
            const state = JSON.parse(fs.readFileSync(statePath, "utf8"));
            appPort = state.appPort;
          }
        } catch (_) {}

        if (appPort) {
          let appHealthy = false;
          try {
            await assertAppPortReachable(`http://127.0.0.1:${appPort}/`, { timeoutMs: 500 });
            appHealthy = true;
          } catch (_) {}

          if (appHealthy) {
            throw new Error(
              `proxy navigation timed out: the proxy at 127.0.0.1:${parsed.port} did not respond within 30000ms. app healthy on :${appPort}, proxy dead on :${parsed.port}.`
            );
          } else {
            throw new Error(
              `proxy navigation timed out: the proxy at 127.0.0.1:${parsed.port} did not respond within 30000ms. app also unresponsive on :${appPort}.`
            );
          }
        } else {
          throw new Error(
            `proxy navigation timed out: the proxy at 127.0.0.1:${parsed.port} did not respond within 30000ms. proxy dead/hung?`
          );
        }
      }
    }
    throw error;
  }
}

// The CSS selector for "clickable / interactive" elements — buttons, links,
// role=button, form controls, <summary>, and anything with an onclick. Shared
// by the candidate-label collector (below) and the text-target resolver
// (`resolveTextTarget`), which prefers an interactive element over a plain
// text node when a click/press label matches both.
const INTERACTIVE_SELECTOR =
  "button, a[href], [role=button], input, select, textarea, summary, [onclick]";

// Collect up to 20 distinct visible labels of interactive elements on the
// page — buttons, links, role=button, form controls, <summary>, and anything
// with an onclick. Used to build an ACTIONABLE error when an interaction's
// target matches nothing: the agent reliably knows a label it rendered, so
// listing the real candidates turns a silent blank capture into a "did you
// mean one of these?" hint. Pure read (no clicks); falls back to value /
// aria-label / placeholder when an element has no text.
async function collectInteractiveLabels(frame) {
  return frame.evaluate((selector) => {
    const nodes = Array.from(document.querySelectorAll(selector));
    const labels = nodes
      .map((node) => {
        const text =
          (node.innerText || node.textContent || "").trim() ||
          (typeof node.value === "string" ? node.value.trim() : "") ||
          (node.getAttribute && node.getAttribute("aria-label")) ||
          (node.getAttribute && node.getAttribute("placeholder")) ||
          "";
        return String(text).trim();
      })
      .filter((label) => label.length > 0);
    return Array.from(new Set(labels)).slice(0, 20);
  }, INTERACTIVE_SELECTOR);
}

// Describe the elements a substring text match resolved, so an ambiguity
// warning can name the competing controls (e.g. the preset button "Bet" vs the
// disclosure button "…or bet on"). Reads each matched element's inner text via
// Playwright's `allInnerTexts`, caps the list at 5, and trims each to a single
// short line. Pure read; degrades to a count-only description if the locator
// API or the page can't produce texts.
async function describeMatchCandidates(baseLocator, matchCount) {
  const CAP = 5;
  const MAX_LEN = 60;
  let texts = [];
  try {
    if (typeof baseLocator.allInnerTexts === "function") {
      texts = await baseLocator.allInnerTexts();
    }
  } catch (_) {
    texts = [];
  }
  const described = texts
    .map((t) => String(t).replace(/\s+/g, " ").trim())
    .filter((t) => t.length > 0)
    .slice(0, CAP)
    .map((t) => (t.length > MAX_LEN ? `${t.slice(0, MAX_LEN)}…` : t))
    .map((t) => `"${t}"`);
  if (described.length === 0) {
    return [`${matchCount} elements (text unavailable)`];
  }
  if (matchCount > described.length) {
    described.push(`…and ${matchCount - described.length} more`);
  }
  return described;
}

// Drive a single user-style interaction against the settled frame before the
// screenshot, so an interactive state (expanded accordion, open modal, filled
// field) can be captured without editing app source.
//
// The target is matched by visible `text` (preferred — the agent reliably
// knows the label it rendered) or a CSS `selector`. `action` is click / fill /
// press; `value` carries the text for `fill` or the key for `press` (e.g.
// `Enter`). On a no-match target this THROWS with the list of candidate
// interactive labels — the capture script's outer catch turns that into a
// failed capture with an actionable message, never a silent blank screenshot.
//
// Resolve a visible-text target to the element most likely intended, instead
// of blindly taking the first substring hit. A bare
// `getByText(text, { exact: false })` is a case-insensitive SUBSTRING match, so
// a label can land on a plain text node or a placeholder rather than the chip /
// button the agent meant (observed: a `"Japan"` click hit placeholder text, not
// the chip; a `"Bet"` click hit a disclosure button described "or bet on"). We
// try increasingly-loose locators in priority order and take the first that
// matches anything:
//   1. exact + interactive   (for click/press)
//   2. exact
//   3. substring + interactive   (for click/press)
//   4. substring
// so an exact, clickable element wins over a substring plain-text node. Returns
// the winning tier's locator plus its match count; when nothing matches at all,
// returns the substring locator (count 0) so the caller's zero-match error path
// still fires with its candidate-label hint.
async function resolveTextTarget(frame, text, action) {
  const preferInteractive = action === "click" || action === "press";
  const exactBase = frame.getByText(text, { exact: true });
  const substrBase = frame.getByText(text, { exact: false });

  const tiers = [];
  // `.and()` (Playwright ≥1.34) intersects two locators to the elements
  // matching both — here, the text element that is ALSO interactive. Guard on
  // its presence so a locator without `.and` degrades to text-only tiers.
  if (preferInteractive && typeof exactBase.and === "function") {
    const interactive = frame.locator(INTERACTIVE_SELECTOR);
    tiers.push(exactBase.and(interactive));
    tiers.push(exactBase);
    tiers.push(substrBase.and(interactive));
    tiers.push(substrBase);
  } else {
    tiers.push(exactBase);
    tiers.push(substrBase);
  }

  for (const loc of tiers) {
    const count = await loc.count();
    if (count > 0) {
      return { baseLocator: loc, matchCount: count };
    }
  }
  return { baseLocator: substrBase, matchCount: 0 };
}

// Pick the single element to act on from a resolved locator. When more than one
// candidate remains within the winning tier, prefer a VISIBLE element over a
// hidden one rather than acting on raw `.first()` (a hidden duplicate — an
// off-screen menu clone, an aria-hidden mirror — is almost never the intended
// target). Degrades to `.first()` when the locator API lacks a visible filter
// or no candidate is visible.
async function pickBestCandidate(baseLocator, matchCount) {
  if (matchCount <= 1) {
    return baseLocator.first();
  }
  try {
    if (typeof baseLocator.filter === "function") {
      const visible = baseLocator.filter({ visible: true });
      if ((await visible.count()) > 0) {
        return visible.first();
      }
    }
  } catch (_) {
    // Locator API without a `{ visible: true }` filter — fall through.
  }
  return baseLocator.first();
}

// Text matching prefers an EXACT, INTERACTIVE element over a looser substring /
// plain-text hit (see `resolveTextTarget`), so the first attempt lands on the
// chip or button the agent meant. When a genuine ambiguity survives that
// resolution (>1 candidate in the winning tier), we still act — on the best
// visible candidate — but push an actionable warning naming every candidate
// into the optional `warnings` array so the agent can switch to an exact
// selector; a zero-match throws an error that spells out the substring caveat
// and the exact-selector / URL-query-param alternatives.
async function performInteraction(
  frame,
  interaction,
  { timeoutMs = 5000, warnings } = {},
) {
  const { action, selector, text, value } = interaction || {};

  let baseLocator;
  let targetDesc;
  let matchedByText = false;
  let matchCount;
  if (typeof text === "string" && text.length > 0) {
    const resolved = await resolveTextTarget(frame, text, action);
    baseLocator = resolved.baseLocator;
    matchCount = resolved.matchCount;
    targetDesc = `text "${text}"`;
    matchedByText = true;
  } else if (typeof selector === "string" && selector.length > 0) {
    baseLocator = frame.locator(selector);
    matchCount = await baseLocator.count();
    targetDesc = `selector "${selector}"`;
  } else {
    throw new Error(
      "preview-interact: interaction requires a `text` or `selector` target",
    );
  }

  if (matchCount === 0) {
    const candidates = await collectInteractiveLabels(frame);
    const candidateList =
      candidates.length > 0 ? candidates.join(", ") : "(none found on page)";
    throw new Error(
      `preview-interact: no element matched ${targetDesc}. ` +
        `Text is matched as a case-insensitive SUBSTRING, so a misspelled or ` +
        `over-specific label matches nothing — prefer an exact/role/testid CSS ` +
        `selector (e.g. {"selector":"[data-testid=\\"save\\"]"}) for a precise ` +
        `target. Many filter/status/sort states are also reachable directly via a ` +
        `URL query param (e.g. add "?status=active" to the path) with no ` +
        `interaction at all. Candidate interactive labels: ${candidateList}`,
    );
  }

  const locator = await pickBestCandidate(baseLocator, matchCount);

  // Ambiguity warning: a text target that still resolves >1 element within the
  // winning tier acts on the best visible candidate, which may not be the one
  // intended. Name the competing elements instead of silently proceeding. Only
  // fires for text matches — an explicit selector that matches many is the
  // caller's deliberate choice.
  if (matchedByText && matchCount > 1 && Array.isArray(warnings)) {
    warnings.push(
      `preview-interact: ${targetDesc} matched ${matchCount} elements — acting on the best visible candidate. ` +
        `Text resolution prefers an exact, interactive match, but several remain, so this may not be the element you meant. ` +
        `Candidates: ${(await describeMatchCandidates(baseLocator, matchCount)).join(" | ")}. ` +
        `Use an exact/role/testid selector to disambiguate.`,
    );
  }

  try {
    switch (action) {
      case "click":
        await locator.click({ timeout: timeoutMs });
        break;
      case "fill":
        await locator.fill(value ?? "", { timeout: timeoutMs });
        break;
      case "press":
        await locator.press(value || "Enter", { timeout: timeoutMs });
        break;
      case "hover":
        // Reveals hover-only affordances (an action bar, a tooltip) — one of the
        // most common ephemeral states a resting-render screenshot misses.
        await locator.hover({ timeout: timeoutMs });
        break;
      default:
        throw new Error(
          `preview-interact: unknown action "${action}" (expected click | fill | press | hover)`,
        );
    }
  } catch (error) {
    const candidates = await collectInteractiveLabels(frame);
    const candidateList =
      candidates.length > 0 ? candidates.join(", ") : "(none found on page)";
    throw new Error(
      `preview-interact: action "${action}" failed against ${targetDesc}: ${error.message || String(error)}. ` +
        `Candidate interactive labels: ${candidateList}`,
    );
  }
}

// Hold until a visible-text or selector predicate becomes true, bounded by a
// wall-clock timeout. Behavioral demos hinge on transient states (an overlay
// appears, then a new round renders); a flow step waits for that real signal
// instead of a fixed sleep — the same "hold to a real signal with a safety
// bound" rule the rest of the capture pipeline follows. THROWS on timeout
// naming the predicate and the bound, so the capture script's outer catch
// turns a never-appearing predicate into an actionable failure rather than an
// infinite hang. `text` is matched case-insensitively as a substring (the
// agent reliably knows the copy it rendered); `selector` is a CSS selector.
async function waitForPredicate(frame, predicate, { defaultTimeoutMs = 8000 } = {}) {
  const { text, selector, timeoutMs } = predicate || {};
  const bound =
    typeof timeoutMs === "number" && timeoutMs > 0 ? timeoutMs : defaultTimeoutMs;

  let locator;
  let desc;
  if (typeof text === "string" && text.length > 0) {
    locator = frame.getByText(text, { exact: false }).first();
    desc = `text "${text}"`;
  } else if (typeof selector === "string" && selector.length > 0) {
    locator = frame.locator(selector).first();
    desc = `selector "${selector}"`;
  } else {
    throw new Error("waitFor: predicate requires a `text` or `selector` target");
  }

  try {
    await locator.waitFor({ state: "visible", timeout: bound });
  } catch (_) {
    throw new Error(
      `waitFor: predicate ${desc} did not become visible within ${bound}ms`,
    );
  }
}

// Drive an ordered sequence of interactions against the settled frame, settling
// the page between each so a later step sees the DOM the earlier one produced.
// This is the persisted-scenario path (`scenario.interactions`): unlike the
// single fire-and-forget `preview-interact`, the whole sequence is replayed on
// every capture and recapture. Any step that matches nothing throws (with the
// candidate-labels hint from `performInteraction`), and the caller turns that
// into a failed capture — never a silent resting-state screenshot for a
// sequence that didn't fully run.
// `settle` is injectable so unit tests that drive a mock frame stay
// network-free and fast; production callers use the default real
// `waitForStablePage` re-settle between steps.
async function performInteractionSequence(
  page,
  frame,
  interactions,
  {
    timeoutMs = 5000,
    settleMs = 5000,
    loadingMarkers,
    settle = waitForStablePage,
    warnings,
  } = {},
) {
  for (let i = 0; i < interactions.length; i += 1) {
    try {
      await performInteraction(frame, interactions[i], { timeoutMs, warnings });
    } catch (err) {
      // Prefix the failing step's index so a miss in a multi-step sequence is
      // locatable, matching the model-side `interactions[i]` validator.
      throw new Error(`interactions[${i}]: ${err.message}`);
    }
    await settle(page, frame, settleMs, loadingMarkers);
  }
}

module.exports = {
  logCaptureTiming,
  resolveTcpTarget,
  assertAppPortReachable,
  escapeHtmlAttribute,
  buildIframeHarness,
  HARNESS_PATH,
  resolveHarnessOrigin,
  buildHarnessUrl,
  collectContentState,
  scrollThroughDocument,
  collectVisibleTextLength,
  forceFinalVisualState,
  centerCaptureWrapper,
  collectImageStates,
  waitForImagesSettled,
  waitForAnimationsSettled,
  createNetworkTracker,
  waitForNetworkQuiet,
  waitForStablePage,
  loadScenarioInIframe,
  loadScenarioTopLevel,
  collectInteractiveLabels,
  describeMatchCandidates,
  performInteraction,
  waitForPredicate,
  performInteractionSequence,
};
