---
title: Codex Handoff — Polyglot ADR Verification
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
targets: [codex]
aliases: [polyglot-adr-handoff, codex-adr-brief]
---

# Codex Handoff: Polyglot ADR Verification

## Objective

Verify the RFC's tier inventory and open questions against the vault's actual source files, then produce `01_Wiki/polyglot-platform-adr.md` as the formal, `status: active` ADR — incorporating confirmed facts and closing the questions Claude left open.

The RFC is at `01_Wiki/polyglot-adr-rfc.md`. Read it in full before starting.

## Verified Facts

*(Established by Claude before this handoff — do not re-derive, verify only.)*

- The vault uses four language tiers: [[rust]] (Tier-0), C# (Tier-1), [[powershell|PowerShell]] (Tier-2), [[python]] (Tier-3).
- Tier-0 artifact: `00_Raw/vulture-mcp/` — a Rust [[mcp-moc|MCP]] server over stdio.
- Tier-1 artifact: `00_Raw/PoShWiKi/` — PowerShell host loading `Microsoft.Data.Sqlite.dll`; proposed pattern in `01_Wiki/dotnet-mcp-server-patterns.md`.
- Tier-2 artifacts: `02_System/*.ps1` (15 scripts), `00_Raw/PoShWiKi/wiki.ps1`.
- Tier-3 artifacts: wiki knowledge only — no live Python tooling in the vault.
- `00_Raw/workbench/` is [[typescript|TypeScript]]/Node and does **not** fit cleanly into any tier — the RFC leaves this open.
- All 15 `02_System/` scripts follow [[ps-automation-spec]]: `$ErrorActionPreference`, `Try/Catch`, exit code 1 on failure.
- `run-maintenance.ps1` invokes child scripts via `pwsh -File`; the Tier-2→Tier-1 contract is `Add-Type` (in-process assembly load in PoShWiKi).

## Constraints

- Do not modify `run-maintenance.ps1` structure — it is the CI backbone and health score depends on it.
- Do not add `tier` as a mandatory YANP field yet — it would break the existing YANP auditor's 100% compliance baseline. Make it optional if you add it at all.
- The ADR note must reach `status: active` only after the open questions are answered with vault evidence, not inference.
- Vault health must remain 100/100 after any changes. Run `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1` to verify.

## Verification Tasks

Work through these in order; record your findings under `## Codex Findings` at the bottom of `01_Wiki/polyglot-adr-rfc.md`.

### 1. Tier Inventory Audit
- Confirm `00_Raw/vulture-mcp/` exists and contains Rust source. Check `Cargo.toml` for the crate name and confirm it is built as a binary (not a lib). Record the actual binary name.
- Check all `00_Raw/` subdirectories for any Python `.py` files, C# `.cs` files, or Rust `.rs` files the RFC inventory misses.
- Confirm `00_Raw/workbench/` is TypeScript (check `package.json`). Determine whether it should be Tier-3 (dynamic, rapid iteration) or needs a `Tier-1.5 — Typed JS` slot.

### 2. PoShWiKi Tier Classification
- Open `00_Raw/PoShWiKi/PoShWiKi.psm1` and locate where `Microsoft.Data.Sqlite` is loaded.
- Determine: is the PowerShell layer merely a thin shell over a .NET library, or does it contain substantive domain logic? This decides whether PoShWiKi is Tier-2 (PowerShell host) or Tier-1 (C#/.NET logic that happens to be invoked from PowerShell).
- The contract table in the RFC currently lists it under Tier-2. Correct or confirm with evidence.

### 3. YANP Auditor Extensibility
- Read `02_System/audit-yanp.ps1` and determine whether it already has hooks for validating custom frontmatter fields beyond `type` and filename casing.
- If not: record what change would be needed to add optional `tier` field validation.
- Recommend: Option A (Pester script) vs Option B (frontmatter field) based on the actual auditor structure.

### 4. Failure-Mode Compliance Spot-Check
- Pick two `02_System/` scripts at random. Verify they have `$ErrorActionPreference = 'Stop'` and `Try/Catch` blocks. Report pass/fail.
- Check `00_Raw/vulture-mcp/src/` for `unwrap()` or `expect()` calls in non-test code paths — these are implicit `panic!` and violate the Tier-0 failure contract. Report count.

## Deliverable

Create `01_Wiki/polyglot-platform-adr.md` with:
- `status: active`
- `type: permanent`
- `author: codex`
- The same tier table and contract table as the RFC, updated with your verified facts
- A `## Codex Verification` section listing what was confirmed vs. what was revised
- Cross-links to all existing notes in the References block (use the same list as the RFC)

Then:
1. Update `01_Wiki/polyglot-adr-rfc.md`: add `status: superseded` and a forward link to `[[polyglot-platform-adr]]`.
2. Add `[[polyglot-platform-adr]]` to `01_Wiki/dotnet-agent-integration.md` References (replacing the ADR gap note).
3. Add `[[polyglot-platform-adr]]` to `01_Wiki/community-polyglot-agent-platform.md` References and change that note's status to `active`.
4. Run `run-maintenance.ps1` and confirm 100/100 before committing.

## Evidence

- `01_Wiki/polyglot-adr-rfc.md` — the RFC this handoff is based on
- `01_Wiki/dotnet-agent-integration.md` — calls out the ADR gap explicitly
- `01_Wiki/community-polyglot-agent-platform.md` — the community synthesis that identified the problem
- `00_Raw/PoShWiKi/PoShWiKi.psm1` — PoShWiKi source (Tier-1 vs Tier-2 classification evidence)
- `00_Raw/vulture-mcp/` — Rust source (Tier-0 inventory confirmation)
- `02_System/audit-yanp.ps1` — YANP auditor (Option B extensibility check)
- `02_System/run-maintenance.ps1` — CI backbone (do not break)

## Next Decision

After verification, one open question may need an editorial call rather than an evidence check:

> **Does `00_Raw/workbench/` (TypeScript) belong in the tier model at all?**

It is currently the Codex tool-runner runtime, not a persistent vault service. It may be better classified as **development scaffolding** — outside the production tier model — rather than forcing it into Tier-3 alongside Python ML pipelines. This decision shapes whether the ADR table has four rows or five.

Record your recommendation in `## Codex Findings` before writing the final ADR note.

---
## References
- [[polyglot-adr-rfc]]
- [[dotnet-agent-integration]]
- [[community-polyglot-agent-platform]]
- [[inter-agent-handoff-protocol]]
- [[ps-automation-spec]]
- [[vault-audit-tool-spec]]
- [[workbench-codex-runner-handoff]]

