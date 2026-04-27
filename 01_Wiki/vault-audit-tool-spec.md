---
title: Vault Audit Tool Spec
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-maintenance-spec, vault-tool-schema]
---
# Vault Audit Tool Spec

Following the **[[agent-tools]]** standard, this document provides the formal schema for the maintenance tools located in `02_System/`. 

## 1. YANP Compliance Auditor
*   **File:** `02_System/audit-yanp.ps1`
*   **Description:** Scans `01_Wiki/` to ensure all files follow lowercase kebab-case naming and contain a valid `type` (permanent, literature, or fleeting) in the YAML frontmatter.
*   **Execution Command:** `powershell.exe -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1`
*   **Inputs:** None.
*   **Outputs:** A PSCustomObject table showing compliance status per file.

## 2. Orphan Note Checker
*   **File:** `02_System/orphan-check.ps1`
*   **Description:** Performs a global scan for markdown files in `01_Wiki/` that have zero incoming wikilinks from other notes.
*   **Execution Command:** `powershell.exe -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1`
*   **Inputs:** None.
*   **Outputs:** A list of orphan note basenames or a success message.

## Usage Guide for Agents
When an agent enters this vault to perform an **[[wiki-pattern-operations|Ingest]]** or **[[agent-evaluation|Online Evaluation]]**, it should run the **YANP Compliance Auditor** after every file modification to ensure protocol integrity.

---
## See Also
* [[yanp-for-agentic-workflows]]
* [[agent-tools]]
* [[wiki-as-codebase]]
- [[ps-yanp-audit]]

