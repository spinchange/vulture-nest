<#
.SYNOPSIS
    YANP Compliance Auditor
.DESCRIPTION
    Scans the 01_Wiki folder to ensure all notes follow the YANP protocol (lowercase kebab-case filenames and valid YAML frontmatter 'type').
.INPUTS
    None
.OUTPUTS
    A table of files and their compliance status.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1
#>
# YANP Compliance Auditor
# This script scans the 01_Wiki folder to ensure all notes follow the YANP protocol.
$ErrorActionPreference = 'Stop'

try {
    $wikiPath = Join-Path (Split-Path $PSScriptRoot -Parent) "01_Wiki"
    $notes = Get-ChildItem -Path $wikiPath -Filter "*.md"

    $report = foreach ($note in $notes) {
        $content = Get-Content $note.FullName -Raw
        $hasType = $content -match "type: (permanent|literature|fleeting|community)"
        $isKebab = $note.Name -match "^[a-z0-9-]+.md$"

        [PSCustomObject]@{
            Name       = $note.Name
            ValidType  = $hasType
            KebabCase  = $isKebab
            Compliant  = ($hasType -and $isKebab)
        }
    }

    $report | Format-Table -AutoSize

    $nonCompliant = $report | Where-Object { $_.Compliant -eq $false }
    if ($nonCompliant) {
        Write-Host "`nFound $($nonCompliant.Count) non-compliant notes." -ForegroundColor Red
    } else {
        Write-Host "`nAll notes are YANP compliant!" -ForegroundColor Green
    }
} catch {
    Write-Error "audit-yanp.ps1 failed: $_"
    exit 1
}
