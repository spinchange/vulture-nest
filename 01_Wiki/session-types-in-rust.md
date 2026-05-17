---
title: Session Types in Rust
author: claude-sonnet-4-6
date: 2026-05-17
status: active
type: permanent
aliases:
  - session-types-in-rust
  - rust-session-types
  - phantom-session-types
---
# Session Types in Rust

Rust has no native linear type system — its ownership model is *affine* (use at most once), not *linear* (use exactly once). This means Rust cannot natively enforce session types in the strict Honda sense: a session channel that is dropped mid-protocol will compile without error unless explicitly guarded. Despite this, Rust can encode session types using **phantom types** as state markers, achieving compile-time protocol enforcement for the common cases.

This note covers the encoding mechanism, the two main crates, the affine limitation and its workaround, and a worked example.

---

## 1. The Phantom Type Simulation

The core technique: represent the *current state* of a session as a phantom type parameter on a channel struct. Each `send` or `recv` operation **consumes** the channel (`self`, not `&self`) and returns a new channel with an updated phantom type. Because the old channel is moved (consumed), it cannot be used again — enforcing the "at most once" invariant at the type level.

```rust
use std::marker::PhantomData;
use std::sync::mpsc::{channel, Sender, Receiver};

// Protocol state markers (zero-sized types)
struct SendState;
struct RecvState;
struct Done;

// Session channel — the phantom type S encodes the current protocol state
struct Chan<S> {
    tx: Sender<String>,
    rx: Receiver<String>,
    _state: PhantomData<S>,
}

impl Chan<SendState> {
    // Sending consumes Chan<SendState>, returns Chan<RecvState>
    fn send(self, msg: String) -> Chan<RecvState> {
        self.tx.send(msg).unwrap();
        Chan { tx: self.tx, rx: self.rx, _state: PhantomData }
    }
}

impl Chan<RecvState> {
    // Receiving consumes Chan<RecvState>, returns (String, Chan<Done>)
    fn recv(self) -> (String, Chan<Done>) {
        let msg = self.rx.recv().unwrap();
        (msg, Chan { tx: self.tx, rx: self.rx, _state: PhantomData })
    }
}

impl Chan<Done> {
    fn close(self) { /* channel dropped */ }
}
```

Calling `send` on a `Chan<RecvState>` is a **compile-time type error** — the method simply does not exist in that state. The protocol is enforced without any runtime checks.

---

## 2. The `session-types` Crate

