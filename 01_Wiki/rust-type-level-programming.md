---
title: [[rust]] Type-Level Programming
author: claude-sonnet-4-6
date: 2026-04-26
status: active
type: permanent
aliases: [rust-gats, rust-const-generics, rust-typenum, type-level-computation]
---
# Rust Type-Level Programming

Type-level programming uses the type system itself as a computation substrate: values become types, functions become trait impls with associated types, and assertions become trait bounds checked at compile time. This note covers the four main mechanisms Rust provides and documents where the capability wall is.

**Prerequisite:** [[rust-phantom-types]] — the foundational pattern on which this builds.

---

## Type-Level Booleans and Naturals

The simplest form: represent compile-time values as distinct types.

```rust
struct True;
struct False;

trait Not { type Output; }
impl Not for True  { type Output = False; }
impl Not for False { type Output = True; }

trait And<Rhs> { type Output; }
impl And<True>  for True  { type Output = True; }
impl And<False> for True  { type Output = False; }
impl And<True>  for False { type Output = False; }
impl And<False> for False { type Output = False; }
```

This is correct but tedious to scale. The `typenum` crate provides production-grade type-level integers using binary encoding:

```rust
use typenum::{U5, U10, Sum, op};

type Fifteen = Sum<U5, U10>;   // computed at compile time
let _: Fifteen = op!(U5 + U10);
```

`typenum` is used in the `generic-array` crate (which powers `nalgebra`, `ndarray`, and cryptographic crates that need arrays of statically-known length).

