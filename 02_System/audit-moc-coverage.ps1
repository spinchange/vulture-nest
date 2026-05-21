# audit-moc-coverage.ps1
# Finds notes in 01_Wiki that are not linked in any *-moc.md file.

$ErrorActionPreference = 'Stop'

try {
    $wikiPath = Join-Path (Split-Path $PSScriptRoot -Parent) "01_Wiki"
    $systemPath = Join-Path (Split-Path $PSScriptRoot -Parent) "02_System"
    $mocs = Get-ChildItem -Path $wikiPath -Filter "*-moc.md"
    $index = Get-Item -Path (Join-Path $wikiPath "index.md")
    $sysIndex = Get-Item -Path (Join-Path $systemPath "system-index.md")
    $allMocs = $mocs + $index + $sysIndex
    $allNotes = Get-ChildItem -Path $wikiPath -Filter "*.md" | Where-Object { $_.Name -notmatch "-moc.md|index.md" }

    $mocLinks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($moc in $allMocs) {
        $content = Get-Content $moc.FullName -Raw
        $matches = [regex]::Matches($content, '\[\[([^\]|]+)(?:\|([^\]]+))?\]\]')
        foreach ($match in $matches) {
            $target = $match.Groups[1].Value.Trim()
            [void]$mocLinks.Add($target)
        }
    }

    $floating = $allNotes | Where-Object { -not $mocLinks.Contains($_.BaseName) } | Sort-Object Name

    Write-Host "Found $($floating.Count) notes not linked in any MOC:`n" -ForegroundColor Yellow
    $floating | Select-Object Name, BaseName | Format-Table -AutoSize
} catch {
    Write-Error "audit-moc-coverage.ps1 failed: $_"
    exit 1
}
