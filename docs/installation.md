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
| Plugin | `claude plugin marketplace add wearegraphite/singulier-claude`, then `claude plugin install product-desk@singulier --scope user`, checked with `claude plugin list` | same |
| Workspace | `~/Singulier/<repo>` clones via `gh repo clone` | `C:\Users\<name>\Singulier\<repo>` |

No Homebrew and no admin rights are needed on macOS, apart from the computer
password the `.pkg` installer asks for. On Windows, Git for Windows is
mandatory: it provides Git Bash, which runs the plugin hooks. Without it, hooks
do not run. Do not use WSL: plugins are not available there.

The device-code login works from Claude Code itself: `gh` prints a one-time
code and the URL, and waits while the user confirms in the browser. No terminal
is needed.

The setup must run in a **Local** session of the desktop app. In a Cloud
session (the default, "Default" button) Claude runs on an Anthropic server: the
tools, the plugin and the clones end up there, not on the user's computer. Step
0 of the setup message detects it (`uname -s` returns `Linux`) and stops.

Claude Code clones the marketplace with the user's git credentials: `gh auth
setup-git` (step 4) must have run before the plugin install, as the repository
is private.

## Checking the plugin is installed

At the end of the setup, after quitting and reopening the app: click your name
at the bottom left of the window, then **Settings**, then **Plugins** (under
**Customisation**). `product-desk` must be in the list.

If it is not:

- in a Local session, run `claude plugin list` and look at the Errors tab of `/plugin`;
- check that `singulier` is listed in `~/.claude/plugins/known_marketplaces.json`;
- the most common causes: a Cloud session, no git credential for the private repository, the app not restarted.

## Renamed from `singulier` (0.9.0)

Up to 0.8.0 the plugin was called `singulier` (`singulier@singulier`, commands
`/singulier:aide`). From 0.9.0 it is `product-desk` (`product-desk@singulier`,
`/product-desk:aide`). The old plugin gets no more updates and is not replaced
automatically. Each person already set up must, in a Local session:

```
/plugin uninstall singulier@singulier
/plugin marketplace update singulier
/plugin install product-desk@singulier
```

then fully quit and reopen the app. The marketplace keeps its name, `singulier`.

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
/plugin install product-desk@singulier
```
