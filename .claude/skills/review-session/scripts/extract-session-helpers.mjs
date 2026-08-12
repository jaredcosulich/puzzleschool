// Pure helpers extracted from extract-session.mjs so they're importable
// in tests without auto-running the script's top-level CLI dispatch.

/**
 * Decide the transcript format from the file path alone.
 *
 * Returns `'gemini'` for Gemini CLI paths (`/.gemini/` or `/chats/session-`),
 * `'claude'` for `/.claude/` paths, and `null` when the path is inconclusive
 * (e.g. a transcript fetched to `/tmp` during a fleet review). The caller
 * then falls back to a content scan via `detectFormatFromRecords`.
 */
export function detectFormatFromPath(inputFile) {
  if (inputFile.includes('/.gemini/') || /\/chats\/session-/.test(inputFile)) return 'gemini';
  if (inputFile.includes('/.claude/')) return 'claude';
  return null;
}

/**
 * Decide the transcript format by scanning a window of parseable records for
 * the first content-bearing Claude or Gemini shape. Returns `'claude'`,
 * `'gemini'`, or `null` when no record in the window is decisive.
 *
 * Critically, a bare top-level `sessionId` is NOT a Gemini signal: current
 * Claude transcripts lead with `last-prompt` / `bridge-session` records that
 * carry `sessionId` but no message body. Treating `sessionId` as Gemini (the
 * old heuristic) misclassified the entire file and parsed zero messages.
 */
export function detectFormatFromRecords(records) {
  for (const obj of records) {
    if (!obj || typeof obj !== 'object') continue;
    // Unambiguous Claude message/summary shapes.
    if ((obj.type === 'user' || obj.type === 'assistant') && obj.message) return 'claude';
    if (obj.type === 'summary' && 'summary' in obj) return 'claude';
    // Unambiguous Gemini shapes (never a bare `sessionId`).
    if (obj.kind === 'main') return 'gemini';
    if (obj.type === 'gemini') return 'gemini';
    if (obj.type === 'info' && typeof obj.content === 'string') return 'gemini';
    // Generic Claude fallback: a message body without an explicit recognised type.
    if (obj.message) return 'claude';
  }
  return null;
}

/**
 * Resolve the transcript format: prefer the path, then a content scan over the
 * sampled records, then `fallback` (historically `'gemini'`) only once the
 * window is exhausted — so a leading metadata preamble can't short-circuit it.
 */
export function detectFormat(inputFile, records, fallback = 'gemini') {
  return detectFormatFromPath(inputFile) ?? detectFormatFromRecords(records) ?? fallback;
}

/**
 * Truncate `s` to `max` characters, appending a `...[truncated]`
 * marker when the value was cut.
 */
export function truncate(s, max) {
  return s.length > max ? s.slice(0, max) + '...[truncated]' : s;
}

/**
 * Format a timestamp as an `HH:MM:SS` string, returning `'?'` when
 * the value is falsy or unparseable.
 */
export function formatTs(ts) {
  if (!ts) return '?';
  try {
    return new Date(ts).toISOString().replace('T', ' ').slice(11, 19);
  } catch {
    return String(ts);
  }
}

/**
 * The wrapper tags the harness injects into the `user` role, mapped to the
 * kind of injection each represents.
 *
 * Not every `role: 'user'` record is something a human typed. Claude Code
 * folds `<system-reminder>` context blocks, slash-command envelopes, and hook
 * output into the same role as real prompts. A "faithful transcript of the
 * prompts" that renders those as user speech is wrong in exactly the way that
 * matters most for a shareable document — it attributes machine text to the
 * person.
 *
 * Order matters only for the *reported* kind when a record is entirely
 * injected: the earlier entry wins, so a slash-command envelope that also
 * carries a reminder reports as `command-envelope`.
 */
