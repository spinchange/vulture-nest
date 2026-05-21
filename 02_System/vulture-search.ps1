<#
.SYNOPSIS
    The Vulture Engine: graph-aware discovery with optional semantic rank fusion.
.DESCRIPTION
    Combines lexical note matching, semantic similarity from stored embeddings,
    and second-order graph expansion to produce a ranked context packet.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Query,

    [switch]$Semantic,

    [ValidateRange(1, 100)]
    [int]$SemanticCandidates = 12,

    [ValidateRange(0.1, 25.0)]
    [double]$SemanticWeight = 12.0
)

$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot
    $WikiPath = Join-Path $VaultRoot "01_Wiki"
    $RegistryPath = Join-Path $VaultRoot "02_System/tool-registry.md"
    $DbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db"
    }
    $LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"

    function Import-SqliteAssemblies {
        $dlls = @(
            "SQLitePCLRaw.core.dll",
            "SQLitePCLRaw.provider.e_sqlite3.dll",
            "SQLitePCLRaw.batteries_v2.dll",
            "Microsoft.Data.Sqlite.dll"
        )

        foreach ($dll in $dlls) {
            $path = Join-Path $LibPath $dll
            if (-not (Test-Path $path)) {
                continue
            }

            try {
                [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
            } catch {
                Add-Type -Path $path -ErrorAction SilentlyContinue
            }
        }

        $os = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
        $nativeLibName = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
        $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLibName"
        if (Test-Path $nativePath) {
            try {
                [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
            } catch {
            }
        }

        try {
            [SQLitePCL.Batteries]::Init()
        } catch {
        }
    }

    function Normalize-Vector {
        param(
            [Parameter(Mandatory = $true)]
            [double[]]$Vector
        )

        $magnitude = 0.0
        foreach ($value in $Vector) {
            $magnitude += $value * $value
        }

        $magnitude = [Math]::Sqrt($magnitude)
        if ($magnitude -eq 0) {
            return $null
        }

        $normalized = [double[]]::new($Vector.Length)
        for ($index = 0; $index -lt $Vector.Length; $index++) {
            $normalized[$index] = $Vector[$index] / $magnitude
        }

        return $normalized
    }

    function Get-NoteEmbeddings {
        $rows = [System.Collections.Generic.List[object]]::new()
        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
        try {
            $connection.Open()
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT NoteName, Embedding FROM NoteEmbeddings"
            $reader = $command.ExecuteReader()
            while ($reader.Read()) {
                $rawVector = [double[]]($reader.GetString(1) | ConvertFrom-Json)
                $normalized = Normalize-Vector -Vector $rawVector
                if ($null -eq $normalized) {
                    continue
                }

                $rows.Add([PSCustomObject]@{
                    Name       = $reader.GetString(0)
                    Normalized = $normalized
                }) | Out-Null
            }
        } finally {
            $connection.Close()
        }

        return $rows
    }

    function Get-QueryEmbedding {
        param(
            [Parameter(Mandatory = $true)]
            [string]$QueryText
        )

        $apiKey = $env:GEMINI_API_KEY
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            return $null
        }

        $embedUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=$apiKey"
        $body = @{
            model = "models/gemini-embedding-001"
            content = @{
                parts = @(@{ text = $QueryText })
            }
        } | ConvertTo-Json -Depth 4 -Compress

        try {
            $response = Invoke-RestMethod -Uri $embedUrl -Method Post -Body $body -ContentType "application/json"
            return Normalize-Vector -Vector ([double[]]$response.embedding.values)
        } catch {
            return $null
        }
    }

    function Get-SemanticNeighbors {
        param(
            [Parameter(Mandatory = $true)]
            [string]$QueryText,

            [Parameter(Mandatory = $true)]
            [System.Collections.IEnumerable]$Embeddings,

            [int]$TopN = 8
        )

        $queryVector = Get-QueryEmbedding -QueryText $QueryText
        if ($null -eq $queryVector) {
            return @()
        }

        $results = [System.Collections.Generic.List[object]]::new()
        foreach ($row in $Embeddings) {
            $dot = 0.0
            for ($index = 0; $index -lt $queryVector.Length; $index++) {
                $dot += $queryVector[$index] * $row.Normalized[$index]
            }

            $results.Add([PSCustomObject]@{
                Name       = $row.Name
                Similarity = $dot
            }) | Out-Null
        }

        return $results |
            Sort-Object Similarity -Descending |
            Select-Object -First $TopN
    }

    function Get-GraphContext {
        param(
            [string[]]$SeedNotes
        )

        if ($SeedNotes.Count -eq 0) {
            return @()
        }

        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
        try {
            $connection.Open()
            $quotedSeeds = $SeedNotes | ForEach-Object { "'" + $_.Replace("'", "''") + "'" }
            $inClause = $quotedSeeds -join ","
            $sql = @"
WITH SeedNotes AS (
    SELECT value AS Name
    FROM json_each('["' || replace('$($SeedNotes -join "','")', ',', '","') || '"]')
),
Neighbors AS (
    SELECT Target AS Related, Source AS Via FROM Links WHERE Source IN ($inClause)
    UNION
    SELECT Source AS Related, Target AS Via FROM Links WHERE Target IN ($inClause)
),
HubScores AS (
    SELECT Target AS Note, COUNT(*) AS Incoming
    FROM Links
    GROUP BY Target
)
SELECT
    n.Related,
    n.Via,
    COALESCE(h.Incoming, 0) AS HubWeight
FROM Neighbors n
LEFT JOIN HubScores h ON n.Related = h.Note
WHERE n.Related NOT IN ($inClause)
"@
            $command = $connection.CreateCommand()
            $command.CommandText = $sql
            $reader = $command.ExecuteReader()
            $related = [System.Collections.Generic.List[object]]::new()
            while ($reader.Read()) {
                $related.Add([PSCustomObject]@{
                    Note      = $reader.GetString(0)
                    Via       = $reader.GetString(1)
                    HubWeight = $reader.GetInt32(2)
                }) | Out-Null
            }

            return $related
        } catch {
            return @()
        } finally {
            $connection.Close()
        }
    }

    Import-SqliteAssemblies

    Write-Host "`n=== VULTURE ENGINE: RANKED CONTEXT FOR '$($Query.ToUpperInvariant())' ===" -ForegroundColor Cyan

    $tokens = $Query.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    $embeddings = @()
    $semanticResults = @()
    $semanticByName = @{}

    if ($Semantic) {
        $embeddings = Get-NoteEmbeddings
        if ($embeddings.Count -gt 0) {
            $semanticResults = Get-SemanticNeighbors -QueryText $Query -Embeddings $embeddings -TopN $SemanticCandidates
            foreach ($result in $semanticResults) {
                $semanticByName[$result.Name] = $result.Similarity
            }
        }
    }

    $rankedPrimary = [System.Collections.Generic.List[object]]::new()
    $markdownFiles = Get-ChildItem -Path $WikiPath -Filter *.md
    foreach ($file in $markdownFiles) {
        $lexicalScore = 0
        $name = $file.BaseName
        $content = Get-Content $file.FullName -Raw

        foreach ($token in $tokens) {
            $escaped = [regex]::Escape($token)
            if ($name -match $escaped) { $lexicalScore += 10 }
            if ($content -match "aliases: .*$escaped") { $lexicalScore += 8 }
            if ($content -match "(?m)^# .*$escaped") { $lexicalScore += 5 }
            if ($content -match $escaped) { $lexicalScore += 1 }
        }

        $semanticSimilarity = 0.0
        if ($semanticByName.ContainsKey($name)) {
            $semanticSimilarity = [double]$semanticByName[$name]
        }

        $semanticScore = if ($Semantic -and $semanticSimilarity -gt 0) {
            [Math]::Round($semanticSimilarity * $SemanticWeight, 2)
        } else {
            0.0
        }

        $totalScore = [Math]::Round($lexicalScore + $semanticScore, 2)
        if ($totalScore -gt 0) {
            $rankedPrimary.Add([PSCustomObject]@{
                Name               = $name
                LexicalScore       = $lexicalScore
                SemanticSimilarity = $semanticSimilarity
                SemanticScore      = $semanticScore
                TotalScore         = $totalScore
            }) | Out-Null
        }
    }

    $sortedPrimary = $rankedPrimary | Sort-Object `
        @{ Expression = "TotalScore"; Descending = $true }, `
        @{ Expression = "LexicalScore"; Descending = $true }, `
        @{ Expression = "Name"; Descending = $false }
    $topSeeds = @($sortedPrimary | Select-Object -First 5 -ExpandProperty Name)

    $primaryScoreByName = @{}
    foreach ($entry in $sortedPrimary) {
        $primaryScoreByName[$entry.Name] = $entry.TotalScore
    }

    $relatedScores = @{}
    $relatedRaw = Get-GraphContext -SeedNotes $topSeeds
    foreach ($related in $relatedRaw) {
        $seedWeight = if ($primaryScoreByName.ContainsKey($related.Via)) {
            [double]$primaryScoreByName[$related.Via]
        } else {
            1.0
        }

        $semanticBoost = if ($semanticByName.ContainsKey($related.Note)) {
            [Math]::Round([double]$semanticByName[$related.Note] * ($SemanticWeight / 2.0), 2)
        } else {
            0.0
        }

        $mocBonus = if ($related.Note -match "-moc$") { 15 } else { 0 }
        $existing = if ($relatedScores.ContainsKey($related.Note)) { [double]$relatedScores[$related.Note] } else { 0.0 }
        $relatedScores[$related.Note] = [Math]::Round($existing + $seedWeight + $related.HubWeight + $mocBonus + $semanticBoost, 2)
    }

    $tools = if (Test-Path $RegistryPath) {
        $registryContent = Get-Content $RegistryPath -Raw
        $registryContent -split '(?=## )' |
            Where-Object {
                $block = $_
                ($tokens | Where-Object { $block -match [regex]::Escape($_) }).Count -gt 0
            } |
            ForEach-Object {
                if ($_ -match "## (.*)") {
                    $matches[1].Trim()
                }
            }
    }

    $displayedPrimary = @($sortedPrimary | Select-Object -First 8)

    Write-Host "`n[PRIMARY KNOWLEDGE]" -ForegroundColor Yellow
    if ($displayedPrimary.Count -gt 0) {
        $displayedPrimary | ForEach-Object {
            if ($Semantic) {
                Write-Host (" - [[{0}]] (Rank: {1:N2}; Lexical: {2}; Semantic: {3:F3})" -f $_.Name, $_.TotalScore, $_.LexicalScore, $_.SemanticSimilarity)
            } else {
                Write-Host (" - [[{0}]] (Score: {1})" -f $_.Name, $_.LexicalScore)
            }
        }
    } else {
        Write-Host " - No primary matches."
    }

    Write-Host "`n[SECOND-ORDER DISCOVERY (Ranked Graph)]" -ForegroundColor Green
    if ($relatedScores.Count -gt 0) {
        $relatedScores.GetEnumerator() |
            Sort-Object Value -Descending |
            Select-Object -First 10 |
            ForEach-Object {
                Write-Host (" - [[{0}]] (Rank: {1:N2})" -f $_.Key, $_.Value)
            }
    } else {
        Write-Host " - No graph neighbors identified."
    }

    if ($Semantic) {
        Write-Host "`n[SEMANTIC SEEDS]" -ForegroundColor Magenta
        $displayedSemanticSeeds = @(
            $displayedPrimary |
                Where-Object { $_.SemanticSimilarity -gt 0 } |
                Sort-Object `
                    @{ Expression = "SemanticSimilarity"; Descending = $true }, `
                    @{ Expression = "TotalScore"; Descending = $true }, `
                    @{ Expression = "Name"; Descending = $false }
        )
        if ($displayedSemanticSeeds.Count -gt 0) {
            $displayedSemanticSeeds | ForEach-Object {
                Write-Host (" - [[{0}]] (Sim: {1:F3})" -f $_.Name, $_.SemanticSimilarity)
            }
        } else {
            Write-Host " - Semantic ranking unavailable. Ensure GEMINI_API_KEY and NoteEmbeddings are present."
        }
    }

    Write-Host "`n[AVAILABLE TOOLS]" -ForegroundColor Yellow
    if ($tools) {
        $tools | ForEach-Object { Write-Host " - Match: $_" }
    } else {
        Write-Host " - No tool matches."
    }

    Write-Host "`n=== PACKET COMPLETE ===" -ForegroundColor Cyan
} catch {
    Write-Error "vulture-search.ps1 failed: $_"
    exit 1
}
