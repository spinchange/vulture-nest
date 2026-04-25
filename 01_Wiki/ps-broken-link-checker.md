---
title: PS: Broken Link Checker
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-broken-link-checker, check-broken-links.ps1]
---
# PS: Broken Link Checker

The `check-broken-links.ps1` script ensures the integrity of the knowledge graph by identifying links that point to non-existent notes.

## Functional Checks
1.  **Link Extraction**: Scans all `.md` files for the ```[[Target]]``` pattern.
2.  **Existence Verification**: Cross-references every target against the actual filenames in `01_Wiki/` and `02_System/`.

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/check-broken-links.ps1
```

## Output
Returns a list of "Dead Links" along with their source file, allowing for rapid repair of the knowledge graph.

---
## References
* [[hybrid-retrieval-spec]]
* [[ps-automation-spec]]
