---
name: pwsh-shell
description: Mandates the use of PowerShell 7+ (pwsh) for all shell operations in this vault. Use when executing scripts, managing vault files, or running Windows commands to ensure modern PowerShell features and compatibility.
---

# PowerShell 7 Shell

This skill ensures that all shell commands are executed using **PowerShell 7 (pwsh)** instead of the legacy Windows PowerShell (powershell.exe).

## Core Mandate

**ALWAYS** wrap every shell command in `pwsh -NoProfile -Command "..."`.

### Why?
The default environment for the `run_shell_command` tool on Windows is PowerShell 5.1. This vault requires PowerShell 7+ for modern features and compatibility with its `02_System/` scripts.

## Usage Patterns

### 1. Simple Commands
Instead of: `Get-ChildItem`
Use: `pwsh -NoProfile -Command "Get-ChildItem"`

### 2. Executing Scripts
Always use the `-ExecutionPolicy Bypass` flag when running local `.ps1` files.
Use: `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/my-script.ps1`

### 3. Complex Pipelines
Ensure the entire pipeline is enclosed in the `pwsh` command string.
Use: `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CPU -gt 10 } | Select-Object ProcessName"`

## Tip
- Do not rely on the default tool shell. Explicitly invoke `pwsh` for every turn.
