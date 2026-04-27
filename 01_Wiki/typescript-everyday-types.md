---
title: [[typescript.md|TypeScript]] Everyday Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-types, union-types, type-aliases, interfaces]
---
# TypeScript Everyday Types

This note covers the core building blocks used to describe data in TypeScript.

## Primitives
* **`string`**: Text values.
* **`number`**: All numeric values (integers and floats).
* **`boolean`**: `true` or `false`.

## The `any` Type
The `any` type disables type-checking for a value. It is useful for gradual migration or when a type is too complex to define immediately, but should generally be avoided using `noImplicitAny`.

## Arrays and Objects
* **Arrays**: Written as `type[]` (e.g., `number[]`) or `Array<type>`.
* **Objects**: Defined by listing properties and their types (e.g., `{ x: number; y: number }`).
  * **Optional Properties**: Append `?` to the property name (e.g., `{ last?: string }`). Reading optional properties requires checking for `undefined`.

## Union Types
A union type represents a value that can be **any one** of several types, separated by `|` (e.g., `number | string`).
* **Narrowing**: You must refine the union (e.g., using `typeof` or `Array.isArray`) before using methods specific to one member.

## Type Aliases vs. Interfaces
Both are used to name a type, but they have key differences.

### Type Aliases (`type`)
A name for any type (object, union, primitive, etc.).
```ts
type Point = { x: number; y: number };
type ID = number | string;
```

### Interfaces (`interface`)
Primarily used to describe the shape of an object.
* **Extensibility**: Interfaces can always be extended via declaration merging (adding new fields to an existing interface), whereas type aliases cannot be changed once created.

## Type Assertions
Use `as` to tell the compiler about a more specific type that it cannot infer (e.g., `const myCanvas = document.getElementById("main_canvas") as HTMLCanvasElement;`).

## Literal Types
Combine with unions to define variables that can only hold specific strings or numbers.
```ts
type Alignment = "left" | "right" | "center";
```

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-basics]]
* [[typescript-narrowing]]

