---
title: MCP Client Development
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-host-build, mcp-client-sdk, build-mcp-client]
---
# MCP Client Development

Developing an **[[mcp-architecture|MCP Client]]** (the "Host") involves connecting to servers, discovering their capabilities, and orchestrating them within an AI application's thought loop.

## Core Client Responsibilities
1.  **Transport Management**: Establishing connections via Stdio or SSE.
2.  **Session Lifecycle**: Managing the `initialize` handshake and graceful shutdowns.
3.  **Capability Discovery**: Listing [[mcp-server-features|Tools, Resources, and Prompts]].
4.  **Orchestration**: Mapping LLM tool-use requests to `callTool` and feeding results back into the model.

## Implementation Patterns

### 1. Python (ClientSession)
The Python SDK uses `ClientSession` within an `AsyncExitStack` for robust transport lifecycle management.
*   **Connection**: `server_params = StdioServerParameters(command="uv", args=["run", "server.py"])`
*   **Handshake**: `async with stdio_client(server_params) as (read, write): async with ClientSession(read, write) as session: await session.initialize()`
*   **Tool Execution**: `result = await session.call_tool(tool_name, tool_args)`

### 2. TypeScript / Node.js
The TypeScript SDK uses a `Client` class with pluggable transports.
*   **Connection**: `const transport = new StdioClientTransport({ command: "node", args: ["server.js"] });`
*   **Handshake**: `const client = new Client({ name: "client", version: "1.0.0" }); await client.connect(transport);`
*   **Tool Execution**: `const result = await client.callTool({ name: toolName, arguments: toolArgs });`

## The "Thought Loop" Orchestration
A standard MCP client follows this pattern for user queries:
1.  **Context Gathering**: Retrieve all available tools from the server via `listTools`.
2.  **Model Prompting**: Send the query + tool schemas to the LLM (e.g., Claude).
3.  **Decision Handling**: If the LLM returns a `tool_use` request:
    *   Client calls `callTool` on the MCP Server.
    *   Client appends the result to the message history.
    *   Client re-prompts the LLM with the updated history.
4.  **Finalization**: Generate and display the final natural language response.

## Advanced Features
*   **Sampling**: Clients can expose their own LLM to the Server, allowing the Server to request its own completions (see `sampling/createMessage`).
*   **Roots**: Clients inform Servers about the filesystem boundaries they are allowed to access via `resources/roots/list`.

## Best Practices
*   **Secure API Keys**: Use `.env` files and avoid hardcoding credentials.
*   **Pathing**: Use absolute paths for server executables to ensure cross-platform compatibility.
*   **Error Propagation**: Tool failures should be caught and returned to the LLM as text content, allowing the model to attempt a correction.

---
## Related
* [[mcp-server-development]]
* [[mcp-client-features]]
* [[mcp-sdks]]
* [[mcp-architecture]]
- [[mcp-best-practices]]

- [[mcp-debugging]]
- [[mcp-remote-connections]]
