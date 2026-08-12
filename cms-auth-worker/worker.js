// Password-gated auth relay for the Sveltia/Decap GitHub backend.
//
// Why this exists: a plain GitHub Pages site is static, so there is no server
// to run a GitHub OAuth callback. This minimal Cloudflare Worker stands in for
// that server on the free tier. Editors get a literal password prompt at the
// same domain as the site; on the correct password the Worker completes the
// Decap auth handshake using a GitHub token you store as a Worker secret.
//
// SECURITY TRADE-OFF: every editor who knows the password commits as the single
// identity behind GITHUB_TOKEN (use a fine-grained PAT scoped to *only* this
// repo's contents). There is no per-user attribution. If you need that, use the
// GitHub OAuth path instead (see CMS_SETUP.md). Rotate the PAT and password by
// updating the Worker secrets.
//
// Required Worker secrets (set via `wrangler secret put <NAME>`):
//   CMS_PASSWORD  — the shared editor password
//   GITHUB_TOKEN  — a fine-grained PAT with Contents: Read & Write on the repo
//
// Wire it up in public/admin/config.yml:
//   backend:
//     name: github
//     repo: OWNER/REPO
//     branch: main
//     base_url: https://<your-worker>.workers.dev
//     auth_endpoint: auth
//
// The Decap GitHub backend opens `${base_url}/${auth_endpoint}` in a popup,
// then expects a postMessage handshake: it sends "authorizing:github" to the
// popup, and the popup replies "authorization:github:success:<json>" carrying
// the token. We reproduce exactly that handshake after the password check.

const PROVIDER = "github";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // The auth popup target. GET renders the password form; POST validates it.
    if (url.pathname === "/auth" || url.pathname === "/auth/") {
      if (request.method === "POST") {
        return handlePasswordSubmit(request, env);
      }
      return htmlResponse(passwordFormPage());
    }

    return new Response("Not found", { status: 404 });
  },
};

// Validate the submitted password against the CMS_PASSWORD secret. On success,
// hand the stored GITHUB_TOKEN back through the Decap postMessage handshake; on
// failure, re-render the form with an error and a 401 so the popup stays open.
async function handlePasswordSubmit(request, env) {
  const form = await request.formData();
  const submitted = form.get("password");

  if (!env.CMS_PASSWORD || submitted !== env.CMS_PASSWORD) {
    return htmlResponse(passwordFormPage("Incorrect password."), 401);
  }
  if (!env.GITHUB_TOKEN) {
    return htmlResponse(passwordFormPage("Server is missing GITHUB_TOKEN."), 500);
  }

  const payload = JSON.stringify({ token: env.GITHUB_TOKEN, provider: PROVIDER });
  return htmlResponse(handshakePage(payload));
}

// The page Decap's popup runs after a correct password. It opens the handshake
// ("authorizing:github"), waits for the editor window to acknowledge, then
// posts the success message with the token and closes itself.
function handshakePage(payloadJson) {
  // payloadJson is server-controlled JSON (token + provider); embedding it in a
  // single-quoted JS string is safe here — it contains no user input.
  return `<!doctype html><meta charset="utf-8"><title>Authorizing…</title>
<body>Authorizing…</body>
<script>
  (function () {
    var data = ${payloadJson};
    function send(message) {
      window.opener && window.opener.postMessage(message, "*");
    }
    // Step 1: announce we are authorizing. The CMS replies, telling us its origin.
    window.addEventListener("message", function () {
      send("authorization:${PROVIDER}:success:" + JSON.stringify(data));
      window.close();
    }, { once: true });
    send("authorizing:${PROVIDER}");
  })();
<\/script>`;
}

function passwordFormPage(error) {
  const errorHtml = error
    ? '<p style="color:#b00020">' + escapeHtml(error) + "</p>"
    : "";
  return `<!doctype html><meta charset="utf-8"><title>Sign in</title>
<body style="font-family:system-ui;max-width:20rem;margin:4rem auto">
  <h1 style="font-size:1.1rem">Content editor sign-in</h1>
  ${errorHtml}
  <form method="POST" action="/auth">
    <label>Password<br>
      <input type="password" name="password" autofocus
             style="width:100%;padding:.5rem;margin:.5rem 0">
    </label>
    <button type="submit" style="padding:.5rem 1rem">Sign in</button>
  </form>
</body>`;
}

function htmlResponse(html, status = 200) {
  return new Response(html, {
    status,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function escapeHtml(s) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
