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
            [string]$ScriptName
        )

        $scriptPath = Join-Path $PSScriptRoot $ScriptName
        Write-Host $Label -ForegroundColor Yellow
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $scriptPath
        if ($LASTEXITCODE -ne 0) {
            throw "Maintenance step failed: $ScriptName (code $LASTEXITCODE)"
        }
    }

    Write-Host "--- Starting Vault Maintenance ---" -ForegroundColor Cyan

    Invoke-MaintenanceStep -Label "`n[1/7] Running YANP Compliance Audit..." -ScriptName 'audit-yanp.ps1'

    Invoke-MaintenanceStep -Label "`n[2/7] Checking for Orphaned Notes..." -ScriptName 'orphan-check.ps1'

    Invoke-MaintenanceStep -Label "`n[3/7] Updating Tool Registry..." -ScriptName 'generate-tool-registry.ps1'

    Invoke-MaintenanceStep -Label "`n[4/7] Checking for Broken Links..." -ScriptName 'check-broken-links.ps1'

    Invoke-MaintenanceStep -Label "`n[5/7] Generating Visual Dashboard..." -ScriptName 'generate-dashboard.ps1'

    Invoke-MaintenanceStep -Label "`n[6/7] Compiling Vulture Portal..." -ScriptName 'generate-wiki.ps1'

    Invoke-MaintenanceStep -Label "`n[7/7] Checking Tier-2 Compliance..." -ScriptName 'test-tier-compliance.ps1'

    Write-Host "`n--- Maintenance Complete! ---" -ForegroundColor Green
} catch {
    Write-Error "run-maintenance.ps1 failed: $_"
    exit 1
}
