---
title: [[typescript|TypeScript]] Functions
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-functions, function-types, generics-in-functions, overloads]
---
# TypeScript Functions

TypeScript provides several ways to describe how functions are called and how they relate input to output.

## Describing Functions
* **Function Type Expressions**: Syntactically similar to arrow functions (e.g., `(a: string) => void`). Parameter names are required.
* **Call Signatures**: Used when a function has properties (defined within an object type using `:` instead of `=>`).
* **Construct Signatures**: Used for functions callable with `new` (e.g., `new (s: string): SomeObject`).

## Generic Functions
Used to describe a correspondence between input and output types.
```ts
function firstElement<Type>(arr: Type[]): Type | undefined {
  return arr[0];
}
```
* **Inference**: TypeScript usually infers the type parameter automatically.
* **Constraints**: Use `extends` to limit the types a parameter can accept (e.g., `<Type extends { length: number }>`).

## Optional and Rest Parameters
* **Optional Parameters**: Mark with `?` (e.g., `x?: number`). They get the type `type | undefined`.
* **Default Parameters**: Provide a value (e.g., `x = 10`). The type is inferred from the default.
* **Rest Parameters**: Use `...` to accept an unbounded number of arguments (e.g., `...m: number[]`).
* **Rest Arguments**: Use spread syntax to provide arguments from an array (e.g., `f(...args)`). Use `as const` for literal tuple inference.

## Function Overloads
Define multiple **overload signatures** followed by a single **implementation signature**.
* The implementation signature is not visible from the outside and must be compatible with all overloads.
* **Guideline**: Prefer union types over overloads when possible for simplicity.

## Special Types for Functions
* **`void`**: For functions that don't return a value. Implementation can return a value (which will be ignored) if contextually typed as `void`.
* **`unknown`**: Safer alternative to `any` for arbitrary values.
* **`never`**: For functions that throw exceptions or never terminate.
* **`Function`**: Global type for all functions; calls return `any` (unsafe).

## Other Features
* **`this` in Functions**: Declare the type of `this` as the first parameter (e.g., `function(this: User) { ... }`).
* **Parameter Destructuring**: Type the object after the destructuring syntax (e.g., `function sum({ a, b, c }: ABC)`).

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-generics]]
- [[typescript-objects]]

