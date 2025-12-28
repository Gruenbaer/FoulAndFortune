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

# Build APK (build.ps1 now handles .env loading automatically)
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

# Extract version from pubspec.yaml
$pubspecPath = "pubspec.yaml"
$versionLine = Get-Content $pubspecPath | Select-String "^version:"
if ($versionLine) {
    $version = ($versionLine -replace "version:\s*", "").Trim()
    # Remove build number (e.g., "3.5.0+3" -> "3.5.0")
    $versionTag = ($version -split '\+')[0]
    $tag = "v$versionTag"
}
else {
    Write-Host "WARNING: Could not extract version from pubspec.yaml" -ForegroundColor Yellow
    $tag = Read-Host "Enter release tag (e.g., v3.5.0)"
}

Write-Host "=== Creating GitHub Release ===" -ForegroundColor Cyan
Write-Host "Tag: $tag" -ForegroundColor White

# Check if gh is authenticated
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: GitHub CLI not authenticated" -ForegroundColor Red
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    exit 1
}

# Create release with APK
Write-Host "Uploading APK to GitHub..." -ForegroundColor Green

$releaseNotes = @"
Release build $tag with QA Assistant, Email Feedback, and GitHub Issue Integration.

Download and install:
``````
adb install -r app-release.apk
``````
"@

gh release create $tag $apkPath --repo Gruenbaer/141fortune --title "Fortune 14/1 - $tag" --notes $releaseNotes

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 Release published!" -ForegroundColor Green
    Write-Host "View at: https://github.com/Gruenbaer/141fortune/releases/tag/$tag" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Download URL:" -ForegroundColor Gray
    Write-Host "https://github.com/Gruenbaer/141fortune/releases/download/$tag/app-release.apk" -ForegroundColor Cyan
}
else {
    Write-Host ""
    Write-Host "❌ Release creation failed" -ForegroundColor Red
    Write-Host "You can create it manually at:" -ForegroundColor Yellow
    Write-Host "https://github.com/Gruenbaer/141fortune/releases/new" -ForegroundColor Cyan
}

