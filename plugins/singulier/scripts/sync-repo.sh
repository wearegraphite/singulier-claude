#!/usr/bin/env bash
# SessionStart hook: fast-forwards the clones of the Singulier workspace to
# their reference branch, so non-technical users always read current code.
# Never merges, never discards local work, never blocks the session.
set -u
. "$(dirname "$0")/lib.sh"

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
  branch=$(reference_branch "$repo")

  if [ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]; then
    warnings+=("$name: local changes found, update skipped. Ask the project admin before touching them.")
    continue
  fi
  if ! git_net -C "$repo" fetch --quiet origin "$branch" 2>/dev/null; then
    warnings+=("$name: could not reach GitHub (offline or not logged in), the local copy may be outdated. Run /singulier:setup-check.")
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

context="Singulier workspace sync."
for line in ${ok[@]+"${ok[@]}"}; do context="$context OK: $line."; done
for line in ${warnings[@]+"${warnings[@]}"}; do context="$context WARNING: $line"; done
if [ ${#warnings[@]} -gt 0 ]; then
  context="$context Tell the user about each warning in their language, in plain words, before answering."
fi

printf '{'
if [ ${#warnings[@]} -gt 0 ]; then
  printf '"systemMessage":"%s",' "$(json_escape "Singulier: ${warnings[*]}")"
fi
printf '"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(json_escape "$context")"
exit 0
