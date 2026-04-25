---
title: TypeScript Generics
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-generics, type-variables, generic-constraints]
---
# TypeScript Generics

Generics provide a way to create reusable components that can work over a variety of types rather than a single one, while maintaining precise type information.

## Type Variables
A type variable (e.g., `<Type>`) captures the type provided by the user so that it can be used to denote other types (like the return type).
```ts
function identity<Type>(arg: Type): Type {
  return arg;
}
```
* **Inference**: TypeScript can usually automatically set the value of `Type` based on the argument passed.

## Generic Types and Interfaces
You can describe the type of a generic function or create entirely generic interfaces and classes.
```ts
interface GenericIdentityFn<Type> {
  (arg: Type): Type;
}
```

## Generic Constraints
Limit the kinds of types a generic parameter can accept using the `extends` keyword.
```ts
interface Lengthwise {
  length: number;
}

function loggingIdentity<Type extends Lengthwise>(arg: Type): Type {
  console.log(arg.length);
  return arg;
}
```

## Using Type Parameters in Constraints
You can constrain one type parameter by another (e.g., to ensure a key exists on an object).
```ts
function getProperty<Type, Key extends keyof Type>(obj: Type, key: Key) {
  return obj[key];
}
```

## Generic Parameter Defaults
Make type arguments optional by providing a default.
```ts
interface Container<T = string> {
  value: T;
}
```

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-functions]]
* [[typescript-objects]]
