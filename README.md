**Made with ❤️ using PowerShell and Pode framework**

# SimpleHTTPPodeApi
A lightweight, secure HTTP API server built with PowerShell and the [Pode framework](https://github.com/Badgerati/Pode). Designed for monitoring, health checks, and simple API services with comprehensive logging capabilities.

## 📋 Requirements

- **PowerShell**: 5.1+ or PowerShell Core 7.0+
- **Pode Module**: Will be installed automatically if not present
- **Network**: Available port 8080 (default)
- **Permissions**: Standard user permissions (no admin required)

## 🎯 Features

- **Minimal & Fast**: Lightweight HTTP server with only essential features
- **Secure by Design**: Standard HTTP response codes, basic security headers
- **Comprehensive Logging**: Daily rotated logs with structured JSON output
- **Health Monitoring**: Built-in health check endpoints for monitoring systems
- **Portable**: Copy-paste deployment with zero configuration required
- **Background Support**: Run as foreground process or background job

## 📁 Project Structure

```
SimpleHTTPPodeApi/
├── server.ps1              # Main server application  
├── start-background.ps1    # Background execution script
├── scripts/
│   └── setup.ps1          # Environment setup and validation
├── README.md              # This documentation
└── logs/                  # Auto-created log directory
    ├── server-YYYY-MM-DD.log
    ├── requests-YYYY-MM-DD.log
    └── requests-structured-YYYY-MM-DD.log
```

## 🚀 Quick Start

### 1. Download & Extract
```powershell
# Extract to your desired location
# Clean project structure - only essential files included
```

### 1.5. Optional Setup
```powershell
# Run setup script to verify requirements
.\scripts\setup.ps1
```

### 2. Start the Server

**Foreground mode:**
```powershell
.\server.ps1
```

**Background mode:**
```powershell
$job = .\start-background.ps1

# Manage background job
Get-Job -Name SimpleHTTPPodeApi    # Check status
Receive-Job -Id $job.Id           # View output
Stop-Job -Id $job.Id              # Stop server
Remove-Job -Id $job.Id            # Clean up
---
