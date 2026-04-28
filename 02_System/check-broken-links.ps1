<#
.SYNOPSIS
    Broken Link Auditor
.DESCRIPTION
    Scans markdown files in the vault and reports unresolved wikilinks with source path and line number.
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
    $linkPattern = '(?<!`)\[\[([^\]|]+)(?:\|([^\]]+))?\]\]'

    function Normalize-LinkTarget {
        param([string]$Target)

        $normalized = $Target.Trim()
        if ($normalized -match '[{}]') { return $null }
        if ($normalized.Contains('#')) { $normalized = $normalized.Split('#', 2)[0] }
        $extension = [System.IO.Path]::GetExtension($normalized)
        if ($extension -and $extension -ne '.md') { return $null }
        $normalized = [System.IO.Path]::GetFileNameWithoutExtension($normalized)
        if ([string]::IsNullOrWhiteSpace($normalized)) { return $null }
        return $normalized
    }

    function Get-RelativePath {
        param([string]$Path)

        return $Path.Substring($VaultRoot.Length + 1)
    }

    function Remove-CodeFences {
        param([string[]]$Lines)

        $sanitized = New-Object System.Collections.Generic.List[string]
        $inFence = $false

        foreach ($line in $Lines) {
            if ($line -match '^\s*```') {
                $inFence = -not $inFence
                $sanitized.Add('')
                continue
            }

            if ($inFence) {
                $sanitized.Add('')
            } else {
                $sanitized.Add($line)
            }
        }

        return ,$sanitized.ToArray()
    }

    $validNotes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    @(
        (Get-ChildItem -Path $wikiPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).BaseName
        (Get-ChildItem -Path $systemPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).BaseName
        (Get-ChildItem -Path $VaultRoot -Filter "*.md" -ErrorAction SilentlyContinue).BaseName
    ) | Select-Object -Unique | ForEach-Object {
        [void]$validNotes.Add($_)
    }

    $files = Get-ChildItem -Path $wikiPath, $systemPath -Filter "*.md" -Recurse
    $brokenLinks = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($file in $files) {
        $lines = Get-Content $file.FullName
        $sanitizedLines = Remove-CodeFences $lines

        for ($i = 0; $i -lt $sanitizedLines.Count; $i++) {
            $line = $sanitizedLines[$i]
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $matches = [regex]::Matches($line, $linkPattern)
            foreach ($match in $matches) {
                $target = Normalize-LinkTarget $match.Groups[1].Value
                if ($null -eq $target) { continue }

                if (-not $validNotes.Contains($target)) {
                    $brokenLinks.Add([PSCustomObject]@{
                        SourcePath   = Get-RelativePath $file.FullName
                        Line         = $i + 1
                        BrokenLink   = $match.Value
                        Target       = $target
                        LinePreview  = $lines[$i].Trim()
                    })
                }
            }
        }
    }

    if ($brokenLinks.Count -gt 0) {
        Write-Host "`nFound $($brokenLinks.Count) broken links:" -ForegroundColor Red
        $brokenLinks |
            Sort-Object SourcePath, Line, BrokenLink |
            Format-Table SourcePath, Line, BrokenLink, Target, LinePreview -Wrap -AutoSize

        $sourceCount = ($brokenLinks | Select-Object -ExpandProperty SourcePath -Unique).Count
        $targetCount = ($brokenLinks | Select-Object -ExpandProperty Target -Unique).Count
        Write-Host "`nSummary: $sourceCount files reference $targetCount missing targets." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "`nNo broken links found. Graph integrity is 100%." -ForegroundColor Green
    }
} catch {
    Write-Error "check-broken-links.ps1 failed: $_"
    exit 1
}
