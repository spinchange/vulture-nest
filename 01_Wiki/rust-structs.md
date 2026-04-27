---
title: [[rust]] Structs
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-structures, methods, impl-blocks]
---
# Rust Structs

A **struct**, or structure, is a custom data type that packages together multiple related values into a meaningful group.

## Defining and Instantiating
Structs are defined using the `struct` keyword followed by a name and fields.
* **Fields**: Each field has a name and a type.
* **Instantiation**: Created by specifying values for each field. The order doesn't need to match the definition.
* **Mutability**: If an instance is mutable (`let mut`), all its fields are mutable.

```rust
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}
```

### Field Init Shorthand
If the variable names and struct field names match, you can use a shorthand:
```rust
fn build_user(email: String, username: String) -> User {
    User { active: true, username, email, sign_in_count: 1 }
}
```

### Struct Update Syntax
Create a new instance using values from an existing instance with the `..` syntax:
```rust
let user2 = User { email: String::from("new@example.com"), ..user1 };
```
*Note: This may move data (e.g., Strings) out of the original instance.*

## Specialized Structs
* **Tuple Structs**: Named structs with anonymous fields (e.g., `struct Color(i32, i32, i32);`).
* **Unit-Like Structs**: Structs without fields (e.g., `struct AlwaysEqual;`), useful for trait implementations.

## Methods and `impl` Blocks
Methods are functions defined within the context of a struct using an `impl` block.
* **`self`**: The first parameter of a method. 
  * `&self`: Immutable borrow (most common).
  * `&mut self`: Mutable borrow.
  * `self`: Takes ownership (rare).
* **Associated Functions**: Functions in an `impl` block that *don't* take `self` as a parameter (often used as constructors like `String::from`).

## Ownership and Traits
* **Ownership**: Structs typically own their data. Storing references requires **lifetimes**.
* **Derived Traits**: Use `#[derive(Debug)]` to enable formatting for debugging with `{:?}` or `{:#?}`.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-ownership]]
* [[rust-enums]]

