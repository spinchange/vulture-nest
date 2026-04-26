---
title: Rust SQLx Migrations
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [sqlx-migrations, rust-sqlite-migrations]
---

# Rust SQLx Migrations

`sqlx` gives Rust services a migration workflow that keeps schema changes close to the application binary and pushes more verification earlier in the lifecycle than string-built query code.

## Core Pattern

The common `sqlx` migration pattern is:
- store migrations as ordered `.sql` files
- embed them with `sqlx::migrate!`
- run them during startup before the service begins handling requests

This makes schema setup part of application boot, not a separate manual step.

## Why It Matters

For agent-facing infrastructure, this improves operational confidence:
- schema evolution is versioned and reviewable
- startup fails early if the database cannot reach the expected state
- deployment artifacts can carry both code and migration logic together

## Tradeoff

The model is stricter than direct `Microsoft.Data.Sqlite` command code. You gain stronger startup guarantees, but you accept a more opinionated workflow around migration files and application initialization.

## Bridge to C#

The contrast with direct C# SQLite usage is documented in [[sqlite-type-safety-rust-vs-csharp]]. In this vault, the comparison matters because [[microsoft-data-sqlite-agent-patterns]] shows a deliberately lightweight memory-service style, while `sqlx` emphasizes stronger lifecycle checks.

---
## References
- [[rust-mcp-patterns]]
- [[sqlite-type-safety-rust-vs-csharp]]
- [[microsoft-data-sqlite-agent-patterns]]
