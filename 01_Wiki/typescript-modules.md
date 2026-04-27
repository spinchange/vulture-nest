---
title: [[typescript.md|TypeScript]] Modules
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-modules, es-modules, commonjs, import-type]
---
# TypeScript Modules

TypeScript follows the ES Modules (ESM) specification for modularizing code, while maintaining support for legacy formats like CommonJS.

## Defining a Module
Any file containing a top-level `import` or `export` is considered a module. Files without them are treated as scripts with shared global scope.

## ES Module Syntax
* **`export default`**: The main export of a file.
* **`export`**: Named exports for variables, functions, and types.
* **`import`**: Consume exports from other files.
* **`import * as name`**: Import all exports into a single namespace.
* **`export { ... } from './file'`**: Re-exporting items.

### TypeScript Specifics
* **`import type`**: Ensures a reference is only used as a type and can be safely removed by non-TS transpilers.
* **Inline `type` imports**: `import { someValue, type someType } from './file'`.

## CommonJS Syntax
The format used by Node.js and many npm packages.
* **`module.exports = { ... }`**: Exporting items.
* **`const math = require('./math')`**: Importing items.
* **`import fs = require('fs')`**: TypeScript's syntax for CommonJS interoperability.

## Module Resolution
The process of mapping an import string to a file on disk. Strategies include `Node` (replicating Node.js logic) and `Classic`.

## Namespaces
A TypeScript-specific way to organize code that pre-dates ESM. Primarily used today in definition files (`.d.ts`) on DefinitelyTyped.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-compiler-options]]

