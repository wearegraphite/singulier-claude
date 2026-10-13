#!/usr/bin/env bash
# Shared helpers for the Singulier hooks. Must run on macOS (bash 3.2, BSD
# tools) and on Windows (Git Bash, GNU tools). No jq: it is not installed by
# default on either platform.

# Converts a Windows path (C:\Users\x) to a POSIX one (/c/Users/x) under Git
# Bash; returns the path unchanged elsewhere.
to_unix() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$1"
  else
    printf '%s' "$1" | sed 's#\\#/#g'
  fi
}

lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# Absolute path with `..` and symlinks resolved on its longest existing parent,
# so `other/../Singulier/x` or a symlinked folder cannot dodge the workspace check.
canonical_path() {
  local path dir rest resolved part
  local -a parts kept
  path=$(to_unix "$1")
  case "$path" in /*) ;; *) path="$PWD/$path" ;; esac

  # The longest existing prefix is resolved by the file system itself, so `..`
  # after a symlink goes where the kernel goes (`link/..` is the parent of the
  # link's target, not of the link).
  dir=$path
  rest=""
  while [ ! -d "$dir" ]; do
    rest="/$(basename "$dir")$rest"
    dir=$(dirname "$dir")
  done
  resolved=$(cd -P "$dir" 2>/dev/null && pwd -P) || resolved=$dir

  # Only the missing tail is folded as text: no symlink can hide in it.
  IFS=/ read -r -a parts <<<"${resolved%/}$rest"
  kept=()
  for part in ${parts[@]+"${parts[@]}"}; do
    case "$part" in
      '' | .) ;;
      ..) [ ${#kept[@]} -gt 0 ] && unset "kept[$((${#kept[@]} - 1))]" ;;
      *) kept+=("$part") ;;
    esac
  done
  path=""
  for part in ${kept[@]+"${kept[@]}"}; do path="$path/$part"; done
  printf '%s' "${path:-/}"
}

# Root folder holding the clones managed by the plugin. Override with the
# SINGULIER_WORKSPACE environment variable.
workspace_root() {
  canonical_path "${SINGULIER_WORKSPACE:-$HOME/Singulier}"
}

# True when the given path is the workspace root or inside it. Case-insensitive,
# as the default file systems on macOS and Windows are.
in_workspace() {
  local path root
  path=$(lower "$(canonical_path "$1")")
  root=$(lower "$(workspace_root)")
  case "$path/" in
    "$root/"*) return 0 ;;
  esac
  return 1
}

# A clone is read-only unless an admin ran, inside it:
#   git config singulier.readonly false
repo_readonly() {
  [ "$(git -C "$1" config --get singulier.readonly 2>/dev/null)" != "false" ]
}

# Repository name of a clone, from its origin URL (`.../owner/name(.git)`).
repo_name() {
  git -C "$1" config --get remote.origin.url 2>/dev/null | sed -e 's#\.git$##' -e 's#.*[/:]##'
}

# Branch set for a repository in config/branches.txt, shipped with the plugin.
mapped_branch() {
  local file name
  file="$(dirname "${BASH_SOURCE[0]}")/../config/branches.txt"
  [ -f "$file" ] || return 0
  name=$(lower "$(repo_name "$1")")
  [ -n "$name" ] || return 0
  tr -d '\r' <"$file" | sed 's/#.*//' | while read -r repo branch _; do
    [ "$(lower "$repo")" = "$name" ] && [ -n "$branch" ] && printf '%s' "$branch" && break
  done
}

# Branch a clone must follow: `git config singulier.branch`, else the plugin's
# config/branches.txt, else the remote's default branch, else main.
reference_branch() {
  local branch
  branch=$(git -C "$1" config --get singulier.branch 2>/dev/null)
  [ -n "$branch" ] || branch=$(mapped_branch "$1")
  if [ -z "$branch" ]; then
    branch=$(git -C "$1" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
    branch=${branch#origin/}
  fi
  printf '%s' "${branch:-main}"
}

# Runs git without ever waiting for a password prompt or a stalled network.
git_net() {
  GIT_TERMINAL_PROMPT=0 \
    GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=15" \
    git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=20 "$@"
}

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\n\t' '  '
}
