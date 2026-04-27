---
title: [[rust]] Phantom Types
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: permanent
aliases: [phantom-data, rust-type-state, type-level-state-machine]
---
# Rust Phantom Types

A phantom type is a type parameter that appears in a struct's generic parameter list but not in any of its fields. The compiler erases it at runtime — it costs nothing — yet it carries type-system information that constrains what operations are legal.

The standard library mechanism is `std::marker::PhantomData<T>`.

---

## `PhantomData<T>`

```rust
use std::marker::PhantomData;

struct Tagged<T> {
    value: i64,
    _tag: PhantomData<T>,  // zero-sized; erased at runtime
}
```

`PhantomData<T>` is a zero-sized type (ZST). It has no runtime representation. Its sole purpose is to make the compiler treat `Tagged<T>` as if it "contains" a `T`, which has three concrete effects:

1. **Silences the dead-code warning.** Without `PhantomData`, Rust warns that `T` is unused. With it, `T` is considered used.
2. **Participates in drop checking.** If `T` has a destructor, the compiler may require that `T` outlives the struct. `PhantomData<T>` opts the struct into that analysis.
3. **Determines variance.** See §Variance below.

---

## Type-Level State Machines

The primary application. A struct carries a phantom type parameter that encodes its current state. Methods consume `self` (not `&self`) and return `Self` in the next state, making invalid transitions a compile-time error.

```rust
use std::marker::PhantomData;

// State tokens — never instantiated, only used as type parameters
struct Unconfirmed;
struct Confirmed;
struct Shipped;

struct Order<State> {
    id: u64,
    items: Vec<String>,
    _state: PhantomData<State>,
}

impl Order<Unconfirmed> {
    pub fn new(id: u64, items: Vec<String>) -> Self {
        Order { id, items, _state: PhantomData }
    }

    // Consuming self: the Unconfirmed order is gone after this call
    pub fn confirm(self) -> Order<Confirmed> {
        Order { id: self.id, items: self.items, _state: PhantomData }
    }
}

impl Order<Confirmed> {
    pub fn ship(self) -> Order<Shipped> {
        Order { id: self.id, items: self.items, _state: PhantomData }
    }
}

impl Order<Shipped> {
    pub fn tracking_number(&self) -> String {
        format!("TRK-{}", self.id)
    }
}
```

`order.confirm().ship()` compiles. `order.ship()` (skipping confirmation) does not — `Order<Unconfirmed>` has no `ship` method. The invalid transition is caught **before the program runs**.

The key insight: consuming `self` (not `&self`) ensures the old state is gone. The borrow checker enforces that you cannot use an `Order<Unconfirmed>` after calling `.confirm()` on it.

### Builder Pattern Application

The same technique enforces required fields before `.build()` compiles:

```rust
struct Missing;
struct Present;

struct QueryBuilder<HasTable, HasLimit> {
    table: Option<String>,
    limit: Option<usize>,
    _markers: PhantomData<(HasTable, HasLimit)>,
}

impl QueryBuilder<Missing, Missing> {
    pub fn new() -> Self {
        QueryBuilder { table: None, limit: None, _markers: PhantomData }
    }
}

impl<L> QueryBuilder<Missing, L> {
    pub fn table(self, name: &str) -> QueryBuilder<Present, L> {
        QueryBuilder { table: Some(name.to_string()), limit: self.limit, _markers: PhantomData }
    }
}

impl<T> QueryBuilder<T, Missing> {
    pub fn limit(self, n: usize) -> QueryBuilder<T, Present> {
        QueryBuilder { table: self.table, limit: Some(n), _markers: PhantomData }
    }
}

// build() only exists when both are Present
impl QueryBuilder<Present, Present> {
    pub fn build(self) -> String {
        format!("SELECT * FROM {} LIMIT {}", self.table.unwrap(), self.limit.unwrap())
    }
}
```

Calling `.build()` on a builder that is missing either field is a compile-time error.

---

## Capability Encoding

`PhantomData` is the mechanism behind the [[capability-lattice-spec]] §4 type-level delegation model. An agent struct carries a phantom capability set:

```rust
use std::marker::PhantomData;

// Capability tokens
struct CanRead;
struct CanWrite;
struct CanReadWrite;  // or use trait intersection — see capability-lattice-spec §4.2

struct Agent<Caps> {
    id: String,
    _caps: PhantomData<Caps>,
}

trait HasCaps<C> {}
impl HasCaps<CanRead> for Agent<CanRead> {}
impl HasCaps<CanRead> for Agent<CanReadWrite> {}
impl HasCaps<CanWrite> for Agent<CanWrite> {}
impl HasCaps<CanWrite> for Agent<CanReadWrite> {}

fn read_protected_resource<A: HasCaps<CanRead>>(agent: &A) {
    // Only callable if the agent's phantom type satisfies HasCaps<CanRead>
}
```

Attempting to call `read_protected_resource` with an `Agent<CanWrite>` is a compile error. The permission boundary is encoded in the type — no runtime check is needed. See [[capability-lattice-spec]] §4.3 for the full delegation formalism.

---

## Variance

Variance describes how generic type relationships propagate through container types. It matters when you have subtyping relationships (primarily lifetime subtyping in Rust).

| `PhantomData` form | Variance in `T` | Use when |
|---|---|---|
| `PhantomData<T>` | Covariant | Struct logically *owns* or *produces* `T` |
| `PhantomData<fn(T)>` | Contravariant | Struct logically *consumes* `T` |
| `PhantomData<fn(T) -> T>` | Invariant | Struct both produces and consumes `T` |
| `PhantomData<*mut T>` | Invariant | Raw pointer semantics |
| `PhantomData<*const T>` | Covariant | Same as owned |

**Covariance** (`PhantomData<T>`): If `'a: 'b` (lifetime `'a` outlives `'b`), then `Tagged<&'a T>` can be used where `Tagged<&'b T>` is expected. This is what you want when the struct acts as a container.

**Invariance** (`PhantomData<*mut T>`): No substitution is allowed. Required when the struct can both read and write through `T` — otherwise unsound code is possible. The Rustonomicon documents the exact soundness rules.

For state-machine phantoms (type tokens like `Unconfirmed`/`Confirmed` with no lifetime), variance is irrelevant — the tokens have no subtypes.

**Source:** The Rustonomicon, "PhantomData" chapter (`doc.rust-lang.org/nomicon/phantom-data.html`).

---

## Relationship to Other Notes

- **[[rust-generics-and-traits]]**: Prerequisites — generics and trait bounds.
- **[[rust-type-level-programming]]**: Builds on phantom types; GATs, const generics, type-level computation.
- **[[rust-affine-types]]**: Rust's ownership (move semantics) is the enforcement mechanism that makes the type-state pattern work — consuming `self` is an affine operation.
- **[[capability-lattice-spec]]**: Uses `PhantomData` and `HasCaps<SharedCaps>` as its implementation substrate (§4).
- **[[claude-session-types-handoff]]**: Session types in Rust are implemented via phantom types; see that handoff for the dependency.

---

## References
- The Rustonomicon — PhantomData: `doc.rust-lang.org/nomicon/phantom-data.html`
- The Rustonomicon — Variance: `doc.rust-lang.org/nomicon/subtyping.html`
- Jon Gjengset, *Rust for Rustaceans*, Chapter 3 (Designing Interfaces)
- Rust Reference — `std::marker::PhantomData`

