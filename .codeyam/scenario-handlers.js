// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: 40e39b7207a6b9e38a20ea3e7dd8fc56a0dc95abc1fbdf8ae25a575942761e2b
const { createIssue } = require("./scenario-issues");

// Known substrings that mean the app refused to initialize because it was loaded
// from an *insecure context* — a bare dotted-quad IP rather than HTTPS or the
// hostname `localhost`. This is a whole CLASS of failure (Sveltia CMS's
// "only works with HTTPS or localhost", anything gating on `isSecureContext`,
// `crypto.subtle`, service workers, `Secure` cookies, WebAuthn), not one app.
// Matching reclassifies the error as an actionable `insecure-host` advisory
// instead of a generic console/page failure that surfaces as a bare
// `screenshot=null` with no explanation. Substrings are matched
// case-insensitively; keep the set small and well-known.
const INSECURE_CONTEXT_SIGNATURES = [
  "only works with https or localhost",
  "issecurecontext",
  "secure context",
  "requires https",
];

// The single actionable message the `insecure-host` advisory carries. Names the
// class of failure and the fix (the preview origin is `localhost` by default;
// stubborn apps can opt into HTTPS) rather than echoing one app's raw error.
const INSECURE_HOST_ADVISORY_MESSAGE =
  "The app refused to run because it was loaded from an insecure context " +
  "(a bare IP). It requires a secure context — HTTPS or the hostname " +
  "`localhost`. The preview origin is `localhost` by default; if this persists, " +
  "the app may require HTTPS even on localhost — enable `proxy.httpsPreview` in " +
  ".codeyam/editor.json.";

// Reclassify an error string as an `insecure-host` advisory when it matches a
// known insecure-context signature, else null. Pure; the original text is kept
// as the `contextSnippet` so the operator can still see what the app logged.
function insecureContextAdvisory(text) {
  if (typeof text !== "string" || text.length === 0) return null;
  const lower = text.toLowerCase();
  const matched = INSECURE_CONTEXT_SIGNATURES.some((sig) => lower.includes(sig));
  if (!matched) return null;
  return createIssue("insecure-host", INSECURE_HOST_ADVISORY_MESSAGE, {
    contextSnippet: text,
  });
}

// The pathname suffix identifying the editor's OWN terminal socket. Matched by
// suffix rather than full URL because the terminal is proxied through varying
// origins (localhost, a container IP, a tunnel host) and varying ports.
const TERMINAL_SOCKET_PATH_SUFFIX = "/ws/terminal";

// `allowWebSocket` keeps the real `WebSocket` for scenarios that script a
// `/ws/terminal` transcript (or a WS stream): those captures NEED the socket to
// connect so the server replays the scripted agent state into the frame. The
// interception below exists to silence the live terminal's reconnect loop on
// EVERY OTHER capture (a component that opens `/ws/terminal` with no scripted
// playback would otherwise screenshot the "Reconnecting…" overlay); for a
// scripted scenario the server holds the socket open after replay, so there is
// no reconnect spam to silence and stubbing only hides the very state we are
// trying to capture. The flag is computed by the capture orchestrator from the
// scenario's `mocks.transcripts` / `mocks.streams` — see
// `scenarioScriptsLiveSocket` in scenario-check.js.
//
// The interception is SCOPED BY URL and never blanket-replaces the global
// constructor. A dead global `WebSocket` also kills the framework's HMR socket,
// and on a dev-mode client bootstrap that runs through that socket (validated on
// Next.js 16 + turbopack) React then never hydrates in the capture browser —
// silently, with no console error. Every interactive capture of such an app
// reads as inert: clicks land on un-hydrated SSR markup and `interactionEffect`
// comes back `none`/`unhydrated`. Letting HMR connect costs nothing in capture
// noise, because `handleConsoleMessage` below already drops
// "WebSocket connection to" errors.
function getInitScript(allowWebSocket = false) {
  const webSocketStub = allowWebSocket
    ? ""
    : `
    // Intercept ONLY the editor's own terminal socket during capture, to
    // prevent terminal reconnection spam. Every other URL — notably the
    // framework's HMR socket, which dev-mode hydration depends on — gets the
    // real WebSocket.
    (() => {
      const RealWebSocket = window.WebSocket;
      if (!RealWebSocket) return;
      class StubWebSocket {
        static CONNECTING = 0;
        static OPEN = 1;
        static CLOSING = 2;
        static CLOSED = 3;
        readyState = 3;
        url = "";
        onopen = null;
        onclose = null;
        onerror = null;
        onmessage = null;
        send() {}
        close() {}
        addEventListener() {}
        removeEventListener() {}
        dispatchEvent() { return false; }
        constructor(url) {
          this.url = String(url);
          setTimeout(() => {
            if (this.onerror) this.onerror(new Event("error"));
            if (this.onclose) this.onclose(new CloseEvent("close"));
          }, 0);
        }
      }
      const isTerminalSocket = (url) => {
        const raw = String(url);
        try {
          return new URL(raw, window.location.href).pathname.endsWith(
            ${JSON.stringify(TERMINAL_SOCKET_PATH_SUFFIX)}
          );
        } catch (_) {
          return raw.includes(${JSON.stringify(TERMINAL_SOCKET_PATH_SUFFIX)});
        }
      };
      function CodeyamWebSocket(url, protocols) {
        if (isTerminalSocket(url)) return new StubWebSocket(url);
        return protocols === undefined
          ? new RealWebSocket(url)
          : new RealWebSocket(url, protocols);
      }
      CodeyamWebSocket.prototype = RealWebSocket.prototype;
      CodeyamWebSocket.CONNECTING = 0;
      CodeyamWebSocket.OPEN = 1;
      CodeyamWebSocket.CLOSING = 2;
      CodeyamWebSocket.CLOSED = 3;
      window.WebSocket = CodeyamWebSocket;
    })();`;
  return `
    window.__codeyamUnhandledRejections = [];
    window.addEventListener("unhandledrejection", (event) => {
      const reason = event.reason;
      const message =
        reason instanceof Error ? reason.message : String(reason);
      window.__codeyamUnhandledRejections.push(message);
    });
${webSocketStub}
  `;
}

