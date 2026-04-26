---
title: TypeScript Mapped Types
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-mapped-types, type-iteration, key-remapping]
---
# TypeScript Mapped Types

Mapped types allow you to create new types by iterating over the keys of an existing type.

## Basic Syntax
```ts
type OptionsFlags<Type> = {
  [Property in keyof Type]: boolean;
};
```

## Mapping Modifiers
Use `readonly` and `?` to affect mutability and optionality. Prefix with `+` (default) or `-` to add or remove them.
```ts
type CreateMutable<Type> = {
  -readonly [Property in keyof Type]: Type[Property];
};
```

## Key Remapping via `as`
Map keys to new property names using the `as` clause, often combined with Template Literal Types.
```ts
type Getters<Type> = {
  [Property in keyof Type as `get${Capitalize<string & Property>}`]: () => Type[Property]
};
```
* **Filtering**: Map a key to `never` to remove it from the resulting type.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-type-operators]]
* [[typescript-template-literals]]
- [[typescript-objects]]
