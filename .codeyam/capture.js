#!/usr/bin/env node
// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: ef6a93a53c3713f399320bd8f89b4481cac2ebdd6359057e89d6b79c9a53808f

// Render environment (colorScheme, deviceScaleFactor, userAgent, locale,
// timezoneId, reduceMotion, forcedColors) is read from config when present
// and passed to browser.newContext(). This is what makes screenshots match
// the Live Preview iframe's host browser — see docs/rendering.md.
//
// iframeBackground is forwarded to buildIframeHarness so the capture paints
// the user's editor-shell background (or whatever the UI detected) behind
// the iframe instead of a hardcoded white.

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const { chromium } = require("playwright");

// Substring Playwright has emitted across every 1.x release when the
// browser cache is empty. Match the substring (not the full string)
// because Playwright includes the offending path inline.
const PLAYWRIGHT_MISSING_BROWSER_PATTERN = "Executable doesn't exist";
const PLAYWRIGHT_INSTALL_COMMAND = "npx playwright install chromium";

// Substrings Playwright/Chromium emit when the browser process dies on a
// transient launch crash. On the cloud VM the base image has no dbus session,
// so Chromium intermittently aborts at launch with `Received signal 11`
// (SIGSEGV) — an environmental fault, not a scenario fault. Match either form
// because the wording varies across Playwright releases and the OS signal
// reporter.
const PLAYWRIGHT_LAUNCH_CRASH_PATTERNS = ["SIGSEGV", "Received signal 11"];
// A transient SIGSEGV launch crash is environmental, so a bounded retry clears
// it. Keep it small — a genuinely broken environment must still surface loudly
// rather than spin.
const CAPTURE_LAUNCH_SIGSEGV_RETRIES = 2;
// Short backoff between SIGSEGV retries so the transient fault has a moment to
// clear; small enough not to eat the per-slug recapture budget.
const CAPTURE_LAUNCH_SIGSEGV_BACKOFF_MS = 250;

// Pin the headless capture browser's `localhost` resolution to the IPv4
// loopback the editor's listeners bind. The browser-facing preview origin is
// now `localhost` (secure-context apps refuse a bare IP — see
// `BROWSER_FACING_HOST`), but on a dual-stack host `localhost` can resolve to
// `::1` first, which nothing answers on — stalling the capture or paying a
// happy-eyeballs fallback delay. Forcing the map removes that intermittency
// deterministically for capture. The operator's OWN preview browser is covered
// separately by the editor binding `::1` alongside `127.0.0.1` (see start.rs).
const CAPTURE_HOST_RESOLVER_RULES = "MAP localhost 127.0.0.1";
const CAPTURE_LAUNCH_ARGS = [
  `--host-resolver-rules=${CAPTURE_HOST_RESOLVER_RULES}`,
  // Cloud-VM-no-dbus / containerized-launch hardening. Each flag below is
  // inert on a healthy desktop, so the laptop capture path is unchanged; on
  // the dbus-less cloud base image they stop Chromium from SIGSEGV-ing at
  // launch (signal 11). See plan chromium-capture-dbus-crash-hardening.
  // No setuid sandbox in the container (the cloud VM runs capture without the
  // kernel namespaces the sandbox needs).
  "--no-sandbox",
  // /dev/shm is tiny in many containers; route shared memory to /tmp so the
  // renderer doesn't crash allocating it.
  "--disable-dev-shm-usage",
  // No GPU on the headless cloud VM — avoid the GL init path that aborts.
  "--disable-gpu",
  // Stub out the dbus integration Chromium reaches for at launch; the cloud
  // base image has no dbus session bus, which is the proximate cause of the
  // signal-11 abort.
  "--disable-features=DBus",
];
// Point Chromium's dbus client at a dead address so it never blocks on (or
// crashes against) a missing session bus. Spread over the real env in the
// default launcher so the laptop path keeps its normal environment.
const CAPTURE_LAUNCH_DBUS_ENV = { DBUS_SESSION_BUS_ADDRESS: "/dev/null" };

// Does this launch error look like a transient SIGSEGV browser crash?
// (environmental — e.g. the cloud VM's missing dbus session bus — not a
// scenario fault, so it is safe to retry).
function isTransientLaunchCrash(error) {
  return (
    error &&
    typeof error.message === "string" &&
    PLAYWRIGHT_LAUNCH_CRASH_PATTERNS.some((pattern) =>
      error.message.includes(pattern),
    )
  );
}

// Self-heal around `chromium.launch()`. Two recoverable classes:
//
//   1. "missing browser" — run `npx playwright install chromium` synchronously
//      (with `stdio: "inherit"` so the user sees progress) and retry once.
//   2. transient SIGSEGV launch crash — retry the launch up to
//      `CAPTURE_LAUNCH_SIGSEGV_RETRIES` times with a short backoff, since the
//      crash is environmental (dbus-less cloud VM) and clears on a retry.
//
// For any unrecognized error, or after exhausting retries, rethrow the
// ORIGINAL Playwright error so the existing `Scenario check failed: <stderr>`
// path keeps showing the actionable message — looping would hide a real ops
// failure under a slow timeout.
async function launchChromiumWithSelfHeal({
  launch = () =>
    chromium.launch({
      args: CAPTURE_LAUNCH_ARGS,
      env: { ...process.env, ...CAPTURE_LAUNCH_DBUS_ENV },
    }),
  install = () => execSync(PLAYWRIGHT_INSTALL_COMMAND, { stdio: "inherit" }),
  stderr = process.stderr,
  sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms)),
} = {}) {
  try {
    return await launch();
  } catch (error) {
    const isMissingBrowser =
      error &&
      typeof error.message === "string" &&
      error.message.includes(PLAYWRIGHT_MISSING_BROWSER_PATTERN);
    const isTransientCrash = isTransientLaunchCrash(error);
    if (!isMissingBrowser && !isTransientCrash) throw error;

    if (isTransientCrash) {
      for (let attempt = 1; attempt <= CAPTURE_LAUNCH_SIGSEGV_RETRIES; attempt++) {
        stderr.write(
          `Chromium crashed at launch (transient, likely a dbus-less environment) — retry ${attempt}/${CAPTURE_LAUNCH_SIGSEGV_RETRIES}.\n`,
        );
        await sleep(CAPTURE_LAUNCH_SIGSEGV_BACKOFF_MS);
        try {
          return await launch();
        } catch (retryError) {
          if (!isTransientLaunchCrash(retryError)) throw retryError;
        }
      }
      throw error;
    }

    stderr.write(
      "Playwright's Chromium browser is missing — installing it now (one-time ~150 MB download). Subsequent runs will be instant.\n",
    );
    try {
      install();
    } catch (_installError) {
      throw error;
    }
    try {
      return await launch();
    } catch (_retryError) {
      throw error;
    }
  }
}

const {
  findScenarioError,
  SCENARIO_ERROR_MARKER,
  hasRenderableContent,
  buildSettleAdvisory,
  describeBlankReason,
} = require("./scenario-metrics");

const {
  createIssue,
  pushIssue,
  buildResult,
} = require("./scenario-issues");

const {
  attachHttpMocks,
  isDeclaredErrorMock,
  unmockedRouteFrom,
} = require("./scenario-mocks");

const {
  assertAppPortReachable,
  loadScenarioInIframe,
  loadScenarioTopLevel,
  resolveHarnessOrigin,
  waitForStablePage,
  createNetworkTracker,
  waitForNetworkQuiet,
  collectContentState,
  scrollThroughDocument,
  collectVisibleTextLength,
  forceFinalVisualState,
  centerCaptureWrapper,
  performInteraction,
  waitForPredicate,
  performInteractionSequence,
} = require("./scenario-playwright");

