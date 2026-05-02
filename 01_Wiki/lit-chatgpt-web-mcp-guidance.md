---
title: "Literature: ChatGPT Web MCP Guidance"
author: "codex"
date: "2026-05-01"
status: "active"
type: "literature"
aliases:
  - "ChatGPT Web MCP Guidance"
  - "ChatGPT MCP Remote Server Guidance"
  - "OpenAI ChatGPT MCP Guidance"
source: "https://help.openai.com/en/articles/12584461-developer-mode-and-mcp-apps-in-chatgpt-beta"
---

# Literature: ChatGPT Web MCP Guidance

Current OpenAI help guidance for exposing MCP-backed tools to ChatGPT web.
This note is intentionally conservative: it separates what is verified in the
current help article from what is plausible but not yet safe to treat as policy.

---

## Verified

- ChatGPT web supports `remote servers` for MCP.
- Local MCP servers are not supported in ChatGPT web.
- Full MCP support, including write/modify actions, is available for ChatGPT Business and Enterprise/Edu.
- Pro users can use MCP with read/fetch permissions in developer mode.
- ChatGPT shows explicit confirmation modals before write/modify actions.
- App configuration requires an endpoint, required metadata, and an authentication mechanism if applicable.
- OpenAI says custom MCP apps/connectors are web only in this flow.

## Likely But Not Yet Safe To Treat As Canonical

- The deployment will probably need a public HTTPS endpoint.
- A tunnel or reverse proxy may be the simplest way to publish a vault-hosted service.
- An auth header or OAuth flow is likely the right protection layer for a public endpoint.

## Not Safe To Claim

- That a particular transport such as SSE is the only supported remote transport, unless separately verified in current product docs.
- That a fixed per-call timeout is part of the current product contract.
- That a specific UI label or header name is guaranteed to remain stable.

## Implication For Vulture Nest

The safest implementation path is a remote MCP server in front of the vault
with explicit auth and narrow tools, not a direct local stdio connector.
Write actions should remain atomic so ChatGPT's confirmation dialog maps to a
single, understandable vault mutation.

## See Also

- [[mcp-remote-connections]]
- [[lit-mcp-authorization]]
- [[lit-mcp-security-best-practices]]
- [[mcp-moc]]
