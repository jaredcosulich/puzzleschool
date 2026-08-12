#!/usr/bin/env node
// Finds session transcripts for review.
//
// Sources both Claude Code (~/.claude/projects/<hash>/<uuid>.jsonl) and
// Gemini CLI (~/.gemini/tmp/<project>/chats/session-*.jsonl) sessions.
//
// Usage:
//   node find-last-session.mjs                          # Most recent session for cwd's Claude project
//   node find-last-session.mjs --list-projects          # All projects with recent sessions (both sources)
//   node find-last-session.mjs --list-sessions          # List sessions for the resolved project(s)
//   node find-last-session.mjs --project=tea-test       # Substring-match a project name (both sources)
//   node find-last-session.mjs --project-dir=/full/path # Exact Claude project directory path
//   node find-last-session.mjs --source=claude          # Restrict to Claude sessions
//   node find-last-session.mjs --source=gemini          # Restrict to Gemini sessions
//   node find-last-session.mjs --nth=2                  # 2nd most recent session
//   node find-last-session.mjs --exclude=<uuid>         # Skip a specific session
//   node find-last-session.mjs --exclude-current        # Skip the currently-running session
//   node find-last-session.mjs --contains="some text"   # Print all sessions containing text (newest first)
//
// Output: Absolute path(s) to session .jsonl file(s) on stdout, status on stderr. Exits 1 if none match.

import { readdir, stat } from 'node:fs/promises';
import { createReadStream } from 'node:fs';
import { createInterface } from 'node:readline';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { claudeProjectHashFromPath } from './find-last-session-helpers.mjs';

const claudeRoot = join(homedir(), '.claude', 'projects');
const geminiRoot = join(homedir(), '.gemini', 'tmp');

const MAX_AGE_DAYS = 30;
const maxAgeMs = MAX_AGE_DAYS * 24 * 60 * 60 * 1000;
const now = Date.now();

// ── Args ─────────────────────────────────────────────────────────────────
const args = {
  excludeUuid: null,
  excludeCurrent: false,
  nth: 1,
  listProjects: false,
  listSessions: false,
  projectFilter: null,
  projectDirOverride: null,
  source: null, // 'claude' | 'gemini' | null (both)
  contains: null,
};
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith('--exclude=')) args.excludeUuid = arg.slice('--exclude='.length);
  else if (arg === '--exclude-current') args.excludeCurrent = true;
  else if (arg.startsWith('--nth=')) args.nth = parseInt(arg.slice('--nth='.length), 10) || 1;
  else if (arg === '--list-projects') args.listProjects = true;
  else if (arg === '--list-sessions') args.listSessions = true;
  else if (arg.startsWith('--project=')) args.projectFilter = arg.slice('--project='.length);
  else if (arg.startsWith('--project-dir=')) args.projectDirOverride = arg.slice('--project-dir='.length);
  else if (arg.startsWith('--source=')) args.source = arg.slice('--source='.length);
  else if (arg.startsWith('--contains=')) args.contains = arg.slice('--contains='.length);
}
const wantClaude = args.source !== 'gemini';
const wantGemini = args.source !== 'claude';

// ── Helpers ──────────────────────────────────────────────────────────────

/**
 * Convert a Claude project hash dirname back to a readable path.
 * e.g. "-Users-you-projects-my-app" → "/Users/you/projects/my-app"
 */
function claudeHashToReadablePath(hash) {
  return hash.replace(/^-/, '/').replace(/-/g, '/');
}

function eligibleStat(st) {
  if (!st.isFile()) return false;
  if (st.size < 512) return false;
  if (now - st.mtimeMs > maxAgeMs) return false;
  return true;
}

/**
 * Scan a Claude session JSONL for the latest `/rename` command and return its args,
 * or null if the session was never renamed. Streams line-by-line and skips
 * JSON parsing for lines that don't mention `/rename`.
 */
async function readClaudeSessionRenameLabel(sessionPath) {
  let latest = null;
  try {
    const stream = createReadStream(sessionPath, { encoding: 'utf8' });
    const rl = createInterface({ input: stream, crlfDelay: Infinity });
    for await (const line of rl) {
      if (!line.includes('/rename')) continue;
      let entry;
      try { entry = JSON.parse(line); } catch { continue; }
      if (entry.type !== 'system' || entry.subtype !== 'local_command') continue;
      const content = typeof entry.content === 'string' ? entry.content : '';
      if (!content.includes('<command-name>/rename</command-name>')) continue;
      const m = content.match(/<command-args>([\s\S]*?)<\/command-args>/);
      if (m && m[1].trim().length > 0) latest = m[1].trim();
    }
  } catch {
    return null;
  }
  return latest;
}

