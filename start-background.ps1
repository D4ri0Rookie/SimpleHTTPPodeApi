<#
.SYNOPSIS
    Start SimpleHTTPPodeApi server in background
.DESCRIPTION
    Starts the minimal HTTP API server as a background job
#>

$serverScript = Join-Path $PSScriptRoot "server.ps1"

# Create logs directory if it doesn't exist
$logDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Start server as background job
$job = Start-Job -ScriptBlock {
    param($ScriptPath)
    Set-Location (Split-Path $ScriptPath -Parent)
    & $ScriptPath
} -ArgumentList $serverScript -Name "SimpleHTTPPodeApi"

Write-Host "🚀 SimpleHTTPPodeApi started in background" -ForegroundColor Green
Write-Host "📋 Job ID: $($job.Id)" -ForegroundColor Cyan
Write-Host "📋 Server: http://localhost:8080" -ForegroundColor Cyan
Write-Host "" 
Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  Get-Job -Name SimpleHTTPPodeApi    # Check status" -ForegroundColor Gray
Write-Host "  Receive-Job -Id $($job.Id)         # Get output" -ForegroundColor Gray
Write-Host "  Stop-Job -Id $($job.Id)            # Stop server" -ForegroundColor Gray
Write-Host "  Remove-Job -Id $($job.Id)          # Remove job" -ForegroundColor Gray

return $job