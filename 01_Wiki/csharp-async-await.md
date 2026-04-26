---
title: C# Async/Await
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [asynchronous-programming, task-parallel-library, tpl]
---
# C# Async/Await

The **Async/Await** pattern is the standard for non-blocking programming in C#. It allows for high-performance I/O operations without tying up threads.

## Core Concepts

### 1. Task and Task<T>
Represents an asynchronous operation that may or may not return a value.

### 2. The `async` Modifier
Applied to a method to indicate it contains asynchronous code and to enable the use of the `await` keyword.

### 3. The `await` Keyword
Suspends the execution of the method until the awaited task completes, without blocking the main thread (or the thread pool thread).

## Best Practices
- **Async All the Way:** Don't mix sync and async code (avoid `.Result` or `.Wait()`).
- **ConfigureAwait(false):** Used in library code to avoid capturing the synchronization context, improving performance and avoiding deadlocks.
- **ValueTask:** A more memory-efficient alternative to `Task` for methods that often return synchronously.

## Application in Agentic Workflows
Agents are inherently asynchronous. They wait for:
- LLM API responses.
- Tool execution results.
- Human feedback.
Using `async/await` ensures that the agent's host application remains responsive while these long-running tasks are in flight.

---
## References
- [[ms-learn-csharp-overview]] (Source)
- [[csharp-moc]]
- [[agent-thought-cycle]]
- [[python-asyncio]]
