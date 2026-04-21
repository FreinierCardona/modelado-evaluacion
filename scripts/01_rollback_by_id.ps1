Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "rollback-by-id.ps1"

& $mainScript