async function findClaudeSessionsInDir(sessionDir) {
  let entries;
  try { entries = await readdir(sessionDir); } catch { return []; }
  const out = [];
  for (const name of entries) {
    if (!name.endsWith('.jsonl')) continue;
    const uuid = name.replace('.jsonl', '');
    if (args.excludeUuid && uuid === args.excludeUuid) continue;
    const fullPath = join(sessionDir, name);
    try {
      const st = await stat(fullPath);
      if (!eligibleStat(st)) continue;
      out.push({ source: 'claude', path: fullPath, uuid, mtimeMs: st.mtimeMs, size: st.size });
    } catch { continue; }
  }
  out.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return out;
}

async function findGeminiSessionsInDir(chatsDir) {
  let entries;
  try { entries = await readdir(chatsDir); } catch { return []; }
  const out = [];
  for (const name of entries) {
    if (!name.startsWith('session-')) continue;
    if (!name.endsWith('.jsonl')) continue; // older `.json` blobs aren't streamable transcripts
    const fullPath = join(chatsDir, name);
    // Filename: session-<ISO-date>-<short-uuid>.jsonl
    const m = name.match(/^session-.+-([0-9a-fA-F]+)\.jsonl$/);
    const uuid = m ? m[1] : name.slice('session-'.length, -'.jsonl'.length);
    if (args.excludeUuid && uuid === args.excludeUuid) continue;
    try {
      const st = await stat(fullPath);
      if (!eligibleStat(st)) continue;
      out.push({ source: 'gemini', path: fullPath, uuid, mtimeMs: st.mtimeMs, size: st.size });
    } catch { continue; }
  }
  out.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return out;
}

async function listClaudeProjects() {
  let dirs;
  try { dirs = await readdir(claudeRoot); } catch { return []; }
  const out = [];
  for (const name of dirs) {
    const dirPath = join(claudeRoot, name);
    const sessions = await findClaudeSessionsInDir(dirPath);
    if (sessions.length === 0) continue;
    out.push({
      source: 'claude',
      dirName: name,
      dirPath,
      readablePath: claudeHashToReadablePath(name),
      sessions,
    });
  }
  return out;
}

async function listGeminiProjects() {
  let dirs;
  try { dirs = await readdir(geminiRoot); } catch { return []; }
  const out = [];
  for (const name of dirs) {
    // Skip non-project subdirs that share `~/.gemini/tmp`
    if (name === 'background-processes' || name === 'bin') continue;
    const chatsDir = join(geminiRoot, name, 'chats');
    try {
      const st = await stat(chatsDir);
      if (!st.isDirectory()) continue;
    } catch { continue; }
    const sessions = await findGeminiSessionsInDir(chatsDir);
    if (sessions.length === 0) continue;
    out.push({
      source: 'gemini',
      dirName: name,
      dirPath: chatsDir,
      readablePath: name, // Gemini stores by the project's last-path-segment, not a hash
      sessions,
    });
  }
  return out;
}

