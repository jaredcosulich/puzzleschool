// Compose the `<head>` title for a page: "Page · Site".
//
// The site-title suffix exists to give a page context wherever its title is
// read out of place — a crowded tab strip, a search result, a shared link
// preview. When the page title already IS the site title there is no context
// left to add, so the suffix becomes plain duplication ("The Puzzle School ·
// The Puzzle School"). Home hits exactly that case: its content title and the
// site title are the same string, and both are CMS-editable, so the collision
// can reappear from a content edit with no code review in the loop. Deduping
// here — in the one place the site composes a title — is what makes that safe.
export function composePageTitle(pageTitle: string | undefined, siteTitle: string): string {
  const trimmed = pageTitle?.trim();
  if (!trimmed) return siteTitle;
  // Compare loosely: a stray trailing space or different casing from the CMS is
  // the same duplication to a reader, and an exact `===` would sail past it.
  if (trimmed.toLowerCase() === siteTitle.trim().toLowerCase()) return siteTitle;
  return `${trimmed} · ${siteTitle}`;
}
