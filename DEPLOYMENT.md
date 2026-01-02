# Deployment Instructions

## Version 3.8.3+15 (Latest)

### Build Commands (CLI)

```powershell
# 1. Update version in pubspec.yaml
# Edit line 4: version: 3.8.3+15

# 2. Clean build
puro flutter clean

# 3. Build Release APK (for direct distribution)
puro flutter build apk --release

# 4. Build App Bundle (for Play Store)
puro flutter build appbundle --release
```

### Build Outputs

- **Release APK**: `build\app\outputs\flutter-apk\app-release.apk`
- **App Bundle**: `build\app\outputs\bundle\release\app-release.aab`

### Latest Build

- **Date**: 2026-01-02
- **Version**: 3.8.3+15
- **Size**: 83.2MB (APK)
- **Type**: Release APK
- **Location**: `build\app\outputs\flutter-apk\app-release.apk`

### Deployment Options

#### Option 1: Direct APK Installation
Transfer the APK file to your Android device and install directly.

#### Option 2: Google Play Store
1. Build app bundle: `puro flutter build appbundle --release`
2. Upload `app-release.aab` to Google Play Console
3. Create a new release and publish

### Notes

- If app bundle build fails with symbol stripping errors, use APK build instead
- APK file size may be larger than bundle but works for direct distribution
- Always increment version number before each release
