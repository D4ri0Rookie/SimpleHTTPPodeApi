<#
.SYNOPSIS
    SimpleHTTPPodeApi - Minimal and portable HTTP server
.DESCRIPTION
    Simple and clean HTTP server without external dependencies or certificates.
    Perfect for quick testing, local development, and situations where HTTPS is not required.
    Completely self-contained and portable across different systems.

.NOTES
    Version: 1.1.0
    Date: 2025-08-28
    Requirements: PowerShell 5.1+, Pode module
    Port: 8080 (HTTP alternative standard)
#>

#Requires -Modules Pode

# =============================================================================
# CENTRALIZED LOGGING FUNCTION for the entire server
# =============================================================================

function Write-ServerLog {
    <#
    .SYNOPSIS
        Writes centralized logs to both console and file with daily rotation
    .DESCRIPTION
        Handles all HTTP server logging with timestamps and levels.
        Logs are saved in logs/ folder with automatic daily rotation.
        Simplified version without TraceId (not needed for basic HTTP server).
    .PARAMETER Message
        The message to log
    .PARAMETER Level
        The log level: Info, Warning, Error (default: Info)
    #>
    param([string]$Message, [string]$Level = "Info")
    
    # Create consistent timestamp in readable format
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Always show log on console for immediate debugging
    Write-Host $logEntry
    
    # Save to file with automatic daily rotation
    $logDir = Join-Path $PSScriptRoot "logs"
    if (-not (Test-Path $logDir)) {
        # Create logs folder if it doesn't exist
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Filename with date for automatic rotation (server-2025-08-28.log)
    $logFile = Join-Path $logDir "server-$(Get-Date -Format 'yyyy-MM-dd').log"
    # Always write, even if there are file access errors
    Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
}

# =============================================================================
# HTTP SERVER STARTUP - Simple and direct
# =============================================================================

# Startup log to indicate process beginning
Write-ServerLog "🌐 Starting SimpleHTTPPodeApi..." "Info"

# HTTP server startup without preliminary validations (unlike HTTPS)
# No certificate checks or complex configurations needed
try {
    # Start-PodeServer starts HTTP server with 5 concurrent threads for better performance
    # Balanced between performance and resource usage
    Start-PodeServer -Threads 5 -ScriptBlock {
        
        # =============================================================================
        # INTERNAL PODE SERVER FUNCTIONS
        # Optimized versions for use inside HTTP server
        # =============================================================================
        
        # Internal version of Write-ServerLog for use inside Pode
        # Duplicated because external functions are not always available inside Pode
        function Write-InternalLog {
            param([string]$Message, [string]$Level = "Info")
            
            # Same timestamp format for consistency with external logs
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] [$Level] $Message"
            
            # Console output for immediate debug
            Write-Host $logEntry
            
            # Save to log files (same logic as external function with size control)
            $currentPath = $PSScriptRoot
            $logDir = Join-Path $currentPath "logs"
            if (-not (Test-Path $logDir)) {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }
            
            $logFile = Join-Path $logDir "server-$(Get-Date -Format 'yyyy-MM-dd').log"
            Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
        }
        
        # Server configuration start log
        Write-InternalLog "🔧 Configuring server..." "Info"
        
        # =============================================================================
        # HTTP ENDPOINT CONFIGURATION
        # =============================================================================
        
        # Simple HTTP endpoint configuration without certificates
        # Uses localhost for security (doesn't expose on all network interfaces)
        # Port 8080: standard for development and HTTP testing
        Add-PodeEndpoint -Address "localhost" -Port 8080 -Protocol HTTP
        Write-InternalLog "✅ HTTP endpoint added on port 8080" "Info"
        
        # =============================================================================
        # REQUEST LOGGING MIDDLEWARE - Simplified version for HTTP
        # =============================================================================
        
        # Middleware that logs EVERY HTTP request with essential details
        # Simplified version compared to HTTPS: no TraceId, no authentication
        Add-PodeMiddleware -Name 'RequestLogger' -ScriptBlock {
            # Collect basic HTTP request information
            $requestInfo = @{
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                method = $WebEvent.Method          # GET, POST, etc.
                path = $WebEvent.Path              # /, /hello, /health, etc.
                ip = $WebEvent.Request.RemoteEndPoint.Address.ToString()  # Client IP
                userAgent = $WebEvent.Request.Headers['User-Agent']       # Browser/tool used
            }
            
            # Create simple log message for monitoring
            $logMessage = "[$($requestInfo.timestamp)] [$($requestInfo.method)] $($requestInfo.path) from $($requestInfo.ip)"
            Write-Host $logMessage -ForegroundColor Gray  # Gray for non-authenticated HTTP requests
            
            # Save logs to file with dual format (readable + structured JSON)
            $currentPath = $PSScriptRoot
            $logDir = Join-Path $currentPath "logs"
            if (Test-Path $logDir) {
                # Text log for human reading
                $requestLogFile = Join-Path $logDir "requests-$(Get-Date -Format 'yyyy-MM-dd').log"
                Add-Content -Path $requestLogFile -Value $logMessage -ErrorAction SilentlyContinue
                
                # JSON log for automatic parsing and analysis
                $structuredLogFile = Join-Path $logDir "requests-structured-$(Get-Date -Format 'yyyy-MM-dd').log"
                $jsonEntry = $requestInfo | ConvertTo-Json -Compress
                Add-Content -Path $structuredLogFile -Value $jsonEntry -ErrorAction SilentlyContinue
            }
        }
        
        # =============================================================================
        # RATE LIMITING MIDDLEWARE - Protects against spam and DoS attacks
        # =============================================================================
        
        # Rate limiting: max 60 requests per minute per IP address
        # Simple in-memory rate limiting for basic protection
        Add-PodeMiddleware -Name 'RateLimiting' -ScriptBlock {
            $clientIP = $WebEvent.Request.RemoteEndPoint.Address.ToString()
            $currentMinute = Get-Date -Format "yyyy-MM-dd HH:mm"
            $rateLimitKey = "$clientIP-$currentMinute"
            
            # Initialize rate limit storage if not exists
            if (-not $WebEvent.Data.ContainsKey('RateLimits')) {
                $WebEvent.Data.RateLimits = @{}
            }
            
            # Get current request count for this IP in current minute
            $requestCount = $WebEvent.Data.RateLimits[$rateLimitKey]
            if (-not $requestCount) {
                $requestCount = 0
            }
            
            # Check if rate limit exceeded
            if ($requestCount -ge 60) {
                Write-Host "🚫 Rate limit exceeded for $clientIP ($requestCount requests/minute)" -ForegroundColor Red
                
                # Return 429 Too Many Requests
                Set-PodeResponseStatus -Code 429 -Description 'Too Many Requests'
                Write-PodeJsonResponse -Value @{
                    error = "Rate limit exceeded"
                    message = "Maximum 60 requests per minute allowed"
                    retryAfter = 60
                } -StatusCode 429
                return $false  # Stop processing this request
            }
            
            # Increment request count
            $WebEvent.Data.RateLimits[$rateLimitKey] = $requestCount + 1
            
            # Clean old rate limit entries (keep only current and previous minute)
            $previousMinute = (Get-Date).AddMinutes(-1).ToString("yyyy-MM-dd HH:mm")
            $keysToKeep = @("$clientIP-$currentMinute", "$clientIP-$previousMinute")
            
            $keysToRemove = $WebEvent.Data.RateLimits.Keys | Where-Object { $_ -notlike "$clientIP-*" -or $_ -notin $keysToKeep }
            foreach ($key in $keysToRemove) {
                $WebEvent.Data.RateLimits.Remove($key)
            }
        }
        
        # =============================================================================
        # OWASP SECURITY MIDDLEWARE - Basic security headers for HTTP
        # =============================================================================
        
        # Middleware that adds OWASP-compliant security headers to ALL responses
        # Simplified version for HTTP (without HSTS which requires HTTPS)
        Add-PodeMiddleware -Name 'OWASPSecurityHeaders' -ScriptBlock {
            try {
                # Content Security Policy - Prevents XSS and code injection
                Set-PodeHeader -Name 'Content-Security-Policy' -Value "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
                
                # Prevents MIME type sniffing attacks
                Set-PodeHeader -Name 'X-Content-Type-Options' -Value 'nosniff'
                
                # XSS protection for legacy browsers
                Set-PodeHeader -Name 'X-XSS-Protection' -Value '1; mode=block'
                
                # Prevents clickjacking attacks
                Set-PodeHeader -Name 'X-Frame-Options' -Value 'DENY'
                
                # Controls referrer information sent
                Set-PodeHeader -Name 'Referrer-Policy' -Value 'strict-origin-when-cross-origin'
                
                # Disables potentially dangerous browser features
                Set-PodeHeader -Name 'Permissions-Policy' -Value 'camera=(), microphone=(), geolocation=()'
                
                # Reduced server signature for security through obscurity
                Set-PodeHeader -Name 'Server' -Value 'SimpleHTTPPodeApi'
            }
            catch {
                # Log error but don't block the request
                Write-Host "⚠️ Security headers error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # =============================================================================
        # HTTP ROUTES DEFINITION - Simple and direct endpoints
        # =============================================================================
        
        # ROOT ENDPOINT (/) - Main HTTP server status page
        # Informational page showing server status and available endpoints
        Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
            # Generate HTML page with HTTP server information
            # Similar style to HTTPS version but without security indicators
            Write-PodeHtmlResponse -Value @"
<!DOCTYPE html>
<html>
<head>
    <title>SimpleHTTPPodeApi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { color: #28a745; font-size: 24px; margin-bottom: 20px; }
        .info { color: #666; line-height: 1.6; }
        .endpoint { background: #f8f9fa; padding: 10px; margin: 10px 0; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <div class="status">✅ Server Funzionante</div>
        <div class="info">
            <strong>SimpleHTTPPodeApi</strong> is active and listening.<br>
            Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br><br>
            <strong>Available endpoints:</strong><br>
            <div class="endpoint">GET / - This page</div>
            <div class="endpoint">GET /hello - Hello World JSON</div>
            <div class="endpoint">GET /health - Health check</div>
        </div>
    </div>
</body>
</html>
"@ -StatusCode 200
        }
        
        # =============================================================================
        # LOADING ROUTES FROM EXTERNAL FILES
        # =============================================================================
        
        # Load all route files from routes/ folder
        $routesPath = Join-Path $PSScriptRoot "routes"
        if (Test-Path $routesPath) {
            $routeFiles = Get-ChildItem -Path $routesPath -Filter "*.ps1"
            foreach ($routeFile in $routeFiles) {
                try {
                    Write-InternalLog "📂 Loading route: $($routeFile.Name)" "Info"
                    . $routeFile.FullName
                    Write-InternalLog "✅ Route loaded: $($routeFile.Name)" "Info"
                }
                catch {
                    Write-InternalLog "❌ Error loading route $($routeFile.Name): $($_.Exception.Message)" "Error"
                }
            }
        }
        else {
            Write-InternalLog "⚠️ Routes folder not found: $routesPath" "Warning"
        }
        
        # =============================================================================
        # FINAL SUMMARY AND HTTP SERVER READY
        # =============================================================================
        
        # Summary log to confirm configured endpoints
        Write-InternalLog "🎯 Routes configured:" "Info"
        Write-InternalLog "   GET / - Server status page" "Info"
        Write-InternalLog "   + Routes from files in routes/ folder" "Info"
        Write-InternalLog "   All other URLs return 404" "Info"
        Write-InternalLog "🛡️ OWASP security headers enabled" "Info"
        Write-InternalLog "🚫 Rate limiting enabled (60 req/min per IP)" "Info"
        Write-InternalLog "🚀 Server ready on http://localhost:8080" "Info"
        
        # =============================================================================
        # PERIODIC MEMORY CLEANUP - Prevents memory leaks in long-running server
        # =============================================================================
        
        # Schedule periodic memory cleanup every 30 minutes to prevent memory leaks
        # This helps maintain stable memory usage during long-running operations
        Add-PodeSchedule -Name 'MemoryCleanup' -Cron '*/30 * * * *' -ScriptBlock {
            try {
                # Force garbage collection to free unused memory
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
                [System.GC]::Collect()  # Second pass for better cleanup
                
                # Simple log message
                Write-Host "🧹 Automatic memory cleanup completed" -ForegroundColor Green
            }
            catch {
                Write-Host "⚠️ Memory cleanup error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # HTTP server is now fully configured and listening
        # Pode will automatically handle incoming requests without authentication
    }
}
catch {
    # Error handling during HTTP server startup
    # Catches issues with busy ports, wrong configurations, binding problems, etc.
    Write-ServerLog "❌ Server error: $($_.Exception.Message)" "Error"
    Write-ServerLog "🔍 Stack trace: $($_.ScriptStackTrace)" "Error"
    exit 1  # Exit with error code to indicate failure
}
finally {
    # Finally block always executes, even on errors or interruptions (Ctrl+C)
    # Performs basic resource cleanup and connection closure
    
    Write-ServerLog "🔄 Starting cleanup..." "Info"
    
    try {
        # Basic PowerShell resource cleanup
        # Force garbage collection to free memory
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-ServerLog "✅ Memory cleanup completed" "Info"
        
        # Close any open network connections from current process
        # Force closure of listening TCP sockets
        $connections = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
        if ($connections) {
            Write-ServerLog "🔌 Found $($connections.Count) active connections on port 8080" "Info"
            # TCP connections close automatically when process terminates
        }
        
        # Clean temporary files created by server (if any exist)
        $tempPath = Join-Path $env:TEMP "SimpleHTTPPodeApi_*"
        $tempFiles = Get-ChildItem -Path $tempPath -ErrorAction SilentlyContinue
        if ($tempFiles) {
            $tempFiles | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-ServerLog "🗑️ Cleaned up $($tempFiles.Count) temporary files" "Info"
        }
        
        # Ensure all logs are written to disk before shutdown
        Start-Sleep -Milliseconds 100  # Brief pause to complete I/O operations
        
        Write-ServerLog "✅ Cleanup completed successfully" "Info"
    }
    catch {
        # If cleanup fails, log error but don't block shutdown
        Write-ServerLog "⚠️ Cleanup error (non-critical): $($_.Exception.Message)" "Warning"
    }
    
    Write-ServerLog "🛑 Server stopped" "Info"
}
