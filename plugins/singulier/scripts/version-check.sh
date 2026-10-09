#!/usr/bin/env bash
# Daily check that the installed plugin is the latest published one. Sourced by
# sync-repo.sh; sets VERSION_NOTICE when an update is available. Never fails:
# offline, logged out or rate-limited simply means no notice today.

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$plugin_root/.claude-plugin/plugin.json"
VERSION_NOTICE=""

# First "key": "value" of a flat JSON document. No jq on stock machines.
json_value() {
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1
}

# True when version $1 is lower than version $2 (dotted numbers).
version_lt() {
  [ "$1" = "$2" ] && return 1
  awk -v a="$1" -v b="$2" 'BEGIN {
    n = split(a, x, "."); m = split(b, y, "."); if (m > n) n = m
    for (i = 1; i <= n; i++) { if (x[i] + 0 < y[i] + 0) exit 0; if (x[i] + 0 > y[i] + 0) exit 1 }
    exit 1 }'
}

# Runs a command, killing it after $1 seconds (no `timeout` on stock macOS).
with_timeout() {
  local seconds=$1 pid watcher status
  shift
  "$@" &
  pid=$!
  (sleep "$seconds" && kill "$pid" 2>/dev/null) &
  watcher=$!
  wait "$pid"
  status=$?
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  return $status
}

check_plugin_version() {
  local installed repo stamp_dir stamp latest
  installed=$(json_value version <"$manifest")
  repo=$(json_value repository <"$manifest" | sed -e 's#^https://github.com/##' -e 's#\.git$##')
  [ -n "$installed" ] && [ -n "$repo" ] || return 0
  command -v gh >/dev/null 2>&1 || return 0

  # At most one network call a day.
  stamp_dir=${CLAUDE_PLUGIN_DATA:-$HOME/.cache/singulier-claude}
  stamp="$stamp_dir/last-version-check"
  if [ -f "$stamp" ] && [ -z "$(find "$stamp" -mmin +1440 2>/dev/null)" ]; then
    latest=$(cat "$stamp")
  else
    latest=$(with_timeout 10 gh api -H "Accept: application/vnd.github.raw" \
      "repos/$repo/contents/plugins/singulier/.claude-plugin/plugin.json" 2>/dev/null | json_value version)
    [ -n "$latest" ] || return 0
    mkdir -p "$stamp_dir" 2>/dev/null && printf '%s' "$latest" >"$stamp"
  fi

  if version_lt "$installed" "$latest"; then
    VERSION_NOTICE="The Singulier plugin is outdated (installed $installed, latest $latest). Tell the user, in their language and plain words: fully quit the Claude app and reopen it; if this message comes back, type /plugin marketplace update singulier, then /reload-plugins."
  fi
  return 0
}
