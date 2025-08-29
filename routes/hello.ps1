# ENDPOINT HELLO (/hello) - Simple Hello World
# Basic test endpoint that returns an HTML page
Add-PodeRoute -Method Get -Path '/hello' -ScriptBlock {
    Write-PodeHtmlResponse -Value @"
<!DOCTYPE html>
<html>
<head>
    <title>Hello World - SimpleHTTPPodeApi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { color: #007bff; font-size: 24px; margin-bottom: 20px; }
        .info { color: #666; line-height: 1.6; }
        .endpoint { background: #f8f9fa; padding: 10px; margin: 10px 0; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <div class="status">👋 Hello World!</div>
        <div class="info">
            Welcome to the greeting endpoint of <strong>SimpleHTTPPodeApi</strong>.<br>
            Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br><br>
            <strong>Information:</strong><br>
            <div class="endpoint">Server: SimpleHTTPPodeApi</div>
            <div class="endpoint">Endpoint: GET /hello</div>
            <div class="endpoint">Format: HTML</div>
        </div>
    </div>
</body>
</html>
"@ -StatusCode 200
}