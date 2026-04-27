---
title: [[typescript.md|TypeScript]] Type Operators
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-operators, keyof, typeof-operator, indexed-access]
---
# TypeScript Type Operators

TypeScript provides powerful operators to query and manipulate types based on the structure of values and other types.

## The `keyof` Operator
Takes an object type and produces a string or numeric literal union of its keys.
```ts
type Point = { x: number; y: number };
type P = keyof Point; // "x" | "y"
```
* **Index Signatures**: If a type has a `string` index signature, `keyof` returns `string | number`.

## The `typeof` Operator
Used in a **type context** to refer to the type of a variable or property.
```ts
let s = "hello";
let n: typeof s; // string
```
* **Use Case**: Frequently used with `ReturnType<T>` to extract the return type of a function value.
* **Limitations**: Only legal on identifiers or their properties.

## Indexed Access Types
Use `Type[Key]` to look up a specific property on another type.
```ts
type Person = { age: number; name: string };
type Age = Person["age"]; // number
```
* **Arbitrary Types**: You can index with unions or other types like `number` to get array element types (e.g., `MyArray[number]`).
* **Constraints**: You can only use types when indexing, not variables (unless using `typeof`).

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-everyday-types]]
* [[typescript-generics]]
- [[typescript-objects]]
- [[typescript-template-literals]]
- [[typescript-narrowing]]

