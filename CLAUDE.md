# singulier-claude

Claude Code plugin (and its marketplace) for non-technical Singulier team
members. Read `docs/development.md` before changing anything.

- Hook scripts must run on macOS bash 3.2 (BSD tools) and Windows Git Bash: no `jq`, no GNU-only flags. Run `bash tests/run.sh` after any change to `plugins/singulier/scripts/`.
- The plugin may be enabled for the whole organisation: every hook must do nothing outside the workspace folder.
- Bump the version in both `plugin.json` and `marketplace.json` on release.
- Code and docs in English; commit descriptions in French (Conventional Commits).
