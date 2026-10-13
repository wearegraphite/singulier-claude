#!/usr/bin/env bash
# End-to-end checks for the hook scripts, against throwaway git repos.
# Usage: bash tests/run.sh   (macOS or Windows Git Bash)
set -u

scripts="$(cd "$(dirname "$0")/../plugins/singulier/scripts" && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export SINGULIER_WORKSPACE="$tmp/Singulier"
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
mkdir -p "$SINGULIER_WORKSPACE" "$tmp/outside" "$tmp/bin"

# Stub gh: never reach GitHub.
printf '#!/bin/sh\nexit 0\n' >"$tmp/bin/gh"
chmod +x "$tmp/bin/gh"
export PATH="$tmp/bin:$PATH" CLAUDE_PLUGIN_DATA="$tmp/plugin-data"

failures=0
check() { # check <label> <expected exit code> <actual exit code>
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (expected exit $2, got $3)"; failures=$((failures + 1)); fi
}
contains() { # contains <label> <haystack> <needle>
  case "$2" in *"$3"*) echo "ok   $1" ;; *) echo "FAIL $1 (missing '$3' in: $2)"; failures=$((failures + 1)) ;; esac
}

# A bare "GitHub" remote with a main branch, and a clone in the workspace.
git init -q --bare -b main "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/author" 2>/dev/null
(cd "$tmp/author" && echo v1 > file.txt && git add . && git commit -qm v1 && git push -q origin main)
git clone -q "$tmp/origin.git" "$SINGULIER_WORKSPACE/project"
repo="$SINGULIER_WORKSPACE/project"
(cd "$tmp/author" && echo v2 > file.txt && git commit -qam v2 && git push -q origin main)

sync() { CLAUDE_PROJECT_DIR="$1" bash "$scripts/sync-repo.sh" </dev/null; }
guard() { CLAUDE_PROJECT_DIR="$1" bash "$scripts/guard.sh" <<<"$2" 2>/dev/null; }

echo "== sync"
out=$(sync "$repo")
contains "pulls the new commit" "$(cat "$repo/file.txt")" "v2"
contains "reports success" "$out" "project is up to date with main"

(cd "$repo" && git checkout -q -b someone-else)
sync "$repo" >/dev/null
contains "switches back to the reference branch" "$(git -C "$repo" branch --show-current)" "main"

echo dirty > "$repo/file.txt"
out=$(sync "$repo")
contains "skips a clone with local changes" "$out" "local changes found"
contains "keeps the local changes" "$(cat "$repo/file.txt")" "dirty"
git -C "$repo" checkout -q -- file.txt

(cd "$tmp/author" && git checkout -q -b dev && echo dev > file.txt && git commit -qam dev && git push -q origin dev && git checkout -q main)
. "$scripts/lib.sh"
check "repository name comes from the origin URL" "origin" "$(repo_name "$repo")"
branches="$scripts/../config/branches.txt"
cp "$branches" "$tmp/branches.bak"
printf 'ORIGIN dev\r\n' >>"$branches"
sync "$repo" >/dev/null
cp "$tmp/branches.bak" "$branches"
contains "follows the branch set in config/branches.txt" "$(git -C "$repo" branch --show-current)" "dev"
git -C "$repo" config singulier.branch main
sync "$repo" >/dev/null
contains "git config overrides config/branches.txt" "$(git -C "$repo" branch --show-current)" "main"
git -C "$repo" config --unset singulier.branch

out=$(sync "$SINGULIER_WORKSPACE")
contains "syncs every clone from the workspace root" "$out" "project is up to date"

out=$(sync "$tmp/outside")
check "ignores folders outside the workspace" "" "$out"

echo "== throttled sync (UserPromptSubmit)"
prompt_sync() { CLAUDE_PROJECT_DIR="$1" bash "$scripts/sync-repo.sh" prompt </dev/null; }
(cd "$tmp/author" && echo v3 > file.txt && git commit -qam v3 && git push -q origin main)
sync "$repo" >/dev/null # session start stamps the attempt
out=$(prompt_sync "$repo")
check "stays silent while the last sync is recent" "" "$out"
(cd "$tmp/author" && echo v4 > file.txt && git commit -qam v4 && git push -q origin main)
prompt_sync "$repo" >/dev/null
contains "does not fetch while the last sync is recent" "$(cat "$repo/file.txt")" "v3"
printf '%s' "$(( $(date +%s) - 5 * 3600 ))" >"$repo/.git/singulier-last-sync"
out=$(prompt_sync "$repo")
contains "syncs once the last sync is older than 4 hours" "$(cat "$repo/file.txt")" "v4"
contains "labels the output for UserPromptSubmit" "$out" "UserPromptSubmit"
check "keeps the stamp out of git status" "" "$(git -C "$repo" status --porcelain)"

echo "== guard"
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git log --oneline -5"}}'; check "allows git log" 0 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"gh issue create --title \"x\""}}'; check "allows gh issue create" 0 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'; check "blocks git push" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git -C /x commit -m y"}}'; check "blocks git -C commit" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 3"}}'; check "blocks gh pr merge" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"gh api -X DELETE repos/a/b"}}'; check "blocks gh api DELETE" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git config singulier.readonly false"}}'; check "blocks changing the plugin settings" 2 $?
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$repo/file.txt\"}}"; check "blocks edits inside the workspace" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git config Singulier.ReadOnly false"}}'; check "blocks the settings in any case" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"printf x >> .git/config"}}'; check "blocks writing .git/config directly" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"gh api graphql -f query=\"mutation { deleteProjectV2Item(input: {}) { x } }\""}}'; check "blocks graphql delete mutations" 2 $?
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"gh api graphql -f query=\"query { viewer { login } }\""}}'; check "allows graphql queries" 0 $?
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/outside/../Singulier/project/file.txt\"}}"; check "blocks edits reaching the workspace through .." 2 $?
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/outside/missing/../../Singulier/project/file.txt\"}}"; check "blocks .. below a missing folder" 2 $?
ln -s "$repo" "$tmp/outside/link"
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/outside/link/file.txt\"}}"; check "blocks edits reaching the workspace through a symlink" 2 $?
mkdir -p "$repo/sub" && ln -s "$repo/sub" "$tmp/outside/sublink"
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/outside/sublink/../file.txt\"}}"; check "blocks .. applied after a symlink" 2 $?
guard "$repo" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/outside/sublink/missing/../../file.txt\"}}"; check "blocks .. in a missing tail after a symlink" 2 $?
ln -s "$tmp/outside" "$repo/out"
guard "$repo" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$repo/out/../file.txt\"}}"; check "blocks .. after a symlink leaving the workspace" 2 $?
guard "$repo" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmp/outside/a/../notes.md\"}}"; check "blocks any .. in a write path" 2 $?
guard "$repo" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmp/outside/notes.md\"}}"; check "allows writes outside the workspace" 0 $?
guard "$tmp/outside" '{"tool_name":"Bash","tool_input":{"command":"git push"}}'; check "ignores sessions outside the workspace" 0 $?

git -C "$repo" config singulier.readonly false
guard "$repo" '{"tool_name":"Bash","tool_input":{"command":"git commit -m y"}}'; check "admin override allows git commit" 0 $?

echo
[ $failures -eq 0 ] && echo "All checks passed." || echo "$failures check(s) failed."
exit $failures
