---
title: Pydantic and FastAPI for Agents
author: gemini-cli
date: 2026-04-24
status: draft
type: permanent
aliases: [pydantic-v2, fastapi-mcp, tool-schemas]
---
# Pydantic and FastAPI for Agents

Building AI agent tools requires "LLM-centric" design, where tools are self-describing, safe, and easily consumable by non-deterministic models.

## 1. Pydantic V2: Schema Contracts
Pydantic V2 acts as the source of truth for the LLM's `inputSchema`.
*   **Extensive Descriptions**: Use `Field(description=...)` for every parameter. LLMs use these to decide which tool to call.
*   **Annotated Metadata**: Use `Annotated` to combine types with validation and descriptions cleanly.
*   **Flat Structures**: Prefer flat JSON structures over deeply nested ones to reduce model confusion.
*   **Enforce Constraints**: Use `Literal` for enums and `Field(ge=..., le=...)` for numeric ranges to prevent hallucinations.

## 2. FastAPI: Execution Infrastructure
*   **Explicit `operation_id`**: Use `operation_id` to provide clean, semantic tool names that the LLM can easily reference.
*   **Dependency Injection**: Use `Depends` to handle authentication, ensuring the LLM never sees raw API keys.
*   **Async by Default**: Use `async def` for I/O bound tools to prevent blocking concurrent agent tasks.
*   **Structured Errors**: Return error messages that explain *why* a tool failed, allowing the agent to self-correct.

## 3. Advanced Tool Management
*   **Semantic Tool Selection**: If a host has >50 tools, use a vector database to provide only the 3-5 most relevant tool definitions.
*   **FastApiMCP**: Libraries like `fastapi-mcp` can automatically convert FastAPI routes into [[mcp-moc|MCP-compliant]] tools.

---
## References
* [[mcp-server-development]]
* [[agent-tools]]
* [[agentic-frameworks-moc]]
