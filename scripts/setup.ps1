<#
.SYNOPSIS
    Setup script for SimpleHTTPPodeApi

.DESCRIPTION
    Checks requirements and prepares the environment for running SimpleHTTPPodeApi

.NOTES
    Version: 1.0.0 - Simplified
    Date: 2025-08-28
#>

Write-Host "🔧 SimpleHTTPPodeApi Setup" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
Write-Host "📋 Checking PowerShell version..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "   PowerShell version: $psVersion" -ForegroundColor Green

if ($psVersion.Major -lt 5) {
    Write-Host "❌ PowerShell 5.1 or higher is required" -ForegroundColor Red
    exit 1
}

# Check if Pode module is installed
Write-Host "📦 Checking Pode module..." -ForegroundColor Yellow
$podeModule = Get-Module -ListAvailable Pode
if ($podeModule) {
    Write-Host "   Pode module found: $($podeModule[0].Version)" -ForegroundColor Green
} else {
    Write-Host "⚠️  Pode module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name Pode -Scope CurrentUser -Force -AllowClobber
        Write-Host "✅ Pode module installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Pode module: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Try running as Administrator or use: Install-Module -Name Pode -Scope CurrentUser" -ForegroundColor Yellow
        exit 1
    }
}

# Create logs directory (only directory needed)
Write-Host "📁 Creating logs directory..." -ForegroundColor Yellow
$rootPath = Split-Path $PSScriptRoot -Parent
$logsPath = Join-Path $rootPath "logs"

if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
    Write-Host "   Created: logs/" -ForegroundColor Green
} else {
    Write-Host "   Exists: logs/" -ForegroundColor Gray
}

# Test port availability
Write-Host "🔌 Checking port availability..." -ForegroundColor Yellow
try {
    $portTest = Test-NetConnection -ComputerName localhost -Port 8080 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($portTest) {
        Write-Host "⚠️  Port 8080 is already in use" -ForegroundColor Yellow
        Write-Host "   You may need to stop the existing service or choose a different port" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Port 8080 is available" -ForegroundColor Green
    }
}
catch {
    Write-Host "✅ Port 8080 appears to be available" -ForegroundColor Green
}

# Display configuration summary
Write-Host ""
Write-Host "📊 Configuration Summary" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Server Type: HTTP Only (minimal)" -ForegroundColor White
Write-Host "Default Port: 8080" -ForegroundColor White
Write-Host "Protocol: HTTP" -ForegroundColor White
Write-Host "Authentication: None" -ForegroundColor White
Write-Host "Logging: Daily rotation in logs/ directory" -ForegroundColor White
Write-Host ""

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 To start the server:" -ForegroundColor Yellow
Write-Host "   Foreground: .\server.ps1" -ForegroundColor White
Write-Host "   Background: .\start-background.ps1" -ForegroundColor White
Write-Host ""
Write-Host "📡 Available endpoints:" -ForegroundColor Yellow
Write-Host "   GET  /                - Server status page (HTML)" -ForegroundColor White
Write-Host "   GET  /hello           - Hello World (JSON)" -ForegroundColor White
Write-Host "   GET  /health          - Health check (JSON)" -ForegroundColor White
Write-Host "   *    /*              - All other URLs return 404" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 After starting, visit: http://localhost:8080" -ForegroundColor Cyan