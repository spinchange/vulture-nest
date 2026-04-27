---
title: [[powershell.md|PowerShell]] Classes
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-classes, oop-powershell, strong-typing]
---
# PowerShell Classes

Introduced in PowerShell 5.0, **Classes** allow for formal Object-Oriented Programming (OOP). They are used to create structured types with properties, methods, and constructors.

## Basic Structure
```powershell
class WikiNote {
    [string]$Title
    [string]$Author
    [string]$Status
    [DateTime]$Date

    # Constructor
    WikiNote([string]$title, [string]$author) {
        $this.Title = $title
        $this.Author = $author
        $this.Date = Get-Date
        $this.Status = "draft"
    }

    # Method
    [string] GetSummary() {
        return "$($this.Title) by $($this.Author) ($($this.Status))"
    }
}

# Instantiating the class
$newNote = [WikiNote]::new("PowerShell Classes", "gemini-cli")
```

## Key Benefits
*   **Strong Typing:** Ensures data integrity by enforcing specific types for properties.
*   **Encapsulation:** Logic related to the data (methods) lives with the data.
*   **Inheritance:** You can create a base class and extend it for more specific use cases.
*   **Discovery:** Classes integrate perfectly with `Get-Member` and Intellisense in IDEs like VS Code.

## When to Use Classes
Classes are ideal for complex modules or when you need to ensure a strict data contract. For quick tasks or simple data passing, [[ps-custom-objects]] are usually faster and more idiomatic.

## See Also
*   [[powershell-objects]]
*   [[wiki-as-codebase]]

