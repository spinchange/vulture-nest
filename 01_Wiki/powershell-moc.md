---
title: PowerShell MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [powershell-hub, ps-development]
---
# PowerShell MOC

This Map of Content serves as the central hub for PowerShell development patterns and object-oriented scripting within this vault.

## Core Object Model
The foundation of PowerShell is its object-oriented nature. Unlike text-based shells, PowerShell passes structured data.
* [[powershell-objects]]: The fundamental philosophy of "Everything is an Object."
* [[ps-custom-objects]]: Creating lightweight, ad-hoc data structures for reports and data manipulation.

## Advanced Structures
For more formal development and complex logic:
* [[ps-classes]]: Implementing formal schemas and methods for reusable tools.
* [[ps-calculated-properties]]: Dynamically extending existing objects during pipeline processing.

## System Utilities
The vault's maintenance is handled via local scripts:
* `02_System/audit-yanp.ps1`: Compliance auditor.
* `02_System/orphan-check.ps1`: Link health auditor.

---
## See Also
* [[programming-languages-moc]]
* [[wiki-as-codebase]]
