---
title: TypeScript Utility Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-utilities, partial-type, pick-type, omit-type, return-type]
---
# TypeScript Utility Types

TypeScript provides several global utility types to facilitate common type transformations.

## Property Modifiers
* **`Partial<T>`**: Constructs a type with all properties of `T` set to optional.
* **`Required<T>`**: Constructs a type with all properties of `T` set to required (opposite of `Partial`).
* **`Readonly<T>`**: Constructs a type with all properties of `T` set to `readonly`.

## Subset and Mapping
* **`Record<K, T>`**: Constructs an object type whose property keys are `K` and whose property values are `T`.
* **`Pick<T, K>`**: Constructs a type by picking the set of properties `K` (string literal or union of string literals) from `T`.
* **`Omit<T, K>`**: Constructs a type by picking all properties from `T` and then removing `K`.

## Union Manipulation
* **`Exclude<T, U>`**: Excludes from `T` those types that are assignable to `U`.
* **`Extract<T, U>`**: Extracts from `T` those types that are assignable to `U`.
* **`NonNullable<T>`**: Excludes `null` and `undefined` from `T`.

## Function and Class Types
* **`Parameters<T>`**: Obtains the parameters of a function type in a tuple.
* **`ReturnType<T>`**: Obtains the return type of a function type.
* **`ConstructorParameters<T>`**: Obtains the parameters of a constructor function type in a tuple.
* **`InstanceType<T>`**: Obtains the instance type of a constructor function type.

## Advanced
* **`Awaited<T>`**: Models operations like `await` in `async` functions, or the `.then()` method on `Promise`s.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-generics]]
* [[typescript-conditional-types]]

* [[agent-note-conventions]] (Modeling metadata constraints)