// Name of the cookie the editor's control-API accepts the session token in —
// must match `SESSION_COOKIE` in crates/control-api/src/origin_guard.rs. On a
// non-loopback (cloud) bind the control-API requires this token on the harness
// route (`/__codeyam_harness`); without it the top-level harness navigation 401s
// and `#scenario-frame` never attaches, so EVERY capture times out. The browser
// UI carries this cookie automatically; the headless capturer does not, so we
// inject it here from the on-box 0600 token file.
const SESSION_COOKIE = "cy_session";

// The loopback names the editor can be addressed by. A cookie is scoped by
// HOST, and the jar does NOT treat these as interchangeable: a cookie stored for
// `localhost` is simply not sent to `127.0.0.1`. That matters because the two
// token-gated capture routes resolve their origin differently — the harness
// route via `resolveHarnessOrigin()` (typically `localhost`), the preview-proxy
// route via `PROXY_CAPTURE_LOOPBACK` in handlers.rs, which is deliberately
// IPv4-pinned to `127.0.0.1` so it matches the forwarder's own pinning. Scoping
// the cookie to `localhost` alone therefore authenticated the harness route and
// left every `/__codeyam_preview` capture with no credential, so `preview-verify`
// / `preview-interact` / `preview-flow` all 401'd on a non-loopback bind.
// Emitting one cookie per alias is the fix: same token, same on-box editor,
// whichever name the capture URL happens to use.
const LOOPBACK_COOKIE_DOMAINS = ["localhost", "127.0.0.1"];

// Extract the host from an origin string, or null when it is unparseable.
function originHost(origin) {
  try {
    return new URL(origin).hostname;
  } catch (_) {
    return null;
  }
}

// Build the Playwright cookie array that authenticates the capture context to
// the editor's token-gated control-API. Reads the on-box `.codeyam/session-token`
// (0600) and emits a `cy_session` cookie for every host the capture might address
// the editor by (see `LOOPBACK_COOKIE_DOMAINS`); cookies are port-agnostic, so
// one per host covers the harness origin on the control port, the preview-proxy
// route, and any `/api` call on the app-proxy port. A non-loopback harness origin
// (a cloud tunnel domain) additionally gets its own host, since no loopback alias
// would match it. Returns `[]` — a no-op — when there is no token file (a
// loopback bind that never persisted one) or no resolvable harness origin, so a
// laptop capture is completely unaffected. `deps` is injectable so the builder is
// unit-testable without disk.
function buildSessionTokenCookies({
  readTokenFile = () => {
    const p = path.join(process.cwd(), ".codeyam", "session-token");
    return fs.existsSync(p) ? fs.readFileSync(p, "utf8").trim() : null;
  },
  harnessOrigin = resolveHarnessOrigin(),
} = {}) {
  try {
    const token = readTokenFile();
    if (!token || !harnessOrigin) return [];
    const host = originHost(harnessOrigin);
    const domains = [...LOOPBACK_COOKIE_DOMAINS];
    // A tunnelled/cloud harness origin is not a loopback alias, so it needs its
    // own entry or the harness navigation goes out uncredentialed.
    if (host && !domains.includes(host)) domains.push(host);
    return domains.map((domain) => ({
      name: SESSION_COOKIE,
      value: token,
      domain,
      path: "/",
      httpOnly: true,
      sameSite: "Lax",
    }));
  } catch (_) {
    // A missing/unreadable token file must never break capture on a loopback
    // bind where the token isn't required anyway — degrade to no cookie.
    return [];
  }
}

// True when a non-empty on-box `.codeyam/session-token` exists (the same
// 0600 file `buildSessionTokenCookies` reads). Used by the capability-skew
// guard to tell "no token, loopback bind, nothing to inject" (fine) apart from
// "a token exists but the capture produced no cookie" (a stale capture script
// heading into a guaranteed 401). Never throws — an unreadable file reports
// absent, degrading to today's behavior.
function onBoxSessionTokenExists() {
  try {
    const p = path.join(process.cwd(), ".codeyam", "session-token");
    return fs.existsSync(p) && fs.readFileSync(p, "utf8").trim().length > 0;
  } catch (_) {
    return false;
  }
}

// Pure predicate behind the capability-skew guard: true when the capture WILL
// use the token-gated harness route (an origin resolved) yet produced NO
// `cy_session` cookie despite an on-box token existing — the signature of a
// generated `.codeyam/capture.js` stale relative to the harness route, heading
// into a guaranteed 401. Separated from the throw so the decision is
// unit-testable without a browser context. Returns false the moment any leg is
// absent (loopback bind with no harness origin, no token, or a cookie was
// produced), so a healthy capture never trips it.
function captureAuthSkewDetected({ harnessOrigin, cookieCount, tokenExists }) {
  return Boolean(harnessOrigin) && cookieCount === 0 && Boolean(tokenExists);
}

const {
  getInitScript,
  handleConsoleMessage,
  handlePageError,
  handleRequestFailed,
} = require("./scenario-handlers");

const {
  waitForHydration,
} = require("./scenario-interactivity");

// Read project-specific loading markers from `.codeyam/stack.json`
// (`capture.loadingMarkers`). The capture script runs with cwd = project dir
// (scenario_check.rs sets `.current_dir(project_dir)`), so this relative path
// resolves to the project's own config. An app's loading copy ("Loading…",
// "Please wait") is app-specific, so it lives in stack.json rather than being
// hardcoded into the shared harness; the codeyam-harness defaults in
// scenario-metrics.js always apply on top. Never throws — a missing or
// malformed stack.json just yields no extra markers.
function readStackLoadingMarkers() {
  try {
    const raw = fs.readFileSync(path.join(".codeyam", "stack.json"), "utf8");
    const stack = JSON.parse(raw);
    const markers = stack && stack.capture && stack.capture.loadingMarkers;
    return Array.isArray(markers)
      ? markers.filter((m) => typeof m === "string" && m.length > 0)
      : [];
  } catch (_) {
    return [];
  }
}

// True when the scenario being captured scripts a `/ws/terminal` transcript or
// a WebSocket stream. Such captures need the REAL `WebSocket` so the server can
// replay the scripted agent state into the frame — `getInitScript` keeps its
// reconnect-silencing stub OFF for them (see the comment there). Read from the
// scenario file by slug (`config.scenarioId`), the same cwd-relative path
// `readStackLoadingMarkers` uses. Defaults to `false` (stub stays on, today's
// behavior) for the scenario-less CLI preview path or any unreadable/parse
// failure, so a missing file never accidentally un-stubs a live terminal.
function scenarioScriptsLiveSocket(config) {
  const slug = config && config.scenarioId;
  if (!slug) return false;
  try {
    const raw = fs.readFileSync(
      path.join(".codeyam", "scenarios", `${slug}.json`),
      "utf8",
    );
    const mocks = (JSON.parse(raw) || {}).mocks || {};
    const transcripts = mocks.transcripts || {};
    const streams = mocks.streams || {};
    return Object.keys(transcripts).length > 0 || Object.keys(streams).length > 0;
  } catch (_) {
    return false;
  }
}

// Classify what a driven interaction actually did, from the DOM fingerprint on
// either side of it plus the page's hydration state. Pure, so the distinction
// this encodes is unit-tested without a browser.
//
// A click that changed nothing has two very different causes, and reporting both
// as "none" is what let a dead page masquerade as a flaky harness: a page that
// NEVER HYDRATED could not have responded to ANY interaction (no client JS is
// running), whereas a hydrated page with an unchanged DOM really does mean the
// control is inert. Keeping them apart is what tells a reader whether to go look
// at their component or at the environment.
//
// `hydrated` is the three-valued signal from `waitForHydration`: only a PROVEN
// dead page (`false`) earns "unhydrated". `null` means the wait could not judge
// (unknown framework, no controls, probe threw) and must keep reporting "none" —
// never invent a hydration fault we cannot prove.
function classifyInteractionEffect(beforeFingerprint, afterFingerprint, hydrated) {
  if (beforeFingerprint !== afterFingerprint) return "changed";
  if (hydrated === false) return "unhydrated";
  return "none";
}

