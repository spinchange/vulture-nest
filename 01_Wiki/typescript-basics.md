---
title: [[typescript.md|TypeScript]] Basics
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-basics, static-typing, tsc-compiler]
---
# TypeScript Basics

TypeScript is a static type-checker for JavaScript. It identifies potential errors in code before it runs, providing a more robust development experience.

## The Role of Static Type-Checking
JavaScript only provides **dynamic typing**, where errors are discovered at runtime. TypeScript adds a **static type system** that makes predictions about code behavior based on the shapes and capabilities of values.

### Non-Exception Failures
TypeScript catches "valid" JavaScript that is likely a bug, such as:
* Accessing non-existent properties (`user.location` where `location` isn't defined).
* Typos in property or method names.
* Uncalled functions (e.g., `Math.random < 0.5`).
* Basic logic errors (unreachable code due to impossible conditions).

## Tooling and `tsc`
The TypeScript compiler (`tsc`) transforms `.ts` files into plain `.js` files.
* **Type Erasure**: Type annotations are completely removed during compilation; they do not exist at runtime.
* **Downleveling**: TypeScript can transpile modern JavaScript features (like template strings) to older versions (like ES5) for better compatibility.

## Strictness Settings
TypeScript's strictness can be adjusted to suit the project's needs. Key flags include:
* **`noImplicitAny`**: Issues an error when a variable's type is implicitly inferred as `any`.
* **`strictNullChecks`**: Makes handling `null` and `undefined` explicit, preventing "billion dollar mistake" bugs.
* **`strict`**: Enables all strict type-checking options simultaneously.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-everyday-types]]

