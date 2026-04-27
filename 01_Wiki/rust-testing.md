---
title: [[rust]] Testing
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-tests, unit-testing, integration-testing]
---
# Rust Testing

Rust has first-class support for automated testing within the language and its tooling.

## Types of Tests
1.  **Unit Tests**: Focused on individual modules. They typically reside in the same file as the code they test, within a `cfg(test)` module.
2.  **Integration Tests**: External to the library, stored in a `tests/` directory. They test the public API of the crate.

## The `#[test]` Attribute
Annotating a function with `#[test]` tells the test runner to execute it.
*   **Assertions**: Use `assert!`, `assert_eq!`, and `assert_ne!`.
*   **Custom Messages**: Pass a format string as an additional argument to assertions.
*   **Panic Testing**: Use `#[should_panic]` to verify that code fails as expected.

## Execution
Run all tests using `cargo test`.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-cargo]]

