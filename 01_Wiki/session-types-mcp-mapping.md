---
title: Session Types — MCP Lifecycle Mapping
author: claude-sonnet-4-6
date: 2026-05-17
status: draft
type: spec
aliases:
  - session-types-mcp-mapping
  - mcp-session-type
  - mcp-lifecycle-session-type
---
# Session Types — MCP Lifecycle Mapping

**Status: DRAFT.** This note makes a novel claim — that MCP's connection lifecycle can be expressed as a binary session type and that encoding it in the SDK would catch a class of protocol violations at compile time. The claim is grounded in the MCP specification and in established session type theory ([[session-types]], [[session-types-in-rust]]), but the specific encoding and the phantom-typed SDK sketch are not established in the MCP or Rust literature. Treat as speculative-but-grounded.

---

## 1. MCP's Stateful Lifecycle

MCP connections move through three phases defined in the specification (see [[mcp-transport]]):

**Phase 1 — Initialize**
The client sends `initialize` with its protocol version and client info. The server responds with `InitializeResult` (server info, capabilities, protocol version). The client then sends `notifications/initialized`. Only after this exchange is the session fully established.

**Phase 2 — Active**
The session is operational. The client may invoke tools (`tools/call`), list capabilities (`tools/list`, `resources/list`), read resources, make prompts, subscribe to changes, and receive server notifications. Tool calls and responses may interleave with notifications.

**Phase 3 — Closed**
Either party may close the connection. The session is terminal.

The protocol violation MCP cannot currently prevent statically: a client that calls `tools/call` before sending `notifications/initialized` is in Phase 1 still. The server may reject it at runtime, or may not — depending on implementation. The MCP SDK types do not prevent the call.

---

## 2. The Session Type

Using the notation from [[session-types]] §1–5, MCP's lifecycle expressed as a binary session type from the **client's perspective**:

```
McpSession =
    !Initialize.
    ?InitializeResult.
    !Initialized.
    ActiveSession

ActiveSession = μX. ⊕{
    toolCall:    !ToolCall.?ToolResult.X,
    listTools:   !ListToolsRequest.?ListToolsResult.X,
    readResource: !ReadResourceRequest.?ReadResourceResult.X,
    receiveNote: ?ServerNotification.X,
    close:       End
}
```

**Key:** `!T` = send, `?T` = receive, `μX` = recursive protocol variable, `⊕` = internal choice (client chooses which branch to take).

The **server's dual** (derived automatically via duality rules):

```
McpSession̄ =
    ?Initialize.
    !InitializeResult.
    ?Initialized.
    ActiveSession̄

ActiveSession̄ = μX. &{
    toolCall:    ?ToolCall.!ToolResult.X,
    listTools:   ?ListToolsRequest.!ListToolsResult.X,
    readResource: ?ReadResourceRequest.!ReadResourceResult.X,
    receiveNote: !ServerNotification.X,
    close:       End
}
```

The client's `⊕` (internal choice — "I decide which message to send next") dualizes to the server's `&` (external choice — "I handle whatever the client sends next").

---

## 3. What Current MCP Clients Cannot Enforce

Given the session type above, the following violations are detectable at compile time if the type is encoded in the SDK, but are currently only detectable at runtime (if at all):

| Violation | Session type enforcement | Current state |
|---|---|---|
| `tools/call` before `notifications/initialized` | Type error — channel is in `!Initialized` state, `toolCall` branch does not exist yet | Runtime only, server-dependent |
| Second `initialize` after handshake complete | Type error — `ActiveSession` has no `!Initialize` branch | Runtime only |
| Using a closed channel | Type error — `End` has no operations | Panics or returns error depending on transport |
| Calling `listTools` after `close` branch taken | Type error — channel is in `End` state | Undefined behavior / silent |

---

## 4. Phantom-Typed MCP Client Sketch

Using the `dialectic`-style encoding from [[session-types-in-rust]], a session-typed MCP client library would expose methods only valid in the current phase. The type of the channel changes as the protocol progresses.

