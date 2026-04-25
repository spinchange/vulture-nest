<#
.SYNOPSIS
    Real-time Vault Watcher
.DESCRIPTION
    Monitors the 01_Wiki folder for changes and automatically triggers 
    a graph sync and portal compilation.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/watch-wiki.ps1
#>

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$VaultRoot = Split-Path -Parent $PSScriptRoot
$WikiPath = Join-Path $VaultRoot "01_Wiki"

Write-Host "--- Vulture Watcher Active ---" -ForegroundColor Cyan
Write-Host "Monitoring: $WikiPath"
Write-Host "Press Ctrl+C to stop.`n"

# Define the action to take on change
$Action = {
    param($Source, $EventArgs)
    $name = $EventArgs.Name
    $changeType = $EventArgs.ChangeType
    
    if ($name -match '\.md$') {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected: $name ($changeType)" -ForegroundColor Yellow
        
        # 1. Sync the graph (to ensure new links are queryable)
        Write-Host " - Syncing graph..." -ForegroundColor Gray
        & pwsh -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/sync-vault-graph.ps1" | Out-Null
        
        # 2. Re-compile the portal (incremental)
        Write-Host " - Compiling portal..." -ForegroundColor Gray
        & pwsh -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/generate-wiki.ps1" | Out-Null
        
        Write-Host " - Done. Portal updated.`n" -ForegroundColor Green
    }
}

# Initialize Watcher
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $WikiPath
$Watcher.Filter = "*.md"
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# Register events
$Created = Register-ObjectEvent $Watcher "Created" -Action $Action
$Changed = Register-ObjectEvent $Watcher "Changed" -Action $Action
$Renamed = Register-ObjectEvent $Watcher "Renamed" -Action $Action

try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    # Cleanup on exit
    $Watcher.EnableRaisingEvents = $false
    Unregister-Event -SourceIdentifier $Created.Name
    Unregister-Event -SourceIdentifier $Changed.Name
    Unregister-Event -SourceIdentifier $Renamed.Name
    $Watcher.Dispose()
    Write-Host "`n--- Watcher Stopped ---" -ForegroundColor Cyan
}
