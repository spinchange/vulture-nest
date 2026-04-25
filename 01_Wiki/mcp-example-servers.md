---
title: MCP Example Servers
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-server-examples, reference-mcp-servers]
---
# MCP Example Servers

Official and community reference implementations showcase the versatility of MCP for exposing tools and data to AI models.

## Official Reference Servers
*   **[Fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch)**: Converts web content into LLM-friendly formats.
*   **[Filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)**: Secure local file operations with path scoping.
*   **[Git](https://github.com/modelcontextprotocol/servers/tree/main/src/git)**: Tools for reading, searching, and manipulating repositories.
*   **[Memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)**: Persistent knowledge-graph-based memory.
*   **[Sequential Thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)**: Reflective problem-solving via thought sequences.
*   **[Everything](https://github.com/modelcontextprotocol/servers/tree/main/src/everything)**: A comprehensive test server covering tools, resources, and prompts.

## Quick Start (Direct Execution)
*   **TypeScript (npx)**: `npx -y @modelcontextprotocol/server-memory`
*   **Python (uvx)**: `uvx mcp-server-git`

## Official Integrations
Many companies maintain official MCP servers for their platforms:
*   **GitHub**: Repository and issue management.
*   **Slack**: Channel and message interaction.
*   **Brave Search**: Real-time web search results.
*   **Google Drive**: Document access and retrieval.

---
## References
* Source: `00_Raw/mcp/Example Servers.md`
* [[mcp-server-features]]
* [[mcp-local-connections]]
