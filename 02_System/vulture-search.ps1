<#
.SYNOPSIS
    The Vulture Engine: Graph-Aware Discovery (Optimized & Ranked)
.DESCRIPTION
    A specialized retrieval engine that uses a weighted ranking model to surface 
    relevant knowledge and tools. Leverages the PoShWiKi graph for second-order discovery.
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    [switch]$Semantic
)
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot
    $wikiPath = Join-Path $VaultRoot "01_Wiki"
    $registryPath = Join-Path $VaultRoot "02_System/tool-registry.md"
    $dbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($dbPath)) { $dbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db" }
    $LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"

# --- 1. Load SQLite Assemblies ---
function Import-SqliteAssemblies {
    $dlls = @("SQLitePCLRaw.core.dll", "SQLitePCLRaw.provider.e_sqlite3.dll", "SQLitePCLRaw.batteries_v2.dll", "Microsoft.Data.Sqlite.dll")
    foreach ($dll in $dlls) {
        $path = Join-Path $LibPath $dll
        if (Test-Path $path) {
            try {
                [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
            } catch {
                Add-Type -Path $path -ErrorAction SilentlyContinue
            }
        }
    }
    $os = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
    $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
    $nativeLibName = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
    $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLibName"
    if (Test-Path $nativePath) {
        try {
            [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
        } catch {}
    }
    try { [SQLitePCL.Batteries]::Init() } catch {}
}
    Import-SqliteAssemblies

# --- 2. Ranking & Retrieval Functions ---
function Get-SemanticNeighbors([string]$queryText, [int]$topN = 8) {
    $apiKey = $env:GEMINI_API_KEY
    if ([string]::IsNullOrWhiteSpace($apiKey)) { return @() }

    $embedUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=$apiKey"
    $body     = @{ model = "models/gemini-embedding-001"; content = @{ parts = @(@{ text = $queryText }) } } | ConvertTo-Json -Depth 4 -Compress
    try {
        $resp     = Invoke-RestMethod -Uri $embedUrl -Method Post -Body $body -ContentType "application/json"
        $queryVec = [double[]]$resp.embedding.values
    } catch { return @() }

    # Normalize query vector
    $qMag = 0.0; foreach ($v in $queryVec) { $qMag += $v * $v }
    $qMag = [Math]::Sqrt($qMag)
    if ($qMag -gt 0) { for ($k = 0; $k -lt $queryVec.Length; $k++) { $queryVec[$k] /= $qMag } }

    # Load stored embeddings
    $conn = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$dbPath")
    $conn.Open()
    $embRows = @()
    try {
        $cmd = $conn.CreateCommand(); $cmd.CommandText = "SELECT NoteName, Embedding FROM NoteEmbeddings"
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) { $embRows += [PSCustomObject]@{ Name = $reader.GetString(0); Emb = $reader.GetString(1) } }
    } finally { $conn.Close() }

    if ($embRows.Count -eq 0) { return @() }

    $results = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($row in $embRows) {
        $vec = [double[]]($row.Emb | ConvertFrom-Json)
        $mag = 0.0; foreach ($v in $vec) { $mag += $v * $v }
        $mag = [Math]::Sqrt($mag)
        if ($mag -eq 0) { continue }
        $dot = 0.0
        for ($k = 0; $k -lt $queryVec.Length; $k++) { $dot += $queryVec[$k] * ($vec[$k] / $mag) }
        $results.Add([PSCustomObject]@{ Name = $row.Name; Similarity = $dot }) | Out-Null
    }

    return $results | Sort-Object Similarity -Descending | Select-Object -First $topN
}
function Get-GraphContext([string[]]$SeedNotes) {
    if ($SeedNotes.Count -eq 0) { return @() }
    $connString = "Data Source=$dbPath"
    $conn = [Microsoft.Data.Sqlite.SqliteConnection]::new($connString)
    try {
        $conn.Open()
        # Single query to get all neighbors and their incoming link counts (Hub Score)
        $inClause = "'$($SeedNotes -join "','")'"
        $sql = @"
            WITH Seeds AS (SELECT value as Name FROM (SELECT $inClause as list) CROSS JOIN json_each('["' || replace(list, "','", '","') || '"]')),
                 Neighbors AS (
                    SELECT Target as Related, Source as Via FROM Links WHERE Source IN (SELECT Name FROM Seeds)
                    UNION
                    SELECT Source as Related, Target as Via FROM Links WHERE Target IN (SELECT Name FROM Seeds)
                 ),
                 HubScores AS (
                    SELECT Target as Note, COUNT(*) as Incoming FROM Links GROUP BY Target
                 )
            SELECT n.Related, n.Via, COALESCE(h.Incoming, 0) as HubWeight
            FROM Neighbors n
            LEFT JOIN HubScores h ON n.Related = h.Note
            WHERE n.Related NOT IN (SELECT Name FROM Seeds)
"@
        $cmd = $conn.CreateCommand(); $cmd.CommandText = $sql
        $reader = $cmd.ExecuteReader()
        $rawRelated = @()
        while ($reader.Read()) {
            $rawRelated += [PSCustomObject]@{
                Note      = $reader.GetString(0)
                Via       = $reader.GetString(1)
                HubWeight = $reader.GetInt32(2)
            }
        }
        return $rawRelated
    } catch { return @() } finally { $conn.Close() }
}

# --- 3. Execution ---
    Write-Host "`n=== VULTURE ENGINE: RANKED CONTEXT FOR '$($Query.ToUpper())' ===" -ForegroundColor Cyan

# Tokenize query for better matching
    $tokens = $Query.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)

# Primary Search with basic scoring
    $primaryScores = @{}
    $MdFiles = Get-ChildItem -Path $wikiPath -Filter *.md
    foreach ($file in $MdFiles) {
        $score = 0
        $name = $file.BaseName
        $content = Get-Content $file.FullName -Raw

        foreach ($token in $tokens) {
            $t = [regex]::Escape($token)
            if ($name -match $t) { $score += 10 }
            if ($content -match "aliases: .*$t") { $score += 8 }
            if ($content -match "(?m)^# .*$t") { $score += 5 }
            if ($content -match $t) { $score += 1 }
        }

        if ($score -gt 0) { $primaryScores[$name] = $score }
    }

    $sortedPrimary = $primaryScores.GetEnumerator() | Sort-Object Value -Descending
    $topSeeds = $sortedPrimary | Select-Object -First 5 -ExpandProperty Key

    # Graph expansion
    $relatedRaw = Get-GraphContext -SeedNotes $topSeeds
    $relatedScores = @{}
    foreach ($rel in $relatedRaw) {
        # Score = (Connection to seed weight) + (Hub weight) + (MOC bonus)
        $seedWeight = $primaryScores[$rel.Via]
        if ($null -eq $seedWeight) { $seedWeight = 1 }

        $current = if ($relatedScores.ContainsKey($rel.Note)) { $relatedScores[$rel.Note] } else { 0 }
        $mocBonus = if ($rel.Note -match "-moc$") { 15 } else { 0 }

        $relatedScores[$rel.Note] = $current + $seedWeight + $rel.HubWeight + $mocBonus
    }

    # --- 4. Semantic Search (optional) ---
    $semanticResults = @()
    if ($Semantic) {
        $semanticResults = Get-SemanticNeighbors -queryText $Query
    }

    # --- 5. Tool Search ---
    $tools = if (Test-Path $registryPath) {
        $regContent = Get-Content $registryPath -Raw
        $regContent -split '(?=## )' | Where-Object {
            $block = $_; $tokens | Where-Object { $block -match [regex]::Escape($_) }
        } | ForEach-Object { if ($_ -match "## (.*)") { $matches[1].Trim() } }
    }

# --- 5. Output ---
    Write-Host "`n[PRIMARY KNOWLEDGE]" -ForegroundColor Yellow
    if ($sortedPrimary) {
        $sortedPrimary | Select-Object -First 8 | ForEach-Object {
            Write-Host " - [[$($_.Key)]] (Score: $($_.Value))"
        }
    } else { Write-Host " - No primary matches." }

    Write-Host "`n[SECOND-ORDER DISCOVERY (Ranked Graph)]" -ForegroundColor Green
    if ($relatedScores.Count -gt 0) {
        $relatedScores.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
            Write-Host " - [[$($_.Key)]] (Rank: $($_.Value))"
        }
    } else { Write-Host " - No graph neighbors identified." }

    if ($Semantic) {
        Write-Host "`n[SEMANTIC NEIGHBORS]" -ForegroundColor Magenta
        if ($semanticResults.Count -gt 0) {
            $semanticResults | ForEach-Object {
                Write-Host (" - [[$($_.Name)]] (Sim: {0:F3})" -f $_.Similarity)
            }
        } else { Write-Host " - No embeddings found. Run sync-embeddings.ps1 first." }
    }

    Write-Host "`n[AVAILABLE TOOLS]" -ForegroundColor Yellow
    if ($tools) { $tools | ForEach-Object { Write-Host " - Match: $_" } } else { Write-Host " - No tool matches." }

    Write-Host "`n=== PACKET COMPLETE ===" -ForegroundColor Cyan
} catch {
    Write-Error "vulture-search.ps1 failed: $_"
    exit 1
}
