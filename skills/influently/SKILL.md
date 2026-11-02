---
name: influently
description: Use when the user asks about Influently, their Influently Workspaces, connected Instagram, TikTok or YouTube accounts, contacts and contact tags, automations, or the audit log of who did what in a Workspace. Reads Influently data, makes drafts and tags, and (only when the person allows it) sends messages or schedules posts, through the Influently MCP server.
license: MIT
compatibility: Requires the Influently MCP server (https://use.influently.app/mcp) and a browser for the one-time OAuth sign-in.
metadata:
  author: Oskar Kalbarczyk
  version: "0.2.0"
---

# Influently

Influently is a SaaS for creators and teams. It is organised around Workspaces. A Workspace holds connected social accounts (Instagram, TikTok, YouTube), contacts, automations and an audit log.

## Connecting

The Influently MCP server lives at `https://use.influently.app/mcp`.

- Sign-in uses OAuth in the browser. The client discovers it; there is no token or API key to paste.
- On first use the person lands on an Influently page where they approve which Workspaces and which permissions this agent gets.
- Write permissions are off by default. The person has to tick them on the approval page. Sending and publishing permissions sit in their own group, "Allow actions on real people and accounts", unticked and never preselected.
- A connection keeps only the scopes it was granted. An older connection stays read-only until the person reconnects and ticks more.
- If tools are missing or return an authorization error, the connection is not set up or not approved yet. Tell the person to complete the sign-in (in Claude Code run `/mcp`, in Codex run `codex mcp login influently`) rather than retrying.

## Tools

The server lists the tools the person approved. Always check the actual tool list instead of assuming; it can be shorter than the lists below. Prefer the tool's own description and input schema over this file.

Read tools:

- `list_workspaces`: Workspaces the connection can see.
- `list_connected_accounts` (`accounts:read`): connected Instagram, TikTok and YouTube accounts in a Workspace.
- `list_audit_events` (`audit:read`): the audit log. Owner and Admin roles only.
- `list_contact_tags` (`contacts:read`): tags used on contacts in a Workspace.

Write tools (one step, nothing is sent to anyone):

- `contacts:write` (Owner and Admin; the Workspace needs messaging): `find_contacts {query?}`, `add_contact_tag {contactId, tag}`, `remove_contact_tag {contactId, tag}`. Tags are at most 40 characters, 20 per contact and 200 per Workspace.
- `posts:write` (any member): `list_media`, `list_posting_accounts`, `list_post_drafts`, `create_post_draft {caption, mediaId, accountIds}`, `edit_post_draft {postId, caption}`, `unschedule_post {postId}`. A draft uses existing READY media only (no uploads), TikTok accounts are refused, and it is always a DRAFT: it is never reviewed, scheduled or published by these tools. `edit_post_draft` changes the caption only, clears review and schedule, and works only while the post is still a draft.
- `automations:write` (any member): `list_comment_automations`, `pause_automation {automationId}`, `create_comment_automation_draft {name?, accountId?}`. The draft is switched off with an empty flow and cannot answer anyone. A person finishes it and turns it on.
- `flows:write` (Owner and Admin): `list_flows`, `create_flow_draft {name, template?}`. An unpublished shell attached to nothing. It cannot be published through MCP.

Act tools (two steps, real people or real posts; present only when the person ticked the act scopes):

- `messages:send` (needs the Instagram messaging Capability): `send_message {contactId, text}` with text 1 to 1000 characters.
- `broadcasts:send` (Owner and Admin, plus messaging): `send_broadcast {text, segmentId?}` with text 1 to 1000 characters.
- `posts:publish` (Owner and Admin): `schedule_post {postId, scheduledAt}`. `scheduledAt` is ISO 8601 with an offset or Z. Only for a post the person has already reviewed in Influently. Past times, times over 180 days away and already scheduled posts are refused.
- `automations:enable` (any member): `resume_automation {automationId}`. Turning an automation on lets it answer real people. `automations:write` can pause but cannot switch one on.

## Choosing a Workspace

- Every Workspace tool takes an optional `workspaceId`. It is required when the connection covers several Workspaces.
- If the connection covers several, call `list_workspaces` first, pass `workspaceId` on every call, and ask the person which one when it is ambiguous.
- If only one Workspace was granted, it is implied and you do not need to pass it.

## Rules

- Never invent or guess IDs (Workspace, account, contact, post, automation, confirmation). Take them from tool results or from the person.
- Reading needs no confirmation. Ask before any write you were not clearly asked to do.
- Never paste, request or store tokens, passwords or API keys. Sign-in happens in the browser only.
- Permission, plan or role errors: explain them plainly (what was denied and why, for example "audit log needs Owner or Admin"). Point the person to Influently > account settings > connected apps to change what this agent may do. Do not try to work around the error.
- HTTP 429 (rate limited): wait about a minute, then retry once. Do not hammer the server.
- Report what the data says. If a list is empty, say so instead of guessing.
- Tell the person what a draft is: posts and automations you create stay drafts, and a person reviews and turns them on in Influently.

## Sending and publishing

Act tools use a two-step protocol:

1. Call the tool with its normal arguments. Nothing happens. The result has `status: "preview"`, a `confirmationId` (valid 10 minutes, single use) and today's remaining allowance.
2. Show the preview to the person in full: who or what it affects and the exact text or time. Only after they clearly say yes, call the same tool again with only `confirmationId` (plus `workspaceId` if the connection covers several Workspaces). Any other argument is refused and does not burn the confirmation. The server executes exactly the previewed payload.

Rules:

- Never call the confirm step without showing the full preview and getting a clear yes. Silence, a vague reply or an earlier yes for something else is not a yes.
- Never reuse or guess a `confirmationId`. One confirmation is one action.
- Never loop sends or publishes. Never retry a failed send without asking the person.
- For bulk work (many contacts, repeated posts), ask the person how to proceed instead of batching on your own.
- If a confirmation is not valid, already used or expired, tell the person and start again from step 1 with a new preview.
- If the daily limit is reached, stop and tell the person. The confirmation stays valid. Default limits per connection and per Workspace are 50 messages, 1 broadcast and 3 published posts a day (a broadcast also uses one message per recipient), but the person or the operator can have different numbers.
- If the action is refused (messaging window closed, contact opted out, send switch off, audience changed, post edited), report the reason and do not try to work around it.

Instagram messaging rules:

- `send_message` replies only inside the standard 24 hour window. A message written by an agent is never sent under Meta's human agent tag, which is for people. After 24 hours the person must reply from the Influently inbox themselves.
- Messages sent this way appear as sent by the person and pause automation for that contact for 24 hours. Opted-out contacts are refused.

Every preview and every confirmed action is recorded in the Workspace audit log, tagged with the client. The person can review or revoke the connection under Influently > account settings > connected apps. Revoking cuts it off at once.
