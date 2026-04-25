---
title: Rust Variables and Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-types, rust-mutability, shadowing]
---
# Rust Variables and Types

In Rust, variables and types are the foundation of how data is stored and manipulated. The language emphasizes safety and clarity through its handling of mutability and static typing.

## Variables and Mutability
By default, variables in Rust are **immutable**. This encourages safety and concurrency.
* **`let`**: Declares an immutable variable.
* **`let mut`**: Declares a mutable variable, allowing its value to be changed.

### Constants
Declared with the `const` keyword.
* Always immutable (cannot use `mut`).
* Must have an explicit type annotation.
* Can be declared in any scope, including global.
* Must be set to a constant expression (evaluated at compile time).

### Shadowing
You can declare a new variable with the same name as a previous one.
* The new variable "shadows" the previous one.
* Allows changing the **type** of a variable name while keeping it immutable.
* Different from `mut`, as it creates a entirely new variable.

## Data Types
Rust is a **statically typed** language. The compiler must know all types at compile time.

### Scalar Types
Represent a single value:
* **Integers**: Signed (`i8`, `i16`, `i32`, `i64`, `i128`, `isize`) and Unsigned (`u8`, `u16`, `u32`, `u64`, `u128`, `usize`). Default is `i32`.
* **Floating-Point**: `f32` and `f64`. Default is `f64`.
* **Booleans**: `bool` (`true` or `false`).
* **Characters**: `char` (4-byte Unicode scalar value).

### Compound Types
Group multiple values into one:
* **Tuples**: Fixed-length collection of multiple types. Accessed via destructuring or dot notation (e.g., `tup.0`).
* **Arrays**: Fixed-length collection of the **same** type. Stored on the stack. Accessed via indexing (e.g., `a[0]`).

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-ownership]]
