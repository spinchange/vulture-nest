<#
.SYNOPSIS
    Orphan Note Checker
.DESCRIPTION
    Scans for markdown files in 01_Wiki that have no incoming wikilinks from other notes in the vault.
.INPUTS
    None
.OUTPUTS
    A list of orphaned notes.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1
#>
$ErrorActionPreference = 'Stop'

try {
    $VaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiPath = Join-Path $VaultRoot "01_Wiki"
    $systemPath = Join-Path $VaultRoot "02_System"
    $wikiFiles = Get-ChildItem -Path $wikiPath -Filter *.md
    $allNotes = $wikiFiles | Select-Object -ExpandProperty BaseName
    $allContent = Get-ChildItem -Path $wikiPath, $systemPath -Filter *.md | Get-Content -Raw | Out-String

    $orphans = foreach ($note in $allNotes) {
        $pattern = "\[\[" + [regex]::Escape($note) + "(\]|\|)"
        if ($allContent -notmatch $pattern) {
            $note
        }
    }

    if ($orphans) {
        Write-Host "Orphaned Notes found:"
        $orphans | ForEach-Object { Write-Host " - $_" }
    } else {
        Write-Host "No orphaned notes found."
    }
} catch {
    Write-Error "orphan-check.ps1 failed: $_"
    exit 1
}
