<#
.SYNOPSIS
    YANP Compliance Auditor
.DESCRIPTION
    Scans 01_Wiki recursively and validates note filenames plus opening YAML frontmatter structure.
.INPUTS
    None
.OUTPUTS
    A table of files and their compliance status.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1
#>

$ErrorActionPreference = 'Stop'

try {
    $wikiPath = Join-Path (Split-Path $PSScriptRoot -Parent) "01_Wiki"
    $notes = Get-ChildItem -Path $wikiPath -Filter "*.md" -Recurse | Sort-Object FullName
    $allowedTypes = @('community', 'community-report', 'experiment', 'fleeting', 'handoff', 'literature', 'permanent', 'spec')
    $allowedStatuses = @('active', 'archived', 'draft', 'partially-resolved', 'superseded')
    $requiredFields = @('title', 'author', 'date', 'status', 'type')

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
                # Peek ahead to determine block type: list (- item) or nested mapping (key: val)
                $peekIdx = $i + 1
                while ($peekIdx -lt $lines.Count -and [string]::IsNullOrWhiteSpace($lines[$peekIdx])) { $peekIdx++ }
                $isNestedMapping = $peekIdx -lt $lines.Count -and $lines[$peekIdx] -match '^\s+[A-Za-z0-9_-]+:\s*'

                if ($isNestedMapping) {
                    # Consume all indented lines as an opaque nested block
                    $j = $i + 1
                    $nestedLines = New-Object System.Collections.Generic.List[string]
                    while ($j -lt $lines.Count) {
                        $nextLine = $lines[$j]
                        if ($nextLine.Trim() -eq '---') { break }
                        if ($nextLine -match '^\s' -or [string]::IsNullOrWhiteSpace($nextLine)) {
                            $nestedLines.Add($nextLine)
                            $j++
                            continue
                        }
                        break
                    }
                    $frontmatter[$key] = $nestedLines -join "`n"
                    $i = $j - 1
                } else {
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
                }
            } elseif ($value.Trim().StartsWith('[') -and $value.Trim().EndsWith(']')) {
                $frontmatter[$key] = Convert-InlineList $value
            } else {
                $frontmatter[$key] = Get-ScalarValue $value
            }

            $i++
        }

        throw "Frontmatter block was not closed."
    }

    $report = foreach ($note in $notes) {
        $content = Get-Content $note.FullName -Raw
        $isKebab = $note.Name -match "^[a-z0-9-]+.md$"
        $frontmatter = $null
        $errors = New-Object System.Collections.Generic.List[string]

        try {
            $frontmatter = Get-FrontmatterMap $content
            if ($null -eq $frontmatter) {
                $errors.Add('Missing opening YAML frontmatter block.')
            }
        } catch {
            $errors.Add($_.Exception.Message)
        }

        if ($frontmatter) {
            foreach ($field in $requiredFields) {
                if (-not $frontmatter.Contains($field) -or [string]::IsNullOrWhiteSpace([string]$frontmatter[$field])) {
                    $errors.Add("Missing required field: $field")
                }
            }

            if ($frontmatter.Contains('type') -and $allowedTypes -notcontains [string]$frontmatter['type']) {
                $errors.Add("Invalid type: $($frontmatter['type'])")
            }

            if ($frontmatter.Contains('status') -and $allowedStatuses -notcontains [string]$frontmatter['status']) {
                $errors.Add("Invalid status: $($frontmatter['status'])")
            }

            if ($frontmatter.Contains('date')) {
                $dateValue = [string]$frontmatter['date']
                if ($dateValue -notmatch '^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z)?$') {
                    $errors.Add("Invalid date format: $dateValue")
                }
            }
        }

        if (-not $isKebab) {
            $errors.Add('Filename is not lowercase kebab-case.')
        }

        [PSCustomObject]@{
            Name       = $note.Name
            Path       = $note.FullName.Substring($wikiPath.Length + 1)
            Title      = if ($frontmatter) { [string]$frontmatter['title'] } else { $null }
            Type       = if ($frontmatter) { [string]$frontmatter['type'] } else { $null }
            Status     = if ($frontmatter) { [string]$frontmatter['status'] } else { $null }
            Date       = if ($frontmatter) { [string]$frontmatter['date'] } else { $null }
            KebabCase  = $isKebab
            Compliant  = ($errors.Count -eq 0)
            Errors     = ($errors -join '; ')
            Aliases    = if ($frontmatter -and $frontmatter.Contains('aliases')) { @($frontmatter['aliases']) } else { @() }
            Warnings   = ''
        }
    }

    $titleMap = @{}
    $aliasMap = @{}
    foreach ($row in $report) {
        if (-not [string]::IsNullOrWhiteSpace($row.Title)) {
            $titleKey = $row.Title.ToLowerInvariant()
            if (-not $titleMap.ContainsKey($titleKey)) {
                $titleMap[$titleKey] = New-Object System.Collections.Generic.List[string]
            }
            $titleMap[$titleKey].Add($row.Path)
        }

        foreach ($alias in $row.Aliases) {
            if ([string]::IsNullOrWhiteSpace($alias)) { continue }
            $aliasKey = $alias.ToLowerInvariant()
            if (-not $aliasMap.ContainsKey($aliasKey)) {
                $aliasMap[$aliasKey] = New-Object System.Collections.Generic.List[string]
            }
            $aliasMap[$aliasKey].Add($row.Path)
        }
    }

    foreach ($row in $report) {
        $errors = New-Object System.Collections.Generic.List[string]
        if (-not [string]::IsNullOrWhiteSpace($row.Errors)) {
            foreach ($existingError in ($row.Errors -split '; ' | Where-Object { $_ })) {
                $errors.Add($existingError)
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($row.Title)) {
            $titleKey = $row.Title.ToLowerInvariant()
            if ($titleMap[$titleKey].Count -gt 1) {
                $row.Warnings = ($row.Warnings, "Duplicate title: $($row.Title)" | Where-Object { $_ }) -join '; '
            }
        }

        foreach ($alias in $row.Aliases) {
            if ([string]::IsNullOrWhiteSpace($alias)) { continue }
            $aliasKey = $alias.ToLowerInvariant()
            if ($aliasMap[$aliasKey].Count -gt 1) {
                $row.Warnings = ($row.Warnings, "Duplicate alias: $alias" | Where-Object { $_ }) -join '; '
            }
        }

        $row.Errors = ($errors | Select-Object -Unique) -join '; '
        $row.Compliant = [string]::IsNullOrWhiteSpace($row.Errors)
    }

    $report |
        Select-Object Path, Type, Status, Date, KebabCase, Compliant, Errors, Warnings |
        Format-Table -Wrap -AutoSize

    $nonCompliant = $report | Where-Object { $_.Compliant -eq $false }
    if ($nonCompliant) {
        Write-Host "`nFound $($nonCompliant.Count) non-compliant notes." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "`nAll notes are YANP compliant!" -ForegroundColor Green
    }
} catch {
    Write-Error "audit-yanp.ps1 failed: $_"
    exit 1
}
