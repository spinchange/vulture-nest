<#
.SYNOPSIS
    Creates a dated experiment scaffold under 04_Experiments.
.DESCRIPTION
    Generates a new experiment directory and pre-fills entry.md with
    frontmatter and section headings for runs, debates, and evaluations.
    Optionally scaffolds a Tier-2-compliant PowerShell runner inside the
    experiment directory.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/new-experiment.ps1 -Slug demo
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [ValidateSet("run", "debate", "evaluation")]
    [string]$Type = "run",

    [string[]]$Participants = @("human"),

    [string]$Hypothesis = "",

    [switch]$IncludeScript,

    [ValidatePattern('^[A-Za-z0-9._-]+\.ps1$')]
    [string]$ScriptName = "run.ps1"
)

$ErrorActionPreference = 'Stop'

try {
    $vaultRoot = Split-Path $PSScriptRoot -Parent
    $date = Get-Date -Format "yyyy-MM-dd"
    $dir = Join-Path $vaultRoot "04_Experiments\${date}_${Slug}"
    $entryPath = Join-Path $dir "entry.md"

    New-Item -ItemType Directory -Path $dir -Force | Out-Null

    $normalizedParticipants = @(
        foreach ($participant in $Participants) {
            foreach ($part in ($participant -split ',')) {
                $trimmed = $part.Trim()
                if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                    $trimmed
                }
            }
        }
    )

    $participantList = if ($normalizedParticipants.Count -gt 0) {
        ($normalizedParticipants | ForEach-Object { "'$_'" }) -join ", "
    } else {
        "'human'"
    }

    $frontmatter = @"
---
title: $Slug
author: human
date: '$date'
status: active
type: experiment
experiment-type: $Type
participants: [$participantList]
hypothesis: $Hypothesis
result: ''
verdict: ongoing
aliases: []
---

# $Slug

## Hypothesis
$Hypothesis

## Setup


## Run Log


## Results


## Outcome

"@

    Set-Content -Path $entryPath -Value $frontmatter -Encoding utf8

    if ($IncludeScript) {
        $scriptPath = Join-Path $dir $ScriptName
        $scriptTemplate = @"
<#
.SYNOPSIS
    Experiment runner scaffold for $Slug.
.DESCRIPTION
    Tier-2-compliant entrypoint for experiment automation captured under 04_Experiments.
#>

[CmdletBinding()]
param()

\$ErrorActionPreference = 'Stop'

try {
    \$experimentRoot = Split-Path -Parent \$MyInvocation.MyCommand.Definition
    \$entryPath = Join-Path \$experimentRoot "entry.md"

    Write-Host "Running experiment scaffold: $Slug" -ForegroundColor Cyan
    Write-Host "Entry note: \$entryPath" -ForegroundColor DarkGray

    # Replace this block with experiment-specific logic and log durable outputs
    # under the local results/ directory to keep artifacts attached to the run.
} catch {
    Write-Error "$ScriptName failed: \$_"
    exit 1
}
"@

        Set-Content -Path $scriptPath -Value $scriptTemplate -Encoding utf8
    }

    Write-Host "Created: $entryPath" -ForegroundColor Green
} catch {
    Write-Error "new-experiment.ps1 failed: $_"
    exit 1
}
