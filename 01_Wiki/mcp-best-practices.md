---
title: MCP Best Practices
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-patterns, mcp-optimization, mcp-security-hardening]
---
# MCP Best Practices

To build robust, scalable, and secure MCP implementations, developers should follow these established patterns and security guidelines.

## 1. Context Optimization
As the number of tools and servers grows, naive loading of all definitions upfront wastes tokens and degrades LLM performance.

### Progressive Tool Discovery
Instead of loading everything, use a layered approach:
*   **Layer 1: Catalog**: Expose a lightweight `search_tools` meta-tool.
*   **Layer 2: Inspect**: The model fetches the full schema for a specific tool only when needed.
*   **Layer 3: Execute**: The model calls the tool with full knowledge.

### Dynamic Server Management
Connect and disconnect servers based on active [[agent-skills-index|Agent Skills]] or user intent to keep the context window focused.

## 2. Programmatic Tool Calling ("Code Mode")
For complex tasks requiring multiple tool calls (e.g., read -> transform -> write), have the model write a script instead of making individual round trips.
*   **Benefit**: Massive reduction in tokens and latency.
*   **Requirement**: Execute the model-generated script in a secure, network-isolated **Sandbox** (e.g., Deno, Wasmtime).

## 3. Security Hardening

### Mitigation: Confused Deputy Attack
Exploited when an MCP proxy server uses a static client ID for third-party APIs.
*   **Fix**: Implement **per-client consent** before forwarding to the third-party authorization server.

### Mitigation: Token Passthrough
The anti-pattern of accepting a client's token and passing it blindly to a downstream API.
*   **Fix**: Always validate that tokens were issued specifically for the MCP server (enforce `aud` claim).

### Mitigation: SSRF (Server-Side Request Forgery)
Malicious servers can induce clients to fetch URLs pointing to internal resources (e.g., `169.254.169.254`).
*   **Fix**: Enforce HTTPS, block private IP ranges, and use egress proxies for client deployments.

## 4. Implementation Guidelines
*   **Stdio vs. HTTP**: Use Stdio for local, single-user scripts; use HTTP/SSE for cloud-hosted or multi-user applications.
*   **Logging**: Always log to `stderr` in stdio servers. Redact credentials and tokens from all logs.
*   **Error Handling**: Use `isError: true` in protocol responses to signal tool-level failures without crashing the transport.

---
## References
* Source: `00_Raw/mcp/Client Best Practices.md`, `00_Raw/mcp/Secuirty Best Practices.md`
* [[mcp-architecture]]
* [[mcp-security]]
* [[mcp-authorization]]
- [[mcp-client-development]]
- [[rust-mcp-patterns]]
- [[mcp-server-development]]
- [[mcp-agent-skills]]
