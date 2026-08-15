// codeyam-generated — DO NOT EDIT.
// codeyam-editor: 0.1.7  source-sha256: d8b013d0cb4c1a686f889f66d9fd682b4a6b31458bc618ab492231594c7370d3
// Route matcher for the capture harness — one of THREE implementations of a
// single semantic. The authority is the Rust engine
// (crates/mock-engine/src/route_parser.rs), where the contract is written down;
// this file and the injected live-preview shim
// (crates/proxy-http/src/fetch_patch.js) are ports of it.
//
// This is NOT a verbatim copy of the shim, and describing it as one is what let
// the drift hide: the two JS matchers agreed with EACH OTHER while both
// disagreed with the server (they prefix-matched full-URL patterns and returned
// before applying any query spec, where the server anchored). All three are now
// pinned against one shared fixture table,
// crates/mock-engine/fixtures/route-match-fixtures.json, asserted with its
// expected verdicts by both `scenario-mocks.test.js` and the Rust tests — so a
// change to one implementation the others do not follow is a test failure, and
// two matchers agreeing on a wrong answer no longer passes.
//
// The semantic, in short (see route_parser.rs for the full contract): `:name`
// and `*` each match one non-empty path segment; a TRAILING `**` matches the
// remaining path including `/` and including an empty remainder; a `?k=v` /
// `?k=*` suffix constrains the query as a subset match. A full-URL pattern
// (`http://…`) with no wildcard matches by PREFIX — the compatibility rule
// every shipped external mock relies on — while a wildcarded one matches by the
// wildcard rules.
function matchUrl(pattern, url) {
  // Split the query spec off FIRST — for full-URL and path-only patterns
  // alike. Returning early for full URLs (as this did) meant a spec like
  // `?k=*` on an external mock was silently ignored.
  const pqi = pattern.indexOf("?");
  const patPath = pqi >= 0 ? pattern.slice(0, pqi) : pattern;
  const patSpec = pqi >= 0 ? pattern.slice(pqi + 1) : "";

  // Full-URL patterns (external APIs) match against the whole URL, with its
  // own query stripped before the compare.
  if (patPath.startsWith("http://") || patPath.startsWith("https://")) {
    const [rawPath, rawQuery] = splitUrlQuery(url);
    // Compatibility rule: a wildcard-free full-URL pattern prefix-matches,
    // which is what every external mock relies on today. A wildcarded one
    // matches by the wildcard rules, with no prefix fallback.
    const urlMatched = hasWildcard(patPath)
      ? matchPath(patPath, rawPath)
      : rawPath.indexOf(patPath) === 0;
    if (!urlMatched) return false;
    return matchQuerySpec(patSpec, rawQuery);
  }

  let reqPath = url;
  let reqQuery = "";
  try {
    const u = new URL(url);
    reqPath = u.pathname;
    reqQuery = u.search.replace(/^\?/, "");
  } catch {
    [reqPath, reqQuery] = splitUrlQuery(url);
  }

  if (!matchPath(patPath, reqPath)) return false;
  return matchQuerySpec(patSpec, reqQuery);
}

// Split a raw URL into [everything-before-the-query, query]. The `#fragment`
// is dropped from both halves, mirroring the server's strip_url_query.
function splitUrlQuery(url) {
  const qi = url.indexOf("?");
  const hi = url.indexOf("#");
  const cut = qi < 0 ? hi : hi < 0 ? qi : Math.min(qi, hi);
  const head = cut < 0 ? url : url.slice(0, cut);
  if (qi < 0) return [head, ""];
  const query = url.slice(qi + 1);
  const fi = query.indexOf("#");
  return [head, fi >= 0 ? query.slice(0, fi) : query];
}

// True when a segment is a valid `:name` param. A `:`-prefixed segment with
// an empty or punctuated name is matched literally, same as the server.
function isParamSegment(seg) {
  return /^:[\p{L}\p{N}_]+$/u.test(seg);
}

// True when a segment is any wildcard: `:name`, `*`, or `**`.
function isWildcardSegment(seg) {
  return seg === "*" || seg === "**" || isParamSegment(seg);
}

// True when the pattern contains any wildcard segment.
function hasWildcard(pattern) {
  return pattern.split("/").some(isWildcardSegment);
}

// Segment-wise path match. `:name` and `*` each match any single non-empty
// segment; a TRAILING `**` matches the remaining path including `/` and
// including an empty remainder (`/api/**` covers `/api`); every other segment
// must be equal. No implicit prefix match, same as the server.
function matchPath(pattern, path) {
  const pp = pattern.split("/");
  const rp = path.split("/");
  if (pp[pp.length - 1] === "**") {
    const head = pp.length - 1;
    if (rp.length < head) return false;
    for (let i = 0; i < head; i++) {
      if (!matchSegment(pp[i], rp[i])) return false;
    }
    return true;
  }
  if (pp.length !== rp.length) return false;
  for (let i = 0; i < pp.length; i++) {
    if (!matchSegment(pp[i], rp[i])) return false;
  }
  return true;
}

