# Secure Secrets Management

This project uses Flutter's `--dart-define` for secure secrets management.

## Why This Approach?

- ✅ **No secrets in source code** - prevents accidental exposure
- ✅ **Build-time only** - secrets only exist during compilation
- ✅ **No risk of commit** - impossible to accidentally commit secrets
- ✅ **Industry standard** - widely used best practice

## Setup

### 1. Configure Your Secrets

Set environment variables (one time per session):

```powershell
# Set your Gemini API Key
$env:GEMINI_API_KEY = "your_actual_api_key_here"

# Set your SMTP Password  
$env:SMTP_PASSWORD = "your_actual_smtp_password_here"
```

### 2. Google Cloud Console Configuration

**IMPORTANT**: Configure API restrictions to prevent abuse even if key leaks:

1. Go to https://console.cloud.google.com/apis/credentials
2. Find your API key and click Edit
3. Set **Application restrictions**:
   - Select "Android apps"
   - Add package name: `com.knthlz.fortune141`
4. Set **API restrictions**:
   - Select "Restrict key"
   - Enable only: "Generative Language API"
5. Set **Quota limits**:
   - Configure daily request limits (e.g., 1000/day)

## Usage

### Development/Testing

```powershell
.\build_scripts\run_debug.ps1
```

This will prompt for secrets if not set in environment.

### Production Build

```powershell
.\build_scripts\build.ps1
```

Builds release APK with secrets from environment variables.

## How It Works

Secrets are passed as command-line flags during build:

```powershell
flutter run --dart-define=GEMINI_API_KEY=your_key
```

The app accesses them via `BuildEnv` class:

```dart
import 'package:fortune141/build_env.dart';

final apiKey = BuildEnv.geminiApiKey;
```

## Security Best Practices

1. **Never hardcode secrets** in scripts or source files
2. **Use environment variables** for all sensitive data
3. **Enable API restrictions** in Google Cloud Console
4. **Rotate keys regularly** (e.g., monthly)
5. **Monitor API usage** for unusual activity

## Files

- `lib/build_env.dart` - Environment variable accessors
- `build_scripts/build.ps1` - Production build script
- `build_scripts/run_debug.ps1` - Development run script
- `.env.example` - Template showing required secrets

## Migration from secrets.dart

The old `lib/secrets.dart` file is deprecated and will be deleted. All secrets are now managed via `--dart-define` flags.
