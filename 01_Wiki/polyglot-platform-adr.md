---
title: Polyglot Platform ADR
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [platform-adr, tier-selection-adr, language-tier-decision-record]
---
# Polyglot Platform ADR

This note is the active Architecture Decision Record for language-tier selection in the vault. It supersedes [[polyglot-adr-rfc]] and records the verified difference between the intended platform model and the source files currently checked into the workspace.

## Decision

The vault keeps the four-tier language model as its architectural decision rule:

- Tier-0: [[rust]] for long-lived, safety-critical services
- Tier-1: C# / .NET for typed integration surfaces and hosted agent services
- Tier-2: [[powershell|PowerShell]] for automation, maintenance, and shell-adjacent workflows
- Tier-3: [[python]] for ML experiments and framework-specific orchestration

This ADR also records a fifth classification that is not part of the production tier model:

- [[typescript|TypeScript]]/Node development scaffolding sits outside the tier table unless it becomes a persistent product/runtime boundary in its own right

## Verified Tier Inventory

| Tier | Language | Current Vault Status |
|------|----------|----------------------|
| 0 | Rust | No Rust source is checked into the current vault. The referenced `vulture-mcp` artifact is not present under `00_Raw/` or elsewhere in the repo as source code. |
| 1 | C# / .NET | No C# source tree is checked into the current vault. The only live .NET artifact is the bundled `Microsoft.Data.Sqlite.dll` dependency loaded by PoShWiKi. |
| 2 | PowerShell | Live tooling tier. `02_System/` contains 15 `.ps1` scripts, and `00_Raw/PoShWiKi/` contains a PowerShell CLI and module with substantive wiki logic. |
| 3 | Python | Knowledge-only tier. No live Python tooling or `.py` source files are checked into the current vault. |

## Workbench Classification

`00_Raw/workbench/` is a TypeScript/Node project with `src/` and `tests/`, and `package.json` describes it as a persistent repo workbench for coding sessions. It should not be forced into Tier-3 or a new "Tier-1.5" slot.

Decision: classify Workbench as development scaffolding outside the production tier model. It is a tool-runner/runtime used to inspect and operate on repos, not a persistent vault service or language-choice precedent for the production stack.

## Selection Criteria

### Tier 0 — Rust

Select when:
- The component is a long-lived daemon, [[mcp-moc|MCP]] server, or infrastructure process
- Memory safety and ownership guarantees matter more than iteration speed
- Concurrent state handling must be compile-time constrained
- Latency and operational predictability are primary concerns

### Tier 1 — C# / .NET

Select when:
- The component needs DI-managed lifetimes or a hosted service model
- The tool exposes a typed API, MCP surface, or ASP.NET Core boundary
- The domain model benefits from strong typing, records, and LINQ
- Enterprise identity or CLR-hosted integration is part of the problem

### Tier 2 — PowerShell

Select when:
- The task is one-shot automation, CI/CD orchestration, or vault maintenance
- Human auditability and shell-native behavior matter more than throughput
- Filesystem operations, process execution, or markdown/SQLite scripting dominate the work
- The implementation can satisfy [[ps-automation-spec]]

### Tier 3 — Python

Select when:
- The task depends directly on Python-native ML or agent frameworks
- Rapid experimental iteration matters more than static guarantees
- The artifact is an evaluation harness, ML pipeline, or framework-specific prototype

## Inter-Tier Communication Contracts

| Pair | Contract | Current Vault Evidence |
|------|----------|------------------------|
| Tier 0 ↔ Tier 1 | MCP (stdio or SSE), JSON-RPC 2.0 | Architectural contract only. No live Rust or C# service pair is checked into this vault. |
| Tier 1 ↔ Tier 2 | HTTP/REST, subprocess JSON, or hosted .NET boundary | No live Tier-1 service boundary is present. PoShWiKi's `Add-Type` call is in-process CLR interop inside a Tier-2 artifact, not a Tier-1 service boundary. |
| Tier 2 → Tier 2 | `pwsh -File` subprocess with structured stdout/stderr | `02_System/run-maintenance.ps1` invokes child scripts via `pwsh -File`. |
| Tier 1 ↔ Tier 3 | HTTP/REST or `subprocess` | Aspirational only. No live vault example. |
| Tier 0 ↔ Tier 3 | OpenAI-compatible local REST | Architectural/knowledge reference only via [[foundry-local]]. No live vault example. |

Invariant: tiers only cross boundaries through documented contracts. In-process library loading does not by itself create a new tier boundary.

## Failure Mode Responsibilities

| Tier | Failure Contract |
|------|------------------|
| Tier 0 (Rust) | Prefer `Result<T, E>`; reserve `panic!` for invariant violations and test-only paths; log structured operational errors |
| Tier 1 (C#) | Catch exceptions at tool/API boundaries; return structured errors; log through the host's logging abstraction |
| Tier 2 (PowerShell) | Set `$ErrorActionPreference = 'Stop'`; wrap critical paths in `try/catch`; write failures clearly; exit with code `1` on failure |
| Tier 3 (Python) | Catch exceptions at the API/agent boundary; return structured JSON errors; do not expose raw tracebacks to an LLM |

## Enforcement Mechanism

The current YANP auditor does not have reusable hooks for custom frontmatter validation. It regex-checks `type` and filename casing only.

Decision: start with Option A, a dedicated tier-compliance Pester/PowerShell script. If the vault later wants a `tier` frontmatter field, keep it optional and add it only after frontmatter validation is upgraded beyond the current regex-only approach.

## Codex Verification

Confirmed:
- `02_System/` contains 15 PowerShell scripts.
- `run-maintenance.ps1` invokes child scripts via `pwsh -File`.
- PoShWiKi loads `Microsoft.Data.Sqlite.dll` via `Add-Type`.
- `00_Raw/workbench/` is a TypeScript/Node project, not Python.

Revised:
- The current vault does not contain the Rust `vulture-mcp` source tree described in the RFC.
- The current vault does not contain a live C# source tree; Tier-1 is architectural intent, not a checked-in implementation.
- PoShWiKi remains Tier-2 because its domain logic is implemented in PowerShell.
- `Add-Type` in PoShWiKi is not evidence of a live Tier-1↔Tier-2 service contract.
- `audit-yanp.ps1` is too simple to justify Option B as the first enforcement step.
- The claim that all 15 `02_System/` scripts follow [[ps-automation-spec]] is not fully verified by spot-check; `orphan-check.ps1` lacks both `$ErrorActionPreference = 'Stop'` and a `try/catch` boundary.

---
## References
- [[polyglot-adr-rfc]]
- [[codex-polyglot-adr-handoff]]
- [[codex-ps-compliance-handoff]]
- [[dotnet-agent-integration]]
- [[community-polyglot-agent-platform]]
- [[ps-automation-spec]]
- [[vault-audit-tool-spec]]
- [[agentic-tdd-patterns]]
- [[dotnet-mcp-server-patterns]]
- [[foundry-local]]
- [[hardware-aware-inference]]

