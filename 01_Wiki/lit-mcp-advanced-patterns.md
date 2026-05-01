---
title: "Literature: MCP Advanced Patterns & Skills"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Build with Agent Skills.md", "00_Raw/mcp/Client Best Practices.md"]
aliases: ["MCP Host Patterns", "Progressive Discovery", "Programmatic Tool Calling", "MCP Agent Skills"]
---

# Literature: MCP Advanced Patterns & Skills

This literature note covers advanced architectural patterns for scaling Model Context Protocol (MCP) host applications and the use of agent skills to scaffold server development.

## Scaling Host Applications (Client Best Practices)
As the number of tools increases, naive loading degrades performance. Two key patterns mitigate this:

### 1. Progressive Tool Discovery
- **Pattern**: Delay loading full tool definitions until needed.
- **Layers**:
    1.  **Catalog**: Model calls a lightweight `search_tools` meta-tool.
    2.  **Inspect**: Model fetches the full schema for a specific candidate tool.
    3.  **Execute**: Model invokes the tool.
- **Dynamic Management**: Connecting/disconnecting entire servers based on task relevance.

### 2. Programmatic Tool Calling (Code Mode)
- **Pattern**: The model writes code that calls multiple tools; the client executes this script in a sandbox.
- **Benefits**: Reduces token round-trips for chained operations (e.g., read -> transform -> write). Only the final summary returns to the model.
- **Infrastructure**: Requires a sandboxed runtime (e.g., Deno, Monty, Wasmtime) and a host-brokered API.

## Building with Agent Skills
[Agent skills](https://agentskills.io/home) are portable instructions that guide AI coding assistants through development.

### Official MCP Skills (`mcp-server-dev`)
- **`build-mcp-server`**: Entry point for use-case discovery and scaffolding.
- **`build-mcp-app`**: For adding interactive UI widgets.
- **`build-mcpb`**: For packaging servers as bundles (MCPB) for easy installation.

### Deployment Path Selection
The skills guide the user toward one of four paths:
1.  **Remote (Streamable HTTP)**: Default for cloud APIs.
2.  **MCP Apps**: For rich UI/widgets.
3.  **MCP Bundles (MCPB)**: For local-system access without requiring Node/Python environments.
4.  **Local (Stdio)**: For initial prototyping.

---
## See Also
- [[mcp-moc]]
- [[lit-mcp-architecture]]
- [[lit-mcp-server-development]]
- [[lit-mcp-client-development]]
- [[pattern-agent-as-tool]]
