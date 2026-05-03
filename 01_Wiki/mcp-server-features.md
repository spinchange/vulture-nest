---
title: [[mcp-moc|MCP]] Server Features
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [resource-templates]
---
# MCP Server Features

MCP servers expose three primary primitives that define their capabilities and how they interact with AI applications.

## 1. Tools (Action-Oriented)
Tools are executable functions that an LLM can actively call based on user intent.
*   **Mechanism**: Defined via JSON Schema for input validation.
*   **Control**: The Model decides when and how to call them.
*   **Examples**: `search_flights`, `send_email`, `query_database`.
*   **Protocol**: `tools/list` and `tools/call`.

## 2. Resources (Data-Oriented)
Resources provide read-only data that acts as context for the LLM.
*   **Mechanism**: Accessed via unique URIs (e.g., `file:///logs/today.txt`).
*   **Types**: 
    *   **Direct Resources**: Fixed URIs for specific data.
    *   **Resource Templates**: Dynamic URIs with parameters (e.g., `logs://{date}/errors`).
*   **Control**: The Application/Host decides which resources to provide to the model.
*   **Protocol**: `resources/list`, `resources/read`, and `resources/subscribe`.

## 3. Prompts (Instruction-Oriented)
Prompts are reusable instruction templates that guide the LLM's interaction with tools and resources.
*   **Mechanism**: Parameterized templates (e.g., "Summarize these logs").
*   **Control**: The User explicitly selects and invokes them (often via slash commands).
*   **Protocol**: `prompts/list` and `prompts/get`.

## Comparative Overview

| Feature | Role | Control | Complexity |
| :--- | :--- | :--- | :--- |
| **Tools** | Active Action | Model | High (requires reasoning) |
| **Resources** | Passive Context | Application | Medium (requires retrieval) |
| **Prompts** | Guided Workflow | User | Low (pre-defined) |

---
## References
* Source: `00_Raw/mcp/Understanding MCP Servers.md`
* [[mcp-primitives]]
* [[mcp-architecture]]
- [[mcp-client-features]]

