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
    powershell.exe -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1
#>
$wikiFiles = Get-ChildItem -Path 01_Wiki -Filter *.md
$allNotes = $wikiFiles | Select-Object -ExpandProperty BaseName
$allContent = Get-ChildItem -Path 01_Wiki, 02_System -Filter *.md | Get-Content -Raw | Out-String

$orphans = foreach ($note in $allNotes) {
    # Escape for regex: [ and ]
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