```rust
use dialectic::prelude::*;
use serde_json::Value;

// MCP protocol phases as zero-sized state markers
struct Uninitialized;
struct Initializing;   // after sending Initialize, before receiving InitializeResult
struct Established;    // active session
struct Closed;

// MCP session channel — phantom type encodes current phase
struct McpChannel<Phase> {
    inner: transport::Channel,
    _phase: PhantomData<Phase>,
}

impl McpChannel<Uninitialized> {
    /// Start the MCP handshake. Only callable in the Uninitialized state.
    async fn initialize(
        self,
        req: InitializeRequest,
    ) -> Result<McpChannel<Initializing>, McpError> {
        self.inner.send_request("initialize", req).await?;
        Ok(McpChannel { inner: self.inner, _phase: PhantomData })
    }
}

impl McpChannel<Initializing> {
    /// Receive the server's response. Only callable after sending Initialize.
    async fn receive_result(
        self,
    ) -> Result<(InitializeResult, McpChannel<Established>), McpError> {
        let result = self.inner.recv_response::<InitializeResult>().await?;
        // Send the required notifications/initialized
        self.inner.send_notification("notifications/initialized", ()).await?;
        Ok((result, McpChannel { inner: self.inner, _phase: PhantomData }))
    }
}

impl McpChannel<Established> {
    /// Call a tool. Only callable in the Established state.
    async fn tool_call(
        &self,
        name: &str,
        args: Value,
    ) -> Result<ToolResult, McpError> {
        self.inner.send_request("tools/call", ToolCallParams { name, arguments: args }).await?;
        self.inner.recv_response::<ToolResult>().await
    }

    /// Close the session. Consumes the channel and returns the terminal state.
    async fn close(self) -> McpChannel<Closed> {
        let _ = self.inner.close().await;
        McpChannel { inner: self.inner, _phase: PhantomData }
    }
}

// McpChannel<Closed> has no methods — protocol is terminal.
// McpChannel<Uninitialized> has no tool_call method — compile error if attempted.
```

With this encoding, the following code **does not compile:**

```rust
// Error: method `tool_call` not found for type `McpChannel<Uninitialized>`
let result = channel.tool_call("readFile", json!({"path": "/etc/passwd"})).await;
```

The error appears at compile time, before the code ever runs.

---

## 5. Orthogonality to the Capability Lattice

The [[capability-lattice-spec]] answers: "Is this tool in the agent's registered capability set?"

This note answers: "Is this tool callable *right now* given the current connection phase?"

The two are independent but compose:

```
Safe(client, operation, state) iff
    operation ∈ Caps(client)              ← capability lattice
    AND state →operation is valid         ← session type (this spec)
```

An agent could have `tools/call` in its capability set but be in `Uninitialized` state — the lattice says "allowed", the session type says "not right now." Both checks are needed for a complete trust guarantee.

---

## 6. Limitations and Open Questions

**MCP v2 complexity:** MCP v2 (2025-03-26) added the Tasks primitive with its own lifecycle states (submitted, working, completed, canceled, failed — see [[mcp-transport]]). A complete session type for MCP v2 would need to encode `Task` state alongside the connection phase. The mapping above covers MCP v2's connection lifecycle; Task state management is a separate (nested) session type not developed here.

**Notifications are not strictly ordered:** MCP servers can send `notifications/tools/list_changed` at any point in the active session, interleaved with tool call responses. The session type models this as a `receiveNote` branch but real implementations need to demultiplex notification messages from response messages on the same transport. This is a transport-layer concern the session type does not fully resolve.

**SDK adoption gap:** Implementing phantom-typed channels in a shipping MCP SDK (the TypeScript SDK, the Python SDK, or the Rust SDK) would require breaking changes. The encoding is sound but the migration cost is non-trivial. The value is highest in a greenfield Rust MCP client.

---

## See Also

- [[session-types]] — Foundational theory; notation used in §2 is defined there
- [[session-types-in-rust]] — The phantom type encoding; `dialectic` crate
- [[capability-lattice-spec]] — The orthogonal capability existence check; §7 defers to this note for sequencing
- [[mcp-transport]] — MCP v2 lifecycle specification; the concrete source for the session type in §2
- [[rust-phantom-types]] — The `PhantomData<T>` mechanism in §4
- [[community-protocol-trust-substrate]] — The motivating architecture argument
