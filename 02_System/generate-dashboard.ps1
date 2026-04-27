<#
.SYNOPSIS
    Generates the Vault Pulse dashboard as a standalone HTML file.
.DESCRIPTION
    Builds a single-file dashboard that combines vault health metrics, graph topology,
    and recent activity from both log.md and the PoShWiKi SQLite database.
.PARAMETER OutputPath
    Optional output path for the generated HTML. Defaults to 03_Web/public/dashboard.html.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/generate-dashboard.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

try {
    if ($PSVersionTable.PSEdition -ne 'Core') {
        throw "generate-dashboard.ps1 requires PowerShell 7 (pwsh). Current edition: $($PSVersionTable.PSEdition)."
    }

    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $OutputPath = Join-Path $VaultRoot '03_Web/public/dashboard.html'
    }

    $WikiPath = Join-Path $VaultRoot '01_Wiki'
    $SystemPath = Join-Path $VaultRoot '02_System'
    $LogPath = Join-Path $SystemPath 'log.md'
    $DbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/wiki.db'
    }

    $LibPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/lib'
    $Script:SqliteLoaded = $false

    function Import-SqliteAssemblies {
        if ($Script:SqliteLoaded) {
            return
        }

        if ('Microsoft.Data.Sqlite.SqliteConnection' -as [type]) {
            $Script:SqliteLoaded = $true
            return
        }

        $dlls = @(
            'SQLitePCLRaw.core.dll',
            'SQLitePCLRaw.provider.e_sqlite3.dll',
            'SQLitePCLRaw.batteries_v2.dll',
            'Microsoft.Data.Sqlite.dll'
        )

        foreach ($dll in $dlls) {
            $path = Join-Path $LibPath $dll
            if (-not (Test-Path $path)) {
                throw "Required SQLite assembly not found: $path"
            }

            try {
                Add-Type -Path $path -ErrorAction Stop
            } catch [System.InvalidOperationException] {
                # Add-Type throws when the assembly is already loaded; that is safe to ignore.
            }
        }

        $os = if ($IsWindows) { 'win' } elseif ($IsLinux) { 'linux' } elseif ($IsMacOS) { 'osx' } else { 'unknown' }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
        $runtimeArch = switch ($arch) {
            'x64' { 'x64' }
            'arm64' { 'arm64' }
            'x86' { 'x86' }
            'arm' { 'arm' }
            default { $arch }
        }

        $nativeLibName = if ($IsWindows) { 'e_sqlite3.dll' } elseif ($IsMacOS) { 'libe_sqlite3.dylib' } else { 'libe_sqlite3.so' }
        $nativePath = Join-Path $LibPath "runtimes/$os-$runtimeArch/native/$nativeLibName"

        if (-not (Test-Path $nativePath)) {
            throw "Required native SQLite library not found: $nativePath"
        }

        try {
            [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
        } catch {
            Write-Verbose "Native library already loaded or deferred to SQLitePCL: $_"
        }

        try {
            [SQLitePCL.Batteries]::Init()
        } catch {
            throw "Failed to initialize SQLite batteries: $_"
        }

        if (-not ('Microsoft.Data.Sqlite.SqliteConnection' -as [type])) {
            throw "SQLite types failed to load from $LibPath."
        }

        $Script:SqliteLoaded = $true
    }

    function Get-SqliteConnection {
        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
        $connection.Open()
        return $connection
    }

    function Invoke-SqliteQuery {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Query,
            [hashtable]$Parameters = @{}
        )

        $connection = Get-SqliteConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            foreach ($key in $Parameters.Keys) {
                $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null
            }

            $reader = $command.ExecuteReader()
            try {
                $results = @()
                while ($reader.Read()) {
                    $row = [ordered]@{}
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                        $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
                    }
                    $results += [PSCustomObject]$row
                }
                return @($results)
            } finally {
                $reader.Close()
                $reader.Dispose()
            }
        } finally {
            $connection.Close()
            $connection.Dispose()
        }
    }

    function Get-NormalizedContent {
        param([Parameter(Mandatory = $true)][string]$Path)
        return ((Get-Content -Path $Path -Raw) -replace "`0", '')
    }

    function ConvertTo-PlainText {
        param([Parameter(Mandatory = $true)][string]$Text)
        $normalized = ($Text -replace "`r`n", "`n").Replace(([char]96).ToString() + 'n', [Environment]::NewLine)
        $normalized = $normalized -replace '\[\[([^\]|]+)\|([^\]]+)\]\]', '$2'
        $normalized = $normalized -replace '\[\[([^\]]+)\]\]', '$1'
        $normalized = $normalized -replace '`', ''
        $normalized = $normalized -replace '\*\*', ''
        return $normalized.Trim()
    }

    function Get-MarkdownSectionBody {
        param(
            [Parameter(Mandatory = $true)][string]$Content,
            [Parameter(Mandatory = $true)][string]$Section
        )

        $normalized = ($Content -replace "`r`n", "`n")
        $pattern = "(?ms)^##\s+$([regex]::Escape($Section))\s*\n(.*?)(?=^##\s+|\z)"
        $match = [regex]::Match($normalized, $pattern)
        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        }

        return $null
    }

    function Split-ActivityLines {
        param([Parameter(Mandatory = $true)][string]$Text)

        $clean = ConvertTo-PlainText -Text $Text
        $lines = $clean -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }

        return @(
            $lines |
                ForEach-Object { $_ -replace '^[-*]\s*', '' } |
                ForEach-Object { $_ -replace '^[•]\s*', '' } |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ }
        )
    }

    function Normalize-LinkTarget {
        param([Parameter(Mandatory = $true)][string]$Target)

        $normalized = $Target.Trim()
        if ($normalized -match '[{}]') { return $null }
        if ($normalized.Contains('#')) { $normalized = $normalized.Split('#', 2)[0] }
        $normalized = [System.IO.Path]::GetFileNameWithoutExtension($normalized)
        if ([string]::IsNullOrWhiteSpace($normalized)) { return $null }
        return $normalized
    }

    function Get-VaultStats {
        $allMdFiles = Get-ChildItem -Path $WikiPath, $SystemPath -Filter '*.md'
        $wikiNotes = Get-ChildItem -Path $WikiPath -Filter '*.md'
        $noteCount = $wikiNotes.Count

        $totalLinks = 0
        foreach ($file in $allMdFiles) {
            $content = Get-Content -Path $file.FullName -Raw
            $totalLinks += ([regex]::Matches($content, '\[\[')).Count
        }

        $allNoteNames = $wikiNotes.BaseName
        $allContent = (($allMdFiles | Get-Content -Raw | Out-String) -replace "`0", '')
        $orphanCount = 0
        foreach ($note in $allNoteNames) {
            $pattern = "\[\[(?:[^|\]]*/)?{0}(?:\.md)?(?:\]|\||#)" -f [regex]::Escape($note)
            if ($allContent -notmatch $pattern) {
                $orphanCount++
            }
        }

        # --- Semantic Orphans ---
        $semanticOrphanCount = 0
        try {
            $embRows = Invoke-SqliteQuery -Query "SELECT NoteName, Embedding FROM NoteEmbeddings"
            if ($embRows.Count -lt $noteCount) {
                Write-Verbose "Skipping semantic orphan count because embeddings are incomplete ($($embRows.Count)/$noteCount)."
            } elseif ($embRows.Count -gt 0) {
                # Normalize embeddings
                $normalized = @{}
                $noteNames = @()
                foreach ($row in $embRows) {
                    $vec = [double[]]($row.Embedding | ConvertFrom-Json)
                    $mag = 0.0
                    foreach ($v in $vec) { $mag += $v * $v }
                    $mag = [Math]::Sqrt($mag)
                    if ($mag -gt 0) {
                        $norm = [double[]]::new($vec.Length)
                        for ($k = 0; $k -lt $vec.Length; $k++) { $norm[$k] = $vec[$k] / $mag }
                        $normalized[$row.NoteName] = $norm
                        $noteNames += $row.NoteName
                    }
                }

                # Load existing links
                $linkRows = Invoke-SqliteQuery -Query "SELECT Source, Target FROM Links"
                $existingLinks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                foreach ($link in $linkRows) {
                    $existingLinks.Add("$($link.Source)|$($link.Target)") | Out-Null
                    $existingLinks.Add("$($link.Target)|$($link.Source)") | Out-Null
                }

                # Count pairs above 0.80 threshold with no link
                for ($i = 0; $i -lt $noteNames.Count; $i++) {
                    $a = $noteNames[$i]
                    $va = $normalized[$a]
                    for ($j = $i + 1; $j -lt $noteNames.Count; $j++) {
                        $b = $noteNames[$j]
                        if ($existingLinks.Contains("$a|$b")) { continue }
                        $vb = $normalized[$b]
                        $dot = 0.0
                        for ($k = 0; $k -lt $va.Length; $k++) { $dot += $va[$k] * $vb[$k] }
                        if ($dot -ge 0.80) {
                            $semanticOrphanCount++
                        }
                    }
                }
            }
        } catch {
            Write-Verbose "Could not compute semantic orphans: $_"
        }

        $brokenLinkCount = 0
        $validNoteNames = @(
            (Get-ChildItem -Path $VaultRoot -Filter '*.md' -ErrorAction SilentlyContinue).BaseName
            (Get-ChildItem -Path $WikiPath -Filter '*.md' -Recurse -ErrorAction SilentlyContinue).BaseName
            (Get-ChildItem -Path $SystemPath -Filter '*.md' -Recurse -ErrorAction SilentlyContinue).BaseName
        ) | Select-Object -Unique
        foreach ($file in $allMdFiles) {
            $content = Get-Content -Path $file.FullName -Raw
            $content = [regex]::Replace($content, '(?s)```.*?```', '')
            $matches = [regex]::Matches($content, '(?<!`)\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')
            foreach ($match in $matches) {
                $target = Normalize-LinkTarget $match.Groups[1].Value
                if ($null -eq $target) { continue }
                if ($validNoteNames -notcontains $target) {
                    $brokenLinkCount++
                }
            }
        }

        $linkDensity = if ($noteCount -gt 0) { [math]::Round($totalLinks / $noteCount, 2) } else { 0 }
        # Penalty: 2 for orphan, 5 for broken, 1 for semantic orphan
        $healthScore = [math]::Max(0, 100 - ($orphanCount * 2) - ($brokenLinkCount * 5) - ($semanticOrphanCount * 1))

        return [PSCustomObject]@{
            TotalNotes   = $noteCount
            TotalLinks   = $totalLinks
            LinkDensity  = $linkDensity
            OrphanCount  = $orphanCount
            SemanticOrphans = $semanticOrphanCount
            BrokenLinks  = $brokenLinkCount
            HealthScore  = $healthScore
        }
    }

    function Get-TopHubs {
        $query = @'
SELECT Target AS Note, COUNT(*) AS Incoming
FROM Links
GROUP BY Target
ORDER BY Incoming DESC, Target ASC
LIMIT 5;
'@

        return Invoke-SqliteQuery -Query $query
    }

    function Get-LatestSessionPage {
        param(
            [Parameter(Mandatory = $false)]
            [string]$RequiredSection
        )

        $query = @'
SELECT Title, Content, Modified
FROM Pages
WHERE Title LIKE 'Session %'
ORDER BY Modified DESC, Title DESC
LIMIT 25;
'@

        $result = Invoke-SqliteQuery -Query $query
        if ([string]::IsNullOrWhiteSpace($RequiredSection)) {
            if ($result.Count -gt 0) {
                return $result[0]
            }

            return $null
        }

        foreach ($page in $result) {
            $sectionBody = Get-MarkdownSectionBody -Content $page.Content -Section $RequiredSection
            if (-not [string]::IsNullOrWhiteSpace($sectionBody)) {
                return $page
            }
        }

        return $null
    }

    function Get-SessionActivity {
        param($SessionPage)

        if (-not $SessionPage) {
            return [PSCustomObject]@{
                Actions     = @()
                Seam        = @()
                ActionCount = 0
            }
        }

        $actions = @()
        $seam = @()
        $actionCount = 0
        $actionsBody = Get-MarkdownSectionBody -Content $SessionPage.Content -Section 'Actions'
        if (-not [string]::IsNullOrWhiteSpace($actionsBody)) {
            $actionLines = @(Split-ActivityLines -Text $actionsBody)
            $actionCount = $actionLines.Count
            foreach ($line in ($actionLines | Select-Object -Last 4)) {
                $actions += [PSCustomObject]@{
                    Timestamp = $SessionPage.Modified
                    Detail    = $line
                }
            }
        }

        $currentSeamBody = Get-MarkdownSectionBody -Content $SessionPage.Content -Section 'Current Seam'
        if (-not [string]::IsNullOrWhiteSpace($currentSeamBody)) {
            $currentSeamLines = @(Split-ActivityLines -Text $currentSeamBody)
            if ($currentSeamLines.Count -gt 0) {
                $seam += [PSCustomObject]@{
                    Timestamp = $SessionPage.Modified
                    Title     = 'Current Seam'
                    Detail    = ($currentSeamLines -join ' | ')
                }
            }
        }

        $nextStepsBody = Get-MarkdownSectionBody -Content $SessionPage.Content -Section 'Next Steps'
        if (-not [string]::IsNullOrWhiteSpace($nextStepsBody)) {
            $nextStepLines = @(Split-ActivityLines -Text $nextStepsBody)
            if ($nextStepLines.Count -gt 0) {
                $seam += [PSCustomObject]@{
                    Timestamp = $SessionPage.Modified
                    Title     = 'Next Step'
                    Detail    = $nextStepLines[0]
                }
            }
        }

        return [PSCustomObject]@{
            Actions     = $actions
            Seam        = $seam
            ActionCount = $actionCount
        }
    }

    function Get-Tier2ComplianceStats {
        $scripts = Get-ChildItem -Path $SystemPath -Filter '*.ps1'
        $compliantCount = 0

        foreach ($script in $scripts) {
            $content = Get-Content -Path $script.FullName -Raw
            $hasEap = $content -match '(?m)^\s*\$ErrorActionPreference\s*=\s*[''"]Stop[''"]'
            $hasTryCatch = $content -match '(?is)\btry\s*\{.*\}\s*catch\s*\{'
            if ($hasEap -and $hasTryCatch) {
                $compliantCount++
            }
        }

        return [PSCustomObject]@{
            TotalScripts     = $scripts.Count
            CompliantScripts = $compliantCount
            NonCompliant     = ($scripts.Count - $compliantCount)
        }
    }

    function Get-GitStats {
        try {
            $recentCommits = (& git rev-list --count --since='7 days ago' HEAD 2>$null).Trim()
            $headShort = (& git rev-parse --short HEAD 2>$null).Trim()
            $recentCommitLines = @(
                & git log --since='7 days ago' --pretty=format:'%h %s' --max-count=8 2>$null
            )

            if ([string]::IsNullOrWhiteSpace($recentCommits)) {
                $recentCommits = '0'
            }

            return [PSCustomObject]@{
                RecentCommits7d = $recentCommits
                HeadShort       = $headShort
                RecentCommitLines = @($recentCommitLines)
            }
        } catch {
            return [PSCustomObject]@{
                RecentCommits7d = 'n/a'
                HeadShort       = 'n/a'
                RecentCommitLines = @()
            }
        }
    }

    function Get-RecentLogActions {
        if (-not (Test-Path $LogPath)) {
            return @()
        }

        $content = Get-NormalizedContent -Path $LogPath
        $lines = ($content -replace "`r`n", "`n") -split "`n"
        $majorLines = foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }

            if ($trimmed -match '^##\s+\[[0-9]{4}-[0-9]{2}-[0-9]{2}\].+$') {
                ($trimmed -replace '^##\s+', '')
                continue
            }

            if ($trimmed -match '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}\]\s+.+$') {
                $trimmed
                continue
            }

            if ($trimmed -match '^- \[[0-9]{4}-[0-9]{2}-[0-9]{2}(?:\s+[0-9]{2}:[0-9]{2}(?::[0-9]{2})?)?\]\s+.+$') {
                ($trimmed -replace '^- ', '')
                continue
            }

            if ($trimmed -match '^- \*\*[0-9]{4}-[0-9]{2}-[0-9]{2}\s+[0-9]{2}:[0-9]{2}\*\*:\s+.+$') {
                $trimmed
            }
        }

        return @($majorLines | Select-Object -Last 5 | ForEach-Object { ConvertTo-PlainText -Text $_ })
    }

    function ConvertTo-HtmlSafe {
        param([AllowNull()][string]$Value)
        $safeValue = if ([string]::IsNullOrEmpty($Value)) { '' } else { $Value }
        return [System.Net.WebUtility]::HtmlEncode($safeValue)
    }

    function Format-FeedTimestamp {
        param($Value)

        if ($Value -is [DateTime]) {
            return $Value.ToString('MMM dd HH:mm')
        }

        try {
            return ([DateTime]$Value).ToString('MMM dd HH:mm')
        } catch {
            return [string]$Value
        }
    }

    Import-SqliteAssemblies

    Write-Host "Collecting vault metrics..." -ForegroundColor Cyan
    $stats = Get-VaultStats
    $tier2Stats = Get-Tier2ComplianceStats
    $hubs = Get-TopHubs
    $latestSession = Get-LatestSessionPage
    $latestActionSession = Get-LatestSessionPage -RequiredSection 'Actions'
    if (-not $latestActionSession) {
        $latestActionSession = $latestSession
    }

    $sessionActivity = Get-SessionActivity -SessionPage $latestActionSession
    $gitStats = Get-GitStats
    $logActions = Get-RecentLogActions
    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm'

    $hubRows = if ($hubs.Count -gt 0) {
        ($hubs | ForEach-Object {
            "<tr><td class='rank'>$(ConvertTo-HtmlSafe $_.Note)</td><td class='value'>$($_.Incoming)</td></tr>"
        }) -join [Environment]::NewLine
    } else {
        "<tr><td colspan='2'>No hub data available.</td></tr>"
    }

    $sessionItems = if ($sessionActivity.Actions.Count -gt 0) {
        ($sessionActivity.Actions | ForEach-Object {
            $stamp = ConvertTo-HtmlSafe (Format-FeedTimestamp -Value $_.Timestamp)
            $detail = ConvertTo-HtmlSafe $_.Detail
            "<li><span class='feed-meta'>$stamp | action</span><span class='feed-text'>$detail</span></li>"
        }) -join [Environment]::NewLine
    } else {
        "<li><span class='feed-text'>No recent PoShWiKi session actions found.</span></li>"
    }

    $sessionSeamItems = if ($sessionActivity.Seam.Count -gt 0) {
        ($sessionActivity.Seam | ForEach-Object {
            $stamp = ConvertTo-HtmlSafe (Format-FeedTimestamp -Value $_.Timestamp)
            $title = ConvertTo-HtmlSafe $_.Title
            $detail = ConvertTo-HtmlSafe $_.Detail
            "<li><span class='feed-meta'>$stamp | $title</span><span class='feed-text'>$detail</span></li>"
        }) -join [Environment]::NewLine
    } else {
        "<li><span class='feed-text'>No current seam summary found.</span></li>"
    }

    $logItems = if ($logActions.Count -gt 0) {
        ($logActions | ForEach-Object {
            "<li><span class='feed-text'>$(ConvertTo-HtmlSafe (ConvertTo-PlainText -Text $_))</span></li>"
        }) -join [Environment]::NewLine
    } else {
        "<li><span class='feed-text'>No recent log actions found.</span></li>"
    }

    $sessionTitle = if ($latestSession) { $latestSession.Title } else { 'No session page' }
    $sessionActionTitle = if ($latestActionSession) { $latestActionSession.Title } else { 'No session page' }
    $sessionActionFoot = if ($sessionActionTitle -ne $sessionTitle) {
        "Action lines recorded on <span class='terminal'>$(ConvertTo-HtmlSafe $sessionActionTitle)</span>. Latest session page is <span class='terminal'>$(ConvertTo-HtmlSafe $sessionTitle)</span>."
    } else {
        "Action lines recorded on <span class='terminal'>$(ConvertTo-HtmlSafe $sessionTitle)</span>."
    }
    $sessionActionCallout = if ($sessionActionTitle -ne $sessionTitle) {
        "Latest page with an <span class='terminal'>Actions</span> section: <span class='terminal'>$(ConvertTo-HtmlSafe $sessionActionTitle)</span>. Latest session page: <span class='terminal'>$(ConvertTo-HtmlSafe $sessionTitle)</span>."
    } else {
        "Latest session page: <span class='terminal'>$(ConvertTo-HtmlSafe $sessionTitle)</span>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Vault Pulse Dashboard</title>
  <style>
    :root {
      --bg: #0b0d10;
      --panel: #11151a;
      --panel-2: #161c22;
      --text: #e7ecef;
      --muted: #95a1aa;
      --line: #2a333c;
      --accent: #d7f75b;
      --accent-soft: rgba(215, 247, 91, 0.12);
      --danger: #ff8a80;
      --mono: "Cascadia Code", "IBM Plex Mono", "Consolas", monospace;
      --sans: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
    }

    * { box-sizing: border-box; }
    body {
      margin: 0;
      background:
        radial-gradient(circle at top right, rgba(215, 247, 91, 0.08), transparent 28%),
        linear-gradient(180deg, #0b0d10 0%, #090b0d 100%);
      color: var(--text);
      font-family: var(--sans);
      line-height: 1.45;
    }

    .shell {
      max-width: 1280px;
      margin: 0 auto;
      padding: 24px;
    }

    .topbar {
      display: flex;
      align-items: center;
      gap: 10px;
      font-family: var(--mono);
      font-size: 12px;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 16px;
      padding: 12px 14px;
      border: 1px solid var(--line);
      border-radius: 12px;
      background: rgba(255,255,255,0.02);
    }

    .topbar .brand {
      color: var(--accent);
    }

    .topbar .sep {
      color: var(--line);
    }

    .topbar a {
      color: var(--text);
      text-decoration: none;
    }

    .topbar a:hover {
      color: var(--accent);
    }

    .masthead {
      display: grid;
      grid-template-columns: 1.3fr .7fr;
      gap: 16px;
      margin-bottom: 16px;
    }

    .panel {
      background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0)), var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 18px 20px;
      box-shadow: inset 0 1px 0 rgba(255,255,255,0.03);
    }

    .terminal {
      font-family: var(--mono);
      letter-spacing: 0.02em;
    }

    .eyebrow, .feed-meta, .metric-label, .kicker {
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      font-size: 11px;
    }

    h1, h2, h3, p { margin: 0; }
    h1 {
      font-size: clamp(28px, 4vw, 54px);
      line-height: 0.95;
      margin-top: 8px;
    }

    .subhead {
      margin-top: 12px;
      color: var(--muted);
      max-width: 58ch;
    }

    .stamp {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      margin-top: 18px;
      padding-top: 14px;
      border-top: 1px solid var(--line);
      color: var(--muted);
      font-family: var(--mono);
      font-size: 12px;
    }

    .hero-score {
      display: flex;
      flex-direction: column;
      justify-content: center;
      min-height: 100%;
      background: linear-gradient(180deg, var(--accent-soft), transparent 45%), var(--panel-2);
    }

    .score {
      font-family: var(--mono);
      font-size: clamp(56px, 8vw, 96px);
      color: var(--accent);
      line-height: 0.9;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(12, 1fr);
      gap: 16px;
    }

    .metrics {
      grid-column: span 12;
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px;
    }

    .metric {
      min-height: 132px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .metric-value {
      font-family: var(--mono);
      font-size: clamp(28px, 4vw, 42px);
      margin-top: 16px;
    }

    .metric-foot {
      color: var(--muted);
      font-size: 13px;
      border-top: 1px solid var(--line);
      padding-top: 12px;
    }

    .topology { grid-column: span 5; }
    .activity { grid-column: span 7; }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 14px;
      font-family: var(--mono);
      font-size: 14px;
    }

    th, td {
      padding: 10px 0;
      border-bottom: 1px solid var(--line);
      text-align: left;
    }

    th {
      color: var(--muted);
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    td.value {
      text-align: right;
      color: var(--accent);
    }

    ul.feed {
      list-style: none;
      padding: 0;
      margin: 14px 0 0;
      display: grid;
      gap: 12px;
    }

    ul.feed li {
      border-left: 2px solid var(--line);
      padding-left: 12px;
    }

    .feed-text {
      display: block;
      margin-top: 4px;
      white-space: pre-wrap;
    }

    .split {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
      margin-top: 16px;
    }

    .callout {
      margin-top: 14px;
      padding: 12px 14px;
      border: 1px solid var(--line);
      border-radius: 10px;
      background: rgba(255,255,255,0.02);
      color: var(--muted);
      font-size: 13px;
    }

    .commit-strip {
      margin-top: 16px;
      padding: 12px 14px;
      border: 1px solid var(--line);
      border-radius: 12px;
      background: rgba(255,255,255,0.02);
    }

    .commit-strip h3 {
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--muted);
      margin-bottom: 10px;
    }

    .commit-track {
      display: flex;
      gap: 10px;
      overflow-x: auto;
      padding-bottom: 4px;
      scrollbar-color: var(--line) transparent;
    }

    .commit-track::-webkit-scrollbar { height: 6px; }
    .commit-track::-webkit-scrollbar-thumb { background: var(--line); border-radius: 999px; }

    .commit-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      white-space: nowrap;
      font-family: var(--mono);
      font-size: 12px;
      color: var(--text);
      border: 1px solid var(--line);
      border-radius: 999px;
      padding: 8px 12px;
      background: rgba(255,255,255,0.02);
      flex: 0 0 auto;
    }

    .commit-pill .sha {
      color: var(--accent);
    }

    .health-ok { color: var(--accent); }
    .health-warn { color: var(--danger); }

    @media (max-width: 980px) {
      .masthead, .metrics, .split { grid-template-columns: 1fr; }
      .topology, .activity { grid-column: span 12; }
    }
  </style>
