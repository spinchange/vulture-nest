<#
.SYNOPSIS
    Tier-2 compliance auditor for PowerShell automation scripts.
.DESCRIPTION
    Scans all 02_System/*.ps1 files and checks whether each script sets
    $ErrorActionPreference = 'Stop' and contains a try/catch block.
.OUTPUTS
    One PSCustomObject row per script with compliance fields.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/test-tier-compliance.ps1
#>

$ErrorActionPreference = 'Stop'

try {
    $scripts = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' | Sort-Object Name

    $report = foreach ($script in $scripts) {
        $content = Get-Content -Path $script.FullName -Raw
        $hasEAP = $content -match '(?m)^\s*\$ErrorActionPreference\s*=\s*[''"]Stop[''"]'
        $hasTryCatch = $content -match "(?is)\btry\s*\{.*\}\s*catch\s*\{"

        [PSCustomObject]@{
            Script      = $script.Name
            HasEAP      = $hasEAP
            HasTryCatch = $hasTryCatch
            Compliant   = ($hasEAP -and $hasTryCatch)
        }
    }

    $report

    $nonCompliant = @($report | Where-Object { -not $_.Compliant })
    Write-Host "`nChecked $($report.Count) Tier-2 scripts. Non-compliant: $($nonCompliant.Count)." -ForegroundColor $(if ($nonCompliant.Count -eq 0) { 'Green' } else { 'Red' })

    if ($nonCompliant.Count -gt 0) {
        exit 1
    }
} catch {
    Write-Error "test-tier-compliance.ps1 failed: $_"
    exit 1
}
