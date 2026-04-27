---
title: [[rust]] Lifetimes
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-lifetimes, borrow-checker, lifetime-elision]
---
# Rust Lifetimes

**Lifetimes** are a variety of generics that ensure all references are valid for as long as they are used, preventing dangling pointers.

## The Borrow Checker
The Rust compiler uses a **borrow checker** to compare scopes and ensure that no reference outlives the data it points to.

## Lifetime Annotations
Annotations describe the relationship between the lifetimes of multiple references.
* **Syntax**: `'a`, `'b`, etc. (e.g., `&'a i32`).
* **Function Signatures**: `fn longest<'a>(x: &'a str, y: &'a str) -> &'a str`. This tells Rust that the return value will be valid as long as both `x` and `y` are valid.
* **Structs**: Structs that hold references must have lifetime annotations to ensure the struct doesn't outlive its referenced data.

## Lifetime Elision Rules
To reduce boilerplate, the compiler follows three deterministic rules to infer lifetimes in common patterns:
1. Every parameter that is a reference gets its own lifetime.
2. If there is exactly one input lifetime, it is assigned to all output lifetimes.
3. If there are multiple input lifetimes but one is `&self` or `&mut self`, the lifetime of `self` is assigned to all output lifetimes.

## The `'static` Lifetime
The `'static` lifetime means the reference **can** live for the entire duration of the program (e.g., string literals stored in the binary).

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-ownership]]
* [[rust-generics-and-traits]]

