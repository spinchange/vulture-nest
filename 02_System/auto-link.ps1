<#
.SYNOPSIS
    Auto-links semantically related notes using Gemini as the link-direction judge.
.DESCRIPTION
    Loads note embeddings, finds high-similarity unlinked pairs, asks Gemini to decide
    directionality for each pair, and writes wikilinks directly into the notes.
    Run sync-vault-graph.ps1 afterwards to update the graph.
.PARAMETER TopN
    Number of top suggestion pairs to process. Default: 20
.PARAMETER Threshold
    Minimum cosine similarity to consider. Default: 0.85
.PARAMETER DryRun
    Show Gemini decisions without modifying any files.
.PARAMETER Model
    Gemini generative model to use. Default: gemini-1.5-flash
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -DryRun
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -TopN 30
#>
[CmdletBinding()]
param(
    [int]$TopN       = 20,
    [double]$Threshold = 0.85,
    [switch]$DryRun,
    [string]$Model   = "claude-haiku-4-5-20251001"
)
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot    = Split-Path -Parent $PSScriptRoot
    $WikiFolder   = Join-Path $VaultRoot "01_Wiki"
    $LogPath      = Join-Path $PSScriptRoot "log.md"
    $DbPath       = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db"
    }
    $LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"
    $ApiKey  = $env:GEMINI_API_KEY

    # --- SQLite ---
    function Import-SqliteAssemblies {
        Write-Host "Debug: LibPath = $LibPath"
        $dlls = @("SQLitePCLRaw.core.dll","SQLitePCLRaw.provider.e_sqlite3.dll","SQLitePCLRaw.batteries_v2.dll","Microsoft.Data.Sqlite.dll")
        foreach ($dll in $dlls) {
            $path = Join-Path $LibPath $dll
            Write-Host "Debug: Loading $path"
            if (Test-Path $path) {
                try { 
                    [System.Reflection.Assembly]::LoadFrom($path) | Out-Null 
                    Write-Host "Debug: Loaded $dll"
                }
                catch { 
                    Write-Host "Debug: Failed to load $dll : $_"
                    Add-Type -Path $path 
                }
            } else {
                Write-Host "Debug: $path not found"
            }
        }
        $os   = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
        if ($arch -eq "x64") { $arch = "x64" } # Ensure consistency with runtime paths
        $nativeLib  = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
        $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLib"
        if (Test-Path $nativePath) { try { [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null } catch {} }
        try { [SQLitePCL.Batteries]::Init() } catch {}
    }
    Import-SqliteAssemblies

    $connString = "Data Source=$DbPath"
    function Invoke-Sql([string]$query) {
        $c = New-Object Microsoft.Data.Sqlite.SqliteConnection($connString)
        $c.Open()
        try {
            $cmd = $c.CreateCommand(); $cmd.CommandText = $query
            $reader = $cmd.ExecuteReader(); $rows = @()
            while ($reader.Read()) {
                $row = [ordered]@{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
                }
                $rows += [PSCustomObject]$row
            }
            return @($rows)
        } finally { $c.Close() }
    }

    # --- Load and normalize embeddings ---
    $embRows = Invoke-Sql "SELECT NoteName, Embedding FROM NoteEmbeddings"
    if ($embRows.Count -eq 0) { throw "No embeddings found. Run sync-embeddings.ps1 first." }

    $noteNames  = @()
    $normalized = @{}
    foreach ($row in $embRows) {
        $vec = [double[]]($row.Embedding | ConvertFrom-Json)
        $mag = 0.0; foreach ($v in $vec) { $mag += $v * $v }
        $mag = [Math]::Sqrt($mag)
        if ($mag -eq 0) { continue }
        $norm = [double[]]::new($vec.Length)
        for ($k = 0; $k -lt $vec.Length; $k++) { $norm[$k] = $vec[$k] / $mag }
        $normalized[$row.NoteName] = $norm
        $noteNames += $row.NoteName
    }

    # --- Load existing links ---
    $linkRows      = Invoke-Sql "SELECT Source, Target FROM Links"
    $existingLinks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($link in $linkRows) {
        $existingLinks.Add("$($link.Source)|$($link.Target)") | Out-Null
        $existingLinks.Add("$($link.Target)|$($link.Source)") | Out-Null
    }

    # --- Compute top-N suggestions above threshold ---
    Write-Host "Computing pairwise similarity for $($noteNames.Count) notes..." -ForegroundColor Cyan
    $suggestions = [System.Collections.Generic.List[PSCustomObject]]::new()
    for ($i = 0; $i -lt $noteNames.Count; $i++) {
        $a = $noteNames[$i]; $va = $normalized[$a]
        for ($j = $i + 1; $j -lt $noteNames.Count; $j++) {
            $b = $noteNames[$j]
            if ($existingLinks.Contains("$a|$b")) { continue }
            $vb = $normalized[$b]; $dot = 0.0
            for ($k = 0; $k -lt $va.Length; $k++) { $dot += $va[$k] * $vb[$k] }
            if ($dot -ge $Threshold) {
                $suggestions.Add([PSCustomObject]@{ NoteA = $a; NoteB = $b; Similarity = [Math]::Round($dot, 4) }) | Out-Null
            }
        }
    }
    $candidates = $suggestions | Sort-Object Similarity -Descending | Select-Object -First $TopN
    Write-Host "Processing top $($candidates.Count) pair(s) above threshold $Threshold..." -ForegroundColor Cyan
    if ($DryRun) { Write-Host "(DRY RUN - no files will be modified)`n" -ForegroundColor Yellow }

    # --- Link insertion ---
    function Add-WikiLink([string]$filePath, [string]$linkTarget) {
        $lines   = [System.IO.File]::ReadAllLines($filePath)
        $linkLine = "- [[$linkTarget]]"

        # Already contains this link?
        if ($lines | Where-Object { $_ -match [regex]::Escape("[[$linkTarget]]") }) { return $false }

        # Find an existing Related/See Also section
        $relatedIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^##\s+(Related|See Also|Links|References)\s*$") {
                $relatedIdx = $i; break
            }
        }

        $newLines = [System.Collections.Generic.List[string]]::new($lines)
        if ($relatedIdx -ge 0) {
            # Insert before the next ## heading or at end of file
            $insertAt = $newLines.Count
            for ($i = $relatedIdx + 1; $i -lt $newLines.Count; $i++) {
                if ($newLines[$i] -match "^## ") { $insertAt = $i; break }
            }
            $newLines.Insert($insertAt, $linkLine)
        } else {
            # Append a new Related section
            $newLines.Add("")
            $newLines.Add("## Related")
            $newLines.Add($linkLine)
        }

        [System.IO.File]::WriteAllLines($filePath, $newLines)
        return $true
    }

    # --- Claude judge ---
    $anthropicKey = $env:ANTHROPIC_API_KEY
    if ([string]::IsNullOrWhiteSpace($anthropicKey)) { throw "ANTHROPIC_API_KEY is not set." }

    function Invoke-GeminiJudge([string]$nameA, [string]$contentA, [string]$nameB, [string]$contentB, [double]$sim) {
        $capA = if ($contentA.Length -gt 2000) { $contentA.Substring(0, 2000) + "..." } else { $contentA }
        $capB = if ($contentB.Length -gt 2000) { $contentB.Substring(0, 2000) + "..." } else { $contentB }

        $prompt = @"
You are a knowledge graph curator reviewing two notes from a personal wiki.
Decide whether a wikilink should be added between them and in which direction.

== Note A: [[$nameA]] ==
$capA

== Note B: [[$nameB]] ==
$capB

Cosine similarity score: $sim (1.0 = identical, 0.0 = unrelated)

Choose exactly one action:
- "A_to_B" : Note A should reference Note B (add [[$nameB]] inside Note A)
- "B_to_A" : Note B should reference Note A (add [[$nameA]] inside Note B)
- "both"   : Each note benefits from referencing the other
- "none"   : Similarity is coincidental; no link adds value

Rules:
- Prefer "both" when notes are genuinely complementary concepts.
- Prefer "none" when similarity comes from shared vocabulary rather than shared meaning.
- Handoff notes (filename contains "handoff") should link TO their subject, not receive links.

Respond with JSON: {"action": "...", "reason": "one sentence"}
"@

        $body = @{
            model      = $Model
            max_tokens = 256
            messages   = @(@{ role = "user"; content = $prompt })
        } | ConvertTo-Json -Depth 6 -Compress

        $headers = @{
            "x-api-key"         = $anthropicKey
            "anthropic-version" = "2023-06-01"
            "content-type"      = "application/json"
        }

        $maxRetries = 3
        for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
            try {
                $resp = Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" -Method Post -Headers $headers -Body $body
                $text = $resp.content[0].text -replace '(?s)^```(?:json)?\s*', '' -replace '\s*```\s*$', ''
                $json = $text.Trim() | ConvertFrom-Json
                return $json
            } catch {
                if ($null -ne $_.Exception.Response) {
                    $code = $_.Exception.Response.StatusCode.value__
                    if ($code -eq 429 -and $attempt -lt $maxRetries) {
                        Write-Host "  Rate limit - waiting 60s..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 60
                        continue
                    }
                }
                throw
            }
        }
    }

    # --- Main loop ---
    $linked = 0; $skipped = 0; $i = 0
    foreach ($pair in $candidates) {
        $i++
        $pathA = Join-Path $WikiFolder "$($pair.NoteA).md"
        $pathB = Join-Path $WikiFolder "$($pair.NoteB).md"

        # Skip if either file is missing (e.g. note is in system layer)
        if (-not (Test-Path $pathA) -or -not (Test-Path $pathB)) {
            Write-Host ("  [{0}/{1}] SKIP (file not in 01_Wiki): [[{2}]] and [[{3}]]" -f $i, $candidates.Count, $pair.NoteA, $pair.NoteB) -ForegroundColor Gray
            $skipped++
            continue
        }

        $contentA = [System.IO.File]::ReadAllText($pathA)
        $contentB = [System.IO.File]::ReadAllText($pathB)

        Write-Host ("`n  [{0}/{1}] Sim {2:F3}  [[{3}]] and [[{4}]]" -f $i, $candidates.Count, $pair.Similarity, $pair.NoteA, $pair.NoteB) -ForegroundColor White

        $decision = Invoke-GeminiJudge $pair.NoteA $contentA $pair.NoteB $contentB $pair.Similarity

        $action = $decision.action
        $reason = $decision.reason
        Write-Host ("         -> $action : $reason") -ForegroundColor $(if ($action -eq 'none') { 'Gray' } else { 'Green' })

        if (-not $DryRun) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
            switch ($action) {
                "A_to_B" {
                    if (Add-WikiLink $pathA $pair.NoteB) {
                        Add-Content $LogPath "`n- [$timestamp] auto-link: added [[$($pair.NoteB)]] to [[$($pair.NoteA)]] (sim=$($pair.Similarity)) - $reason"
                        $linked++
                    }
                }
                "B_to_A" {
                    if (Add-WikiLink $pathB $pair.NoteA) {
                        Add-Content $LogPath "`n- [$timestamp] auto-link: added [[$($pair.NoteA)]] to [[$($pair.NoteB)]] (sim=$($pair.Similarity)) - $reason"
                        $linked++
                    }
                }
                "both" {
                    $didA = Add-WikiLink $pathA $pair.NoteB
                    $didB = Add-WikiLink $pathB $pair.NoteA
                    if ($didA -or $didB) {
                        Add-Content $LogPath "`n- [$timestamp] auto-link: mutual link [[$($pair.NoteA)]] and [[$($pair.NoteB)]] (sim=$($pair.Similarity)) - $reason"
                        $linked++
                    }
                }
                "none" { $skipped++ }
            }
        }

        # 4s between judge calls - safe under 15 RPM free tier
        if ($i -lt $candidates.Count) { Start-Sleep -Milliseconds 4000 }
    }

    Write-Host "`n--- Auto-Link Complete ---" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "Dry run - no files modified." -ForegroundColor Yellow
    } else {
        Write-Host "$linked pair(s) linked, $skipped skipped." -ForegroundColor Green
        if ($linked -gt 0) {
            Write-Host "Run sync-vault-graph.ps1 to update the link graph." -ForegroundColor Gray
        }
    }

} catch {
    Write-Error "auto-link.ps1 failed: $_"
    exit 1
}
