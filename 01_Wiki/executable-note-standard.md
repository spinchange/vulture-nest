---
title: Executable Note Standard
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [active-knowledge, runnable-notes, script-notes]
---
# Executable Note Standard

Building on the [[wiki-as-codebase]] philosophy, this standard defines how wiki notes can contain "Active Knowledge"—embedded logic that an agent can safely execute to perform vault tasks.

## 1. Metadata Triggers
A note signals its executable status via YAML frontmatter:
*   `type`: `active` (Specifies this is an automation or tool note).
*   `runner`: `powershell` (Specifies the required execution environment).
*   `scope`: `vault` | `system` (Defines the intended impact boundary).

## 2. Block Identification
Runnable code must be contained in fenced code blocks. To be considered "Active," the block should be tagged with `powershell` and preceded by an H2 heading describing the task.

```powershell
# Task: [Human Readable Task Name]
# Boundary: [Path/Scope]
$vaultRoot = "C:\Users\executor\Documents\vulture-nest"
# ... logic ...
```

## 3. Execution Context
*   **Working Directory**: All executable notes must assume the vault root as the base directory.
*   **Permissions**: All scripts must be compatible with the [[powershell-moc|win32/PowerShell 7+]] mandate and runnable via `-ExecutionPolicy Bypass`.
*   **Variables**: Agents should provide standard environment variables to the script context (e.g., `VAULT_ROOT`, `CURRENT_NOTE_PATH`).

## 4. Security Boundaries (The "Golden Rules")
1.  **Explicit Consent**: Agents **MUST NOT** execute active blocks automatically. They must present the code to the Human Architect and receive an explicit "Approve Execution" signal.
2.  **Surgical Impact**: Scripts should be designed to modify specific targets (e.g., a single note, a specific metadata key) rather than performing global destructive actions.
3.  **Auditability**: Every execution must be logged in the `[[02_System/log.md|System Log]]` with the note name and timestamp.
4.  **No Secrets**: Active notes must never store API keys or credentials. Use environment variables or local secret managers as per [[ps-automation-spec]].

## 5. Use Cases
*   **Dynamic Indexing**: A note that, when run, updates its own "See Also" section based on a semantic query.
*   **Metadata Refactoring**: A note that cleans up tags or statuses across a specific MOC.
*   **Tool Bootstrapping**: Automatically generating or updating `.ps1` files in `02_System/` based on high-level designs.

---
## References
* [[wiki-as-codebase]]
* [[ps-automation-spec]]
* [[powershell-moc]]
* [[GEMINI.md]]
