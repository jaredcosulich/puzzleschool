# GitHub Pages Deploy Setup

The build agent will ask which setup applies to your project.

## Two Base Modes (Chosen at Setup)

Depending on whether your site uses a custom domain or a default subpath, select the correct branch in `astro.config.mjs`:

### Path A: Custom Domain (e.g., harvardintech.com)

1. Set `site` and `base` in `astro.config.mjs`:
   ```javascript
   site: 'https://harvardintech.com', // Your custom domain
   base: '/',
   ```
2. Create a file named `public/CNAME` in your project and write your custom domain name there (e.g., `harvardintech.com` without any protocol).
3. Update your DNS provider with the following records pointing to GitHub's servers:
   - A records:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`
   - CNAME record pointing to `<your-username>.github.io`

### Path B: Default GitHub Pages Subpath (e.g., user.github.io/repo)

1. Set `site` and `base` in `astro.config.mjs`:
   ```javascript
   site: 'https://<username>.github.io',
   base: '/<repo-name>/', // Must end with a trailing slash!
   ```

---

## Configuring GitHub Pages

1. Navigate to your repository on GitHub.
2. Go to **Settings** > **Pages**.
3. Under **Build and deployment** > **Source**, select **GitHub Actions** (instead of Deploy from a branch). This allows the automated workflow to build and push safely.
