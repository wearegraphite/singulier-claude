---
name: help
description: Explains to a non-technical Singulier team member what Claude can do for them with this plugin, how to open a project, what Claude will not do, the state of their local copy, and who to contact. Use when the user types /singulier:help or asks "help", "what can you do?", "how does this work?", "I am lost", "where do I start?". French speakers have the same content under /singulier:aide.
---

# Help

The user is not technical. Answer in their language (English here unless they
write in another one), in short sections, with no jargon and no commands to
type. Keep the whole answer to one screen. Do not list skill names or plugin
internals.

## 1. What you can ask me

Give these four groups, each with its two examples:

- **Understand the project**: "How is the price of a product calculated?", "Where does the data on this page come from?"
- **Report a problem or ask for a change**: "The export button does nothing, can you create a ticket?", "I need a new filter on the clients list."
- **Follow progress**: "Where are we on the payment integration?", "Show me my open issues."
- **Your setup**: "Check my installation.", "Also get project X on my computer."

Add: "Just write as you would to a colleague."

## 2. How to open a project

In the Claude app, click the `</>` icon, start a session, choose the folder
**Singulier**, then the project. The project updates itself at each new
session. To get another project, ask for it.

## 3. What I will not do

I do not change the project's code, merge or delete anything. If something
needs changing, I write a ticket for the developers, and I always show it to
you before creating it.

## 4. Your copy of the project

If the session is inside the Singulier workspace, give one line from the
"Singulier workspace sync" context received at session start: project, branch
followed, date of the last change, or the warning if the update failed. If
there is no such context, say that this session is not opened on a project
folder and point to section 2.

## 5. Who to contact

Run `printenv SINGULIER_CONTACT`. If it prints something, give it as the
contact for anything blocking. Otherwise say "the project admin".
