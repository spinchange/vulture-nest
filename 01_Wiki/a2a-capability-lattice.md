---
title: A2A Capability Lattice
author: claude-sonnet-4-6
date: 2026-04-26T00:00:00.000Z
status: draft
type: permanent
aliases:
  - a2a-lattice
  - a2a-capability-set
---
# A2A Capability Lattice

**Context:** [[capability-lattice-spec]] formalizes how MCP tool manifests map to typed capability sets and how agent delegation is bounded by their intersection (§4). This note extends that lattice to the A2A layer, completing the formal closure of the [[community-protocol-trust-substrate]] theory.

`status: draft` — the A2A specification reached v1.0 but remains under active development. The lattice formalism here is grounded in the current spec; the static analysis layer (§4) is aspirational pending schema stabilization.

---

## 1. Capability Set for A2A Agents

In [[capability-lattice-spec]] §4.1, the MCP capability set is:

```
Caps(S) = { (name, ArgType, ResultType) | tool ∈ S.manifest }
```

The A2A equivalent replaces "tool in server manifest" with "skill in Agent Card":

```
Caps(A) = { (id, InputModes, OutputModes) | skill ∈ A.agentCard.skills }
```

Each element is a triple: the skill's `id`, its accepted input MIME types, and its produced output MIME types.

**Key difference from MCP:** A2A Skills do not carry explicit JSON Schema for their payloads. The contract is expressed through Part types (text, file, data) and semantic `description` rather than a typed schema. This means the A2A lattice operates at a coarser granularity than the MCP lattice:

- MCP capability analysis can be type-checked at the **field level** — is this argument's type correct?
- A2A capability analysis is bounded at the **skill level** — is this skill in scope for the caller?

The OAuth scope is the runtime mechanism that enforces the skill-level boundary.

---

## 2. Delegation as Meet (∩) at the A2A Layer

When orchestrator `O` delegates to subagent `S`, the effective capability follows the same structure as [[capability-lattice-spec]] §4.3:

```
Effective(O → S) = Caps(S) ∩ Scope(O)
```

Where:
- `Caps(S)` = skills advertised in S's Agent Card
- `Scope(O)` = skills O is currently authorized to invoke, as a subset of O's OAuth-granted scopes

The **monotonicity invariant** holds at both layers: delegation can only reduce or preserve capability, never increase it. An orchestrator cannot grant a skill it does not itself possess — the A2A equivalent of Rust's "you cannot move a value you've already moved."

### Lattice Structure

```
         ⊤ (all possible skills)
        / \
  Caps(A)  Caps(B)
        \ /
   Caps(A) ∩ Caps(B)   ← maximum safe delegation scope
        |
        ⊥ (empty — no skills)
```

- **Meet (∩):** The largest skill set both parties possess; the safe delegation ceiling.
- **Join (∪):** The union of skills; the scope of a combined agent (additive composition, not delegation).
- **Monotonicity:** Every step down the delegation chain can only reduce or preserve capability.

---

## 3. OAuth Scope as Runtime Enforcement

In the MCP lattice, the capability constraint is enforced at connection time by the MCP host: the client can only call tools present in the server's manifest. In the A2A lattice, the equivalent enforcement is **OAuth scope per request**:

1. The Agent Card declares `security_schemes` and `security` requirements, including required OAuth scopes per skill or globally.
2. The orchestrator's access token carries OAuth scopes granted by the authorization server.
3. When the orchestrator invokes a subagent skill, the subagent validates that the presented token's scopes include the scope required for that skill.
4. A token lacking a required scope → request is rejected at the A2A layer before processing begins.

This maps the lattice intersection to a runtime check: `Effective(O → S)` is the set of skills in `Caps(S)` for which `O`'s token carries the requisite OAuth scope. Skills whose scopes are absent from `O`'s token are effectively absent from the intersection — as if the orchestrator did not have the capability at all.

---

## 4. Typed Agent Card Interface (Static Analysis Analogue)

The MCP lattice enables compile-time enforcement via Rust trait bounds and C# interface hierarchies ([[capability-lattice-spec]] §4.2). The A2A equivalent is a **typed Agent Card interface** — a set of interface types derived from the Agent Card's skill list:

```typescript
// Each skill defines an interface
interface CanSummarizeUrl {
  summarizeUrl(input: TextPart): Promise<DataPart>;
}
interface CanTranslateText {
  translateText(input: TextPart, targetLanguage: string): Promise<TextPart>;
}

// An agent's capability set is the composition of its skill interfaces
interface ResearchAgentCaps extends CanSummarizeUrl, CanTranslateText {}

// Delegation is a generic bound requiring both parties to satisfy SharedCaps
function delegate<O extends SharedCaps, S extends SharedCaps, SharedCaps>(
  orchestrator: O,
  subagent: S
): DelegatedAgent<SharedCaps> {
  return new DelegatedAgent(subagent);
}
```

Invoking a skill outside `SharedCaps` is a **compile-time type error**, not a runtime OAuth rejection. This is the A2A layer of the trust-by-construction property.

**Caveat (reason for `status: draft`):** Because A2A Skills currently lack explicit typed input/output schemas (unlike MCP Tools with JSON Schema), generating typed interfaces from an Agent Card requires additional schema conventions not yet standardized in the spec. The static analysis layer is aspirational; the runtime enforcement layer (§3) is fully operational.

---

## 5. Closing the Trust Substrate

With both lattices defined, the [[community-protocol-trust-substrate]] claim is formally complete across all communication boundaries in a multi-agent system:

| Layer | Mechanism | Enforcement point |
|---|---|---|
| Runtime isolation | [[docker-sandbox]] | OS process boundary |
| Protocol isolation (tools) | MCP manifest + capability negotiation | MCP host at connection time |
| Protocol isolation (agents) | Agent Card + OAuth scope | A2A server per request |
| Type-level isolation (tools) | MCP capability lattice ([[capability-lattice-spec]]) | Compiler / static analyzer |
| **Type-level isolation (agents)** | **A2A capability lattice (this spec)** | **Type checker (aspirational)** |

The static analysis query from [[capability-lattice-spec]] §4.4 — "does any agent in the workflow transitively receive a capability it shouldn't have?" — is now answerable across both the tool layer (MCP) and the agent layer (A2A). The workflow graph `G = (V, E)` has two classes of edges: MCP tool-call edges (fully typed, statically analyzable today) and A2A delegation edges (skill-scoped, statically analyzable pending schema stabilization).

---

## References

- [[capability-lattice-spec]]
- [[a2a-protocol]]
- [[a2a-mcp-contrast]]
- [[community-protocol-trust-substrate]]
- [[mcp-architecture]]
- [[mcp-security]]
- [[docker-sandbox]]
