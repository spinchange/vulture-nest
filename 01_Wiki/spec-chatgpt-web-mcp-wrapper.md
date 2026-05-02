---
title: "Spec: ChatGPT Web MCP Wrapper"
author: "codex"
date: "2026-05-01"
status: "active"
type: "spec"
aliases:
  - "chatgpt-web-mcp-wrapper"
  - "remote-mcp-wrapper"
  - "vault-chatgpt-connector"
derived_from:
  - "[[lit-chatgpt-web-mcp-guidance]]"
  - "[[lit-mcp-authorization]]"
  - "[[lit-mcp-security-best-practices]]"
---

# Spec: ChatGPT Web MCP Wrapper

**Purpose:** Expose the Vulture Nest vault to ChatGPT web through a remote MCP
surface while preserving YANP integrity, write safety, and a narrow tool
surface.

---

## 1. Design Goal

Provide a remote MCP entry point for vault read, search, and write actions
without exposing the local vault process directly to ChatGPT web.

The wrapper is intentionally thin:
- it adapts the existing local vault logic,
- it terminates public requests,
- it enforces auth and request-level guardrails,
- it forwards only approved operations into the vault.

## 2. Verified Constraints

- ChatGPT web supports remote MCP servers, not local stdio servers.
- Full MCP write support is plan-gated and confirmation-gated in ChatGPT.
- Tool configuration requires an endpoint, metadata, and an auth mechanism when applicable.
- The vault should not rely on the browser client to reach the local filesystem directly.

## 3. Wrapper Responsibilities

### 3.1 Transport Boundary

The wrapper exposes a remote HTTPS endpoint for ChatGPT web. The transport
adapter used behind that endpoint should be selected to match the current
OpenAI connector requirements, but the wrapper must not assume a local-only
stdio lifecycle.

### 3.2 Authentication Boundary

The wrapper must require authentication before any tool call is executed.
Recommended implementation:
- bearer token or equivalent static secret for the first cut,
- OAuth if and when the vault needs user-granular authorization,
- explicit rotation support for any secret stored on disk.

### 3.3 Tool Boundary

Expose a narrow tool set:
- `vault_search`
- `vault_read`
- `vault_propose_write`
- `vault_apply_write`

Keep write operations atomic so the ChatGPT confirmation dialog maps to a
single, understandable mutation.

### 3.4 Policy Boundary

The wrapper must enforce:
- frontmatter validation before write,
- filename and stem hygiene,
- link integrity checks before publish,
- a reject-by-default stance for unsupported operations,
- audit logging for every accepted tool call.

## 4. Recommended Shape

The smallest durable shape for Vulture Nest is:

1. Local vault logic stays in the existing Windows workspace.
2. A thin Node.js wrapper receives remote MCP traffic.
3. The wrapper validates auth and request shape.
4. The wrapper delegates to the existing vault read/write implementation.
5. A public HTTPS endpoint exposes the wrapper to ChatGPT web.

This keeps the local vault isolated while still letting ChatGPT web read and
modify notes through a controlled boundary.

## 5. Implementation

- `02_System/chatgpt_web_mcp_wrapper.py` is the first-cut wrapper implementation.
- The script uses `FastMCP` with streamable HTTP and a static bearer-token verifier.
- The tool surface is intentionally narrow so the chat UI sees explicit read and write boundaries.

## 6. Non-Goals

- No direct exposure of the filesystem to ChatGPT web.
- No dependence on a browser-side local process.
- No broad tool surface that mixes search, read, and mutation in one call.
- No assumption that a specific transport detail will stay fixed if the
product docs change.

## 7. See Also

- [[lit-chatgpt-web-mcp-guidance]]
- [[lit-mcp-authorization]]
- [[lit-mcp-security-best-practices]]
- [[mcp-remote-connections]]
- [[mcp-moc]]
