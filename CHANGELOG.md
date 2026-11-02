# Changelog

## 0.2.0

- Skill documents the write tools: contact tags (`find_contacts`, `add_contact_tag`, `remove_contact_tag`), post drafts (`list_media`, `list_posting_accounts`, `list_post_drafts`, `create_post_draft`, `edit_post_draft`, `unschedule_post`), automations (`list_comment_automations`, `pause_automation`, `create_comment_automation_draft`) and flows (`list_flows`, `create_flow_draft`).
- Skill documents the two-step action tools: `send_message`, `send_broadcast`, `schedule_post` and `resume_automation`, with the preview and confirmation protocol, daily limits and Instagram messaging rules.
- Rewrote the skill's "Sending and publishing" section with explicit rules: show the full preview, wait for a clear yes, never reuse ids, never loop sends.
- README tool summary and safety section updated.
- Manifest descriptions and Codex capabilities mention write tools.
- Version bumped to 0.2.0 in both plugin manifests and the skill.

## 0.1.0

- Initial release.
- Claude Code plugin and marketplace manifests.
- Codex plugin manifest, MCP declaration with OAuth, and marketplace file.
- `influently` skill (Agent Skills format), also exposed at `.agents/skills/influently`.
- Read-only tools: `list_workspaces`, `list_connected_accounts`, `list_audit_events`, `list_contact_tags`.
