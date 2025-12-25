# Script to build APK and prepare for GitHub Release
# 
# Usage:
#   1. Set your API key: $env:GEMINI_API_KEY = "your_new_key"
#   2. Set SMTP password: $env:SMTP_PASSWORD = "your_password"  
#   3. Run: .\build_scripts\build_and_release.ps1

param(
    [switch]$SkipBuild = $false
)

Write-Host "=== Fortune 14/1 - GitHub Release Builder ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (-not $env:GEMINI_API_KEY -and -not $SkipBuild) {
    Write-Host "ERROR: GEMINI_API_KEY not set!" -ForegroundColor Red
    Write-Host "Set it with: `$env:GEMINI_API_KEY = 'your_new_key_here'" -ForegroundColor Yellow
    exit 1
}

if (-not $env:SMTP_PASSWORD -and -not $SkipBuild) {
    Write-Host "ERROR: SMTP_PASSWORD not set!" -ForegroundColor Red  
    Write-Host "Set it with: `$env:SMTP_PASSWORD = 'your_password_here'" -ForegroundColor Yellow
    exit 1
}

# Build APK
if (-not $SkipBuild) {
    Write-Host "Building release APK..." -ForegroundColor Green
    & "$PSScriptRoot\build.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}

# Check if APK exists
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "ERROR: APK not found at $apkPath" -ForegroundColor Red
    exit 1
}

$apkSize = (Get-Item $apkPath).Length / 1MB
Write-Host ""
Write-Host "✅ APK ready!" -ForegroundColor Green
Write-Host "   Location: $apkPath" -ForegroundColor Cyan
Write-Host "   Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Next Steps ===" -ForegroundColor Yellow
Write-Host "1. Go to: https://github.com/Gruenbaer/fortune142/releases/new" -ForegroundColor White
Write-Host "   (The form should be pre-filled from the browser)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Drag and drop this APK into the 'Attach binaries' area:" -ForegroundColor White
Write-Host "   $apkPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Click 'Publish release'" -ForegroundColor White
Write-Host ""
Write-Host "Download URL will be:" -ForegroundColor Gray
Write-Host "https://github.com/Gruenbaer/fortune142/releases/download/v1.0.0/app-release.apk" -ForegroundColor Cyan
Write-Host ""

# Open the APK folder in Explorer
Write-Host "Opening APK folder..." -ForegroundColor Green
Start-Process explorer.exe -ArgumentList "/select,$apkPath"
