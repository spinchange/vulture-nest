<#
.SYNOPSIS
    Syncs wikilinks from the vault to the PoShWiKi database (Optimized).
.DESCRIPTION
    Refactored for performance using a single transaction and prepared statements.
    Parses all Markdown files in 01_Wiki/ for wikilinks and stores the relationship graph 
    in the 'Links' table of the SQLite database.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-vault-graph.ps1
#>
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot

    # 1. Database Configuration
    $DbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/wiki.db"
    }
    $LibPath = Join-Path $VaultRoot "00_Raw/PoShWiKi/lib"

    # 2. Load SQLite Assemblies
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
                try {
                    # Force load from absolute path to resolve dependencies in cloud runners
                    [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
                } catch {
                    Add-Type -Path $path -ErrorAction SilentlyContinue
                }
            }
        }

        # Native library loading logic (crucial for cloud runners)
        $os = if ($IsWindows) { "win" } elseif ($IsLinux) { "linux" } else { "osx" }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
        $nativeLibName = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
        $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLibName"

        if (Test-Path $nativePath) {
            try {
                [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
            } catch {}
        }

        try {
            [SQLitePCL.Batteries]::Init()
        } catch {}
    }
    Import-SqliteAssemblies

    # 3. Optimized Sync Logic
    $WikiFolder = Join-Path $VaultRoot "01_Wiki"
    $MdFiles = Get-ChildItem -Path $WikiFolder, $PSScriptRoot -Filter "*.md"
    $TotalNotes = $MdFiles.Count
    $TotalLinks = 0

    Write-Host "Syncing graph from $TotalNotes notes..." -ForegroundColor Cyan

    $connString = "Data Source=$DbPath"
    $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection($connString)
    try {
        $conn.Open()

        # 3.1 Initialize Schema & Indexes
        $initCmd = $conn.CreateCommand()
        $initCmd.CommandText = @"
        CREATE TABLE IF NOT EXISTS Links (Source TEXT, Target TEXT);
        CREATE INDEX IF NOT EXISTS idx_links_source ON Links(Source);
        CREATE INDEX IF NOT EXISTS idx_links_target ON Links(Target);
        DELETE FROM Links;
"@
        $initCmd.ExecuteNonQuery() | Out-Null

        # 3.2 Prepare Insert Command & Transaction
        $transaction = $conn.BeginTransaction()
        $insertCmd = $conn.CreateCommand()
        $insertCmd.Transaction = $transaction
        $insertCmd.CommandText = "INSERT INTO Links (Source, Target) VALUES (@Source, @Target)"
        $paramSource = $insertCmd.Parameters.Add("@Source", 'Text')
        $paramTarget = $insertCmd.Parameters.Add("@Target", 'Text')

        foreach ($file in $MdFiles) {
            $source = $file.BaseName
            $content = Get-Content -Path $file.FullName -Raw
            $matches = [Regex]::Matches($content, '\[\[(.*?)\]\]')

            foreach ($match in $matches) {
                $target = $match.Groups[1].Value.Split('|')[0].Trim()
                if (-not [string]::IsNullOrWhiteSpace($target)) {
                    $paramSource.Value = $source
                    $paramTarget.Value = $target
                    $insertCmd.ExecuteNonQuery() | Out-Null
                    $TotalLinks++
                }
            }
        }

        $transaction.Commit()
        Write-Host "Sync complete. $TotalLinks links mapped." -ForegroundColor Green

    } catch {
        if ($null -ne $transaction) { $transaction.Rollback() }
        Write-Error "Sync failed: $_"
    } finally {
        $conn.Close()
    }

    # 4. Helper for Metrics (Invoke-Query equivalent)
    function Invoke-LocalQuery([string]$Query) {
        $c = New-Object Microsoft.Data.Sqlite.SqliteConnection($connString)
        $c.Open()
        try {
            $cmd = $c.CreateCommand(); $cmd.CommandText = $Query
            $r = $cmd.ExecuteReader(); $res = @()
            while ($r.Read()) {
                $obj = [ordered]@{}
                for ($i=0; $i -lt $r.FieldCount; $i++) { $obj[$r.GetName($i)] = $r.GetValue($i) }
                $res += [PSCustomObject]$obj
            }
            return @($res)
        } finally { $c.Close() }
    }

    # 5. Output Summary
    $Hubs = Invoke-LocalQuery "SELECT Target as Note, COUNT(*) as Incoming FROM Links GROUP BY Target ORDER BY Incoming DESC LIMIT 5"
    $AllNoteNames = $MdFiles.BaseName
    $LinkedNotes = Invoke-LocalQuery "SELECT DISTINCT Source AS Note FROM Links UNION SELECT DISTINCT Target AS Note FROM Links"
    $LinkedNames = $LinkedNotes.Note
    $Orphans = $AllNoteNames | Where-Object { $_ -notin $LinkedNames }

    $Summary = [PSCustomObject]@{
        TotalNotesScanned = $TotalNotes
        TotalLinksFound   = $TotalLinks
        TopHubs           = $Hubs
        Orphans           = $Orphans
    }

    Write-Output "--- Graph Summary (Optimized) ---"
    $Summary.TopHubs | Format-Table -AutoSize
    if ($Summary.Orphans.Count -gt 0) { Write-Output "Orphans: $($Summary.Orphans -join ', ')" } else { Write-Output "Orphans: None" }

    return $Summary
} catch {
    Write-Error "sync-vault-graph.ps1 failed: $_"
    exit 1
}