**Peano naturals** (Zero, Succ(Zero), Succ(Succ(Zero)) ...) are the theoretical formulation, but binary encoding (`typenum`'s approach) is required for anything beyond toy examples due to the exponential blowup of nested `Succ` types.

---

## GATs — Generic Associated Types

**Stabilized:** Rust 1.65 (October 2022). RFC #1598.

Associated types in traits can themselves have generic parameters. This unlocks higher-kinded type patterns that were previously impossible.

### The Motivating Problem

Without GATs, you cannot write a `Container` trait where the item type can borrow from the container:

```rust
// Pre-GAT attempt — does not compile
trait Container {
    type Item;  // cannot be lifetime-parameterized here
    fn get(&self) -> Self::Item;  // Item borrows from self, but lifetime is unnameable
}
```

With GATs:

```rust
trait Container {
    type Item<'a> where Self: 'a;  // Item can now borrow from the container
    fn get<'a>(&'a self) -> Self::Item<'a>;
}

struct VecContainer(Vec<String>);

impl Container for VecContainer {
    type Item<'a> = &'a String where Self: 'a;
    fn get<'a>(&'a self) -> &'a String {
        &self.0[0]
    }
}
```

### Streaming Iterators

The canonical use case. Standard `Iterator` requires `Item` to not borrow from the iterator — each `.next()` must return an owned value or a reference with a lifetime unrelated to `self`. GATs allow a `StreamingIterator` where each item can borrow from the iterator's own buffer:

```rust
trait StreamingIterator {
    type Item<'a> where Self: 'a;
    fn next<'a>(&'a mut self) -> Option<Self::Item<'a>>;
}
```

This pattern is useful for CSV parsers, line-by-line file readers, and any iterator over borrowed slices of an internal buffer.

### Type-Level Functions via GATs

A trait with a GAT acts as a type-level function:

```rust
trait TypeFn {
    type Apply<T>;
}

struct OptionFn;
impl TypeFn for OptionFn {
    type Apply<T> = Option<T>;
}

struct VecFn;
impl TypeFn for VecFn {
    type Apply<T> = Vec<T>;
}

// Compose: apply two type-level functions in sequence
fn apply_twice<F: TypeFn, T>(x: T) -> F::Apply<F::Apply<T>>
where
    F::Apply<T>: Sized,
{
    todo!()
}
```

**Source:** GAT stabilization RFC #1598; `blog.rust-lang.org/2022/10/28/gats-stabilization.html`.

---

## Const Generics

**Stabilized progressively:** basic const generics in Rust 1.51 (March 2021); more features in subsequent releases.

Generics parameterized over constant values, not just types. The canonical example is array length:

```rust
fn sum<const N: usize>(arr: [i32; N]) -> i32 {
    arr.iter().sum()
}

let a: [i32; 3] = [1, 2, 3];
let b: [i32; 5] = [1, 2, 3, 4, 5];
sum(a);  // N = 3, inferred
sum(b);  // N = 5, inferred
```

Before const generics, array-length-polymorphic functions required either macros or trait impls for each size (the standard library historically implemented traits for `[T; 0]` through `[T; 32]` by hand).

### Const Generic Structs

```rust
struct Matrix<const ROWS: usize, const COLS: usize> {
    data: [[f64; COLS]; ROWS],
}

impl<const R: usize, const C: usize> Matrix<R, C> {
    fn transpose(&self) -> Matrix<C, R> {
        let mut result = Matrix { data: [[0.0; R]; C] };
        for i in 0..R {
            for j in 0..C {
                result.data[j][i] = self.data[i][j];
            }
        }
        result
    }
}
```

The return type of `transpose()` is `Matrix<C, R>` — the dimensions are swapped in the type. A caller that passes the result to something expecting `Matrix<R, C>` (when `R ≠ C`) gets a compile error.

### Const Expressions (Partially Stable)

Const generics can be used in expressions, but the feature is still evolving. As of Rust 1.79, `N + 1` in a const generic context requires `#![feature(generic_const_exprs)]` (nightly only). The stable subset covers most array and buffer patterns.

---

## Type-Level Functions via Associated Types

The pattern that ties everything together: a trait with an associated type is a type-level function. Compose them by nesting:

```rust
trait Twice {
    type Output;
}

// Twice<T> = (T, T)
impl<T> Twice for T {
    type Output = (T, T);
}

fn make_twice<T: Twice>(x: T) -> (T, T) where T: Copy {
    (x, x)
}
```

More complex compositions use marker traits as the input "argument" and `Output` as the result:

```rust
trait Stringify {
    type Output: std::fmt::Display;
}

trait Compose<F: Stringify> {
    type Output;
}
```

The trait solver evaluates these chains at compile time. This is how `typenum` implements addition, multiplication, and comparison over type-level numbers — each operation is a trait impl with `Output`.

---

## The Wall: What Rust Cannot Do

Rust's type system is **not dependently typed**. Dependent types (as in Idris, Agda, or Coq) allow a type to depend on a *runtime value*. Rust cannot express "a list of length `n`" where `n` is determined at runtime.

**The wall in practice:**

1. **Runtime-length arrays**: `[T; n]` where `n` comes from user input is not a type-level constant. You must use `Vec<T>`.
2. **Proof terms**: Rust cannot express "a function that returns a number only if it's prime" where primality is a type-level constraint checked at runtime.
3. **Refinement types**: You cannot write `type PositiveInt = { x: i32 | x > 0 }` and have the compiler verify the constraint without a macro workaround.

**What you can do at the wall:**

- Use `const` functions and `const fn` evaluation to compute values at compile time from *compile-time* inputs.
- Use `typenum` or const generics for dimension/size constraints that are statically known.
- Use the newtype pattern + `TryFrom` to enforce invariants at construction time (runtime, not type-level).
- Use proc macros to generate type-level proofs for cases you can enumerate.

The formal characterization: Rust's type system is equivalent to System F_ω (higher-order polymorphism) with additional affine and lifetime constraints, but without Pi types (which are the core of dependent type theory). Do not attempt to push past this wall without moving to a dependently-typed language.

---

## Relationship to Other Notes

- **[[rust-phantom-types]]**: Prerequisite; phantom types are the most common entry point into type-level programming.
- **[[rust-generics-and-traits]]**: Foundation — all of the above requires solid understanding of trait bounds and associated types.
- **[[rust-affine-types]]**: Orthogonal dimension of Rust's type system — ownership and linearity rather than type-level computation.
- **[[capability-lattice-spec]]**: The `HasCaps<SharedCaps>` pattern in §4 is a type-level function applied to capability sets.

---

## References

- Rust RFC #1598 — Generic Associated Types: `github.com/rust-lang/rfcs/blob/master/text/1598-generic_associated_types.md`
- Rust Blog — GATs stabilization (2022): `blog.rust-lang.org/2022/10/28/gats-stabilization.html`
- Rust Reference — Const generics
- `typenum` crate documentation: `docs.rs/typenum`
- Jon Gjengset, *Rust for Rustaceans*, Chapter 3 and 12
- The Rustonomicon — Higher-Ranked Trait Bounds