async function getDOMFingerprint(frame) {
  try {
    return await frame.evaluate(() => {
      const body = document.body;
      if (!body) return "";
      const html = body.innerHTML;
      let hash = 0;
      for (let i = 0; i < html.length; i++) {
        hash = (hash << 5) - hash + html.charCodeAt(i);
        hash |= 0;
      }
      return `${html.length}-${hash}`;
    });
  } catch (err) {
    return "";
  }
}

// Cold-start retry pause. waitForStablePage settles as soon as the page is
// HTML-stable, which for a lazy/Suspense app is the empty `<div id="root">`
// shell — stable for the ~3s the dynamic chunk takes to load (longer when the
// scenario's mocks slow the boot). 500ms re-checked before the chunk resolved
// and reported a false blank; this pause must comfortably exceed that window
// while staying under the test runner's default per-case timeout.
const BLANK_RETRY_DELAY_MS = 3000;

// Pause after scrolling the document to trip scroll-gated reveal observers, so
// the IntersectionObserver callbacks fire and any opacity/transform entrance
// transition begins before we measure visible content and screenshot. Driven
// through `page.waitForTimeout` so it is a real wait in Playwright but instant
// against the stubbed pages in unit tests.
const REVEAL_SETTLE_MS = 600;

// Measure the frame's visible (painted, non-opacity:0) text and fold it into
// the content state in place, so the blank gate can distinguish "text rendered
// but invisible" from a populated frame. Best-effort: a frame/target that
// cannot be measured (a stubbed test target returns a non-number, an evaluate
// throws) leaves the state untouched, so `hasRenderableContent` falls back to
// its DOM-presence behavior rather than treating an un-measurable frame as
// blank.
async function mergeVisibleTextLength(contentState, frame) {
  if (!contentState) return;
  let visible;
  try {
    visible = await collectVisibleTextLength(frame);
  } catch (_) {
    return;
  }
  if (typeof visible === "number") {
    contentState.visibleTextLength = visible;
  }
}

// True when `url` targets a different origin than `appOrigin`. Used to decide
// whether the codeyam capture markers must be stripped before the request
// leaves (cross-origin) or may ride along (same-origin, the app's own dev
// server). A malformed URL counts as same-origin (false) so we never strip
// markers from a request we can't classify — the conservative default keeps
// same-origin behavior unchanged. `url` may be a string or a URL-like object.
function isCrossOriginRequest(url, appOrigin) {
  try {
    const href = typeof url === "string" ? url : url.href;
    return new URL(href).origin !== appOrigin;
  } catch (_) {
    return false;
  }
}

// Decide whether a failed request should fail the capture. Only a failure
// targeting the captured page's OWN origin counts — a first-party route that
// 500s or a same-origin asset that 404s is a real capture problem. A
// cross-origin failure (the mocked app's dev port being down, an external
// CDN/API) is an external resource and is tolerated, so the editor-shell
// screenshot still succeeds. Mirrors the console handler's tolerance for
// declared error-mock URLs. When `appOrigin` is unknown (malformed capture
// URL) the failure stays fatal — the conservative default preserves today's
// behavior rather than silently swallowing every failure. Pure, so the
// decision is unit-testable without a live browser.
function isCaptureFatalRequestFailure(url, appOrigin) {
  if (!appOrigin) return true;
  return !isCrossOriginRequest(url, appOrigin);
}

// Return a copy of `headers` with every name in `markerNames` removed.
// Names are matched case-insensitively against the (lowercased) header keys
// Playwright reports. Pure — never mutates its input — so unrelated headers
// (Accept, User-Agent, a scenario's own requestHeaders) survive untouched.
function stripMarkerHeaders(headers, markerNames) {
  const out = { ...headers };
  for (const name of markerNames) {
    delete out[name.toLowerCase()];
  }
  return out;
}

// Apply the scenario's merged `browserState` to a Playwright context and
// stamp the codeyam capture markers on every request the context makes.
//
// Cookies need a concrete URL to bind to (Playwright requires either
// `url` or `domain`+`path`); we derive domain/path from the requested
// capture URL when the scenario didn't pin them. Request headers go
// through `setExtraHTTPHeaders` so every navigation and resource
// request in the context carries them.
//
// Every capture-originated request carries `X-Codeyam-Capture: 1` (and
// `X-Codeyam-Scenario: <slug>` when a scenario is active) so a dev-server
// log can tell the headless capture apart from the operator's own browser
// hitting the same route — they are otherwise indistinguishable. These are
// defaults: a scenario's own `requestHeaders` are merged on top and win,
// so a user can override or clear them.
async function applyBrowserState(context, config) {
  const state = (config && config.browserState) || {};
  const cookies = state.cookies || {};
  const cookieEntries = Object.entries(cookies);
  if (cookieEntries.length > 0) {
    let host = "127.0.0.1";
    try {
      host = new URL(config.url).hostname || host;
    } catch (_) {
      /* fall back to localhost if config.url is malformed */
    }
    const playwrightCookies = cookieEntries.map(([name, raw]) => {
      const descriptor =
        raw && typeof raw === "object" && !Array.isArray(raw) ? raw : {};
      const value = typeof raw === "string" ? raw : descriptor.value || "";
      return {
        name,
        value,
        domain: descriptor.domain || host,
        path: descriptor.path || "/",
        sameSite: descriptor.sameSite || "Lax",
        httpOnly: descriptor.httpOnly === true,
        secure: descriptor.secure === true,
      };
    });
    await context.addCookies(playwrightCookies);
  }
  const codeyamHeaders = {
    "X-Codeyam-Capture": "1",
    ...(config && config.scenarioId
      ? { "X-Codeyam-Scenario": config.scenarioId }
      : {}),
  };
  // Scenario `requestHeaders` are merged last so a user value overrides
  // the codeyam default (e.g. setting `X-Codeyam-Capture: "0"` as an
  // escape hatch). `codeyamHeaders` always has at least the capture marker,
  // so this fires on every capture — including ones with no browserState.
  const headers = { ...codeyamHeaders, ...(state.requestHeaders || {}) };
  if (Object.keys(headers).length > 0) {
    await context.setExtraHTTPHeaders(headers);
  }

  // Strip the codeyam capture markers (and any scenario request headers) from
  // CROSS-ORIGIN requests. setExtraHTTPHeaders applies context-wide, so the
  // custom `X-Codeyam-*` headers ride along on third-party subresource
  // requests (Google Fonts, CDNs, external APIs) too — and a non-safelisted
  // request header forces a CORS preflight those hosts reject
  // (`Request header field x-codeyam-capture is not allowed`), which fails the
  // whole capture. The markers are only meaningful to the app's OWN dev server
  // (same-origin), so re-send cross-origin requests without them. Same-origin
  // requests are never matched here, so dev-module/HMR loading is untouched.
  let appOrigin = null;
  try {
    appOrigin = new URL(config.url).origin;
  } catch (_) {
    /* malformed capture URL — skip the cross-origin guard entirely */
  }
  if (appOrigin && typeof context.route === "function") {
    // Only the codeyam markers are stripped — a scenario's own requestHeaders
    // are the author's deliberate choice and left intact.
    const markerNames = Object.keys(codeyamHeaders);
    await context.route(
      (url) => isCrossOriginRequest(url, appOrigin),
      async (route) => {
        const reqHeaders = stripMarkerHeaders(route.request().headers(), markerNames);
        await route.continue({ headers: reqHeaders });
      },
    );
  }

  // Seed the scenario's `browserState.localStorage` / `.sessionStorage` into
  // the page before any app JS runs. Storage-gated UI (first-run banners,
  // dismissed-prompt flags, persisted view state) is otherwise
  // uncontrollable at capture time. Playwright serializes the function and
  // its arg into the page context, so the function body must not close over
  // outer variables. Only registered when the scenario actually carries
  // storage, preserving the pre-storage capture context for everyone else.
  const localStorageSeed = state.localStorage || {};
  const sessionStorageSeed = state.sessionStorage || {};
  if (
    Object.keys(localStorageSeed).length > 0 ||
    Object.keys(sessionStorageSeed).length > 0
  ) {
    await context.addInitScript(
      (storage) => {
        try {
          for (const [key, value] of Object.entries(storage.local)) {
            window.localStorage.setItem(key, value);
          }
          for (const [key, value] of Object.entries(storage.session)) {
            window.sessionStorage.setItem(key, value);
          }
        } catch (_) {
          // Storage unavailable (sandboxed/opaque origin) — the seed is
          // best-effort; never fail the capture over it.
        }
      },
      { local: localStorageSeed, session: sessionStorageSeed },
    );
  }
}

