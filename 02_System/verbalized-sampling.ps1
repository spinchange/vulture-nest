<#
.SYNOPSIS
    Elicits tail-distribution knowledge from Claude via Mode-Anchored Departure (Idea 3, Approach B).
.DESCRIPTION
    Two-call pipeline:

      Call 1 — Claude names its modal response (the most probable default), then enumerates 9
               departures ranked by departure distance from that anchor, each with a verbalized P(%).
               The modal anchor is what makes this Approach B: departures are measured against an
               explicit reference point, not inferred from rank order alone.

      Call 2 — Tail departures (ranks TailStart–9) plus the modal are submitted as context for a
               synthesis pass that produces a response the modal would not contain.

    ParseWarning is set on: missing modal block, fewer than 9 ranks, rank-9 modal collapse, or
    Call 2 reversion (synthesis token-overlap with modal above threshold).
.PARAMETER Question
    The question to probe. Positional.
.PARAMETER TailStart
    Rank at which the "tail" begins; ranks TailStart–9 feed Call 2. Default: 7.
    Must be 4–9. TailStart=7 is the canonical Approach B setting.
.PARAMETER Model
    Claude model ID. Default: claude-sonnet-4-6
.PARAMETER MaxTokens
    Max tokens per API call. Default: 2000
.PARAMETER ApiKey
    Anthropic API key. Falls back to $env:ANTHROPIC_API_KEY.
.PARAMETER OutFile
    Optional path to write the full result as JSON.
.EXAMPLE
    pwsh -File 02_System/verbalized-sampling.ps1 -Question "What causes inflation?"
.EXAMPLE
    pwsh -File 02_System/verbalized-sampling.ps1 -Question "What is consciousness?" -TailStart 6 -OutFile result.json
.EXAMPLE
    $r = pwsh -File 02_System/verbalized-sampling.ps1 -Question "How do you build trust?"
    $r.Synthesis
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Question,

    [ValidateRange(4, 9)]
    [int]$TailStart = 7,

    [string]$Model = 'claude-sonnet-4-6',

    [int]$MaxTokens = 2000,

    [string]$ApiKey,

    [string]$OutFile
)

$ErrorActionPreference = 'Stop'

# ── API key resolution ────────────────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:ANTHROPIC_API_KEY
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'No API key found. Set $env:ANTHROPIC_API_KEY or pass -ApiKey.'
}

$ApiUrl = 'https://api.anthropic.com/v1/messages'
$Headers = @{
    'x-api-key'         = $ApiKey
    'anthropic-version' = '2023-06-01'
    'content-type'      = 'application/json'
}

# ── Claude call helper ────────────────────────────────────────────────────────
function Invoke-Claude {
    param(
        [string]$SystemPrompt,
        [string]$UserMessage,
        [string]$Label = 'call'
    )
    $body = [ordered]@{
        model      = $Model
        max_tokens = $MaxTokens
        system     = $SystemPrompt
        messages   = @(
            @{ role = 'user'; content = $UserMessage }
        )
    } | ConvertTo-Json -Depth 6

    try {
        $response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Headers $Headers -Body $body -ContentType 'application/json'
    }
    catch {
        $statusCode = $_.Exception.Response?.StatusCode.value__
        throw "Claude API error on $Label (HTTP $statusCode): $($_.Exception.Message)"
    }
    return $response.content[0].text
}

