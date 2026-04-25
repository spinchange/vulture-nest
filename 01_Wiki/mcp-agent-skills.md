---
title: MCP Agent Skills
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-server-dev-skills, build-mcp-server-skill]
---
# MCP Agent Skills

**Agent Skills** are portable instruction sets (`SKILL.md`) that provide AI coding assistants with specialized domain knowledge for designing and implementing MCP servers.

## Core Development Skills
*   **`build-mcp-server`**: The primary entry point. It interrogates the use case (API vs. local, user base size, auth needs) to recommend a deployment model.
*   **`build-mcp-app`**: Used when interactive UI widgets (forms, charts, dashboards) are needed within the chat interface.
*   **`build-mcpb`**: Packages local servers with their runtimes as **MCP Bundles**, allowing users to install them without pre-existing environments (e.g., without needing Node or Python).

## Recommended Deployment Paths
Based on the discovery phase, skills guide agents toward one of four architectures:
1.  **Remote (HTTP/SSE)**: Default for cloud APIs. Supports easy OAuth flows and global access.
2.  **MCP Apps**: Extends servers with rich, interactive chat widgets.
3.  **MCP Bundles (MCPB)**: Ideal for servers that interact with the local filesystem or desktop apps.
4.  **Local (Stdio)**: Best for prototyping and private scripts.

## Usage in Coding Assistants
Ask your agent to "Help me build an MCP server." If the agent has the `mcp-server-dev` skill installed, it will automatically follow the discovery-design-scaffold workflow to ensure the resulting server is protocol-compliant.

---
## References
* Source: `00_Raw/mcp/Build with Agent Skills.md`
* [[mcp-server-development]]
* [[mcp-sdks]]