// Emit a `redirect-mismatch` issue when the final iframe URL's path
// differs from the requested path. This converts the silent
// screenshot-of-/login failure (auth lost in the capture context) into
// a typed, actionable diagnostic the agent can route to.
function pushRedirectMismatchIssue(issues, requestedUrl, frame, response, config) {
  let requestedPath;
  try {
    requestedPath = new URL(requestedUrl).pathname;
  } catch (_) {
    return;
  }
  const finalUrl = (frame && frame.url && frame.url()) || requestedUrl;
  let finalPath;
  try {
    finalPath = new URL(finalUrl).pathname;
  } catch (_) {
    return;
  }
  if (requestedPath === finalPath) return;
  const cookies =
    (config && config.browserState && config.browserState.cookies) || {};
  const hasCookies = Object.keys(cookies).length > 0;
  const hint = hasCookies
    ? " — scenario carries browserState.cookies; auth likely lost in the capture context (run `codeyam-editor editor scenario-explain <slug>` to verify)"
    : "";
  pushIssue(
    issues,
    createIssue(
      "redirect-mismatch",
      `Capture URL redirected from ${requestedPath} to ${finalPath}${hint}`,
      {
        url: finalUrl,
        status: response && response.status ? response.status() : null,
      },
    ),
  );
}

// Read-only page-state snapshot for `capture-state`: the full localStorage
// map, a bounded sample of visible text nodes (document order), and — when a
// selector is given — that element's text. Evaluated in-page against the
// settled frame so it reflects exactly what a real capture saw (the proxy
// already injected the scenario's seed into the served HTML). Every read is
// individually guarded so a sandboxed/cross-origin localStorage never throws
// the whole capture; the worst case is an empty section, not a failure.
async function dumpPageState(frame, selector) {
  return frame.evaluate((sel) => {
    const localStorage = {};
    try {
      for (let i = 0; i < window.localStorage.length; i++) {
        const key = window.localStorage.key(i);
        if (key != null) localStorage[key] = window.localStorage.getItem(key);
      }
    } catch (_) {
      /* localStorage may be unavailable (sandboxed/opaque origin) */
    }

    const visibleText = [];
    try {
      // Reject text inside non-rendered tags (SCRIPT/STYLE/etc.) so an
      // injected proxy script or inline CSS never masquerades as on-screen
      // text — that noise is exactly what makes a state dump misleading.
      const SKIP_TAGS = new Set([
        "SCRIPT",
        "STYLE",
        "NOSCRIPT",
        "TEMPLATE",
        "HEAD",
        "TITLE",
      ]);
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        {
          acceptNode(node) {
            const parent = node.parentElement;
            if (parent && SKIP_TAGS.has(parent.tagName)) {
              return NodeFilter.FILTER_REJECT;
            }
            return (node.textContent || "").trim()
              ? NodeFilter.FILTER_ACCEPT
              : NodeFilter.FILTER_REJECT;
          },
        },
      );
      let node;
      while ((node = walker.nextNode()) && visibleText.length < 40) {
        const text = (node.textContent || "").replace(/\s+/g, " ").trim();
        if (text) visibleText.push(text);
      }
    } catch (_) {
      /* no body / detached document */
    }

    let selectorText = null;
    if (sel) {
      try {
        const el = document.querySelector(sel);
        if (el) selectorText = (el.textContent || "").replace(/\s+/g, " ").trim();
      } catch (_) {
        /* invalid selector — leave selectorText null */
      }
    }

    return { localStorage, visibleText, selectorText };
  }, selector || null);
}

// Landed-state verification: assert the localStorage the capture INJECTED
// (`config.browserState.localStorage`, which already carries the seed-session
// overlay the editor merged in) actually reached the capture browser after the
// page settled. The core promise of a seeded scenario is remote control of the
// app — a seed that silently doesn't land produces an empty screenshot that
// looks like a successful capture of an empty app, which is exactly the
// failure this guards. Returns a loud `seed-not-landed` issue (which fails the
// capture, since `ok` requires zero issues) when a non-empty injected seed is
// missing/empty on read-back, or `null` when there was nothing to verify, the
// seed landed, or storage is unavailable (sandboxed/opaque origin — never fail
// the capture over the verifier itself).
async function verifySeededStorageLanded(frame, config) {
  const expected =
    (config && config.browserState && config.browserState.localStorage) || {};
  const expectedKeys = Object.keys(expected);
  if (expectedKeys.length === 0) return null; // nothing was seeded into storage

  let readback;
  try {
    readback = await frame.evaluate((keys) => {
      try {
        const allKeys = [];
        for (let i = 0; i < window.localStorage.length; i++) {
          const k = window.localStorage.key(i);
          if (k != null) allKeys.push(k);
        }
        const present = {};
        for (const k of keys) {
          const v = window.localStorage.getItem(k);
          present[k] = v != null && v !== "";
        }
        return { present, allKeys };
      } catch (_) {
        // localStorage unavailable (sandboxed/opaque origin) — can't verify.
        return null;
      }
    }, expectedKeys);
  } catch (_) {
    return null; // evaluate failed — never fail a capture over the verifier.
  }
  if (!readback) return null; // storage unavailable — best-effort, don't fail.

  const missing = expectedKeys.filter((k) => !readback.present[k]);
  if (missing.length === 0) return null; // every seeded key landed — success.

  const actual = readback.allKeys.length ? readback.allKeys.join(", ") : "<none>";
  return createIssue(
    "seed-not-landed",
    `Seeded localStorage did not reach the capture browser: expected non-empty ` +
      `keys [${expectedKeys.join(", ")}] but [${missing.join(", ")}] are ` +
      `missing/empty after load (browser localStorage holds: [${actual}]). The ` +
      `seed did NOT land, so this screenshot shows DEFAULT/EMPTY state — fix the ` +
      `seed; do not delete the scenario. Likely causes: (1) the seed-session ` +
      `overlay was stale or empty (re-run the seed adapter to refresh it), (2) the ` +
      `adapter's stdout localStorage map failed to parse, or (3) the injection ` +
      `path is down (the seeded origin differs from the captured page's origin).`,
    { url: (frame && frame.url && frame.url()) || (config && config.url) },
  );
}

