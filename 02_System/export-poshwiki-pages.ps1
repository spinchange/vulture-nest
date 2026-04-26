<#
.SYNOPSIS
    Exports PoShWiKi pages from the active SQLite database into repo-backed markdown snapshots.
.DESCRIPTION
    Reads pages from the active PoShWiKi database and writes each page to
    02_System/poshwiki-pages so CI and GitHub Pages can rebuild dashboard/session
    state from checked-in artifacts.
.PARAMETER OutputDirectory
    Optional override for the export directory. Defaults to 02_System/poshwiki-pages.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/export-poshwiki-pages.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'

try {
    $vaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiModulePath = Join-Path $vaultRoot '00_Raw/PoShWiKi/PoShWiKi.psd1'

    if (-not (Test-Path $wikiModulePath)) {
        throw "PoShWiKi module not found at $wikiModulePath"
    }

    if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
        $OutputDirectory = Join-Path $PSScriptRoot 'poshwiki-pages'
    }

    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    Import-Module $wikiModulePath -Force

    $pages = @(Get-WikiPageList)
    if ($pages.Count -eq 0) {
        throw "No PoShWiKi pages were found in the active database."
    }

    foreach ($page in $pages) {
        $pageTitle = [string]$page.Title
        $pageRecord = Get-WikiPage -Title $pageTitle
        $targetPath = Join-Path $OutputDirectory "$pageTitle.md"
        Set-Content -Path $targetPath -Value $pageRecord.Content -Encoding utf8
        Write-Host "Exported PoShWiKi page: $pageTitle" -ForegroundColor Cyan
    }

    Write-Host "Exported $($pages.Count) PoShWiKi pages to $OutputDirectory." -ForegroundColor Green
    [PSCustomObject]@{
        OutputDirectory = $OutputDirectory
        PageCount       = $pages.Count
    }
} catch {
    Write-Error "export-poshwiki-pages.ps1 failed: $_"
    exit 1
}
