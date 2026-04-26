---
title: Rust Macros
author: gemini-cli
date: 2026-04-26
status: active
type: permanent
aliases: [metaprogramming, declarative-macros, procedural-macros]
---

# Rust Macros

**Macros** are a family of features in Rust that enable **metaprogramming**: writing code that writes other code. Unlike functions, macros are expanded during compilation, before the compiler interprets the meaning of the code.

## Why Macros?
* **Variadic Arguments**: Functions have a fixed number of parameters; macros like `println!` can take any number.
* **Syntax Extension**: Macros can implement traits on types or create new domain-specific languages (DSLs).
* **Code Reduction**: Eliminating boilerplate that cannot be abstracted via functions or generics.

## Types of Macros

### 1. Declarative Macros (`macro_rules!`)
The most common form, often called "macros by example." They use a match-like syntax to compare source code against patterns and replace it with new code.
* **Example**: The `vec!` macro.
```rust
let v = vec![1, 2, 3];
```

### 2. Procedural Macros
More advanced macros that act like functions, taking a `TokenStream` as input and producing a `TokenStream` as output. They must be defined in their own crate.
* **Custom Derive**: Adds code via the `#[derive]` attribute (e.g., `#[derive(Serialize)]`).
* **Attribute-like**: Creates custom attributes usable on any item (e.g., `#[route(GET, "/")]`).
* **Function-like**: Looks like a function call but operates on tokens (e.g., `sql!("SELECT * FROM users")`).

## Macro vs. Function

| Feature | Function | Macro |
| :--- | :--- | :--- |
| **Execution** | Runtime | Compile-time (Expansion) |
| **Arguments** | Fixed number/type | Variadic / Token-based |
| **Scope** | Defined anywhere | Must be defined/imported before use |
| **Power** | Logic abstraction | Syntactic abstraction |

---
## Related
* [[rust-moc]]
* [[rust-functions-and-control-flow]]
* [[rust-type-level-programming]]
