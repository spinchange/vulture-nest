param(
    [string]$MigrationsPath = (Join-Path $PSScriptRoot "migrations"),
    [string]$SettingsPath = (Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) ".gemini/settings.json"),
    [string]$SqlRpc = $env:SUPABASE_SQL_RPC,
    [string]$DatabaseUrl = $(if ($env:SUPABASE_DB_URL) { $env:SUPABASE_DB_URL } else { $env:DATABASE_URL })
)

$ErrorActionPreference = "Stop"

try {
    function Get-MigrationLedgerBootstrap {
        return @"
CREATE TABLE IF NOT EXISTS schema_migrations (
    version       TEXT PRIMARY KEY,
    applied_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description   TEXT
);
"@
    }

    function Get-MigrationEnvelope {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Version,

            [Parameter(Mandatory = $true)]
            [string]$MigrationSql
        )

        $description = ($Version -replace '^\d{4}-\d{2}-\d{2}_', '') -replace "'", "''"
        $escapedVersion = $Version.Replace("'", "''")
        return @"
$(Get-MigrationLedgerBootstrap)
$MigrationSql
INSERT INTO schema_migrations (version, description)
VALUES ('$escapedVersion', '$description')
ON CONFLICT (version) DO NOTHING;
"@
    }

    function Get-VultureSupabaseConfig {
        param([string]$Path)

        if (-not (Test-Path -LiteralPath $Path)) {
            return $null
        }

        $settings = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
        return $settings.mcpServers.'vulture-ingest'.env
    }

    function Invoke-MigrationVerification {
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
            -Uri "$($SupabaseUrl.TrimEnd('/'))/rest/v1/source_pages?select=id,indexed_by,promoted_by&limit=1" `
            -Headers $headers `
            -Method Get | Out-Null

        Invoke-RestMethod `
            -Uri "$($SupabaseUrl.TrimEnd('/'))/rest/v1/source_events?select=id&limit=1" `
            -Headers $headers `
            -Method Get | Out-Null

        Invoke-RestMethod `
            -Uri "$($supabaseUrl.TrimEnd('/'))/rest/v1/schema_migrations?select=version&limit=1" `
            -Headers $headers `
            -Method Get | Out-Null

        Write-Host "Verification OK: source_pages, source_events, and schema_migrations are visible through PostgREST."
    }

    if (-not (Test-Path -LiteralPath $MigrationsPath)) {
        throw "Migrations directory not found: $MigrationsPath"
    }

    $migrationFiles = @(Get-ChildItem -LiteralPath $MigrationsPath -Filter '*.sql' -File | Sort-Object Name)
    if ($migrationFiles.Count -eq 0) {
        throw "No migration files found in: $MigrationsPath"
    }

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

        foreach ($migrationFile in $migrationFiles) {
            $migrationSql = Get-Content -Raw -LiteralPath $migrationFile.FullName
            $payloadSql = Get-MigrationEnvelope -Version $migrationFile.BaseName -MigrationSql $migrationSql
            $body = @{ sql = $payloadSql } | ConvertTo-Json -Compress

            Invoke-RestMethod `
                -Uri "$($supabaseUrl.TrimEnd('/'))/rest/v1/rpc/$SqlRpc" `
                -Headers $headers `
                -Method Post `
                -Body $body | Out-Null

            Write-Host "Migration applied through RPC: $($migrationFile.Name)"
        }

        Invoke-MigrationVerification -SupabaseUrl $supabaseUrl -ServiceKey $serviceKey
        exit 0
    }

    $psql = Get-Command psql -ErrorAction SilentlyContinue
    if ($DatabaseUrl -and $psql) {
        foreach ($migrationFile in $migrationFiles) {
            $migrationSql = Get-Content -Raw -LiteralPath $migrationFile.FullName
            $payloadSql = Get-MigrationEnvelope -Version $migrationFile.BaseName -MigrationSql $migrationSql
            $tempSqlPath = [System.IO.Path]::GetTempFileName()
            try {
                Set-Content -LiteralPath $tempSqlPath -Value $payloadSql -Encoding utf8
                Write-Host "Attempting to apply migration via psql: $($migrationFile.Name)"
                & $psql.Source $DatabaseUrl -v ON_ERROR_STOP=1 -f $tempSqlPath
                if ($LASTEXITCODE -ne 0) {
                    throw "psql failed with exit code $LASTEXITCODE while applying $($migrationFile.Name). Ensure the connection string is correct."
                }
            } finally {
                if (Test-Path -LiteralPath $tempSqlPath) {
                    Remove-Item -LiteralPath $tempSqlPath -Force
                }
            }
        }

        Write-Host "Migrations applied through psql."
        Invoke-MigrationVerification -SupabaseUrl $supabaseUrl -ServiceKey $serviceKey
        exit 0
    }

    Write-Warning "AUTOMATION BLOCKED: No SQL execution path found."
    Write-Host "Please apply the migration manually at: https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new"
    Write-Host "SQL Source Directory: 02_System/vulture-ingest/migrations/"

    throw "No SQL execution path available. Set SUPABASE_SQL_RPC to an existing RPC name, or install psql and set SUPABASE_DB_URL/DATABASE_URL."
} catch {
    Write-Error "apply-migration.ps1 failed: $_"
    exit 1
}
