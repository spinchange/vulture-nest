<#
.SYNOPSIS
    Tier-2 compliance auditor for PowerShell automation scripts.
.DESCRIPTION
    Scans Tier-2 PowerShell automation scripts in 02_System and 04_Experiments
    and checks whether each script sets $ErrorActionPreference = 'Stop' and
    contains a try/catch block.
.OUTPUTS
    One PSCustomObject row per script with compliance fields.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/test-tier-compliance.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

try {
    $vaultRoot = Split-Path -Parent $PSScriptRoot
    $scanRoots = @(
        [PSCustomObject]@{
            Scope = "02_System"
            Path = $PSScriptRoot
            Recurse = $false
        },
        [PSCustomObject]@{
            Scope = "04_Experiments"
            Path = Join-Path $vaultRoot "04_Experiments"
            Recurse = $true
        }
    )

    $scripts = foreach ($scanRoot in $scanRoots) {
        if (-not (Test-Path $scanRoot.Path)) {
            continue
        }

        Get-ChildItem -Path $scanRoot.Path -Filter '*.ps1' -File -Recurse:$scanRoot.Recurse |
            Sort-Object FullName |
            ForEach-Object {
                [PSCustomObject]@{
                    Scope = $scanRoot.Scope
                    File = $_
                }
            }
    }

    $report = foreach ($entry in $scripts) {
        $script = $entry.File
        $content = Get-Content -Path $script.FullName -Raw
        $hasEAP = $content -match '(?m)^\s*\$ErrorActionPreference\s*=\s*[''"]Stop[''"]'
        $hasTryCatch = $content -match "(?is)\btry\s*\{.*\}\s*catch\s*\{"
        $relativePath = [System.IO.Path]::GetRelativePath($vaultRoot, $script.FullName)

        [PSCustomObject]@{
            Scope       = $entry.Scope
            RelativePath = $relativePath
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
