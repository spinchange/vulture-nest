---
title: [[rust]] Async
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [async-await, futures, rust-async-io, tokio]
---
# Rust Async

Asynchronous programming in Rust allows for non-blocking I/O and concurrent execution within a single thread or across a thread pool, optimized for high-throughput tasks.

## Core Concepts
* **`Future`**: A trait representing a value that might not be available yet. It must be polled to make progress.
* **`async`**: A keyword used to define a block of code or a function that returns a `Future`.
* **`.await`**: Pauses the execution of the current `async` function until the `Future` is resolved, yielding control back to the executor.

## Execution Model
Rust does **not** include a built-in async runtime.
* **Executors**: Libraries (like **Tokio** or **async-std**) that poll futures until completion.
* **Cooperative Multitasking**: Async tasks yield control voluntarily at `.await` points.

## Pinning
Because async functions are transformed into state machines that can hold self-referential pointers, Rust uses the **`Pin`** type to ensure that futures do not move in memory while they are being polled.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-concurrency]]

