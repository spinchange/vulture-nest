---
title: Session Types — Foundational Reference
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: permanent
aliases: [session-types, linear-types, affine-types, dyadic-interaction]
---
# Session Types

**Origin:** Kohei Honda, "Types for Dyadic Interaction" (CONCUR 1993). Extended to N-party protocols by Honda, Yoshida, and Carbone, "Multiparty Asynchronous Session Types" (POPL 2008).

---

## 1. Core Definition

A **session type** is the type of a communication channel. Where an ordinary type describes the shape of a value (e.g., `String`, `i64`), a session type describes the *entire legal sequence of messages* that may flow over a channel — what is sent, what is received, in what order, and in which direction. Violating the protocol is a type error.

Session types make protocol conformance a static, compile-time property. A program that calls `tools/call` before completing the initialization handshake is not a runtime bug to be caught by a guard — it is a type error, rejected before the program runs.

---

## 2. Notation

Binary session types use a small grammar. From the perspective of one party:

| Expression | Meaning |
|---|---|
| `!T.S` | Send a value of type `T`, then continue with session type `S` |
| `?T.S` | Receive a value of type `T`, then continue with session type `S` |
| `S₁ ⊕ S₂` | **Internal choice**: this party selects which branch to take |
| `S₁ & S₂` | **External choice**: the other party selects the branch |
| `End` | Session is complete; channel may be closed |
| `rec α. S` | Recursive session: `α` is a type variable bound to the whole expression, allowing loops |

### Example: Simple RPC

```
Client = !Request.?Response.End
```

The client sends a `Request`, receives a `Response`, then the session ends. This is binary, two-message, no branching.

### Example: Stateful protocol with loop

```
Client = !Init.?Ack.Loop
Loop   = rec α. (?Query.!Result.α) ⊕ End
```

The client initializes, waits for acknowledgment, then enters a loop: it either sends a `Query` and receives a `Result` (repeating), or terminates.

---

## 3. Linear Types vs. Affine Types

Session types are built on **linear types**, which are the foundation of the "use exactly once" guarantee.

| Type discipline | Rule | What it prevents |
|---|---|---|
| **Linear** | Each value must be used *exactly once* — no drop, no copy | Abandoning a session mid-protocol (compiler error); prevents resource leaks and unclosed channels |
| **Affine** | Each value may be used *at most once* — may be dropped, may not be copied | Double-use; but *silent drop is allowed* |
| **Unrestricted** | A value may be used any number of times | Nothing; standard types in most languages |

A **session channel is a linear type on a channel**: the channel must be driven through every step of its declared protocol to `End`. Abandoning it mid-session — closing the connection before completing the handshake — is a type error in a fully linear type system.

**Rust is affine, not linear.** Rust's ownership system enforces "at most once" (you cannot move a value twice) but allows silent drop (you may simply not use a value). This means Rust can encode session types but cannot natively enforce the "must complete" constraint. See [[session-types-in-rust]] for the workaround.

---

## 4. Duality

In a two-party session, the two ends of a channel must have *complementary* types. The **dual** of a session type flips every send into a receive and every receive into a send:

```
dual(!T.S)      = ?T.dual(S)
dual(?T.S)      = !T.dual(S)
dual(S₁ ⊕ S₂) = dual(S₁) & dual(S₂)   ← internal choice becomes external
dual(S₁ & S₂) = dual(S₁) ⊕ dual(S₂)   ← external becomes internal
dual(End)       = End
dual(rec α. S)  = rec α. dual(S)
```

Duality is the type-level enforcement of protocol agreement. If the client has type `!Request.?Response.End`, the server *must* have type `?Request.!Response.End` — its dual. A type system that checks duality at the point where the two ends of a channel are connected catches mismatched protocol implementations at compile time.

### Duality and MCP

In MCP's initialization handshake:

```
Client = !Initialize.?InitializeResult.!Initialized.ActiveClient
Server = ?Initialize.!InitializeResult.?Initialized.ActiveServer
```

These are duals. The type system can verify this at the point where an MCP client connects to an MCP server — before any messages are sent.

---

## 5. Recursion and Choice

Real protocols are not always linear sequences. Session types handle both loops and branching:

### Recursion

```
EchoServer = rec α. (?String.!String.α) & End
```

The server repeatedly receives a `String` and echoes it back (`α` recurses), until the client signals `End` (external choice for the server; internal choice for the client).

### Branching

Internal choice (`⊕`) means *this party* decides:

```
Client = !Query.(?Success.End ⊕ ?Error.End)
```

Wait — this is wrong. The choice here is made by whoever sends the tagged message after `!Query`. Correct reading: the server's response determines the branch, so from the client's view this is external choice (`&`):

```
Client = !Query.(?Success.End & ?Error.End)
```

The distinction matters: internal choice means you choose and notify; external choice means you wait to learn which branch the other party chose.

---

## 6. Multiparty Session Types (MPST)

Binary session types govern two-party channels. **Multiparty session types** (Honda, Yoshida, Carbone 2008) extend the formalism to N-party protocols. The key addition is the **global type**: a single type that describes the complete protocol as seen from above, naming each participant.

### Global type notation

```
A → B: T . G
```

"Party `A` sends a value of type `T` to party `B`, then protocol `G` continues."

### Example: Three-party agent workflow

```
G = Orchestrator → Worker: Task .
    Worker → Validator: Result .
    Validator → Orchestrator: ValidationReport .
    End
```

This global type is then **projected** onto each participant, producing their local (binary) session type:

```
Orchestrator_local = !Task.?ValidationReport.End
Worker_local       = ?Task.!Result.End
Validator_local    = ?Result.!ValidationReport.End
```

Projection is automatic and guaranteed to produce dual-consistent local types. If any participant's implementation does not match its local projection, it is a type error.

### Why MPST matters for agents

Multi-agent orchestration is exactly the N-party problem MPST was designed for. An orchestrator that delegates to two subagents, where one subagent's output feeds the other's input, is a three-party session. MPST provides the machinery to:

1. Specify the full workflow protocol as a global type (a design artifact).
2. Derive each agent's required behavior as a local type (a compile target).
3. Verify that each agent implementation satisfies its local type (static analysis).

---

## 7. Connection to Capability Sets and the Trust Substrate

Session types and the [[capability-lattice-spec]] are **orthogonal but complementary**:

| Dimension | Mechanism | Question answered |
|---|---|---|
| **What** tools exist | Capability lattice (set of tools in the manifest) | "Is this tool registered?" |
| **When** tools may be called | Session type (protocol state machine) | "Is calling this tool legal *right now*?" |

The lattice establishes which operations are in the capability set. The session type establishes which operations are reachable in the current protocol state. Both are needed for the full "trust-by-construction" guarantee that [[community-protocol-trust-substrate]] argues for: a tool that is in the capability set but called out of sequence is still a protocol violation — only session types catch it.

Concretely for MCP: the capability lattice proves that `tools/call` is a registered operation. The session type proves that `tools/call` is only callable *after* the `initialized` notification has been sent. See [[session-types-mcp-mapping]] for the full mapping.

---

## References

- Honda, K. (1993). "Types for Dyadic Interaction." CONCUR '93, LNCS 715.
- Honda, K., Yoshida, N., Carbone, M. (2008). "Multiparty Asynchronous Session Types." POPL '08.
- Yoshida, N., Vasconcelos, V.T. (2007). "Language Primitives and Type Discipline for Structured Communication-Based Programming." ESOP '07.
- [[capability-lattice-spec]]
- [[session-types-in-rust]]
- [[session-types-mcp-mapping]]
- [[community-protocol-trust-substrate]]
- [[mcp-architecture]]
