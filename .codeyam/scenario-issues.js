// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: f716c003edd7d61285497b3fa96d87deb70df246d14b515681b44ffef136050b
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
  };
}

module.exports = {
  createIssue,
  pushIssue,
  buildResult,
};
