---
title: Rust Concurrency
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [rust-threads, channels, mutex, sync-and-send]
---
# Rust Concurrency

Rust's ownership and type systems provide "Fearless Concurrency" by catching data races at compile time.

## Threads
Create a new thread using `std::thread::spawn`.
* **`join()`**: Call on a thread handle to wait for the thread to finish.
* **`move` closures**: Used with `spawn` to allow the new thread to take ownership of values from the spawning thread.

## Message Passing with Channels
"Do not communicate by sharing memory; instead, share memory by communicating."
* **`std::sync::msc`** (Multiple Producer, Single Consumer):
  * **Transmitter (`tx`)**: Send values using `send()`.
  * **Receiver (`rx`)**: Receive values using `recv()` (blocking) or `try_recv()` (non-blocking).

## Shared-State Concurrency
* **`Mutex<T>`** (Mutual Exclusion): Allows only one thread to access data at a time.
  * Use `lock()` to acquire access; returns a `MutexGuard` that automatically unlocks when it goes out of scope.
* **`Arc<T>`** (Atomic Reference Counting): Used to share ownership of a `Mutex` across multiple threads safely.

## Extensible Concurrency with `Sync` and `Send`
* **`Send`**: Indicates that ownership of the type can be transferred between threads.
* **`Sync`**: Indicates that it is safe for the type to be referenced from multiple threads simultaneously.
Almost all primitive types are `Send` and `Sync`.

---
## References
* Source: `00_Raw/the-rust-programming-language.md`
* [[rust-moc]]
* [[rust-smart-pointers]]

* [[mcp-best-practices]] (Host-as-Broker pattern)
