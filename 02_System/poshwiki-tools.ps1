<#
.SYNOPSIS
    Standardized API wrapper for PoShWiKi.
.DESCRIPTION
    Provides high-level functions for recording durable thoughts and logs in the PoShWiKi database.
    This script acts as the "Thought API" for agents to ensure standardized note-taking.
    Adheres to [[ps-automation-spec]] and [[agent-note-conventions]].
.PARAMETER Title
    The title of the wiki page. Defaults to today's session title if omitted.
.PARAMETER Section
    The name of the section (## heading) to target.
.PARAMETER Content
    The text content to write or append.
.EXAMPLE
    Invoke-WikiLog -Content "Initialized the workspace."
.EXAMPLE
    Invoke-WikiNote -Section "Decisions" -Content "- Use PoShWiKi for session logs."
#>
$ErrorActionPreference = 'Stop'

try {
    function Get-PoShWiKiDatabasePath {
        $overridePath = $env:POSHWIKI_DB_PATH
        if (-not [string]::IsNullOrWhiteSpace($overridePath)) {
            return $overridePath
        }

        return Join-Path (Split-Path $PSScriptRoot -Parent) "00_Raw\PoShWiKi\wiki.db"
    }

    function Import-PoShWiKiSqliteAssemblies {
        if ('Microsoft.Data.Sqlite.SqliteConnection' -as [type]) {
            return
        }

        $libPath = Join-Path (Split-Path $PSScriptRoot -Parent) "00_Raw\PoShWiKi\lib"
        $dlls = @(
            "SQLitePCLRaw.core.dll",
            "SQLitePCLRaw.provider.e_sqlite3.dll",
            "SQLitePCLRaw.batteries_v2.dll",
            "Microsoft.Data.Sqlite.dll"
        )

        foreach ($dll in $dlls) {
            $path = Join-Path $libPath $dll
            if (-not (Test-Path $path)) {
                throw "Required SQLite assembly not found: $path"
            }

            Add-Type -Path $path -ErrorAction SilentlyContinue
        }

        $os = if ($IsWindows) { "win" } elseif ($IsMacOS) { "osx" } else { "linux" }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
        $runtimeArch = switch ($arch) {
            "x64" { "x64" }
            "arm64" { "arm64" }
            "x86" { "x86" }
            "arm" { "arm" }
            default { $arch }
        }

        $nativeLibName = if ($IsWindows) { "e_sqlite3.dll" } elseif ($IsMacOS) { "libe_sqlite3.dylib" } else { "libe_sqlite3.so" }
        $nativePath = Join-Path $libPath "runtimes/$os-$runtimeArch/native/$nativeLibName"

        if (Test-Path $nativePath) {
            try {
                [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
            } catch {
                Write-Verbose "Native SQLite library already loaded or deferred: $_"
            }
        }

        try {
            [SQLitePCL.Batteries]::Init()
        } catch {
            throw "Failed to initialize SQLite batteries: $_"
        }
    }

    function Get-PoShWiKiConnection {
        Import-PoShWiKiSqliteAssemblies

        $dbPath = Get-PoShWiKiDatabasePath
        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$dbPath")
        $connection.Open()
        return $connection
    }

    function Invoke-PoShWiKiDbNonQuery {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Query,

            [hashtable]$Parameters = @{}
        )

        $connection = Get-PoShWiKiConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query

            foreach ($key in $Parameters.Keys) {
                $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null
            }

            return $command.ExecuteNonQuery()
        } finally {
            $connection.Dispose()
        }
    }

    function Invoke-PoShWiKiDbScalar {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Query,

            [hashtable]$Parameters = @{}
        )

        $connection = Get-PoShWiKiConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query

            foreach ($key in $Parameters.Keys) {
                $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null
            }

            return $command.ExecuteScalar()
        } finally {
            $connection.Dispose()
        }
    }

    function Invoke-PoShWiKiDbQuery {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Query,

            [hashtable]$Parameters = @{}
        )

        $connection = Get-PoShWiKiConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query

            foreach ($key in $Parameters.Keys) {
                $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null
            }

            $reader = $command.ExecuteReader()
            $rows = @()
            while ($reader.Read()) {
                $row = [ordered]@{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $value = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
                    $row[$reader.GetName($i)] = $value
                }
                $rows += [PSCustomObject]$row
            }

            return @($rows)
        } finally {
            $connection.Dispose()
        }
    }

    function Initialize-PoShWiKiStructuredTables {
        $schema = @"
CREATE TABLE IF NOT EXISTS Seams (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at  TEXT NOT NULL DEFAULT (datetime('now')),
    agent       TEXT NOT NULL,
    target      TEXT,
    goal        TEXT NOT NULL,
    seam        TEXT NOT NULL,
    next_step   TEXT NOT NULL,
    note_path   TEXT
);
CREATE TABLE IF NOT EXISTS Debates (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at   TEXT NOT NULL DEFAULT (datetime('now')),
    topic        TEXT NOT NULL,
    participants TEXT NOT NULL,
    hypothesis   TEXT,
    verdict      TEXT,
    entry_path   TEXT
);
"@

        Invoke-PoShWiKiDbNonQuery -Query $schema | Out-Null
    }

    function Get-WikiSessionTitle {
        <#
        .SYNOPSIS
            Generates a standardized session title.
        .DESCRIPTION
            Returns a string in the format "Session YYYY-MM-DD".
        #>
        return "Session $(Get-Date -Format 'yyyy-MM-dd')"
    }

    function Invoke-WikiNote {
        <#
        .SYNOPSIS
            Upserts a section in a wiki page.
        .DESCRIPTION
            Maps to PoShWiKi's upsert-section command. If the page or section doesn't exist, they are created.
            Handles both creating a new page and updating an existing one.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$false)]
            [string]$Title,

            [Parameter(Mandatory=$true)]
            [string]$Section,

            [Parameter(Mandatory=$true)]
            [string]$Content
        )

        if ([string]::IsNullOrWhiteSpace($Title)) { $Title = Get-WikiSessionTitle }

        # Ensure page exists
        $page = Invoke-PoShWiKiCli -Command "get" -Arguments @($Title) -Quiet
        if (-not $page) {
            # Create a basic page if it doesn't exist
            Invoke-PoShWiKiCli -Command "save" -Arguments @($Title, "# $Title`n") | Out-Null
        }

        return Invoke-PoShWiKiCli -Command "upsert-section" -Arguments @($Title, $Section, $Content)
    }

    function Invoke-WikiLog {
        <#
        .SYNOPSIS
            Appends content to the ## Actions section of a wiki page.
        .DESCRIPTION
            Maps to PoShWiKi's append-section command targeting the "Actions" section.
            If the page or section doesn't exist, they are created.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$false)]
            [string]$Title,

            [Parameter(Mandatory=$true)]
            [string]$Content
        )

        if ([string]::IsNullOrWhiteSpace($Title)) { $Title = Get-WikiSessionTitle }

        # Ensure page exists
        $page = Invoke-PoShWiKiCli -Command "get" -Arguments @($Title) -Quiet
        if (-not $page) {
            # Create page with Actions section
            Invoke-PoShWiKiCli -Command "save" -Arguments @($Title, "# $Title`n`n## Actions`n") | Out-Null
        } else {
            # Ensure Actions section exists
            if ($page.Content -notmatch "(?m)^##\s+Actions") {
                 Invoke-PoShWiKiCli -Command "upsert-section" -Arguments @($Title, "Actions", "") | Out-Null
            }
        }

        return Invoke-PoShWiKiCli -Command "append-section" -Arguments @($Title, "Actions", $Content)
    }

    function New-WikiSeam {
        <#
        .SYNOPSIS
            Records a "Seam" for session handoff or pausing.
        .DESCRIPTION
            Prompts for a Goal, the Current Seam (what was finished), and the Next Step.
            Saves these to the current session page in PoShWiKi.
        #>
        [CmdletBinding()]
        param(
            [string]$Agent = "claude",

            [string]$Target,

            [Parameter(Mandatory=$true)]
            [string]$Goal,

            [Parameter(Mandatory=$true)]
            [string]$Seam,

            [Parameter(Mandatory=$true)]
            [string]$NextStep,

            [string]$NotePath
        )

        $Title = Get-WikiSessionTitle

        Invoke-WikiNote -Title $Title -Section "Session Goal" -Content $Goal | Out-Null
        Invoke-WikiNote -Title $Title -Section "Current Seam" -Content $Seam | Out-Null
        Invoke-WikiNote -Title $Title -Section "Next Steps" -Content "- $NextStep" | Out-Null

        Initialize-PoShWiKiStructuredTables
        $rowId = Invoke-PoShWiKiDbScalar -Query @"
INSERT INTO Seams (agent, target, goal, seam, next_step, note_path)
VALUES (@agent, @target, @goal, @seam, @next_step, @note_path);
SELECT last_insert_rowid();
"@ -Parameters @{
            agent     = $Agent
            target    = if ([string]::IsNullOrWhiteSpace($Target)) { $null } else { $Target }
            goal      = $Goal
            seam      = $Seam
            next_step = $NextStep
            note_path = if ([string]::IsNullOrWhiteSpace($NotePath)) { $null } else { $NotePath }
        }

        Write-Host "Seam recorded successfully in [[$Title]]." -ForegroundColor Green
        return [PSCustomObject]@{
            Id      = [int64]$rowId
            Agent   = $Agent
            Target  = $Target
            Session = $Title
            Goal    = $Goal
            Seam    = $Seam
            Next    = $NextStep
            NotePath = $NotePath
        }
    }

    function Get-LastSeam {
        [CmdletBinding()]
        param(
            [string]$Target
        )

        Initialize-PoShWiKiStructuredTables

        if ([string]::IsNullOrWhiteSpace($Target)) {
            $rows = Invoke-PoShWiKiDbQuery -Query @"
SELECT id, created_at, agent, target, goal, seam, next_step, note_path
FROM Seams
ORDER BY created_at DESC, id DESC
LIMIT 1;
"@
        } else {
            $rows = Invoke-PoShWiKiDbQuery -Query @"
SELECT id, created_at, agent, target, goal, seam, next_step, note_path
FROM Seams
WHERE target = @target OR target IS NULL
ORDER BY created_at DESC, id DESC
LIMIT 1;
"@ -Parameters @{ target = $Target }
        }

        if ($rows.Count -eq 0) {
            return $null
        }

        return $rows[0]
    }

    function New-DebateLog {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string]$Topic,

            [Parameter(Mandatory = $true)]
            [string[]]$Participants,

            [string]$Hypothesis,

            [string]$Verdict,

            [string]$EntryPath
        )

        Initialize-PoShWiKiStructuredTables
        $participantsJson = $Participants | ConvertTo-Json -Compress
        $rowId = Invoke-PoShWiKiDbScalar -Query @"
