# Administration

## GitHub access

GitHub permissions are the real safety boundary; the plugin guardrails only
prevent mistakes.

- **Repositories**: give team members the **Triage** role. It allows creating, editing, labelling, assigning, closing and reopening issues, but not pushing code or merging pull requests. Use **Read** if they should only read and comment.
- **Project boards**: add them to each GitHub Project as **Write** (Project settings > Manage access), so they can add items, change fields and create views.
- **This plugin repository**: everyone who installs the plugin needs **Read** access to `wearegraphite/singulier-claude`, as it is private.
- Protect the long-lived branches (`main`, `dev`) with branch protection rules anyway.

## Organisation-wide deployment

Instead of each person installing the plugin, an Owner of the Claude
organisation can enable it for everyone through managed settings (claude.ai >
Organization settings > Claude Code > Managed settings):

```json
{
  "extraKnownMarketplaces": {
    "singulier": {
      "source": { "source": "github", "repo": "wearegraphite/singulier-claude" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "product-desk@singulier": true
  }
}
```

Points to know:

- Up to 0.8.0 the plugin was `singulier@singulier`. If managed settings still enable that name, replace it with `product-desk@singulier`. See [Installation](installation.md#renamed-from-singulier-090).

- `autoUpdate: true` makes Claude Code fetch new plugin versions in the background (off by default for non-Anthropic marketplaces). Set in managed settings, users cannot turn it off.

- It applies to every member, developers included. The plugin only acts inside the workspace folder, so developers' own clones are not affected.
- Members still need read access to this private repository for Claude Code to fetch it. To verify on a first test machine before rolling out.
- Managed settings can also be delivered by MDM or a `managed-settings.json` file. See the Claude Code documentation: https://code.claude.com/docs/en/plugins/org.md and https://code.claude.com/docs/en/managed-settings.md.

## Which branch team members follow

By default a clone follows the GitHub default branch of its repository. To make
everyone follow another branch, add a line to
`plugins/product-desk/config/branches.txt` and release the plugin:

```
my-project dev
```

Clones switch to it at their next session start.

## Per-clone settings

Set inside a clone with `git config` (stored in the clone's `.git/config`,
never committed). From inside the workspace, Claude is not allowed to change
them: run the commands yourself, or from a session opened outside the workspace.

| Setting | Default | Effect |
| --- | --- | --- |
| `singulier.branch` | `config/branches.txt`, else the repository's default branch | Branch this clone follows, overriding `branches.txt`. Example: `git config singulier.branch dev`. |
| `singulier.readonly` | `true` | `false` lifts the read-only guardrails for that clone (for a team member who is allowed to edit, for example documentation). |

## Contact shown to team members

The `help` / `aide` skills tell users who to contact when they are stuck. By
default they say "the project admin". To name a person or a channel without
writing it in this public repository, set the `SINGULIER_CONTACT` environment
variable, ideally in the organisation's managed settings:

```json
{ "env": { "SINGULIER_CONTACT": "the #my-team channel, or Jane Doe" } }
```

## Workspace location

Default: `~/Singulier` (macOS), `C:\Users\<name>\Singulier` (Windows). To change
it, set the `SINGULIER_WORKSPACE` environment variable, for example in the
user's Claude Code settings (`~/.claude/settings.json`):

```json
{ "env": { "SINGULIER_WORKSPACE": "/Users/name/Work/Singulier" } }
```

## Recommended in each project repository

- `.github/ISSUE_TEMPLATE/`: issue templates. Claude follows them when writing issues.
- `ONBOARDING.md` or a `CLAUDE.md` section for non-developers: business vocabulary, where things are, who owns what. It makes code answers far better.
