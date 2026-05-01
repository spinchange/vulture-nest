<#
.SYNOPSIS
    MCP Config Health Checker
.DESCRIPTION
    Validates configured MCP servers by starting each server from .gemini/settings.json,
    running protocol initialization, and asserting discovery returns at least one tool.
    Empty credential-like environment variables are reported as warnings. Live credential
    checks are opt-in; by default this command performs no external service calls beyond
    starting the local MCP servers.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/check-mcp-health.ps1
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/check-mcp-health.ps1 -LiveServices
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path (Split-Path -Parent $PSScriptRoot) '.gemini/settings.json'),
    [double]$TimeoutSeconds = 10,
    [switch]$LiveServices,
    [switch]$LiveFirecrawl,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

try {
    $checker = Join-Path $PSScriptRoot 'mcp_healthcheck.py'
    $args = @($checker, '--config', $ConfigPath, '--timeout', ([string]$TimeoutSeconds))
    if ($LiveServices) {
        $args += '--live-services'
    }
    if ($LiveFirecrawl) {
        $args += '--live-firecrawl'
    }
    if ($Json) {
        $args += '--json'
    }

    & python @args
    if ($LASTEXITCODE -ne 0) {
        throw "MCP health check failed with exit code $LASTEXITCODE."
    }
} catch {
    Write-Error "check-mcp-health.ps1 failed: $_"
    exit 1
}
