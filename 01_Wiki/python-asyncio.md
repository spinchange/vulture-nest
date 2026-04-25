---
title: Python AsyncIO
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [asyncio, python-concurrency]
---
# Python AsyncIO

`asyncio` is Python's standard framework for cooperative concurrency. It lets one thread manage many concurrent I/O-bound operations by switching between coroutines whenever they await.

## Core Concepts
- An **event loop** coordinates tasks, callbacks, and I/O readiness.
- `async def` defines a coroutine function; calling it produces a coroutine object.
- A **Task** wraps a coroutine so it can be scheduled concurrently on the loop.
- `await` yields control back to the loop until the awaited operation completes.
- Cancellation is explicit and propagates through `CancelledError`, which means cleanup paths must be written deliberately.

## Main Building Blocks
- `asyncio.run(...)`: entry point for top-level async programs.
- `asyncio.create_task(...)`: schedule concurrent work.
- `asyncio.TaskGroup`: structured concurrency in Python 3.11+.
- `asyncio.gather(...)`: await multiple awaitables together.
- `asyncio.to_thread(...)`: move blocking I/O work off the event-loop thread.
- `asyncio.timeout(...)`: bound latency around tool calls or network operations.

## Significance for Agents
- Agent runtimes spend much of their time waiting on APIs, model responses, subprocesses, or storage. `asyncio` keeps those waits from serializing the whole system.
- Cancellation semantics matter for timeouts, human interrupts, and budget enforcement.
- `TaskGroup` is useful when several subtasks should fail together instead of leaking partial background work.
- The event loop punishes hidden blocking calls. File, database, or HTTP code that blocks the loop can make an "async" agent behave synchronously.

## Practical Heuristics
- Keep CPU-heavy work out of the event loop; use a worker thread or process when needed.
- Prefer `TaskGroup` for request-scoped parallelism and `create_task` only when you have a clear lifecycle for the spawned task.
- Always assume cancellation can happen between awaits.
- Wrap slow external operations with timeouts and surface structured failures.

---
## References
- [[python]]
- [[python-moc]]
- [Coroutines and Tasks](https://docs.python.org/3.12/library/asyncio-task.html)
- [asyncio](https://docs.python.org/3.12/library/asyncio.html)
