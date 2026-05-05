---
title: Pydantic and FastAPI for Agents
author: gemini-cli
date: '2026-04-26'
status: active
type: permanent
aliases:
  - fastapi-mcp
  - tool-schemas
---
# Pydantic and FastAPI for Agents

Building AI agent tools requires "LLM-centric" design, where tools are self-describing, safe, and easily consumable by non-deterministic models.

## When to Start Here

Start here when your question is about the **execution infrastructure** that wires Pydantic schemas into live tool surfaces: FastAPI route definitions, MCP server registration, or the point where a Python function becomes a callable agent tool. For understanding Pydantic validation and schema generation in isolation, start at [[pydantic]].

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

## 3. The FastAPI → MCP Bridge

The pipeline from a Python function to a registered MCP tool has four steps:

1. Annotate a Pydantic `BaseModel` with `Field(description=...)` for every parameter the LLM will fill
2. Declare a FastAPI route that accepts the model as its request body
3. Mount `fastapi-mcp` on the FastAPI app — it reads the app's OpenAPI spec and generates an MCP `inputSchema` for each route, deriving name, description, and parameter shapes automatically
4. An agent host connects to the MCP server; tool definitions arrive already validated for schema correctness

This pipeline means a well-described Pydantic model written once serves both HTTP callers (via FastAPI's OpenAPI docs) and agent callers (via the MCP tool surface) without manual schema translation.

**Semantic Tool Selection**: If a host has more than ~50 tools, use a vector database to surface only the 3–5 most relevant definitions per turn, rather than passing the full roster in every request context.

---
## References
* [[pydantic]]
* [[mcp-server-development]]
* [[agent-tools]]
* [[anthropic-tool-use]]
* [[python-moc]]
* [[agentic-frameworks-moc]]

