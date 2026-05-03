---
title: Rust
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases: [rust-lang, rust-programming-language]
---

# Rust

**Rust** is a systems programming language built around a compile-time ownership model that eliminates memory errors and data races without a garbage collector. It is the Nest's language for trust-boundary enforcement, high-performance MCP servers, and type-level safety guarantees that Python cannot express.

## Why Rust in the Nest

Rust appears in two distinct roles here:

**Tier-0 Safe Core.** The [[rust-tier-0-patterns|Tier-0 architecture]] places Rust at the trust boundary of the multi-agent stack. Rust validates and gates capability claims — using `serde` for schema enforcement at the protocol boundary — before handing verified state to Python orchestrators. The choice of Rust here is deliberate: the ownership system makes the boundary *provably* safe at compile time rather than relying on runtime checks.

**MCP Server Implementation.** [[rust-mcp-patterns]] describes the pattern for building MCP servers in Rust — trading Python's development speed for predictable latency, memory efficiency, and the ability to use the type system to encode protocol invariants. Rust MCP servers are appropriate when a tool must be fast, long-running, or exposed to untrusted callers.

The type system also provides formal tools — affine types, phantom types, const generics — that are studied in the vault for their theoretical properties and their influence on how to think about capability lattices.

## Reading the Cluster

The Rust cluster is large. Navigate it in three tracks depending on your goal.

### Track 1 — Language Fundamentals

Start here if you are building Rust fluency or returning after a gap.

- **[[rust-ownership]]** is the essential prerequisite. Read this before anything else — it governs the rest of the language.
- **[[rust-variables-and-types]]**, **[[rust-structs]]**, **[[rust-enums]]** — the data vocabulary.
- **[[rust-functions-and-control-flow]]**, **[[rust-modules-and-packages]]** — program structure.
- **[[rust-generics-and-traits]]** — how behavior is defined and shared. The second most important concept after ownership.
- **[[rust-error-handling]]** — `Result`-first style; essential for writing idiomatic Rust.
- **[[rust-lifetimes]]** — tackle after ownership and traits are solid; the compiler will tell you when you need this.

Supporting: [[rust-collections]], [[rust-iterators-and-closures]], [[rust-macros]], [[rust-cargo]], [[rust-testing]].

### Track 2 — Vault Applications

Start here if you are working on the Tier-0 binary, an MCP server, or the ingestion pipeline.

- **[[rust-tier-0-patterns]]** — capability gating, serde boundary, Tier-0 → Tier-1 handoff.
- **[[rust-mcp-patterns]]** — MCP server design in Rust: routing, resource handlers, tool registration.
- **[[rust-concurrency]]** + **[[rust-async]]** — needed for any server or long-running agent worker.
- **[[rust-smart-pointers]]** — `Arc<Mutex<T>>` is common in shared-state async code.
- **[[rust-sqlx-migrations]]** — database tooling for the Rust service layer.

### Track 3 — Type System Theory

Start here if you are studying formal safety properties or the capability lattice design.

- **[[rust-phantom-types]]** — zero-cost type-level state encoding (marker structs, state machines).
- **[[rust-type-level-programming]]** — GATs, const generics, type-level computation.
- **[[rust-affine-types]]** — the formal type-theoretic reading of Rust's ownership model.

The community report [[rust-type-systems]] synthesizes this track across multiple sources.

## See Also

- [[rust-moc]] — full structured traversal of the cluster
- [[programming-languages-moc]]
- [[rust-tier-0-patterns]] — the vault-specific application layer
- [[lit-rust-programming-language]] — literature note for the Rust Book
