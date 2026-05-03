---
title: [[mcp-moc|MCP]] Best Practices
author: gemini-cli
date: 2026-05-02
status: active
type: permanent
aliases: [mcp-patterns, mcp-optimization, mcp-security-hardening]
---
# MCP Best Practices

Operational patterns for scaling MCP host applications across numerous servers and tools.

## Progressive Tool Discovery
When a host has access to hundreds of tools, loading all definitions upfront wastes tokens and degrades performance. **Progressive Discovery** defers injecting tool definitions into the context until needed.

### The Three-Layer Pattern
1.  **Catalog**: The host exposes a `search_tools` meta-tool. The model queries it with natural language to find relevant tool names and brief descriptions.
2.  **Inspect**: The model calls `get_tool_details` for specific candidate tools to fetch their full input/output schemas.
3.  **Execute**: The model invokes the tool with full knowledge of its interface.

**Implementation Tip**: Use a threshold (e.g., 1%-5% of context window) to decide when to switch from upfront loading to progressive discovery.

## Programmatic Tool Calling (Code Mode)
Standard tool calling requires a round trip for every invocation. In **Code Mode**, the model writes a script that chains multiple tool calls. The script executes in a sandboxed environment, and only the final summary returns to the model.

### Benefits
-   **Reduced Latency**: Minimizes round trips between the model and the client.
-   **Token Efficiency**: Intermediate data stays in the sandbox and never enters the model's context.
-   **Isolation**: Sandbox execution should have no direct network access; calls are brokered by the host.

## Security & Scoping
-   **Scope Minimization**: Use a least-privilege model. Begin with baseline scopes and use incremental elevation via `WWW-Authenticate` challenges only when needed.
-   **Token Validation**: Never implement token validation from scratch. Use well-tested OAuth 2.1 libraries.
-   **Egress Control**: Run MCP servers in sandboxed environments with restricted network and filesystem access.

## Caching Considerations
-   Adding/removing tool definitions mid-conversation invalidates prompt caches. To preserve caching, append new definitions after the cache breakpoint or route calls through a stable `call_tool` meta-tool.

---
## See Also
* [[mcp-architecture]]
* [[mcp-security]]
* [[mcp-authorization]]
* [[mcp-moc]]
* [[agentic-protocols]]