// Drive an ordered list of flow steps against ONE already-loaded browser
// session so a scripted multi-step demo (`editor preview-flow`) is captured as
// the real round-trip — click state and client transients persist across
// steps, which N independent fresh-load captures could never reproduce. Each
// step is one of:
//   - navigate: re-load a route (resolved relative to the initial url) using
//     the same loader strategy as the initial load, then re-settle. Returns
//     the new content frame so subsequent steps target the navigated page.
//   - click / fill / press: a `performInteraction` against the current frame,
//     then re-settle.
//   - waitFor: hold until a visible-text / selector predicate (bounded).
//   - capture: write a numbered filmstrip frame to the step's `outputPath`.
// A failing step THROWS with its 1-based index and action, so the outer catch
// in `runScenarioCheck` reports exactly which step broke (and, for waitFor,
// the predicate that never appeared) instead of a silent blank capture.
// Returns the frame the flow ended on, so the caller's final screenshot and
// result URL reflect the last navigated route.
async function runFlowSteps(page, initialFrame, steps, ctx) {
  const {
    url,
    loadingMarkers,
    navigation,
    iframeBackground,
    preflight,
    harnessOrigin,
    hydrationTimeoutMs = 10000,
    settleMs,
  } = ctx;
  // Honor a caller-supplied `settleMs` for the in-flow stability windows,
  // falling back to today's hardcoded defaults (5s for interaction steps, 10s
  // for a navigate). This stops the field from being silently dropped — the
  // exact trap that made a reporter's `settleMs: 8000` a no-op.
  const navigateSettleMs =
    typeof settleMs === "number" && settleMs > 0 ? settleMs : 10000;
  const interactionSettleMs =
    typeof settleMs === "number" && settleMs > 0 ? settleMs : 5000;
  let frame = initialFrame;

  for (let i = 0; i < steps.length; i++) {
    const step = steps[i] || {};
    const n = i + 1;
    try {
      switch (step.action) {
        case "navigate": {
          const target = new URL(step.path, url).href;
          const loadResult =
            navigation === "topLevel"
              ? await loadScenarioTopLevel(page, target, { preflight })
              : await loadScenarioInIframe(page, target, {
                  background: iframeBackground,
                  preflight,
                  harnessOrigin,
                });
          frame = loadResult.frame;
          await waitForStablePage(page, frame, navigateSettleMs, loadingMarkers);
          // A navigate loads a fresh route that must re-hydrate before the next
          // fill/click, or the interaction lands on inert SSR markup (the same
          // bug the top-level wait fixes, one route deeper). Bounded and
          // stack-gated exactly like the top-level wait.
          await waitForHydration(frame, {
            url: target,
            timeoutMs: hydrationTimeoutMs,
          });
          break;
        }
        case "click":
        case "fill":
        case "press":
          await performInteraction(frame, step);
          await waitForStablePage(page, frame, interactionSettleMs, loadingMarkers);
          break;
        case "waitFor":
          await waitForPredicate(frame, step);
          break;
        case "capture":
          if (step.outputPath) {
            fs.mkdirSync(path.dirname(step.outputPath), { recursive: true });
            await page.screenshot({ path: step.outputPath, fullPage: false });
          }
          break;
        default:
          throw new Error(
            `unknown step action "${step.action}" (expected navigate | click | fill | press | waitFor | capture)`,
          );
      }
    } catch (error) {
      throw new Error(
        `flow step ${n} (${step.action}) failed: ${error.message || String(error)}`,
      );
    }
  }

  return frame;
}

