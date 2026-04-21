Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$answer = (Read-Host "WARNING: This may rollback multiple changesets. Continue? (Y/N)").Trim().ToLowerInvariant()
if ($answer -notin @("y", "yes", "s", "si")) {
    Write-Host "Canceled."
    exit 0
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "rollback-by-id.ps1"

& $mainScript -AllowCascade
