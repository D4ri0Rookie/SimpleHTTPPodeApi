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
```

### 📡 API Endpoints

### Core Endpoints

| Method | Endpoint | Response | Description |
|--------|----------|----------|-------------|
| `GET` | `/` | HTML | Server status page with available endpoints |
| `GET` | `/hello` | JSON | Simple "Hello World" test endpoint |
| `GET` | `/health` | JSON | Health check endpoint for monitoring |
| `*` | `/*` | 404 | All other requests return standard HTTP 404 |


## 📝 Logging

The server automatically creates comprehensive logs in the `logs/` directory:

### Log Files

| File Pattern | Content | Format |
|--------------|---------|---------|
| `server-YYYY-MM-DD.log` | Server events (startup, shutdown, errors) | Plain text |
| `requests-YYYY-MM-DD.log` | HTTP requests and responses | Plain text |
| `requests-structured-YYYY-MM-DD.log` | HTTP requests with metadata | JSON |

### Log Rotation

- **Daily rotation**: New log files created each day
- **Automatic cleanup**: No manual intervention required
- **Structured data**: JSON logs for automated analysis

### Default Settings

- **Host**: `localhost` (hardcoded for security)
- **Port**: `8080` (hardcoded)
- **Protocol**: `HTTP` only
- **Logging**: Enabled with daily rotation
- **Security Headers**: Basic protection enabled
- **Configuration files**: None (zero-config design)

### Customization

The server uses hardcoded values for maximum portability and security. To modify settings, edit `server.ps1`:

## 🛡️ Security

### Built-in Protection

- **Standard HTTP responses**: Proper 404 for unknown routes
- **Security headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Request logging**: Full audit trail of all requests
- **No authentication**: Designed for internal/trusted networks

## 🙏 Acknowledgments

This project is built on top of the excellent [Pode framework](https://github.com/Badgerati/Pode) by [@Badgerati](https://github.com/Badgerati). Pode provides the robust HTTP server foundation that makes this simple API server possible.

Special thanks to the Pode community for creating such a powerful and easy-to-use PowerShell web framework.
