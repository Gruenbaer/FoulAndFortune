$ErrorActionPreference = "Stop"

$envFile = "$PSScriptRoot/../.env"
$envExample = "$PSScriptRoot/../.env.example"

# 1. Ensure .env exists
if (!(Test-Path $envFile)) {
    Write-Warning ".env file not found. Creating from .env.example..."
    Copy-Item $envExample $envFile
    Write-Host "Created .env file." -ForegroundColor Green
}

# 2. Read existing vars
$envContent = Get-Content $envFile
$envMap = @{}
foreach ($line in $envContent) {
    if ($line -match "^\s*([^#=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $val = $matches[2].Trim()
        $envMap[$key] = $val
    }
}

# 3. Check for GITHUB_TOKEN
if ([string]::IsNullOrWhiteSpace($envMap["GITHUB_TOKEN"]) -or $envMap["GITHUB_TOKEN"] -eq "ghp_your_token_here") {
    Write-Host "`n⚠️  GitHub Token missing or default!" -ForegroundColor Yellow
    Write-Host "Please create a token at: https://github.com/settings/tokens"
    Write-Host "Select (classic) token with 'repo' scope."
    
    $token = Read-Host "Enter your GitHub Token (starts with ghp_...)"
    if (![string]::IsNullOrWhiteSpace($token)) {
        Add-Content -Path $envFile -Value "`nGITHUB_TOKEN=$token"
        $envMap["GITHUB_TOKEN"] = $token
        Write-Host "Token saved to .env" -ForegroundColor Green
    }
    else {
        Write-Warning "No token provided. QA Bot will use offline mode (local files)."
    }
}

# 4. Construct Dart Defines
$dartDefines = @()
foreach ($key in $envMap.Keys) {
    $val = $envMap[$key]
    if (![string]::IsNullOrWhiteSpace($val)) {
        $dartDefines += "--dart-define=$key=$val"
    }
}

# 5. Run Flutter
Write-Host "`n🚀 Launching Fortune 14/1 with configuration..." -ForegroundColor Cyan
if ($envMap.ContainsKey("GITHUB_TOKEN")) {
    Write-Host "GitHub Integration: ENABLED" -ForegroundColor Green
}
else {
    Write-Host "GitHub Integration: DISABLED (Offline Mode)" -ForegroundColor Yellow
}

$cmd = "puro flutter run -d emulator-5554 $dartDefines"
Write-Host "Command: $cmd" -ForegroundColor DarkGray

Invoke-Expression $cmd
