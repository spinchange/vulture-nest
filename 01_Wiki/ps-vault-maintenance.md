---
title: PS: Vault Maintenance
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-vault-maintenance, run-maintenance.ps1]
---
# PS: Vault Maintenance

`run-maintenance.ps1` is the master orchestration script for the vault's "Knowledge CI/CD" pipeline.

## Orchestration Logic
It executes the following scripts in sequence to ensure total vault synchronization:
1.  `[[ps-yanp-audit]]`: Validates protocol compliance.
2.  `[[ps-orphan-check]]`: Identifies disconnected notes.
3.  `[[ps-tool-registry-generator]]`: Refreshes the machine-readable tool index.

## Usage
This script should be run after every major ingestion or refactor to maintain the high-signal state of the vault.
```powershell
powershell.exe -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1
```

---
## References
* [[ps-automation-spec]]
* [[wiki-as-codebase]]
* [[automation-test]]
- [[vault-audit-tool-spec]]
- [[ps-broken-link-checker]]
- [[ps-vault-stats]]
