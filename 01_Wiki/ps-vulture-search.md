---
title: PS: Vulture Search
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-vulture-search, vulture-search.ps1, context-packet]
---
# PS: Vulture Search

`vulture-search.ps1` is a hybrid discovery engine designed specifically for agentic retrieval. It bridges the gap between passive knowledge and active capabilities.

## Mechanism
When queried, the engine performs a two-pass search:
1.  **Knowledge Pass**: Scans `01_Wiki/` for matching titles, content, and `aliases`.
2.  **Capability Pass**: Scans `02_System/tool-registry.md` to identify scripts that can act on the search subject.

## The Context Packet
The script outputs a "Context Packet" which provides an agent with:
*   Relevant notes to read.
*   Specific tools to execute to complete the task.

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/vulture-search.ps1 -Query "Rust"
```

---
## References
* [[hybrid-retrieval-spec]]
* [[ps-automation-spec]]
