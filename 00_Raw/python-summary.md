# Python Core Development Patterns

## Overview
Python emphasizes readability, resource safety, and type integrity through several core patterns.

## Decorators (Behavioral Extension)
Decorators wrap functions or classes to modify behavior using the `@decorator_name` syntax. They leverage closures and first-class functions.
* Use `functools.wraps` to preserve metadata.
* `typing.ParamSpec` for type safety in wrappers.

## Context Managers (Resource Management)
The `with` statement ensures resources like files and locks are managed correctly.
* Implemented via `__enter__` and `__exit__`.
* `@contextlib.contextmanager` for generator-based implementation.
* `async with` for asynchronous resources.

## Type Hinting (Static Analysis)
PEP 484 type hints enable tools like `mypy`.
* Python 3.9+: Built-in collections (e.g., `list[int]`).
* Python 3.10+: Pipe operator for unions (e.g., `int | None`).
* `Generator[YieldType, SendType, ReturnType]` for complex iterators.

Source: Google Search Summary (2026-04-24)
