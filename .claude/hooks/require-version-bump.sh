#!/usr/bin/env bash
# PreToolUse hook (maintainers of this repository only): blocks a `git push`
# that ships changes under plugins/singulier/ without bumping `version` in
# plugin.json. Claude Code only delivers a commit to users when that version
# changes, so an unbumped push never reaches them.
# Must run on macOS bash 3.2 and Windows Git Bash: no jq, no GNU-only flags.

input=$(cat)
case "$input" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
manifest="plugins/singulier/.claude-plugin/plugin.json"

# Compare with the branch's upstream, or origin/main when there is none.
base=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
[ -n "$base" ] || base="origin/main"
git rev-parse --verify --quiet "$base" >/dev/null || exit 0

# Nothing shipped to users: no bump needed.
if [ -z "$(git diff --name-only "$base" HEAD -- plugins/singulier/)" ]; then
  exit 0
fi

read_version() {
  git show "$1:$manifest" 2>/dev/null \
    | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n 1
}

old=$(read_version "$base")
new=$(read_version HEAD)

if [ -n "$old" ] && [ "$old" = "$new" ]; then
  echo "Push blocked: plugins/singulier/ changed since $base but the version is still $new. Bump \"version\" in $manifest (and only there) and commit it, otherwise users never get the update." >&2
  exit 2
fi
exit 0
