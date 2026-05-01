$settings = Get-Content .gemini/settings.json | ConvertFrom-Json
$config = $settings.mcpServers.'vulture-ingest'.env
$url = $config.SUPABASE_URL
$key = $config.SUPABASE_SERVICE_KEY

$headers = @{
    'apikey' = $key
    'Authorization' = "Bearer $key"
}

try {
    $resp = Invoke-RestMethod -Uri "$url/rest/v1/source_pages?limit=1" -Headers $headers -Method Get
    Write-Host "Connection OK"
    $resp | ConvertTo-Json
} catch {
    Write-Host "Connection failed: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)"
    }
}
