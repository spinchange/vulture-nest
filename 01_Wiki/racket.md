---
title: Racket
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [racket-lang, language-oriented-programming, lisp-scheme]
---
# Racket

Racket is a descendant of Scheme and a pioneer of **Language-Oriented Programming (LOP)**. It is designed to be a "programmable programming language."

## Language-Oriented Programming
Racket's primary strength is the ease with which one can create new Domain-Specific Languages (DSLs).
*   **Hygienic Macros:** Unlike C-style macros, Racket macros are syntax-aware and prevent accidental variable capture.
*   **#lang:** Every Racket file starts with a `#lang` declaration, specifying the language/dialect being used.

## Engineering Standards
*   **Software Contracts:** Formal boundaries between modules that catch errors at the interface level.
*   **Typed Racket:** A sibling language that adds a static type system to the Racket ecosystem.

## See Also
* [[programming-languages-moc]]
* [[wiki-as-codebase]] (Connecting LOP to the concept of self-documenting code)
