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

Invoke-MaintenanceStep -Label "`n[1/6] Running YANP Compliance Audit..." -ScriptName 'audit-yanp.ps1'

Invoke-MaintenanceStep -Label "`n[2/6] Checking for Orphaned Notes..." -ScriptName 'orphan-check.ps1'

Invoke-MaintenanceStep -Label "`n[3/6] Updating Tool Registry..." -ScriptName 'generate-tool-registry.ps1'

Invoke-MaintenanceStep -Label "`n[4/6] Checking for Broken Links..." -ScriptName 'check-broken-links.ps1'

Invoke-MaintenanceStep -Label "`n[5/6] Generating Visual Dashboard..." -ScriptName 'generate-dashboard.ps1'

Invoke-MaintenanceStep -Label "`n[6/6] Compiling Vulture Portal..." -ScriptName 'generate-wiki.ps1'

Write-Host "`n--- Maintenance Complete! ---" -ForegroundColor Green
