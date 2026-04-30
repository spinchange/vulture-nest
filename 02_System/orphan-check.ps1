<#
.SYNOPSIS
    Orphan Note Checker
.DESCRIPTION
    Scans markdown notes in 01_Wiki recursively and reports notes with no incoming wikilinks from other vault files.
.INPUTS
    None
.OUTPUTS
    A table of orphaned notes with relative path and note metadata.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1
#>
$ErrorActionPreference = 'Stop'

try {
    $VaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiPath = Join-Path $VaultRoot "01_Wiki"
    $systemPath = Join-Path $VaultRoot "02_System"
    $rootMarkdownFiles = Get-ChildItem -Path $VaultRoot -Filter "*.md" -File -ErrorAction SilentlyContinue
    $wikiFiles = Get-ChildItem -Path $wikiPath -Filter "*.md" -Recurse -File | Sort-Object FullName
    $sourceFiles = @(
        $wikiFiles
        (Get-ChildItem -Path $systemPath -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue)
        $rootMarkdownFiles
    ) | Sort-Object FullName -Unique
    $linkPattern = '(?<!`)\[\[([^\]|]+)(?:\|([^\]]+))?\]\]'

    function Get-ScalarValue {
        param([string]$Value)

        if ($null -eq $Value) { return $null }
        $trimmed = $Value.Trim()
        if (
            ($trimmed.StartsWith("'") -and $trimmed.EndsWith("'")) -or
            ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"'))
        ) {
            return $trimmed.Substring(1, $trimmed.Length - 2)
        }
        return $trimmed
    }

    function Convert-InlineList {
        param([string]$Value)

        $trimmed = $Value.Trim()
        if (-not ($trimmed.StartsWith('[') -and $trimmed.EndsWith(']'))) {
            throw "Invalid inline list syntax."
        }

        $inner = $trimmed.Substring(1, $trimmed.Length - 2).Trim()
        if ([string]::IsNullOrWhiteSpace($inner)) {
            return @()
        }

        return ,@(
            $inner.Split(',') |
            ForEach-Object { Get-ScalarValue $_ } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        )
    }

    function Get-FrontmatterMap {
        param([string]$Content)

        $lines = $Content -split "`r?`n"
        if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') {
            return $null
        }

        $frontmatter = [ordered]@{}
        $i = 1
        while ($i -lt $lines.Count) {
            $line = $lines[$i]
            if ($line.Trim() -eq '---') {
                return $frontmatter
            }

            if ([string]::IsNullOrWhiteSpace($line)) {
                $i++
                continue
            }

            if ($line -notmatch '^(?<key>[A-Za-z0-9_-]+):\s*(?<value>.*)$') {
                throw "Invalid frontmatter line: $line"
            }

            $key = $matches['key']
            $value = $matches['value']
            if ($frontmatter.Contains($key)) {
                throw "Duplicate frontmatter key: $key"
            }

            if ([string]::IsNullOrWhiteSpace($value)) {
                $items = New-Object System.Collections.Generic.List[string]
                $j = $i + 1
                while ($j -lt $lines.Count) {
                    $nextLine = $lines[$j]
                    if ($nextLine.Trim() -eq '---') { break }
                    if ($nextLine -match '^\s*-\s*(.+?)\s*$') {
                        $items.Add((Get-ScalarValue $matches[1]))
                        $j++
                        continue
                    }
                    if ([string]::IsNullOrWhiteSpace($nextLine)) {
                        $j++
                        continue
                    }
                    break
                }
                $frontmatter[$key] = ,@($items)
                $i = $j - 1
            } elseif ($value.Trim().StartsWith('[') -and $value.Trim().EndsWith(']')) {
                $frontmatter[$key] = Convert-InlineList $value
            } else {
                $frontmatter[$key] = Get-ScalarValue $value
            }

            $i++
        }

        throw "Frontmatter block was not closed."
    }

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

    function Get-RelativePath {
        param([string]$Path)

        return $Path.Substring($VaultRoot.Length + 1)
    }

    $notesByKey = @{}
    foreach ($file in $wikiFiles) {
        $frontmatter = $null
        try {
            $frontmatter = Get-FrontmatterMap (Get-Content $file.FullName -Raw)
        } catch {
            $frontmatter = $null
        }

        $note = [PSCustomObject]@{
            Name         = $file.BaseName
            RelativePath = Get-RelativePath $file.FullName
            Type         = if ($frontmatter -and $frontmatter.Contains('type')) { [string]$frontmatter['type'] } else { '' }
            Status       = if ($frontmatter -and $frontmatter.Contains('status')) { [string]$frontmatter['status'] } else { '' }
            Aliases      = if ($frontmatter -and $frontmatter.Contains('aliases')) { @($frontmatter['aliases']) } else { @() }
            InboundCount = 0
        }

        $keys = New-Object System.Collections.Generic.List[string]
        $keys.Add($note.Name)
        foreach ($alias in $note.Aliases) {
            if (-not [string]::IsNullOrWhiteSpace($alias)) {
                $keys.Add([System.IO.Path]::GetFileNameWithoutExtension($alias.Trim()))
            }
        }

        foreach ($key in ($keys | Sort-Object -Unique)) {
            $notesByKey[$key.ToLowerInvariant()] = $note
        }
    }

    foreach ($sourceFile in $sourceFiles) {
        $lines = Get-Content $sourceFile.FullName
        $sanitizedLines = Remove-CodeFences $lines
        $sourceRelativePath = Get-RelativePath $sourceFile.FullName

        $referencedInFile = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        for ($i = 0; $i -lt $sanitizedLines.Count; $i++) {
            $line = $sanitizedLines[$i]
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $matches = [regex]::Matches($line, $linkPattern)
            foreach ($match in $matches) {
                $target = Normalize-LinkTarget $match.Groups[1].Value
                if ($null -eq $target) { continue }

                $targetKey = $target.ToLowerInvariant()
                if (-not $notesByKey.ContainsKey($targetKey)) { continue }

                $note = $notesByKey[$targetKey]
                if ($note.RelativePath -ieq $sourceRelativePath) { continue }

                [void]$referencedInFile.Add($note.RelativePath)
            }
        }

        foreach ($relativePath in $referencedInFile) {
            $targetNote = $notesByKey.Values | Where-Object { $_.RelativePath -ieq $relativePath } | Select-Object -First 1
            if ($null -ne $targetNote) {
                $targetNote.InboundCount++
            }
        }
    }

    $orphans = $notesByKey.Values |
        Sort-Object RelativePath -Unique |
        Where-Object { $_.InboundCount -eq 0 } |
        Sort-Object RelativePath

    if ($orphans.Count -gt 0) {
        Write-Host "`nFound $($orphans.Count) orphan notes:" -ForegroundColor Yellow
        $orphans |
            Select-Object RelativePath, Type, Status, InboundCount |
            Format-Table -Wrap -AutoSize

        Write-Host "`nSummary: $($wikiFiles.Count) notes scanned, $($orphans.Count) orphans found." -ForegroundColor Yellow
    } else {
        Write-Host "`nNo orphaned notes found." -ForegroundColor Green
    }
} catch {
    Write-Error "orphan-check.ps1 failed: $_"
    exit 1
}
