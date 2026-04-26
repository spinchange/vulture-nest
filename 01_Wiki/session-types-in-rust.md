---
title: Session Types in Rust
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: permanent
aliases: [session-types-rust, phantom-session, dialectic-crate, session-types-crate]
---
# Session Types in Rust

**Prerequisite:** [[session-types]] for theory, [[rust-generics-and-traits]] for the Rust type machinery.

Rust has no native linear type system. It has an **affine** type system: ownership enforces "use at most once" but permits silent drop. Session types require a stricter discipline. This note covers how Rust encodes session types despite this limitation, what the encoding can and cannot enforce, and where the remaining gap lies.

---

## 1. The Phantom Type Simulation

The canonical Rust approach encodes the current protocol state as a phantom type parameter on a channel wrapper struct. Crucially, every operation that advances the session **consumes `self`** (takes ownership) and returns a *new channel value* whose phantom type has been updated to reflect the next protocol state.

### The mechanism

```rust
use std::marker::PhantomData;

// The channel wrapper. `S` is the current session type — it is never stored,
// only used as a compile-time proof that the channel is in state S.
struct Chan<S> {
    inner: /* underlying transport */,
    _state: PhantomData<S>,
}

// Session type tokens — zero-sized types used as state markers
struct Send<T, S>(PhantomData<(T, S)>);  // !T.S
struct Recv<T, S>(PhantomData<(T, S)>);  // ?T.S
struct End;
```

Operations consume the current channel and produce the next one:

```rust
impl<T: Serialize, S> Chan<Send<T, S>> {
    fn send(self, value: T) -> Chan<S> {
        // serialize value and write to transport
        Chan { inner: self.inner, _state: PhantomData }
    }
}

impl<T: DeserializeOwned, S> Chan<Recv<T, S>> {
    fn recv(self) -> (T, Chan<S>) {
        // read from transport and deserialize
        let value: T = /* ... */;
        (value, Chan { inner: self.inner, _state: PhantomData })
    }
}

impl Chan<End> {
    fn close(self) { /* send close frame, drop transport */ }
}
```

The key property: `Chan<Send<T, S>>` only has a `send` method. Calling `recv` or `close` on it is a compile-time type error. After `send`, the channel becomes `Chan<S>` — the next state. The type checker enforces the sequence.

### Why `self` (not `&self`)

Taking `self` by value is what makes the session linear-ish. Once you call `.send(v)`, the `Chan<Send<T,S>>` is moved out of your hands. You cannot call `.send` again on the original — Rust's ownership prevents it. This is the affine type system enforcing the "at most once" constraint automatically.

---

## 2. The `session-types` Crate

The canonical Rust implementation of Honda's binary session types. Published as `session-types` on crates.io; the academic reference is "Session Types for Rust" (Jespersen, Munksgaard, Larsen, 2015).

### Basic API

```rust
use session_types::*;

// Define the session type aliases
type Client = Send<String, Recv<i64, Eps>>;  // !String.?i64.End
type Server = <Client as HasDual>::Dual;      // ?String.!i64.End

fn client(c: Chan<(), Client>) {
    let c = c.send("hello".to_string());   // Chan<(), Recv<i64, Eps>>
    let (n, c) = c.recv();                 // Chan<(), Eps>
    c.close();
    println!("Got: {}", n);
}

fn server(c: Chan<(), Server>) {
    let (s, c) = c.recv();                 // Chan<(), Send<i64, Eps>>
    let c = c.send(s.len() as i64);        // Chan<(), Eps>
    c.close();
}

fn main() {
    let (client_chan, server_chan) = session_channel();
    std::thread::spawn(move || server(server_chan));
    client(client_chan);
}
```

`session_channel()` produces a pair `(Chan<(), S>, Chan<(), S::Dual>)` — the duality constraint is enforced at construction. You cannot create a mismatched channel pair.

### Branching

```rust
type WithChoice = Choose<Send<String, Eps>, Send<i64, Eps>>;  // select string path or int path
type WithOffer  = Offer<Recv<String, Eps>, Recv<i64, Eps>>;   // offer: other party picks

fn chooser(c: Chan<(), WithChoice>) {
    // pick the left branch
    let c = c.sel1();   // Chan<(), Send<String, Eps>>
    c.send("left".to_string()).close();
}

fn offerer(c: Chan<(), WithOffer>) {
    offer!(c, {
        String => { let (s, c) = c.recv(); c.close(); println!("String: {s}"); }
        i64    => { let (n, c) = c.recv(); c.close(); println!("i64: {n}"); }
    });
}
```

---

