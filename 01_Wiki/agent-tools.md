---
title: Agent Tools
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [tool-definition, function-calling]
---
# Agent Tools

A **Tool** is a function provided to an LLM to complement its native capabilities (e.g., calculators, web search, database access).

## Core Opinion

Tools are the real execution boundary of most agent systems. In the Nest, they matter less as "features" and more as the point where a model stops predicting text and starts requesting capabilities that have cost, latency, side effects, and trust implications.

The practical split is:

- use **tools** when the model needs a bounded capability with a clear contract
- use **[[code-agents]]** when the task is too open-ended for narrow tool schemas and needs generated executable logic
- use **[[mcp-primitives]]** when the question is protocol shape rather than framework-local tool design

## Decision Rule

Start from `[[agent-tools]]` when your question sounds like one of these:

- "What should count as a tool versus plain prompt context?"
- "How should a capability be described so the model can use it reliably?"
- "Why do tool contracts fail even when the underlying function works?"
- "How do framework-local tools relate to MCP?"

## Anatomy of a Tool
To be usable by an agent, a tool must be described precisely in the **System Message**:
*   **Name:** A clear, unique identifier (e.g., `get_weather`).
*   **Description:** A textual explanation of what the tool does.
*   **Arguments:** Names and types (e.g., `location: str`).
*   **Callable:** The actual code ([[python]], JS, API) that executes the task.

Anthropic's direct API exposes this surface through a top-level `tools` field on the Messages API, with tool calls returned as `tool_use` content blocks rather than a separate role channel.

## Auto-Documentation
Modern frameworks use Python introspection (decorators like `@tool`) to automatically generate tool descriptions from docstrings and type hints. This reduces the risk of the LLM receiving a mismatched specification.

## What Makes a Tool Good

A good tool contract is:

- **narrow enough to choose correctly**: the model should know when to use it and when not to
- **structured enough to validate**: arguments should be typed and reject malformed requests
- **observable enough to recover from**: outputs and errors should give the loop something actionable
- **bounded enough to trust**: side effects and authority should be explicit

This is why Pydantic schemas, decorators, and MCP capability descriptions show up repeatedly across the vault.

## Model Context Protocol ([[mcp-moc|MCP]])
MCP is an open standard designed to unify how tools are provided to LLMs, allowing tools to be shared across different agentic frameworks without re-implementation.

## Relationship to the Rest of the Vault

- [[agent-thought-cycle]] explains where tools sit in the basic loop.
- [[mcp-primitives]] explains the protocol-level distinction between tools, resources, and prompts.
- [[anthropic-tool-use]] and [[function-calling]] cover provider-specific tool invocation surfaces.
- [[adk-multi-agent-orchestration]] shows the adjacent pattern where an entire agent is wrapped as a tool.

## See Also
* [[agent-actions]]
* [[smolagents]]
* [[powershell-moc]] (Local tool implementation)
- [[mcp-primitives]]
- [[anthropic-tool-use]]
- [[function-calling]]

