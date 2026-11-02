# Influently agent plugin

Connect AI coding agents and assistants to [Influently](https://influently.app) through its MCP server. The repo packages the server connection and an agent skill that explains how to use it, for Claude Code, Codex, Cursor, OpenCode and the Claude app.

Influently is a SaaS for creators and teams. It is organised around Workspaces, which hold connected Instagram, TikTok and YouTube accounts, contacts, automations and an audit log.

The MCP server is at `https://use.influently.app/mcp`. Today its tools are read-only: `list_workspaces`, `list_connected_accounts`, `list_audit_events` (Owner and Admin only) and `list_contact_tags`. The server lists the tools you approved, so your agent always sees the current set.

Full setup guide: https://influently.app/agent-setup

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
3. Write permissions are off by default. You turn them on only if you want them.

You can change or revoke access at any time in Influently > account settings > connected apps.

## Safety

- Access is limited to the Workspaces and permissions you approve.
- The skill tells agents to never invent IDs, never ask for or paste credentials, and to ask before any action with side effects.
- When sending or publishing tools are enabled, they use two steps: a preview with a short-lived confirmation id, then a second call after you approve. Daily limits and the Instagram messaging window apply.
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
