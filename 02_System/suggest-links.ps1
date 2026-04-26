<#
.SYNOPSIS
    Suggests missing wikilinks based on semantic similarity of note embeddings.
.DESCRIPTION
    Loads all embeddings from NoteEmbeddings, computes pairwise cosine similarity,
    and surfaces pairs above the similarity threshold that have no existing wikilink
    in either direction. These are "semantic orphans" — conceptually adjacent notes
    that are structurally disconnected. Run sync-embeddings.ps1 first.
.PARAMETER Threshold
    Minimum cosine similarity to report (0.0–1.0). Default: 0.80
.PARAMETER TopN
    Maximum number of suggestions to return. Default: 20
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/suggest-links.ps1
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/suggest-links.ps1 -Threshold 0.85 -TopN 10
#>
[CmdletBinding()]
param(
    [double]$Threshold = 0.80,
    [int]$TopN = 20
)
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot    = Split-Path -Parent $PSScriptRoot
    $DbPath       = $env:POSHWIKI_DB_PATH
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
            if (Test-Path $path) {
                try { [System.Reflection.Assembly]::LoadFrom($path) | Out-Null }
                catch { Add-Type -Path $path -ErrorAction SilentlyContinue }
            }
        }
        $os   = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
        $nativeLib  = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
        $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLib"
        if (Test-Path $nativePath) {
            try { [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null } catch {}
        }
        try { [SQLitePCL.Batteries]::Init() } catch {}
    }
    Import-SqliteAssemblies

    $connString = "Data Source=$DbPath"

    function Invoke-Sql([string]$query) {
        $c = [Microsoft.Data.Sqlite.SqliteConnection]::new($connString)
        $c.Open()
        try {
            $cmd = $c.CreateCommand()
            $cmd.CommandText = $query
            $reader = $cmd.ExecuteReader()
            $rows = @()
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

    # --- Load embeddings ---
    $embRows = Invoke-Sql "SELECT NoteName, Embedding FROM NoteEmbeddings"
    if ($embRows.Count -eq 0) {
        Write-Warning "No embeddings found. Run sync-embeddings.ps1 first."
        exit 0
    }

    # Parse and pre-normalize all vectors (normalization makes dot product = cosine similarity)
    $noteNames  = @()
    $normalized = @{}
    foreach ($row in $embRows) {
        $vec = [double[]]($row.Embedding | ConvertFrom-Json)
        $mag = 0.0
        foreach ($v in $vec) { $mag += $v * $v }
        $mag = [Math]::Sqrt($mag)
        if ($mag -eq 0) { continue }
        $norm = [double[]]::new($vec.Length)
        for ($k = 0; $k -lt $vec.Length; $k++) { $norm[$k] = $vec[$k] / $mag }
        $normalized[$row.NoteName] = $norm
        $noteNames += $row.NoteName
    }

    # --- Load existing links (both directions) ---
    $linkRows      = Invoke-Sql "SELECT Source, Target FROM Links"
    $existingLinks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($link in $linkRows) {
        $existingLinks.Add("$($link.Source)|$($link.Target)") | Out-Null
        $existingLinks.Add("$($link.Target)|$($link.Source)") | Out-Null
    }

    # --- Pairwise cosine similarity ---
    Write-Host "Computing pairwise similarity for $($noteNames.Count) notes..." -ForegroundColor Cyan

    $suggestions = [System.Collections.Generic.List[PSCustomObject]]::new()

    for ($i = 0; $i -lt $noteNames.Count; $i++) {
        $a  = $noteNames[$i]
        $va = $normalized[$a]
        for ($j = $i + 1; $j -lt $noteNames.Count; $j++) {
            $b = $noteNames[$j]
            if ($existingLinks.Contains("$a|$b")) { continue }

            $vb  = $normalized[$b]
            $dot = 0.0
            for ($k = 0; $k -lt $va.Length; $k++) { $dot += $va[$k] * $vb[$k] }

            if ($dot -ge $Threshold) {
                $suggestions.Add([PSCustomObject]@{
                    NoteA      = $a
                    NoteB      = $b
                    Similarity = [Math]::Round($dot, 4)
                }) | Out-Null
            }
        }
    }

    $top = $suggestions | Sort-Object Similarity -Descending | Select-Object -First $TopN

    # --- Output ---
    Write-Host "`n=== LINK SUGGESTIONS (threshold: $Threshold) ===" -ForegroundColor Cyan

    if ($suggestions.Count -eq 0) {
        Write-Host "No semantic orphans found above threshold $Threshold." -ForegroundColor Green
    } else {
        Write-Host ("Top {0} of {1} candidate pair(s):`n" -f $top.Count, $suggestions.Count) -ForegroundColor Yellow
        foreach ($s in $top) {
            Write-Host ("  {0:F4}  [[{1}]] <-> [[{2}]]" -f $s.Similarity, $s.NoteA, $s.NoteB)
        }
        Write-Host "`nTo link: add [[NoteB]] inside NoteA (or vice versa) and re-run sync-vault-graph.ps1." -ForegroundColor Gray
    }

    $top | Out-Null

} catch {
    Write-Error "suggest-links.ps1 failed: $_"
    exit 1
}
