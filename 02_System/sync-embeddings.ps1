<#
.SYNOPSIS
    Syncs note embeddings to SQLite using the Gemini text-embedding-004 API.
.DESCRIPTION
    Reads all notes from 01_Wiki/, computes SHA256 hashes for change detection,
    calls the Gemini batch embedding API for new or changed notes, and stores vectors
    as JSON in the NoteEmbeddings table. Incremental: skips notes whose content
    hasn't changed since last embedding. Exits 0 gracefully if GEMINI_API_KEY is not set.
.PARAMETER Force
    Re-embed all notes even if content is unchanged.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-embeddings.ps1
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-embeddings.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot  = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot     = Split-Path -Parent $PSScriptRoot
    $WikiFolder    = Join-Path $VaultRoot "01_Wiki"
    $DbPath        = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db"
    }
    $LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"
    $ApiKey  = $env:GEMINI_API_KEY

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-Host "GEMINI_API_KEY not set — skipping embedding sync." -ForegroundColor Yellow
        exit 0
    }

    # --- SQLite setup (mirrors pattern used across system scripts) ---
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

    function Invoke-Sql([string]$query, [hashtable]$params = @{}) {
        $c = [Microsoft.Data.Sqlite.SqliteConnection]::new($connString)
        $c.Open()
        try {
            $cmd = $c.CreateCommand()
            $cmd.CommandText = $query
            foreach ($k in $params.Keys) { $cmd.Parameters.AddWithValue("@$k", $params[$k]) | Out-Null }
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

    # --- Schema ---
    $c = [Microsoft.Data.Sqlite.SqliteConnection]::new($connString)
    $c.Open()
    try {
        $cmd = $c.CreateCommand()
        $cmd.CommandText = @"
CREATE TABLE IF NOT EXISTS NoteEmbeddings (
    NoteName    TEXT PRIMARY KEY,
    Embedding   TEXT NOT NULL,
    ContentHash TEXT NOT NULL,
    EmbeddedAt  DATETIME DEFAULT CURRENT_TIMESTAMP
);
"@
        $cmd.ExecuteNonQuery() | Out-Null
    } finally { $c.Close() }

    # --- Change detection ---
    function Get-ContentHash([string]$content) {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $sha   = [System.Security.Cryptography.SHA256]::Create()
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))) -replace '-', ''
    }

    function Get-EmbedText([string]$name, [string]$content) {
        # Strip YAML frontmatter, prepend note name, cap at 8 000 chars (~2 000 tokens)
        $body = $content -replace '(?s)^---.*?---\s*', ''
        $text = "$name`n$body"
        if ($text.Length -gt 8000) { return $text.Substring(0, 8000) }
        return $text
    }

    $existingRows   = Invoke-Sql "SELECT NoteName, ContentHash FROM NoteEmbeddings"
    $existingHashes = @{}
    foreach ($row in $existingRows) { $existingHashes[$row.NoteName] = $row.ContentHash }

    $mdFiles  = Get-ChildItem -Path $WikiFolder -Filter "*.md"
    $toEmbed  = @()
    foreach ($file in $mdFiles) {
        $name    = $file.BaseName
        $content = Get-Content $file.FullName -Raw
        $hash    = Get-ContentHash $content
        if ($Force -or (-not $existingHashes.ContainsKey($name)) -or ($existingHashes[$name] -ne $hash)) {
            $toEmbed += [PSCustomObject]@{
                Name      = $name
                Hash      = $hash
                EmbedText = (Get-EmbedText $name $content)
            }
        }
    }

    if ($toEmbed.Count -eq 0) {
        Write-Host "All $($mdFiles.Count) notes up to date — nothing to embed." -ForegroundColor Green
        exit 0
    }

    Write-Host "Embedding $($toEmbed.Count) note(s) via Gemini text-embedding-004..." -ForegroundColor Cyan

    # Individual embedContent calls — batch endpoint has inconsistent model support
    # Free tier: 100 RPM, so 650ms between calls keeps us safely under the limit
    $embedUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=$ApiKey"
    $upsertSql = @"
INSERT INTO NoteEmbeddings (NoteName, Embedding, ContentHash, EmbeddedAt)
VALUES (@Name, @Embedding, @Hash, CURRENT_TIMESTAMP)
ON CONFLICT(NoteName) DO UPDATE SET
    Embedding   = excluded.Embedding,
    ContentHash = excluded.ContentHash,
    EmbeddedAt  = CURRENT_TIMESTAMP;
"@
    $embedded = 0
    $total    = $toEmbed.Count

    foreach ($note in $toEmbed) {
        $body = @{
            model   = "models/gemini-embedding-001"
            content = @{ parts = @(@{ text = $note.EmbedText }) }
        } | ConvertTo-Json -Depth 4 -Compress

        # Retry loop — backs off 60s on 429 before retrying
        $maxRetries = 5
        $response   = $null
        for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
            try {
                $response = Invoke-RestMethod -Uri $embedUrl -Method Post -Body $body -ContentType "application/json"
                break
            } catch {
                $code = $_.Exception.Response.StatusCode.value__
                if ($code -eq 429 -and $attempt -lt $maxRetries) {
                    Write-Host ("  Rate limit hit — waiting 60s before retry {0}/{1}..." -f $attempt, ($maxRetries - 1)) -ForegroundColor Yellow
                    Start-Sleep -Seconds 60
                } else {
                    throw "Gemini API error on '$($note.Name)' (HTTP $code): $_"
                }
            }
        }

        $embJson = $response.embedding.values | ConvertTo-Json -Compress

        $c = [Microsoft.Data.Sqlite.SqliteConnection]::new($connString)
        $c.Open()
        try {
            $cmd = $c.CreateCommand()
            $cmd.CommandText = $upsertSql
            $cmd.Parameters.AddWithValue("@Name",      $note.Name)  | Out-Null
            $cmd.Parameters.AddWithValue("@Embedding", $embJson)    | Out-Null
            $cmd.Parameters.AddWithValue("@Hash",      $note.Hash)  | Out-Null
            $cmd.ExecuteNonQuery() | Out-Null
        } finally { $c.Close() }

        $embedded++
        Write-Host ("  [{0}/{1}] {2}" -f $embedded, $total, $note.Name) -ForegroundColor Gray

        # 1200ms between calls ~= 50 RPM, well under the free-tier limit
        if ($embedded -lt $total) { Start-Sleep -Milliseconds 1200 }
    }

    Write-Host "Done. $embedded note(s) embedded and stored." -ForegroundColor Green

} catch {
    Write-Error "sync-embeddings.ps1 failed: $_"
    exit 1
}
