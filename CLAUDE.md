# singulier-claude

Claude Code plugin (and its marketplace) for non-technical Singulier team
members. Read `docs/development.md` before changing anything.

- Hook scripts must run on macOS bash 3.2 (BSD tools) and Windows Git Bash: no `jq`, no GNU-only flags. Run `bash tests/run.sh` after any change to `plugins/product-desk/scripts/`.
- The plugin may be enabled for the whole organisation: every hook must do nothing outside the workspace folder.
- Release = bump `version` in `plugins/product-desk/.claude-plugin/plugin.json` only. Never add a `version` to the `marketplace.json` entry: `plugin.json` wins and the two drift.
- **Bump that version before every push that changes `plugins/product-desk/`**: Claude Code only ships a commit to users when the version changes, so an unbumped push never reaches them. `.claude/hooks/require-version-bump.sh` blocks such a push.
- Test the update band (`plugins/product-desk/hooks/`) with `cd plugins/product-desk && claude plugin test .`.
- Code and docs in English; commit descriptions in French (Conventional Commits).
