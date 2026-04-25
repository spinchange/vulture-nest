---
title: PS: YANP Audit
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-yanp-audit, audit-yanp.ps1]
---
# PS: YANP Audit

The `audit-yanp.ps1` script is the primary compliance tool for the vault. It ensures that all notes in `01_Wiki/` adhere to the **Yet Another Note Protocol**.

## Functional Checks
1.  **Kebab-Case**: Verifies that filenames are lowercase and hyphen-separated.
2.  **Metadata Integrity**: Scans for a valid `type` field in the YAML frontmatter (`permanent`, `literature`, or `fleeting`).

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1
```

## Output
Returns a table showing each file's status across all checks. It highlights non-compliant files in red for rapid identification.

---
## References
* [[yanp-for-agentic-workflows]]
* [[ps-automation-spec]]
