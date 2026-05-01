---
title: C# for Agentic Workflows
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [dotnet-for-agents, csharp-agent-patterns, csharp-agent-memory]
---

# C# for Agentic Workflows

The PoShWiKi repository demonstrates a pragmatic pattern for **agentic tooling in the .NET ecosystem**: keep the outer interface scriptable, but delegate durable state to a small, explicit `Microsoft.Data.Sqlite` layer.

## Core Pattern

For agent workflows, C#/.NET is strongest when it is used as the **deterministic substrate** beneath a looser shell or prompt interface:
- **Shell/UI Layer:** [[powershell|PowerShell]] functions and CLI commands provide low-friction invocation.
- **State Layer:** `Microsoft.Data.Sqlite` manages durable page storage and metadata.
- **Agent Layer:** JSON or object output gives the model a stable contract.

PoShWiKi uses PowerShell as the host, but the underlying database pattern is the same one a C# tool, ASP.NET Core service, or [[mcp-moc|MCP]] server would use.

## Why This Works for Agents

### 1. Explicit State Boundaries
The database path is resolved once, with an environment variable override (`POSHWIKI_DB_PATH`) for scratch runs and test isolation. This is a strong agent pattern because it makes "where state lives" externally controllable without changing code.

### 2. Deterministic Command Semantics
Each operation does one small thing:
- open a connection
- create a command
- bind parameters
- execute
- return plain objects

This lowers ambiguity for both humans and models. The command surface is narrow, and the storage semantics are stable.

### 3. Scriptable but Typed Infrastructure
Even though PoShWiKi is written in PowerShell, it directly uses typed .NET objects such as `Microsoft.Data.Sqlite.SqliteConnection`. This is a useful hybrid for agent systems:
- PowerShell gives fast operational glue.
- .NET gives a stable runtime, managed libraries, and predictable database access.

## Design Guidance

When building agentic tools in C#, prefer this shape when:
- you need a small local memory store
- you want predictable CRUD behavior
- an ORM would add unnecessary abstraction
- the tool must be easy to embed in shells, scripts, or MCP adapters

Prefer a heavier stack such as [[ef-core-basics]] when:
- the domain model is large
- migrations are frequent
- entity relationships are central
- stronger higher-level typing is worth the extra framework surface

## PoShWiKi-Derived Lessons

- Bundle the exact SQLite dependencies your tool needs when cross-machine reproducibility matters.
- Keep read/write operations parameterized instead of interpolating SQL.
- Return plain objects at the boundary so agents can consume results without adapter logic.
- Make test databases injectable so contract tests and concurrent runs do not mutate production state.
- Treat the CLI contract as part of the API, not just a human convenience.

---
## References
- [[microsoft-data-sqlite-agent-patterns]]
- [[ms-repo-poshwiki]]
- [[poshwiki]]
- [[dotnet-moc]]
- [[csharp-moc]]
- [[dotnet-agent-integration]]
- [[dotnet-mcp-server-patterns]]
- [[poshwiki-tools]]

