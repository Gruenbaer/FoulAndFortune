# APK Distribution Guide

## ⚠️ SECURITY WARNING

**NEVER commit APK/AAB files to Git!**

APKs contain embedded secrets that can be extracted by:
- Decompiling with `apktool` or `jadx`
- Extracting `strings.xml` resources
- Analyzing compiled Dart code

Even with `--dart-define`, secrets are compiled into the binary.

---

## Proper APK Distribution

### Option 1: GitHub Releases (Recommended)

**Best for:** Public distribution

1. Build APK with secrets:
   ```powershell
   $env:GEMINI_API_KEY = "your_key"
   $env:SMTP_PASSWORD = "your_password"
   .\build_scripts\build.ps1
   ```

2. Create a GitHub Release:
   - Go to: https://github.com/Gruenbaer/141fortune/releases
   - Click "Create a new release"
   - Tag: `v1.0.0` (increment for each release)
   - Title: "Fortune 14/1 v1.0.0"
   - Attach: `build\app\outputs\flutter-apk\app-release.apk`
   - Click "Publish release"

3. Users download from: `https://github.com/Gruenbaer/141fortune/releases/latest`

**Advantages:**
- Not in git history
- Downloadable by anyone
- Version tracking
- Release notes

### Option 2: Direct Server Upload (Current Method)

**Best for:** Private distribution

```powershell
# Build APK
.\build_scripts\build.ps1

# Upload to your server
scp build\app\outputs\flutter-apk\app-release.apk ssh-w0208b4b@w0208b4b.kasserver.com:~/temp.apk
ssh ssh-w0208b4b@w0208b4b.kasserver.com "mv temp.apk /www/htdocs/w0208b4b/knthlz.de/download/fortune141.apk"
```

Download URL: `https://knthlz.de/download/fortune141.apk`

### Option 3: Google Play Store

**Best for:** Professional distribution

- No secrets in APK needed (use Google Cloud Secret Manager)
- Automatic updates
- Wider distribution
- Costs $25 one-time fee

---

## Additional Security for Production

### 1. ProGuard/R8 Obfuscation

Enable in `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

This makes decompilation harder (but not impossible).

### 2. API Key Restrictions (Already Done)

Configured in Google Cloud Console:
- ✅ Android app restriction: `com.knthlz.fortune141`
- ✅ API restriction: Generative Language API only
- ✅ Quota limits

Even if key is extracted, it only works in your app.

### 3. Server-Side Proxy (Future Enhancement)

For maximum security:
- Create a backend API on your server
- App calls your server (with auth token)
- Server calls Gemini API with server-side key
- Key never in APK

---

## Current Setup

✅ **Secrets managed with --dart-define**  
✅ **API restrictions configured**  
✅ **APKs blocked in .gitignore**  
✅ **Distribution via knthlz.de**  

The current setup is **reasonably secure** for a small-scale app:
- API key extracted from APK only works in your Android app
- Daily quota limits prevent abuse
- SMTP credentials have limited scope (email sending only)

For a commercial app with many users, consider the server-side proxy approach.
