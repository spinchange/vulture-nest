---
title: JavaScript MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [js-development, desktop-js]
---
# JavaScript MOC

This map covers the JavaScript-side runtime surface of the vault: browser-adjacent tooling, Node-compatible package ecosystems, and desktop/web bridges. In this repo, JavaScript matters less as a standalone language theory topic and more as the environment around [[typescript|TypeScript]], workbench tooling, and desktop-facing prototypes.

## Runtimes and Tooling
Start here if you are choosing an execution environment or trying to understand the surrounding JS runtime assumptions.

* [[javascript-on-desktop]]: The evolution from Electron to more lightweight alternatives.
* [[bun-vs-deno]]: Comparing the modern "No-Config" runtimes.
* [[typescript-moc]]: Type-safe development and the [[typescript|TypeScript]] Handbook.

## Frameworks
This section covers the concrete UI/runtime bridge technologies most relevant to the Nest.

* [[tauri]]: Building tiny, secure desktop apps with web frontends and [[rust]] backends.

## How This Cluster Relates To The Nest

- Use [[typescript-moc]] when the question is language shape, typing, or SDK ergonomics.
- Use [[javascript-on-desktop]] and [[tauri]] when the question is desktop delivery or human-facing local tools.
- Use [[bun-vs-deno]] when runtime selection matters more than framework choice.

## Where To Start

If your goal is:

1. desktop app architecture -> [[javascript-on-desktop]], then [[tauri]]
2. typed JS development -> [[typescript-moc]]
3. runtime tradeoffs -> [[bun-vs-deno]]

---
## See Also
* [[programming-languages-moc]]
* [[powershell-moc]]
* [[wiki-as-codebase]]

