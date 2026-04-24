---
title: Tauri
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [tauri-framework, rust-desktop, modern-desktop-apps]
---
# Tauri

**Tauri** is a modern toolkit for building tiny, fast, and secure desktop applications using a web frontend and a **Rust** backend. It is the leading alternative to Electron.

## Core Architecture
*   **Frontend:** Any web framework (React, Vue, Svelte, or even plain JS/HTML). It is rendered using the **System Native WebView** (e.g., WebView2 on Windows).
*   **Backend:** Written in **Rust**. Handles system-level tasks like file I/O, networking, and high-performance processing.
*   **Bridge:** A secure, message-passing IPC (Inter-Process Communication) layer that connects the JS frontend to the Rust backend.

## Key Advantages
1.  **Extremely Small Binaries:** Because it doesn't bundle a browser (like Chromium), Tauri apps are often 20-50x smaller than Electron apps.
2.  **Memory Efficiency:** Rust is significantly more efficient than Node.js, and using the native WebView reduces RAM overhead.
3.  **Security by Default:** Capabilities (like file system access) must be explicitly enabled in the configuration. It uses a "deny-by-default" security model.
4.  **Performance:** Heavy-duty logic can be offloaded to Rust, which provides near-native execution speed.

## Tauri vs. Electron
| Feature | Electron | Tauri |
| :--- | :--- | :--- |
| **Backend** | Node.js | Rust |
| **Browser** | Bundled Chromium | Native WebView |
| **Bundle Size** | ~100MB | ~5MB |
| **Security** | Flexible | Strict (Sandboxed) |

## See Also
*   [[javascript-on-desktop]]
*   [[bun-vs-deno]]
*   [[wiki-as-codebase]]
