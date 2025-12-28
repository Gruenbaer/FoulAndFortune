# Build script for release APK
# This script builds the app with secrets from .env file
# 
# Usage: 
#   1. Ensure .env file exists with your secrets
#   2. Run this script: .\build_scripts\build.ps1

param(
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"

$envFile = "$PSScriptRoot/../.env"
$envExample = "$PSScriptRoot/../.env.example"

# Load .env file
if (!(Test-Path $envFile)) {
    if (Test-Path $envExample) {
        Write-Host "Creating .env from .env.example..." -ForegroundColor Yellow
        Copy-Item $envExample $envFile
        Write-Host "Please edit .env with your actual credentials and run again." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "ERROR: No .env or .env.example found!" -ForegroundColor Red
        exit 1
    }
}

# Parse .env into hash table
$envMap = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([^#=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $val = $matches[2].Trim()
        if (![string]::IsNullOrWhiteSpace($val)) {
            $envMap[$key] = $val
        }
    }
}

# Validate required keys
if (-not $envMap.ContainsKey("GEMINI_API_KEY") -or $envMap["GEMINI_API_KEY"] -eq "your_api_key_here") {
    Write-Host "ERROR: GEMINI_API_KEY not set in .env" -ForegroundColor Red
    exit 1
}

if (-not $envMap.ContainsKey("SMTP_PASSWORD") -or $envMap["SMTP_PASSWORD"] -eq "your_password_here") {
    Write-Host "ERROR: SMTP_PASSWORD not set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Building release APK with secure configuration..." -ForegroundColor Green

# Build dart-define arguments from .env
$dartDefines = @()
foreach ($key in $envMap.Keys) {
    $dartDefines += "--dart-define=$key=$($envMap[$key])"
}

# Build with all environment variables
puro flutter build apk --release $dartDefines

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
}
else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}
