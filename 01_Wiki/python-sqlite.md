---
title: [[python]] sqlite3
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [python-sqlite, sqlite3-module]
---
# Python sqlite3

`sqlite3` is Python's built-in DB-API 2.0 interface for SQLite. It gives agents a local, serverless database for persistence, indexing, and durable intermediate state.

## Core Concepts
- SQLite stores data in a single file and does not require a separate database server.
- The Python module exposes connections, cursors, transactions, parameterized queries, and row factories.
- `sqlite3.Row` is useful when results should behave like mappings as well as tuples.

## Significance for Agents
- Embedded storage is a strong fit for local agent memory, caches, work queues, and audit trails.
- SQLite is durable enough for many single-user or single-node workflows without adding operational overhead.
- Parameterized queries matter because prompt-derived strings should never be interpolated directly into SQL.

## Practical Heuristics
- Use placeholders instead of string-built SQL.
- Decide transaction boundaries explicitly for write-heavy workflows.
- Set a row factory when downstream code benefits from named-column access.
- Treat SQLite as a local systems primitive, not a substitute for a distributed database.

---
## References
- [[python-standard-library-hubs]]
- [[python-moc]]
- [sqlite3](https://docs.python.org/3.12/library/sqlite3.html)

