---
title: Session Types
author: claude-sonnet-4-6
date: 2026-05-17
status: active
type: permanent
aliases:
  - session-types
  - linear-types
  - multiparty-session-types
  - mpst
  - honda-session-types
---
# Session Types

A **session type** is a type assigned to a communication channel that encodes the *entire legal sequence of messages* that may flow over it — not merely which messages are possible, but in what order, in which direction, and with what types at each step. Violating the protocol is a type error, detectable at compile time.

Session types were introduced by Kohei Honda in "Types for Dyadic Interaction" (1993) as a discipline for concurrent programs. Their relevance to multi-agent systems is direct: every structured agent interaction — tool invocation, handoff, orchestration handshake — is a protocol, and session types are the formalism that makes protocols first-class types.

---

## 1. The Core Idea

A session type is written as a *sequence of actions* on a channel:

```
!T.S    — send a value of type T, then continue as session S
?T.S    — receive a value of type T, then continue as session S
End     — close the channel (protocol complete)
```

Example — a simple request/response channel:

```
Client side:  !Request.?Response.End
Server side:  ?Request.!Response.End
```

The client sends a `Request`, then waits to receive a `Response`, then closes. The server receives a `Request`, sends a `Response`, then closes. These two types are *dual*: if one end sends, the other receives, at every step. Duality is how session types prove that two participants are talking the same protocol.

---

## 2. Linear Types — The Foundation

Session types rest on **linear types**, a type discipline from linear logic (Girard, 1987). A linear value must be used *exactly once* — it cannot be dropped or duplicated.

Applied to channels: a session channel is linear. It must be driven through every step of its protocol to completion. Abandoning it mid-session — dropping the channel after the first send without performing the required receive — is a type error.

This "must complete" property is what gives session types their safety guarantee: if the program type-checks, the protocol is guaranteed to terminate correctly from both ends.

**Affine types** (Rust's ownership model) are the relaxation: use *at most once*. A value may be dropped without using it. Rust is an affine type system, not a linear one. The practical consequence for session types in Rust is documented in [[session-types-in-rust]].

---

## 3. Duality

For every session type `S` on one end of a channel, there is a unique *dual* type `S̄` on the other end:

```
!T.S  dualizes to  ?T.S̄
?T.S  dualizes to  !T.S̄
End   dualizes to  End
```

Duality is enforced by the type system: if the two ends of a channel do not have dual types, the program does not type-check. This eliminates an entire class of protocol errors — mismatched message types, missing responses, reversed send/receive directions — at compile time.

---

## 4. Branching and Choice

Real protocols involve choices. Session types extend to branching with `⊕` (internal choice, the sender decides) and `&` (external choice, the receiver decides):

```
⊕{ ok: !Result.End, err: !Error.End }   — sender chooses between ok and err branches
&{ ok: ?Result.End, err: ?Error.End }   — receiver handles either branch
```

The dual of `⊕` is `&` and vice versa. Together, branching session types can express any finite-state protocol.

---

## 5. Recursion

Protocols that loop (e.g., a server handling multiple requests) are expressed with recursive session types:

```
μX. ?Request.!Response.X    — server loop: receive, respond, repeat
```

`μX` binds the type variable `X`, and `X` appears as a continuation, enabling the recursion. This is the type-level analogue of a state machine with a looping state.

---

## 6. Multiparty Session Types (MPST)

Binary session types (Honda 1993) cover two-party protocols. **Multiparty Session Types** (Honda, Yoshida, Carbone, 2008) extend the formalism to N-party protocols — directly applicable to multi-agent orchestration where more than two agents participate in a workflow.

In MPST, a **global type** describes the entire protocol from a bird's-eye view:

```
A → B: Request.
B → C: Forward.
C → B: Result.
B → A: Response.
End
```

The global type specifies who sends what to whom at each step. From it, the type system derives a **local type** for each participant — the session type seen from that participant's perspective. If all local types are projections of the same global type, the N-party protocol is *coherent*: no deadlocks, no message mismatches, no orphaned sends.

MPST is directly applicable to multi-agent workflows: each agent is a participant, the orchestration protocol is the global type, and each agent's local type is the sequence of messages it must send and receive.

---

## 7. Why This Matters for Agents

### 7.1 Protocol Completeness

An agent framework that does not use session types can only check capability *existence* (whether a tool is registered). Session types check capability *sequencing* (whether this tool may be called *right now* given the current protocol state). The two are orthogonal — see [[capability-lattice-spec]] §7.

```
Safe(agent, operation, state) iff
    operation ∈ Caps(agent)          ← capability lattice
    AND state →operation is valid    ← session type
```

### 7.2 MCP's Lifecycle is a Session Type

MCP's connection lifecycle is a textbook binary session type:

```
McpSession = !Initialize.?InitializeResult.!Initialized.ActiveSession
ActiveSession = μX. (&{ toolCall:   ?ToolCall.!ToolResult.X,
                         listChange: ?Notification.X,
                         close:      End })
```

A client that calls `tools/call` before completing the handshake is attempting to call a method in the wrong phase. With session types encoded in the SDK, this is a compile-time type error. Without them, it is a runtime protocol violation — detectable only if the server validates state, silent otherwise. The full mapping is developed in [[session-types-mcp-mapping]].

### 7.3 Handoffs as Session Types

The [[inter-agent-handoff-protocol]] and [[pattern-progressive-handoff]] patterns describe structured multi-agent ownership transfers. Each handoff is a three-phase protocol (acknowledge, transfer, confirm). An MPST global type for this protocol would make a dropped handoff — an agent that acknowledges but never transfers — a type error, not a silent failure.

---

## 8. Relationship to the Capability Lattice

The capability lattice ([[capability-lattice-spec]]) and session types are complementary, not competing:

| Dimension | Mechanism |
|---|---|
| What tools exist | Capability lattice — static set of registered operations |
| When a tool may be called | Session type — dynamic permission slice for current protocol state |
| Delegation safety | Lattice (you cannot grant what you don't possess) |
| Handshake correctness | Session type (you cannot skip the initialization phase) |

A fully type-safe agent platform needs both: the lattice for capability governance and session types for protocol sequencing.

---

## See Also

- [[session-types-in-rust]] — Practical encoding using phantom types; `session-types` and `dialectic` crates
- [[session-types-mcp-mapping]] — MCP lifecycle expressed as a session type (spec, status: draft)
- [[capability-lattice-spec]] — The capability existence complement; §7 explicitly defers to session types for sequencing
- [[community-protocol-trust-substrate]] — The community-level argument for trust-by-construction
- [[rust-phantom-types]] — The Rust mechanism used to simulate session types
- [[rust-affine-types]] — Why Rust's ownership is affine (not linear) and what this means for session channel safety
- [[mcp-transport]] — MCP's three-phase stateful lifecycle, the concrete target for [[session-types-mcp-mapping]]
- [[agentic-protocols]] — A2A and MCP as protocol specifications amenable to session type analysis
