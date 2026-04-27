---
title: Agent Tools
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [tool-definition, function-calling, mcp]
---
# Agent Tools

A **Tool** is a function provided to an LLM to complement its native capabilities (e.g., calculators, web search, database access).

## Anatomy of a Tool
To be usable by an agent, a tool must be described precisely in the **System Message**:
*   **Name:** A clear, unique identifier (e.g., `get_weather`).
*   **Description:** A textual explanation of what the tool does.
*   **Arguments:** Names and types (e.g., `location: str`).
*   **Callable:** The actual code ([[python]], JS, API) that executes the task.

## Auto-Documentation
Modern frameworks use Python introspection (decorators like `@tool`) to automatically generate tool descriptions from docstrings and type hints. This reduces the risk of the LLM receiving a mismatched specification.

## Model Context Protocol ([[mcp-moc|MCP]])
MCP is an open standard designed to unify how tools are provided to LLMs, allowing tools to be shared across different agentic frameworks without re-implementation.

## See Also
* [[agent-actions]]
* [[smolagents]]
* [[powershell-moc]] (Local tool implementation)
- [[mcp-primitives]]