## 3. The `dialectic` Crate

A more ergonomic, modern alternative with async support via Tokio. Written by David Thrane Christiansen. The type-level protocol description is expressed as Rust types rather than explicit state machines.

### Differences from `session-types`

| Feature | `session-types` | `dialectic` |
|---|---|---|
| Async | No (blocking channels) | Yes (Tokio) |
| Ergonomics | Explicit type aliases, verbose | Procedural macros, terser |
| Recursive types | Supported | Supported |
| Branching syntax | `choose!` / `offer!` macros | `choose!` / `offer!` macros, improved |
| Production readiness | Academic/experimental | More actively maintained |

### Example

```rust
use dialectic::prelude::*;

// Protocol definition via type alias
type EchoOnce = Session! {
    send String;
    recv String;
};

async fn echo_client(chan: Chan<EchoOnce, impl Transmit<String> + Receive<String>>) {
    let chan = chan.send("hello".to_string()).await.unwrap();
    let (msg, chan) = chan.recv().await.unwrap();
    chan.close();
    println!("Echo: {msg}");
}
```

The `Session! { ... }` macro translates a readable protocol description into the phantom-type encoding.

---

## 4. The "Must Complete" Limitation

Rust's affine type system enforces "at most once" — but session types need "exactly once." The gap: **a `Chan<S>` can be dropped mid-session without a compile error.**

```rust
fn incomplete_client(c: Chan<Send<String, Recv<i64, Eps>>>) {
    let _c = c.send("hello".to_string());
    // _c goes out of scope here — Recv<i64, Eps> never consumed
    // Rust: fine. Real session type: type error.
}
```

The underlying transport connection may now be in an undefined state on the server side.

### The standard workaround: panicking `Drop`

Both `session-types` and `dialectic` implement `Drop` on the channel type in a way that panics if the session is dropped in any state other than `Eps`/`End`:

```rust
impl<S> Drop for Chan<S> {
    fn drop(&mut self) {
        // Check if S == Eps (the only valid terminal state).
        // If not, panic — someone dropped the channel mid-session.
        if std::any::TypeId::of::<S>() != std::any::TypeId::of::<Eps>() {
            panic!("Session channel dropped in non-terminal state");
        }
    }
}
```

This converts the type-level failure into a runtime panic — better than a silent bug, worse than a compile error. The theoretical gap between affine and linear types cannot be fully closed without language-level linear type support.

---

## 5. Putting It Together: A Typed MCP Initialization Handshake

The following sketches what an MCP client SDK would look like if it used session types. This is illustrative — a complete implementation is specified in [[session-types-mcp-mapping]].

```rust
// Session type aliases for MCP initialization
type McpInit = Send<Initialize, Recv<InitializeResult, Send<Initialized, McpActive>>>;

// McpActive is recursive: loop over tool calls and notifications until End
type McpActive = rec!(
    Offer<
        Recv<ToolCall, Send<ToolResult, Var<Z>>>,  // server sends tool call, client responds
        End                                         // close the session
    >
);

// A function that can only be called AFTER initialization is complete
// — because it takes `Chan<McpActive>`, not `Chan<McpInit>`
async fn call_tool(
    chan: Chan<McpActive>,
    call: ToolCall,
) -> (ToolResult, Chan<McpActive>) {
    // ...
}

// Calling call_tool with a Chan<McpInit> is a type error — enforced at compile time.
```

---

## 6. Summary

| Property | What Rust enforces | What remains a gap |
|---|---|---|
| Correct message type at each step | Yes — phantom type on channel | — |
| Correct sequence of send/recv | Yes — consuming `self` prevents reuse | — |
| Duality between two ends | Yes — `session_channel()` enforces it | — |
| Protocol must be completed | No — `Drop` panic is runtime, not compile | Requires linear types |
| Async protocol execution | Yes (via `dialectic`) | — |

Session types in Rust provide strong, compile-time protocol conformance with one known gap: incomplete sessions fail at runtime via panic rather than at compile time. For most agent infrastructure purposes, the compile-time guarantees are the valuable part — the runtime panic is still a significant improvement over silent protocol violations.

---

## References

- Jespersen, T.B.L., Munksgaard, P., Larsen, K.F. (2015). "Session Types for Rust." 11th ACM SIGPLAN Workshop on Generic Programming.
- Christiansen, D.T. `dialectic` crate documentation: docs.rs/dialectic.
- `session-types` crate: crates.io/crates/session-types.
- [[session-types]]
- [[session-types-mcp-mapping]]
- [[rust-generics-and-traits]]
- [[rust-ownership]]
