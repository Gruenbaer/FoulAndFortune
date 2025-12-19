# Fortune 142 Build Script
# Automatically builds and renames APK with proper naming convention

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('debug', 'release')]
    [string]$BuildType = 'release'
)

Write-Host "Building Fortune 142 v2.0.0 ($BuildType)..." -ForegroundColor Cyan

# Run Flutter build
& "C:\Users\emiliano.kamppeter\.puro\envs\stable\flutter\bin\flutter.bat" build apk --$BuildType

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Read version from pubspec.yaml
    $pubspecContent = Get-Content ".\pubspec.yaml" -Raw
    if ($pubspecContent -match 'version:\s*(\d+\.\d+\.\d+)') {
        $version = $Matches[1]
    } else {
        $version = "2.0.0"
    }
    
    # Define paths
    $sourceFile = ".\build\app\outputs\flutter-apk\app-$BuildType.apk"
    $targetFile = ".\build\app\outputs\flutter-apk\fortune142-v$version-$BuildType.apk"
    
    # Rename APK
    if (Test-Path $sourceFile) {
        Copy-Item $sourceFile $targetFile -Force
        Write-Host "`n✅ APK created: fortune142-v$version-$BuildType.apk" -ForegroundColor Green
        Write-Host "📍 Location: build\app\outputs\flutter-apk\" -ForegroundColor Yellow
        Write-Host "📦 Size: $((Get-Item $targetFile).Length / 1MB | ForEach-Object {$_.ToString('0.0')}) MB`n" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Error: Source APK not found at $sourceFile" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
