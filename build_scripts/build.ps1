# Build script for release APK
# This script builds the app with secrets from environment variables
# 
# Usage: 
#   1. Set environment variables with your secrets (DO NOT hardcode here!)
#   2. Run this script: .\build_scripts\build.ps1

param(
    [string]$DeviceId = ""
)

# Check if secrets are set in environment
if (-not $env:GEMINI_API_KEY) {
    Write-Host "ERROR: GEMINI_API_KEY environment variable not set" -ForegroundColor Red
    Write-Host "Please set it before running this script:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your_key_here"' -ForegroundColor Yellow
    exit 1
}

if (-not $env:SMTP_PASSWORD) {
    Write-Host "ERROR: SMTP_PASSWORD environment variable not set" -ForegroundColor Red
    Write-Host "Please set it before running this script:" -ForegroundColor Yellow
    Write-Host '  $env:SMTP_PASSWORD = "your_password_here"' -ForegroundColor Yellow
    exit 1
}

Write-Host "Building release APK with secure configuration..." -ForegroundColor Green

# Build with secrets passed as dart-define flags
puro flutter build apk --release `
  --dart-define=GEMINI_API_KEY=$env:GEMINI_API_KEY `
  --dart-define=SMTP_HOST=w0208b4b.kasserver.com `
  --dart-define=SMTP_PORT=465 `
  --dart-define=SMTP_USERNAME=m07878f2 `
  --dart-define=SMTP_PASSWORD=$env:SMTP_PASSWORD `
  --dart-define=FEEDBACK_RECIPIENT=info@knthlz.de

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}
