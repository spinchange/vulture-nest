---
title: [[typescript.md|TypeScript]] Compiler Options
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [tsconfig, compiler-flags, tsc-config]
---
# TypeScript Compiler Options

TypeScript's behavior is highly configurable through compiler options, typically defined in a `tsconfig.json` file.

## Core Options
*   **`target`**: The version of JavaScript to output (e.g., `ESNext`, `ES2022`).
*   **`module`**: The module system to use (e.g., `CommonJS`, `ESNext`, `NodeNext`).
*   **`lib`**: A list of library files to include in the compilation (e.g., `["DOM", "ESNext"]`).
*   **`strict`**: Enables a wide range of strong type-checking behaviors.

## Strictness Flags
*   **`noImplicitAny`**: Error on inferred `any` types.
*   **`strictNullChecks`**: Forces explicit handling of `null` and `undefined`.
*   **`noImplicitReturns`**: Error when not all code paths in a function return a value.

## Output Control
*   **`outDir`**: The directory where compiled files are placed.
*   **`rootDir`**: The root directory of input files.
*   **`sourceMap`**: Generates source map files for debugging.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-basics]]

