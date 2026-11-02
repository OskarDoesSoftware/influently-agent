# Influently agent plugin

Connect AI coding agents and assistants to [Influently](https://influently.app) through its MCP server. The repo packages the server connection and an agent skill that explains how to use it, for Claude Code, Codex, Cursor, OpenCode and the Claude app.

Influently is a SaaS for creators and teams. It is organised around Workspaces, which hold connected Instagram, TikTok and YouTube accounts, contacts, automations and an audit log.

The MCP server is at `https://use.influently.app/mcp`. The server lists the tools you approved, so your agent always sees the current set. Tools come in three kinds:

- Read tools: `list_workspaces`, `list_connected_accounts`, `list_audit_events` (Owner and Admin only) and `list_contact_tags`.
- Write tools, one step, listed on the approval page under "Allow changes": find contacts and add or remove contact tags, list media and posting accounts, create and edit post drafts, unschedule a post, list and pause comment automations, create a switched-off draft comment automation, and list flows and create an unpublished flow draft. None of them sends anything to anyone. Drafts stay drafts until a person reviews and turns them on in Influently.
- Action tools, two steps, listed under "Allow actions on real people and accounts": `send_message`, `send_broadcast`, `schedule_post` (only for a post you already reviewed in Influently) and `resume_automation`.

Agent setup instructions: https://influently.app/agent-setup/prompt.md

## Install

### Claude Code

```
/plugin marketplace add OskarDoesSoftware/influently-agent
/plugin install influently@influently
```

Then run `/mcp` to sign in.

### Codex

```
codex plugin marketplace add OskarDoesSoftware/influently-agent
```

Then install the `influently` plugin from the Codex plugin directory. If you prefer to skip the plugin, add only the server and sign in:

```
codex mcp add influently --url https://use.influently.app/mcp
codex mcp login influently
```

### Cursor

One click: [add Influently to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=influently&config=eyJ1cmwiOiJodHRwczovL3VzZS5pbmZsdWVudGx5LmFwcC9tY3AifQ==)

Or paste this into `~/.cursor/mcp.json` (or `.cursor/mcp.json` in a project):

```json
{
  "mcpServers": {
    "influently": {
      "url": "https://use.influently.app/mcp"
    }
  }
}
```

Cursor also loads the skill from `.agents/skills/influently` when you open this repo.

### OpenCode

Add to `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "influently": {
      "type": "remote",
      "url": "https://use.influently.app/mcp"
    }
  }
}
```

Then run `opencode mcp auth influently`.

### Claude app (custom connector)

In Claude, open Customize > Connectors > Add custom connector, and enter `https://use.influently.app/mcp`.

### Other skills-compatible tools

Copy `skills/influently` into your tool's skills folder, and add the MCP server URL above.

## Sign-in and approval

1. Your client opens Influently in the browser (OAuth). You never paste a token or password into the agent.
2. On first use you land on an Influently page where you choose which Workspaces and which permissions the agent gets.
3. Write permissions are off by default. You turn them on only if you want them. Permissions for actions on real people and accounts are in their own group with a warning, and are never preselected.

Existing connections keep only the permissions they were granted. You can change or revoke access at any time in Influently > account settings > connected apps. Revoking cuts the connection off at once.

## Safety

- Access is limited to the Workspaces and permissions you approve.
- The skill tells agents to never invent or guess IDs, never ask for or paste credentials, and to ask before any action with side effects.
- Sending and scheduling tools use two steps. The first call returns a preview with a confirmation id (valid 10 minutes, single use) and nothing happens. The agent must show you the full preview, and only after you clearly say yes does it call again with just the confirmation id. The server then runs exactly what the preview showed. One confirmation is one action, and the skill forbids looping sends or retrying a failed send without asking you.
- Default daily limits per connection and per Workspace are 50 messages, 1 broadcast and 3 published posts. The Instagram messaging window applies: an agent can reply only within 24 hours, and its messages are never sent under Meta's human agent tag.
- Every preview and confirmed action is recorded in the Workspace audit log, tagged with the client.
- Audit events are visible to Owners and Admins only.

## Development

```
scripts/validate.sh        # run all checks
scripts/sync-skill.sh      # copy skills/influently to .agents/skills/influently
```

`skills/influently` is the source of truth. `.agents/skills/influently` is a plain copy (not a symlink) so it works on Windows checkouts and in tools that do not follow symlinks; `validate.sh` fails if the two differ.

## Issues

Report problems or requests at https://github.com/OskarDoesSoftware/influently-agent/issues.

## License

MIT. See [LICENSE](LICENSE).
