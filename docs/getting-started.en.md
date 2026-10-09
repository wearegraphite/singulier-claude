# Getting started

[Version française](getting-started.fr.md)

This guide is for you if you are not a developer. Once done, you can ask Claude
questions about our projects ("how is this price calculated?") and create or
follow GitHub issues, without going through a developer.

You **type nothing**: you paste one message, Claude does the rest and tells you
when to click. Allow 15 to 30 minutes, once.

---

## Before you start

- [ ] The **Claude app** is installed on your computer (https://claude.ai/download) and you are logged in with your Singulier account.
- [ ] You have a **GitHub account**. If not, create one for free at https://github.com/signup with your work email.
- [ ] You have sent your **GitHub username** to the project admin, and they confirmed your access.

---

## Step 1: open Claude Code

1. Open the Claude app.
2. At the top of the window, click the **`</>`** icon (right of the chat bubble):

   ![Code button in the Claude app](images/code-tab-toggle.png)

   You are now in **Claude Code**: the mode where Claude can work on your computer. The bubble on the left is the usual chat; it cannot do the setup.
3. Start a new session. If Claude asks you to choose a folder, pick your **Documents** folder.

---

## Step 2: paste the setup message

Copy the whole block below (copy button at the top right of the block on
GitHub), paste it into Claude Code and send it.

```text
Talk to me in English, simply: I am not technical. Set up my computer to work on Singulier projects. Run every command yourself. Only ask me to act when it cannot be avoided (clicking in an installer, confirming in the browser), one thing at a time, telling me exactly where to click.

Steps, in order. Announce each step in one sentence, then do it.
1. System: detect macOS or Windows.
2. git: check `git --version`. If missing: on macOS run `xcode-select --install` and tell me to click "Install" in the window that opens, then wait until I am done; on Windows run `winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements`.
3. GitHub CLI: check `gh --version`. If missing: on macOS download the `gh_*_macOS_universal.pkg` file of the latest release (https://api.github.com/repos/cli/cli/releases/latest), open it with `open` and guide me through the installer (it will ask for the computer password); on Windows run `winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements`.
   On Windows, if you installed git or gh: tell me to fully quit the Claude app, reopen it and paste this message again. Stop there.
4. GitHub login: if `gh auth status` fails or does not show the `project` scope, run `gh auth login --web -h github.com -p https -s project` in the background, read its output, give me the 8-character code and the link https://github.com/login/device, and wait until I tell you it is confirmed. Check with `gh auth status`, then run `gh auth setup-git`.
5. Access: run `gh repo list wearegraphite --limit 100`. If the list is empty, give me my GitHub username (`gh api user --jq .login`), tell me to send it to the project admin, and stop.
6. Singulier plugin: if you do not already have `singulier:` skills, add to my user Claude settings (`settings.json` in the Claude configuration folder, usually `~/.claude/`; merge, overwrite nothing): in `extraKnownMarketplaces`, the key `singulier` with `{"source": {"source": "github", "repo": "wearegraphite/singulier-claude"}}`; in `enabledPlugins`, `"singulier@singulier": true`.
7. Projects: create the `Singulier` folder in my home folder. Show me the projects from step 5 with simple names, ask which ones I want, and clone each with `gh repo clone wearegraphite/<project> "<Singulier folder>/<project>"`.
8. End: sum up in three lines what is ready, then tell me to fully quit the Claude app and reopen it.

If a step fails twice, stop and tell me what to send to the project admin.
```

During the setup:

- Claude sometimes asks for **permission to run a command**: click **Allow**. This is normal, it is how it installs the tools.
- When it gives you a **GitHub code**, open the link it shows, log in to GitHub, type the code, click **Authorize**, then reply "done".
- At the end, **fully quit the Claude app and reopen it** (on Mac: `Cmd + Q`).

---

## Every day

1. Open the Claude app and click **`</>`**.
2. Start a session and choose the project folder: your home folder, then **Singulier**, then the project name.
3. Ask your question in plain words, as you would ask a colleague.

The project updates itself at each new session: you always see the current
version.

Not sure what to ask? Type **`/singulier:help`**.

Examples:

- "How is the price of a product calculated?"
- "Where does the data on the dashboard come from?"
- "Create an issue: the export button does nothing on the clients page."
- "Where are we on the payment integration?"
- "Show me my open issues."
- "Also get project X on my computer."
- "Check my installation."

Good to know:

- Claude **cannot change the project's code**. If you need a change, it offers to write an issue for the developers.
- It **always shows you an issue before creating** or changing it.
- It separates what it checked in the code from what it assumes. When in doubt, it tells you who to ask.

---

## Common problems

| What you see | What to do |
| --- | --- |
| No `</>` icon | Update the Claude app (app menu) or reinstall it from https://claude.ai/download. |
| Claude says it cannot run commands | You are in the chat (bubble): click `</>`. |
| Claude says the project could not be updated | Check your internet connection. If it persists, ask it to "check my installation". |
| Claude says you have no access to a project | Send your GitHub username to the project admin. |
| Anything else | Send a screenshot to the project admin. |
