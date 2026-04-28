<#
.SYNOPSIS
    Creates a dated experiment scaffold under 04_Experiments.
.DESCRIPTION
    Generates a new experiment directory and pre-fills entry.md with
    frontmatter and section headings for runs, debates, and evaluations.
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

    [string]$Hypothesis = ""
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
    Write-Host "Created: $entryPath" -ForegroundColor Green
} catch {
    Write-Error "new-experiment.ps1 failed: $_"
    exit 1
}
