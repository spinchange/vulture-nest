<#
.SYNOPSIS
    Master Vault Maintenance
.DESCRIPTION
    The "Knowledge CI/CD" master script. Runs compliance audits, orphan checks, link checks, registry updates, generates the visual dashboard, and compiles the static portal.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

    function Invoke-MaintenanceStep {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Label,

            [Parameter(Mandatory = $true)]
            [string]$ScriptName,

            [switch]$Optional
        )

        $scriptPath = Join-Path $PSScriptRoot $ScriptName
        Write-Host $Label -ForegroundColor Yellow
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $scriptPath
        if ($LASTEXITCODE -ne 0) {
            if ($Optional) {
                Write-Warning "Optional step skipped or failed: $ScriptName (code $LASTEXITCODE)"
            } else {
                throw "Maintenance step failed: $ScriptName (code $LASTEXITCODE)"
            }
        }
    }

    Write-Host "--- Starting Vault Maintenance ---" -ForegroundColor Cyan

    Invoke-MaintenanceStep -Label "`n[1/10] Checking MCP Server Health..." -ScriptName 'check-mcp-health.ps1'

    Invoke-MaintenanceStep -Label "`n[2/10] Running YANP Compliance Audit..." -ScriptName 'audit-yanp.ps1'

    Invoke-MaintenanceStep -Label "`n[3/10] Checking for Orphaned Notes..." -ScriptName 'orphan-check.ps1'

    Invoke-MaintenanceStep -Label "`n[4/10] Updating Tool Registry..." -ScriptName 'generate-tool-registry.ps1'

    Invoke-MaintenanceStep -Label "`n[5/10] Checking for Broken Links..." -ScriptName 'check-broken-links.ps1'

    Invoke-MaintenanceStep -Label "`n[6/10] Exporting PoShWiKi Page Snapshots..." -ScriptName 'export-poshwiki-pages.ps1'

    Invoke-MaintenanceStep -Label "`n[7/10] Generating Visual Dashboard..." -ScriptName 'generate-dashboard.ps1'

    Invoke-MaintenanceStep -Label "`n[8/10] Compiling Vulture Portal..." -ScriptName 'generate-wiki.ps1'

    Invoke-MaintenanceStep -Label "`n[9/10] Checking Tier-2 Compliance..." -ScriptName 'test-tier-compliance.ps1'

    Invoke-MaintenanceStep -Label "`n[10/10] Syncing Note Embeddings (Gemini)..." -ScriptName 'sync-embeddings.ps1' -Optional

    Write-Host "`n--- Maintenance Complete! ---" -ForegroundColor Green
} catch {
    Write-Error "run-maintenance.ps1 failed: $_"
    exit 1
}
