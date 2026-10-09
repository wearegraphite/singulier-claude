---
name: code-questions
description: Answers questions from non-technical Singulier team members about how a project works, by reading its code and documentation, in plain language. Use when the user asks how a feature works, why the application behaves a certain way, where data comes from, whether something is possible or already exists, or what a technical term in the project means.
---

# Code questions

The user is usually not technical: a consultant, a project manager, a client
contact. They want an answer they can act on, not a code tour. Speak their
language (French by default at Singulier).

## How to look

1. Start with the project's own documentation: `CLAUDE.md`, `README.md`, `ONBOARDING.md`, then `docs/` or `knowledge/` folders. They often hold the business vocabulary and the decisions.
2. Then search the code for the feature, screen or term the user mentions.
3. Check the open and recent issues (`gh issue list --search "<keywords>" --state all`) when the question is about a bug or a planned change.

## How to answer

- Lead with the answer in one or two sentences, then the explanation if useful.
- Business words, not code words. Explain a technical term the first time it appears. Code snippets only if asked.
- Cite where it comes from in a light way ("défini dans `back/src/...`"), so a developer can check.
- Separate what you verified in the code from what you infer. Say clearly when you do not know or when the answer depends on data you cannot see (database content, production settings, external systems).
- The local copy follows one branch (often `main` or `dev`): what is live in production may differ. Say so when it matters.

## When the user wants a change

The project is read-only here. If the user wants something fixed or built, offer to write a GitHub issue that describes the need precisely (use the new-ticket skill), and pass on what you found in the code.

## Never

- Modify, create or delete files in the project, or run commands that change it.
- Run the application, its scripts, migrations or anything that touches a database or an external service.
- Read or reveal secrets (`.env` files, keys, tokens). If an answer depends on one, say a setting exists without showing its value.