</head>
<body>
  <main class="shell">
    <nav class="topbar">
      <span class="brand">VULTURE</span>
      <span class="sep">/</span>
      <span>PORTAL</span>
      <span class="sep">/</span>
      <a href="index.html">INDEX</a>
      <span class="sep">/</span>
      <span>DASHBOARD</span>
    </nav>
    <section class="masthead">
      <div class="panel">
        <div class="eyebrow terminal">Vault Pulse / Live Substrate Dashboard</div>
        <h1>Vulture Engine<br>Operational Surface</h1>
        <p class="subhead">Text-first telemetry for the vault substrate: health, centrality, and the most recent motion across system logs and PoShWiKi memory.</p>
        <div class="stamp">
          <span>Generated $generatedAt</span>
          <span>Source: SQLite + Markdown</span>
        </div>
      </div>
      <div class="panel hero-score">
        <div class="kicker terminal">Vault Health</div>
        <div class="score">$($stats.HealthScore)%</div>
        <div class="$(if ($stats.HealthScore -ge 100) { 'health-ok' } else { 'health-warn' }) terminal">orphan=$($stats.OrphanCount) / broken=$($stats.BrokenLinks) / neural_gap=$($stats.SemanticOrphans)</div>
      </div>
    </section>

    <section class="metrics">
      <article class="panel metric">
        <div class="metric-label terminal">Total Notes</div>
        <div class="metric-value">$($stats.TotalNotes)</div>
        <div class="metric-foot">Wiki notes currently indexed under <span class="terminal">01_Wiki</span>.</div>
      </article>
      <article class="panel metric">
        <div class="metric-label terminal">Link Density</div>
        <div class="metric-value">$($stats.LinkDensity)</div>
        <div class="metric-foot">Average wikilinks per note across the active vault corpus.</div>
      </article>
      <article class="panel metric">
        <div class="metric-label terminal">Neural Gap</div>
        <div class="metric-value">$($stats.SemanticOrphans)</div>
        <div class="metric-foot">"Semantic orphans" — highly similar notes lacking a formal wikilink.</div>
      </article>
      <article class="panel metric">
        <div class="metric-label terminal">PoShWiKi Pages</div>
        <div class="metric-value">$(Invoke-SqliteQuery -Query 'SELECT COUNT(*) AS PageCount FROM Pages;' | Select-Object -ExpandProperty PageCount)</div>
        <div class="metric-foot">Structured pages currently stored in <span class="terminal">wiki.db</span>.</div>
      </article>
      <article class="panel metric">
        <div class="metric-label terminal">Session Actions</div>
        <div class="metric-value">$($sessionActivity.ActionCount)</div>
        <div class="metric-foot">$sessionActionFoot</div>
      </article>
      <article class="panel metric">
        <div class="metric-label terminal">Tier-2 Compliance</div>
        <div class="metric-value">$($tier2Stats.CompliantScripts)/$($tier2Stats.TotalScripts)</div>
        <div class="metric-foot">PowerShell scripts passing EAP + try/catch enforcement. Non-compliant: $($tier2Stats.NonCompliant).</div>
      </article>
    </section>

    <section class="grid">
      <article class="panel topology">
        <div class="eyebrow terminal">Knowledge Topology</div>
        <h2>Top 5 Hubs</h2>
        <table>
          <thead>
            <tr><th>Note</th><th style="text-align:right">Incoming</th></tr>
          </thead>
          <tbody>
            $hubRows
          </tbody>
        </table>
        <div class="callout">Centrality is computed from the <span class="terminal">Links</span> table in PoShWiKi by incoming link count.</div>
      </article>

      <article class="panel activity">
        <div class="eyebrow terminal">Activity Feed</div>
        <h2>Recent Motion</h2>
        <div class="split">
          <section>
            <h3>PoShWiKi Session</h3>
            <div class="callout">$sessionActionCallout</div>
            <ul class="feed">
              $sessionItems
            </ul>
            <div class="callout">Current seam and immediate handoff state.</div>
            <ul class="feed">
              $sessionSeamItems
            </ul>
          </section>
          <section>
            <h3>log.md Major Actions</h3>
            <div class="callout">Last five major actions pulled from <span class="terminal">02_System/log.md</span>.</div>
            <ul class="feed">
              $logItems
            </ul>
          </section>
        </div>
      </article>
    </section>

    <section class="commit-strip">
      <h3>Recent Commits</h3>
      <div class="commit-track">
        $(
            if ($gitStats.RecentCommitLines.Count -gt 0) {
                ($gitStats.RecentCommitLines | ForEach-Object {
                    if ($_ -match '^([0-9a-f]+)\s+(.+)$') {
                        "<span class='commit-pill'><span class='sha'>$($matches[1])</span><span>$([System.Net.WebUtility]::HtmlEncode($matches[2]))</span></span>"
                    } else {
                        "<span class='commit-pill'>$([System.Net.WebUtility]::HtmlEncode($_))</span>"
                    }
                }) -join [Environment]::NewLine
            } else {
                "<span class='commit-pill'>No recent commits found.</span>"
            }
        )
      </div>
    </section>
  </main>
</body>
</html>
"@

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($OutputPath, $html, $utf8NoBom)

    Write-Host "Dashboard generated at $OutputPath" -ForegroundColor Green
    [PSCustomObject]@{
        OutputPath     = $OutputPath
        HealthScore    = $stats.HealthScore
        TotalNotes     = $stats.TotalNotes
        LinkDensity    = $stats.LinkDensity
        HubCount       = $hubs.Count
        SessionActions = $sessionActivity.ActionCount
        Tier2Compliant = $tier2Stats.CompliantScripts
        Tier2Total     = $tier2Stats.TotalScripts
        RecentCommits7d = $gitStats.RecentCommits7d
        RecentCommitLines = $gitStats.RecentCommitLines.Count
        SessionTitle      = $sessionTitle
        SessionActionPage = $sessionActionTitle
        LogActionCount    = $logActions.Count
    }
}
catch {
    Write-Error $_
    exit 1
}
