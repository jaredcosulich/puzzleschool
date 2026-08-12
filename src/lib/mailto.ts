// Build a `mailto:` link with optional pre-filled subject/body.
//
// A static site can't process a contact form server-side, so the "Support Us"
// / "Contact" pattern is a plain mailto link the visitor's mail client opens.
// Centralizing the URL construction keeps subject lines consistent and the
// query string correctly encoded (spaces, punctuation, newlines).
export interface MailtoOptions {
  to: string;
  subject?: string;
  body?: string;
}

export function buildMailto({ to, subject, body }: MailtoOptions): string {
  const params = new URLSearchParams();
  if (subject) params.set('subject', subject);
  if (body) params.set('body', body);
  const query = params.toString();
  // URLSearchParams encodes spaces as `+`; mail clients expect `%20` in the
  // mailto query, so normalize it.
  const normalized = query.replace(/\+/g, '%20');
  return `mailto:${to}${normalized ? `?${normalized}` : ''}`;
}
