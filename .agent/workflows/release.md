---
description: Create and publish a new release
---

# Release Workflow

Complete workflow for versioning, building, and publishing a new app release.

## Prerequisites

- Ensure all changes are committed
- GitHub CLI (`gh`) installed and authenticated
- Flutter/Puro in PATH

## Steps

### 1. Bump Version in pubspec.yaml

**Current format:** `version: 3.8.3+15` (version+buildNumber)

**How to bump:**
- **Major:** Breaking changes → `4.0.0+16`
- **Minor:** New features → `3.9.0+16`
- **Patch:** Bug fixes → `3.8.4+16`

**Manual edit:**
```yaml
# pubspec.yaml
version: 3.8.4+16  # Increment as needed
```

Or use sed/PowerShell:
```powershell
# Patch bump example
$content = Get-Content pubspec.yaml -Raw
$content -replace 'version: (\d+)\.(\d+)\.(\d+)\+(\d+)', {
    $major = $matches[1]
    $minor = $matches[2]
    $patch = [int]$matches[3] + 1
    $build = [int]$matches[4] + 1
    "version: $major.$minor.$patch+$build"
} | Set-Content pubspec.yaml
```

### 2. Update RELEASE_NOTES.md

Add a new section at the top describing user-facing improvements:

```markdown
### v3.8.4 - [Catchy Title] 🎯

Brief description of what changed.

* **Feature 1:** User-facing benefit
* **Fix:** What was broken and is now fixed
* **Polish:** UI/UX improvements

***
```

**Focus on:**
- What users will notice
- How it improves their experience
- Simple, non-technical language

### 3. Commit Version Bump

```bash
git add pubspec.yaml RELEASE_NOTES.md
git commit -m "chore: bump version to v3.8.4"
git push
```

### 4. Run Release Script

// turbo
Execute the automated release script:
```powershell
.\tools\deploy_release.ps1
```

**What it does:**
1. Extracts version from `pubspec.yaml`
2. Checks if tag already exists
3. Generates changelog from git commits
4. Builds release APK
5. Renames APK to `FoulAndFortune-v{version}.apk`
6. Creates GitHub release with versioned APK
7. Prepares messaging notifications

**Interactive prompts:**
- Web deployment (usually "n")
- Changelog customization (add highlights or press Enter)
- Messaging platform selection (usually "1" for WhatsApp)

### 5. Verify Release

Check the GitHub release:
```
https://github.com/Gruenbaer/FoulAndFortune/releases
```

**Verify:**
- ✅ Tag created (v3.8.4)
- ✅ APK attached with correct filename (`FoulAndFortune-v3.8.4.apk`)
- ✅ Release notes are correct
- ✅ Download link works

### 6. Copy WhatsApp Message

The script generates a WhatsApp message. Here's the template for manual creation:

```
*FoulAndFortune Update v3.8.4 ist da! 🎱*

*Was ist neu:*
• [Feature/Fix in user-friendly language]
• [Another improvement]
• [Bug fix explained simply]

*Download:* https://github.com/Gruenbaer/FoulAndFortune/releases/download/v3.8.4/FoulAndFortune-v3.8.4.apk

Viel Spaß! 🎯
```

**Tips for good messaging:**
- Lead with most exciting change
- Use emojis sparingly but effectively
- Keep it concise (3-4 bullet points max)
- Focus on user benefits, not technical details
- Always include direct download link

### 7. Send Notifications

**WhatsApp:**
- Script opens WhatsApp with pre-filled message
- Review, adjust if needed
- Select recipients or groups
- Send

**Alternative channels:**
- Telegram (option 2 in script)
- Signal (option 3 in script)

## Example: Full Release Flow

```powershell
# 1. Bump version
# (Edit pubspec.yaml: 3.8.3+15 → 3.8.4+16)

# 2. Update release notes
# (Add v3.8.4 section to RELEASE_NOTES.md)

# 3. Commit
git add pubspec.yaml RELEASE_NOTES.md
git commit -m "chore: bump version to v3.8.4"
git push

# 4. Release
.\tools\deploy_release.ps1
# - Enter "n" for web deployment
# - Enter custom notes or press Enter for auto-changelog
# - Enter "1" for WhatsApp

# 5. Verify on GitHub
# https://github.com/Gruenbaer/FoulAndFortune/releases

# 6. Send WhatsApp message
# (Script opens WhatsApp automatically)
```

## Troubleshooting

**"Tag already exists":**
- Delete remote tag: `git push origin :refs/tags/v3.8.4`
- Delete local tag: `git tag -d v3.8.4`
- Or increment version and try again

**"APK not found":**
- Ensure Flutter build completed successfully
- Check `build/app/outputs/flutter-apk/` directory

**"gh command not found":**
- Install GitHub CLI: https://cli.github.com/
- Authenticate: `gh auth login`

**WhatsApp doesn't open:**
- Manually copy download URL
- Open WhatsApp and paste message

## Quick Reference

| Task | Command |
|------|---------|
| Bump version | Edit `pubspec.yaml` |
| Release | `.\tools\deploy_release.ps1` |
| View releases | https://github.com/Gruenbaer/FoulAndFortune/releases |
| Delete tag | `git tag -d v3.8.4 && git push origin :refs/tags/v3.8.4` |
