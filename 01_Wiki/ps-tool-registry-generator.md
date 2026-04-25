---
title: PS: Tool Registry Generator
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-tool-registry-generator, generate-tool-registry.ps1]
---
# PS: Tool Registry Generator

`generate-tool-registry.ps1` is the "Compiler" for the vault's automation suite. It transforms code-level metadata into agent-accessible documentation.

## Functional Mechanism
1.  **Scanning**: Iterates through all `.ps1` files in `02_System/`.
2.  **Extraction**: Uses the `Get-Help` cmdlet to extract structured data from `.SYNOPSIS`, `.DESCRIPTION`, `.INPUTS`, and `.OUTPUTS` blocks.
3.  **Compilation**: Generates a machine-readable Markdown file: `[[tool-registry|tool-registry.md]]`.

## Why it Matters
This script ensures that any new automation added by a human developer is immediately discoverable and usable by AI agents without manual documentation updates.

---
## References
* [[ps-automation-spec]]
* [[tool-registry]]
