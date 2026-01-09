# Deploy Release Script for Fortune 14/2
# Automates: Build APK -> GitHub Release -> WhatsApp Notification

$ErrorActionPreference = "Stop"

# Define Flutter Path (Using Puro first, fallback to standard Flutter)
# First try to use Puro
if (Get-Command "puro" -ErrorAction SilentlyContinue) {
    $flutterBin = "puro"
    $flutterCmd = "flutter"
}
else {
    # Fallback to hardcoded path
    $flutterBin = "C:\Users\Emili\.gemini\flutter\bin\flutter.bat"
    $flutterCmd = ""
    if (-not (Test-Path $flutterBin)) {
        # Final fallback to PATH
        $flutterBin = "flutter"
    }
}

# 1. Extract Version from pubspec.yaml
Write-Host "Checking version in pubspec.yaml..." -ForegroundColor Cyan
$pubspec = Get-Content "pubspec.yaml"
$versionLine = $pubspec | Select-String "version: " | Select-Object -First 1
if (-not $versionLine) {
    Write-Error "Could not find version in pubspec.yaml"
}
$fullVersion = $versionLine.ToString().Split(":")[1].Trim()
$version = $fullVersion.Split("+")[0] # Remove build number if present
Write-Host "   Detected Version: $version" -ForegroundColor Green


# 2. Check if Tag Exists
$tagExists = git tag -l "v$version"
if ($tagExists) {
    Write-Warning "Tag v$version already exists!"
    $confirm = Read-Host "Continue anyway? (y/n)"
    if ($confirm -ne 'y') { exit }
}

# 3. Generate Changelog
Write-Host "Generating Changelog..." -ForegroundColor Cyan
# Get last tag (get the most recent tag by version, not by describe)
$lastTag = git tag --sort=-version:refname | Select-Object -First 1
if (-not $lastTag) { 
    # If no tags exist, use first commit
    $lastTag = git rev-list --max-parents=0 HEAD 
}

$commits = git log --oneline --no-merges "$lastTag..HEAD" | ForEach-Object { "- $_" }
Write-Host "   Changes since $lastTag :"
$commits | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

# Auto-accept generated changelog
Write-Host "`nUsing auto-generated changelog" -ForegroundColor Green
$releaseNotes = $commits -join "`n"

# 4. Build APK
Write-Host "Building APK (Release Mode)..." -ForegroundColor Cyan
# Execute Flutter using Call Operator '&'
if ($flutterCmd) {
    & $flutterBin $flutterCmd build apk --release
}
else {
    & $flutterBin build apk --release
}
if ($LASTEXITCODE -ne 0) { throw "Build Failed" }

$apkPath = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apkPath)) { throw "APK not found at $apkPath" }

# Rename APK to include version for unique releases
$versionedApkName = "FoulAndFortune-v$version.apk"
$versionedApkPath = "build/app/outputs/flutter-apk/$versionedApkName"
Write-Host "Renaming APK to $versionedApkName..." -ForegroundColor Cyan
Copy-Item $apkPath $versionedApkPath -Force

# 5. Create GitHub Release
Write-Host "Publishing to GitHub..." -ForegroundColor Cyan
$notesFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $notesFile -Value $releaseNotes

try {
    # GH CLI usually in PATH
    cmd /c "gh release create v$version ""$versionedApkPath"" --title ""v$version"" --notes-file ""$notesFile"""
}
finally {
    Remove-Item $notesFile
}

if ($LASTEXITCODE -ne 0) { throw "GitHub Release Failed" }

Write-Host "Release v$version Published!" -ForegroundColor Green

# 6. Messaging Notifications
Write-Host "Select platforms to announce release:" -ForegroundColor Cyan
Write-Host "1) WhatsApp"
Write-Host "2) Telegram (Default)"
Write-Host "3) Signal"
Write-Host "4) All of the above"
$platformChoice = Read-Host "Choice [2]"
if ($platformChoice -eq "") { $platformChoice = "2" }

