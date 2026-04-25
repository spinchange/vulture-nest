---
title: Python
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [python-fundamentals, python-programming]
---
# Python

**Python** is a high-level, object-oriented language whose runtime model, standard library, and tooling make it the default environment for modern LLM and agent frameworks.

## Significance for Agents
Python is where most agent stacks land first because it combines:
- [[python-data-model|A flexible object model]] for protocols, adapters, and "dunder"-driven customization.
- [[python-asyncio|Async I/O primitives]] for concurrent tool calls, network clients, and orchestration loops.
- [[python-typing|A modern typing system]] for editor support and schema-oriented development.
- [[pydantic|Pydantic]] for validating tool inputs and generating JSON Schema.
- [[python-standard-library-hubs|A strong standard library]] for file access, serialization, and embedded storage.

## Core Ideas
- Python treats code, classes, functions, modules, and instances as objects with discoverable behavior.
- The language favors readable syntax, dynamic dispatch, and gradual typing rather than compile-time enforcement.
- The standard library is broad enough that many agent prototypes can start without third-party dependencies.

## Technical Hubs
- [[python-moc]]: Structured traversal of the Python foundation.
- [[python-data-model]]: Objects, values, types, and special methods.
- [[python-asyncio]]: Coroutines, tasks, cancellation, and event-loop behavior.
- [[python-typing]]: Type hints, protocols, `TypedDict`, and `Annotated`.
- [[pydantic]]: Validation and schema generation for tool contracts.
- [[python-standard-library-hubs]]: `pathlib`, `json`, and `sqlite3` as practical building blocks.

---
## References
- [[programming-languages-moc]]
- [[python-moc]]
- [[agentic-frameworks-moc]]
