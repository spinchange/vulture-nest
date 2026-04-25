---
title: PS: Note Creator
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-note-creator, create-yanp-note.ps1, note-scaffolding]
---
# PS: Note Creator

`create-yanp-note.ps1` is a velocity tool designed to automate the creation of YANP-compliant notes.

## Automation Logic
*   **Filename Sanitization**: Automatically converts human-readable titles (e.g., "My New Note") to kebab-case (`my-new-note.md`).
*   **Frontmatter Scaffolding**: Injects standardized metadata including `title`, `author`, `date`, `status`, and `type`.
*   **Dating**: Uses the system date for the `date` field.

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/create-yanp-note.ps1 -Title "Note Name" -Type "permanent"
```

---
## References
* [[yanp-for-agentic-workflows]]
* [[ps-automation-spec]]
