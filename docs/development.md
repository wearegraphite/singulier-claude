# Development

## Layout

```
.claude-plugin/marketplace.json   marketplace catalogue (one plugin)
plugins/singulier/
  .claude-plugin/plugin.json      plugin manifest and version
  hooks/hooks.json                SessionStart and PreToolUse hooks
  scripts/                        hook scripts (bash, macOS + Git Bash)
  skills/<name>/SKILL.md          skills
tests/run.sh                      end-to-end checks of the hook scripts
docs/                             documentation
```

## Testing

Hook scripts, against throwaway git repositories (no network needed):

```sh
bash tests/run.sh
```

Run it on macOS and on Windows (Git Bash) before a release.

Plugin manifest and structure:

```sh
claude plugin validate plugins/singulier
claude plugin validate .
```

In a real session, without installing:

```sh
claude --plugin-dir plugins/singulier
```

Open it inside a workspace clone to exercise the hooks; set
`SINGULIER_WORKSPACE` to a test folder to avoid touching your own clones.

## Conventions

- Code, comments and documentation in English. Commit messages follow Conventional Commits, description in French.
- Scripts: no `jq`, no GNU-only flags, no bash 4 features (macOS ships bash 3.2). Keep `.sh` files with LF line endings (`.gitattributes` enforces it).
- Skills are written for non-technical users: plain language, Claude does the commands, confirmation before any write to GitHub.

## Releasing

1. Bump `version` in `plugins/singulier/.claude-plugin/plugin.json`, and only there: Claude Code takes the version from `plugin.json` and only ships a commit to users when that version changes. Do not put a `version` in the `marketplace.json` entry.
2. Merge to `main`.

How users get it:

- **Auto-update** (`autoUpdate: true` on the marketplace): Claude Code refreshes the marketplace in the background a few minutes into a session; the new version loads at the next launch or after `/reload-plugins`. It needs stored GitHub credentials (`gh auth setup-git`) while the repository is private, and fails silently otherwise.
- **Our own check**: once a day, the session-start hook compares the installed version with the one on `main` and has Claude tell the user to restart the app, or to run `/plugin marketplace update singulier` then `/reload-plugins`.
