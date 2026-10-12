// Pure helpers extracted from find-last-session.mjs so they're importable
// in tests without auto-running the script's top-level CLI dispatch.
//
// `now` and `maxAgeMs` are factored as parameters or have explicit defaults
// to keep eligibleStat deterministic across the test boundary.

import { readdir, readFile, stat } from "node:fs/promises";
import { createReadStream } from "node:fs";
import { createInterface } from "node:readline";
import { join } from "node:path";

export const MAX_AGE_DAYS = 30;
export const MAX_AGE_MS = MAX_AGE_DAYS * 24 * 60 * 60 * 1000;

/**
 * Where the editor records which of a project's sessions were unattended
 * Build runs, relative to the project root. Written by control-api's
 * `build_session_transcript` module beside the broker's `session-exits.jsonl`.
 */
export const BUILD_SESSION_TRANSCRIPTS_PATH = join(
  ".codeyam",
  "run",
  "build-session-transcripts.jsonl"
);

/**
 * Extract the provider session ids recorded as Build runs from the raw
 * contents of `build-session-transcripts.jsonl`.
 *
 * Pure and deliberately forgiving: the file is appended to by a process that
 * can be killed mid-write, so a truncated or malformed line is skipped rather
 * than discarding the rows around it. A row with no `providerSessionId` is
 * ignored — labelling is a nicety, and a bad row must never cost the caller
 * its session list.
 */
export function buildSessionIdsFromJsonl(text) {
  const ids = new Set();
  for (const line of String(text ?? "").split("\n")) {
    if (line.trim() === "") continue;
    let row;
    try {
      row = JSON.parse(line);
    } catch {
      continue;
    }
    if (row && typeof row.providerSessionId === "string" && row.providerSessionId !== "") {
      ids.add(row.providerSessionId);
    }
  }
  return ids;
}

/**
 * The set of session ids that were unattended Build runs for `projectDir`.
 *
 * A project that has never run one — or is not a codeyam project at all —
 * has no such file, and an empty set is the correct answer for it: every
 * session then lists exactly as it does today.
 */
export async function readBuildSessionIds(projectDir) {
  if (!projectDir) return new Set();
  try {
    return buildSessionIdsFromJsonl(
      await readFile(join(projectDir, BUILD_SESSION_TRANSCRIPTS_PATH), "utf8")
    );
  } catch {
    return new Set();
  }
}

/**
 * The source tag shown for a session. A Build run is labelled `build` rather
 * than by its provider, because "which of these did the editor drive
 * unattended?" is the question the label has to answer — the provider is
 * already implied by the project it sits under.
 */
export function sessionSourceLabel(session) {
  return session.build ? "build" : session.source;
}

/**
 * Convert Claude's flat-encoded project directory name (e.g.
 * `-Users-jared-projects-foo`) back into the original filesystem path.
 */
export function claudeHashToReadablePath(hash) {
  return hash.replace(/^-/, "/").replace(/-/g, "/");
}

/**
 * Mirror Claude Code's cwd→project-dir encoding: every character outside
 * `[A-Za-z0-9-]` is replaced with `-`. Used to derive the
 * `~/.claude/projects/<hash>` directory for a project path. Replacing
 * only `/` and `.` (the old behavior) mishashed paths containing spaces,
 * underscores, parens, or non-ASCII, so the lookup missed and the
 * envelope download rendered an empty transcript. Confirmed against
 * anthropics/claude-code#19972.
 */
export function claudeProjectHashFromPath(p) {
  return p.replace(/[^A-Za-z0-9-]/g, "-");
}

/**
 * Return true when the given `fs.Stats` describes a file that is
 * large enough and recent enough (default 30 days) to count as a
 * usable session for the review-session picker.
 */
export function eligibleStat(st, { now = Date.now(), maxAgeMs = MAX_AGE_MS } = {}) {
  if (!st.isFile()) return false;
  if (st.size < 512) return false;
  if (now - st.mtimeMs > maxAgeMs) return false;
  return true;
}

/**
 * Stream a Claude session JSONL file and return the most recent
 * `/rename` command argument used to relabel the session, or `null`
 * if none was issued.
 */
