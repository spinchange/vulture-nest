---
title: Microsoft.Data.Sqlite Agent Patterns
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [ado-net-sqlite-agent-patterns, csharp-sqlite-patterns, sqlite-agent-patterns]
---

# Microsoft.Data.Sqlite Agent Patterns

The PoShWiKi codebase is a compact example of using **`Microsoft.Data.Sqlite` as an agent-memory substrate** without introducing an ORM. Its value is not architectural novelty, but the clarity of its patterns.

## 1. Self-Contained SQLite Runtime

PoShWiKi loads `Microsoft.Data.Sqlite.dll` and the `SQLitePCLRaw` dependency chain from a local `lib/` directory, then initializes the native provider at module import time.

This pattern matters for agents because it avoids "works on my machine" drift:
- the managed assembly is bundled
- the native SQLite library is bundled
- the host process (`pwsh`) becomes the delivery vehicle for a deterministic storage stack

This is a practical template for local-first agent tools that cannot rely on global package installation.

## 2. Connection-Per-Operation Lifecycle

The repository uses a small helper that:
1. builds a `Data Source=...` connection string
2. constructs `SqliteConnection`
3. opens the connection
4. returns it to a narrowly scoped caller

Each SQL helper then creates a command, executes it, and disposes the connection in a `finally` block. This is a strong pattern for small agent tools because it minimizes hidden state and reduces the chance of stale long-lived connections.

## 3. Parameterized Command Construction

PoShWiKi binds user input through `AddWithValue()` rather than string interpolation:
- `@Title`
- `@Content`
- `@Q`

For agentic workflows, this is the minimum safe default. The model can generate dynamic values, but the query shape remains fixed and injection-resistant.

## 4. Read Path: Reader to Plain Object

`Invoke-WikiSql` executes `ExecuteReader()`, iterates columns dynamically, and hydrates each row into an ordered `PSCustomObject`.

The transferable C# lesson is:
- use a low-level reader when the schema is tiny
- translate rows into a plain boundary type immediately
- keep the return contract serializable

In a C# service, the equivalent shape would be a `record`, DTO, or dictionary. In PoShWiKi, `PSCustomObject` serves that same boundary role.

## 5. Write Path: Explicit Non-Query + UPSERT

Writes are kept simple:
- schema bootstrap uses `CREATE TABLE IF NOT EXISTS`
- page saves use `INSERT ... ON CONFLICT(Title) DO UPDATE`
- deletes use `DELETE`

This gives agents an idempotent write surface. "Save this page" can safely mean create-or-update without first branching into separate existence checks.

## 6. Section Logic Above the Database

An important design choice is that section mutation does **not** happen through relational substructures. PoShWiKi reads the page, rewrites Markdown sections with regex, then stores the full updated page content back through the SQLite layer.

That means:
- SQLite is the durability layer
- [[powershell|PowerShell]]/.NET string logic is the document-edit layer
- the page remains a single durable unit of truth

This is often the right tradeoff for agent tools where document semantics matter more than relational normalization.

## 7. Operational Constraints Revealed by the Audit

The deep audit surfaced a few practical constraints:
- the repo is **not** a Node package, so generic JS proof tooling warns on `testOrExplain()`
- the shipped PowerShell test suite is the real verification surface
- `smoke.ps1` is brittle if `artifacts/` already exists, while `contracts.ps1`, `wrapper.ps1`, `profile-smoke.ps1`, and `concurrency.ps1` passed cleanly

This is a good reminder that agent infrastructure should expose its native test command explicitly rather than relying on ecosystem-default assumptions.

---
## References
- [[csharp-for-agentic-workflows]]
- [[poshwiki]]
- [[ms-repo-poshwiki]]
- [[powershell-moc]]
- [[sqlite-type-safety-rust-vs-csharp]]
- [[dotnet-mcp-server-patterns]]

