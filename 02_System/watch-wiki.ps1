<#
.SYNOPSIS
    Vulture Watchdog: Debounced Recompiler
.DESCRIPTION
    Monitors 01_Wiki/ for changes and triggers a graph sync and portal compilation.
    Uses a debounced FileSystemWatcher to prevent redundant builds during save bursts.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/watch-wiki.ps1
#>
$ErrorActionPreference = 'Stop'

try {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
    $WikiPath = Join-Path $VaultRoot "01_Wiki"
    $DebounceMs = 1500 # Wait 1.5s after last change before building

    Write-Host "--- Vulture Watchdog Started ---" -ForegroundColor Cyan
    Write-Host "Monitoring: $WikiPath" -ForegroundColor Gray
    Write-Host "Press Ctrl+C to stop.`n"

    $Watcher = New-Object System.IO.FileSystemWatcher
    $Watcher.Path = $WikiPath
    $Watcher.Filter = "*.md"
    $Watcher.IncludeSubdirectories = $true
    $Watcher.EnableRaisingEvents = $true

    $LastEventTime = [DateTime]::MinValue
    $Timer = New-Object System.Timers.Timer($DebounceMs)
    $Timer.AutoReset = $false

    $Action = {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected. Syncing & Compiling..." -ForegroundColor Yellow
        try {
            pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "sync-vault-graph.ps1")
            pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "generate-wiki.ps1")
            pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "generate-dashboard.ps1")
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Build complete. Portal updated." -ForegroundColor Green
        } catch {
            Write-Error "Build failed: $_"
        }
    }

    Register-ObjectEvent -InputObject $Timer -EventName Elapsed -Action $Action | Out-Null

    $OnFileChange = Register-ObjectEvent -InputObject $Watcher -EventName Changed -Action {
        $global:Timer.Stop()
        $global:Timer.Start()
    }

    $OnCreated = Register-ObjectEvent -InputObject $Watcher -EventName Created -Action {
        $global:Timer.Stop()
        $global:Timer.Start()
    }

    $OnDeleted = Register-ObjectEvent -InputObject $Watcher -EventName Deleted -Action {
        $global:Timer.Stop()
        $global:Timer.Start()
    }

    $OnRenamed = Register-ObjectEvent -InputObject $Watcher -EventName Renamed -Action {
        $global:Timer.Stop()
        $global:Timer.Start()
    }

    try {
        while ($true) { Start-Sleep -Seconds 1 }
    } finally {
        $Watcher.Dispose()
        $Timer.Dispose()
        Unregister-Event -SourceIdentifier $OnFileChange.Name
        Unregister-Event -SourceIdentifier $OnCreated.Name
        Unregister-Event -SourceIdentifier $OnDeleted.Name
        Unregister-Event -SourceIdentifier $OnRenamed.Name
        Write-Host "`n--- Watchdog Stopped ---" -ForegroundColor Cyan
    }
} catch {
    Write-Error "watch-wiki.ps1 failed: $_"
    exit 1
}
