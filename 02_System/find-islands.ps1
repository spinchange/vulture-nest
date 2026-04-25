<#
.SYNOPSIS
    Identifies "Island" notes in the vault.
.DESCRIPTION
    Analyzes the PoShWiKi 'Links' table to find notes that are not linked 
    from any Map of Content (MOC) or major hub.
#>

# Load sync-vault-graph logic to get Invoke-Query
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $PSScriptRoot "sync-vault-graph.ps1") | Out-Null

$AllNotes = Get-ChildItem -Path (Join-Path $VaultRoot "01_Wiki") -Filter *.md | Select-Object -ExpandProperty BaseName

# 1. Find all targets of MOCs
$MocTargets = Invoke-LocalQuery -Query "SELECT DISTINCT Target FROM Links WHERE Source LIKE '%-moc'" | Select-Object -ExpandProperty Target

# 2. Identify notes not reached by an MOC
$Islands = $AllNotes | Where-Object { $_ -notin $MocTargets -and $_ -notmatch "-moc$" }

# 3. Further cluster analysis: Do these islands link to EACH OTHER?
$IslandLinks = Invoke-LocalQuery -Query "SELECT Source, Target FROM Links WHERE Source IN ('$($Islands -join "','")')"

Write-Host "`n=== ISLAND ANALYSIS ===" -ForegroundColor Cyan
Write-Host "Total Notes: $($AllNotes.Count)"
Write-Host "MOC-Linked : $($MocTargets.Count)"
Write-Host "Islands    : $($Islands.Count)"

Write-Host "`n[DISCONNECTED CLUSTERS]" -ForegroundColor Yellow
foreach ($island in $Islands) {
    $outLinks = $IslandLinks | Where-Object { $_.Source -eq $island }
    $linkCount = if ($null -eq $outLinks) { 0 } else { $outLinks.Count }
    Write-Host " - [[$island]] ($linkCount outgoing links)"
}

Write-Host "`n[RECOMMENDATION]" -ForegroundColor Green
Write-Host "These notes should be integrated into a relevant MOC to ensure agent discoverability."
