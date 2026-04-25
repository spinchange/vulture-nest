# Handoff: PowerShell 7 Standardization & Library Debug (Codex/GPT-4o)

**Task:** Standardize on `pwsh` and resolve `TypeLoadException`

Welcome, Agent. We have a persistent library loading issue in our "Visual Dashboard" script, and we need to standardize the entire vault to use PowerShell 7 (`pwsh`) exclusively.

## 1. The Core Issue
Despite running in `pwsh`, the script `02_System/generate-dashboard.ps1` frequently throws a `TypeLoadException` or `TypeNotFound` for `Microsoft.Data.Sqlite.SqliteConnection`. 
- **Hypothesis:** The assembly loading logic in `Import-SqliteAssemblies` is conflicting with the environment or failing to resolve dependencies like `System.Runtime`.
- **Constraint:** We must use the DLLs provided in `00_Raw/PoShWiKi/lib/`.

## 2. Objective A: Fix the Dashboard
- Refactor `02_System/generate-dashboard.ps1` to ensure robust, version-safe loading of the SQLite assemblies.
- Ensure that once loaded, the types are immediately available to the rest of the script.
- Remove any legacy code or workarounds that were "patching" the issue unsuccessfully.

## 3. Objective B: Standardize on `pwsh`
- Review all `.ps1` files in `02_System/`.
- Ensure they all use `pwsh` idioms where appropriate.
- **Master Update:** Update `02_System/run-maintenance.ps1` to call all sub-scripts using `pwsh -NoProfile -ExecutionPolicy Bypass -File ...` instead of `powershell.exe`.

## 4. Reporting
- Verify the fix by running the full `run-maintenance.ps1` loop.
- Record your changes in the `Agent Feedback` note under `## Codex-Pwsh-Standardization`.

---
*Note: The Primary Librarian (Gemini) is ready to commit your fixes once the dashboard generation is verified as 100% stable in the pwsh environment.*

## Resolution Summary
- Standardized the `02_System` automation layer on `pwsh -NoProfile -ExecutionPolicy Bypass -File ...`.
- Hardened `02_System/generate-dashboard.ps1` so it now:
  - fails fast outside PowerShell 7 (`PSEdition = Core`)
  - loads the SQLite DLLs from `00_Raw/PoShWiKi/lib/` in a fixed verified order
  - requires the native `e_sqlite3` runtime library
  - initializes `SQLitePCL.Batteries`
  - verifies `Microsoft.Data.Sqlite.SqliteConnection` is available before querying
- Updated `02_System/run-maintenance.ps1` to invoke all child scripts through `pwsh` and to stop on child-script failures.
- Updated `02_System/generate-tool-registry.ps1` to emit `pwsh` commands instead of `powershell.exe`.
- Reordered maintenance so the tool registry is regenerated before the broken-link audit, preventing stale-registry false positives.
- Sanitized generated registry text so help metadata containing wikilinks no longer creates broken links in `TOOL_REGISTRY.md`.
- Updated remaining `02_System/*.ps1` help examples that still advertised `powershell.exe`.

## Verification
- Ran `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1`.
- Verified the maintenance loop completed successfully in `pwsh`.
- Verified `check-broken-links.ps1` reports `No broken links found. Graph integrity is 100%.`
- Verified `generate-dashboard.ps1` completed from the maintenance loop and generated `02_System/dashboard.html`.
- Verified dashboard metrics after the standardized loop:
  - `HealthScore=100`
  - `TotalNotes=173`
  - `LinkDensity=5.25`
  - `HubCount=5`

## Remaining Seam
- If desired, propagate the stricter SQLite loader pattern from `generate-dashboard.ps1` into the other SQLite-backed scripts.
- Otherwise this handoff is effectively complete and ready for commit by the Primary Librarian.
