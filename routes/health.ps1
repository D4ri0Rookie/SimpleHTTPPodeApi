# ENDPOINT HEALTH CHECK (/health) - HTTP server status check
# Monitoring endpoint that returns an HTML page
Add-PodeRoute -Method Get -Path '/health' -ScriptBlock {
    # Collect basic system information
    $uptime = [math]::Round([System.Environment]::TickCount / 1000 / 60, 1)  # uptime in minutes
    $memory = [math]::Round((Get-Process -Id $PID).WorkingSet64 / 1MB, 2)  # MB used
    
    Write-PodeHtmlResponse -Value @"
<!DOCTYPE html>
<html>
<head>
    <title>Health Check - SimpleHTTPPodeApi</title>
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
        <div class="status">✅ Sistema OK</div>
        <div class="info">
            Health check for <strong>SimpleHTTPPodeApi</strong>.<br>
            Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br><br>
            <strong>System metrics:</strong><br>
            <div class="endpoint">Status: OK</div>
            <div class="endpoint">Uptime: $uptime minutes</div>
            <div class="endpoint">Memory: $memory MB</div>
            <div class="endpoint">Server: SimpleHTTPPodeApi</div>
        </div>
    </div>
</body>
</html>
"@ -StatusCode 200
}