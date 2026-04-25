<#
.SYNOPSIS
    The Vulture Engine: Graph-Aware Discovery (Optimized & Ranked)
.DESCRIPTION
    A specialized retrieval engine that uses a weighted ranking model to surface 
    relevant knowledge and tools. Leverages the PoShWiKi graph for second-order discovery.
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$VaultRoot = Split-Path -Parent $PSScriptRoot
$wikiPath = Join-Path $VaultRoot "01_Wiki"
$registryPath = Join-Path $VaultRoot "02_System/TOOL_REGISTRY.md"
$dbPath = $env:POSHWIKI_DB_PATH
if ([string]::IsNullOrWhiteSpace($dbPath)) { $dbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db" }
$LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"

# --- 1. Load SQLite Assemblies ---
function Import-SqliteAssemblies {
    $dlls = @("SQLitePCLRaw.core.dll", "SQLitePCLRaw.provider.e_sqlite3.dll", "SQLitePCLRaw.batteries_v2.dll", "Microsoft.Data.Sqlite.dll")
    foreach ($dll in $dlls) {
        $path = Join-Path $LibPath $dll
        if (Test-Path $path) { Add-Type -Path $path -ErrorAction SilentlyContinue }
    }
    $os = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
    $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
    $nativeLibName = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
    $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLibName"
    if (Test-Path $nativePath) { [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null }
    try { [SQLitePCL.Batteries]::Init() } catch {}
}
Import-SqliteAssemblies

# --- 2. Ranking & Retrieval Functions ---
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

# --- 4. Tool Search ---
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

Write-Host "`n[AVAILABLE TOOLS]" -ForegroundColor Yellow
if ($tools) { $tools | ForEach-Object { Write-Host " - Match: $_" } } else { Write-Host " - No tool matches." }

Write-Host "`n=== PACKET COMPLETE ===" -ForegroundColor Cyan
