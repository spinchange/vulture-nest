---
title: "Literature: Language Summaries (Python & Racket)"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/python-summary.md", "00_Raw/racket-summary.md"]
aliases: ["Language Overviews", "Python Core Patterns", "Racket LOP Overview"]
---

# Literature: Language Summaries (Python & Racket)

This note captures foundational overviews for core development languages used and referenced within the vault.

## Python Core Patterns
- **Decorators**: Behavioral extension using closures and `@decorator` syntax. Preservation of metadata via `functools.wraps` is recommended.
- **Context Managers**: Resource safety through the `with` statement (`__enter__` / `__exit__`), including async variants.
- **Type Hinting**: Evolution toward static analysis (PEP 484) with built-in collection support (3.9+) and union operators (3.10+).

## Racket LOP Philosophy
- **Language-Oriented Programming (LOP)**: The primary philosophy of Racket, enabling the creation of custom Domain-Specific Languages (DSLs).
- **Hygienic Macros**: Advanced syntax objects that prevent name collisions during expansion.
- **Software Contracts**: Mechanisms for enforcing boundaries and specifying behaviors between components.
- **Multi-Paradigm**: Support for functional, imperative, OO, and logic programming within the Lisp-Scheme family.

---
## See Also
- [[python-moc]]
- [[python-decorators]]
- [[python-context-managers]]
- [[python-typing]]
- [[racket]]
- [[programming-languages-moc]]
