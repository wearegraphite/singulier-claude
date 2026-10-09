---
name: setup-check
description: Checks and repairs the computer setup of a Singulier team member (git, GitHub CLI, GitHub login, workspace folder, project clones) and clones a project into the workspace. Use when the user asks to set up, check or fix their installation, to get or download a project, when a git or gh command fails because a tool or login is missing, or when the session start reported a sync warning.
---

# Setup check

The user is usually not technical. Speak their language (French by default at
Singulier), in plain words, one step at a time. Never paste a long list of
commands for them to run: run the checks yourself and only ask them to act
when a step needs them (installing software, logging in through a browser).

## Workspace

Projects live in one folder, the workspace: `~/Singulier` (macOS) or
`C:\Users\<name>\Singulier` (Windows), unless the `SINGULIER_WORKSPACE`
environment variable says otherwise. Inside it, each project is a clone named
after its repository. The plugin keeps these clones up to date at every session
start and read-only.

## Checks, in order

Run each check, report a short status line, fix what you can, then move on.

1. **Operating system**: `uname -s` (`Darwin` = macOS, `MINGW*`/`MSYS*` = Windows Git Bash).
2. **git**: `git --version`. Missing:
   - macOS: run `xcode-select --install` and tell the user to click "Install" in the window that opens; wait until they are done.
   - Windows: `winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements`, then the user must fully quit and reopen the Claude app.
3. **GitHub CLI**: `gh --version`. Missing:
   - macOS: download the `gh_*_macOS_universal.pkg` asset of the latest release (`https://api.github.com/repos/cli/cli/releases/latest`) to a temporary folder, `open` it and guide the user through the installer (it asks for the computer password). No Homebrew needed.
   - Windows: `winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements`, then the user must fully quit and reopen the Claude app.
4. **GitHub login and Projects permission**: `gh auth status` must succeed and list the `project` scope. Otherwise run `gh auth login --web -h github.com -p https -s project` in the background, read its output, give the user the 8-character code and https://github.com/login/device, wait for them to confirm, then check `gh auth status` again. This works without a terminal.
5. **git uses the GitHub login**: run `gh auth setup-git` (safe to run again).
6. **Plugin settings**: nothing to check if these skills are loaded. If the user's Claude settings lack the Singulier marketplace (for example on a fresh machine), the getting-started guide explains the settings to add.
7. **Organisation access**: `gh repo list wearegraphite --limit 50`. An empty list or an error means the project admin has not added the user's GitHub account yet: tell them to send their GitHub username to the admin.
8. **Workspace**: create the folder if it does not exist (`mkdir -p`), then list the clones it holds.

End with a short summary: what works, what was fixed, what is still needed and from whom.

## Getting a project

When the user wants a project (for example "je veux travailler sur le site web"):

1. Find the repository: `gh repo list wearegraphite --limit 100` and match the name. Ask only if several match.
2. Clone it into the workspace over HTTPS: `gh repo clone wearegraphite/<repo> "<workspace>/<repo>"`.
3. Nothing to configure for the branch: the plugin's `config/branches.txt`, maintained by the admin, says which branch each project follows (the GitHub default branch otherwise). The first session in the clone switches to it.
4. Tell the user how to work on it from now on: in the Claude app, click the `</>` icon, start a session, choose the folder `Singulier`, then the project.

## Rules

- Never delete or move a clone. If a clone looks broken, describe the problem and refer the user to the project admin.
- Never store tokens or passwords in files.
- If something fails twice, stop, say what you tried and refer the user to the project admin.
