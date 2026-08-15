// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: 895f97d7ea439499e24dfce06a2611e5f5808016ce616e34bb0bf24c40c78dba
function createIssue(kind, message, extra = {}) {
  const issue = {
    kind,
    message,
    url: extra.url ?? null,
    status: extra.status ?? null,
  };
  if (extra.matchedPattern != null) issue.matchedPattern = extra.matchedPattern;
  if (extra.contextSnippet != null) issue.contextSnippet = extra.contextSnippet;
  return issue;
}

function pushIssue(issues, issue) {
  const key = JSON.stringify(issue);
  if (!issues.some((existing) => JSON.stringify(existing) === key)) {
    issues.push(issue);
  }
}

function buildResult({
  loaded,
  hasContent,
  issues,
  outputPath,
  url,
  unmockedRoutes = [],
  mockUsage = { used: [], unused: [] },
  externalRequests = [],
}) {
  return {
    ok: loaded && hasContent && issues.length === 0,
    loaded,
    hasContent,
    url,
    outputPath: outputPath ?? null,
    issues,
    // Diagnostic-only: same-origin 4xx routes with no scenario mock. Does NOT
    // affect `ok` — the paired console error already fails the capture; this is
    // the actionable route list the failure message and `stub-unmocked-routes`
    // consume. Defaults to `[]` so callers that omit it are unchanged.
    unmockedRoutes,
    // Diagnostic-only, and deliberately NOT part of `ok`: an unused mock is not
    // automatically an error (a scenario may legitimately declare a mock for a
    // request the page makes only on interaction). Reporting it turns a silent
    // inertness into a visible fact; failing on it would break working scenarios
    // for a heuristic.
    mockUsage,
    // Requests grouped by origin, split mocked/unmocked and same/cross-origin.
    // The line that ends a "why is this page blank" misdiagnosis.
    externalRequests,
  };
}

module.exports = {
  createIssue,
  pushIssue,
  buildResult,
};
