---
name: github-tracking
description: Finds, updates and comments GitHub issues, and manages GitHub Projects (items, fields, statuses, views) for Singulier projects with the gh CLI. Use whenever the user talks about issues, tickets, bugs to report, feature requests, the backlog, the project board, statuses, priorities, assignees, labels, milestones or views, or asks "where are we on X".
---

# GitHub tracking

The user is usually not technical. Speak their language (French by default at
Singulier), plainly. Do the gh work yourself; never ask them to type commands.

## Find the context first

- Repository: `gh repo view --json nameWithOwner` inside a clone. Outside a clone, ask which project, or list them with `gh repo list wearegraphite`.
- Project boards linked to it: `gh project list --owner wearegraphite`, and the fields of the right one with `gh project field-list <number> --owner wearegraphite --format json`.
- Conventions: before writing, read the issue templates (`.github/ISSUE_TEMPLATE/` in the clone), the labels (`gh label list`) and three recent issues (`gh issue list --limit 3 --json number,title,body,labels`). Follow their language, tone, structure and labels.

## Creating an issue

Use the new-ticket skill: it interviews the user step by step (problem, goal,
how to know it is done, urgency), checks the code, drafts the ticket and
creates it after a go-ahead. Here, only add the issue to the board when asked
for an existing one: `gh project item-add <number> --owner wearegraphite --url <issue url>`.

## Updating

- Comment: `gh issue comment <n> --body-file <file>`.
- Edit title, body, labels, assignees, milestone: `gh issue edit <n> ...`.
- Project fields: get the item id (`gh project item-list <number> --owner wearegraphite --format json`), the field and option ids (`field-list`), then `gh project item-edit --id <item> --project-id <project id> --field-id <field> --single-select-option-id <option>` (or `--text`, `--number`, `--date`, `--iteration-id`). `gh project view <number> --owner wearegraphite --format json` gives the project id.
- Always show what will change and get a go-ahead before editing or commenting. Closing or reopening an issue needs an explicit request.

## Status questions ("where are we on X?")

Search issues and project items, then answer with a short summary: what is done, in progress, blocked, and by whom, with links. Separate facts from your reading of them.

## Views

Project views (table, board, roadmap, filters, grouping, sorting) may not be creatable from the gh CLI or the API. First check what `gh project --help` and the GitHub API offer; if creating a view is not possible that way, give the user short click-by-click instructions for github.com: open the project, "New view" next to the tabs, pick the layout, then set filter, group by and sort from the view menu. Suggest a concrete filter (for example `assignee:@me status:"In progress"`).

## Never

- Delete issues, projects, fields or views; transfer issues; touch repository settings.
- Create or merge pull requests.
- Post on behalf of the user without their go-ahead.
- Put credentials, client personal data or commercially sensitive figures in an issue.
