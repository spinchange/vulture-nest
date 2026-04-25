---
title: Rust Error Handling
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [panic, result-type, error-propagation, rust-errors]
---
# Rust Error Handling

Rust groups errors into two major categories: **recoverable** and **unrecoverable**.

## Unrecoverable Errors with `panic!`
When a program encounters an unrecoverable state (e.g., array out of bounds), it calls the `panic!` macro.
* **Behavior**: Prints an error message, unwinds/cleans up the stack, and quits.
* **`RUST_BACKTRACE=1`**: An environment variable that provides a full call stack on panic for easier debugging.

## Recoverable Errors with `Result<T, E>`
For errors that the program can potentially handle, Rust uses the `Result` enum:
```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```
* **Handling**: Use `match` or helper methods like `unwrap()` (panics on error) and `expect("msg")` (panics with a custom message).
* **Propagating Errors**: Use the `?` operator to return an error from a function to the caller immediately if it occurs.

## The `?` Operator
The `?` operator is a concise way to handle `Result` (and `Option`).
* If the value is `Ok(v)`, it returns `v` to the current scope.
* If the value is `Err(e)`, it returns `Err(e)` from the entire function.
* **Requirement**: The function's return type must be compatible with the error being propagated (e.g., `Result` or `Option`).

## Guidelines
* **Use `panic!`** for examples, prototypes, tests, or when an invariant is broken (bug in the code).
* **Use `Result`** when failure is an expected possibility (e.g., file not found, network error).

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-enums]]
