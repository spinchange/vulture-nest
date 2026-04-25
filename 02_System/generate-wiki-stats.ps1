<#
.SYNOPSIS
    Vault Stats Generator
.DESCRIPTION
    Calculates high-level metrics for the vault, including note counts, link density, and health indicators.
.OUTPUTS
    A summary table of vault statistics.
.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File 02_System/generate-wiki-stats.ps1
#>

$wikiPath = "01_Wiki"
$systemPath = "02_System"

# 1. Basic Counts
$allMdFiles = Get-ChildItem -Path $wikiPath, $systemPath -Filter "*.md"
$wikiNotes = Get-ChildItem -Path $wikiPath -Filter "*.md"
$noteCount = $wikiNotes.Count

# 2. Link Counting
$totalLinks = 0
$allMdFiles | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $matches = [regex]::Matches($content, '\[\[')
    $totalLinks += $matches.Count
}

# 3. Connectivity (Orphans)
# Reusing logic from orphan-check.ps1
$allNoteNames = $wikiNotes.BaseName
$allContent = $allMdFiles | Get-Content -Raw | Out-String
$orphanCount = 0
foreach ($note in $allNoteNames) {
    $pattern = "\[\[" + [regex]::Escape($note) + "(\]|\|)"
    if ($allContent -notmatch $pattern) { $orphanCount++ }
}

# 4. Integrity (Broken Links)
$brokenLinkCount = 0
$validNoteNames = (Get-ChildItem -Path . , $wikiPath, $systemPath -Filter "*.md").BaseName | Select-Object -Unique
foreach ($file in $allMdFiles) {
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, '\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')
    foreach ($match in $matches) {
        if ($validNoteNames -notcontains $match.Groups[1].Value.Trim()) { $brokenLinkCount++ }
    }
}

# 5. Calculation
$linkDensity = [math]::Round($totalLinks / $noteCount, 2)
$healthScore = [math]::Max(0, 100 - ($orphanCount * 2) - ($brokenLinkCount * 5))

# 6. Output
Write-Host "`n=== VAULT STATISTICS: $(Get-Date -Format 'yyyy-MM-dd') ===" -ForegroundColor Cyan
[PSCustomObject]@{
    "Total Wiki Notes"   = $noteCount
    "Total Wikilinks"    = $totalLinks
    "Link Density"       = "$linkDensity links/note"
    "Orphaned Notes"     = $orphanCount
    "Broken Links"       = $brokenLinkCount
    "Vault Health Score" = "$healthScore%"
} | Format-List

Write-Host "--- Stats Complete ---" -ForegroundColor Green
