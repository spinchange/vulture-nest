<#
.SYNOPSIS
    Broken Link Auditor
.DESCRIPTION
    Scans all markdown files in the vault to find [[Wikilinks]] that point to non-existent notes.
.OUTPUTS
    A table of source files and their broken link targets.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/check-broken-links.ps1
#>

$VaultRoot = Split-Path $PSScriptRoot -Parent
$wikiPath = Join-Path $VaultRoot "01_Wiki"
$systemPath = Join-Path $VaultRoot "02_System"

# 1. Get all valid note names (BaseNames)
$validNotes = (Get-ChildItem -Path $wikiPath, $systemPath, $VaultRoot -Filter "*.md").BaseName | Select-Object -Unique


# 2. Scan for links
$brokenLinks = New-Object System.Collections.Generic.List[PSCustomObject]

$files = Get-ChildItem -Path $wikiPath, $systemPath -Filter "*.md"
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    # Regex for [[NoteName]] or [[NoteName|Alias]]
    $matches = [regex]::Matches($content, '\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')

    foreach ($match in $matches) {
        $target = $match.Groups[1].Value.Trim()
        
        # Check if the target exists in our valid notes list
        if ($validNotes -notcontains $target) {
            $brokenLinks.Add([PSCustomObject]@{
                SourceFile = $file.Name
                BrokenLink = "[[$target]]"
            })
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Host "`nFound $($brokenLinks.Count) broken links:" -ForegroundColor Red
    $brokenLinks | Format-Table -AutoSize
} else {
    Write-Host "`nNo broken links found. Graph integrity is 100%." -ForegroundColor Green
}
