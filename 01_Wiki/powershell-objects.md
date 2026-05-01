---
title: [[powershell|PowerShell]] Objects
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [powershell-oo, everything-is-an-object, ps-pipeline]
---
# PowerShell Objects

Unlike traditional text-based shells (like Bash), **PowerShell** is fundamentally object-oriented. Every command returns an object or a collection of objects, which can be manipulated via their properties and methods.

## The Object Pipeline
In a text shell, the pipeline passes strings. In PowerShell, the pipeline passes **structured data**.
*   **Text Approach:** `ls -l | grep ".txt"` (Requires parsing text columns).
*   **PowerShell Approach:** `Get-ChildItem | Where-Object Extension -eq ".txt"` (Filters by the `Extension` property).

## Discovery: `Get-Member`
The `Get-Member` cmdlet (alias `gm`) is the primary tool for inspecting objects. It reveals the object's **TypeName** (.NET class), **Properties** (data), and **Methods** (actions).

```powershell
# Example: Inspecting a process
Get-Process | Get-Member
```

## Creating Custom Data: `PSCustomObject`
The `PSCustomObject` is a lightweight container for structured data. It is the standard way to pass custom information through the pipeline.

```powershell
$server = [PSCustomObject]@{
    Name = "WebSrv01"
    IP   = "192.168.1.10"
    Role = "Web"
}
```

## Core Principles
1.  **Filter Left:** Filter as early as possible in the pipeline to improve performance.
2.  **Output Objects, Not Text:** Functions should return objects so they can be reused by other cmdlets.
3.  **Everything is .NET:** PowerShell is built on .NET, meaning you have access to the entire .NET library directly from the shell.

## See Also
*   [[wiki-as-codebase]]

