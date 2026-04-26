---
title: RFC — Polyglot Agent Platform ADR
author: claude-sonnet-4-6
date: 2026-04-25
status: draft
type: permanent
aliases: [polyglot-adr, tier-selection-adr, platform-adr-rfc, language-tier-adr]
---
# RFC: Polyglot Agent Platform — Architecture Decision Record

**Status:** Draft — pending Codex verification against vault implementation evidence.

This RFC proposes the formal ADR that [[dotnet-agent-integration]] and [[community-polyglot-agent-platform]] identify as missing. Its purpose: turn the observed four-tier language model into a **verifiable, enforceable design principle** so agents and contributors have a deterministic answer to "which language should I write this in?"

## Problem Statement

The vault contains tooling across four languages. Without explicit selection criteria, two failure modes emerge:

1. **Tier Collapse** — agents default to Python (Tier-3) for everything, losing compile-time safety (Tier-0 Rust) and DI composability (Tier-1 C#).
2. **Tier Creep** — automation scripts grow into services without formalizing the service contract, producing brittle cross-tier dependencies with no documented failure-mode ownership.

## Current Vault Tier Inventory (Observed)

| Tier | Language | Vault Artifacts |
|------|----------|----------------|
| 0 | Rust | `vulture-mcp` (MCP server, stdio) |
| 1 | C# / .NET | PoShWiKi (`Microsoft.Data.Sqlite` via PowerShell/.NET), proposed [[dotnet-mcp-server-patterns]] |
| 2 | PowerShell | `02_System/` (15 scripts), `00_Raw/PoShWiKi/wiki.ps1` |
| 3 | Python | Wiki knowledge only (LangGraph, smolagents, etc.) — no live vault tooling |

This inventory is a **Codex verification target**: the actual files must be audited before the ADR reaches `status: active`.

## Proposed Selection Criteria

### Tier 0 — Rust
**Select when:**
- The component must handle concurrent connections without shared mutable state bugs
- Memory safety must be compile-time verified (agent infrastructure, inference engines)
- Latency target is sub-millisecond per operation
- The artifact is a long-lived daemon or MCP server

**Ruling example:** `vulture-mcp` correctly lives here — it is a persistent MCP server exposed to clients over stdio, with no safe equivalent in other tiers.

### Tier 1 — C# / .NET
**Select when:**
- Dependency Injection is required to manage service lifetimes across the agent loop
- The tool exposes an MCP server or ASP.NET Core endpoint
- The domain model warrants an ORM (EF Core) or typed LINQ queries
- Integration with enterprise identity, auth, or the CLR security model is needed
- Latency target is 1 ms – 500 ms per operation

**Ruling example:** An MCP server that wraps a SQLite knowledge store correctly lives here, per [[dotnet-mcp-server-patterns]].

### Tier 2 — PowerShell
**Select when:**
- The task is one-shot automation, CI/CD orchestration, or vault maintenance
- Human auditability is required (human reads the script to verify correctness)
- Filesystem operations or shell interop dominate the work
- No latency constraint applies (batch or interactive use)
- The tool must satisfy the [[ps-automation-spec]] standard

**Ruling example:** All of `02_System/*.ps1` correctly lives here.

### Tier 3 — Python
**Select when:**
- The task requires the PyTorch / HuggingFace ecosystem directly
- The component is a rapid-iteration ML experiment or framework evaluation
- A Python-native framework (LangGraph, smolagents) is the point of the exercise
- No throughput constraint applies and prototype correctness takes priority

**Ruling example:** Running a smolagents evaluation harness. *Not* a production MCP server.

## Proposed Inter-Tier Communication Contracts

| Pair | Contract | Vault Evidence |
|------|----------|----------------|
| Tier 0 ↔ Tier 1 | MCP (stdio or SSE), JSON-RPC 2.0 | `vulture-mcp` ↔ Workbench (Node/JS runtime) |
| Tier 1 ↔ Tier 2 | `Add-Type` (in-process .NET assembly load) | PoShWiKi loads `Microsoft.Data.Sqlite.dll` |
| Tier 2 → Tier 1 | `pwsh -File` subprocess with JSON stdout | `run-maintenance.ps1` invoking child scripts |
| Tier 1 ↔ Tier 3 | HTTP/REST or `subprocess` | Aspirational — no live vault example yet |
| Tier 0 ↔ Tier 3 | OpenAI-compatible local REST via [[foundry-local]] | [[foundry-local]] shared-service mode |

**Invariant:** tiers only cross boundaries via **documented contracts**. A Tier-2 script must never reach into a Tier-0 binary except via MCP or explicit subprocess with known stdout shape.

## Proposed Failure Mode Responsibilities

| Tier | Failure Contract |
|------|-----------------|
| Tier 0 (Rust) | `Result<T, E>` everywhere; `panic!` only for invariant violations in tests; log structured errors via `tracing` |
| Tier 1 (C#) | Catch all exceptions at the MCP/HTTP tool boundary; return `ProblemDetails` (RFC 9457) for API errors; log via `ILogger<T>` |
| Tier 2 (PowerShell) | `$ErrorActionPreference = 'Stop'`; `Try/Catch` around critical paths; write structured errors to stderr; exit code 1 on failure |
| Tier 3 (Python) | Catch all exceptions at the API/agent boundary; return structured JSON `{"error": {...}}`; never surface raw Python traceback to an LLM |

## Proposed Enforcement Mechanism

**Option A — Pester/PowerShell lint script (`Test-TierCompliance.ps1`):**
Reads each `01_Wiki/*.md` note and checks whether code blocks or tool references that imply a tier choice are consistent with selection criteria. Reports violations as a structured list. Can be added to `run-maintenance.ps1`.

**Option B — YANP frontmatter field (`tier: [0|1|2|3]`):**
Add `tier` as an optional YANP field for notes that describe executable tools. The YANP auditor (`audit-yanp.ps1`) validates the value against the ADR criteria. Lightweight and human-readable.

**Recommendation:** Start with Option B (lower implementation cost, immediately verifiable by the existing YANP auditor). Option A can follow once the ADR is active and the tier field is in place.

## Open Questions for Codex

1. **Inventory accuracy:** Are there any Rust, C#, or Python source files in the vault that the Tier Inventory table misses? Check `00_Raw/` subdirectories.
2. **PoShWiKi tier classification:** PoShWiKi is PowerShell (Tier-2) but its core is `Microsoft.Data.Sqlite` (Tier-1 CLR). Should PoShWiKi be classified as Tier-1 or Tier-2, and does that change the contract table?
3. **Workbench tier:** `00_Raw/workbench/` is TypeScript/Node. The tier model has no Tier for JS. Does it belong as Tier-3 (dynamic, rapid iteration) or does it need its own slot given it hosts the Codex tool runner?
4. **Enforcement precedent:** Does `audit-yanp.ps1` already have extensible hooks for custom field validation, or would the `tier` field require a new validation path?

## Proposed Note to Create

Once Codex verifies the open questions, the deliverable is:
- `01_Wiki/polyglot-platform-adr.md` — `status: active`, incorporating Codex's verified facts
- `01_Wiki/polyglot-adr-rfc.md` (this note) — updated to `status: superseded` with a forward link

---
## References
- [[dotnet-agent-integration]]
- [[community-polyglot-agent-platform]]
- [[ps-automation-spec]]
- [[vault-audit-tool-spec]]
- [[agentic-tdd-patterns]]
- [[dotnet-mcp-server-patterns]]
- [[foundry-local]]
- [[hardware-aware-inference]]
