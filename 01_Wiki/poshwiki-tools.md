---
title: PoShWiKi Tools API
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [poshwiki-api, thought-api, sidecar-database]
---
# PoShWiKi Tools API

The **PoShWiKi Tools API** (`02_System/poshwiki-tools.ps1`) is a high-level PowerShell 7 wrapper around the core PoShWiKi engine. It serves as the primary interface for agents to record their internal state, session logs, and collaborative findings without needing to manage low-level SQLite CLI arguments.

## 1. The Relational Sidecar Pattern
In the **vulture-nest**, we distinguish between **Durable Knowledge** (stored in flat YANP files in `01_Wiki/`) and **Ephemeral/Procedural Memory**. The PoShWiKi API implements the "Relational Sidecar" pattern:

- **YANP Files:** The human-readable source of truth. Version-controlled via Git. High latency for atomic updates.
- **PoShWiKi (SQLite):** The agent-runnable substrate. Low latency for atomic updates. High queryability via SQL/LINQ.

The API bridges these by allowing agents to "emit" thoughts into the database, which can later be "compiled" or promoted into durable YANP notes.

## 2. Core API Surface

### `Invoke-WikiNote` (The Atomic Upsert)
Standardizes section-level updates. Instead of overwriting an entire file, an agent can target a specific `## Heading`. 
- **Behavior:** If the page or section doesn't exist, it is created. If it exists, only that section is updated.
- **Use Case:** Maintaining a "Project Status" or "Current Assumptions" list across multiple turns.

### `Invoke-WikiLog` (Chronological Append)
Appends progress to a dedicated `## Actions` section on the current session page.
- **Behavior:** Automatically targets the page returned by `Get-WikiSessionTitle`.
- **Use Case:** Step-by-step logging of an agent's technical execution.

### `New-WikiSeam` (State Synchronization)
A specialized protocol for session handoffs. It records three critical vectors:
1.  **The Goal:** What we were trying to achieve.
2.  **The Seam:** The exact technical boundary where we stopped.
3.  **Next Step:** The immediate follow-up required by the next agent or human session.

## 3. Collaborative Benefits
The API is designed for **Heterogeneous Multi-Agent** environments:
- **Unified Context:** Claude and Gemini can both write to the same `Session 2026-04-25` page, creating a shared "short-term memory."
- **Standardized Reporting:** The [[visitor-directives|Visitor Protocol]] requires all guests to use this API, ensuring that no matter which model is working, the logs remain queryable and structured.
- **Discovery:** The `vulture-search.ps1` engine queries this substrate to provide agents with "Actionable Context" from previous sessions.

## 4. Technical Implementation
The wrapper is built on **PowerShell 7** and uses the `Microsoft.Data.Sqlite` library. It includes robust error handling to prevent database locking during concurrent agent access and returns `PSCustomObject` for machine-readability.

---
## References
- [[poshwiki]]
- [[ps-automation-spec]]
- [[visitor-directives]]
- [[daemon-design-pattern]]
- [[the-compounding-artifact]]
