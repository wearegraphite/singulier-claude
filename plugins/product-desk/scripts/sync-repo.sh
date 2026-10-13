#!/usr/bin/env bash
# Fast-forwards the clones of the Singulier workspace to their reference
# branch, so non-technical users always read current code.
# Never merges, never discards local work, never blocks the session.
#
# Two modes:
#   (no argument)  SessionStart: always syncs.
#   prompt         UserPromptSubmit: syncs a clone only if its last attempt is
#                  older than SINGULIER_SYNC_HOURS (default 4), so a session
#                  left open for days still reads current code without a
#                  network call at every message.
set -u
. "$(dirname "$0")/lib.sh"

mode=${1:-session}
hours=${SINGULIER_SYNC_HOURS:-4}
case "$hours" in '' | *[!0-9]*) hours=4 ;; esac
interval=$((hours * 3600))
now=$(date +%s)

# Stamp kept inside .git, so it never shows up as a local change. It records
# the last attempt, successful or not: an offline laptop is not retried at
# every message.
stamp_file() { printf '%s/singulier-last-sync' "$(git -C "$1" rev-parse --absolute-git-dir)"; }
sync_due() {
  local last
  [ "$mode" = prompt ] || return 0
  last=$(cat "$(stamp_file "$1")" 2>/dev/null)
  case "$last" in '' | *[!0-9]*) return 0 ;; esac
  [ $((now - last)) -lt 0 ] || [ $((now - last)) -ge "$interval" ]
}

cat >/dev/null # the hook input is not needed

dir=$(canonical_path "${CLAUDE_PROJECT_DIR:-$PWD}")
in_workspace "$dir" || exit 0

# Sync the opened clone, or every clone when the workspace root itself is open.
targets=()
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  targets=("$(git -C "$dir" rev-parse --show-toplevel)")
elif [ "$(lower "$dir")" = "$(lower "$(workspace_root)")" ]; then
  for child in "$dir"/*/; do
    [ -d "$child.git" ] && targets+=("${child%/}")
  done
fi
[ ${#targets[@]} -gt 0 ] || exit 0

ok=()
warnings=()
for repo in "${targets[@]}"; do
  name=$(basename "$repo")
  sync_due "$repo" || continue
  printf '%s' "$now" >"$(stamp_file "$repo")" 2>/dev/null
  branch=$(reference_branch "$repo")

  if [ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]; then
    warnings+=("$name: local changes found, update skipped. Ask the project admin before touching them.")
    continue
  fi
  if ! git_net -C "$repo" fetch --quiet origin "$branch" 2>/dev/null; then
    warnings+=("$name: could not reach GitHub (offline or not logged in), the local copy may be outdated. Run /product-desk:setup-check.")
    continue
  fi
  current=$(git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [ "$current" != "$branch" ] && ! git -C "$repo" checkout --quiet "$branch" 2>/dev/null; then
    warnings+=("$name: could not switch to branch $branch.")
    continue
  fi
  if ! git -C "$repo" merge --quiet --ff-only "origin/$branch" >/dev/null 2>&1; then
    warnings+=("$name: local branch $branch has diverged from GitHub, update skipped. Ask the project admin.")
    continue
  fi
  ok+=("$name is up to date with $branch ($(git -C "$repo" log -1 --format='last change %cr, %h'))")
done

# Prompt mode: nothing was due, stay silent.
if [ "$mode" = prompt ] && [ ${#ok[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ]; then
  exit 0
fi

context="Singulier workspace sync."
for line in ${ok[@]+"${ok[@]}"}; do context="$context OK: $line."; done
for line in ${warnings[@]+"${warnings[@]}"}; do context="$context WARNING: $line"; done
if [ ${#warnings[@]} -gt 0 ]; then
  context="$context Tell the user about each warning in their language, in plain words, before answering."
fi
if [ "$mode" != prompt ]; then
  context="$context If the user seems lost or asks what you can do, offer /product-desk:aide (French) or /product-desk:help (English)."
fi
event=SessionStart
[ "$mode" = prompt ] && event=UserPromptSubmit

printf '{'
if [ ${#warnings[@]} -gt 0 ]; then
  printf '"systemMessage":"%s",' "$(json_escape "Singulier: ${warnings[*]}")"
fi
printf '"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$event" "$(json_escape "$context")"
exit 0
