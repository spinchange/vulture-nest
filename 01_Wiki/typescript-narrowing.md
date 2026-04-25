---
title: TypeScript Narrowing
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-narrowing, type-guards, discriminated-unions]
---
# TypeScript Narrowing

**Narrowing** is the process of refining types to more specific types than declared based on the structure of the code and runtime checks.

## Common Type Guards
TypeScript analyzes JavaScript's runtime control flow constructs to narrow types.
* **`typeof`**: Used for primitives (e.g., `if (typeof padding === "number")`). Note: `typeof null` is `"object"`.
* **Truthiness**: Narrowing based on whether a value is truthy or falsy (e.g., `if (strs) { ... }`).
* **Equality**: Using `===`, `!==`, `==`, and `!=` (e.g., `if (x === y)`). Note: `== null` checks for both `null` and `undefined`.
* **The `in` Operator**: Checking if an object has a specific property (e.g., `if ("swim" in animal)`).
* **`instanceof`**: Checking if a value is an instance of a specific class or constructor function.

## Assignments and Control Flow
* **Assignments**: TypeScript narrows the type of a variable on the left side of an assignment based on the type of the value on the right.
* **Control Flow Analysis**: TypeScript analyzes reachability to narrow types (e.g., if a function returns in an `if` block, the type is narrowed in the subsequent code).

## User-Defined Type Guards
Define a function with a **type predicate** as its return type to take direct control over narrowing.
```ts
function isFish(pet: Fish | Bird): pet is Fish {
  return (pet as Fish).swim !== undefined;
}
```

## Discriminated Unions
A pattern where a common property with literal types (a **discriminant**) is used to distinguish between different types in a union.
```ts
interface Circle { kind: "circle"; radius: number; }
interface Square { kind: "square"; sideLength: number; }
type Shape = Circle | Square;

function getArea(shape: Shape) {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.sideLength ** 2;
  }
}
```

## Exhaustiveness Checking with `never`
The `never` type can be used to ensure all members of a union are handled in a `switch` statement or `if/else` chain.
```ts
default:
  const _exhaustiveCheck: never = shape;
  return _exhaustiveCheck;
```

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-everyday-types]]
