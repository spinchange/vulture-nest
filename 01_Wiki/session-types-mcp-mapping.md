---
title: Session Types — MCP Lifecycle Mapping
author: claude-sonnet-4-6
date: 2026-04-26T00:00:00.000Z
status: draft
type: permanent
aliases:
  - session-types-mcp
  - mcp-session-type
  - typed-mcp-client
---
# Session Types: MCP Lifecycle Mapping

> **Status: draft.** This note applies session types formalism to MCP's lifecycle. The theory is established (see [[session-types]]); the specific mapping to MCP and the phantom-type client sketch are speculative-but-grounded — they are not yet an implemented library or a published proposal. Treat as a design argument, not a reference.

**Context:** [[mcp-architecture]] documents MCP's three-phase stateful lifecycle. [[session-types-in-rust]] covers the phantom-type encoding. This note bridges the two: expressing MCP's lifecycle as a session type, identifying what violations the current protocol cannot prevent, and sketching what a typed MCP SDK would look like.

---

## 1. MCP's Lifecycle as a Session Type

MCP defines three connection phases:

1. **Initialize**: client sends `initialize` (with protocol version, client capabilities), server replies `InitializeResult` (with server capabilities), client sends `notifications/initialized`.
2. **Active session**: arbitrary interleaving of tool calls, resource reads, and lifecycle notifications.
3. **Shutdown**: client sends `shutdown` (or simply closes the transport).

