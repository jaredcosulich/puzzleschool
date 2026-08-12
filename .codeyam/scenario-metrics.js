// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: 38a6c6948b0693d3313d5fbe0699cc69cba672c518d8489c55e165a22eb2f066
const LOADING_MARKERS = [
  "Loading scenario...",
  "Loading tests...",
  "Loading scenarios...",
  "disconnected",
];

// `extraMarkers` are project-supplied (from stack.json `capture.loadingMarkers`)
// because an app's own loading copy ("Loading…", "Please wait") is
// app-specific and must NOT be hardcoded into the shared harness — only the
// four codeyam-harness markers above are universal. Matching is
// case-insensitive so "Loading…" and "loading…" both count; without the
// project markers a stable app loading screen looks "ready" to
// waitForStablePage and gets captured mid-hydration.
function hasLoadingMarkers(text, extraMarkers = []) {
  if (!text) return false;
  const lower = text.toLowerCase();
  const markers = LOADING_MARKERS.concat(
    Array.isArray(extraMarkers) ? extraMarkers : [],
  );
  return markers.some(
    (marker) => marker && lower.includes(String(marker).toLowerCase()),
  );
}

function hasRenderableContent(state) {
  if (!state) return false;

  // Reveal-suppression guard. A scroll-gated entrance animation starts its
  // content at `opacity:0` and reveals it via an IntersectionObserver wired
  // from the app shell. Captured in isolation (no shell), the observer never
  // fires, so the text renders into the DOM — `bodyTextLength`/`rootTextLength`
  // are non-zero — yet stays visually invisible and the screenshot is blank.
  // `visibleTextLength` is the length of text actually PAINTED to the frame
  // (computed-style opacity/visibility aware). When the DOM carries text but
  // none of it is visible AND there is no visible media, the frame is
  // near-blank: report no content so the blank gate rejects it instead of
  // waving through an empty shell. `visibleTextLength` is optional — older
  // capture configs (and stubbed test targets) omit it, in which case the
  // original DOM-presence behavior below is preserved byte-for-byte.
  const domTextLength = Math.max(
    state.bodyTextLength || 0,
    state.rootTextLength || 0,
  );
  const hasVisibleMedia =
    (state.loadedImageCount || 0) > 0 || (state.mediaBboxCount || 0) > 0;
  if (
    typeof state.visibleTextLength === "number" &&
    domTextLength > 0 &&
    state.visibleTextLength === 0 &&
    !hasVisibleMedia
  ) {
    return false;
  }

  if (
    state.rootChildCount > 0 ||
    state.rootTextLength > 0 ||
    state.bodyTextLength > 0
  ) {
    return true;
  }
  if ((state.loadedImageCount || 0) > 0) return true;
  if ((state.mediaBboxCount || 0) > 0) return true;
  return false;
}

function describeBlankReason(state) {
  if (!state) return "no content state collected";
  const parts = [];
  // Distinguish "no text in the DOM at all" from "text rendered but nothing is
  // visible" — the latter is the reveal-suppression symptom (opacity:0
  // entrance content whose observer never fired in isolation), which points
  // the author at a different fix than a genuinely empty page.
  if (
    typeof state.visibleTextLength === "number" &&
    state.bodyTextLength > 0 &&
    state.visibleTextLength === 0
  ) {
    parts.push("text rendered but not visible (reveal-suppressed?)");
  } else if (!(state.bodyTextLength > 0)) {
    parts.push("no text");
  }
  const imageCount = state.imageCount || 0;
  const loadedImageCount = state.loadedImageCount || 0;
  if (imageCount > 0 && loadedImageCount === 0) {
    parts.push(`${imageCount} unloaded image${imageCount === 1 ? "" : "s"}`);
  } else if (imageCount === 0) {
    parts.push("no images");
  }
  if (!((state.mediaBboxCount || 0) > 0)) {
    parts.push("no svg/canvas/video");
  }
  return parts.join(", ");
}

function shouldStopWaitingForImages(images, options = {}) {
  const { elapsedMs = 0, overallTimeoutMs = 5000 } = options;
  if (!Array.isArray(images) || images.length === 0) return true;
  if (elapsedMs >= overallTimeoutMs) return true;
  return images.every((img) => img && img.complete === true);
}

const ERROR_PATTERNS = [
  "not found in registry",
  "Component not found",
  "Scenario Error",
];

// The DOM attribute codeyam's own ScenarioRenderer stamps on its error and
// seed-error fallback frames. Error detection anchors on this marker rather
// than scanning the whole page body for ERROR_PATTERNS: a legitimately-mocked
// scenario whose *content* quotes one of those harness phrases (a journal entry
// describing the error component, say) must not be flagged as a failed capture.
// Arbitrary client apps that never render a codeyam ScenarioRenderer never emit
// the marker, so their pages are treated as healthy regardless of body text —
// these patterns were always codeyam-harness-specific, never generic.
const SCENARIO_ERROR_MARKER = "data-codeyam-scenario-error";

