---
title: [[rust]] Enums and Pattern Matching
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-enumerations, match-expression, option-enum, if-let]
---
# Rust Enums and Pattern Matching

**Enums** (enumerations) allow you to define a type by enumerating its possible variants. Unlike enums in many other languages, Rust enums can store data directly within their variants.

## Defining Enums
Variants can have different types and amounts of associated data, including strings, numeric types, structs, or even other enums.

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

## The `Option` Enum
Rust replaces the concept of `null` with the `Option<T>` enum, which is part of the prelude.
* `Some(T)`: Indicates the presence of a value of type `T`.
* `None`: Indicates the absence of a value.
The compiler requires you to handle the `None` case, preventing "null reference" errors at compile time.

## Pattern Matching
### The `match` Construct
`match` is an exhaustive control flow construct that compares a value against a series of patterns.
* **Exhaustiveness**: Every possible case must be handled.
* **Catch-all (`_`)**: A placeholder that matches any value without binding to it.
* **Binding**: Patterns can bind to the data inside enum variants (e.g., `Some(i) => ...`).

### Concise Control Flow
* **`if let`**: Syntax sugar for a `match` that only cares about one pattern, ignoring the rest.
* **`let...else`**: Stay on the "happy path" by binding a pattern or returning early if it doesn't match.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-structs]]
* [[rust-error-handling]]

