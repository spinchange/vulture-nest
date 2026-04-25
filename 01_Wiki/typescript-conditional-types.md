---
title: TypeScript Conditional Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-conditional-types, type-ternary, infer-keyword]
---
# TypeScript Conditional Types

Conditional types allow you to describe relations between input and output types using logic similar to ternary expressions.

## Basic Syntax
```ts
SomeType extends OtherType ? TrueType : FalseType;
```
If `SomeType` is assignable to `OtherType`, the result is `TrueType`.

## Constraints and Extraction
Conditional types can be used to extract information from a type when a constraint is met.
```ts
type MessageOf<T> = T extends { message: unknown } ? T["message"] : never;
```

## The `infer` Keyword
Used to declaratively introduce a new generic type variable within the `extends` clause of a conditional type.
```ts
type GetReturnType<T> = T extends (...args: any[]) => infer R ? R : any;
```

## Distributive Conditional Types
When a conditional type acts on a generic type and is given a union, it "distributes" across the union members.
* `ToArray<string | number>` becomes `ToArray<string> | ToArray<number>`.
* **Disabling Distributivity**: Wrap the types in square brackets (e.g., `[T] extends [any]`).

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-generics]]
* [[typescript-type-operators]]
