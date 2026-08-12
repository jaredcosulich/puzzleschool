---
name: codeyam-summarize
user-invocable: true
disable-model-invocation: false
description: |
  Export this session as a shareable, self-contained HTML document of the
  conversation itself — every prompt and response, verbatim, with tool
  calls, command output, and internal steps collapsed to one-line beats.
  Writes it to a folder you pick (Desktop / Downloads / Documents / inside
  the project) with a name that is obvious in an email attachment picker.
  Read-only on the repo; nothing is committed or pushed.
---

# Export a session as a shareable conversation

This skill turns a working session into one HTML file you can email. The
document reproduces what was actually said — your prompts and the agent's
responses — and strips the machinery around them.

It is a thin, stable entry point. The phased procedure lives in the
version-controlled sibling so it can evolve through normal review instead
of silent self-edits:

**Read `.claude/skills/codeyam-summarize/summarize-procedure.md` now and
follow it.** Everything below is the contract; the procedure is the body.

## Contract

- **Faithful, and subtractive only.** Prompts and responses are reproduced
  verbatim, in order. Never rewrite, condense, paraphrase, or "improve" a
  turn — not in the file, and not when describing it. What makes this
  artifact worth sending is that it is evidence of how the interaction
  actually went. Trimming only ever *removes* the mechanical layer.
- **Read-only on the repo.** The skill reads a transcript and writes one
  HTML file to a destination the user chose. It never edits source, never
  stages, never commits, never pushes.
- **The destination is the user's explicit choice, never assumed.** The
  command refuses to guess; so should you. Ask, then pass the answer.
- **Redaction is offered, never silent.** Before handing over a file that
  is going to leave the machine, say plainly that the transcript is
  reproduced verbatim and may contain file paths, hostnames, environment
  details, or anything that was pasted into the session — and offer to
  review it. Do **not** auto-scrub: that would break faithfulness, and a
  quietly-edited transcript is worse than an honest one. Do not stay
  silent either: that ships secrets by default.
- **Stack-agnostic.** Nothing here touches project source, framework, test
  runner, or app shape. It reads an agent transcript and writes a file, so
  it behaves identically on a Rust CLI, a Flask backend, and a Vite app.

## Preflight

Confirm the project is initialized for codeyam-editor:

```bash
codeyam-editor editor config-show >/dev/null 2>&1 || {
  echo "Project is not initialized for codeyam-editor. Run /codeyam-onboard first."
  exit 1
}
```

If it fails, tell the user to run `/codeyam-onboard` and stop.

## Run

Work through `.claude/skills/codeyam-summarize/summarize-procedure.md` top
to bottom. The artifact is a single `.html` file at the destination the
user picked; re-running never overwrites an earlier one.
