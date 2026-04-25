---
title: Rust Common Collections
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-collections, vectors, hash-maps, rust-strings]
---
# Rust Common Collections

Rust's standard library provides several data structures that store multiple values on the **heap**.

## Vectors (`Vec<T>`)
A growable list of elements of the same type.
* **Creation**: `Vec::new()` or the `vec![1, 2, 3]` macro.
* **Updating**: Use `push(value)` to add elements.
* **Access**: 
  * `&v[index]`: Panics if index is out of bounds.
  * `v.get(index)`: Returns `Option<&T>` (safe).
* **Iteration**: `for i in &v { ... }` (immutable) or `for i in &mut v { ... }` (mutable).

## Strings (`String` vs `&str`)
A collection of bytes interpreted as UTF-8 text.
* **`String`**: Owned, growable, mutable. Wrapper around `Vec<u8>`.
* **`&str`**: A borrowed string slice (immutable reference).
* **Indexing**: Rust does **not** support indexing into strings (e.g., `s[0]`) because UTF-8 characters vary in byte length.
* **Slicing**: Use ranges (e.g., `&s[0..4]`), but be careful of character boundaries.
* **Concatenation**: `+` operator (takes ownership of the first string) or the `format!` macro (returns a new `String` without taking ownership).

## Hash Maps (`HashMap<K, V>`)
Stores key-value pairs using a hashing function.
* **Creation**: `use std::collections::HashMap;` then `HashMap::new()`.
* **Updating**:
  * `insert(key, value)`: Overwrites existing values.
  * `entry(key).or_insert(value)`: Only inserts if the key doesn't exist.
* **Ownership**: Types that implement `Copy` are copied; owned types (like `String`) are moved.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-variables-and-types]]
* [[rust-ownership]]
