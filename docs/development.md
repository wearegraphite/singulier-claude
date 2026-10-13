# Development

## Layout

```
.claude-plugin/marketplace.json   marketplace catalogue (one plugin)
plugins/product-desk/
  .claude-plugin/plugin.json      plugin manifest and version
  hooks/hooks.json                SessionStart and PreToolUse hooks, and the hooks module
  hooks/register.tsx              hooks module: the update band's settings
  hooks/update-band.tsx           update band (generic; settings in register.tsx)
  scripts/                        hook scripts (bash, macOS + Git Bash)
  tests/update-band.test.tsx      update band tests (terminal and desktop)
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

The update band (hooks module):

```sh
cd plugins/product-desk && claude plugin test .
```

Plugin manifest and structure:

```sh
claude plugin validate plugins/product-desk
claude plugin validate .
```

In a real session, without installing:

```sh
claude --plugin-dir plugins/product-desk
```

Open it inside a workspace clone to exercise the hooks; set
`SINGULIER_WORKSPACE` to a test folder to avoid touching your own clones.

## Conventions

- Code, comments and documentation in English. Commit messages follow Conventional Commits, description in French.
- Scripts: no `jq`, no GNU-only flags, no bash 4 features (macOS ships bash 3.2). Keep `.sh` files with LF line endings (`.gitattributes` enforces it).
- Skills are written for non-technical users: plain language, Claude does the commands, confirmation before any write to GitHub.

## Releasing

1. Bump `version` in `plugins/product-desk/.claude-plugin/plugin.json`, and only there: Claude Code takes the version from `plugin.json` and only ships a commit to users when that version changes. Do not put a `version` in the `marketplace.json` entry.
2. Merge to `main`.

Do the bump before every push that changes `plugins/product-desk/`, not only for big releases: an unbumped push never reaches users. A project hook (`.claude/settings.json` → `.claude/hooks/require-version-bump.sh`) blocks a `git push` run by Claude when files under `plugins/product-desk/` changed since the upstream branch and the version did not. It does not cover pushes typed by hand.

How users get it:

- **Auto-update** (`autoUpdate: true` on the marketplace): Claude Code refreshes the marketplace in the background a few minutes into a session; the new version loads at the next launch or after `/reload-plugins`. It needs stored GitHub credentials (`gh auth setup-git`) while the repository is private, and fails silently otherwise.
- **Our own update band**: at session start and every 6 hours, a row above the prompt says a newer version is on `main` and updates it in place with one button (see [How it works](how-it-works.md#update-band)).
