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
            [Parameter(Mandatory=$true)]
            [string]$Goal,

            [Parameter(Mandatory=$true)]
            [string]$Seam,

            [Parameter(Mandatory=$true)]
            [string]$NextStep
        )

        $Title = Get-WikiSessionTitle

        Invoke-WikiNote -Title $Title -Section "Session Goal" -Content $Goal | Out-Null
        Invoke-WikiNote -Title $Title -Section "Current Seam" -Content $Seam | Out-Null
        Invoke-WikiNote -Title $Title -Section "Next Steps" -Content "- $NextStep" | Out-Null

        Write-Host "Seam recorded successfully in [[$Title]]." -ForegroundColor Green
        return [PSCustomObject]@{
            Session = $Title
            Goal    = $Goal
            Seam    = $Seam
            Next    = $NextStep
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
