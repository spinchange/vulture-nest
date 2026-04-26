<#
.SYNOPSIS
    Seeds the PoShWiKi Pages table from repo-backed markdown snapshots.
.DESCRIPTION
    Loads checked-in PoShWiKi page exports from 02_System/poshwiki-pages and writes
    them into the active wiki.db so CI and fresh workspaces can rebuild the same
    session/activity context used by the dashboard.
.PARAMETER PageDirectory
    Optional override for the directory containing exported PoShWiKi page files.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/seed-poshwiki-pages.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$PageDirectory
)

$ErrorActionPreference = 'Stop'

try {
    $vaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiCliPath = Join-Path $vaultRoot '00_Raw/PoShWiKi/wiki.ps1'

    if (-not (Test-Path $wikiCliPath)) {
        throw "PoShWiKi CLI not found at $wikiCliPath"
    }

    if ([string]::IsNullOrWhiteSpace($PageDirectory)) {
        $PageDirectory = Join-Path $PSScriptRoot 'poshwiki-pages'
    }

    if (-not (Test-Path $PageDirectory)) {
        throw "Page directory not found: $PageDirectory"
    }

    $pageFiles = Get-ChildItem -Path $PageDirectory -Filter '*.md' | Sort-Object Name
    if ($pageFiles.Count -eq 0) {
        throw "No PoShWiKi page exports found in $PageDirectory"
    }

    foreach ($pageFile in $pageFiles) {
        Write-Host "Seeding PoShWiKi page: $($pageFile.BaseName)" -ForegroundColor Cyan
        & pwsh -NoProfile -File $wikiCliPath set $pageFile.BaseName $pageFile.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to seed PoShWiKi page from $($pageFile.FullName)"
        }
    }

    Write-Host "Seeded $($pageFiles.Count) PoShWiKi pages." -ForegroundColor Green
    [PSCustomObject]@{
        PageDirectory = $PageDirectory
        PageCount     = $pageFiles.Count
    }
} catch {
    Write-Error "seed-poshwiki-pages.ps1 failed: $_"
    exit 1
}
