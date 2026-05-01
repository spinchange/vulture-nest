param(
    [string]$SchemaPath = (Join-Path $PSScriptRoot "schema.sql"),
    [string]$SettingsPath = (Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) ".gemini/settings.json"),
    [string]$SqlRpc = $env:SUPABASE_SQL_RPC,
    [string]$DatabaseUrl = $(if ($env:SUPABASE_DB_URL) { $env:SUPABASE_DB_URL } else { $env:DATABASE_URL })
)

$ErrorActionPreference = "Stop"

function Get-VultureSupabaseConfig {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $settings = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    return $settings.mcpServers.'vulture-ingest'.env
}

function Invoke-SchemaVerification {
    param(
        [string]$SupabaseUrl,
        [string]$ServiceKey
    )

    if (-not $SupabaseUrl -or -not $ServiceKey) {
        Write-Warning "Skipping PostgREST verification because SUPABASE_URL or SUPABASE_SERVICE_KEY is missing."
        return
    }

    $headers = @{
        apikey = $ServiceKey
        Authorization = "Bearer $ServiceKey"
    }

    Invoke-RestMethod `
        -Uri "$($SupabaseUrl.TrimEnd('/'))/rest/v1/source_pages?select=id&limit=1" `
        -Headers $headers `
        -Method Get | Out-Null

    Write-Host "Verification OK: source_pages is visible through PostgREST."
}

if (-not (Test-Path -LiteralPath $SchemaPath)) {
    throw "Schema file not found: $SchemaPath"
}

$schemaSql = Get-Content -Raw -LiteralPath $SchemaPath
$config = Get-VultureSupabaseConfig -Path $SettingsPath
$supabaseUrl = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { $config.SUPABASE_URL }
$serviceKey = if ($env:SUPABASE_SERVICE_KEY) { $env:SUPABASE_SERVICE_KEY } else { $config.SUPABASE_SERVICE_KEY }

if ($SqlRpc) {
    if (-not $supabaseUrl -or -not $serviceKey) {
        throw "SUPABASE_URL and SUPABASE_SERVICE_KEY are required when using -SqlRpc."
    }

    $headers = @{
        apikey = $serviceKey
        Authorization = "Bearer $serviceKey"
        "Content-Type" = "application/json"
    }
    $body = @{ sql = $schemaSql } | ConvertTo-Json -Compress

    Invoke-RestMethod `
        -Uri "$($supabaseUrl.TrimEnd('/'))/rest/v1/rpc/$SqlRpc" `
        -Headers $headers `
        -Method Post `
        -Body $body | Out-Null

    Write-Host "Schema applied through RPC: $SqlRpc"
    Invoke-SchemaVerification -SupabaseUrl $supabaseUrl -ServiceKey $serviceKey
    exit 0
}

$psql = Get-Command psql -ErrorAction SilentlyContinue
if ($DatabaseUrl -and $psql) {
    Write-Host "Attempting to apply schema via psql..."
    & $psql.Source $DatabaseUrl -v ON_ERROR_STOP=1 -f $SchemaPath
    if ($LASTEXITCODE -ne 0) {
        throw "psql failed with exit code $LASTEXITCODE. Ensure the connection string is correct."
    }

    Write-Host "Schema applied through psql."
    Invoke-SchemaVerification -SupabaseUrl $supabaseUrl -ServiceKey $serviceKey
    exit 0
}

Write-Warning "AUTOMATION BLOCKED: No SQL execution path found."
Write-Host "Please apply the schema manually at: https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new"
Write-Host "SQL Source: 02_System/vulture-ingest/schema.sql"

throw "No SQL execution path available. Set SUPABASE_SQL_RPC to an existing RPC name, or install psql and set SUPABASE_DB_URL/DATABASE_URL."
