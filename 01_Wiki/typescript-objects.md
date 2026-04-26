---
title: TypeScript Object Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-objects, property-modifiers, index-signatures, extending-types]
---
# TypeScript Object Types

Objects are the fundamental way data is grouped in JavaScript. TypeScript provides several modifiers and patterns to describe them accurately.

## Property Modifiers
* **Optional Properties (`?`)**: Properties that may or may not be present (e.g., `{ x?: number }`). Always check for `undefined` when reading.
* **`readonly` Properties**: Properties that cannot be re-assigned after initialization (e.g., `{ readonly id: string }`). Note: This doesn't make the value itself immutable if it's an object.

## Index Signatures
Used when the names of properties aren't known ahead of time but their values' types are.
```ts
interface StringArray {
  [index: number]: string;
}
```
* **Constraint**: All named properties must match the index signature's return type (or a union that includes it).

## Excess Property Checks
TypeScript triggers errors when an object literal is assigned to a type and contains properties not defined in that type.
* **Workarounds**: Use a type assertion (`as`), add an index signature, or assign the literal to an intermediate variable first.

## Combining Types
* **Extending Interfaces (`extends`)**: Copy members from other interfaces to build complex types. Supports multiple inheritance.
* **Intersection Types (`&`)**: Combine existing types. Conflicting properties result in a `never` type if they are incompatible.

## Generic Object Types
Create reusable container types by using type parameters.
```ts
interface Box<Type> {
  contents: Type;
}
```

## Built-in Generic Containers
* **`Array<T>`**: Standard array (shorthand `T[]`).
* **`ReadonlyArray<T>`**: Arrays that cannot be mutated (shorthand `readonly T[]`).
* **Tuples**: Arrays with fixed length and specific types at each position (e.g., `[string, number]`). Supports optional (`?`) and rest (`...`) elements.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-everyday-types]]
* [[typescript-generics]]
- [[typescript-type-operators]]
- [[typescript-utility-types]]
- [[typescript-functions]]