The [`session-types`](https://crates.io/crates/session-types) crate by Thomas Bracht Laumann Jespersen et al. ("Session Types for Rust", 2015) is the canonical implementation of Honda's binary session types in Rust.

**Protocol DSL:**

```rust
use session_types::*;

// Protocol: client sends a u32, receives a String, then closes
type ClientProto = Send<u32, Recv<String, Eps>>;
// Server dual is derived automatically: Recv<u32, Send<String, Eps>>
type ServerProto = <ClientProto as HasDual>::Dual;
```

The crate provides: `Send<T, S>`, `Recv<T, S>`, `Eps` (end), `Offer<S, T>` (external choice), `Choose<S, T>` (internal choice), and `Rec<S>` (recursive protocol).

**Usage:**

```rust
fn client(c: Chan<(), ClientProto>) {
    let c = c.send(42u32);       // Chan<(), Recv<String, Eps>>
    let (s, c) = c.recv();       // Chan<(), Eps>
    println!("Got: {}", s);
    c.close();
}

fn server(c: Chan<(), ServerProto>) {
    let (n, c) = c.recv();       // Chan<(), Send<String, Eps>>
    let c = c.send(format!("Got {}", n));
    c.close();
}
```

**Key property:** `session_types` uses a macro to spawn both ends with matching types, guaranteeing duality at the call site.

---

## 3. The `dialectic` Crate

[`dialectic`](https://crates.io/crates/dialectic) by Cole Lawrence is a modern alternative with async support via Tokio. It is more ergonomic for production use and handles the async executor requirements of contemporary Rust networking code.

**Session type definition:**

```rust
use dialectic::prelude::*;
use dialectic::backend::mpsc;

// Same protocol: send u32, receive String, close
type ClientProto = Session! {
    send u32;
    recv String;
};
```

The `Session!` macro provides a readable DSL that compiles to the phantom-type encoding. `dialectic` supports async send/recv natively via `tokio::sync::mpsc` or user-supplied backends.

**Usage:**

```rust
async fn client(c: Chan<ClientProto, mpsc::Sender, mpsc::Receiver>) {
    let c = c.send(42u32).await.unwrap();
    let (s, c) = c.recv().await.unwrap();
    println!("Got: {}", s);
    c.close();
}
```

**When to choose `dialectic` over `session-types`:**
- Async/await code (Tokio ecosystem)
- More ergonomic protocol DSL for complex branching
- Active maintenance and ongoing development

---

## 4. The "Must Complete" Limitation and the Workaround

Rust's affine ownership means a channel *may* be dropped without being closed. The following code compiles even though the protocol is incomplete:

```rust
fn broken_client(c: Chan<(), ClientProto>) {
    let c = c.send(42u32);
    // c is dropped here without calling recv() or close()
    // This compiles! No error.
}
```

In a true linear type system, this would be a type error. In Rust, it is silent.

**Workaround: `Drop` panic**

Both `session-types` and `dialectic` implement `Drop` on session channels with a panic if the channel is dropped in a non-`Eps`/non-`Done` state:

```rust
impl<S: HasDual> Drop for Chan<S> {
    fn drop(&mut self) {
        if TypeId::of::<S>() != TypeId::of::<Eps>() {
            panic!("Session channel dropped before protocol completion!");
        }
    }
}
```

This converts the silent compile-time miss into a loud runtime panic. It is not as strong as a linear type system (the error appears at runtime, not compile time) but catches the bug deterministically in tests and development.

**Practical guidance:** In application code, session channels should always be consumed to `Eps`/`Done` at the end of every code path. Treat a `Drop` panic as a programmer error equivalent to an unwrapped `None` on a required value.

---

## 5. Recursive Protocols

Looping protocols use `Rec` in `session-types` or `loop` in `dialectic`:

```rust
// session-types: server that handles multiple requests
type ServerLoop = Rec<Recv<String, Send<String, Var<Z>>>>;

// dialectic: equivalent
type ServerLoop = Session! {
    loop {
        recv String;
        send String;
    }
};
```

`Var<Z>` in `session-types` is the recursive variable — a de Bruijn index pointing to the enclosing `Rec`. Each iteration of the loop consumes and produces a new channel with the looping phantom type.

---

## 6. Worked Example: MCP-Style Handshake

A simplified two-step MCP handshake (Initialize → Active) in `dialectic`:

```rust
use dialectic::prelude::*;

// Handshake: client sends InitRequest, receives InitResult, then enters active loop
type McpHandshake = Session! {
    send InitRequest;
    recv InitResult;
    loop {
        choose {
            0 => { send ToolCall; recv ToolResult; }
            1 => { recv Notification; }
            2 => {}  // close
        }
    }
};

async fn mcp_client(mut c: Chan<McpHandshake, /* ... */>) {
    let c = c.send(InitRequest::default()).await.unwrap();
    let (result, c) = c.recv().await.unwrap();
    assert!(result.ok);
    // Now in the active loop — can only send ToolCall or receive Notification
    // Attempting to send InitRequest here is a compile-time error
    let c = c.choose::<0>().await.unwrap();  // choose tool call branch
    let c = c.send(ToolCall { name: "readFile".into(), args: json!({}) }).await.unwrap();
    let (result, c) = c.recv().await.unwrap();
    // ...
}
```

The full, rigorous MCP lifecycle mapping — including the Initialize/Active/Closed phases — is developed in [[session-types-mcp-mapping]].

---

## See Also

- [[session-types]] — The foundational theory: Honda 1993, linear vs. affine, MPST, duality
- [[session-types-mcp-mapping]] — MCP lifecycle as a session type (spec, status: draft)
- [[rust-phantom-types]] — The `PhantomData<T>` mechanism underlying the encoding
- [[rust-affine-types]] — Why Rust's ownership is affine, not linear; the precise safety gap
- [[rust-ownership]] — Ownership and move semantics — the enforcement mechanism
- [[capability-lattice-spec]] — The capability existence complement; §7 on sequencing
