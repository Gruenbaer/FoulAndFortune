---
description: Deploy to Play Store internal track
---

# Play Store Release Workflow

Complete workflow for building and uploading to Google Play Store.

## Prerequisites

- ✅ Release keystore configured (`android/upload-keystore.jks`)
- ✅ Key properties file exists (`android/key.properties`)
- ✅ Google Play API credentials configured (`android/api-key.json`)
- ✅ Fastlane installed: `gem install fastlane`
- ✅ All changes committed to git

## Current Configuration

**Package:** `com.knthlz.foulandfortune`
**Current Version:** `3.9.3+21` (from pubspec.yaml)
**Track:** Beta (Open Testing - **no email addresses required!**)
**Bundle Location:** `build/app/outputs/bundle/release/app-release.aab`

## Quick Deploy

### Option 1: Full Deploy (Build + Upload)

// turbo
Navigate to android directory and deploy:
```powershell
cd android
fastlane deploy
```

This will:
1. Clean build directory
2. Run `flutter pub get`
3. Build release app bundle (`.aab`)
4. Upload to Play Store **beta track (open testing)** as **draft**

### Option 2: Build Only (No Upload)

// turbo
Just build the bundle without uploading:
```powershell
cd android
fastlane build
```

### Option 3: Manual Upload

If you want to manually upload a pre-built bundle:

// turbo
```powershell
cd android
fastlane run upload_to_play_store track:beta release_status:draft aab:../build/app/outputs/bundle/release/app-release.aab skip_upload_screenshots:true skip_upload_images:true skip_upload_metadata:true
```

## Step-by-Step Process

### 1. Bump Version (if needed)

Edit `pubspec.yaml`:
```yaml
version: 3.9.4+22  # Increment version and build number
```

**Rules:**
- Always increment build number (+21 → +22)
- Increment version for user-facing changes (3.9.3 → 3.9.4)

### 2. Test Build Locally

// turbo
Ensure the app builds without errors:
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Verify the bundle was created:
```powershell
ls build/app/outputs/bundle/release/app-release.aab
```

### 3. Deploy to Play Store

// turbo
```powershell
cd android
fastlane deploy
```

**What happens:**
1. ✅ Cleans previous build
2. ✅ Fetches dependencies
3. ✅ Builds signed release bundle
4. ✅ Uploads to Play Store internal track (draft)

### 4. Review in Play Console

1. Open Google Play Console: https://play.google.com/console
2. Navigate to **FoulAndFortune** app
3. Go to **Testing** → **Open testing**
4. Review the draft release
5. Add release notes if needed
6. Click **Review release** → **Start rollout to Open testing**

### 5. Share Test Link with Users

1. In Play Console: **Testing** → **Open testing** → **Testers**
2. Copy the **opt-in URL** (looks like: `https://play.google.com/apps/testing/com.knthlz.foulandfortune`)
3. Share this link with anyone who wants to test
4. Users click the link → **Become a tester** → Install from Play Store

## Troubleshooting

### "APK or Bundle not found"

Check if bundle exists:
```powershell
ls build/app/outputs/bundle/release/app-release.aab
```

If missing, run build manually:
```powershell
flutter build appbundle --release
```

### "Signing configuration error"

Verify keystore files exist:
```powershell
ls android/upload-keystore.jks
ls android/key.properties
```

### "API authentication failed"

Check JSON key file:
```powershell
ls android/api-key.json
```

Ensure it's not corrupted or expired. Download fresh from Google Cloud Console if needed.

### "Version code XXX has already been used"

Increment the build number in `pubspec.yaml`:
```yaml
version: 3.9.3+22  # Increment +21 → +22
```

### "Fastlane command not found"

Install Fastlane:
```powershell
gem install fastlane
```

Or use bundler:
```powershell
cd android
bundle install
bundle exec fastlane deploy
```

## Release Tracks

### Internal (Current Default)
- **Purpose:** Quick testing with small group
- **Review:** Minimal (usually < 1 hour)
- **Testers:** Up to 100 email addresses
- **Best for:** Initial testing, QA

### Alpha
- **Purpose:** Broader testing
- **Review:** Minimal
- **Testers:** Unlimited (opt-in link)
- **Best for:** Beta testers, early adopters

### Beta
- **Purpose:** Public beta testing
- **Review:** Minimal
- **Testers:** Public or closed group
- **Best for:** Pre-release public testing

### Production
- **Purpose:** Public release
- **Review:** Full review (can take days)
- **Roll-out:** Can be gradual (e.g., 10%, 50%, 100%)
- **Best for:** Official releases

## Changing the Track

Edit `android/fastlane/Fastfile` and change the `track:` parameter:

```ruby
upload_to_play_store(
  track: 'alpha',  # or 'beta', 'production'
  release_status: 'draft',  # or 'completed' to publish immediately
  # ... other options
)
```

## Quick Reference

| Task | Command |
|------|---------|
| Full deploy | `cd android && fastlane deploy` |
| Build only | `cd android && fastlane build` |
| Test build | `flutter build appbundle --release` |
| View bundle | `ls build/app/outputs/bundle/release/` |
| Play Console | https://play.google.com/console |

## After Upload Checklist

- [ ] Verify bundle uploaded in Play Console
- [ ] Check version code matches pubspec.yaml
- [ ] Add release notes in Play Console
- [ ] Review permissions and declarations
- [ ] Submit for review (if ready)
- [ ] Test download with internal testers
