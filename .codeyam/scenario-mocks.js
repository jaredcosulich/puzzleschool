// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: 6f8ab32b12ddf24a13cf3ec43288f53c95cf4126dfd969e63495270353a53de7
// Route matcher shared, semantically, with the injected live-preview shim
// (crates/proxy-http/src/fetch_patch.js::matchUrl / matchPath / matchQuerySpec).
// This is a VERBATIM port of that shim's matcher — the two interception paths
// MUST agree on which requests a mock route covers. When they drifted (the
// shim gained `:param` + query-spec parity but this capture-harness matcher was
// left doing exact string matching), a parameterized or query-spec'd mock
// rendered in the Live Preview but escaped Playwright's `page.route` during
// capture and rendered an empty list. `scenario-mocks.test.js` pins the two to
// identical verdicts on a shared fixture table so a future divergence is a
// test failure, not another lost build session.
//
// `:param` path segments match any single non-empty segment; a `?k=v` / `?k=*`
// query-spec suffix constrains the query as a subset match (`k=*` matches any
// value; an empty spec matches any query). Full-URL patterns (`http://…`) match
// by prefix on the raw URL. Mirrors crates/mock-engine's server matcher.
function matchUrl(pattern, url) {
  // Full-URL patterns (external APIs) match by prefix on the raw URL.
  if (pattern.startsWith("http://") || pattern.startsWith("https://")) {
    return url.indexOf(pattern) === 0;
  }

  let reqPath = url;
  let reqQuery = "";
  try {
    const u = new URL(url);
    reqPath = u.pathname;
    reqQuery = u.search.replace(/^\?/, "");
  } catch {
    const qi = url.indexOf("?");
    if (qi >= 0) {
      reqPath = url.slice(0, qi);
      reqQuery = url.slice(qi + 1);
    }
  }

  const patParts = pattern.split("?");
  if (!matchPath(patParts[0], reqPath)) return false;
  return matchQuerySpec(patParts.length > 1 ? patParts[1] : "", reqQuery);
}

// Segment-wise path match with `:param` wildcards. A `:name` segment matches
// any single non-empty segment; every other segment must be equal, and the
// segment counts must match — no implicit prefix match, same as the server.
function matchPath(pattern, path) {
  const pp = pattern.split("/");
  const rp = path.split("/");
  if (pp.length !== rp.length) return false;
  for (let i = 0; i < pp.length; i++) {
    if (pp[i].charAt(0) === ":") {
      if (rp[i] === "") return false;
      continue;
    }
    if (pp[i] !== rp[i]) return false;
  }
  return true;
}

// Query-spec match. An empty spec matches any query (a path-only route still
// matches a request that carries query params). Otherwise every `k=v` pair in
// the spec must be present in the request query; `k=*` matches any value.
function matchQuerySpec(spec, query) {
  if (!spec) return true;
  const want = new URLSearchParams(spec);
  const have = new URLSearchParams(query);
  let ok = true;
  want.forEach((v, k) => {
    const got = have.get(k);
    if (got === null) {
      ok = false;
      return;
    }
    if (v !== "*" && got !== v) ok = false;
  });
  return ok;
}

// Split a mock key (`"<METHOD> <route>"`, e.g. `"GET /api/plans"`) into its
// method and route pattern. Returns null for a malformed key with no separator.
function splitMockKey(key) {
  const spaceIdx = key.indexOf(" ");
  if (spaceIdx === -1) return null;
  return { method: key.slice(0, spaceIdx), route: key.slice(spaceIdx + 1) };
}

function findHttpMock(httpMocks, request) {
  const method = request.method().toUpperCase();
  const url = request.url();
  for (const [key, mock] of Object.entries(httpMocks)) {
    const parsed = splitMockKey(key);
    if (!parsed) continue;
    // Method stays an exact check; only the route is matched by pattern.
    if (parsed.method.toUpperCase() !== method) continue;
    if (matchUrl(parsed.route, url)) return mock;
  }
  return null;
}

// The set of path/URL route patterns declared by the mock keys. A key is
// `"<METHOD> <route>"` (e.g. `"GET /api/plans"`); we strip the method so the
// route matcher can decide whether a request *could* match any mock without
// knowing the method (the handler re-checks method via findHttpMock).
function mockedTargets(httpMocks) {
  const targets = new Set();
  for (const key of Object.keys(httpMocks)) {
    const parsed = splitMockKey(key);
    if (!parsed) continue;
    targets.add(parsed.route);
  }
  return targets;
}

