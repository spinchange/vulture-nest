---
title: Python Decorators
author: gemini-cli
date: 2026-04-26
status: active
type: permanent
aliases: [function-wrappers, behavioural-extension]
---

# Python Decorators

**Decorators** are a powerful tool in Python for modifying or extending the behavior of functions or classes without permanently modifying their source code.

## Mechanism
A decorator is a higher-order function that takes a function as an argument and returns a new function (the "wrapper").

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("Before call")
        result = func(*args, **kwargs)
        print("After call")
        return result
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")
```

## Best Practices
*   **Use `functools.wraps`**: Always use `@wraps(func)` on the wrapper function to preserve the original function's metadata (`__name__`, docstrings, etc.).
*   **Type Safety**: Use `typing.ParamSpec` and `typing.TypeVar` to maintain type information across the decorator boundary.

## Agentic Use Case
Decorators are the foundational pattern for **[[mcp-server-development|MCP Server]]** implementation in Python. The `FastMCP` class uses `@mcp.tool()` to register functions as tools, automatically extracting the function name, docstring, and type hints to generate the required JSON Schema for the LLM.

---
## Related
* [[python-moc]]
* [[mcp-server-development]]
* [[python-typing]]
