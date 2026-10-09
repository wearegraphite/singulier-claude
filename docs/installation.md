# Installation

Team members should follow the [getting started guide](getting-started.en.md)
([français](getting-started.fr.md)): they paste one message into Claude Code and
Claude does the setup. This page explains what that setup does, for admins and
for troubleshooting.

## What gets installed

| Piece | macOS | Windows |
| --- | --- | --- |
| git | Apple Command Line Tools (`xcode-select --install`, a system window) | `winget install --id Git.Git -e` |
| GitHub CLI (`gh`) | official `.pkg` installer from the latest `cli/cli` release | `winget install --id GitHub.cli -e` |
| GitHub login | `gh auth login --web -h github.com -p https -s project` (device code in the browser), then `gh auth setup-git` | same |
| Plugin | user `settings.json`: `extraKnownMarketplaces.singulier` (with `autoUpdate: true`) and `enabledPlugins["singulier@singulier"]` | same |
| Workspace | `~/Singulier/<repo>` clones via `gh repo clone` | `C:\Users\<name>\Singulier\<repo>` |

No Homebrew and no admin rights are needed on macOS, apart from the computer
password the `.pkg` installer asks for. On Windows, Git for Windows is
mandatory: it provides Git Bash, which runs the plugin hooks. Without it, hooks
do not run. Do not use WSL: plugins are not available there.

The device-code login works from Claude Code itself: `gh` prints a one-time
code and the URL, and waits while the user confirms in the browser. No terminal
is needed.

## If the organisation enables the plugin centrally

See [Administration](administration.md). Step 6 of the setup message then has
nothing to do.

## Manual install (developers)

```sh
# macOS
brew install git gh
# Windows (PowerShell)
winget install --id Git.Git -e; winget install --id GitHub.cli -e

gh auth login -h github.com -p https -s project
gh auth setup-git
```

Then in Claude Code:

```
/plugin marketplace add wearegraphite/singulier-claude
/plugin install singulier@singulier
```
