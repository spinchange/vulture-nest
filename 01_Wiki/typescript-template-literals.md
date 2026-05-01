---
title: [[typescript|TypeScript]] Template Literal Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-template-literals, type-string-manipulation, intrinsic-string-types]
---
# TypeScript Template Literal Types

Template literal types allow for complex string manipulation within the type system, leveraging the same syntax as JavaScript template strings.

## Basic Syntax and Expansion
A template literal type expands into all possible combinations when provided with unions.
```ts
type World = "world";
type Greeting = `hello ${World}`; // "hello world"

type Lang = "en" | "ja";
type Locale = `${Lang}_id`; // "en_id" | "ja_id"
```

## Inference and Deconstruction
TypeScript can infer portions of a string inside a template literal.
```ts
type PropEventSource<T> = {
  on<K extends string & keyof T>(eventName: `${K}Changed`, callback: (v: T[K]) => void): void;
};
```

## Intrinsic String Manipulation Types
Built-in helpers for common string operations:
* `Uppercase<StringType>`
* `Lowercase<StringType>`
* `Capitalize<StringType>`
* `Uncapitalize<StringType>`

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-mapped-types]]

