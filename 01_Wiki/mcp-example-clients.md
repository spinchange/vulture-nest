---
title: MCP Example Clients
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-hosts, applications-supporting-mcp]
---
# MCP Example Clients

A wide range of applications now support MCP, acting as **Hosts** that orchestrate interactions between LLMs and MCP servers.

## Featured Clients
*   **[Claude Desktop App](https://claude.ai/download)**: The primary consumer for local stdio servers.
*   **[Cursor](https://cursor.com/)**: AI-first code editor with deep MCP integration for code generation and refactoring.
*   **[VS Code (GitHub Copilot)](https://code.visualstudio.com/)**: Leverages MCP servers for project-wide planning and execution.
*   **[Gemini CLI](https://github.com/google-gemini/gemini-cli)**: Open-source terminal agent with native MCP support.
*   **[Cline](https://github.com/cline/cline)**: Autonomous coding agent in VS Code that can create and manage its own MCP servers.

## Supported Feature Tiers
Clients differ in which part of the protocol they implement:
*   **Core**: Resources, Prompts, and Tools.
*   **Advanced**: Sampling (Server asks Client's LLM for text), Roots (Client defines file boundaries), and Elicitation (Server asks User for input).

## Implementation Diversity
*   **IDEs**: Cursor, Windsurf, Zed, JetBrains.
*   **Terminal/CLI**: mcpc, Amazon Q CLI, goose.
*   **Web/SaaS**: Claude.ai, ChatGPT, Microsoft Copilot Studio.
*   **No-Code Platforms**: Langflow, MindPal, AgenticFlow.

---
## References
* Source: `00_Raw/mcp/Example Clients.md`
* [[mcp-client-development]]
* [[mcp-client-features]]
