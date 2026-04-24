---
title: Python
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [python-patterns, decorators, context-managers]
---
# Python

Python is a high-level, interpreted programming language known for its readability and "batteries-included" philosophy. Within this vault, we focus on its core development patterns and type system.

## Core Patterns
*   **Decorators:** Used for behavioral extension via the `@decorator` syntax. They leverage closures to wrap functions or classes. Use `functools.wraps` to maintain metadata.
*   **Context Managers:** Managed via the `with` statement and the `__enter__`/`__exit__` protocol. Essential for resource safety (files, sockets, database connections).

## Type System
Since PEP 484, Python has embraced static type hinting.
*   **Gradual Typing:** Coexists with dynamic typing, checked via tools like `mypy`.
*   **Modern Syntax:** Python 3.10+ uses `|` for unions (e.g., `int | str`).

## See Also
* [[programming-languages-moc]]
* [[javascript-on-desktop]] (Comparison of interpreted ecosystems)
