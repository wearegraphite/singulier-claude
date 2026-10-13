---
name: github-tracking
description: Finds, updates and comments GitHub issues, and manages GitHub Projects (items, fields, statuses, views) for Singulier projects with the gh CLI. Use whenever the user talks about issues, tickets, bugs to report, feature requests, the backlog, the project board, statuses, priorities, assignees, labels, milestones or views, or asks "where are we on X", "qu'est-ce que je dois tester", or says a check is done ("j'ai testé #380, c'est bon").
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
creates it after a go-ahead; a big need becomes an epic with its sub-tickets
there too. Here, only add the issue to the board when asked
for an existing one: `gh project item-add <number> --owner wearegraphite --url <issue url>`.

## Updating

- Comment: `gh issue comment <n> --body-file <file>`.
- Edit title, body, labels, assignees, milestone: `gh issue edit <n> ...`.
- Project fields: get the item id (`gh project item-list <number> --owner wearegraphite --format json`), the field and option ids (`field-list`), then `gh project item-edit --id <item> --project-id <project id> --field-id <field> --single-select-option-id <option>` (or `--text`, `--number`, `--date`, `--iteration-id`). `gh project view <number> --owner wearegraphite --format json` gives the project id.
- Always show what will change and get a go-ahead before editing or commenting. Closing or reopening an issue needs an explicit request.

## Status questions ("where are we on X?")

Search issues and project items, then answer with a short summary: what is done, in progress, blocked, and by whom, with links. Separate facts from your reading of them.

For an epic (a parent issue with sub-issues), read its sub-issues' states
(`gh issue view <n> --json title,state,body` and the GraphQL `subIssues`
field) and their board column, and say which wave is in progress. Its
« Vagues » table and graph show 🟡 en cours, 🧪 livré à tester, ✅ fini,
⛔ bloqué when developers run it with ticket-flow; send the user to the epic's
link to see that graph. Trust the tracker over the epic body if they differ.

How to read a ticket's state, in plain words for the user:
- closed → fini.
- open, in « à valider » (or Testing, In Review...) → livré : le code est en
  place, il reste une vérification à faire à la main, souvent par la personne
  qui a demandé. Say what to check: it is in the ticket's last comment and its
  unticked « Fini quand » boxes.
- open with a box `~~…~~ → déplacée vers #M` → this part continues in #M.
- A merged change does not close a ticket by itself when developers work on a
  branch other than the main one: an open ticket is not necessarily late.

## Checks waiting for the user ("qu'est-ce que je dois tester ?")

List the open tickets in « à valider » where the user is named under « Qui
valide » (or who asked for them), with what to check for each and the link.

When the user says a check is done (« j'ai testé #380, c'est bon »):
- show what you will do and get a go-ahead: tick the box with their words as
  proof, comment « vérifié par <rôle> le <date> : <ce qui a été vu> », close
  the ticket, move it to the board's « done » status;
- if the ticket is in an epic whose body has a « Vagues » section, turn its
  node and wave cell to ✅ (wave ✅ only when all its tickets are closed): edit
  only that section, after re-reading the body.
If the check failed, do not close: comment what was seen (steps, result,
expected) and tell them the developers will take it back.

## Views

Project views (table, board, roadmap, filters, grouping, sorting) may not be creatable from the gh CLI or the API. First check what `gh project --help` and the GitHub API offer; if creating a view is not possible that way, give the user short click-by-click instructions for github.com: open the project, "New view" next to the tabs, pick the layout, then set filter, group by and sort from the view menu. Suggest a concrete filter (for example `assignee:@me status:"In progress"`).

## Never

- Delete issues, projects, fields or views; transfer issues; touch repository settings.
- Create or merge pull requests.
- Post on behalf of the user without their go-ahead.
- Put credentials, client personal data or commercially sensitive figures in an issue.
