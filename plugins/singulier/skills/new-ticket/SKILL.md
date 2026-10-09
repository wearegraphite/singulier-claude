---
name: new-ticket
description: Guides a non-technical Singulier team member, one question at a time, from a vague need to a well-built GitHub issue - the problem today, the goal, how to know it is done, urgency - then checks the code, drafts the ticket in the ticket-flow shape developers deliver from, and creates it after a go-ahead. Use when the user wants to report a bug, ask for a change or a new feature, "créer un ticket", "ouvrir une issue", "signaler un problème", "faire une demande", or when code-questions ends with a change request.
---

# New ticket

The user is usually not technical: a consultant, a project manager, a client
contact. Your job is to turn what they say into a ticket a developer (or a
ticket-flow agent) can deliver without coming back to ask. Speak their language
(French by default at Singulier), plainly. Do the gh work yourself.

## 1. Find the context (silently)

- Repository: `gh repo view --json nameWithOwner` inside a clone. Outside one,
  ask which project (list them with `gh repo list wearegraphite`).
- Project rules: read the clone's `CLAUDE.md`. A `## Workflow` section means the
  project uses ticket-flow: it names the tracker, the board and its statuses,
  mandatory labels and sometimes its own template. Follow it; it wins over the
  defaults below.
- Conventions: `.github/ISSUE_TEMPLATE/`, `gh label list`, three recent issues
  (`gh issue list --limit 3 --json number,title,body,labels`).

Do not report this step to the user; just use it.

## 2. The interview

One question per message. Offer choices when you can (AskUserQuestion is
good for that), rephrase what you understood before moving on, and accept
« je ne sais pas » without insisting. Skip any question the user already
answered in their first message. Never ask what the code can tell you.

1. **Kind**: bug (something that worked or should work does not), change to
   something that exists, new feature, or a question to investigate.
2. **The problem today**: what happens, where (page, screen, export, e-mail),
   for whom (a role, a client account: no names or personal data), since when,
   how often. For a bug: the steps to reproduce it, what happened, what was
   expected. Ask for a screenshot or an example if it would help.
3. **The goal**: what should happen instead, and why it matters (time lost,
   error risk, a client waiting, a deadline). Who asked for it.
4. **Done when**: how will they know it is fixed? Propose two or three
   concrete checks from what you heard (« sur la page X, en faisant Y, on voit
   Z ») and let them correct or add.
5. **Urgency**: blocking now, needed by a date, or when possible.
6. **Out of scope** (only if the need is broad): what this ticket should not
   try to solve.

Stop when you can fill the template below; five or six questions is usually
enough. If the answers describe several unrelated problems, say so and offer
one ticket each.

## 3. Check the code (read-only)

Before drafting, look at the project the way the code-questions skill does:

- Search for duplicates: `gh issue list --search "<mots>" --state all`. If one
  matches, show it and offer to comment on it instead.
- Find where the feature lives and how it behaves today. Note the files likely
  touched. If the code contradicts what the user described, ask them about it
  rather than picking one.
- Everything you conclude from the code is a hypothesis: write it as such. Do
  not invent causes.

## 4. Size check

A ticket should be deliverable by one developer (or one agent) in about a day.
It is too big if any of these is true:

- it changes more than one screen or flow that could be delivered separately;
- it needs a product decision nobody has taken yet (« on ne sait pas encore si... »);
- nobody knows where the problem comes from;
- the "done when" list goes past six checks.

When it is too big, propose a split the user can understand, in this order:
first a ticket to decide the open question or to investigate the cause, then
one ticket per result the user will see. Each one must make sense on its own.
If the split is not clear to you either, write one ticket and add, under
« Contexte », « À découper par un développeur avant de commencer ».

## 5. Draft

Title: the finding or the outcome, concrete, with numbers when there are some
(« L'export Excel des factures s'arrête à 1 000 lignes », not « Problème export »).

Body, in the project's ticket language (headings below in French; these are the
ticket-flow headings, keep them so the developers' tools can read the ticket):

```markdown
## Contexte
Le problème aujourd'hui : quoi, où, pour qui, depuis quand, à quelle fréquence.
Pour un bug : étapes pour reproduire, résultat obtenu, résultat attendu.
Demandé par : <rôle ou personne>, le <date>. Urgence : <bloquant / avant le JJ/MM / quand possible>.

## Ce qu'on veut
Le résultat attendu en une ou deux phrases, et pourquoi ça compte.

## Fichiers probablement touchés
- `chemin/fichier` : ce qui y change (hypothèse, à confirmer par le développeur)

## Fini quand
- [ ] critère vérifiable par quelqu'un d'autre, sans demander à l'auteur

## Comment vérifier
1. Aller sur ..., faire ..., constater ...

## Hors périmètre
Ce que ce ticket ne résout pas.

## Qui valide
<la personne qui a fait la demande, ou celle qui recettera>
```

Leave out a section that has nothing to say, except « Ce qu'on veut » and
« Fini quand ». « Fini quand » boxes must be checkable: no « ça marche bien ».

Labels: a type label that exists in the repository (bug, enhancement...), and
the mandatory labels of the `## Workflow` section if there is one, except
ticket-flow's `model:` and `taille:` labels: never set those, a developer sets
them when qualifying the ticket. Never create a label without asking.

Security: if the need touches logins, rights, one client seeing another's data,
files people upload, payments or secrets, say so in « Contexte » and add the
`sécurité` label if the repository has it.

## 6. Confirm, create, report

1. Show the full draft (title, body, labels) and wait for an explicit
   go-ahead. Apply the corrections and show it again if they are substantial.
2. Create it: write the body to a temporary file, then
   `gh issue create --title ... --body-file <file> --label ...`. Read the
   issue number and link from the output.
3. If the project has a board, add the issue
   (`gh project item-add <n> --owner wearegraphite --url <issue url>`) and set
   its status to the "to do" option and the fields the `## Workflow` section
   lists (see the github-tracking skill for the commands).
4. Give the user the link and a one-line summary. If you split the need, list
   every ticket created.

## Never

- Create, edit or comment an issue without the user's go-ahead.
- Put credentials, client personal data or commercially sensitive figures in a
  ticket. Describe them (« un client grand compte ») instead.
- Present a guess about the code as a fact.
- Modify the project's files: the clone is read-only.