export async function readClaudeSessionRenameLabel(sessionPath) {
  let latest = null;
  try {
    const stream = createReadStream(sessionPath, { encoding: "utf8" });
    const rl = createInterface({ input: stream, crlfDelay: Infinity });
    for await (const line of rl) {
      if (!line.includes("/rename")) continue;
      let entry;
      try {
        entry = JSON.parse(line);
      } catch {
        continue;
      }
      if (entry.type !== "system" || entry.subtype !== "local_command") continue;
      const content = typeof entry.content === "string" ? entry.content : "";
      if (!content.includes("<command-name>/rename</command-name>")) continue;
      const m = content.match(/<command-args>([\s\S]*?)<\/command-args>/);
      if (m && m[1].trim().length > 0) latest = m[1].trim();
    }
  } catch {
    return null;
  }
  return latest;
}

/**
 * List eligible Claude `*.jsonl` session files in `sessionDir`,
 * sorted newest first, optionally excluding a specific session UUID.
 */
export async function findClaudeSessionsInDir(sessionDir, { excludeUuid = null } = {}) {
  let entries;
  try {
    entries = await readdir(sessionDir);
  } catch {
    return [];
  }
  const out = [];
  for (const name of entries) {
    if (!name.endsWith(".jsonl")) continue;
    const uuid = name.replace(".jsonl", "");
    if (excludeUuid && uuid === excludeUuid) continue;
    const fullPath = join(sessionDir, name);
    try {
      const st = await stat(fullPath);
      if (!eligibleStat(st)) continue;
      out.push({ source: "claude", path: fullPath, uuid, mtimeMs: st.mtimeMs, size: st.size });
    } catch {
      continue;
    }
  }
  out.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return out;
}

/**
 * List eligible Gemini `session-*.jsonl` files in a chats directory,
 * sorted newest first, optionally excluding a specific session UUID.
 */
export async function findGeminiSessionsInDir(chatsDir, { excludeUuid = null } = {}) {
  let entries;
  try {
    entries = await readdir(chatsDir);
  } catch {
    return [];
  }
  const out = [];
  for (const name of entries) {
    if (!name.startsWith("session-")) continue;
    if (!name.endsWith(".jsonl")) continue;
    const fullPath = join(chatsDir, name);
    const m = name.match(/^session-.+-([0-9a-fA-F]+)\.jsonl$/);
    const uuid = m ? m[1] : name.slice("session-".length, -".jsonl".length);
    if (excludeUuid && uuid === excludeUuid) continue;
    try {
      const st = await stat(fullPath);
      if (!eligibleStat(st)) continue;
      out.push({ source: "gemini", path: fullPath, uuid, mtimeMs: st.mtimeMs, size: st.size });
    } catch {
      continue;
    }
  }
  out.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return out;
}

/**
 * Enumerate Claude project directories under `claudeRoot`, returning
 * project metadata and the sorted list of sessions for each one.
 */
export async function listClaudeProjects(claudeRoot) {
  let dirs;
  try {
    dirs = await readdir(claudeRoot);
  } catch {
    return [];
  }
  const out = [];
  for (const name of dirs) {
    const dirPath = join(claudeRoot, name);
    const sessions = await findClaudeSessionsInDir(dirPath);
    if (sessions.length === 0) continue;
    out.push({
      source: "claude",
      dirName: name,
      dirPath,
      readablePath: claudeHashToReadablePath(name),
      sessions,
    });
  }
  return out;
}

/**
 * Enumerate Gemini project directories under `geminiRoot`, skipping
 * non-project entries and returning per-project metadata with the
 * sorted list of sessions.
 */
export async function listGeminiProjects(geminiRoot) {
  let dirs;
  try {
    dirs = await readdir(geminiRoot);
  } catch {
    return [];
  }
  const out = [];
  for (const name of dirs) {
    if (name === "background-processes" || name === "bin") continue;
    const chatsDir = join(geminiRoot, name, "chats");
    try {
      const st = await stat(chatsDir);
      if (!st.isDirectory()) continue;
    } catch {
      continue;
    }
    const sessions = await findGeminiSessionsInDir(chatsDir);
    if (sessions.length === 0) continue;
    out.push({
      source: "gemini",
      dirName: name,
      dirPath: chatsDir,
      readablePath: name,
      sessions,
    });
  }
  return out;
}

/**
 * Stream the session file and return true as soon as any line
 * contains `needle` (case-insensitive), short-circuiting on the first
 * match.
 */
export async function sessionContains(filePath, needle) {
  const lc = needle.toLowerCase();
  const stream = createReadStream(filePath, { encoding: "utf8" });
  const rl = createInterface({ input: stream, crlfDelay: Infinity });
  for await (const line of rl) {
    if (line.toLowerCase().includes(lc)) {
      rl.close();
      stream.destroy();
      return true;
    }
  }
  return false;
}