const INJECTED_USER_BLOCKS = [
  ['command-name', 'command-envelope'],
  ['command-message', 'command-envelope'],
  ['command-args', 'command-envelope'],
  ['local-command-stdout', 'command-envelope'],
  ['local-command-stderr', 'command-envelope'],
  ['local-command-caveat', 'command-envelope'],
  ['user-prompt-submit-hook', 'hook-output'],
  ['session-start-hook', 'hook-output'],
  ['post-tool-use-hook', 'hook-output'],
  ['system-reminder', 'system-reminder'],
];

/**
 * Classify a `role: 'user'` record's text and recover the human-authored part.
 *
 * Returns `{ kind, human }` where `kind` is one of `human`,
 * `command-envelope`, `hook-output`, `system-reminder`, or `empty`, and
 * `human` is the text with every injected block removed.
 *
 * The two cases that matter:
 *
 * - A record that is *only* an injected block has an empty remainder and
 *   reports the injection's kind — the conversation renderer folds it into a
 *   collapsed beat instead of showing it as a prompt.
 * - A real prompt that carries an *appended* reminder (the common shape —
 *   the harness appends context to what the user typed) reports `human` with
 *   the reminder stripped and the prompt intact. Dropping the whole record
 *   here would silently lose real user speech.
 *
 * Pure and total: any non-string input classifies as `empty`.
 */
export function classifyUserText(text) {
  if (typeof text !== 'string' || text.trim() === '') {
    return { kind: 'empty', human: '' };
  }

  // A slash command's expanded skill body arrives in the user role as a whole
  // document beginning with this header. It is the machine's expansion of what
  // the human typed (`/codeyam-editor`), not speech — rendering it as a prompt
  // attributes pages of instructions to the user. Anchored to the very start so
  // a message that merely mentions the phrase is untouched.
  if (/^\s*Base directory for this skill:\s*\S/.test(text)) {
    return { kind: 'command-envelope', human: '' };
  }

  let remainder = text;
  let injectedKind = null;

  for (const [tag, kind] of INJECTED_USER_BLOCKS) {
    // Paired block first, then any orphan open/close tag left by a truncated
    // or streamed record — an unmatched `<system-reminder>` must not survive
    // into the human remainder and read as something the user typed.
    const paired = new RegExp(`<${tag}>[\\s\\S]*?</${tag}>`, 'g');
    const orphan = new RegExp(`</?${tag}>`, 'g');
    for (const re of [paired, orphan]) {
      // Compare against the replacement rather than calling `re.test` first —
      // a `g`-flagged regex carries `lastIndex` state across calls, and that
      // has burned this pattern before.
      const stripped = remainder.replace(re, '');
      if (stripped !== remainder) {
        if (injectedKind === null) injectedKind = kind;
        remainder = stripped;
      }
    }
  }

  const human = remainder.trim();
  if (human !== '') return { kind: 'human', human };
  return { kind: injectedKind ?? 'empty', human: '' };
}

/**
 * Collapse the parsed message stream into an ordered list of conversation
 * turns: `user`, `assistant`, and `beat`.
 *
 * Trimming is **subtractive only** — a `user` or `assistant` turn carries its
 * source text verbatim. Nothing here paraphrases, summarizes, or reorders.
 *
 * The mechanical layer (tool calls, tool results, thinking blocks, and
 * harness-injected user records) never appears expanded. Instead a contiguous
 * run of it between two visible turns collapses into a single `beat` turn
 * naming how much happened and which distinct tools ran. That single line is
 * deliberate: it answers "was the agent working here, or stalled?", which a
 * bare gap in the transcript does not.
 *
 * Tool *results* are not counted — they are the other half of a call already
 * counted as a `tool_use`, and counting both would double every number.
 *
 * Lives here rather than in `extract-session.mjs` because that script runs its
 * CLI dispatch at import time, so anything defined there cannot be unit-tested.
 */