// `preflight` is injectable (defaulting to the real app-port reachability
// check) so unit tests that mock the browser can stay network-free.
// `harnessOrigin` is likewise injectable: it defaults to resolving the editor's
// harness origin from `.codeyam/server-state.json`, but a test passes an
// explicit value (e.g. `null` to force the legacy `setContent` harness) so the
// iframe-load path never silently depends on a server-state file in cwd.
// Resolved ONCE here and threaded into every iframe load below.
async function runScenarioCheck(
  config,
  { preflight = assertAppPortReachable, harnessOrigin } = {},
) {
  const { url, outputPath, width, height, httpMocks = {} } = config;
  // The harness host mirrors the capture target's host so the framed load stays
  // SAME-SITE — see `resolveHarnessOrigin`. A cross-site frame withholds the
  // SameSite=Lax `cy_session` cookie and every token-gated route 401s.
  const resolvedHarnessOrigin =
    harnessOrigin !== undefined
      ? harnessOrigin
      : resolveHarnessOrigin({ targetUrl: url });
  // Per-scenario capture-check allowances (see `CaptureAllowances` /
  // `ScenarioDefinition` on the Rust side). Default false so the guards keep
  // their strict behavior for every scenario that does not opt in.
  const allowMinimalRender = !!(config && config.allowMinimalRender);
  const expectedConsoleErrors = !!(config && config.expectedConsoleErrors);
  let interactionEffect = null;
  let interactionRetried = false;
  // Non-fatal warnings raised while resolving interaction/flow targets — e.g. a
  // substring text match that hit more than one element. Surfaced on the result
  // so the agent sees the ambiguity instead of a silently-wrong first-match.
  const interactionWarnings = [];
  const issues = [];
  // Actionable set for self-healing: same-origin routes that returned 4xx with
  // no scenario mock. A hermetic-proxy/upstream 404 is a *successful* HTTP
  // response with status 404 (not a Playwright `requestfailed`), so the only
  // place with method + path + status together is the `page.on("response")`
  // collector below. De-duped by `"<METHOD> <path>"`; surfaced through
  // `buildResult` so the Rust failure message can name each unmocked route and
  // `stub-unmocked-routes` can add stub mocks for them.
  const unmockedRoutes = [];
  const unmockedRouteKeys = new Set();
  // Origin of the captured page, used to classify failed requests: only a
  // failure on the page's OWN origin should fail the capture (see
  // `isCaptureFatalRequestFailure`). Derived from `config.url` exactly as
  // `applyBrowserState` does; a malformed URL leaves it null, which keeps every
  // request failure fatal (today's behavior).
  let appOrigin = null;
  try {
    appOrigin = new URL(url).origin;
  } catch (_) {
    /* malformed capture URL — the guard no-ops and failures stay fatal */
  }
  const browser = await launchChromiumWithSelfHeal();
  const contextOptions = {
    viewport: { width: width || 1440, height: height || 900 },
  };
  if (config.colorScheme) contextOptions.colorScheme = config.colorScheme;
  if (config.deviceScaleFactor)
    contextOptions.deviceScaleFactor = config.deviceScaleFactor;
  if (config.userAgent) contextOptions.userAgent = config.userAgent;
  if (config.locale) contextOptions.locale = config.locale;
  if (config.timezoneId) contextOptions.timezoneId = config.timezoneId;
  if (config.reduceMotion) contextOptions.reducedMotion = config.reduceMotion;
  if (config.forcedColors) contextOptions.forcedColors = config.forcedColors;
  // When the opt-in HTTPS preview (`proxy.httpsPreview`) is on, the capture
  // origin is `https://localhost:<port>` served by the reverse proxy's
  // self-signed cert. Accept it for capture only — gated on the https origin so
  // plain-HTTP captures keep full TLS-error fidelity.
  if (typeof appOrigin === "string" && appOrigin.startsWith("https://")) {
    contextOptions.ignoreHTTPSErrors = true;
  }
  const context = await browser.newContext(contextOptions);

  // Authenticate the capture context to the editor's token-gated control-API
  // BEFORE any navigation. On a non-loopback bind the harness route requires the
  // session token; the browser UI carries it as a cookie automatically but the
  // headless capturer does not, so inject it from the on-box token file. Scoped
  // to the SAME resolved harness origin the capture navigates to: when no harness
  // origin resolves (missing server-state, or a test that passes
  // `harnessOrigin: null`) there is nothing to authenticate to, so no cookie is
  // added. The `addCookies` guard keeps a mock context that doesn't implement it
  // from throwing (a real Playwright context always has it).
  const sessionCookies = buildSessionTokenCookies({
    harnessOrigin: resolvedHarnessOrigin,
  });
  // Capability-skew guard. When the capture WILL use the token-gated harness
  // route (a harness origin resolved) AND an on-box session token exists, but no
  // `cy_session` cookie was produced, the token injection is broken — the
  // generated `.codeyam/capture.js` is stale relative to the harness route it
  // must authenticate to. Proceeding would hit a guaranteed 401 and strand every
  // component capture on a `#scenario-frame` timeout. Fail loudly at the source
  // instead, naming the version skew and its fix — closing the gap between the
  // harness route (present) and the capture-side auth (absent).
  if (
    captureAuthSkewDetected({
      harnessOrigin: resolvedHarnessOrigin,
      cookieCount: sessionCookies.length,
      tokenExists: onBoxSessionTokenExists(),
    })
  ) {
    throw new Error(
      `The capture harness origin ${resolvedHarnessOrigin} is token-gated and an ` +
        `on-box \`.codeyam/session-token\` exists, but the capture produced no ` +
        `\`cy_session\` cookie — the generated \`.codeyam/capture.js\` is stale ` +
        `relative to the harness route (its session-token injection is missing or ` +
        `broken). Regenerate the capture script / refresh the editor binary on this VM.`,
    );
  }
  if (sessionCookies.length > 0 && typeof context.addCookies === "function") {
    await context.addCookies(sessionCookies);
  }

  // Apply the scenario's merged `browserState` (cookies + request
  // headers) to the capture context BEFORE the first navigation.
  // Belt-and-suspenders with the proxy's `Set-Cookie` injection: the
  // proxy handles upstream-bound forwards, this branch handles the
  // capture context's own request headers so an auth-gated route does
  // not redirect to `/login` when the proxy is bypassed.
  await applyBrowserState(context, config);

  // Context-level init script runs in ALL frames (including cross-origin iframes).
  // Keep the real WebSocket for scenarios that script a `/ws/terminal`
  // transcript / WS stream so the scripted agent state reaches the capture;
  // every other capture gets the reconnect-silencing stub.
  await context.addInitScript(getInitScript(scenarioScriptsLiveSocket(config)));

  const page = await context.newPage();
  // Attach the network tracker BEFORE navigation so every request (the document
  // and every client-side data fetch) is counted. Used after DOM stability to
  // wait out an in-flight fetch that would otherwise be screenshotted as a
  // loading skeleton.
  const networkTracker = createNetworkTracker(page);
  await attachHttpMocks(page, httpMocks);

  page.on("pageerror", (error) => {
    pushIssue(issues, handlePageError(error));
  });

  page.on("console", (message) => {
    const issue = handleConsoleMessage(message);
    if (!issue) return;
    // Per-scenario allowance: a scenario that provokes console errors by design
    // (a broken-image fallback whose `<img>` is meant to 404) opts in via
    // `expectedConsoleErrors`. Load-bearing: without it the console-error guard
    // fails the capture instead of screenshotting the intended fallback UI. A
    // non-opted-in scenario still fails, so an unexpected console error is never
    // silently tolerated.
    if (expectedConsoleErrors) return;
    // Console errors produced by the scenario's OWN declared error mocks
    // (status >= 400) are the intended behavior of an error-state scenario,
    // not a capture problem — skip them so "History - Load Error"-style
    // scenarios can screenshot the failure UI they exist to demonstrate.
    const sourceUrl = message.location && message.location().url;
    if (sourceUrl && isDeclaredErrorMock(httpMocks, sourceUrl)) return;
    // A console error originating from a cross-origin resource — the "Failed to
    // load resource" Chromium logs alongside a cross-origin requestfailed (the
    // down app dev port, an external CDN) — is an external-resource failure, not
    // an editor-shell problem. Tolerate it for the same reason, and via the same
    // predicate, as the requestfailed handler below.
    if (sourceUrl && !isCaptureFatalRequestFailure(sourceUrl, appOrigin)) return;
    pushIssue(issues, issue);
  });

  page.on("response", (response) => {
    // Collect same-origin 4xx responses that no scenario mock covers — the set
    // a stub mock would fix. Mirrors the console-guard predicates exactly so the
    // reported set matches the guard's tolerances: a scenario that provokes
    // errors by design (`expectedConsoleErrors`) reports none, and a route the
    // scenario already declares an error mock for is the mock's intended 4xx,
    // not a missing mock.
    if (expectedConsoleErrors) return;
    const req = response.request();
    const reqUrl = req.url();
    // Same-origin only — mirror the console/requestfailed origin gate so a
    // cross-origin sub-resource 4xx is never reported as an unmocked route.
    if (!isCaptureFatalRequestFailure(reqUrl, appOrigin)) return;
    // The status-threshold, declared-mock, and path-extraction decision is the
    // pure `unmockedRouteFrom` helper; the listener keeps only the stateful
    // same-origin gate above and the dedup below.
    const route = unmockedRouteFrom(req.method(), reqUrl, response.status(), httpMocks);
    if (!route) return;
    const key = `${route.method} ${route.path}`;
    if (unmockedRouteKeys.has(key)) return;
    unmockedRouteKeys.add(key);
    unmockedRoutes.push(route);
  });

  page.on("requestfailed", (request) => {
    // Per-scenario allowance: the broken-image fallback scenario's `<img>` 404
    // is a SAME-origin request failure it exists to demonstrate, so
    // `expectedConsoleErrors` tolerates it here too (the console guard above
    // relaxes the paired "Failed to load resource" error). Load-bearing for the
    // same reason; a non-opted-in same-origin failure still fails the capture.
    if (expectedConsoleErrors) return;
    // A cross-origin sub-resource failing must not fail an editor-shell
    // screenshot — only the captured page's OWN origin counts. The most common
    // case here is the live preview pane reaching the mocked project's app dev
    // port (e.g. http://localhost:3000), which is not running in the
    // self-hosting capture container.
    if (!isCaptureFatalRequestFailure(request.url(), appOrigin)) return;
    const issue = handleRequestFailed(request);
    if (issue) {
      pushIssue(issues, issue);
    }
  });

  let loaded = false;

  try {
    // Application/route captures navigate at the top level so the
    // first-party session cookie is sent (auth-gated routes render the
    // authenticated page instead of /login); component captures keep the
    // iframe harness for its background/sizing control. The backend signals
    // the choice via `config.navigation` ("topLevel"); absent (the default)
    // means the iframe harness, so existing callers are unchanged.
    const loadResult =
      config.navigation === "topLevel"
        ? await loadScenarioTopLevel(page, url, { preflight })
        : await loadScenarioInIframe(page, url, {
            background: config.iframeBackground,
            preflight,
            harnessOrigin: resolvedHarnessOrigin,
          });
    // `frame` is `let` so a `navigate` flow step (below) can re-point it at the
    // freshly-loaded route's content frame; `response` is the initial load only.
    let frame = loadResult.frame;
    const response = loadResult.response;
    loaded = true;

    if (response && response.status() >= 400) {
      pushIssue(
        issues,
        createIssue("navigation", `Navigation returned HTTP ${response.status()}`, {
          url: response.url(),
          status: response.status(),
        }),
      );
    } else if (!response && config.navigation === "topLevel") {
      // A real top-level document load always yields a response. A null one
      // means the status could never be checked — and an unverified status is
      // not a passing status: a 500 whose error body renders text would
      // otherwise satisfy `hasContent` and pass as `ok`. Fail loudly instead.
      // The iframe path stays tolerant: there the app response is matched by
      // exact URL and is legitimately allowed to miss.
      pushIssue(
        issues,
        createIssue(
          "navigation",
          "Navigation response unavailable — could not verify the HTTP status of the top-level document",
          { url },
        ),
      );
    }

    pushRedirectMismatchIssue(issues, url, frame, response, config);

    // Project loading markers come from config when a caller injects them
    // (unit tests), otherwise from stack.json — so a stable-but-loading app
    // screen is not mistaken for settled content and captured mid-hydration.
    const loadingMarkers = Array.isArray(config.loadingMarkers)
      ? config.loadingMarkers
      : readStackLoadingMarkers();
    // Content-stability window. Defaults to 10s; the editor's own WS-driven
    // terminal/build route under self-hosting passes a longer `stableTimeoutMs`
    // (its network never goes idle, so the default expired before the WS replay
    // landed and the capture came back blank — VM1). Every other route omits the
    // field and keeps the 10s default.
    const stableTimeoutMs =
      typeof config.stableTimeoutMs === "number" && config.stableTimeoutMs > 0
        ? config.stableTimeoutMs
        : 10000;
    // Hydration wait cap. Mirrors `stableTimeoutMs`: defaults to 10s, but a slow
    // Turbopack cold-compile route can extend it via `config.hydrationTimeoutMs`
    // without a code change. Bounded and near-zero on a healthy page (attaches in
    // a poll or two); only a genuinely dead page pays the full cap.
    const hydrationTimeoutMs =
      typeof config.hydrationTimeoutMs === "number" &&
      config.hydrationTimeoutMs > 0
        ? config.hydrationTimeoutMs
        : 10000;
    const stableOutcome = await waitForStablePage(
      page,
      frame,
      stableTimeoutMs,
      loadingMarkers,
    );

    // DOM-stable does not mean done: a client-side data fetch can still be in
    // flight (the loading skeleton cleared but its replacement content hasn't
    // landed). Wait for the network to go quiet — bounded, so a streaming /
    // long-poll endpoint that never idles caps out and captures anyway rather
    // than hanging.
    const networkOutcome = await waitForNetworkQuiet(networkTracker);

    // If the page never settled (a loading marker outlasted the wait) or the
    // network never went quiet, the screenshot likely caught a client-fetched
    // page mid-load. Compute the non-blocking advisory now, while both settle
    // signals are in hand, and surface it on the capture-state report below.
    const settleAdvisory = buildSettleAdvisory(stableOutcome, networkOutcome);

    const rejectionMessages = await frame.evaluate(
      () => window.__codeyamUnhandledRejections || [],
    );
    for (const message of rejectionMessages) {
      pushIssue(
        issues,
        createIssue("unhandledrejection", message, {
          url: page.url() || url,
        }),
      );
    }

    // Reveal-suppression fix: scroll-gated entrance animations (content held at
    // `opacity:0` until an IntersectionObserver fires on scroll) render blank in
    // isolation, where the app shell that wires those observers is absent.
    // Emulate reduced motion — so reduced-motion-aware stylesheets drop their
    // entrance animations and render the final state — and scroll the document
    // end-to-end to trip every observer, so the content reveals BEFORE we
    // measure and screenshot it, with no per-project force-reveal script. Both
    // are best-effort: a page/frame that cannot emulate or scroll (a
    // backend/static capture, a stubbed test target) is a no-op.
    if (typeof page.emulateMedia === "function") {
      await page.emulateMedia({ reducedMotion: "reduce" }).catch(() => {});
    }
    await scrollThroughDocument(frame).catch(() => {});
    if (typeof page.waitForTimeout === "function") {
      await page.waitForTimeout(REVEAL_SETTLE_MS);
    }

    // Cold-start retry: a single re-collect after BLANK_RETRY_DELAY_MS covers
    // the React.lazy / Suspense-fallback race where waitForStablePage settles
    // on the still-empty `<div id="root">` shell before the dynamic chunk
    // resolves. One retry is enough — the pause is sized to outlast the
    // chunk-load window; only a genuinely blank page falls through to the
    // blank issue below.
    let contentState = await collectContentState(frame);
    await mergeVisibleTextLength(contentState, frame);
    let hasContent = hasRenderableContent(contentState);
    if (!hasContent) {
      await new Promise((r) => setTimeout(r, BLANK_RETRY_DELAY_MS));
      contentState = await collectContentState(frame);
      await mergeVisibleTextLength(contentState, frame);
      hasContent = hasRenderableContent(contentState);
    }

    // Per-scenario allowance: a scenario whose intended UI is intrinsically
    // minimal (an empty `<textarea>` the blank heuristic can't "see") opts in
    // via `allowMinimalRender`. Accept the near-blank render as valid content so
    // BOTH the blank issue below is skipped AND `buildResult`'s `ok` (which
    // independently requires `hasContent`) can be true — otherwise the capture
    // would still fail with an empty issue list. The cold-start retry already
    // ran above, so a non-opted-in blank (a genuinely empty render) still falls
    // through to the issue below.
    if (!hasContent && allowMinimalRender) {
      hasContent = true;
    }

    if (!hasContent) {
      pushIssue(
        issues,
        createIssue(
          "blank",
          `Page rendered no visible content (${describeBlankReason(contentState)})`,
          { url: page.url() || url },
        ),
      );
    }

    // Check for codeyam's scenario-renderer error fallback. We anchor on the
    // DOM marker the ScenarioRenderer stamps on its error / seed-error frames
    // rather than scanning the whole page body for ERROR_PATTERNS — a
    // legitimately-mocked scenario whose content quotes one of those harness
    // phrases must not be flagged. Apps with no codeyam ScenarioRenderer never
    // emit the marker, so their pages are treated as healthy regardless of body
    // text. The scan is scoped to the marked element's own text.
    const errorMarker = await frame.evaluate((attr) => {
      const el = document.querySelector(`[${attr}]`);
      if (!el) return null;
      return {
        reason: el.getAttribute(attr) || "",
        text: el.innerText || el.textContent || "",
      };
    }, SCENARIO_ERROR_MARKER);
    const scenarioError = findScenarioError(errorMarker);
    if (scenarioError) {
      const { matchedPattern, contextSnippet } = scenarioError;
      pushIssue(
        issues,
        createIssue(
          "error-state",
          `Page contains error content (matched "${matchedPattern}"): ${contextSnippet ?? ""}`,
          {
            url: page.url() || url,
            matchedPattern,
            contextSnippet,
          },
        ),
      );
    }

    // Hydration / interactivity gate: a page can render content and log no
    // errors yet never have hydrated, leaving every control dead. Read-only
    // (it inspects framework-attachment markers, never clicks), so it is safe
    // to run before the screenshot. Stack-gated and fail-safe — see
    // scenario-interactivity.js — so backend / static / unknown-framework
    // captures are an automatic pass.
    // `hydration.hydrated` is also consulted below to classify interactionEffect:
    // the wait runs BEFORE any interaction, which is exactly the reading we want
    // — "was this page alive when we found it," not "did our click revive it."
    //
    // WAIT for hydration (not just detect it): the one-shot probe read the
    // attachment state before React had a chance to hydrate SSR markup, so the
    // subsequent fill/click landed on inert controls and the submit handler
    // never fired — yet the run reported success. Waiting here gates the
    // screenshot AND every interaction branch below (steps / interaction /
    // interactions[] all run after this line) on the client runtime actually
    // attaching. Stack-gated and fail-safe: a timed-out wait yields
    // `hydrated: false` (so a truly dead page still classifies `unhydrated`),
    // and a non-interactive stack returns instantly.
    const hydration = await waitForHydration(frame, {
      url: page.url() || url,
      timeoutMs: hydrationTimeoutMs,
      // `undefined` in production → waitForHydration reads .codeyam/stack.json;
      // a test injects a stack to force the interactive path without a real file.
      stack: config.stack,
    });
    if (hydration.issue) {
      pushIssue(issues, hydration.issue);
    }

    // Assert the injected seed actually landed in the capture browser, at rest
    // and BEFORE any interaction can legitimately mutate storage. A non-empty
    // seed that didn't reach localStorage means the screenshot will show
    // default/empty state — fail loudly instead of emitting a misleading frame.
    const seedNotLandedIssue = await verifySeededStorageLanded(frame, config);
    if (seedNotLandedIssue) {
      pushIssue(issues, seedNotLandedIssue);
    }

    // Scripted multi-step flow (`editor preview-flow`): drive an ordered
    // sequence of steps in THIS one browser session — so a behavioral
    // round-trip (click → observe → click) is captured as the real flow, not N
    // independent fresh-load snapshots. Each `capture` step writes a numbered
    // filmstrip frame; the others advance the same page. Mutually exclusive
    // with the single `interaction` path below. `frame` is reassigned so a
    // `navigate` step's new content frame backs the rest of the flow and the
    // final result URL.
    if (Array.isArray(config.steps) && config.steps.length > 0) {
      frame = await runFlowSteps(page, frame, config.steps, {
        url,
        loadingMarkers,
        navigation: config.navigation,
        iframeBackground: config.iframeBackground,
        preflight,
        harnessOrigin: resolvedHarnessOrigin,
        warnings: interactionWarnings,
        hydrationTimeoutMs,
        settleMs: config.settleMs,
      });
    } else if (config.interaction) {
      // Record fingerprint before interaction
      const beforeFingerprint = await getDOMFingerprint(frame);

      // Drive the requested interaction (if any) against the settled frame,
      // then re-settle, so `preview-interact` captures the RESULT of a click /
      // fill / press (expanded accordion, open modal) without editing app
      // source. A no-match target throws here and is caught below as a failed
      // capture with the candidate-labels hint — never a silent blank shot.
      await performInteraction(frame, config.interaction, {
        warnings: interactionWarnings,
      });
      await waitForStablePage(page, frame, 5000, loadingMarkers);

      // Record fingerprint after interaction
      let afterFingerprint = await getDOMFingerprint(frame);

      // If unchanged and it was a click, retry once after 500ms (covers the hydration race)
      if (beforeFingerprint === afterFingerprint && config.interaction.action === "click") {
        interactionRetried = true;
        await new Promise((resolve) => setTimeout(resolve, 500));
        // The retry re-resolves the same target; suppress its ambiguity warning
        // (already captured on the first attempt) to avoid a duplicate.
        await performInteraction(frame, config.interaction);
        await waitForStablePage(page, frame, 5000, loadingMarkers);
        afterFingerprint = await getDOMFingerprint(frame);
      }

      interactionEffect = classifyInteractionEffect(
        beforeFingerprint,
        afterFingerprint,
        hydration.hydrated,
      );
    }

    // Replay the scenario's PERSISTED interaction sequence (if any) in order,
    // settling between steps, so a declared interactive state — an expanded
    // section, a revealed hover bar, an open modal — is reproduced on every
    // capture and recapture, not just in a one-off `preview-interact`. A step
    // that matches nothing throws and is caught below as a failed capture, so a
    // sequence that didn't fully run never persists a resting-state screenshot.
    if (Array.isArray(config.interactions) && config.interactions.length > 0) {
      await performInteractionSequence(page, frame, config.interactions, {
        settleMs: 5000,
        loadingMarkers,
        warnings: interactionWarnings,
      });
    }

    // Snap any remaining mid-flight CSS entrance animation to its final frame
    // for the static shot — but only when the scenario has NOT declared an
    // interactive state (a single `interaction`, a persisted `interactions`
    // sequence, or a multi-step `steps` flow), so an intentionally
    // animated/collapsed interactive frame is never clobbered by the force.
    const hasDeclaredInteractiveState =
      !!config.interaction ||
      (Array.isArray(config.interactions) && config.interactions.length > 0) ||
      (Array.isArray(config.steps) && config.steps.length > 0);
    if (outputPath && loaded && !hasDeclaredInteractiveState) {
      await forceFinalVisualState(frame).catch(() => {});
    }

    // Center an isolated-component wrapper that is not already centered. The
    // shot below is full-viewport with no element clip, so an isolation page
    // that does not center itself lands in the top-left corner. Unlike
    // forceFinalVisualState this is NOT gated on hasDeclaredInteractiveState:
    // an isolation page with a declared interaction still needs to be centered,
    // and moving the wrapper does not clobber its contents the way
    // animation-forcing does — so a replayed interaction sequence stays valid.
    if (outputPath && loaded) {
      await centerCaptureWrapper(frame).catch(() => {});
    }

    if (outputPath && loaded) {
      fs.mkdirSync(path.dirname(outputPath), { recursive: true });
      await page.screenshot({ path: outputPath, fullPage: false });
    }

    const result = buildResult({
      loaded,
      hasContent,
      issues,
      outputPath,
      url: frame.url() || url,
      unmockedRoutes,
    });

    if (config.interaction) {
      result.interactionEffect = interactionEffect;
      result.interactionRetried = interactionRetried;
    }

    // Surface any non-fatal interaction/flow warnings (e.g. an ambiguous
    // substring text match) so the CLI can print them and the agent can switch
    // to a precise selector. Only attached when present — a clean run is
    // byte-for-byte unchanged.
    if (interactionWarnings.length > 0) {
      result.warnings = interactionWarnings.slice();
    }

    // `capture-state` mode: attach the read-only page-state snapshot so the
    // backend can report localStorage + rendered text. Off by default, so a
    // normal error-check capture is byte-for-byte unchanged.
    if (config.captureState) {
      result.state = await dumpPageState(frame, config.stateSelector);
      // A populated state that renders blank is exactly when an agent reaches
      // for capture-state, so bundle the client-fetch advisory with the dump it
      // explains. Only when the page didn't settle cleanly — the SSR /
      // props-driven happy path stays advisory-free.
      if (settleAdvisory) {
        result.state.advisories = [settleAdvisory];
      }
    }

    return result;
  } catch (error) {
    pushIssue(
      issues,
      createIssue("navigation", error.message || String(error), { url }),
    );

    return buildResult({
      loaded,
      hasContent: false,
      issues,
      outputPath,
      url,
      unmockedRoutes,
    });
  } finally {
    await browser.close();
  }
}

