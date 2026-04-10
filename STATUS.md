# Project Status and Handoff

Last updated: 2026-04-10 18:15 (local)
Branch: master (tracking origin/master)
Latest commit: a8c6f4c feat: ship live pool tracking and stronger straight pool validation

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Stabilize the new live-tracked pool match modes
- Keep 14.1 behavior canonical while pool evolves separately
- Next: UI deprecation cleanup (`withOpacity` -> `withValues`) and real device smoke test
- New local data backup/export-import path in global settings absichern and auditieren


## Recent work (2026-04-10)
- **Release v4.5.12**
  - Version bumped to `4.5.12+49`
  - Commit `a8c6f4c` pushed to `origin/master`
  - GitHub release `v4.5.12` published with APK asset
- **Pool Match Center**
  - Pool modes now track live per Aufnahme/Visit instead of a vague late summary
  - Guards for unlogische buttons; grey buttons explain missing prerequisites on long-press
  - Player-switch buttons visually marked, Push Out now resolves via explicit next-shooter dialog
  - Wording aligned to `Rack Win` / `Game Win` / `Set Win` as appropriate
- **14.1**
  - Help/tutorial now explicitly separated from the pool live-tracking model
  - New live-flow scenario tests for notation, persistence, completion, and stats
  - Fixed duplicate empty `0` inning being appended at game end in snapshots/notation
- **Testing**
  - New pool scenario suite and richer widget flow tests
  - Full `puro flutter test` green in local build mirror `C:\temp\FoulAndFortune-build`
- **Data Backup**
  - New full backup/export-import path in global settings
  - Export writes a JSON snapshot for settings, players, games, achievements, shot events, and practice drill history
  - Import restores that snapshot as a full local replace and clears stale sync internals
  - Roundtrip covered by `test/data_backup_service_test.dart`

## Working tree
- Dirty after post-release docs/cleanup and new backup feature work

## Tests
- `puro flutter test` green in local build mirror `C:\temp\FoulAndFortune-build`
- Targeted pool and 14.1 scenario suites green
- `test/data_backup_service_test.dart` green
- Manual device smoke test still pending

## Open tasks / decisions
- Run a real Android device smoke test for `v4.5.12`
- Decide how broad the UI-wide `withOpacity` migration should be
- Continue analyzer cleanup outside the just-touched core files

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
- Release: `.\tools\deploy_release.ps1` or local build mirror on `C:\temp\FoulAndFortune-build` when `Q:` blocks Windows symlink/plugin generation
