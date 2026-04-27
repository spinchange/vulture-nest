---
title: PS: Vault Stats
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-vault-stats, generate-wiki-stats.ps1, vault-health-score]
---
# PS: Vault Stats

`generate-wiki-stats.ps1` provides high-level observability into the density and health of the vault.

## Metrics Tracked
*   **Total Wiki Notes**: The raw count of permanent, literature, and fleeting notes.
*   **Link Density**: The average number of Wikilinks per note (a proxy for "IQ").
*   **Orphan Count**: Notes that are not linked to.
*   **Broken Link Count**: Links that point nowhere.
*   **Vault Health Score**: A weighted percentage (0-100%) based on orphans and broken links.

## Usage
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/generate-wiki-stats.ps1
```

---
## References
* [[powershell-moc]]
* [[the-compounding-artifact]]
- [[ps-orphan-check]]
- [[ps-broken-link-checker]]

