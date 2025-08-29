**Made with ❤️ using PowerShell and Pode framework**

# SimpleHTTPPodeApi
A lightweight, secure HTTP API server built with PowerShell and the [Pode framework](https://github.com/Badgerati/Pode). Designed for monitoring, health checks, and simple API services with comprehensive logging capabilities.

## 🎯 Features

- **Minimal & Fast**: Lightweight HTTP server with 5 concurrent threads for optimal performance
- **Secure by Design**: OWASP-compliant security headers and rate limiting protection  
- **Rate Limiting**: Built-in DoS protection (60 requests/minute per IP)
- **Memory Management**: Automatic memory cleanup every 30 minutes prevents memory leaks
- **Comprehensive Logging**: Daily rotated logs with structured JSON output
- **Health Monitoring**: Built-in health check endpoints for monitoring systems
- **Portable**: Copy-paste deployment with zero configuration required
- **Background Support**: Run as foreground process or background job

## 📋 Requirements

- **PowerShell**: 5.1+ or PowerShell Core 7.0+
- **Pode Module**: Will be installed automatically if not present
- **Network**: Available port 8080 (default)
- **Permissions**: Standard user permissions (no admin required)

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
<img width="1935" height="1118" alt="image" src="https://github.com/user-attachments/assets/b23a6198-f6f2-4964-8704-4454a03e105c" />

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
| `GET` | `/hello` | HTML | Simple "Hello World" test endpoint |
| `GET` | `/health` | HTML | Health check endpoint for monitoring |
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

### Sample Log Entries

**Server Log:**
```
[2025-08-29 19:27:27] [Info] 🌐 Starting SimpleHTTPPodeApi...
[2025-08-29 19:27:28] [Info] 🔧 Configuring server...
[2025-08-29 19:27:28] [Info] ✅ HTTP endpoint added on port 8080
[2025-08-29 19:27:28] [Info] 📂 Loading route: health.ps1
[2025-08-29 19:27:28] [Info] ✅ Route loaded: health.ps1
[2025-08-29 19:27:28] [Info] 📂 Loading route: hello.ps1
[2025-08-29 19:27:28] [Info] ✅ Route loaded: hello.ps1
[2025-08-29 19:27:28] [Info] 🎯 Routes configured:
[2025-08-29 19:27:28] [Info]    GET / - Server status page
[2025-08-29 19:27:28] [Info]    + Routes from files in routes/ folder
[2025-08-29 19:27:28] [Info]    All other URLs return 404
[2025-08-29 19:27:28] [Info] 🛡️ OWASP security headers enabled
[2025-08-29 19:27:28] [Info] 🚫 Rate limiting enabled (60 req/min per IP)
[2025-08-29 19:27:28] [Info] 🚀 Server ready on http://localhost:8080
```

**Request Log:**
```
[2025-08-29 14:30:20] [GET] /health from 192.168.1.100
[2025-08-29 14:30:25] [POST] /hello from 10.0.0.50
```

**Structured Log (JSON):**
```json
{"timestamp":"2025-08-29 14:30:20","method":"GET","path":"/health","ip":"192.168.1.100","userAgent":"curl/7.68.0"}
```

### Default Settings

- **Host**: `localhost` (hardcoded for security)
- **Port**: `8080` (hardcoded)
- **Protocol**: `HTTP` only
- **Threads**: `5` concurrent connections
- **Rate Limiting**: `60` requests/minute per IP
- **Memory Cleanup**: Every `30` minutes
- **Logging**: Enabled with daily rotation
- **Security Headers**: OWASP-compliant protection enabled
- **Configuration files**: None (zero-config design)

### Customization

The server uses hardcoded values for maximum portability and security. To modify settings, edit `server.ps1`:

```powershell
# Line 58: Change binding (be careful with 0.0.0.0)
Add-PodeEndpoint -Address "localhost" -Port 8080 -Protocol HTTP

# Add custom routes after existing ones
Add-PodeRoute -Method Get -Path '/custom' -ScriptBlock {
    Write-PodeJsonResponse -Value @{ 
        message = "Custom endpoint"
        timestamp = (Get-Date).ToString("o")
    } -StatusCode 200
}
```

## 🛡️ Security

### Built-in Protection

- **OWASP Security Headers**: Content Security Policy, X-Frame-Options, X-Content-Type-Options, etc.
- **Rate Limiting**: Automatic DoS protection (60 requests/minute per IP)
- **Standard HTTP responses**: Proper 404 for unknown routes, 429 for rate limits
- **Request logging**: Full audit trail of all requests with IP tracking
- **Memory Management**: Prevents memory leaks in long-running deployments
- **Multi-threaded**: 5 concurrent threads for better performance and availability
- **No authentication**: Designed for internal/trusted networks

## 🙏 Acknowledgments

This project is built on top of the excellent [Pode framework](https://github.com/Badgerati/Pode) by [@Badgerati](https://github.com/Badgerati). Pode provides the robust HTTP server foundation that makes this simple API server possible.

Special thanks to the Pode community for creating such a powerful and easy-to-use PowerShell web framework.

## Thanks
Big thanks to everyone who helped, and a special shoutout to AI for the tips and help with the documentation! 🚀
