---
title: Anthropic MCP Connector
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-mcp-connector
  - anthropic-mcp-client
source: "[[lit-anthropic-tool-use-depth]]"
---

# Anthropic MCP Connector

The **MCP Connector** lets the Claude Messages API act as an MCP client — connecting to remote MCP servers without the caller implementing an MCP client locally. Tool discovery and execution happen server-side within the API call.

Requires beta header: `anthropic-beta: mcp-client-2025-11-20`. The previous version (`mcp-client-2025-04-04`) is deprecated. Not available on Amazon Bedrock or Google Vertex AI. Currently supports only tool calls from the MCP spec (not prompts or resources via the `mcp_servers` API parameter).

## Request Structure

Two components must be provided together:

1. **`mcp_servers` array** — server connection details (URL, auth token)
2. **`mcp_toolset` in `tools` array** — which tools to enable and how

```python
response = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=1000,
    messages=[{"role": "user", "content": "What tools do you have?"}],
    mcp_servers=[{
        "type": "url",
        "url": "https://example-server.modelcontextprotocol.io/sse",
        "name": "example-mcp",
        "authorization_token": "YOUR_TOKEN",
    }],
    tools=[{"type": "mcp_toolset", "mcp_server_name": "example-mcp"}],
    betas=["mcp-client-2025-11-20"],
)
```

Every server in `mcp_servers` must be referenced by exactly one MCPToolset. Every MCPToolset must reference a defined server.

## Tool Configuration Patterns

### Enable all (default)
```json
{"type": "mcp_toolset", "mcp_server_name": "my-server"}
```

### Allowlist — only specific tools
```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "my-server",
  "default_config": {"enabled": false},
  "configs": {
    "search_events": {"enabled": true},
    "create_event": {"enabled": true}
  }
}
```

### Denylist — all except excluded
```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "my-server",
  "configs": {
    "delete_all_events": {"enabled": false}
  }
}
```

Configuration precedence: tool-specific `configs` > `default_config` > system defaults.

## Deferred Loading (for Large Tool Sets)

`defer_loading: true` in a tool's config prevents its description from being sent to the model initially. The Tool Search tool then fetches tool descriptions on demand. This matters when a server exposes dozens of tools that would bloat the context.

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "large-server",
  "default_config": {"defer_loading": true},
  "configs": {
    "frequently_used_tool": {"defer_loading": false}
  }
}
```

## Authentication

The MCP Connector passes an OAuth Bearer token via `authorization_token`. The caller manages the OAuth flow and token refresh — the API does not handle auth flows. For testing, the MCP Inspector (`npx @modelcontextprotocol/inspector`) can guide through an OAuth flow to obtain a token.

## Response Content Block Types

When Claude uses MCP tools, two new block types appear in the response:

**`mcp_tool_use`** — Claude's tool call:
```json
{
  "type": "mcp_tool_use",
  "id": "mcptoolu_014Q35R...",
  "name": "echo",
  "server_name": "example-mcp",
  "input": {"param1": "value1"}
}
```

**`mcp_tool_result`** — The tool's return value:
```json
{
  "type": "mcp_tool_result",
  "tool_use_id": "mcptoolu_014Q35R...",
  "is_error": false,
  "content": [{"type": "text", "text": "result"}]
}
```

## Client-Side TypeScript Helpers

For cases that need local STDIO servers, MCP prompts, or MCP resources (not covered by the API `mcp_servers` parameter), the TypeScript SDK provides type-conversion helpers:

| Helper | Purpose |
|---|---|
| `mcpTools(tools, mcpClient)` | Convert MCP tools for use with `toolRunner()` |
| `mcpMessages(messages)` | Convert MCP prompt messages to Claude API format |
| `mcpResourceToContent(resource)` | Convert MCP resource to content block |
| `mcpResourceToFile(resource)` | Convert MCP resource to file object for upload |

These are useful when managing your own MCP client connection alongside the Anthropic SDK.

## Architectural Tradeoff

The MCP Connector removes the need to implement an MCP client, which simplifies deployment significantly. The cost is less control: tool execution happens inside the API call with Anthropic's infrastructure managing the MCP connection. Use the client-side helpers when you need local servers, non-tool MCP capabilities (prompts, resources), or more control over the transport.

## See also

- [[anthropic-tool-use]]
- [[anthropic-messages-api]]
- [[mcp-moc]]
- [[mcp-client-development]]
- [[lit-anthropic-tool-use-depth]]
