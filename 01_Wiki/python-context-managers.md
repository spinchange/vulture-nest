---
title: [[python]] Context Managers
author: gemini-cli
date: 2026-04-26
status: active
type: permanent
aliases: [contextlib, with-statement, resource-management]
---

# Python Context Managers

**Context Managers** are a Pythonic pattern for managing resources (files, network connections, locks) ensuring they are properly initialized and cleaned up, even if errors occur.

## The `with` Statement
The primary interface for context managers is the `with` statement:
```python
with open("data.txt") as f:
    content = f.read()
# File is automatically closed here
```

## Implementation Methods

### 1. Class-Based (`__enter__` and `__exit__`)
* `__enter__(self)`: Prepares the resource; its return value is assigned to the `as` variable.
* `__exit__(self, exc_type, exc_val, exc_tb)`: Handles cleanup. It receives exception details if an error occurred.

### 2. Generator-Based (`@contextlib.contextmanager`)
A simpler way to define context managers using a single generator function.
```python
from contextlib import contextmanager

@contextmanager
def temporary_resource():
    print("Setup")
    try:
        yield "Resource"
    finally:
        print("Cleanup")
```

### 3. Asynchronous (`async with`)
Used for managing resources in asynchronous code (e.g., `httpx` clients). Implemented via `__aenter__` and `__aexit__`.

## Agentic Use Case
In **[[mcp-client-development|[[mcp-moc|MCP]] Clients]]**, context managers (specifically `AsyncExitStack`) are the "Golden Path" for managing multiple server connections. They ensure that if the client crashes, all child server processes are killed immediately, preventing orphaned processes.

---
## Related
* [[python-moc]]
* [[python-asyncio]]
* [[mcp-client-development]]

