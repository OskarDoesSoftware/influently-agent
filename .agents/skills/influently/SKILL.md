---
name: influently
description: Use when the user asks about Influently, their Influently Workspaces, connected Instagram, TikTok or YouTube accounts, contacts and contact tags, automations, or the audit log of who did what in a Workspace. Reads and (when permitted) acts on Influently data through the Influently MCP server.
license: MIT
compatibility: Requires the Influently MCP server (https://use.influently.app/mcp) and a browser for the one-time OAuth sign-in.
metadata:
  author: Oskar Kalbarczyk
  version: "0.1.0"
---

# Influently

Influently is a SaaS for creators and teams. It is organised around Workspaces. A Workspace holds connected social accounts (Instagram, TikTok, YouTube), contacts, automations and an audit log.

## Connecting

The Influently MCP server lives at `https://use.influently.app/mcp`.

- Sign-in uses OAuth in the browser. The client discovers it; there is no token or API key to paste.
- On first use the person lands on an Influently page where they approve which Workspaces and which permissions this agent gets.
- Write permissions are off by default. The person has to turn them on.
- If tools are missing or return an authorization error, the connection is not set up or not approved yet. Tell the person to complete the sign-in (in Claude Code run `/mcp`, in Codex run `codex mcp login influently`) rather than retrying.

## Tools available today

All current tools are read-only:

- `list_workspaces`: Workspaces the connection can see.
- `list_connected_accounts`: connected Instagram, TikTok and YouTube accounts in a Workspace.
- `list_audit_events`: the audit log. Owner and Admin roles only.
- `list_contact_tags`: tags used on contacts in a Workspace.

The server lists the tools the person approved. Always check the actual tool list instead of assuming; it can be shorter or longer than the list above. Prefer the tool's own description and input schema over this file.

## Choosing a Workspace

- If the connection covers several Workspaces, pass the Workspace explicitly on every call. Call `list_workspaces` first and ask the person which one when it is ambiguous.
- If only one Workspace was granted, it is implied and you do not need to pass it.

## Rules

- Never invent IDs (Workspace, account, contact, event). Take them from tool results or from the person.
- Ask before any action with side effects. Reading needs no confirmation.
- Never paste, request or store tokens, passwords or API keys. Sign-in happens in the browser only.
- Permission, plan or role errors: explain them plainly (what was denied and why, for example "audit log needs Owner or Admin"). Point the person to Influently > account settings > connected apps to change what this agent may do. Do not try to work around the error.
- HTTP 429 (rate limited): wait about a minute, then retry once. Do not hammer the server.
- Report what the data says. If a list is empty, say so instead of guessing.

## Sending and publishing (when available)

These tools are not available today and appear only when the person has enabled write permissions. When they exist they use a two-step flow:

1. The first call returns a preview and a short-lived confirmation id. Nothing is sent or published yet.
2. Show the preview to the person. Only after their explicit approval, call again with the confirmation id.

Also:

- Respect daily limits and, for Instagram messaging, the platform messaging window. If the server reports a limit or a closed window, stop and tell the person.
- Never loop sends or publishes. One approved preview covers one action. For many recipients, ask the person how to proceed instead of batching on your own.
- If the confirmation id expired, start over from the first step and show the new preview.
