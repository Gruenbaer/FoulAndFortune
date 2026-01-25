# Project Status and Handoff

Last updated: 2026-01-23 08:27 (local)
Branch: master (tracking origin/master)
Latest commit: bbb5ad3 docs: add release notes for v4.2.5+31

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Training mode persistence in game history + UI indicators.
- Skip player2 stats updates in training mode.
- Regenerate Drift codegen for new games column.

## Refactor status
- Multi-game refactor Phase 2 is marked complete in `REFACTOR_EXECUTION_LOG.md`.
- Manual parity testing completed; results logged in `REFACTOR_14.1_PARITY.md`.

## Working tree
- Dirty: `lib/data/app_database.dart`, `lib/data/prefs_migration_service.dart`,
  `lib/models/game_record.dart`, `lib/screens/details_screen.dart`,
  `lib/screens/game_history_screen.dart`, `lib/screens/game_screen.dart`,
  `lib/screens/home_screen.dart`, `lib/services/game_history_service.dart`,
  `supabase/schema.sql`, `test/db_persistence_test.dart`,
  `test/prefs_migration_test.dart`.

## Tests
- `puro flutter test` (FAIL, 2026-01-23 08:26) - Puro crashed: access denied running
  `git show HEAD:bin/internal/engine.version` (CreateFile failed 5).

## Open tasks / decisions
- Run `puro flutter pub run build_runner build --delete-conflicting-outputs` to
  refresh `lib/data/app_database.g.dart` for `games.isTrainingMode`.
- Re-run `puro flutter test` once Puro access issue is resolved.

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
