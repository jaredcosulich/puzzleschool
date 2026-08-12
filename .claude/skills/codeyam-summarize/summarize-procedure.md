# /codeyam-summarize — procedure

The body of the `codeyam-summarize` skill. Read `SKILL.md` for the contract
this procedure must not violate; this file is the sequence.

Four short phases. All the extraction and rendering is done by
`codeyam-editor editor session-summarize`, which is deterministic and
tested — your job is the conversation around it, not the transformation.

---

## Phase 1 — Pick the session

Default to **the current session**. That is what the user almost always
means, and it needs no flag: the command locates this session's own
transcript on its own.

Only if the user asks for an earlier session, list the candidates:

```bash
node .claude/skills/review-session/scripts/find-last-session.mjs --list-sessions
```

Show them with their dates and let the user choose, then pass the chosen
path as `--session <path>`.

Do not read the transcript yourself to "check" it. It can be tens of
megabytes; the command streams it, and pulling it into context would cost
the whole window for no benefit.

## Phase 2 — Pick the destination

Ask, with `AskUserQuestion`. Never assume — the whole point is that the
user can find the file afterward.

- **Desktop** — recommended default. It is the first place a mail client's
  attachment picker opens to.
- **Downloads**
- **Documents**
- **Inside the project** (`.codeyam/summaries/`) — for keeping the summary
  with the work. It is gitignored, so it will not land in a commit.

Pass the answer as `--dest desktop|downloads|documents|project`. If the
machine has no such folder (common for Desktop on headless Linux), the
command says so and names what *is* available — relay that and re-ask
rather than silently picking another.

## Phase 3 — Name it

The filename is what the recipient sees. Propose a short title derived
from the session's first real prompt — or from what the user has been
working on in this session, which you already know — and confirm it.

Keep it to a few words. It is slugified into
`codeyam-session-<date>-<project>-<title>.html`.

## Phase 4 — Run it, then hand off

Run it **bare** — never piped through `tail`, `grep`, or `head`. A pipe
hands you the filter's exit code instead of the command's, and this
command uses exit `2` to mean "recoverable precondition, here is the fix".

```bash
codeyam-editor editor session-summarize \
  --dest <choice> \
  --title "<confirmed title>" \
  --format json
```

Add `--also-markdown` only if the user asked for a markdown copy too.

On success, tell the user:

1. **The absolute path**, on its own line, so it can be copied.
2. **The turn count** and how many raw messages it came from — this is the
   honest measure of how much mechanical noise was removed.
3. That the file is **self-contained**: no external CSS, fonts, scripts,
   or images, so it can be attached to an email directly and opened by
   anyone, offline.
4. **The redaction point**, from the contract, in your own words: the
   transcript is verbatim, so it may contain paths, hostnames, environment
   details, or anything pasted into the session. Offer to review it before
   they send. Do not scrub anything on your own initiative — ask first,
   and if they want changes, make exactly the ones they name.

If the command exits `2`, it printed a `BLOCKED:` reason and a
`Next valid action:` line. Do that action, or relay it to the user — do
not retry the same invocation unchanged.

---

## What this skill must not do

- Do not summarize, condense, or narrate the conversation in the artifact.
  The document is the conversation. If the user wants a narrative summary,
  that is a different request — offer to write one separately, in the chat.
- Do not commit, stage, push, or edit any project source.
- Do not overwrite an earlier summary. The command appends `-2`, `-3`, …
  by design: an existing file may be the exact bytes someone already
  received.
