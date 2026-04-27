---
title: SQLite Type Safety [[rust]] vs C#
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [rust-vs-csharp-sqlite-safety, sqlite-safety-bridge]
---

# SQLite Type Safety Rust vs C#

This bridge note compares the SQLite patterns in [[rust-sqlx-migrations]] with the `Microsoft.Data.Sqlite` approach documented in [[microsoft-data-sqlite-agent-patterns]].

## The Core Difference

The Rust and C# ecosystems place safety at different layers:
- **Rust + sqlx:** pushes more verification toward compile time and startup-time migration checks.
- **C# + Microsoft.Data.Sqlite:** keeps the database API explicit and lightweight, but most query correctness remains a runtime concern.

## Rust / sqlx Pattern

In the `sqlx` workflow:
- migrations live as versioned SQL files
- `sqlx::migrate!` embeds them into the binary
- schema application is part of startup behavior

This gives a stronger deployment guarantee: the compiled server carries its schema evolution logic with it.

## C# / Microsoft.Data.Sqlite Pattern

In the PoShWiKi-style approach:
- SQL is authored as strings in code
- commands are created manually
- parameters are bound manually
- result shaping is manual

This gives more operational flexibility and less framework overhead, but it does **not** give compile-time query validation. If a column name changes, the failure shows up at runtime.

## What "Safety" Means in Practice

### Rust Strengths
- schema evolution is formalized through migrations
- deployment can be self-contained
- the ecosystem encourages stronger correctness checks before runtime

### C# Strengths
- low ceremony for small tools
- easy embedding inside shells, scripts, and desktop/server hosts
- straightforward imperative control over command execution

## Agentic Tradeoff

For agent tools, the choice is less about language preference and more about the failure model you want:
- choose the Rust/`sqlx` style when startup integrity and stronger compile-time guarantees are central
- choose the direct `Microsoft.Data.Sqlite` style when fast iteration, shell interoperability, and a thin operational surface matter more

The PoShWiKi audit suggests that the C#/.NET approach is excellent for **small local memory services**, but it relies more heavily on tests and disciplined query authoring than the Rust migration-first path.

---
## References
- [[rust-sqlx-migrations]]
- [[microsoft-data-sqlite-agent-patterns]]
- [[csharp-for-agentic-workflows]]
- [[rust-mcp-patterns]]
- [[ef-core-basics]]

