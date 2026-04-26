---
title: A2A and MCP — Protocol Contrast
author: claude-sonnet-4-6
date: 2026-04-26T00:00:00.000Z
status: active
type: permanent
aliases:
  - a2a-mcp
  - a2a-vs-mcp
  - protocol-comparison
---
# A2A and MCP: Protocol Contrast

MCP and A2A are **complementary**, not competing. Each protocol handles the communication boundary the other does not, and together they cover the full surface area of a multi-agent system.

---

## Side-by-Side Comparison

| Dimension | MCP | A2A |
|---|---|---|
| Relationship | Agent ↔ Tool | Agent ↔ Agent |
| Capability manifest | Tool manifest (JSON Schema) | Agent Card (JSON) |
| Capability unit | Tool | Skill |
| Discovery | Server registration at connection time | `/.well-known/agent-card.json` |
| Input/output contract | Typed JSON Schema per tool | Typed `Part` objects (text, file, data) |
| Interaction model | Single `tools/call` request / response | Stateful `Task` with multi-turn messages |
| Streaming | Not native (single round-trip per call) | Native SSE (`SendStreamingMessage`) |
| Long-running work | Not modeled — callers poll externally | First-class: `WORKING` → `COMPLETED` state machine |
| Async delivery | Not supported | Push notifications via webhook |
| Auth model | Session negotiation within the protocol | OAuth 2.0 / OIDC, out-of-band per request |
| Trust enforcement | Capability-scoped manifest at connection time | Agent Card + OAuth scope per request |
| State | Stateless per call | Stateful per task (`context_id` groups related tasks) |

---

## The Complementarity Thesis

MCP handles the **tool layer**: structured, stateless calls to deterministic resources (databases, APIs, file systems). The contract is tight — a typed input schema, a typed output schema, a single round-trip. The tool does not reason; it executes.

A2A handles the **peer layer**: autonomous agents that reason, maintain state, run for minutes or hours, and engage in multi-turn dialogue before producing an artifact. The contract is loose by design — agents are opaque peers whose internal implementation is irrelevant to the orchestrator. The orchestrator sees only skills and task state.

In a complex agentic system, the two protocols compose naturally:

```
OrchestratorAgent
    │  (A2A — peer delegation)
    ├── ResearchAgent
    │       └── (MCP — tool access) web-search, fetch
    └── WriterAgent
            └── (MCP — tool access) document-editor, spell-check
```

The orchestrator delegates to subagents via A2A. Each subagent invokes its own tools via MCP. Neither protocol is aware of the other's layer. This is the architecture that the [[community-protocol-trust-substrate]] community note identifies as a **complete trust substrate**: every communication boundary in the system is covered by a protocol that encodes explicit, inspectable capability declarations.

---

## Formal Lattice Correspondence

Both protocols support the same capability lattice structure — the delegation intersection operation `Effective(O → S) = Caps(S) ∩ Scope(O)` applies at both layers. The mechanisms that enforce it differ:

| Lattice concept | MCP layer | A2A layer |
|---|---|---|
| Capability set `Caps(X)` | Tools in server manifest | Skills in Agent Card |
| Capability unit | `(name, ArgType, ResultType)` triple | `(id, InputModes, OutputModes)` triple |
| Delegation bound | `Caps(S) ∩ Scope(O)` | `Skills(S) ∩ Scope(O)` |
| Runtime enforcement | MCP host at session-connection time | OAuth scope validation per request |
| Type-level enforcement | Rust trait bounds / C# interfaces (see [[capability-lattice-spec]]) | Typed Agent Card interfaces (see [[a2a-capability-lattice]]) |
| Granularity | Field-level (typed schema) | Skill-level (semantic + MIME type) |

The formal treatment of the MCP lattice is in [[capability-lattice-spec]] §4. The A2A equivalent is in [[a2a-capability-lattice]].

---

## References

- [[a2a-protocol]]
- [[a2a-capability-lattice]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[mcp-primitives]]
- [[mcp-security]]
- [[community-protocol-trust-substrate]]
- [[agentic-protocols]]
