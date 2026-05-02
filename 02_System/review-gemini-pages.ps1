<#
.SYNOPSIS
    Reviews Gemini-authored wiki notes with Claude for accuracy and robustness.
.DESCRIPTION
    Selects notes from 01_Wiki by frontmatter author, optional path list, or git diff scope,
    then sends each note to Claude for a second-pass review. Produces structured findings on
    technical accuracy, robustness, graph integration, overclaim risk, and revision priority.
    DryRun mode shows the candidate set without calling the Anthropic API.
.PARAMETER Path
    Optional explicit note paths or stems to review. Accepts either full relative paths under
    01_Wiki or note stems such as "python-typing".
.PARAMETER SinceCommit
    Optional git revision used to scope reviews to notes changed since that revision.
.PARAMETER Author
    Frontmatter author to target. Defaults to gemini-cli.
.PARAMETER Limit
    Maximum number of notes to review after filtering. Use 0 for no limit. Default: 10.
.PARAMETER Model
    Anthropic model to use for the review pass.
.PARAMETER OutputPath
    Optional markdown report path. If omitted, no report file is written.
.PARAMETER DryRun
    Lists candidate notes and exits without calling the Anthropic API.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/review-gemini-pages.ps1 -DryRun
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/review-gemini-pages.ps1 -SinceCommit HEAD~10 -Limit 20
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/review-gemini-pages.ps1 -Path python.md,rust.md -OutputPath 02_System\claude-review.md
#>