function hasErrorPatterns(text) {
  return ERROR_PATTERNS.some((pattern) => text.includes(pattern));
}

function findErrorPattern(text) {
  if (!text) return null;
  for (const pattern of ERROR_PATTERNS) {
    if (text.includes(pattern)) return pattern;
  }
  return null;
}

const ERROR_CONTEXT_RADIUS = 60;

function buildErrorContextSnippet(text, pattern) {
  if (!text || !pattern) return null;
  const index = text.indexOf(pattern);
  if (index < 0) return null;
  const start = Math.max(0, index - ERROR_CONTEXT_RADIUS);
  const end = Math.min(text.length, index + pattern.length + ERROR_CONTEXT_RADIUS);
  const slice = text.slice(start, end).replace(/\s+/g, " ").trim();
  const prefix = start > 0 ? "…" : "";
  const suffix = end < text.length ? "…" : "";
  return `${prefix}${slice}${suffix}`;
}

// Classify a scenario-error fallback into a `{ matchedPattern, contextSnippet }`
// from the marker info collected off the page. `marker` is the
// `{ reason, text }` read from the `[data-codeyam-scenario-error]` element, or
// null when no such element is present. Returns null when there is no marked
// fallback — the page is healthy and no error-content failure is raised.
//
// When the marked fallback text contains a known ERROR_PATTERN (the render-error
// path renders `Component "X" not found in registry`), that pattern is named so
// the downstream Rust classifier can still extract the component; otherwise the
// marker's `reason` attribute classifies it (the seed-error fallback, whose
// "Seed Error" copy is intentionally not an ERROR_PATTERN). Because the text is
// scoped to the fallback element — not the whole body — content elsewhere on the
// page can quote these phrases freely without tripping detection.
function findScenarioError(marker) {
  // The capture passes the `frame.evaluate` result of querying the marker
  // element: either null (no fallback rendered) or a `{reason, text}` object.
  // Anything else (a bare string, a primitive) is not a marked error — guard
  // so a non-object never reads as a present marker and false-flags the page.
  if (!marker || typeof marker !== "object") return null;
  const text = marker.text || "";
  const reason = marker.reason || "";
  const matchedPattern = findErrorPattern(text) || reason || "scenario error";
  const contextSnippet =
    buildErrorContextSnippet(text, matchedPattern) ||
    (text ? text.replace(/\s+/g, " ").trim().slice(0, 200) : null);
  return { matchedPattern, contextSnippet };
}

// Build the non-blocking "this page looks client-fetched" advisory from the two
// settle signals the capture already computes: `stableOutcome` from
// waitForStablePage (did the page settle, and was a loading marker still up at
// the cap?) and `networkOutcome` from waitForNetworkQuiet (did in-flight network
// go quiet, or did the bounded wait cap out?). Captures settle within a bounded
// window so a never-idle stream can't hang them — which means a slower
// client-side fetch lands AFTER the window and the screenshot catches the
// loading/initial state instead of the populated one. When either signal fires,
// name the cause and the two reliable fixes (server-render the data, or drive a
// props-driven isolated component scenario) so the agent reaches for those up
// front instead of rediscovering the constraint by trial and error. Returns the
// advisory string, or null when the page settled cleanly (the SSR / props-driven
// happy path — no advisory, so a healthy capture stays noise-free).
function buildSettleAdvisory(stableOutcome, networkOutcome) {
  const causes = [];
  if (
    stableOutcome &&
    stableOutcome.stabilized === false &&
    stableOutcome.hadLoadingMarkers === true
  ) {
    causes.push("a loading marker was still on the page");
  }
  if (networkOutcome && networkOutcome.quiet === false) {
    causes.push("network requests were still in flight");
  }
  if (causes.length === 0) return null;
  return (
    `When this page was captured, ${causes.join(" and ")} — it likely fetches ` +
    `its data on the client. Captures settle within a bounded window, so data ` +
    `that arrives via a client-side fetch after that window renders as the ` +
    `loading/initial state, not the populated state. To capture a populated ` +
    `state, server-render the data (SSR/RSC) or drive a props-driven isolated ` +
    `component scenario.`
  );
}

module.exports = {
  hasLoadingMarkers,
  hasRenderableContent,
  buildSettleAdvisory,
  describeBlankReason,
  shouldStopWaitingForImages,
  hasErrorPatterns,
  findErrorPattern,
  findScenarioError,
  buildErrorContextSnippet,
  ERROR_PATTERNS,
  SCENARIO_ERROR_MARKER,
  ERROR_CONTEXT_RADIUS,
};
