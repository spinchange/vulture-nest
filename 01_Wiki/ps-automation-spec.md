---
title: PowerShell Automation Specification
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-spec, executable-knowledge-standard]
---
# PowerShell Automation Specification

To ensure that PowerShell scripts in this vault are discoverable, safe, and easily executable by both humans and AI agents, all scripts in `02_System/` must adhere to this standard.

## 1. File Naming
*   **Format**: `lowercase-kebab-case.ps1`.
*   **Uniqueness**: The stem must be unique across the vault.

## 2. Metadata (Comment-Based Help)
Every script **MUST** start with a `.SYNOPSIS` and `.DESCRIPTION` block. This allows the `[[ps-tool-registry-generator]]` to automatically index the tool for AI agents.

```powershell
<#
.SYNOPSIS
    Short summary of the tool.
.DESCRIPTION
    Detailed explanation of what the script does and its impact.
.PARAMETER Name
    Description of specific parameters.
.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File 02_System/script-name.ps1 -Param "Value"
#>
```

## 3. Argument Handling
*   Use `Param()` blocks for all inputs.
*   Enforce `Mandatory=$true` for required fields to prevent ambiguous agent execution.
*   Use descriptive parameter names (avoid single-letter flags).

## 4. Output Standards
*   **Human-Readable**: Use `Write-Host` with `-ForegroundColor` for status updates.
*   **Machine-Readable**: Use `[PSCustomObject]` to return data. This allows other scripts or agents to parse the output as JSON if needed.
*   **Encoding**: Always use `UTF8` when writing files to maintain compatibility with Obsidian and Git.

## 5. Security & Safety
*   **Execution Policy**: Scripts must be runnable via `-ExecutionPolicy Bypass`.
*   **Pathing**: Always use absolute paths (via `$PSScriptRoot`) or predictable relative paths starting from the vault root.
*   **Error Handling**: Wrap critical logic in `Try/Catch` blocks to ensure a clean exit code (`1` on failure, `0` on success).

## 6. Registry Integration
The `02_System/generate-tool-registry.ps1` script is the "Compiler" for this spec. If a script lacks metadata, it will be omitted from the registry, rendering it "invisible" to automated agent search.

---
## References
* [[powershell-moc]]
* [[wiki-as-codebase]]
* [[GEMINI]]
