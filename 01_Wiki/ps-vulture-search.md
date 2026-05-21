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

When `-Semantic` is enabled, the knowledge pass no longer emits semantic neighbors as an isolated appendix. It fuses lexical ranking with cosine similarity from `NoteEmbeddings`, using the same normalized-vector approach as [[auto-link.ps1]]. This means the primary seed set used for graph expansion is influenced by both explicit token matches and nearby conceptual notes.

## The Context Packet
The script outputs a "Context Packet" which provides an agent with:
*   Relevant notes to read.
*   Specific tools to execute to complete the task.
*   Ranked graph neighbors whose seed weights can include semantic lift, not just literal term overlap.

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/vulture-search.ps1 -Query "[[rust]]"
powershell.exe -ExecutionPolicy Bypass -File 02_System/vulture-search.ps1 -Query "pipeline provenance" -Semantic
```

---
## References
* [[hybrid-retrieval-spec]]
* [[ps-automation-spec]]

