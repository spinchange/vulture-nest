Import-Module "$PSScriptRoot/00_Raw/PoShWiKi/PoShWiKi.psm1" -Force

Write-Host "Running Initialize-Wiki..."
Initialize-Wiki

Write-Host "Checking for CoOccurrenceEvents table..."
# We can use the internal Invoke-WikiSql by using the module prefix if we knew it, 
# but easier to just export it or use a script block.
# Since we are in the same process after Import-Module, if we run this as a script it might work 
# if we dot-source it.

$tables = Invoke-WikiSql -Query "SELECT name FROM sqlite_master WHERE type='table' AND name='CoOccurrenceEvents'"
if ($tables.Count -gt 0) {
    Write-Host "SUCCESS: CoOccurrenceEvents table exists." -ForegroundColor Green
} else {
    Write-Error "FAILURE: CoOccurrenceEvents table NOT found."
}

Write-Host "Checking for Record-CoOccurrence function..."
$cmd = Get-Command Record-CoOccurrence -ErrorAction SilentlyContinue
if ($cmd) {
    Write-Host "SUCCESS: Record-CoOccurrence function is exported." -ForegroundColor Green
} else {
    Write-Error "FAILURE: Record-CoOccurrence function NOT exported."
}
