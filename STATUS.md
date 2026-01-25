# Project Status and Handoff

Last updated: 2026-01-25 14:42 (local)
Branch: master (tracking origin/master)
Latest commit: 5e5838f chore: bump version to v4.3.1+33

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Release v4.3.1 published (APK upload pending manual fix)
- Next: Fix deploy_release.ps1 script to ensure APK uploads correctly

## Recent work (2026-01-25)
- **Bug Fixes:**
  - Removed third consecutive foul splash message (penalty still applied)
  - Fixed player name population from global settings
- **Training Mode UI:**
  - Hide Player 2 column in score sheet when in training mode
  - Single-player stats layout in details screen
- **Release v4.3.1:**
  - Version bumped to 4.3.1+33
  - Release notes updated
  - APK built (85.1MB)
  - GitHub release created (draft published)
  - **TODO**: APK upload to release failed - needs manual upload or script fix

## Working tree
- Clean (all changes committed and pushed)

## Tests
- Code analysis passed with minor lint warnings (fixed)
- Manual testing required for bug fixes and training mode

## Open tasks / decisions
- Upload APK to v4.3.1 release manually or fix deploy_release.ps1
- Test training mode UI changes
- Test bug fixes (third foul, player names)

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
- Release: `.\tools\deploy_release.ps1` (needs APK upload fix)
