---
title: Codex Handoff — ps-automation-spec Compliance Pass
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
targets: [codex]
aliases: [ps-compliance-handoff, tier2-compliance-handoff]
---

# Codex Handoff: ps-automation-spec Compliance Pass

## Objective

Harden all non-compliant `02_System/*.ps1` scripts to satisfy [[ps-automation-spec]], then create `02_System/test-tier-compliance.ps1` as the Option A enforcement artifact specified in [[polyglot-platform-adr]].

Two deliverables, in this order:

1. **Compliance pass** — patch the 12 non-compliant scripts listed below.
2. **Enforcement script** — create `test-tier-compliance.ps1` and wire it into `run-maintenance.ps1`.

## Verified Facts

Spot-check completed by Claude on 2026-04-25. Results are exact — do not re-derive.

### Compliant (no changes needed)
- `orphan-check.ps1` — fixed this session
- `generate-wiki.ps1`
- `generate-dashboard.ps1`

### Missing `try/catch` only
- `run-maintenance.ps1` — has `$ErrorActionPreference = 'Stop'`, missing outer `try/catch`

### Missing `$ErrorActionPreference = 'Stop'` only
- `watch-wiki.ps1`
- `sync-vault-graph.ps1`
- `vulture-search.ps1`
- `poshwiki-tools.ps1`
- `install-vulture-daemon.ps1`

### Missing both
- `audit-yanp.ps1`
- `check-broken-links.ps1`
- `create-yanp-note.ps1`
- `find-thin-nodes.ps1`
- `generate-wiki-stats.ps1`
- `generate-tool-registry.ps1`

## Constraints

- Do not change any script's logic, output format, or public interface — only add the error-handling scaffolding.
- `run-maintenance.ps1` is the CI backbone. Its internal structure (the numbered `[1/6]` step sequence and child `pwsh -File` invocations) must be preserved exactly. The try/catch should wrap the entire body, not individual steps, so the exit code reflects overall failure.
- Scripts that write files or update the SQLite database need the `try/catch` most urgently — prioritize those if you need to batch the work.
- Vault health must be 100/100 after the compliance pass. Run `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1` to verify before committing.

## Pattern to Apply

For scripts missing `$ErrorActionPreference = 'Stop'`: add as the first non-comment line after the param block (or after the help block if there is no param block).

For scripts missing `try/catch`: wrap the entire body in:

```powershell
try {
    # existing body here
} catch {
    Write-Error "<script-stem>.ps1 failed: $_"
    exit 1
}
```

Do not nest try/catch inside an existing try/catch — if the script already has inner try/catch blocks, add only the outer wrapper.

## Deliverable 1: Compliance Pass

Apply the pattern above to all 12 scripts in the non-compliant lists. Commit as a single atomic commit with message:

```
Fix: Apply ps-automation-spec error-handling to all 02_System scripts

Add $ErrorActionPreference = 'Stop' and outer try/catch to 12 scripts
that were missing one or both per compliance spot-check. No logic changes.

Vault health 100/100.
```

## Deliverable 2: test-tier-compliance.ps1

Create `02_System/test-tier-compliance.ps1`. This is the Option A enforcement artifact from [[polyglot-platform-adr]].

**What it checks (scope is Tier-2 only — the only live tier in the vault):**

For every `.ps1` file in `02_System/`:
1. Is `$ErrorActionPreference = 'Stop'` present?
2. Is a `try { ... } catch { ... }` block present?

Output a compliance table (one row per script) with columns: `Script`, `HasEAP`, `HasTryCatch`, `Compliant`. Report a summary count. Exit with code `1` if any script is non-compliant; `0` if all pass.

**Script must satisfy [[ps-automation-spec]] itself:**
- `.SYNOPSIS` / `.DESCRIPTION` / `.EXAMPLE` help block
- `$ErrorActionPreference = 'Stop'`
- `try/catch` with `exit 1`
- Output as `[PSCustomObject]` rows for machine readability

**Wire into `run-maintenance.ps1`:** add a new numbered step (e.g., `[7/7] Checking Tier-2 Compliance...`) that invokes:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/test-tier-compliance.ps1"
```

After wiring, `run-maintenance.ps1` should itself become fully compliant (it gains the outer try/catch from Deliverable 1, plus this step proves compliance is enforced from within maintenance).

Commit as a second atomic commit:

```
Feat: Add test-tier-compliance.ps1 enforcement script (ADR Option A)

Implements Option A from polyglot-platform-adr: a PowerShell script that
checks all 02_System/*.ps1 files for $ErrorActionPreference and try/catch
compliance. Wired into run-maintenance.ps1 as step [7/7].

Vault health 100/100.
```

## Evidence

- `02_System/*.ps1` — the target files
- `01_Wiki/polyglot-platform-adr.md` — ADR specifying Option A enforcement
- `01_Wiki/ps-automation-spec.md` — the standard being enforced
- `02_System/orphan-check.ps1` — reference implementation (compliant, just patched)
- `02_System/generate-dashboard.ps1` — reference implementation (compliant)

## Next Decision

After both commits, update the PoShWiKi session page (`Session 2026-04-25`) with an `Actions` entry and update `Current Seam` to reflect that Option A is live. Log in `02_System/log.md`.

---
## References
- [[polyglot-platform-adr]]
- [[ps-automation-spec]]
- [[vault-audit-tool-spec]]
- [[inter-agent-handoff-protocol]]
- [[codex-polyglot-adr-handoff]]
