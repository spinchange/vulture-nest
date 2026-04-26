<#
.SYNOPSIS
    Installs the Vulture Watcher as a Windows Daemon.
.DESCRIPTION
    Registers the watch-wiki.ps1 script as a Windows Scheduled Task 
    that starts automatically when the user logs in.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/install-vulture-daemon.ps1
#>
$ErrorActionPreference = 'Stop'

try {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot
    $WatcherPath = Join-Path $PSScriptRoot "watch-wiki.ps1"
    $TaskName = "VultureWikiWatcher"

    Write-Host "--- Installing Vulture Daemon ---" -ForegroundColor Cyan

    # 1. Prepare the Action
    $Action = New-ScheduledTaskAction -Execute "pwsh.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$WatcherPath"""

    # 2. Prepare the Trigger (At Log On)
    $Trigger = New-ScheduledTaskTrigger -AtLogOn

    # 3. Prepare the Principal (Run as current user)
    $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

    # 4. Prepare the Settings
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 365)

    # 5. Register the Task
    try {
        # Check if task already exists and remove it
        if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host " - Updating existing task..." -ForegroundColor Gray
        }

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Description "Automated real-time graph and HTML generation for the Vulture Nest vault."

        Write-Host " - Success! Vulture Daemon registered." -ForegroundColor Green
        Write-Host " - The wiki will now be 'Live' automatically every time you log in." -ForegroundColor Yellow
    } catch {
        Write-Error "Failed to register task: $_"
        Write-Host "`nNote: This script may require Administrative privileges to register a task." -ForegroundColor Red
    }
} catch {
    Write-Error "install-vulture-daemon.ps1 failed: $_"
    exit 1
}
