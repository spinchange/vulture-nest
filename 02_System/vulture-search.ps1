<#
.SYNOPSIS
    The Vulture Search Engine
.DESCRIPTION
    A specialized retrieval engine that searches both the Wiki knowledge base and the System tool registry to provide a unified "Context Packet" for agents.
.PARAMETER Query
    The keyword or phrase to search for.
.INPUTS
    String (Query)
.OUTPUTS
    A structured Context Packet linking knowledge to tools.
.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File 02_System/vulture-search.ps1 -Query "PowerShell"
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

$wikiPath = "01_Wiki"
$registryPath = "02_System/TOOL_REGISTRY.md"

Write-Host "`n=== VULTURE ENGINE: CONTEXT PACKET FOR '$($Query.ToUpper())' ===" -ForegroundColor Cyan

# 1. Search Wiki (Knowledge)
$results = Get-ChildItem -Path $wikiPath -Filter *.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $match = $false
    
    # Check content and filename
    if ($_.Name -match [regex]::Escape($Query)) { $match = $true }
    if ($content -match [regex]::Escape($Query)) { $match = $true }
    
    # Simple YAML parsing for aliases
    if ($content -match "aliases: \[(.*?)\]") {
        $aliases = $matches[1]
        if ($aliases -match [regex]::Escape($Query)) { $match = $true }
    }

    if ($match) { $_.BaseName }
} | Select-Object -Unique

# 2. Search Registry (Capabilities)
$tools = if (Test-Path $registryPath) {
    $regContent = Get-Content $registryPath -Raw
    # Split into sections based on Markdown headers
    $toolBlocks = $regContent -split '(?=## )'
    $toolBlocks | Where-Object { $_ -match [regex]::Escape($Query) } | ForEach-Object {
        if ($_ -match "## (.*)") { $matches[1].Trim() }
    }
}

# 3. Format Output for Agent Consumption
Write-Host "`n[KNOWLEDGE BASE]" -ForegroundColor Yellow
if ($results) {
    $results | ForEach-Object { Write-Host " - [[$_]]" }
} else {
    Write-Host " - No direct knowledge matches found."
}

Write-Host "`n[AVAILABLE TOOLS]" -ForegroundColor Yellow
if ($tools) {
    $tools | ForEach-Object { Write-Host " - $Script:Query Match: $_ (See TOOL_REGISTRY.md for usage)" }
} else {
    Write-Host " - No relevant system tools identified."
}

Write-Host "`n=== PACKET COMPLETE ===" -ForegroundColor Cyan
