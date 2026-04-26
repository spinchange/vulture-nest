---
title: Claude Handoff — Session Types Coverage
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: handoff
targets: [claude]
aliases: [claude-session-types-handoff, session-types-seam]
---

# Claude Handoff: Session Types Coverage

## Goal

Build out session types as a first-class knowledge cluster in the vault. Session types are the missing theoretical foundation that would make the trust substrate argument formally complete: the [[capability-lattice-spec]] proves what capabilities an agent *has*; session types prove that those capabilities are *used in the correct order*. Together they close the gap between "this agent has the right tools" and "this agent uses them in a provably correct protocol sequence."

## Seam

The vault currently contains:

- **[[community-protocol-trust-substrate]]**: Claims "trust-by-construction" via type systems and MCP manifests but has no coverage of session types, which are the established formalism for exactly this class of guarantee.
- **[[mcp-architecture]]**: Documents MCP's three-phase stateful lifecycle (Initialize → Confirmed → Dynamic Updates) — a textbook example of a session type — but makes no connection to the formalism.
- **[[capability-lattice-spec]]**: Covers *what* tools an agent can call; does not address *in what order* or *under what protocol state* calls are valid.
- **[[rust-generics-and-traits]]**: Covers trait bounds; stops before phantom types, which are the mechanism Rust uses to simulate session types.

Zero notes mention session types, linear types, or affine types by name. The grep is clean.

## Context From This Session

Identified on 2026-04-26 as the highest-priority gap for the vault's current direction. Quoted from session: "Session types are the one I'd prioritize — it would retroactively sharpen both the capability lattice spec and the trust substrate theory, and it's a gap that compounds the longer it stays unfilled." The A2A and Rust type system handoffs were written in the same session.

## Background the Next Claude Needs

**Session types** (Honda 1993, "Types for Dyadic Interaction") are a type discipline for communication channels. The type of a channel encodes the *entire legal sequence of messages* that may flow over it — not just what messages are possible, but in what order, in which direction, and with what types. Violating the protocol is a type error, caught at compile time.

**Linear types** are the foundation: a linear value must be used *exactly once* — it cannot be dropped or duplicated. A session type is a linear type on a channel: the channel must be driven through every step of its protocol to completion; abandoning it mid-session is a type error.

**Affine types** (Rust's ownership) are the relaxation: use *at most once* (you may drop). Rust's ownership model is an affine type system. This means Rust can simulate linear session types but not enforce the "must complete" constraint natively — a session channel that is dropped mid-protocol will not error unless explicitly modeled.

**Connection to MCP**: MCP's Initialize → Confirmed → Dynamic Updates lifecycle is a three-state session type. If the MCP handshake were expressed as a session type, a client that called `tools/call` before `notifications/initialized` would be a *compile-time error*, not a runtime protocol violation.

**Connection to the capability lattice**: The lattice says which tools exist in the capability set. Session types say which tools can be called *right now* given the current protocol state. They compose: the lattice is the static capability map; the session type is the dynamic permission slice that is valid in the current state.

## Deliverables

### 1. Create `01_Wiki/session-types.md` (`status: active`, `type: permanent`)

The foundational reference note. Must cover:

- The core definition: a session type encodes the protocol of a channel as a type.
- **Linear types vs. affine types**: the "exactly once" vs. "at most once" distinction; why it matters for protocol completeness.
- **Duality**: in a two-party session, if one end has type `!String.?Int.End` (send a string, receive an int, close), the other end must have type `?String.!Int.End`. Duality is the type-level enforcement of protocol agreement between two parties.
- **Multiparty Session Types (MPST)**: the extension to N-party protocols — directly applicable to multi-agent orchestration where more than two agents participate in a workflow.
- **Why this matters for agents**: connect explicitly to MCP's stateful lifecycle and to the capability lattice.

Primary source: Honda 1993, "Types for Dyadic Interaction." Also: Yoshida & Vasconcelos (MPST survey). Do not paraphrase from secondary descriptions — read the actual formalism and distil it.

### 2. Create `01_Wiki/session-types-in-rust.md` (`status: active`, `type: permanent`)

Practical: how session types are implemented in Rust's type system. Must cover:

- **The phantom type simulation**: Rust has no native linear types, so session types are encoded using phantom types (`PhantomData<T>`) as state markers on a channel struct. Each `send`/`recv` operation consumes the channel (`self`, not `&self`) and returns a new channel with an updated phantom type — enforcing the "use at most once" invariant at the type level.
- **The `session-types` crate**: the canonical Rust implementation of Honda's binary session types.
- **The `dialectic` crate**: a more ergonomic modern alternative with async support via Tokio.
- **The "must complete" limitation**: Rust's affine (not linear) types mean a session channel that is dropped mid-protocol compiles. Document the workaround: `Drop` implementations that panic on incomplete sessions.
- **Code example**: a simple two-step session (send request, receive response) implemented with both crates.

Source: `session-types` crate docs and README; `dialectic` crate docs; "Session Types for Rust" by Thomas Bracht Laumann Jespersen et al. (2015).

### 3. Create `01_Wiki/session-types-mcp-mapping.md` (`status: draft`, `type: spec`)

The application: map MCP's actual connection lifecycle to a session type. This is a spec note, not a reference note — it is making a new claim.

- Express MCP's three-phase lifecycle as a session type:
  ```
  McpSession = !Initialize.?InitializeResult.!Initialized.ActiveSession
  ActiveSession = (?ToolCall.!ToolResult.ActiveSession) | (!ListChanged.ActiveSession) | End
  ```
  (Use whatever notation is clearest — invent a readable one if needed, then define it.)
- Identify where the current MCP implementation *cannot* enforce this type — what violations are possible at runtime that would be impossible if the session type were encoded in the SDK types.
- Sketch what an MCP client library would look like if it used the phantom-type session encoding from note 2: method availability should change at compile time as the session progresses through its phases.
- Connect back to [[capability-lattice-spec]]: add a note that the session type is orthogonal to the capability set — the lattice governs which tools exist; the session type governs when they may be called.

### 4. Update `01_Wiki/community-protocol-trust-substrate.md`

Add `[[session-types]]` to the Key Nodes section with the description: "The protocol-sequence complement to capability sets — proves tools are used in the correct order, not just that they exist."

### 5. Update `01_Wiki/capability-lattice-spec.md`

Add a §7 "Open Questions" or append to §6 noting that the current spec addresses capability *existence* but not capability *sequencing*, and that session types (see `[[session-types-mcp-mapping]]`) are the natural extension.

## Constraints

- `session-types-mcp-mapping.md` must be `status: draft` — it is making a novel claim about applying session types to MCP that is not established in the literature. Label it clearly as speculative-but-grounded.
- Do not create a MOC yet. Three notes do not warrant one.
- Source the theory from primary literature, not blog summaries. The Honda 1993 paper is short and readable.

---
## References
- [[community-protocol-trust-substrate]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[rust-generics-and-traits]]
- [[rust-ownership]]
- [[agentic-protocols]]
