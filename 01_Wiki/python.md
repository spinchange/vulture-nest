---
title: Python
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases: [python-fundamentals, python-programming]
---

# Python

**Python** is a high-level, dynamically typed language whose runtime model, async primitives, and ecosystem make it the default orchestration language for LLM and agent workflows. In the Nest it is the Tier-1 layer: the language where agent loops run, tools are called, and MCP clients and servers are written.

## Core Opinion

Python is the Nest's default execution language when the work is mostly coordination: agent loops, SDK calls, schema validation, filesystem automation, and API integration. Its value is not just "easy syntax"; it is the combination of rapid iteration, first-class async support, and an ecosystem where nearly every agent framework and provider ships a Python surface first.

The practical split is:

- use **Python** when you are orchestrating work, binding tool contracts, or integrating SDKs
- use **[[rust]]** when the same system needs stronger trust guarantees, lower-level control, or a compile-time boundary

## Python in the Nest

Python's role here is specific:

**Orchestration layer (Tier-1).** In the [[rust-tier-0-patterns|tiered architecture]], Python sits above Rust's trust boundary and receives validated state from the Tier-0 binary via `serde`-serialized JSON. Agent SDKs — ADK, OpenAI Agents SDK, Swarm — all ship their primary APIs in Python. The ingestion pipeline (`vulture-ingest`) is a Python MCP server.

**SDK and integration surface.** Every major LLM provider (Anthropic, OpenAI, Google) ships Python SDKs first. The Anthropic SDK, FastMCP, Pydantic, and `asyncio` are the core toolchain for the Nest's agentic workflows. When a new tool contract needs to be defined, a new MCP server built, or a new ingestion step wired up, Python is where that work lands.

**Practical glue.** Python's standard library covers the operational needs of the vault — file access (`pathlib`), serialization (`json`), and local storage (`sqlite3`) — without requiring external dependencies for prototyping.

## Decision Rule

Start from `[[python]]` when your question sounds like one of these:

- "Which language should own this agent loop or SDK integration?"
- "How should tool schemas, validators, or MCP clients be expressed?"
- "Which Python note explains the runtime or library pattern I need?"
- "Where do I start for ingestion, orchestration, or lightweight local persistence?"

If the question is instead about hardening a protocol boundary or encoding safety guarantees at compile time, route to [[rust]].

## Language Foundation

These are the highest-leverage things to understand about Python for work in the Nest:

- **[[python-data-model]]** — everything is an object; `__dunder__` methods define behavior for built-in operations. Understanding this makes Python's flexibility predictable rather than surprising.
- **[[python-asyncio]]** — coroutines, event loops, tasks, and cancellation. All MCP clients and most agent orchestrators are async; this is not optional knowledge.
- **[[python-typing]]** — type hints, protocols, `TypedDict`, `Annotated`. Essential for defining tool schemas and understanding how Pydantic generates JSON Schema from Python types.
- **[[python-decorators]]** — the behavioral extension pattern. FastMCP registers tools as decorated functions; many agent frameworks use this pattern for tool and handler registration.
- **[[python-context-managers]]** — `with` blocks for resource safety. MCP client connections, database handles, and file handles all follow this pattern.

## Tool and Schema Layer

- **[[pydantic]]** — runtime validation and JSON Schema generation for tool inputs. The standard for defining and enforcing tool contracts in Python.
- **[[python-standard-library-hubs]]** — why `pathlib`, `json`, and `sqlite3` belong together as a practical building block set.
- **[[python-pathlib]]** — filesystem navigation, path construction, file operations.
- **[[python-json]]** — deterministic serialization boundaries.
- **[[python-sqlite]]** — embedded persistence for local memory stores and caches.

## Where to Start

Choose the path that matches the job:

1. For agent orchestration or SDK work, start with [[python-asyncio]], then [[python-typing]], then [[pydantic]].
2. For local tooling or ingestion scripts, start with [[python-standard-library-hubs]], then [[python-pathlib]] and [[python-json]].
3. For framework internals, read [[python-data-model]] and [[python-decorators]] to understand how registration and dynamic dispatch actually work.
4. For persistent local state, route from [[python-context-managers]] into [[python-sqlite]].

If you are working on the ingestion pipeline or MCP server code specifically, read [[python-asyncio]] and [[python-context-managers]] first, then [[python-standard-library-hubs]].

## Relationship to the Rest of the Vault

- [[rust-tier-0-patterns]] explains the Tier-0/Tier-1 split: Rust validates the boundary; Python orchestrates the work above it.
- [[agentic-frameworks-moc]] is the next stop if your question is framework-specific rather than language-specific.
- [[python-moc]] is the broader cluster map once you know whether you are following the async, typing, or standard-library lane.

## See Also

- [[python-moc]] — full structured traversal of the cluster
- [[agentic-frameworks-moc]] — where Python connects to agent frameworks
- [[rust-tier-0-patterns]] — Tier-0/Tier-1 architecture; Python is Tier-1
- [[programming-languages-moc]]
- [[lit-python-standard-library]]