// Third mirror of SUPPRESSION_PATTERN in ui/src/hooks/useViteHmrAutoReload.ts
// and VITE_WS_NOISE_PATTERN in crates/proxy-http/src/error_capture.js. All
// three surfaces silence the same harness-owned Vite HMR reconnect noise; keep
// in sync. The capture path is the one that was missing it, which made every
// preview-flow / preview-interact against a proxy-wrapped route fail its
// console check on noise the editor itself produces.
const VITE_WS_NOISE_PATTERN =
  /vite.*failed to connect to websocket|WebSocket closed without opened/i;

function handleConsoleMessage(message) {
  if (message.type() !== "error") return null;
  const text = message.text();

  // An insecure-context refusal wins over the generic `console` classification:
  // it is the targeted, actionable signal for the secure-context app class.
  const advisory = insecureContextAdvisory(text);
  if (advisory) return advisory;

  // Vite's reconnect banner ("[vite] failed to connect to websocket." plus the
  // `(browser) … <--[WebSocket (failing)]--> … (server)` diagram) contains none
  // of the substrings the ignore list below matches, so it fell through and
  // vetoed the capture. Matched narrowly — the `vite`-anchored alternative and
  // the exact-phrase second alternative both leave a genuine app-authored error
  // mentioning websockets surfacing as a real issue.
  if (VITE_WS_NOISE_PATTERN.test(text)) return null;

  // Ignore known dev-server WebSocket/HMR errors from Vite proxy, plus the
  // crxjs/Vite dynamic-import reload race: dev loaders `import()` the app entry
  // with a `?t=<timestamp>` cache-buster, and a rapid scenario-reactivation
  // reload aborts the in-flight import, logging "TypeError: Failed to fetch
  // dynamically imported module" (Chrome) or "error loading dynamically
  // imported module" (Vite). Benign — the entry reloads on the next nav.
  if (
    text.includes("WebSocket connection to") ||
    text.includes("Unsupported Media Type") ||
    text.includes("dynamically imported module")
  ) {
    return null;
  }

  // Ignore the browser's blocked-script warning for sandboxed mockup-preview
  // frames. Mockup previews render untrusted AI-generated HTML inside a
  // `sandbox=""` iframe; the HTML-injection proxy injects an error-capture
  // <script> tag, which the browser then refuses to run, emitting
  // "Blocked script execution ... because the frame is sandboxed". That block
  // is the capture's own injected script being denied — benign for capture
  // purposes. Match narrowly on BOTH the block phrase and the "sandboxed"
  // signature so a genuine non-sandbox CSP block ("Blocked script execution"
  // without "sandboxed") still surfaces as a real issue.
  if (
    text.includes("Blocked script execution") &&
    text.includes("sandboxed")
  ) {
    return null;
  }

  // Attach the offending resource URL the console message already exposes, so
  // the capture-failure message can name the unmocked route (e.g.
  // `GET /api/questions/<id>/research`) instead of an opaque "Failed to load
  // resource". `message.location().url` is the resource that produced the
  // error; `format_issue` renders it as `[<url>]` when populated.
  const url = message.location && message.location().url;
  return createIssue("console", text, url ? { url } : {});
}

function handlePageError(error) {
  const text = error.message || String(error);
  // A secure-context guard often throws at boot rather than logging — surface
  // the same actionable advisory for the pageerror path.
  const advisory = insecureContextAdvisory(text);
  if (advisory) return advisory;
  return createIssue("pageerror", text);
}

function handleRequestFailed(request) {
  const errorText = request.failure()?.errorText || "Request failed";

  // Filter benign request cancellations. `net::ERR_ABORTED` is what Playwright
  // emits when a request is in-flight at the moment the page is closed (or the
  // iframe is destroyed). For scenarios whose pages fetch large payloads (the
  // editor's own EditorShell mounts a 2.2MB `/api/tests` fetch), the
  // browser.close() at the end of capture races the fetch and produces this
  // event AFTER the screenshot has already been taken — there is no real
  // failure to surface. Genuine network failures arrive under different
  // codes (net::ERR_CONNECTION_REFUSED, net::ERR_NAME_NOT_RESOLVED, etc.)
  // and continue to be reported.
  if (errorText.includes("net::ERR_ABORTED")) {
    return null;
  }

  return createIssue("requestfailed", errorText, { url: request.url() });
}

module.exports = {
  getInitScript,
  handleConsoleMessage,
  handlePageError,
  handleRequestFailed,
  insecureContextAdvisory,
  INSECURE_CONTEXT_SIGNATURES,
  INSECURE_HOST_ADVISORY_MESSAGE,
  VITE_WS_NOISE_PATTERN,
};