[CmdletBinding()]
param(
    [string[]]$Path,
    [string]$SinceCommit,
    [string]$Author = 'gemini-cli',
    [int]$Limit = 10,
    [string]$Model = 'claude-haiku-4-5-20251001',
    [string]$OutputPath,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

try {
    $vaultRoot = Split-Path $PSScriptRoot -Parent
    $wikiRoot = Join-Path $vaultRoot '01_Wiki'
    $anthropicKey = $env:ANTHROPIC_API_KEY

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
                $peekIdx = $i + 1
                while ($peekIdx -lt $lines.Count -and [string]::IsNullOrWhiteSpace($lines[$peekIdx])) { $peekIdx++ }
                $isNestedMapping = $peekIdx -lt $lines.Count -and $lines[$peekIdx] -match '^\s+[A-Za-z0-9_-]+:\s*'

                if ($isNestedMapping) {
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

        throw 'Frontmatter block was not closed.'
    }

    function Resolve-ReviewPath {
        param([string]$InputPath)

        if ([string]::IsNullOrWhiteSpace($InputPath)) {
            return $null
        }

        $trimmed = $InputPath.Trim()
        $candidate = if ($trimmed.EndsWith('.md')) { $trimmed } else { "$trimmed.md" }
        $relative = $candidate -replace '^[\\/]+', ''
        if ($relative.StartsWith('01_Wiki\') -or $relative.StartsWith('01_Wiki/')) {
            $relative = $relative.Substring(8)
        }

        $fullPath = Join-Path $wikiRoot $relative
        if (Test-Path $fullPath) {
            return (Resolve-Path $fullPath).Path
        }

        return $null
    }

    function Get-ChangedNotePaths {
        param([string]$Revision)

        $output = & git -C $vaultRoot diff --name-only $Revision -- 01_Wiki
        if ($LASTEXITCODE -ne 0) {
            throw "git diff failed for revision '$Revision'."
        }

        $paths = @()
        foreach ($line in @($output)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if (-not $line.Trim().ToLowerInvariant().EndsWith('.md')) { continue }
            $resolved = Join-Path $vaultRoot $line.Trim()
            if (Test-Path $resolved) {
                $paths += (Resolve-Path $resolved).Path
            }
        }

        return @($paths | Sort-Object -Unique)
    }

    function Get-ReviewPrompt {
        param(
            [pscustomobject]$Note,
            [string]$NoteContent
        )

        $body = if ($NoteContent.Length -gt 12000) { $NoteContent.Substring(0, 12000) + "`n...[truncated for review]..." } else { $NoteContent }
        $aliases = if ($Note.Aliases.Count -gt 0) { ($Note.Aliases -join ', ') } else { '(none)' }

        return @"
You are Claude acting as the Chronicler and reviewer for a shared knowledge vault.
Review this Gemini-authored note for accuracy, robustness, and graph quality.

Return JSON only with this shape:
{
  "verdict": "accept" | "revise" | "escalate",
  "technical_accuracy": 0-10,
  "robustness": 0-10,
  "graph_integration": 0-10,
  "overclaim_risk": 0-10,
  "summary": "short paragraph",
  "strengths": ["..."],
  "findings": [
    {
      "severity": "high" | "medium" | "low",
      "category": "accuracy" | "robustness" | "integration" | "scope" | "style",
      "detail": "specific issue with concrete evidence from the note"
    }
  ],
  "recommended_actions": ["..."],
  "needs_human_review": true | false
}

Review criteria:
- Technical accuracy: are claims internally coherent and likely correct?
- Robustness: does the note overgeneralize, omit key caveats, or present draft-level claims as settled?
- Graph integration: are the wikilinks meaningful and sufficient for navigation?
- Overclaim risk: does the note state more certainty than the evidence warrants?
- Prefer concrete findings over vague impressions.
- If the note is acceptable but thin, use "accept" with low-severity recommendations.
- Use "escalate" only for serious factual risk or substantial unsupported claims.

Note metadata:
- Path: $($Note.RelativePath)
- Stem: $($Note.Stem)
- Title: $($Note.Title)
- Author: $($Note.Author)
- Status: $($Note.Status)
- Type: $($Note.Type)
- Date: $($Note.Date)
- Aliases: $aliases

Note content:
$body
"@
    }

    function Get-BalancedJsonObject {
        param([string]$Text)

        if ([string]::IsNullOrWhiteSpace($Text)) {
            return $null
        }

        $inString = $false
        $isEscaped = $false
        $depth = 0
        $start = -1

        for ($i = 0; $i -lt $Text.Length; $i++) {
            $char = $Text[$i]

            if ($isEscaped) {
                $isEscaped = $false
                continue
            }

            if ($char -eq '\') {
                if ($inString) {
                    $isEscaped = $true
                }
                continue
            }

            if ($char -eq '"') {
                $inString = -not $inString
                continue
            }

            if ($inString) {
                continue
            }

            if ($char -eq '{') {
                if ($depth -eq 0) {
                    $start = $i
                }
                $depth++
                continue
            }

            if ($char -eq '}') {
                if ($depth -gt 0) {
                    $depth--
                    if ($depth -eq 0 -and $start -ge 0) {
                        return $Text.Substring($start, ($i - $start + 1))
                    }
                }
            }
        }

        return $null
    }

    function Invoke-ClaudeReview {
        param(
            [pscustomobject]$Note,
            [string]$NoteContent
        )

        $prompt = Get-ReviewPrompt -Note $Note -NoteContent $NoteContent
        $body = @{
            model      = $Model
            max_tokens = 1400
            messages   = @(@{ role = 'user'; content = $prompt })
        } | ConvertTo-Json -Depth 8 -Compress

        $headers = @{
            'x-api-key'         = $anthropicKey
            'anthropic-version' = '2023-06-01'
            'content-type'      = 'application/json'
        }

        $maxRetries = 3
        for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
            try {
                $response = Invoke-RestMethod -Uri 'https://api.anthropic.com/v1/messages' -Method Post -Headers $headers -Body $body
                $text = [string]$response.content[0].text
                $normalized = $text -replace '(?s)^```(?:json)?\s*', '' -replace '\s*```\s*$', ''
                $trimmed = $normalized.Trim()
                $jsonText = Get-BalancedJsonObject -Text $trimmed
                if ([string]::IsNullOrWhiteSpace($jsonText)) {
                    throw "Claude review response did not contain a JSON object."
                }

                return ($jsonText | ConvertFrom-Json)
            } catch {
                $message = $_.Exception.Message
                $isJsonFailure =
                    $message -like '*JSON*' -or
                    $message -like '*deserializing*' -or
                    $message -like '*did not contain a JSON object*'

                if ($isJsonFailure -and $attempt -lt $maxRetries) {
                    Write-Host "Malformed Claude JSON for $($Note.RelativePath) - retrying..." -ForegroundColor Yellow
                    Start-Sleep -Seconds (2 * $attempt)
                    continue
                }

                if ($null -ne $_.Exception.Response) {
                    $code = $_.Exception.Response.StatusCode.value__
                    if ($code -eq 429 -and $attempt -lt $maxRetries) {
                        Write-Host "Rate limit from Anthropic - waiting 60s..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 60
                        continue
                    }
                }

                throw
            }
        }
    }

    function Convert-ReviewReportToMarkdown {
        param(
            [pscustomobject[]]$Results,
            [string]$ScopedAuthor,
            [string]$ScopedRevision
        )

        $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add('# Claude Review Report')
        $lines.Add('')
        $lines.Add("- Generated: $generatedAt")
        $lines.Add("- Target author: $ScopedAuthor")
        if (-not [string]::IsNullOrWhiteSpace($ScopedRevision)) {
            $lines.Add("- Scoped since commit: $ScopedRevision")
        }
        $lines.Add("- Notes reviewed: $($Results.Count)")
        $lines.Add('')

        foreach ($result in $Results) {
            $lines.Add("## [[$($result.Stem)]]")
            $lines.Add('')
            $lines.Add(('- Path: `{0}`' -f $result.RelativePath))
            $lines.Add(('- Verdict: `{0}`' -f $result.Verdict))
            if (-not [string]::IsNullOrWhiteSpace($result.ReviewError)) {
                $lines.Add(('- Review error: `{0}`' -f $result.ReviewError))
                $lines.Add('')
                continue
            }
            $lines.Add("- Accuracy / Robustness / Integration / Overclaim: $($result.TechnicalAccuracy)/10, $($result.Robustness)/10, $($result.GraphIntegration)/10, $($result.OverclaimRisk)/10")
            $lines.Add("- Human review: $($result.NeedsHumanReview)")
            $lines.Add('')
            $lines.Add($result.Summary)
            $lines.Add('')

            if ($result.Strengths.Count -gt 0) {
                $lines.Add('### Strengths')
                foreach ($item in $result.Strengths) {
                    $lines.Add("- $item")
                }
                $lines.Add('')
            }

            if ($result.Findings.Count -gt 0) {
                $lines.Add('### Findings')
                foreach ($finding in $result.Findings) {
                    $lines.Add("- [$($finding.severity)] [$($finding.category)] $($finding.detail)")
                }
                $lines.Add('')
            }

            if ($result.RecommendedActions.Count -gt 0) {
                $lines.Add('### Recommended Actions')
                foreach ($action in $result.RecommendedActions) {
                    $lines.Add("- $action")
                }
                $lines.Add('')
            }
        }

        return ($lines -join "`r`n")
    }

    $explicitPaths = @()
    if ($Path.Count -gt 0) {
        foreach ($entry in $Path) {
            $resolved = Resolve-ReviewPath -InputPath $entry
            if ($null -eq $resolved) {
                throw "Could not resolve review path '$entry' under 01_Wiki."
            }
            $explicitPaths += $resolved
        }
    }

    $changedPaths = @()
    if (-not [string]::IsNullOrWhiteSpace($SinceCommit)) {
        $changedPaths = Get-ChangedNotePaths -Revision $SinceCommit
    }

    $notes = Get-ChildItem -Path $wikiRoot -Filter '*.md' -Recurse | Sort-Object FullName
    $candidates = foreach ($note in $notes) {
        $content = Get-Content $note.FullName -Raw
        $frontmatter = Get-FrontmatterMap -Content $content
        if ($null -eq $frontmatter) { continue }

        $noteAuthor = if ($frontmatter.Contains('author')) { [string]$frontmatter['author'] } else { '' }
        if ($noteAuthor -ne $Author) { continue }

        if ($explicitPaths.Count -gt 0 -and $explicitPaths -notcontains $note.FullName) { continue }
        if ($changedPaths.Count -gt 0 -and $changedPaths -notcontains $note.FullName) { continue }

        [PSCustomObject]@{
            FullPath     = $note.FullName
            RelativePath = $note.FullName.Substring($wikiRoot.Length + 1)
            Stem         = [System.IO.Path]::GetFileNameWithoutExtension($note.Name)
            Title        = if ($frontmatter.Contains('title')) { [string]$frontmatter['title'] } else { '' }
            Author       = $noteAuthor
            Status       = if ($frontmatter.Contains('status')) { [string]$frontmatter['status'] } else { '' }
            Type         = if ($frontmatter.Contains('type')) { [string]$frontmatter['type'] } else { '' }
            Date         = if ($frontmatter.Contains('date')) { [string]$frontmatter['date'] } else { '' }
            Aliases      = if ($frontmatter.Contains('aliases')) { @($frontmatter['aliases']) } else { @() }
            Content      = $content
        }
    }

    if ($Limit -gt 0) {
        $candidates = @($candidates | Select-Object -First $Limit)
    } else {
        $candidates = @($candidates)
    }

    if ($candidates.Count -eq 0) {
        Write-Host 'No matching Gemini-authored notes found for review.' -ForegroundColor Yellow
        return
    }

    Write-Host "Selected $($candidates.Count) note(s) for Claude review." -ForegroundColor Cyan
    $candidates | Select-Object RelativePath, Status, Type, Date | Format-Table -AutoSize

    if ($DryRun) {
        Write-Host 'Dry run only; no Anthropic API calls were made.' -ForegroundColor Yellow
        return
    }

    if ([string]::IsNullOrWhiteSpace($anthropicKey)) {
        throw 'ANTHROPIC_API_KEY is not set.'
    }

    $results = New-Object System.Collections.Generic.List[object]
    $index = 0
    foreach ($candidate in $candidates) {
        $index++
        Write-Host ("[{0}/{1}] Reviewing {2}" -f $index, $candidates.Count, $candidate.RelativePath) -ForegroundColor White
        try {
            $review = Invoke-ClaudeReview -Note $candidate -NoteContent $candidate.Content

            $result = [PSCustomObject]@{
                RelativePath        = $candidate.RelativePath
                Stem                = $candidate.Stem
                Verdict             = [string]$review.verdict
                TechnicalAccuracy   = [int]$review.technical_accuracy
                Robustness          = [int]$review.robustness
                GraphIntegration    = [int]$review.graph_integration
                OverclaimRisk       = [int]$review.overclaim_risk
                Summary             = [string]$review.summary
                Strengths           = @($review.strengths)
                Findings            = @($review.findings)
                RecommendedActions  = @($review.recommended_actions)
                NeedsHumanReview    = [bool]$review.needs_human_review
                ReviewError         = $null
            }

            $results.Add($result) | Out-Null
            Write-Host ("         -> {0} | acc {1}/10 | rob {2}/10 | graph {3}/10 | risk {4}/10" -f $result.Verdict, $result.TechnicalAccuracy, $result.Robustness, $result.GraphIntegration, $result.OverclaimRisk) -ForegroundColor Green
        } catch {
            $errorMessage = [string]$_.Exception.Message
            $result = [PSCustomObject]@{
                RelativePath        = $candidate.RelativePath
                Stem                = $candidate.Stem
                Verdict             = 'error'
                TechnicalAccuracy   = $null
                Robustness          = $null
                GraphIntegration    = $null
                OverclaimRisk       = $null
                Summary             = ''
                Strengths           = @()
                Findings            = @()
                RecommendedActions  = @()
                NeedsHumanReview    = $true
                ReviewError         = $errorMessage
            }
            $results.Add($result) | Out-Null
            Write-Host ("         -> error | {0}" -f $errorMessage) -ForegroundColor Red
        }

        if ($index -lt $candidates.Count) {
            Start-Sleep -Milliseconds 4000
        }
    }

    $results |
        Select-Object RelativePath, Verdict, TechnicalAccuracy, Robustness, GraphIntegration, OverclaimRisk, NeedsHumanReview |
        Format-Table -AutoSize

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $reportPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $vaultRoot $OutputPath }
        $markdown = Convert-ReviewReportToMarkdown -Results $results -ScopedAuthor $Author -ScopedRevision $SinceCommit
        $parent = Split-Path -Parent $reportPath
        if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Set-Content -Path $reportPath -Value $markdown -Encoding utf8
        Write-Host "Wrote review report to $reportPath" -ForegroundColor Cyan
    }
} catch {
    Write-Error "review-gemini-pages.ps1 failed: $_"
    exit 1
}
