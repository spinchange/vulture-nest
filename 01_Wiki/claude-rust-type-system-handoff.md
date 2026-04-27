---
title: Claude Handoff — [[rust]] Advanced Type System
author: claude-sonnet-4-6
date: '2026-04-26'
status: archived
type: handoff
targets:
  - claude
aliases:
  - claude-rust-types-handoff
  - rust-advanced-types-seam
---

# Claude Handoff: Rust Advanced Type System

## Goal

Extend the vault's Rust coverage from practical fundamentals into the advanced type system features that the [[capability-lattice-spec]] already relies on but the vault cannot currently explain. The spec uses phantom types and type-level trait intersection as its implementation mechanism — without these notes, the spec is aspirational documentation with no executable path. This handoff closes that gap.

## Seam

The vault currently contains:

- **[[rust-generics-and-traits]]**: Covers basic generics, trait bounds, `impl Trait`, `where` clauses. Stops here.
- **[[rust-moc]]**: "Advanced Abstractions" section lists generics, lifetimes, iterators, smart pointers — no phantom types, no type-level programming, no GATs, no const generics.
- **[[capability-lattice-spec]] §4**: Uses `PhantomData`, `HasCaps<SharedCaps>` trait bounds, and type-level intersection as its primary implementation idiom. No vault note explains any of these.
- **[[community-protocol-trust-substrate]]**: Claims Rust's ownership model encodes "explicit, statically-verifiable permission boundaries" — but does not name this as an affine type system, which is the formal characterization.

The grep confirms zero vault notes mention phantom types, GATs, generic associated types, const generics, or affine/linear types by name.

## Context From This Session

Identified on 2026-04-26 as a priority gap. The [[capability-lattice-spec]] was written this session and already depends on concepts this cluster would cover. The session types handoff (`[[claude-session-types-handoff]]`) was written in parallel — session types in Rust are implemented via phantom types, so that handoff depends on this one. Do this cluster first.

## Deliverables

### 1. Create `01_Wiki/rust-phantom-types.md` (`status: active`, `type: permanent`)

The most immediately useful note — referenced directly by both [[capability-lattice-spec]] and the session types handoff. Must cover:

- **`PhantomData<T>`**: A zero-sized marker type that tells the compiler "this struct logically contains a `T` even though it doesn't at runtime." Eliminates the dead code warning, participates in variance and drop checking.
- **Type-level state machines**: The primary application pattern. A struct carries a phantom type parameter that encodes its current state. Methods consume `self` (not `&self`) and return `Self<NextState>`, making invalid state transitions unrepresentable. Example: a builder that enforces required fields before `.build()` compiles.
- **Capability encoding**: How `PhantomData` is used to encode capability sets — a struct `Agent<Caps>` where `Caps` is a phantom type parameter representing the agent's permission set. Connect explicitly to [[capability-lattice-spec]] §4.
- **Variance**: `PhantomData<T>` is covariant in `T`; `PhantomData<fn(T)>` is contravariant; `PhantomData<*mut T>` is invariant. Briefly explain why variance matters for soundness.

Source: The Rustonomicon, chapter on `PhantomData` (`doc.rust-lang.org/nomicon/phantom-data.html`). Rust Reference. "Rust for Rustaceans" (Gjengset), chapter on type system.

### 2. Create `01_Wiki/rust-type-level-programming.md` (`status: active`, `type: permanent`)

Covers the broader practice of encoding computation in Rust's type system. Must cover:

- **Type-level booleans and naturals**: Implementing `True`/`False` and Peano numbers as types. The `typenum` crate as the production-grade alternative.
- **GATs (Generic Associated Types)**: Associated types that can themselves have generic parameters. Stabilized in Rust 1.65. The canonical motivating example: `trait Container { type Item<'a>; }` — impossible without GATs. Why this matters for higher-kinded type patterns.
- **Const generics**: Generics over constant values (`[T; N]` where `N: const usize`). Stabilized progressively from Rust 1.51. Allows array-length-polymorphic functions without macros.
- **Type-level functions via traits**: How a trait with an associated type acts as a type-level function (`type Output = ...`). Compose them to compute types at compile time.
- **The limits**: Rust's type system is not dependently typed. You cannot generally compute an arbitrary type from a runtime value at compile time. Document where the wall is.

