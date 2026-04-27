---
title: [[python]] Data Model
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [dunder-methods, python-objects]
---
# Python Data Model

The Python data model explains how objects behave, how the interpreter dispatches operations, and why special methods shape nearly every abstraction in Python.

## Core Concepts
- Every Python value is an object with an **identity**, **type**, and **value**.
- An object's type determines supported operations and whether its value is mutable or immutable.
- Containers hold references to other objects, so mutability questions often depend on whether the container itself can change or whether the referenced objects can change.
- Python behavior is largely protocol-driven: operations like attribute access, iteration, comparison, calling, awaiting, and context management are delegated through special methods.

## Special Methods That Matter
- Construction and representation: `__new__`, `__init__`, `__repr__`, `__str__`
- Collections and iteration: `__len__`, `__iter__`, `__getitem__`, `__contains__`
- Attribute control: `__getattr__`, `__getattribute__`, `__setattr__`
- Numeric and comparison behavior: `__add__`, `__eq__`, `__lt__`
- Context management: `__enter__`, `__exit__`, `__aenter__`, `__aexit__`
- Async integration: `__await__`, `__aiter__`, `__anext__`

## Significance for Agents
- Agent frameworks depend heavily on Python protocols rather than rigid interfaces. Objects become tools, models, iterables, context managers, or awaitables by implementing the right methods.
- Understanding identity versus value helps avoid state bugs when mutable lists, dicts, and caches are shared across tool invocations.
- The data model is the basis for ergonomic abstractions such as model classes, descriptors, validators, and custom serialization hooks.
- Async support is part of the same model: `await`, `async with`, and `async for` are language-level protocol dispatch, not one-off syntax.

## Practical Heuristics
- Prefer immutable values for configuration and message payloads when possible.
- Be explicit when objects own mutable shared state.
- Reach for protocol behavior only when it clarifies the abstraction; do not overload dunder methods just to be clever.
- Treat `__repr__` as observability infrastructure because agent debugging is often log-driven.

---
## References
- [[python]]
- [[python-moc]]
- [Python Data Model](https://docs.python.org/3.12/reference/datamodel.html)

