---
title: [[python]] Typing
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [python-type-hints, gradual-typing]
---
# Python Typing

Python typing adds optional type information for humans, editors, linters, and schema-oriented libraries without changing Python into a statically typed language at runtime.

## Core Concepts
- Type hints describe expected shapes using annotations like `str`, `list[int]`, and `dict[str, Any]`.
- `Protocol` enables structural typing: an object is accepted if it behaves correctly, even without inheriting from a base class.
- `TypedDict` describes JSON-like mappings by key and value shape.
- `Annotated` attaches metadata to a type, which downstream libraries can use for validation or schema generation.
- `Literal`, `Union` or `|`, `Optional`, `Final`, and generics make contracts more precise.

## Significance for Agents
- Agents work best with explicit contracts. Type hints make tool surfaces easier to review, autocomplete, validate, and convert into schemas.
- `TypedDict` and `Annotated` are especially useful for tool-calling payloads because they map cleanly to JSON structures.
- Protocols let framework code depend on behavior rather than inheritance, which fits adapter-heavy agent systems.
- Typing is also the substrate Pydantic uses to infer runtime parsing rules and schema output.

## Practical Heuristics
- Keep public tool inputs narrow and explicit.
- Prefer `TypedDict` for plain request or response envelopes and classes when behavior matters.
- Use `Annotated` only when the metadata has a real consumer such as Pydantic or FastAPI.
- Treat typing as a design aid, not a substitute for runtime validation.

---
## References
- [[python]]
- [[python-moc]]
- [[pydantic]]
- [typing](https://docs.python.org/3.12/library/typing.html)

