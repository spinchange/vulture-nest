---
title: Bun vs Deno
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [modern-js-runtimes, typescript-scripting]
---
# Bun vs Deno

For modern desktop and system scripting, **Bun** and **Deno** have largely superseded Node.js for new projects due to their native [[typescript.md|TypeScript]] support and improved developer experience.

## Comparison Table

| Feature | Deno | Bun |
| :--- | :--- | :--- |
| **Security** | Sandbox (Permissions required) | Standard (Same as Node) |
| **Speed** | Fast (V8) | Ultra-Fast (JavaScriptCore) |
| **Shell** | `Deno.Command` | `Bun.$` (Native Shell) |
| **Compatibility** | High (supports most NPM) | Near-Perfect (Drop-in Node replacement) |
| **Philosophy** | Explicit & Secure | Fast & All-in-One |

## When to use Deno
Use **Deno** if security and zero-config are your priorities. It is excellent for "utility" scripts that you want to share with others, as the permission system ensures the script won't do anything malicious without consent.

## When to use Bun
Use **Bun** if you want raw performance and a "Bash-like" experience inside your JS. The `Bun.$` shell makes it incredibly easy to automate complex sequences of local commands.

## Example: Bun Shell
```javascript
import { $ } from "bun";
const branch = await $`git branch --show-current`.text();
console.log(`Working on ${branch.trim()}`);
```

## See Also
*   [[javascript-on-desktop]]
*   [[powershell-objects]]

