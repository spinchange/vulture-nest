---
title: JavaScript on Desktop
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [js-scripting, nodejs, deno, bun, system-js]
---
# JavaScript on Desktop

JavaScript is no longer confined to the browser. Modern runtimes have turned it into a first-class citizen for desktop automation, system scripting, and application development.

## The Major Runtimes
*   **Node.js:** The industry standard. Powerhouse of the ecosystem, but requires `npm` management.
*   **Deno:** A secure-by-default runtime with native [[typescript.md|TypeScript]] support. Ideal for single-file scripts without a `node_modules` folder.
*   **Bun:** An ultra-fast runtime with a built-in shell (`$`) and package manager. Designed for high-performance CLI tools.

## Key Advantages
1.  **JSON as Native:** JavaScript handles JSON (the language of modern APIs) more natively than any other language.
2.  **Universal Ecosystem:** Access to millions of libraries via NPM for every imaginable task (cloud, database, networking).
3.  **Cross-Platform:** A script written in JS/TS is much more likely to run perfectly on Windows, Linux, and macOS than a [[powershell.md|PowerShell]] or Bash script.

## Shell Integration: The `zx` and `$` Patterns
Modern JS scripting focuses on making shell execution feel native.
*   **zx (Node):** `await $`ls -l``
*   **Bun Shell:** `await $`cat config.json``

## See Also
*   [[powershell-objects]] (for a comparison of OO philosophies)
*   [[wiki-as-codebase]]

