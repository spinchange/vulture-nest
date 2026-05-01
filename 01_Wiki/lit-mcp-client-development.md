---
title: "Literature: MCP Client Development"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Build an MCP Client.md", "00_Raw/mcp/Understanding MCP Clients.md"]
aliases: ["MCP Client Guide", "Host vs Client", "Sampling and Roots"]
---

# Literature: MCP Client Development

This literature note covers the technical implementation and conceptual framework for building **Model Context Protocol (MCP)** clients and host applications.

## Host vs. Client
- **MCP Host**: The top-level AI application (e.g., Claude Desktop, IDE) that manages the user experience and coordinates multiple servers.
- **MCP Client**: The protocol-level component within the host that maintains a 1:1 connection with a specific server.

## Advanced Client Capabilities
Clients can provide specialized services to servers to enable richer agentic workflows:

| Feature | Description | Example |
| :--- | :--- | :--- |
| **Elicitation** | Allows servers to request on-demand structured input from the user. | Asking for seat preferences during a flight booking tool call. |
| **Roots** | Defines advisory filesystem boundaries (`file://`) for server operations. | Restricting a coding agent to a specific project directory. |
| **Sampling** | Allows servers to request LLM completions through the host's existing model access. | A tool asking the model to summarize a retrieved document. |

## Implementation Flow (Python)
1.  **Transport Setup**: Initialize `StdioServerParameters` with the command (python/node) and absolute path to the server script.
2.  **Session Management**: Use `ClientSession` within an `AsyncExitStack` for proper resource cleanup.
3.  **Initialization**: Call `session.initialize()` to perform the protocol handshake.
4.  **Discovery**: Retrieve server capabilities via `session.list_tools()`.
5.  **Execution Loop**: 
    - Receive user query.
    - Pass available tools to LLM.
    - Detect `tool_use` in LLM response.
    - Invoke `session.call_tool(name, args)`.
    - Return result to LLM for final synthesis.

## Best Practices
- **Resource Management**: Always use `AsyncExitStack` or equivalent to ensure pipes are closed gracefully.
- **Path Handling**: Use absolute paths for server scripts to avoid "FileNotFound" errors during host execution.
- **Human-in-the-Loop**: Implement approval checkpoints for `sampling` and high-stakes `tool_call` operations.

---
## See Also
- [[mcp-client-development]] (Permanent Note)
- [[mcp-moc]]
- [[lit-mcp-architecture]]
- [[mcp-best-practices]]