// One segment. `:name`, `*`, and a non-final `**` each match any single
// non-empty segment; anything else must be equal.
function matchSegment(pat, seg) {
  if (isWildcardSegment(pat)) return seg !== "";
  return pat === seg;
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

// The matching mock together with the KEY that declared it, or null. The key is
// what the usage tally counts — reporting "which declared mock fired" needs the
// declaration's identity, not just its body, since two keys can carry
// structurally identical mocks.
function findHttpMockEntry(httpMocks, request) {
  const method = request.method().toUpperCase();
  const url = request.url();
  for (const [key, mock] of Object.entries(httpMocks)) {
    const parsed = splitMockKey(key);
    if (!parsed) continue;
    // Method stays an exact check; only the route is matched by pattern.
    if (parsed.method.toUpperCase() !== method) continue;
    if (matchUrl(parsed.route, url)) return { key, mock };
  }
  return null;
}

function findHttpMock(httpMocks, request) {
  const entry = findHttpMockEntry(httpMocks, request);
  return entry ? entry.mock : null;
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

// The origin half of a URL, or the raw string when it will not parse. Grouping
// by origin is what turns twenty tile URLs into one readable line.
function originOf(url) {
  try {
    return new URL(url).origin;
  } catch {
    return url;
  }
}

// Which declared mock keys actually served a response.
//
// This exists because a declared mock whose key never matches any request is
// silently inert: the capture still reports success, and the frame that lands
// is the healthy state under a name promising a degraded one. The declared keys
// were always known; nothing ever compared them against what fired.
function createMockUsageTally(httpMocks) {
  const declared = Object.keys(httpMocks || {});
  const usedKeys = new Set();
  return {
    recordFulfilled(key) {
      usedKeys.add(key);
    },
    // Declared order is preserved in both lists so the reported set reads the
    // same way the scenario's mock block does.
    get used() {
      return declared.filter((key) => usedKeys.has(key));
    },
    get unused() {
      return declared.filter((key) => !usedKeys.has(key));
    },
  };
}

// Every request the page made, collapsed to one row per `(origin, mocked)` pair.
// A full URL list is noise (twenty tile URLs); origin + count + a representative
// URL is the line that ends a "why is this page blank" misdiagnosis.
function createRequestInventory(appOrigin) {
  // Keyed by `origin|mocked` rather than origin alone: an origin serving both a
  // mocked API call and unmocked sub-resources would otherwise collapse into one
  // row whose `mocked` flag is a coin toss.
  const groups = new Map();

  function groupFor(url, mocked) {
    const origin = originOf(url);
    const groupKey = `${origin}|${mocked ? "mocked" : "unmocked"}`;
    let row = groups.get(groupKey);
    if (!row) {
      row = {
        origin,
        count: 0,
        sampleUrl: url,
        mocked: !!mocked,
        failed: false,
        // `false` when the capture URL did not parse — the caller then has no
        // origin to compare against, and treating everything as cross-origin
        // over-reports rather than hiding a request.
        sameOrigin: !!appOrigin && origin === appOrigin,
      };
      groups.set(groupKey, row);
    }
    return row;
  }

  return {
    recordRequest(url, mocked) {
      groupFor(url, mocked).count += 1;
    },
    recordFailure(url, mocked) {
      groupFor(url, mocked).failed = true;
    },
    // Busiest origin first — the one worth explaining leads the report.
    get groups() {
      return [...groups.values()].sort(
        (a, b) => b.count - a.count || a.origin.localeCompare(b.origin),
      );
    },
  };
}

// Composes the two independent halves above into the single handle the capture
// harness threads through.
//
// Purely observational. Nothing here changes which requests are intercepted:
// `attachHttpMocks` scopes `page.route` to declared targets so unmocked requests
// load natively, and that scoping is load-bearing (a blanket catch-all route
// predicate breaks Vite ESM module loading and blanks the SPA).
function createMockObserver(httpMocks, appOrigin) {
  const usage = createMockUsageTally(httpMocks);
  const inventory = createRequestInventory(appOrigin);
  return {
    recordFulfilled: (key) => usage.recordFulfilled(key),
    recordRequest: (url, mocked) => inventory.recordRequest(url, mocked),
    recordFailure: (url, mocked) => inventory.recordFailure(url, mocked),
    get used() {
      return usage.used;
    },
    get unused() {
      return usage.unused;
    },
    get externalRequests() {
      return inventory.groups;
    },
  };
}

// Passive request inventory. `page.on` observes; it never routes, so attaching
// this cannot change what the page loads.
function attachRequestInventory(page, observer, httpMocks) {
  const targets = mockedTargets(httpMocks || {});
  page.on("request", (request) => {
    const url = request.url();
    observer.recordRequest(url, requestTargetsMock(targets, url));
  });
  page.on("requestfailed", (request) => {
    const url = request.url();
    observer.recordFailure(url, requestTargetsMock(targets, url));
  });
}

// Returns the capture's mock observer (see `createMockObserver`). Always returns
// one, including for a scenario that declares no mocks at all — that is exactly
// the case where an unexplained third-party fetch is hardest to account for.
async function attachHttpMocks(page, httpMocks, options = {}) {
  const observer = createMockObserver(httpMocks, options.appOrigin);
  attachRequestInventory(page, observer, httpMocks);

  if (!httpMocks || Object.keys(httpMocks).length === 0) return observer;

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
      const entry = findHttpMockEntry(httpMocks, route.request());
      if (!entry) {
        await route.continue();
        return;
      }
      const { key, mock } = entry;
      // Counted at the fulfil branch, not at match time: a key is "used" only
      // when it actually served a response.
      observer.recordFulfilled(key);

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

  return observer;
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
  findHttpMockEntry,
  mockedTargets,
  requestTargetsMock,
  originOf,
  createMockUsageTally,
  createRequestInventory,
  createMockObserver,
  attachHttpMocks,
  isDeclaredErrorMock,
  unmockedRouteFrom,
};