$repoUrl = "https://github.com/Gruenbaer/141fortune"
$downloadUrl = "$repoUrl/releases/download/v$version/$versionedApkName"

# Extract first commit message as feature highlight
$firstCommit = $commits | Select-Object -First 1
if ($firstCommit) {
    # Remove leading "- " and commit hash, keep just the message
    $notesText = $firstCommit -replace '^- [a-f0-9]+ ', ''
} else {
    $notesText = "Bug fixes and improvements"
}

# --- WhatsApp ---
if ($platformChoice -match "1|4") {
    Write-Host "Preparing WhatsApp..." -ForegroundColor Cyan
    # Use simple formatting compatible with both WhatsApp and Telegram
    $waMessage = "🎱 Foul & Fortune Update v$version ist da!`n`n"
    $waMessage += "Was ist neu:`n"
    $waMessage += "• $notesText`n`n"
    $waMessage += "Download: $downloadUrl`n`n"
    $waMessage += "Viel Spaß! 🎯"

    $encodedWaMsg = [Uri]::EscapeDataString($waMessage)
    $waUrl = "whatsapp://send?text=$encodedWaMsg"
    Start-Process $waUrl
    Start-Sleep -Seconds 1
}

# --- Telegram ---
if ($platformChoice -match "2|4") {
    Write-Host "Preparing Telegram..." -ForegroundColor Cyan
    # Use same formatting as WhatsApp for consistency
    $tgMessage = "🎱 Foul & Fortune Update v$version ist da!`n`n"
    $tgMessage += "Was ist neu:`n"
    $tgMessage += "• $notesText`n`n"
    $tgMessage += "Download: $downloadUrl`n`n"
    $tgMessage += "Viel Spaß! 🎯"
    
    $encodedTgMsg = [Uri]::EscapeDataString($tgMessage)
    $encodedUrl = [Uri]::EscapeDataString($downloadUrl)
    # https://t.me/share/url?url=<URL>&text=<TEXT>
    $tgUrl = "https://t.me/share/url?url=$encodedUrl&text=$encodedTgMsg"
    
    Start-Process $tgUrl
    Start-Sleep -Seconds 1
}

# --- Signal ---
if ($platformChoice -match "3|4") {
    Write-Host "Preparing Signal..." -ForegroundColor Cyan
    $sigMessage = "Fortune 14/2 Update v$version is live!`n`n"
    $sigMessage += "Whats New:`n"
    $sigMessage += "$notesText`n`n"
    $sigMessage += "Download: $downloadUrl"

    # Signal Desktop has no URI for text. We must use clipboard.
    Set-Clipboard -Value $sigMessage
    Write-Warning "Signal does not support automatic message filling."
    Write-Warning "The release message has been COPIED to your CLIPBOARD."
    Write-Host "1. Opening Signal..."
    Write-Host "2. Select your recipients."
    Write-Host "3. Paste (Ctrl+V) the message."
    
    # Try to open Signal Desktop. It might be in different spots or just 'signal' if in PATH.
    # Fallback to signal.me specific link just to trigger app open if possible, 
    # but strictly opening the app is hard without known path. 
    # We'll try user protocol if registered, or just let user open it.
    # signal.me links are usually for joining/contacting.
    
    # Attempt to launch via Protocol Handler 'signal://' does not usually work for 'open'.
    # We will try valid generic command or just instruct user.
    # But let's try opening the standard install path if it exists, or tell user.
    
    $signalPath = "$env:LOCALAPPDATA\Programs\signal-desktop\Signal.exe"
    if (Test-Path $signalPath) {
        Start-Process $signalPath
    }
    else {
        # Try generic shell open if protocol is registered (unlikely to just open app empty)
        # Just give feedback
        Write-Host "Could not auto-start Signal. Please open it manually." -ForegroundColor Yellow
    }
}

Write-Host "Done! Notifications prepared." -ForegroundColor Green
