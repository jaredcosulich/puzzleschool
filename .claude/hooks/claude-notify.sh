#!/usr/bin/env bash
# Send a one-tap iPhone notification that opens the Claude app.
# Tap on the notification fires the Click URL, which runs an iOS Shortcut
# named "Open Claude" (one action: Open App → Claude).
#
# NTFY_TOPIC resolution order (first wins):
#   1. Already exported in the calling shell
#   2. $HOME/.codeyam/notify.env (per-developer opt-in, never in any repo)
# When NTFY_TOPIC is still unset after both, the script silently no-ops
# (exit 0). Hooks always register at install time; the developer opts in
# later via `codeyam-editor editor notify-setup --topic <topic>`.
#
# Usage:
#   .claude/hooks/claude-notify.sh                     # default message
#   .claude/hooks/claude-notify.sh "Build finished"    # custom message
#   NTFY_TOPIC=<topic> .claude/hooks/claude-notify.sh  # one-shot override

set -u

# Per-user opt-in config. Lives outside any project so a developer's topic
# never leaks into a client repo. Shell env still wins (the conditional
# export only sets NTFY_TOPIC when it isn't already set).
if [ -z "${NTFY_TOPIC:-}" ] && [ -f "$HOME/.codeyam/notify.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$HOME/.codeyam/notify.env"
  set +a
fi

# Silently no-op when notifications aren't configured. Hooks always
# register at install time; this is the "user hasn't opted in yet" path.
if [ -z "${NTFY_TOPIC:-}" ]; then
  exit 0
fi

: "${NTFY_SERVER:=https://ntfy.sh}"
: "${NOTIFY_URL:=shortcuts://run-shortcut?name=Open%20Claude}"
: "${NOTIFY_TITLE:=Claude needs you}"

message="${1:-Tap to open Claude}"

http_code=$(curl -sS -o /tmp/ntfy-resp.txt -w "%{http_code}" \
  -H "Title: $NOTIFY_TITLE" \
  -H "Click: $NOTIFY_URL" \
  -d "$message" \
  "$NTFY_SERVER/$NTFY_TOPIC")

if [[ "$http_code" == "200" ]]; then
  echo "OK"
else
  echo "FAIL — HTTP $http_code, response: $(cat /tmp/ntfy-resp.txt)" >&2
  exit 1
fi