export function buildConversationTurns(messages) {
  const turns = [];
  let beat = null;

  function flushBeat() {
    if (!beat) return;
    const parts = [];
    if (beat.toolCalls > 0) {
      const names = [...beat.tools].join(', ');
      parts.push(
        `${beat.toolCalls} tool call${beat.toolCalls === 1 ? '' : 's'}` +
          (names ? `: ${names}` : '')
      );
    }
    if (beat.internalSteps > 0) {
      parts.push(`${beat.internalSteps} internal step${beat.internalSteps === 1 ? '' : 's'}`);
    }
    turns.push({
      kind: 'beat',
      text: `[${parts.join('; ')}]`,
      ts: beat.ts,
      tools: [...beat.tools],
      toolCalls: beat.toolCalls,
      internalSteps: beat.internalSteps,
    });
    beat = null;
  }

  function addToolCall(ts, name) {
    if (!beat) beat = { ts, tools: new Set(), toolCalls: 0, internalSteps: 0 };
    beat.toolCalls++;
    if (name) beat.tools.add(name);
  }

  function addInternalStep(ts) {
    if (!beat) beat = { ts, tools: new Set(), toolCalls: 0, internalSteps: 0 };
    beat.internalSteps++;
  }

  function emit(kind, text, ts) {
    if (!text || !text.trim()) return;
    flushBeat();
    turns.push({ kind, text: text.trim(), ts: ts ?? null });
  }

  for (const msg of messages) {
    if (msg.role === 'user') {
      const { kind, human } = classifyUserText(msg.text);
      if (kind === 'human') emit('user', human, msg.ts);
      else if (kind !== 'empty') addInternalStep(msg.ts);
      continue;
    }

    if (msg.role === 'user_complex') {
      // Tool results carry no human speech, but a `user_complex` record can
      // also hold real text parts (a prompt sent alongside a tool result).
      // Classify those the same way so an appended reminder is stripped and
      // genuine text still survives.
      const text = (msg.parts ?? [])
        .filter((p) => p.kind === 'text')
        .map((p) => p.text)
        .join('\n');
      const { kind, human } = classifyUserText(text);
      if (kind === 'human') emit('user', human, msg.ts);
      else if (kind !== 'empty') addInternalStep(msg.ts);
      continue;
    }

    if (msg.role === 'assistant') {
      // Walk parts in order so a text response that lands between two tool
      // calls stays between them rather than being hoisted out of sequence.
      let pending = [];
      for (const part of msg.parts ?? []) {
        if (part.kind === 'text') {
          pending.push(part.text);
          continue;
        }
        if (pending.length > 0) {
          emit('assistant', pending.join('\n'), msg.ts);
          pending = [];
        }
        if (part.kind === 'tool') addToolCall(msg.ts, part.name);
        else if (part.kind === 'thinking') addInternalStep(msg.ts);
      }
      if (pending.length > 0) emit('assistant', pending.join('\n'), msg.ts);
    }
  }

  flushBeat();
  return turns;
}

/**
 * Push a Claude transcript record onto `messages`, normalizing
 * user / assistant / tool_use / tool_result shapes into the shared
 * review-session message format.
 */
export function appendClaudeMessage(obj, messages) {
  if (!obj.type) return;

  if (obj.type === 'user') {
    const content = obj.message?.content;
    if (!content) return;
    if (typeof content === 'string') {
      messages.push({ role: 'user', text: content, ts: obj.timestamp });
    } else if (Array.isArray(content)) {
      const parts = [];
      let hasError = false;
      for (const item of content) {
        if (item.type === 'tool_result') {
          const t = typeof item.content === 'string' ? item.content : JSON.stringify(item.content);
          if (item.is_error) hasError = true;
          parts.push({ kind: 'tool_result', error: !!item.is_error, text: truncate(t, 800) });
        } else if (typeof item === 'string') {
          parts.push({ kind: 'text', text: item });
        } else if (item.type === 'text') {
          parts.push({ kind: 'text', text: item.text });
        }
      }
      messages.push({ role: 'user_complex', parts, hasError, ts: obj.timestamp });
    }
    return;
  }

  if (obj.type === 'assistant') {
    const items = obj.message?.content;
    if (!Array.isArray(items)) return;
    const parts = [];
    for (const item of items) {
      if (item.type === 'text' && item.text) {
        parts.push({ kind: 'text', text: item.text });
      } else if (item.type === 'thinking') {
        const t = item.thinking || '';
        parts.push({ kind: 'thinking', text: truncate(t, 1500) });
      } else if (item.type === 'tool_use') {
        const inputStr = typeof item.input === 'string' ? item.input : JSON.stringify(item.input);
        parts.push({ kind: 'tool', name: item.name, input: truncate(inputStr, 500) });
      }
    }
    if (parts.length > 0) messages.push({ role: 'assistant', parts, ts: obj.timestamp });
  }
}

