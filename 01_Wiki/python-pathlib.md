---
title: Python Pathlib
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [pathlib, python-paths]
---
# Python Pathlib

`pathlib` provides object-oriented filesystem paths. It separates pure path manipulation from concrete filesystem I/O and replaces much of the older string-heavy `os.path` style.

## Core Concepts
- `Path` is the usual entry point for platform-native path operations.
- Pure path classes manipulate path semantics without touching the filesystem.
- Concrete path objects can inspect, create, open, rename, glob, and resolve files and directories.

## Significance for Agents
- Agent code often handles workspace files, generated artifacts, and retrieval corpora. `Path` objects make these workflows less error-prone than manual string concatenation.
- Path composition with `/` keeps code readable when prompts or tools stitch together nested directories.
- `glob()` and `rglob()` are useful for corpus discovery, but should be used carefully on large trees.

## Practical Heuristics
- Prefer `Path` over raw strings at module boundaries that interact with the filesystem.
- Resolve paths deliberately when security or sandbox boundaries matter.
- Treat recursive globbing as potentially expensive.

---
## References
- [[python-standard-library-hubs]]
- [[python-moc]]
- [pathlib](https://docs.python.org/3.12/library/pathlib.html)
