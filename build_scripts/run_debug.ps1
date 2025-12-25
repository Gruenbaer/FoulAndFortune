# Run script for debug/development
# This script runs the app on a device with secrets from environment variables
#
# Usage:
#   1. Set environment variables with your secrets
#   2. Run: .\build_scripts\run_debug.ps1 [-DeviceId R5CTA1J0CHD]

param(
    [string]$DeviceId = "R5CTA1J0CHD"
)

# Check if secrets are set, prompt if not
if (-not $env:GEMINI_API_KEY) {
    $env:GEMINI_API_KEY = Read-Host -Prompt "Enter Gemini API Key (or press Enter to skip)"
}

if (-not $env:SMTP_PASSWORD) {
    $env:SMTP_PASSWORD = Read-Host -Prompt "Enter SMTP Password (or press Enter to skip)"
}

Write-Host "Running app on device $DeviceId with secure configuration..." -ForegroundColor Green

# Run with secrets passed as dart-define flags
puro flutter run -d $DeviceId `
  --dart-define=GEMINI_API_KEY=$env:GEMINI_API_KEY `
  --dart-define=SMTP_HOST=w0208b4b.kasserver.com `
  --dart-define=SMTP_PORT=465 `
  --dart-define=SMTP_USERNAME=m07878f2 `
  --dart-define=SMTP_PASSWORD=$env:SMTP_PASSWORD `
  --dart-define=FEEDBACK_RECIPIENT=info@knthlz.de
