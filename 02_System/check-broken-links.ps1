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
$ErrorActionPreference = 'Stop'

try {
    $VaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiPath = Join-Path $VaultRoot "01_Wiki"
    $systemPath = Join-Path $VaultRoot "02_System"

    function Normalize-LinkTarget {
        param([string]$Target)

        $normalized = $Target.Trim()
        if ($normalized -match '[{}]') { return $null }
        if ($normalized.Contains('#')) { $normalized = $normalized.Split('#', 2)[0] }
        $normalized = [System.IO.Path]::GetFileNameWithoutExtension($normalized)
        if ([string]::IsNullOrWhiteSpace($normalized)) { return $null }
        return $normalized
    }

    # 1. Get all valid note names (BaseNames)
    $validNotes = @(
        (Get-ChildItem -Path $wikiPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).BaseName
        (Get-ChildItem -Path $systemPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).BaseName
        (Get-ChildItem -Path $VaultRoot -Filter "*.md" -ErrorAction SilentlyContinue).BaseName
    ) | Select-Object -Unique


    # 2. Scan for links
    $brokenLinks = New-Object System.Collections.Generic.List[PSCustomObject]

    $files = Get-ChildItem -Path $wikiPath, $systemPath -Filter "*.md" -Recurse
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        $content = [regex]::Replace($content, '(?s)```.*?```', '')
        # Regex for [[NoteName]] or [[NoteName|Alias]]
        $matches = [regex]::Matches($content, '(?<!`)\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')

        foreach ($match in $matches) {
            $target = Normalize-LinkTarget $match.Groups[1].Value
            if ($null -eq $target) { continue }

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
} catch {
    Write-Error "check-broken-links.ps1 failed: $_"
    exit 1
}
