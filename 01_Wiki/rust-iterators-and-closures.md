---
title: [[rust]] Iterators and Closures
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [closures, iterators, functional-rust, zero-cost-abstractions]
---
# Rust Iterators and Closures

Rust includes functional programming features that allow for expressive and high-performance code through closures and iterators.

## Closures
Closures are anonymous functions that can capture values from the scope in which they are defined.
* **Syntax**: `|param1, param2| { ... body ... }`
* **Capture Modes**:
  * **Immutable Borrow**: Captures a reference (`&T`).
  * **Mutable Borrow**: Captures a mutable reference (`&mut T`).
  * **Ownership**: Uses the `move` keyword to take ownership of captured values.
* **Traits**:
  * `FnOnce`: Can be called at least once (all closures).
  * `FnMut`: Can be called multiple times; can mutate captured values.
  * `Fn`: Can be called multiple times; doesn't mutate environment.

## Iterators
The iterator pattern allows performing tasks on a sequence of items. Iterators in Rust are **lazy**—they have no effect until consumed.
* **The `Iterator` Trait**: Requires implementing the `next` method, which returns `Option<Self::Item>`.
* **Consuming Adapters**: Methods that call `next` and use up the iterator (e.g., `sum()`, `collect()`).
* **Iterator Adapters**: Methods that transform an iterator into another iterator (e.g., `map()`, `filter()`).
* **Performance**: Iterators are a **zero-cost abstraction**. They compile down to the same efficient machine code as manual loops.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-variables-and-types]]

