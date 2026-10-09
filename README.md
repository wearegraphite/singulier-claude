# singulier-claude

A Claude Code plugin that lets non-technical Singulier team members work on our
GitHub projects without a developer at hand:

- **Ask questions about the code** in plain language ("how is the price computed?", "where does this data come from?").
- **Create and update GitHub issues**, and manage **GitHub Projects** boards.
- **Always read current code**: local copies are updated automatically when a Claude session starts.
- **Stay safe**: local copies are read-only, and destructive git / GitHub commands are blocked.

It works on macOS and Windows, in the Claude desktop app (Code tab) and in the
Claude Code CLI.

## What is inside

| Part | What it does |
| --- | --- |
| `help` / `aide` skills | `/singulier:help` (English) or `/singulier:aide` (French): what to ask, how to open a project, what Claude will not do, state of the local copy, who to contact. |
| `setup-check` skill | Checks and repairs the computer setup (git, GitHub CLI, login, workspace) and clones projects. Run `/singulier:setup-check`. |
| `new-ticket` skill | Step-by-step interview (problem, goal, done when, urgency) that turns a need into a well-built issue, in the [ticket-flow](https://github.com/Xavier-Cliquennois/claude-ticket-flow) shape. |
| `github-tracking` skill | Issues and GitHub Projects: find, update, comment, status summaries, views. |
| `code-questions` skill | Explains how a project works, from its code and docs, for non-developers. |
| `SessionStart` hook | Fast-forwards the clones of the workspace to their reference branch. |
| `PreToolUse` hook | Keeps workspace clones read-only and blocks destructive commands. |

Skills trigger on their own from what the user asks; they can also be called by
name.

## The workspace

The plugin only acts on one folder, the **workspace**: `~/Singulier` on macOS,
`C:\Users\<name>\Singulier` on Windows (override with the `SINGULIER_WORKSPACE`
environment variable). Anything outside it, such as a developer's own clones,
is left untouched. This matters because the plugin may be enabled for the whole
organisation.

## Documentation

- **Getting started, step by step, for non-technical users**: [English](docs/getting-started.en.md) · [Français](docs/getting-started.fr.md). Send this link to new team members.
- [Installation](docs/installation.md): setting up a team member's computer, macOS and Windows.
- [Administration](docs/administration.md): GitHub access, organisation-wide deployment, per-project settings.
- [How it works](docs/how-it-works.md): hooks, guardrails, configuration, known limits.
- [Development](docs/development.md): testing and releasing the plugin.

## Quick start

**Team members**: follow the [getting started guide](docs/getting-started.en.md)
([français](docs/getting-started.fr.md)). They open Claude Code (the `</>` icon
in the Claude app), paste one setup message, and Claude installs the tools,
logs them in to GitHub, enables this plugin and clones their projects.

**Developers**, in Claude Code (CLI, or the Code tab of the desktop app):

```
/plugin marketplace add wearegraphite/singulier-claude
/plugin install singulier@singulier
```

Then ask Claude: "vérifie mon installation" or run `/singulier:setup-check`.
