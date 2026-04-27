---
title: [[rust]] Ownership
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ownership, borrowing, lifetimes]
---
# Rust Ownership

**Ownership** is Rust's most unique feature and is the foundation for its memory safety guarantees. It allows Rust to manage memory without a garbage collector.

## The Three Rules of Ownership
1. Each value in Rust has an **owner**.
2. There can only be **one owner at a time**.
3. When the owner goes **out of scope**, the value will be dropped (deallocated).

## Memory Management
Unlike languages with a Garbage Collector (GC) or those requiring manual allocation/deallocation (C/C++), Rust uses **Resource Acquisition Is Initialization (RAII)**. Memory is automatically returned once the variable that owns it goes out of scope.

### Move vs. Copy
* **Copy**: Simple types with a known size at compile time (integers, booleans) are stored on the **stack** and are copied when assigned to a new variable.
* **Move**: Types that store data on the **heap** (like `String`) move their ownership to the new variable during assignment. The original variable becomes invalid to prevent "double free" errors.

## Borrowing
Borrowing allows you to access data without taking ownership.
* **References**: Created using the `&` symbol.
* **Immutable Borrowing**: Multiple parts of code can read data simultaneously.
* **Mutable Borrowing**: Only one part of code can modify data at a time, and no other references (even immutable ones) can exist simultaneously. This prevents **data races**.

## Lifetimes
Lifetimes are a way for the compiler to ensure that all borrows are valid and that no reference outlives the data it points to. While often inferred, explicit lifetime annotations (e.g., `'a`) are used in complex scenarios.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust]]
* [[agentic-frameworks-moc]]

