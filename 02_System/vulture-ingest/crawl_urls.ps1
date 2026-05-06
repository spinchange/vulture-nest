param(
    [Parameter(Mandatory = $true)]
    [string[]]$Urls,

    [int]$Delay = 5,

    [int]$Pages = 1,

    [switch]$DryRun,

    [switch]$NoIndex,

    [string[]]$Include,

    [string[]]$Exclude
)

$ErrorActionPreference = 'Stop'

try {
    $tempRoot = if ($env:TEMP) { $env:TEMP } else { [System.IO.Path]::GetTempPath() }
    $tempFile = Join-Path $tempRoot ("vulture_crawl_urls_{0}.txt" -f ([guid]::NewGuid().ToString("N")))
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $crawlPy = Join-Path $scriptDir "crawl.py"

    $normalizedUrls = @($Urls | Where-Object { $_ -and $_.Trim() } | ForEach-Object { $_.Trim() })
    if ($normalizedUrls.Count -eq 0) {
        throw "Provide at least one non-empty URL."
    }

    Set-Content -LiteralPath $tempFile -Value $normalizedUrls -Encoding utf8

    $arguments = @(
        $crawlPy
        '--file'
        $tempFile
        '--delay'
        [string]$Delay
        '--pages'
        [string]$Pages
    )

    if ($DryRun) {
        $arguments += '--dry-run'
    }
    if ($NoIndex) {
        $arguments += '--no-index'
    }
    foreach ($path in @($Include | Where-Object { $_ -ne $null })) {
        $arguments += '--include'
        $arguments += $path
    }
    foreach ($path in @($Exclude | Where-Object { $_ -ne $null })) {
        $arguments += '--exclude'
        $arguments += $path
    }

    & python @arguments
    exit $LASTEXITCODE
}
finally {
    if ($tempFile -and (Test-Path -LiteralPath $tempFile)) {
        Remove-Item -LiteralPath $tempFile -Force
    }
}