This is a textbook session type. Expressed formally (client's perspective):

```
McpClient =
    !Initialize .
    ?InitializeResult .
    !Initialized .
    ActiveClient

ActiveClient = rec α .
    ( !ToolsCall  . ?ToolsResult  . α           -- client-initiated tool invocation
    ⊕ !ResourcesRead . ?ResourcesResult . α     -- client-initiated resource read
    ⊕ ?ToolsListChanged . α                     -- server-pushed notification
    ⊕ ?ResourcesListChanged . α                 -- server-pushed notification
    ⊕ End )                                      -- client initiates shutdown
```

The server's session type is the dual:

```
McpServer =
    ?Initialize .
    !InitializeResult .
    ?Initialized .
    ActiveServer

ActiveServer = rec α .
    ( ?ToolsCall  . !ToolsResult  . α
    & ?ResourcesRead . !ResourcesResult . α
    & !ToolsListChanged . α
    & !ResourcesListChanged . α
    & End )
```

**Notation:** `!T` = send, `?T` = receive, `⊕` = internal choice (sender selects), `&` = external choice (receiver waits for sender's selection), `rec α . S` = recursive session with loop variable `α`, `End` = session terminated. See [[session-types]] §2 for the full grammar.

### Reading the client type

The client type says, in sequence: send `Initialize`, receive `InitializeResult`, send `Initialized`, then enter a loop. In the loop the client either:
- Initiates a tool call (`⊕`-branches 1–2, internal choice: client decides)
- Receives a server-pushed notification (`?ToolsListChanged`, `?ResourcesListChanged` — but note: these arrive asynchronously, which complicates strict binary session sequencing; see §3)
- Closes the session

The server type is the dual: every `!` becomes `?` and every `⊕` becomes `&`.

---

## 2. Protocol Violations the Current Implementation Cannot Prevent

MCP is implemented as a JSON-RPC 2.0 layer over stdio or HTTP/SSE. Neither transport nor the protocol library enforces state ordering. The following violations are currently possible at runtime:

### Violation A: Tool call before `initialized`

A client implementation that calls `tools/call` before sending `notifications/initialized` is a protocol error (MCP spec §4.2: "Clients MUST NOT send requests other than `initialize` before receiving the result and sending `notifications/initialized`"). The spec says this, but no type in any current MCP SDK makes it a compile error. The SDK's `tools/call` method is available on the client object from the moment it is constructed.

**Session type diagnosis:** `tools/call` belongs to `ActiveClient`, which is only reachable after the `!Initialized` step. A channel typed at `McpClient` has no `call_tool` method — only `send_initialize`. The method doesn't exist until the session has advanced.

### Violation B: Double initialization

A client that sends `initialize` twice on the same connection sends a message that the server has no valid response for after the first handshake completes. Current SDKs do not prevent this.

**Session type diagnosis:** `!Initialize` appears exactly once in `McpClient` (not under `rec`). After `send_initialize` is called, the channel type advances to `Recv<InitializeResult, ...>`, which has no `send_initialize` method. Attempting to call it a second time is a type error — the channel doesn't exist in a state where it's valid.

### Violation C: Continuing after `End`

A client that sends further requests after issuing `shutdown` is violating the protocol. Current SDK: no enforcement.

**Session type diagnosis:** `close()` (the `End` operation) consumes the channel by value. After `c.close()`, `c` is gone — the compiler prevents any further use.

### Violation D: Notifications sent during initialization

The MCP spec prohibits certain server notifications until after the initialization handshake is complete. A server that pushes `notifications/tools/list_changed` before the client has sent `notifications/initialized` is out of sequence.

**Session type diagnosis:** `!ToolsListChanged` only appears in `ActiveServer`, not in the initialization prefix. A server channel typed at `McpServer` has no `send_tools_list_changed` method until it reaches `ActiveServer`.

---

## 3. Complication: Asynchronous Notifications

MCP allows server-pushed notifications (`tools/list_changed`, `resources/list_changed`) to arrive at any point during `ActiveClient`. Binary session types as formulated by Honda 1993 are **synchronous** — each step in the session is a sequential send or receive. Asynchronous, server-initiated notifications do not fit naturally into the binary sequential model.

Two approaches exist:

**Option A: Model notifications as interleaved external choices.** The `ActiveClient` loop treats each iteration as an external choice: either the client initiates a request, or the server sends a notification. This requires the client to begin each iteration by waiting for a server message, which does not match MCP's request/response structure.

**Option B: Separate channels for requests vs. notifications.** Model the MCP session as two concurrent channels — one for the request/response protocol (strictly typed), one for the server-pushed notification stream (a separate session type). This matches MCP's actual implementation (HTTP+SSE uses separate streams for requests and notifications).

```
McpSession = (RequestChannel, NotificationChannel)

RequestChannel =
    !Initialize . ?InitializeResult . !Initialized .
    rec α . ( !AnyRequest . ?AnyResponse . α ) ⊕ End

NotificationChannel = rec α . ?AnyNotification . α
```

The two channels are created simultaneously at connection time but typed independently. This is multiparty session types with two participants plus a server-push channel, expressible in MPST (see [[session-types]] §6).

For the phantom-type encoding in §4 below, Option B is used: separate channel structs for the request protocol and the notification stream.

---

## 4. Sketch: A Phantom-Type MCP Client SDK

This is what an MCP client library would look like if it used the session-type encoding from [[session-types-in-rust]]. The method set available on the client changes at compile time as the session progresses.

```rust
use std::marker::PhantomData;

// Protocol state markers (zero-sized, never instantiated)
struct Uninit;         // Before send_initialize
struct AwaitingResult; // After send_initialize, before recv_initialize_result
struct AwaitingNotif;  // After recv_initialize_result, before send_initialized
struct Active;         // After send_initialized — tool calls valid here
struct Closed;         // After close() — no methods available

// The MCP client handle, parameterized by protocol state
struct McpClient<S> {
    transport: Transport,
    _state: PhantomData<S>,
}

// Phase 1: Only send_initialize is available
impl McpClient<Uninit> {
    pub fn new(transport: Transport) -> Self {
        McpClient { transport, _state: PhantomData }
    }

    pub async fn send_initialize(self, params: Initialize)
        -> Result<McpClient<AwaitingResult>, McpError>
    {
        self.transport.send_request("initialize", params).await?;
        Ok(McpClient { transport: self.transport, _state: PhantomData })
    }
    // No call_tool(), no send_initialized() — they don't exist yet
}

// Phase 2: Wait for InitializeResult
impl McpClient<AwaitingResult> {
    pub async fn recv_initialize_result(self)
        -> Result<(InitializeResult, McpClient<AwaitingNotif>), McpError>
    {
        let result = self.transport.recv_response::<InitializeResult>().await?;
        Ok((result, McpClient { transport: self.transport, _state: PhantomData }))
    }
}

// Phase 3: Send initialized notification
impl McpClient<AwaitingNotif> {
    pub async fn send_initialized(self)
        -> Result<McpClient<Active>, McpError>
    {
        self.transport.send_notification("notifications/initialized", ()).await?;
        Ok(McpClient { transport: self.transport, _state: PhantomData })
    }
}

// Phase 4: Active session — tool calls and resource reads are now valid
impl McpClient<Active> {
    pub async fn call_tool(
        &self,                          // Note: &self, not self — Active loops
        params: CallToolParams,
    ) -> Result<CallToolResult, McpError> {
        self.transport.send_request("tools/call", params).await
    }

    pub async fn read_resource(
        &self,
        params: ReadResourceParams,
    ) -> Result<ReadResourceResult, McpError> {
        self.transport.send_request("resources/read", params).await
    }

    pub fn close(self) -> McpClient<Closed> {
        drop(self.transport); // sends close frame
        McpClient { transport: /* closed */, _state: PhantomData }
    }
}

// Closed state: no methods — compiler prevents any further use
impl McpClient<Closed> {}
```

### What this enforces at compile time

```rust
// This compiles:
async fn correct_usage(transport: Transport) -> Result<(), McpError> {
    let client = McpClient::new(transport);
    let client = client.send_initialize(init_params).await?;
    let (result, client) = client.recv_initialize_result().await?;
    let client = client.send_initialized().await?;
    let tool_result = client.call_tool(tool_params).await?;
    client.close();
    Ok(())
}

// This does NOT compile — call_tool on McpClient<Uninit> has no such method:
async fn premature_call(transport: Transport) -> Result<(), McpError> {
    let client = McpClient::new(transport);
    let result = client.call_tool(tool_params).await?;  // error[E0599]
    Ok(())
}
```

The error message would be: `no method named 'call_tool' found for struct 'McpClient<Uninit>'`. The type checker rejects it before any network connection is made.

---

## 5. Relationship to the Capability Lattice

The [[capability-lattice-spec]] and session types answer orthogonal questions that together constitute the full trust guarantee:

| Question | Mechanism | Spec |
|---|---|---|
| Is `tools/call` a registered capability? | Capability lattice: `tools/call ∈ Caps(server)` | [[capability-lattice-spec]] §4 |
| Is `tools/call` valid *right now*? | Session type: current state ∈ `ActiveClient` | This note |

An agent that has `tools/call` in its capability set but calls it in the `Uninit` state violates the protocol despite having the capability. The lattice alone cannot catch this. Only the session type can.

The composition of the two:

```
Safe(agent, operation, state) iff
    operation ∈ Caps(agent)          ← capability lattice
    AND state → operation is valid    ← session type
```

Both conditions must hold. The lattice is the static capability map; the session type is the dynamic permission slice that is valid in the current state.

---

## 6. Next Steps for This Spec

This note is `status: draft` because the phantom-type SDK (§4) does not yet exist as a library. To move to `active`:

1. Implement the `McpClient<S>` state machine as a published Rust crate.
2. Handle the async notification channel (Option B from §3) explicitly.
3. Handle the branching in `ActiveClient` — currently `call_tool` and `read_resource` both use `&self` (stateless, can be called in any order), which elides the loop structure. A strict session encoding would use `self` and return the next state after each call.
4. Validate against an actual MCP server (e.g., the reference implementation) that the compiled client cannot send out-of-order messages.

---

## References

- [[session-types]]
- [[session-types-in-rust]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[community-protocol-trust-substrate]]