# ── Token overlap for reversion detection ─────────────────────────────────────
# Returns Jaccard similarity over content words (stop words excluded).
function Measure-TokenOverlap {
    param([string]$A, [string]$B)
    $stop = [System.Collections.Generic.HashSet[string]]@(
        'the','a','an','is','are','was','were','be','been','being','have','has','had',
        'do','does','did','will','would','could','should','may','might','shall','can',
        'of','in','on','at','to','for','with','by','from','as','it','its','this','that',
        'these','those','and','or','but','not','no','so','if','then','than','more',
        'most','also','very','just','i','we','you','they','he','she','what','which',
        'who','when','where','how','why','all','any','each','such','same','other','s'
    )
    $tokA = [System.Collections.Generic.HashSet[string]](
        ($A.ToLower() -split '\W+') | Where-Object { $_ -and -not $stop.Contains($_) }
    )
    $tokB = [System.Collections.Generic.HashSet[string]](
        ($B.ToLower() -split '\W+') | Where-Object { $_ -and -not $stop.Contains($_) }
    )
    if ($tokA.Count -eq 0 -or $tokB.Count -eq 0) { return 0.0 }
    $inter = [System.Collections.Generic.HashSet[string]]::new($tokA)
    $inter.IntersectWith($tokB)
    $union = [System.Collections.Generic.HashSet[string]]::new($tokA)
    $union.UnionWith($tokB)
    return [double]$inter.Count / $union.Count
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

# ── System prompt (verbalized-sampling contract) ──────────────────────────────
# Establishes the probability-as-distribution-position frame upfront.
$systemPrompt = @'
You are participating in a verbalized-sampling exercise. Your task is to map your own response distribution — not to give the "best" answer, but to honestly characterize the space of responses you might produce and deliberately enumerate departures from your most typical response.

P(%) in this exercise means: the probability that a typical, unguided LLM completion would produce this response (or one closely matching it). P=80% is very default; P=5% is deep tail, normally suppressed by alignment pressure.

Be specific and honest. Enumerated departures must be substantively different from each other and from the modal — not stylistic rewrites. The value of this exercise is in naming what is true but unsaid, not in generating variety for its own sake.
'@

# ── Call 1: modal + departure enumeration ────────────────────────────────────
$call1Prompt = @"
Question: $Question

Respond in exactly this format. Do not add text before the first block or between blocks.

[MODAL | P≈{X}%]
{Your most probable default response — what a typical LLM completion would say}

[RANK-1 | DEP:{3–5 word tag} | P≈{X}%]
{Departure — closest to modal, smallest departure}

[RANK-2 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-3 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-4 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-5 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-6 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-7 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-8 | DEP:{3–5 word tag} | P≈{X}%]
{Departure}

[RANK-9 | DEP:{3–5 word tag} | P≈{X}%]
{Departure — furthest from modal, most suppressed in normal operation}

Rules:
- Rank 1 is the smallest departure from modal; Rank 9 is the largest (deepest tail)
- P% should generally decrease as rank increases
- Each departure must be substantively different from modal AND from each other
- DEP tag: 3–5 words capturing the nature or direction of the departure
- Replace {X} with your actual verbalized probability estimate (integer 1–95)
"@

Write-Host "`n[verbalized-sampling] " -ForegroundColor Cyan -NoNewline
Write-Host "Q: $Question" -ForegroundColor White
Write-Host "[1/2] Modal + departure enumeration…" -ForegroundColor DarkCyan

$raw1 = Invoke-Claude -SystemPrompt $systemPrompt -UserMessage $call1Prompt -Label 'Call 1'
Write-Verbose "── Call 1 raw response ──`n$raw1`n"

# ── Parse Call 1 ──────────────────────────────────────────────────────────────
$parseWarning = $null

# Phase 1: modal block
$modalRx = [regex]'\[MODAL\s*\|\s*P[=≈~:]\s*(\d+(?:\.\d+)?)\s*%\]\s*([\s\S]+?)(?=\[RANK-1|\z)'
$modalMatch = $modalRx.Match($raw1)
$modalP    = if ($modalMatch.Success) { [double]$modalMatch.Groups[1].Value } else { $null }
$modalText = if ($modalMatch.Success) { $modalMatch.Groups[2].Value.Trim() } else { $null }

if (-not $modalMatch.Success) {
    Write-Warning 'Could not parse modal block from Call 1.'
    $parseWarning = 'MissingModal'
}

# Phase 2: departure blocks
$deptRx = [regex]'\[RANK-(\d+)\s*\|\s*DEP:(.*?)\s*\|\s*P[=≈~:]\s*(\d+(?:\.\d+)?)\s*%\]\s*([\s\S]+?)(?=\[RANK-\d+|\z)'
$deptMatches = $deptRx.Matches($raw1)

$departures = @(foreach ($m in $deptMatches) {
    [PSCustomObject]@{
        Rank         = [int]$m.Groups[1].Value
        DepartureTag = $m.Groups[2].Value.Trim()
        P            = [double]$m.Groups[3].Value
        Text         = $m.Groups[4].Value.Trim()
    }
}) | Sort-Object Rank

if ($departures.Count -lt 9 -and -not $parseWarning) {
    $parseWarning = 'MissingRanks'
    Write-Warning "Parsed $($departures.Count)/9 departure ranks."
}

# Rank-9 modal collapse check
if ($modalText -and $departures.Count -gt 0) {
    $rank9 = $departures | Where-Object Rank -eq 9 | Select-Object -First 1
    if ($rank9) {
        $collapseOverlap = Measure-TokenOverlap -A $modalText -B $rank9.Text
        if ($collapseOverlap -gt 0.55 -and -not $parseWarning) {
            $parseWarning = 'ModalCollapse'
            Write-Warning "Rank-9 departure resembles modal (Jaccard $([math]::Round($collapseOverlap, 2))). Possible modal collapse."
        }
    }
}

# Print parsed distribution summary
Write-Host "`nModal (P≈$modalP%): " -ForegroundColor Yellow -NoNewline
Write-Host ($modalText -replace "`n", " " | ForEach-Object { if ($_.Length -gt 100) { $_.Substring(0,97) + '…' } else { $_ } }) -ForegroundColor White
foreach ($d in $departures) {
    $bar = '─' * [math]::Max(1, [math]::Round((100 - $d.P) / 10))
    Write-Host ("  R{0:D2} {1} P≈{2}%  [{3}]" -f $d.Rank, $bar, $d.P, $d.DepartureTag) -ForegroundColor DarkGray
}

# ── Call 2: tail synthesis ────────────────────────────────────────────────────
$tailItems = @($departures | Where-Object { $_.Rank -ge $TailStart })
$synthesisText = $null

if ($tailItems.Count -eq 0) {
    Write-Warning "No tail items at rank >= $TailStart. Skipping Call 2."
    if (-not $parseWarning) { $parseWarning = 'NoTailItems' }
}
else {
    $tailBlock = ($tailItems | ForEach-Object {
        "[RANK-$($_.Rank) | DEP:$($_.DepartureTag) | P≈$($_.P)%]`n$($_.Text)"
    }) -join "`n`n"

    $call2Prompt = @"
Original question: $Question

The modal response (P≈$modalP%) was:
$modalText

The most distant valid departures from that modal were:

$tailBlock

Synthesize a substantive response to the original question that incorporates the most valuable insights from these tail departures. Do not merely list or rephrase the departures — integrate them into a genuinely novel perspective that the modal response would not contain. Be concrete and specific. The synthesis should be something the modal answer would actively suppress.

Begin your response directly with the substantive content. Do not include any preamble, meta-commentary, or phrases like "Here is a synthesis..." — just the synthesis itself.
"@

    Write-Host "`n[2/2] Tail synthesis (ranks $TailStart–9)…" -ForegroundColor DarkCyan
    $raw2 = Invoke-Claude -SystemPrompt $systemPrompt -UserMessage $call2Prompt -Label 'Call 2'
    $synthesisText = $raw2.Trim()
    Write-Verbose "── Call 2 raw response ──`n$raw2`n"

    # Reversion check
    if ($modalText) {
        $revOverlap = Measure-TokenOverlap -A $modalText -B $synthesisText
        if ($revOverlap -gt 0.60 -and -not $parseWarning) {
            $parseWarning = 'Call2Reversion'
            Write-Warning "Call 2 synthesis resembles modal (Jaccard $([math]::Round($revOverlap, 2))). Possible reversion."
        }
    }
}

$sw.Stop()

# ── Display synthesis ─────────────────────────────────────────────────────────
Write-Host "`n── SYNTHESIS (tail ranks $TailStart–9) " -ForegroundColor Cyan -NoNewline
Write-Host ("─" * 40) -ForegroundColor DarkCyan
Write-Host $synthesisText -ForegroundColor White
Write-Host ("─" * 56) -ForegroundColor DarkCyan

if ($parseWarning) {
    Write-Host "`nParseWarning: $parseWarning" -ForegroundColor Magenta
}
Write-Host "Elapsed: $($sw.Elapsed.ToString('g'))  Model: $Model  TailStart: $TailStart`n" -ForegroundColor DarkGray

# ── Build result object ───────────────────────────────────────────────────────
$result = [PSCustomObject]@{
    Question     = $Question
    Modal        = [PSCustomObject]@{ P = $modalP; Text = $modalText }
    Departures   = $departures
    TailItems    = $tailItems
    Synthesis    = $synthesisText
    ParseWarning = $parseWarning
    CallCount    = 2
    Model        = $Model
    TailStart    = $TailStart
    Elapsed      = $sw.Elapsed.ToString('g')
}

if ($OutFile) {
    $result | ConvertTo-Json -Depth 10 | Set-Content -Path $OutFile -Encoding UTF8
    Write-Host "JSON written to $OutFile" -ForegroundColor Cyan
}

$result
