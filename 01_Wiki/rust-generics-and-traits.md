---
title: [[rust]] Generics and Traits
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-generics, rust-traits, trait-bounds, monomorphization]
---
# Rust Generics and Traits

Generics and traits are Rust's primary tools for code reuse and defining shared behavior across different types.

## Generics
Generics are abstract placeholders for concrete types.
* **Usage**: Functions (`fn foo<T>(...)`), Structs (`struct Point<T> { x: T, y: T }`), and Enums (`Result<T, E>`).
* **Performance**: Rust uses **monomorphization** (generating specific code for each concrete type used) so there is **no runtime cost** for using generics.

## Traits
A **trait** defines a set of method signatures that a type must implement.
* **Definition**: `pub trait Summary { fn summarize(&self) -> String; }`
* **Default Implementations**: You can provide default code in a trait that types can inherit or override.
* **Blanket Implementations**: Implementing a trait for any type that satisfies another trait (e.g., `impl<T: Display> ToString for T`).

## Trait Bounds
Trait bounds constrain generic types to only those that implement specific behavior.
* **Syntax**: `fn notify<T: Summary>(item: &T)`
* **`+` Syntax**: Require multiple traits (e.g., `T: Summary + Display`).
* **`where` Clause**: For complex bounds, move them after the function signature for readability.
* **`impl Trait`**: A shorthand for simple trait bounds in parameters or return types.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-lifetimes]]

