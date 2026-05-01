---
title: "Literature: MCP Ecosystem Examples"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Example Clients.md", "00_Raw/mcp/Example Servers.md"]
aliases: ["MCP Examples", "MCP Client List", "Reference MCP Servers"]
---

# Literature: MCP Ecosystem Examples

This literature note catalogs existing implementations of the Model Context Protocol (MCP) across both host applications (clients) and data/tool providers (servers).

## Reference Servers
The official MCP team maintains a set of reference implementations to demonstrate protocol capabilities:

- **Everything**: A testing server exposing tools, resources, and prompts simultaneously.
- **Fetch**: Web content retrieval and Markdown conversion.
- **Filesystem**: Secure local file operations with path-based access control.
- **Memory**: Persistent knowledge-graph-based memory for agent context.
- **Sequential Thinking**: Support for dynamic, reflective multi-step reasoning.
- **Git**: Tools for reading, searching, and manipulating repositories.

## Example Clients (Hosts)
A growing list of AI applications support MCP as hosts:
- **Claude Desktop**: The primary consumer implementation with robust Stdio support.
- **Visual Studio Code**: Integrated via extensions for IDE-based tool access.
- **Cursor**: Utilizes MCP for project-wide context and code-generation tools.
- **MCPJam**: A dedicated client for testing and exploring servers.

## Client Feature Matrix
Hosts are evaluated based on their support for protocol primitives:
- **Core**: Resources, Prompts, Tools, Discovery.
- **Orchestration**: Instructions, Sampling, Roots, Elicitation.
- **Operations**: Tasks, Apps (UI Widgets).
- **Security**: DCR (Dynamic Client Registration), Managed Auth.

## Community Resources
- **MCP Registry**: A central hub for discovering official and community-authored servers.
- **GitHub Servers Repo**: `modelcontextprotocol/servers` contains a curated list of official integrations.

---
## See Also
- [[mcp-moc]]
- [[lit-mcp-architecture]]
- [[lit-mcp-server-development]]
- [[lit-mcp-client-development]]
