---
title: PS: Orphan Check
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-orphan-check, orphan-check.ps1]
---
# PS: Orphan Check

`orphan-check.ps1` identifies markdown files in the wiki that lack incoming Wikilinks.

## Logic
The script performs a global scan of all files in `01_Wiki/` and `02_System/` to look for matching wikilink patterns. If a note's name is not found in the content of any other file, it is flagged as an "Orphan."

## Use Case
Crucial for maintaining a healthy knowledge graph. Flagged orphans should either be linked to a Map of Content (MOC) or evaluated for deletion/consolidation.

---
## References
* [[ps-automation-spec]]
* [[the-compounding-artifact]]
