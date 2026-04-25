<#
.SYNOPSIS
    Master Vault Maintenance
.DESCRIPTION
    The "Knowledge CI/CD" master script. Runs compliance audits, orphan checks, and updates the Tool Registry in one pass.
.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1
#>

Write-Host "--- Starting Vault Maintenance ---" -ForegroundColor Cyan

Write-Host "`n[1/3] Running YANP Compliance Audit..." -ForegroundColor Yellow
powershell.exe -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1

Write-Host "`n[2/4] Checking for Orphaned Notes..." -ForegroundColor Yellow
powershell.exe -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1

Write-Host "`n[3/4] Checking for Broken Links..." -ForegroundColor Yellow
powershell.exe -ExecutionPolicy Bypass -File 02_System/check-broken-links.ps1

Write-Host "`n[4/4] Updating Tool Registry..." -ForegroundColor Yellow
powershell.exe -ExecutionPolicy Bypass -File 02_System/generate-tool-registry.ps1

Write-Host "`n--- Maintenance Complete! ---" -ForegroundColor Green