/**
 * Pull the textual `output` / `error` payload out of a Gemini tool
 * call's `result[]` array, returning `{ error, text }` or `null` when
 * no functionResponse was attached.
 */
export function extractGeminiToolResult(tc) {
  if (!Array.isArray(tc.result) || tc.result.length === 0) return null;
  const texts = [];
  let error = false;
  for (const r of tc.result) {
    const fr = r?.functionResponse?.response;
    if (!fr) continue;
    if (fr.error) {
      error = true;
      if (typeof fr.error === 'string') texts.push(fr.error);
      else texts.push(JSON.stringify(fr.error));
      continue;
    }
    if (typeof fr.output === 'string') texts.push(fr.output);
    else if (fr.output !== undefined) texts.push(JSON.stringify(fr.output));
    else texts.push(JSON.stringify(fr));
  }
  if (texts.length === 0) texts.push(JSON.stringify(tc.result));
  return { error, text: truncate(texts.join('\n'), 800) };
}

/**
 * Push a Gemini transcript record onto `messages`, normalizing
 * user / gemini / info shapes (including thoughts and tool calls)
 * into the shared review-session message format.
 */
export function appendGeminiMessage(obj, messages) {
  if (obj.type === 'user') {
    let text;
    if (typeof obj.content === 'string') {
      text = obj.content;
    } else if (Array.isArray(obj.content)) {
      text = obj.content
        .map((p) => (typeof p === 'string' ? p : p?.text || ''))
        .filter(Boolean)
        .join('\n');
    } else {
      return;
    }
    if (text && text.trim()) messages.push({ role: 'user', text, ts: obj.timestamp });
    return;
  }

  if (obj.type === 'gemini') {
    const parts = [];
    if (Array.isArray(obj.thoughts)) {
      for (const t of obj.thoughts) {
        const txt = typeof t === 'string' ? t : t?.text || '';
        if (!txt) continue;
        parts.push({ kind: 'thinking', text: truncate(txt, 1500) });
      }
    }
    if (typeof obj.content === 'string' && obj.content.length > 0) {
      parts.push({ kind: 'text', text: obj.content });
    }
    const toolResults = [];
    if (Array.isArray(obj.toolCalls)) {
      for (const tc of obj.toolCalls) {
        const inputStr = JSON.stringify(tc.args ?? {});
        parts.push({ kind: 'tool', name: tc.name || '?', input: truncate(inputStr, 500) });
        const result = extractGeminiToolResult(tc);
        if (result) toolResults.push(result);
      }
    }
    if (parts.length > 0) {
      messages.push({ role: 'assistant', parts, ts: obj.timestamp });
    }
    if (toolResults.length > 0) {
      messages.push({
        role: 'user_complex',
        parts: toolResults.map((r) => ({ kind: 'tool_result', error: r.error, text: r.text })),
        hasError: toolResults.some((r) => r.error),
        ts: obj.timestamp,
      });
    }
    return;
  }

  if (obj.type === 'info') {
    if (typeof obj.content === 'string' && obj.content.trim()) {
      messages.push({ role: 'user', text: `[info] ${obj.content}`, ts: obj.timestamp });
    }
  }
}
