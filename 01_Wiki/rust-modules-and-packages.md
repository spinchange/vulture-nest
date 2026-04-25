---
title: Rust Modules and Packages
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-modules, crates, packages, paths, pub-use]
---
# Rust Modules and Packages

The Rust module system manages code organization, scope, and privacy. It consists of four primary parts:
* **Packages**: A Cargo feature for building, testing, and sharing crates.
* **Crates**: A tree of modules that produces a library or executable.
* **Modules**: Let you control organization, scope, and privacy.
* **Paths**: A way of naming items (structs, functions, modules).

## Crates and Packages
* **Crate Root**: The entry point for the compiler (usually `src/main.rs` for binary crates or `src/lib.rs` for library crates).
* **Package**: Defined by a `Cargo.toml` file; can contain multiple binary crates and at most one library crate.

## Modules (`mod`)
Modules group related code and control privacy (everything is private by default).
* **Declaration**: `mod garden;` tells Rust to look for the code in `src/garden.rs` or `src/garden/mod.rs`.
* **Visibility**: Use the `pub` keyword to make an item (module, function, struct field) accessible to parent modules.

## Paths
* **Absolute Path**: Starts from the crate root (`crate::module::item`).
* **Relative Path**: Starts from the current module (`self`, `super`, or an identifier).
* **`super`**: Like `..` in a filesystem, refers to the parent module.

## The `use` Keyword
Creates shortcuts to items in a scope to reduce repetition.
* **Idiom**: For functions, bring the parent module into scope. For structs/enums, bring the full path.
* **`as`**: Provides an alias for a brought-in name (e.g., `use std::io::Result as IoResult;`).
* **`pub use` (Re-exporting)**: Brings an item into scope and makes it available for others to import.
* **Nested Paths**: Combine imports (e.g., `use std::{cmp::Ordering, io};`).
* **Glob Operator**: `use std::collections::*;` brings all public items into scope.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-cargo]]