/**
 * npm wrapper entry point for the scenario-check binary: parses the
 * JSON config from argv, drives Playwright to capture the configured
 * URL, and writes the resulting screenshot.
 */
async function main() {
  const config = JSON.parse(process.argv[2] || "{}");

  if (!config.url) {
    console.error(
      "Usage: node scenario-check.js '{\"url\":\"...\",\"outputPath\":\"...\",\"width\":1440,\"height\":900}'",
    );
    process.exit(1);
  }

  const result = await runScenarioCheck(config);
  console.log(JSON.stringify(result));
}

module.exports = {
  runScenarioCheck,
  classifyInteractionEffect,
  mergeVisibleTextLength,
  runFlowSteps,
  dumpPageState,
  verifySeededStorageLanded,
  readStackLoadingMarkers,
  scenarioScriptsLiveSocket,
  applyBrowserState,
  buildSessionTokenCookies,
  captureAuthSkewDetected,
  SESSION_COOKIE,
  isCrossOriginRequest,
  isCaptureFatalRequestFailure,
  stripMarkerHeaders,
  main,
  launchChromiumWithSelfHeal,
  isTransientLaunchCrash,
  CAPTURE_LAUNCH_ARGS,
  CAPTURE_HOST_RESOLVER_RULES,
  CAPTURE_LAUNCH_SIGSEGV_RETRIES,
  PLAYWRIGHT_INSTALL_COMMAND,
  PLAYWRIGHT_MISSING_BROWSER_PATTERN,
  PLAYWRIGHT_LAUNCH_CRASH_PATTERNS,
};

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message || String(error));
    process.exit(1);
  });
}
