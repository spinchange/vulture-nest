---
title: [[rust]] Smart Pointers
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [smart-pointers, deref-trait, drop-trait, box-pointer, reference-counting]
---
# Rust Smart Pointers

Smart pointers are data structures that act like pointers but have additional metadata and capabilities. They generally implement the `Deref` and `Drop` traits.

## `Box<T>`
For allocating values on the **heap**.
* Use when you have a type whose size can't be known at compile time (recursive types).
* Use to transfer ownership of a large amount of data without copying.
* Implements `Deref` to allow being treated as the inner type.

## `Rc<T>` (Reference Counted)
Enables **multiple ownership** of data on the heap.
* Only for **single-threaded** scenarios.
* Keeps track of the number of references; data is cleaned up when the count reaches zero.
* Only provides **immutable** access to the data.

## `RefCell<T>` and Interior Mutability
Allows mutating data even when there are immutable references to that data.
* Enforces borrowing rules at **runtime** rather than compile time.
* `borrow()` returns an immutable smart pointer.
* `borrow_mut()` returns a mutable smart pointer.
* Panics at runtime if borrowing rules are violated.

## `Arc<T>` (Atomic Reference Counted)
A version of `Rc<T>` that is safe to use in **multi-threaded** contexts.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-ownership]]
* [[rust-concurrency]]

