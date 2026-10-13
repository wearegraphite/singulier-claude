# singulier-claude

Claude Code plugin (and its marketplace) for non-technical Singulier team
members. Read `docs/development.md` before changing anything.

- Hook scripts must run on macOS bash 3.2 (BSD tools) and Windows Git Bash: no `jq`, no GNU-only flags. Run `bash tests/run.sh` after any change to `plugins/singulier/scripts/`.
- The plugin may be enabled for the whole organisation: every hook must do nothing outside the workspace folder.
- Release = bump `version` in `plugins/singulier/.claude-plugin/plugin.json` only. Never add a `version` to the `marketplace.json` entry: `plugin.json` wins and the two drift.
- **Bump that version before every push that changes `plugins/singulier/`**: Claude Code only ships a commit to users when the version changes, so an unbumped push never reaches them. `.claude/hooks/require-version-bump.sh` blocks such a push.
- Test the update band (`plugins/singulier/hooks/`) with `cd plugins/singulier && claude plugin test .`.
- Code and docs in English; commit descriptions in French (Conventional Commits).
