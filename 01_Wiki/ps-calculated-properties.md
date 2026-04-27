---
title: PS Calculated Properties
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [calculated-properties, select-object-labels, property-expressions]
---
# PS Calculated Properties

**Calculated Properties** allow you to create or modify object properties on the fly within a pipeline, typically using `Select-Object`.

## Syntax
A calculated property is defined by a hashtable with two keys: **Name** (or Label) and **Expression**.

```powershell
# Example: Transforming file size to MB
Get-ChildItem | Select-Object Name, @{
    Name = "SizeMB"
    Expression = { $_.Length / 1MB }
}
```

## Common Use Cases
*   **Unit Conversion:** Converting bytes to KB/MB/GB.
*   **Formatting:** Truncating strings or formatting dates.
*   **Data Enrichment:** Adding a property that is calculated from other properties (e.g., `TotalCost = Price * Quantity`).
*   **Renaming:** Changing a property name to match a target schema (e.g., changing `Length` to `FileSize`).

## The `$_` Variable
Within the `Expression` block, `$_` represents the current object in the pipeline. This is where the power of [[powershell.md|PowerShell]]'s object-oriented nature shines—you have access to every property of the object while you are transforming it.

## See Also
*   [[powershell-objects]]
*   [[ps-custom-objects]]