INSERT INTO Debates (topic, participants, hypothesis, verdict, entry_path)
VALUES (@topic, @participants, @hypothesis, @verdict, @entry_path);
SELECT last_insert_rowid();
"@ -Parameters @{
            topic        = $Topic
            participants = $participantsJson
            hypothesis   = if ([string]::IsNullOrWhiteSpace($Hypothesis)) { $null } else { $Hypothesis }
            verdict      = if ([string]::IsNullOrWhiteSpace($Verdict)) { $null } else { $Verdict }
            entry_path   = if ([string]::IsNullOrWhiteSpace($EntryPath)) { $null } else { $EntryPath }
        }

        return [int64]$rowId
    }

    function Invoke-HumanCommit {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string]$Message
        )

        & git -c user.name="spinchange" -c user.email="cduffy@ranchcryogenics.com" commit -m "[human] $Message"
        if ($LASTEXITCODE -ne 0) {
            throw "Human-attributed git commit failed with exit code $LASTEXITCODE."
        }
    }

    function Invoke-PoShWiKiCli {
        <#
        .SYNOPSIS
            Internal helper to call the PoShWiKi CLI.
        #>
        param(
            [string]$Command,
            [string[]]$Arguments,
            [switch]$Quiet
        )

        $WikiScript = Join-Path (Split-Path $PSScriptRoot -Parent) "00_Raw\PoShWiKi\wiki.ps1"

        if (-not (Test-Path $WikiScript)) {
            throw "Could not locate PoShWiKi CLI at $WikiScript"
        }

        # Prepare arguments for pwsh
        $cliArgs = @("-NoProfile", "-File", $WikiScript, $Command) + $Arguments + @("-JSON")

        # Execute and capture output
        $output = & pwsh @cliArgs 2>$null
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            if ($Quiet) { return $null }
            throw "PoShWiKi CLI command '$Command' failed with exit code $exitCode."
        }

        if ($output) {
            $jsonStr = $output | Out-String
            try {
                return $jsonStr | ConvertFrom-Json
            } catch {
                return $jsonStr
            }
        }

        return $null
    }
} catch {
    Write-Error "poshwiki-tools.ps1 failed: $_"
    exit 1
}
