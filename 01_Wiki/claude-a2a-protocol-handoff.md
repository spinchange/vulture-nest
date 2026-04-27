---
title: Claude Handoff — A2A Protocol Coverage
author: claude-sonnet-4-6
date: '2026-04-26'
status: archived
type: fleeting
targets:
  - claude
aliases:
  - claude-a2a-handoff
  - a2a-coverage-seam
---

# Claude Handoff: A2A Protocol Coverage

## Goal

Build out the vault's Agent-to-Agent (A2A) coverage from a 5-line stub into a first-class knowledge cluster. A2A is the peer-to-peer complement to [[mcp-moc|MCP]] in the trust substrate theory: MCP governs agent-to-tool communication; A2A governs agent-to-agent delegation. Without A2A depth, the trust substrate community note and the capability lattice spec are only half-documented.

## Seam

The vault currently contains:

- **[[agentic-protocols]]**: Has a 5-line A2A section with no technical depth, no key concepts, and no links beyond `[[multi-agent-systems]]`.
- **[[community-protocol-trust-substrate]]**: References A2A as equal in importance to MCP but has no A2A-specific Key Nodes to link to — the cluster is structurally one-sided.
- **[[capability-lattice-spec]]**: Formalizes MCP tool manifests as typed capability sets. The A2A equivalent (Agent Cards → typed skill sets) is the natural next step but is not addressed.
- **[[mcp-moc]]**: A fully developed MOC with 15+ notes. A2A has no MOC and no permanent notes at all.

The gap: the theory exists, the scaffold does not. This handoff is the seam between the trust substrate claim and the engineering knowledge that would substantiate it for A2A.

## Context From This Session

This handoff was written at session close on 2026-04-26 after identifying A2A as one of four priority gaps for the vault's current direction (alongside session types, [[rust]] advanced type system, and GraphRAG implementation depth). The capability lattice spec was completed this session and covers the MCP side; A2A is the explicit next target.

## Deliverables

### 1. Create `01_Wiki/a2a-protocol.md` (`status: active`, `type: permanent`)

A permanent reference note covering the A2A protocol's core model. Must include:

- **Agent Card**: The JSON manifest that advertises an agent's identity, skills, endpoints, and authentication requirements. This is the A2A structural equivalent of an MCP server manifest — note this analogy explicitly.
- **Skill**: A discrete advertised capability with an `id`, `name`, `description`, and input/output schema. Skills in an Agent Card are the A2A equivalent of Tools in an MCP manifest.
- **Task lifecycle**: The `Task` object — how work is submitted (`tasks/send`), how streaming updates flow back via SSE (`tasks/sendSubscribe`), and how async completion works via push notification (webhook registration).
- **Authentication**: A2A uses OAuth 2.0 / OpenID Connect for agent-to-agent trust. Contrast with MCP's session-negotiation trust model.
- **Parts**: A2A message payloads are typed `Part` objects — `TextPart`, `FilePart`, `DataPart` — analogous to MCP's typed content blocks.

Source: Google's A2A specification at `https://github.com/google/A2A` and `https://google.github.io/A2A/`.

### 2. Create `01_Wiki/a2a-mcp-contrast.md` (`status: active`, `type: permanent`)

A focused comparison note — not a generic "X vs Y" but a precise mapping of how A2A and MCP divide the agent communication surface area:

| Dimension | MCP | A2A |
|---|---|---|
| Relationship | Agent ↔ Tool | Agent ↔ Agent |
| Capability manifest | Tool manifest (JSON Schema) | Agent Card (JSON) |
| Capability unit | Tool | Skill |
| Task model | Single `tools/call` request/response | Stateful `Task` with streaming + push |
| Auth model | Session negotiation | OAuth 2.0 / OIDC |
| Trust enforcement | Capability-scoped manifest | Agent Card + OAuth scope |

This note should argue the complementarity thesis explicitly: MCP handles the tool layer; A2A handles the peer layer. Together they cover the full surface area of agent-to-world and agent-to-agent communication — the same claim the [[community-protocol-trust-substrate]] makes but without the technical backing it needs.

### 3. Create `01_Wiki/a2a-capability-lattice.md` (`status: draft`, `type: spec`)

Extend the [[capability-lattice-spec]] to cover the A2A side. The capability lattice for A2A works as follows:

- `Caps(A)` for an A2A agent = the set of Skills in its Agent Card
- Delegation from orchestrator O to subagent S = `Skills(S) ∩ Scope(O)` — the same meet operation as the MCP lattice
- OAuth scopes are the runtime enforcement mechanism for this intersection; the type-level equivalent is a typed Agent Card interface (analogous to the trait/interface model in the MCP spec)
- The static analysis question is the same: does any delegation chain transitively grant a skill the receiving agent shouldn't have?

This note should connect explicitly to `[[capability-lattice-spec]]` §4 and show how the same lattice structure applies at the A2A layer, making the full trust substrate formally closed: MCP lattice (tool layer) + A2A lattice (agent layer) = complete static analysis of a multi-agent workflow.

### 4. Update `01_Wiki/agentic-protocols.md`

Expand the A2A section from 5 lines to a substantive summary (comparable to the MCP section in the same note) and add `[[a2a-protocol]]` and `[[a2a-mcp-contrast]]` to the See Also links.

### 5. Update `01_Wiki/community-protocol-trust-substrate.md`

Add `[[a2a-protocol]]` and `[[a2a-capability-lattice]]` to the Key Nodes section, filling the structural gap where the theory references A2A but the cluster has nothing to link to.

## Constraints

- Do not create a MOC for A2A yet — three permanent notes is not enough to justify one. Let the cluster grow organically first.
- The `a2a-capability-lattice.md` note should be `status: draft` until the A2A spec itself stabilizes (it was still under active development as of this session).
- Source from the official Google A2A spec and GitHub repo. Do not synthesize from secondary descriptions.

---
## References
- [[agentic-protocols]]
- [[community-protocol-trust-substrate]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[mcp-moc]]
- [[multi-agent-systems]]
- [[claude-session-types-handoff]]
- [[claude-capability-lattice-handoff]]

