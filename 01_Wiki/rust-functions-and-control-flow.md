---
title: Rust Functions and Control Flow
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-functions, rust-loops, rust-control-flow]
---
# Rust Functions and Control Flow

Rust is an expression-based language, which profoundly influences how functions are defined and how logic branches and loops.

## Functions
Functions are declared using the `fn` keyword. Rust uses **snake case** for function and variable names.
* **Parameters**: Must have explicit type annotations in the function signature.
* **Return Values**: The return type is declared after an arrow `->`. Functions return the value of the final expression in their body implicitly. The `return` keyword can be used for early returns.

### Statements vs. Expressions
* **Statements**: Instructions that perform an action and do **not** return a value (e.g., `let x = 6;`).
* **Expressions**: Evaluate to a resultant value (e.g., `5 + 6`, calling a function). Expressions do not end with a semicolon; adding one turns them into statements.

## Control Flow
### `if` Expressions
`if` is an expression in Rust, meaning it returns a value.
* **Conditions**: Must be of type `bool`. No automatic conversion from integers.
* **As Expressions**: Both the `if` and `else` arms must return the same type.

### Loops
Rust has three types of loops:
1. **`loop`**: Executes a block forever or until `break`.
   * **Returning Values**: `break` can return a value from the loop (e.g., `break counter * 2;`).
   * **Loop Labels**: Used to disambiguate `break` or `continue` in nested loops (e.g., `'counting_up: loop`).
2. **`while`**: Conditional loop that runs as long as a condition is true.
3. **`for`**: Most common loop, used for iterating over collections (e.g., `for element in a`).
   * **Ranges**: Often used with ranges like `(1..4)`.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-variables-and-types]]
