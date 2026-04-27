---
title: [[rust]] Affine Types
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: permanent
aliases: [rust-linear-types, substructural-types, rust-ownership-theory]
---
# Rust Affine Types

Rust's ownership model is an implementation of an **affine type system** — a specific point in the formal taxonomy of substructural type systems. Understanding this characterization completes the theoretical argument in [[community-protocol-trust-substrate]] and names the mechanism behind Rust's safety guarantees.

---

## The Substructural Type Taxonomy

Classical type theory assumes three structural rules that allow arbitrary manipulation of typed variables:

- **Weakening**: You may discard a value without using it.
- **Contraction**: You may duplicate a value and use it multiple times.
- **Exchange**: You may reorder how values appear.

Substructural type systems restrict one or more of these rules. The resulting taxonomy (Walker, *ATTAPL*, Chapter 1):

| Name | Weakening | Contraction | Meaning |
|---|---|---|---|
| **Unrestricted** (structural) | ✓ allowed | ✓ allowed | Values may be used any number of times. Most languages. |
| **Affine** | ✓ allowed | ✗ forbidden | Values may be used **at most once** — they can be dropped but not duplicated. |
| **Linear** | ✗ forbidden | ✗ forbidden | Values must be used **exactly once** — cannot be dropped or duplicated. |
| **Relevant** | ✗ forbidden | ✓ allowed | Values must be used **at least once** — cannot be dropped, but may be duplicated. |

Exchange is restricted only in non-commutative / ordered type systems (e.g., Lambek calculus for natural language parsing) — not relevant here.

**Source:** Walker, David. "Substructural Type Systems." In *Advanced Topics in Types and Programming Languages* (ATTAPL), ed. Pierce, MIT Press, 2005. Chapter 1. Freely available via the ATTAPL website.

---

## Rust as an Affine Type System

Rust's `move` semantics enforce the affine rule: a value may be moved (used once) or dropped, but it cannot be used after a move. This is affine, not linear, because Rust permits weakening — you can drop a value without using it at all (`drop(x)` or simply letting it go out of scope).

```rust
let s = String::from("hello");
let t = s;          // s is moved into t
println!("{}", s);  // compile error: s has been moved
```

The borrow checker is the enforcement mechanism. After the move, `s` is in a "moved-from" state that the type system rejects at every use site. This is not a runtime check — the compiler eliminates the moved-from value from the type environment.

### Why Not Linear?

A linear type system would forbid weakening: every value must be consumed by a meaningful operation, not silently dropped. Rust allows both:

```rust
{
    let s = String::from("hello");
    // s is dropped here without being used — weakening allowed
}
```

```rust
drop(s);  // explicit discard — still weakening
```

Rust's partial gesture toward linearity is the `#[must_use]` attribute, which emits a warning (not an error) when a value is silently discarded:

```rust
#[must_use]
fn compute() -> Result<i32, Error> { ... }

compute();  // warning: unused Result that must be used
```

`#[must_use]` approximates the "at least once" relevant rule at the value level, but it is advisory and can be suppressed with `let _ = compute();`.

True linear types — where dropping a value is a compile error — would require explicit consumption of every `Result`, every `File`, every mutex guard. Some Rust libraries approximate this for specific types (e.g., the `must-use` crate, or session type libraries that require channels to be fully consumed), but the language does not enforce it universally.

---

## Connection to the Trust Substrate

[[community-protocol-trust-substrate]] claims that Rust's ownership model encodes "explicit, statically-verifiable permission boundaries" with the property that "you cannot grant permissions you don't possess." The formal name for this property is **the affine rule applied to capability values**.

When a capability is expressed as a Rust value (a struct, an owned handle, a token), moving it is an affine operation:

```rust
let capability = WritePermission::new();
grant_to_subagent(capability);  // capability is moved — original holder can no longer use it
// use(capability);  // compile error: value moved
```

The original holder cannot use the capability after granting it. This is not enforced by runtime authorization logic — it is enforced by the type checker. The affine rule makes "you cannot use what you have given away" a structural property of the language, not a convention.

This is why [[capability-lattice-spec]] §4.3 uses consuming `self` (not `&self`) for the delegation operation: the delegation is a move. The orchestrator's capability token is consumed; a new `DelegatedAgent<SharedCaps>` is returned with a strictly smaller or equal capability set. You cannot grant what you no longer hold.

---

## Connection to Session Types

Session types (see [[claude-session-types-handoff]]) require **linear** channels: a channel must be fully consumed according to its protocol — it cannot be dropped mid-protocol. Rust's affine system can simulate but not enforce this:

- A session-typed channel library can prevent *use-after-move* (affine) — you cannot use a channel in state `S` after transitioning it to state `S'`.
- But Rust cannot prevent *drop-without-consuming* (the linear requirement) unless the channel's `Drop` implementation panics, which is a runtime check, not a type-level one.

Libraries like `session-types` or `dialectic` achieve the use-after-move guarantee through phantom types (see [[rust-phantom-types]]) but rely on runtime panic for the linearity requirement. This is the practical limit of Rust's affine system for session type encoding.

---

## The `Copy` Trait: Explicit Opt-Out of Affinity

Types that implement `Copy` opt out of the affine rule for that type. `Copy` requires that the type is trivially duplicable (no heap allocation, no unique ownership semantics):

```rust
let x: i32 = 5;
let y = x;       // x is copied, not moved
println!("{}", x);  // fine — i32 is Copy
```

`Copy` is only derivable if all fields are `Copy`. `String`, `Vec<T>`, `Box<T>`, and any type with unique ownership cannot implement `Copy`. The affine rule is the default; `Copy` is the explicit, opt-in exception.

`Clone` (explicit duplication via `.clone()`) is a weakening operation — you are creating a new value, not using the original. The original survives the clone. This is different from the linear/affine distinction, which is about what happens to the *original*.

---

## Summary: What the Formal Framing Buys

Naming Rust's ownership model as an affine type system does three things:

1. **Connects it to a body of formal theory.** The properties of affine systems (no aliasing without explicit borrow, safe deallocation, no use-after-free) are proven in the literature, not just asserted by the Rust documentation.
2. **Clarifies the limits.** Rust is affine, not linear — certain invariants (every handle must be consumed) require additional conventions or runtime checks.
3. **Grounds the capability model.** The trust substrate's claim that "you cannot grant what you don't possess" is not a design principle — it is a consequence of the affine rule applied to capability tokens.

---

## Relationship to Other Notes

- **[[rust-ownership]]**: The practical rules that implement the affine system.
- **[[rust-phantom-types]]**: The mechanism for encoding capability state in types; the affine rule (consuming `self`) is what makes the state transitions irrevocable.
- **[[rust-type-level-programming]]**: Orthogonal; type-level computation in Rust is about what types can express, not about the substructural properties of values.
- **[[community-protocol-trust-substrate]]**: The "permission boundaries" claim that this note formally grounds.
- **[[capability-lattice-spec]]**: §4.3 uses the affine move as the delegation mechanism.
- **[[claude-session-types-handoff]]**: Session types require linearity; Rust provides affinity — see that handoff for the gap and workarounds.

---

## References

- Walker, David. "Substructural Type Systems." In *ATTAPL* (Pierce, ed.), MIT Press, 2005. Chapter 1.
- Wadler, Philip. "Linear Types Can Change the World." *Programming Concepts and Methods* (IFIP), 1990.
- The Rustonomicon — Ownership and Moves: `doc.rust-lang.org/nomicon/ownership.html`
- The Rust Reference — `Copy` types
- Rust RFC #0019 — Ownership system (historical)

