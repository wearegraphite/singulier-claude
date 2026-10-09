# How it works

## Session start: keeping clones up to date

`plugins/singulier/scripts/sync-repo.sh` runs when a session starts or resumes.

1. It exits at once if the session folder is outside the workspace.
2. It picks the clone the session is in, or every clone when the workspace root itself is open.
3. For each clone:
   - local changes present: skipped, with a warning (nothing is ever discarded);
   - `git fetch` of the reference branch (`git config singulier.branch`, else `config/branches.txt`, else the GitHub default branch), without password prompts and with network timeouts;
   - switch to the reference branch if the clone is on another one;
   - fast-forward only. If the local branch has diverged, it is skipped with a warning (never merges).
4. It passes the result to Claude as context. Warnings are also shown to the user, and Claude explains them in plain words.

The hook never blocks the session: any failure becomes a warning.

## Plugin version check

`scripts/version-check.sh`, run by the same hook, compares the installed
`plugin.json` version with the one published on `main` of the repository named
in `plugin.json` (`gh api`, 10 s timeout). The result is cached for a day in
`CLAUDE_PLUGIN_DATA`. When a newer version exists, Claude tells the user how to
update. Offline, logged out or rate-limited: no message, no error.

## Guardrails

`plugins/singulier/scripts/guard.sh` runs before each Bash, Edit, Write,
MultiEdit and NotebookEdit tool call, only for sessions inside the workspace.

Blocked unless the clone has `singulier.readonly=false`:

- editing or writing files inside the workspace;
- git commands that change files, branches or history (`commit`, `push`, `merge`, `rebase`, `reset`, `checkout`, `switch`, `stash`, `clean`, `restore`, `add`, `rm`, `tag`...);
- `gh` commands that delete or change shared settings (`repo delete/edit`, `issue delete/transfer`, `pr merge/close/create`, `project delete/close`, `release`, `secret`, `workflow run`...), and `gh api` DELETE calls;
- `rm`;
- GraphQL mutations that delete, remove, archive, transfer or merge (`gh api graphql`).

Always blocked: changing the plugin's own `git config singulier.*` settings,
writing `.git/config` directly, and `GIT_CONFIG_*` overrides.

File paths are resolved (`..` and symlinks) before the workspace check.

Claude receives the reason and is told to explain it and to offer a GitHub
issue instead.

The matching works on the raw tool input with regular expressions (no `jq` on
stock macOS or Windows). It errs on the side of blocking: a harmless command
can be refused, for example `git show HEAD:src/apply.ts`. It is a safety net,
not a security boundary; GitHub roles are. A command written to dodge the
patterns (a script file, an obfuscated string) will get through: the guard
stops Claude's honest mistakes, not deliberate circumvention.

## Platforms

Scripts are written for bash 3.2 with BSD tools (macOS) and for Git Bash with
GNU tools (Windows). Hooks force `"shell": "bash"`; on Windows, Git for Windows
must be installed. Windows paths (`C:\...`) are converted with `cygpath`.

## Known limits

- **Windows desktop app**: the Claude Code documentation does not state which shell the desktop app uses for hooks on Windows. To verify on a real machine.
- **Project views**: the gh CLI may not be able to create GitHub Projects views. The skill then guides the user through github.com.
- **Read-only, not offline**: if GitHub cannot be reached, the session works on the last copy and says so.