// True when a request URL matches one of the declared mock route patterns under
// the shared route matcher (`:param` + query-spec parity), not exact string
// equality. Accepts either a string or a WHATWG URL (Playwright's URL-matcher
// passes a URL).
function requestTargetsMock(targets, url) {
  const href = typeof url === "string" ? url : url.href;
  for (const target of targets) {
    if (matchUrl(target, href)) return true;
  }
  return false;
}

async function attachHttpMocks(page, httpMocks) {
  if (!httpMocks || Object.keys(httpMocks).length === 0) return;

  // Intercept ONLY requests whose path matches a declared mock — not every
  // request. A blanket `page.route("**/*")` intercepts the dev server's ESM
  // module/script/style requests too, and routing them through
  // `route.continue()` breaks Vite dev-mode module loading: the lazy app
  // chunks never resolve and the SPA renders blank. Scoping the matcher to
  // mocked targets lets those requests load natively while still mocking the API.
  const targets = mockedTargets(httpMocks);
  await page.route(
    (url) => requestTargetsMock(targets, url),
    async (route) => {
      const mock = findHttpMock(httpMocks, route.request());
      if (!mock) {
        await route.continue();
        return;
      }

      const headers = { ...(mock.headers || {}) };
      let body;
      if (mock.body !== undefined) {
        body =
          typeof mock.body === "string"
            ? mock.body
            : JSON.stringify(mock.body);
        const hasContentType = Object.keys(headers).some(
          (key) => key.toLowerCase() === "content-type",
        );
        if (!hasContentType) {
          headers["content-type"] = "application/json";
        }
      }

      await route.fulfill({
        status: mock.status || 200,
        headers,
        body,
      });
    },
  );

  // Disable the in-page fetch mock by returning an empty active-mocks.json.
  // The HTML injects a script that synchronously loads this file and
  // monkey-patches window.fetch, which would bypass Playwright's route
  // interception. This route is registered AFTER the mock matcher so it takes
  // priority for that path (Playwright uses LIFO ordering for route handlers).
  await page.route("**/active-mocks.json", async (route) => {
    await route.fulfill({
      status: 200,
      headers: { "content-type": "application/json" },
      body: "[]",
    });
  });
}


// True when a console "Failed to load resource" error at `url` corresponds to
// a mock this scenario DECLARED with an error status (>= 400). An intentional
// error-state scenario (e.g. a History tab mocking `GET /api/history` -> 500)
// must not fail its own capture on the console noise its mock deliberately
// produces. Console errors carry no HTTP method, so any method's mock on a
// matching target counts.
function isDeclaredErrorMock(httpMocks, url) {
  for (const [key, mock] of Object.entries(httpMocks || {})) {
    const parsed = splitMockKey(key);
    if (!parsed) continue;
    // Method-agnostic on purpose: console errors carry no HTTP method, so any
    // method's error mock on a matching route counts. Route matching uses the
    // shared matcher so a `:param`/query-spec error mock is recognised too.
    if (!matchUrl(parsed.route, url)) continue;
    if ((mock.status || 200) >= 400) return true;
  }
  return false;
}

// Given a same-origin response's method/url/status and the scenario's declared
// mocks, return the `{method, path, status}` to record as an unmocked route, or
// `null` if it should be ignored: a sub-4xx response, or one already covered by
// a declared error mock (status >= 400, whose 4xx is the mock's intended
// behavior). The caller applies the same-origin and `expectedConsoleErrors`
// gates before calling. `path` is the URL pathname — the route half of the
// `"<METHOD> <path>"` stub-mock key; a malformed URL falls back to the raw
// string so the key is still well-formed.
function unmockedRouteFrom(method, url, status, httpMocks) {
  if (status < 400) return null;
  if (isDeclaredErrorMock(httpMocks, url)) return null;
  let path = url;
  try {
    path = new URL(url).pathname;
  } catch {
    /* malformed URL — fall back to the raw string for the stub key */
  }
  return { method: String(method).toUpperCase(), path, status };
}

module.exports = {
  matchUrl,
  matchPath,
  matchQuerySpec,
  findHttpMock,
  mockedTargets,
  requestTargetsMock,
  attachHttpMocks,
  isDeclaredErrorMock,
  unmockedRouteFrom,
};