Source: Rustonomicon; `typenum` crate docs; GAT stabilization RFC (#1598); "Rust for Rustaceans" (Gjengset).

### 3. Create `01_Wiki/rust-affine-types.md` (`status: active`, `type: permanent`)

Connects Rust's ownership model to formal type theory — completing the theoretical argument in [[community-protocol-trust-substrate]]. Must cover:

- **The type theory taxonomy**:
  - **Unrestricted (structural)**: values may be used any number of times (most languages)
  - **Affine**: values may be used *at most once* — they can be dropped but not duplicated (**Rust**)
  - **Linear**: values must be used *exactly once* — cannot be dropped or duplicated (theoretical; no mainstream language enforces this natively)
  - **Relevant**: values must be used *at least once* — cannot be dropped but may be duplicated (rare)
- **Rust as an affine type system**: Rust's `move` semantics are affine — a value can be used once or dropped, but not used after move. The borrow checker is the enforcement mechanism.
- **Why not linear**: Rust allows `drop(x)` — deliberately discarding a value. A linear system would require every value to be consumed by a meaningful operation. Note the `#[must_use]` attribute as Rust's partial gesture toward linear enforcement.
- **Connection to the trust substrate**: The claim in [[community-protocol-trust-substrate]] that "you cannot grant permissions you don't possess" is the affine property: moving a capability transfers it — the original holder can no longer use it. Name this explicitly.
- **Connection to session types**: Session types require linear channels (must be fully consumed). Rust's affine system can simulate but not enforce this — see [[claude-session-types-handoff]] for the implication.

Source: "Substructural Type Systems" (Walker, ATTAPL chapter — freely available). "Linear Types Can Change the World" (Wadler 1990). Rustonomicon ownership section.

### 4. Update `01_Wiki/rust-moc.md`

Add a new section **Type System Theory** between "Advanced Abstractions" and "Concurrency & Async":

```
## Type System Theory
* [[rust-phantom-types]]: Zero-cost type-level state encoding.
* [[rust-type-level-programming]]: GATs, const generics, and type-level computation.
* [[rust-affine-types]]: Rust's ownership as a formal type-theoretic system.
```

### 5. Update `01_Wiki/capability-lattice-spec.md`

In §4 (Capability Set as a Type), add backlinks from the phantom type and trait-bound code examples to `[[rust-phantom-types]]` and `[[rust-type-level-programming]]` so a reader can follow the chain from spec to implementation knowledge.

## Ordering Constraint

Write `rust-phantom-types.md` first — it is the prerequisite for both `rust-type-level-programming.md` (which builds on the phantom type pattern) and for the session types cluster (which uses phantom types as its implementation substrate). The other two notes in this cluster can be written in any order after that.

## Constraints

- Source from the Rustonomicon and Rust Reference for anything touching `unsafe` or compiler internals. Do not speculate about type system guarantees — the Rustonomicon is authoritative.
- `rust-affine-types.md` is making a theoretical connection that is correct but not widely spelled out in Rust documentation. Ground every claim in a citable source (Walker ATTAPL, Wadler, or the Rustonomicon). Do not let it drift into unsourced editorializing.
- Do not expand scope to dependent types or proof assistants — document the wall at the end of §2, don't climb over it.

---
## References
- [[rust-moc]]
- [[rust-generics-and-traits]]
- [[rust-ownership]]
- [[rust-lifetimes]]
- [[capability-lattice-spec]]
- [[community-protocol-trust-substrate]]
- [[claude-session-types-handoff]]
- [[session-types-in-rust]]