async function sessionContains(filePath, needle) {
  const lc = needle.toLowerCase();
  const stream = createReadStream(filePath, { encoding: 'utf8' });
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

// ── --list-projects ──────────────────────────────────────────────────────
if (args.listProjects) {
  const projects = [];
  if (wantClaude) projects.push(...(await listClaudeProjects()));
  if (wantGemini) projects.push(...(await listGeminiProjects()));
  if (projects.length === 0) {
    process.stderr.write('No projects with recent sessions found.\n');
    process.exit(1);
  }
  projects.sort((a, b) => b.sessions[0].mtimeMs - a.sessions[0].mtimeMs);
  process.stdout.write('Recent projects with session transcripts:\n\n');
  for (const p of projects.slice(0, 20)) {
    const date = new Date(p.sessions[0].mtimeMs).toISOString().replace('T', ' ').slice(0, 19);
    process.stdout.write(`  [${p.source}] ${p.readablePath}\n`);
    process.stdout.write(`    Dir: ${p.dirName}\n`);
    process.stdout.write(`    Sessions: ${p.sessions.length}, Latest: ${date}\n\n`);
  }
  process.exit(0);
}

// ── Resolve candidate sessions ───────────────────────────────────────────
let candidateSessions = [];
let resolvedLabel = null;

if (args.projectDirOverride) {
  // Exact path: Claude only (Gemini doesn't use a path-derived hash)
  if (wantClaude) {
    const projectHash = claudeProjectHashFromPath(args.projectDirOverride);
    candidateSessions = await findClaudeSessionsInDir(join(claudeRoot, projectHash));
    resolvedLabel = `[claude] ${args.projectDirOverride}`;
  }
} else if (args.projectFilter) {
  const filter = args.projectFilter.toLowerCase();
  const projects = [];
  if (wantClaude) projects.push(...(await listClaudeProjects()));
  if (wantGemini) projects.push(...(await listGeminiProjects()));
  const matches = projects.filter(
    (p) =>
      p.readablePath.toLowerCase().includes(filter) ||
      p.dirName.toLowerCase().includes(filter)
  );
  if (matches.length === 0) {
    process.stderr.write(`No projects matching "${args.projectFilter}" with recent sessions found.\n`);
    process.exit(1);
  }
  // Multiple matches across sources is OK when listing/searching — they're labeled.
  // It's only ambiguous when picking a single nth session and we don't have --source to disambiguate.
  if (matches.length > 1 && !args.listSessions && !args.contains) {
    process.stderr.write(`Multiple projects match "${args.projectFilter}":\n\n`);
    for (const m of matches) {
      process.stderr.write(`  [${m.source}] ${m.readablePath}\n    Dir: ${m.dirName}\n    Sessions: ${m.sessions.length}\n\n`);
    }
    process.stderr.write(`Narrow with --source=claude|gemini, a more specific --project=<substring>, or --project-dir=<path>.\n`);
    process.exit(1);
  }
  for (const m of matches) candidateSessions.push(...m.sessions);
  if (matches.length === 1) resolvedLabel = `[${matches[0].source}] ${matches[0].readablePath}`;
} else {
  // Default: cwd-based Claude project. (Gemini has no stable cwd→project mapping; require --project.)
  if (wantClaude) {
    const projectDir = process.cwd();
    const projectHash = claudeProjectHashFromPath(projectDir);
    candidateSessions = await findClaudeSessionsInDir(join(claudeRoot, projectHash));
    resolvedLabel = `[claude] ${projectDir}`;
  }
  if (args.source === 'gemini') {
    // No --project filter and explicit --source=gemini — search all Gemini projects
    const projects = await listGeminiProjects();
    for (const p of projects) candidateSessions.push(...p.sessions);
  }
}

// Apply --exclude-current. Only meaningful for the cwd Claude project's most-recent session.
if (args.excludeCurrent && candidateSessions.length > 0) {
  const cwdHash = claudeProjectHashFromPath(process.cwd());
  const top = candidateSessions[0];
  if (top.source === 'claude' && top.path.includes(`/${cwdHash}/`)) {
    candidateSessions = candidateSessions.slice(1);
  }
}

if (candidateSessions.length === 0) {
  process.stderr.write(`No eligible session transcripts found.\n`);
  process.exit(1);
}

candidateSessions.sort((a, b) => b.mtimeMs - a.mtimeMs);

// ── --contains ───────────────────────────────────────────────────────────
if (args.contains) {
  if (resolvedLabel) process.stderr.write(`Searching ${resolvedLabel} (${candidateSessions.length} sessions)\n`);
  const matches = [];
  for (const s of candidateSessions) {
    try {
      if (await sessionContains(s.path, args.contains)) matches.push(s);
    } catch { continue; }
  }
  if (matches.length === 0) {
    process.stderr.write(`No sessions containing "${args.contains}" found.\n`);
    process.exit(1);
  }
  process.stderr.write(`${matches.length} session(s) contain "${args.contains}":\n\n`);
  for (const s of matches) {
    const date = new Date(s.mtimeMs).toISOString().replace('T', ' ').slice(0, 19);
    const sizeKb = Math.round(s.size / 1024);
    process.stderr.write(`  [${s.source}] ${s.uuid}  (${sizeKb}KB, ${date})\n    ${s.path}\n\n`);
    process.stdout.write(`${s.path}\n`);
  }
  process.exit(0);
}

// ── --list-sessions ──────────────────────────────────────────────────────
if (args.listSessions) {
  const shown = candidateSessions.slice(0, 10);
  const labels = await Promise.all(
    shown.map((s) => (s.source === 'claude' ? readClaudeSessionRenameLabel(s.path) : Promise.resolve(null)))
  );
  if (resolvedLabel) process.stdout.write(`Project: ${resolvedLabel}\n`);
  process.stdout.write(`Sessions (${candidateSessions.length} found):\n\n`);
  for (let i = 0; i < shown.length; i++) {
    const s = shown[i];
    const sizeKb = Math.round(s.size / 1024);
    const date = new Date(s.mtimeMs).toISOString().replace('T', ' ').slice(0, 19);
    const label = labels[i] ? ` — "${labels[i]}"` : '';
    process.stdout.write(`  ${i + 1}. [${s.source}] ${s.uuid}${label}\n`);
    process.stdout.write(`     Size: ${sizeKb}KB, Last modified: ${date}\n`);
    process.stdout.write(`     Path: ${s.path}\n\n`);
  }
  process.exit(0);
}

// ── Default: print nth session path ──────────────────────────────────────
const target = candidateSessions[Math.min(args.nth - 1, candidateSessions.length - 1)];
const sizeKb = Math.round(target.size / 1024);
const date = new Date(target.mtimeMs).toISOString().replace('T', ' ').slice(0, 19);

process.stdout.write(`${target.path}\n`);
process.stderr.write(`Session: [${target.source}] ${target.uuid} (${sizeKb}KB, last modified ${date})\n`);
