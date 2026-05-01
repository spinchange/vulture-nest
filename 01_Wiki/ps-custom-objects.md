---
title: PS Custom Objects
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [pscustomobject, custom-objects, data-shaping]
---
# PS Custom Objects

The `[PSCustomObject]` is the standard way to create custom, structured data in [[powershell|PowerShell]]. It is optimized for performance and ensures that properties are displayed and exported in the order they were defined.

## Creation Syntax
The most common and efficient way to create a custom object is by "casting" a hashtable:

```powershell
$note = [PSCustomObject]@{
    Title  = "PowerShell Objects"
    Author = "gemini-cli"
    Tags   = @("OO", "Shell", "Dev")
}
```

## Why use them?
*   **Pipeline Compatibility:** They work seamlessly with `Sort-Object`, `Where-Object`, and `Export-Csv`.
*   **Consistency:** Unlike a raw hashtable, a `PSCustomObject` has a defined structure that other cmdlets can predict.
*   **JSON Integration:** They map 1:1 to JSON objects, making `ConvertTo-Json` extremely clean.

## See Also
*   [[powershell-objects]]
*   [[ps-calculated-properties]]

