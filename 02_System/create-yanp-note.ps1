<#
.SYNOPSIS
    YANP Note Creator
.DESCRIPTION
    Scaffolds a new YANP-compliant markdown note with valid frontmatter and a kebab-case filename.
.PARAMETER Title
    The human-readable title of the note.
.PARAMETER Type
    The note classification: permanent (default), literature, or fleeting.
.PARAMETER Author
    The author of the note (defaults to gemini-cli).
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/create-yanp-note.ps1 -Title "My New Note" -Type "permanent"
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    
    [ValidateSet("permanent", "literature", "fleeting")]
    [string]$Type = "permanent",
    
    [string]$Author = "gemini-cli"
)
$ErrorActionPreference = 'Stop'

try {
    # 1. Sanitize Title to kebab-case
    $fileName = $Title.ToLower().Replace(" ", "-").Replace(":", "").Replace("?", "").Replace("/", "-")
    if ($fileName -notmatch "\.md$") { $fileName += ".md" }

    $outputPath = "01_Wiki/$fileName"

    if (Test-Path $outputPath) {
        Write-Error "Note already exists at $outputPath"
        exit 1
    }

    # 2. Build Frontmatter
    $date = Get-Date -Format "yyyy-MM-dd"
    $status = if ($Type -eq "fleeting") { "draft" } else { "active" }

    $template = @"
---
title: $Title
author: $Author
date: $date
status: $status
type: $Type
aliases: []
---
# $Title

[Insert content here]

---
## References
* 
"@

    # 3. Write File
    Set-Content -Path $outputPath -Value $template -Encoding utf8
    Write-Host "Successfully created YANP note: [[$($fileName.Replace('.md',''))]]" -ForegroundColor Green
    Write-Host "Path: $outputPath"
} catch {
    Write-Error "create-yanp-note.ps1 failed: $_"
    exit 1
}
