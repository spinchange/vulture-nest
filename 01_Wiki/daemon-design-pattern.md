---
title: Daemon Design Pattern
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [vault-daemons, background-automation, persistent-services]
---
# Daemon Design Pattern

In the **vulture-nest**, a **Daemon** is a lightweight, background process that ensures the knowledge substrate remains synchronized with the human interface in real-time.

## Core Philosophy
Automation should not require manual invocation. By moving critical synchronization tasks (like graph mapping and HTML generation) into persistent background services, we reduce the cognitive load on the user and ensure the "Source of Truth" is always current.

## Implementation Pattern (Windows/[[powershell.md|PowerShell]])
1.  **The Watcher:** A `.ps1` script using `FileSystemWatcher` to monitor specific vault directories.
2.  **The Task:** A Windows Scheduled Task configured to trigger "At Log On."
3.  **The Execution:** Runs via `pwsh -NoProfile -ExecutionPolicy Bypass` to ensure environment consistency.

## Vault Daemons
- [[the-vulture-portal|Vulture Watcher]]: Synchronizes the relational graph and recompiles the HTML portal on every file save.

## Resilience
Every daemon in the project should include an `install-[name]-daemon.ps1` script to allow for rapid recovery or deployment on new machines.

---
## References
- [[wiki-as-codebase]]
- [[ps-automation-spec]]
- [[the-vulture-portal]]

