$ErrorActionPreference = 'Stop'

try {
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $PSScriptRoot "sync-vault-graph.ps1") | Out-Null

$hubs = Invoke-LocalQuery -Query "SELECT Target as Note, COUNT(*) as Incoming FROM Links GROUP BY Target HAVING Incoming > 2 ORDER BY Incoming DESC"
$results = @()

foreach ($h in $hubs) {
    $note = $h.Note
    $file = Join-Path (Split-Path $PSScriptRoot -Parent) "01_Wiki/$note.md"
    if (Test-Path $file) {
        $c = Get-Content $file -Raw
        $w = ($c -split '\s+').Count
        if ($w -lt 300) {
            $results += [PSCustomObject]@{
                Note      = $note
                Incoming  = $h.Incoming
                WordCount = $w
            }
        }
    }
}

$results | Sort-Object Incoming -Descending | Format-Table -AutoSize
} catch {
    Write-Error "find-thin-nodes.ps1 failed: $_"
    exit 1
}
