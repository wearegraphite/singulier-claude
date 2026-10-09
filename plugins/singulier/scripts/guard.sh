#!/usr/bin/env bash
# PreToolUse hook: keeps the Singulier workspace clones read-only. Blocks file
# edits inside the workspace, git commands that change history or branches,
# and destructive gh commands. This is a safety net against mistakes, not a
# security boundary: GitHub permissions (Triage role) are the real one.
set -u
. "$(dirname "$0")/lib.sh"

input=$(cat)
project_dir=$(to_unix "${CLAUDE_PROJECT_DIR:-$PWD}")
in_workspace "$project_dir" || exit 0

block() {
  echo "Blocked by the Singulier plugin: $1 Do not retry or work around it. Explain this to the user in plain words; if they want a change in the project, offer to write a GitHub issue instead." >&2
  exit 2
}

# The tool input is matched as raw JSON: no jq on stock macOS or Windows.
# Patterns may over-block, which is the safe side.
tool=$(printf '%s' "$input" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)

case "$tool" in
  Bash)
    command=$(printf '%s' "$input" | tr '\n' ' ')
    # git config keys are case-insensitive; .git/config can also be written directly.
    if printf '%s' "$command" | grep -Eiq '(^|[^[:alnum:]_.-])git[[:space:]][^|;&]*config[^|;&]*singulier|\.git[/\\]+config|GIT_CONFIG_'; then
      block "the Singulier settings of a clone can only be changed by an admin."
    fi
    # Shared clones must stay read-only: no edits, so no commit, push or branch work.
    repo_readonly "$project_dir" || exit 0
    if printf '%s' "$command" | grep -Eq '(^|[^[:alnum:]_.-])git[[:space:]][^|;&]*(push|commit|merge|rebase|reset|checkout|switch|stash|clean|restore|cherry-pick|revert|am|apply|rm|mv|add|tag|branch[[:space:]]+-[dDmM])([^[:alnum:]_-]|$)'; then
      block "this project is read-only here, git commands that change files, branches or history are not allowed."
    fi
    if printf '%s' "$command" | grep -Eq '(^|[^[:alnum:]_.-])gh[[:space:]]+(repo[[:space:]]+(delete|archive|rename|edit)|issue[[:space:]]+(delete|transfer)|pr[[:space:]]+(merge|close|create)|project[[:space:]]+(delete|close)|release|secret|variable|workflow[[:space:]]+run)([^[:alnum:]_-]|$)'; then
      block "this gh command can delete or change shared project settings."
    fi
    if printf '%s' "$command" | grep -Eiq '(^|[^[:alnum:]_.-])gh[[:space:]]+api[^|;&]*(-X|--method)[[:space:]=]*delete'; then
      block "deleting through the GitHub API is not allowed."
    fi
    if printf '%s' "$command" | grep -Eiq '(^|[^[:alnum:]_.-])gh[[:space:]]+api[[:space:]]+graphql[^|;&]*(delete|remove|archive|transfer|merge|unlink)[[:alnum:]]*[[:space:]]*\('; then
      block "this GitHub API mutation can delete or move shared data."
    fi
    if printf '%s' "$command" | grep -Eq '(^|[^[:alnum:]_.-])rm[[:space:]]'; then
      block "deleting files in the project folder is not allowed."
    fi
    ;;
  Edit|Write|MultiEdit|NotebookEdit)
    # BSD sed has no alternation: look for each key in turn.
    target=""
    for key in file_path notebook_path; do
      [ -n "$target" ] || target=$(printf '%s' "$input" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1)
    done
    target=$(printf '%s' "$target" | sed 's#\\\\#/#g')
    # The kernel and a tool can read `..` after a symlink differently: refuse
    # the ambiguity instead of guessing. Claude's file tools use absolute paths.
    case "/$target/" in
      */../*) repo_readonly "$project_dir" && block "file paths containing '..' are not allowed here; use the plain absolute path." ;;
    esac
    if [ -n "$target" ] && in_workspace "$target" && repo_readonly "$project_dir"; then
      block "files in the project folder are read-only here."
    fi
    ;;
esac
exit 0
