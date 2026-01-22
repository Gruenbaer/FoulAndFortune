# Project Status and Handoff

Last updated: 2026-01-22 14:42 (local)
Branch: master (tracking origin/master)
Latest commit: run `git log -1 --oneline`

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Training mode (single-player) UI and settings support.
- New game multiplier controls (1x/2x/3x) in setup flow.
- Parity checklist updated and logged PASS for Phase 2.

## Refactor status
- Multi-game refactor Phase 2 is marked complete in `REFACTOR_EXECUTION_LOG.md`.
- Manual parity testing completed; results logged in `REFACTOR_14.1_PARITY.md`.

## Working tree
- Dirty (uncommitted changes in `REFACTOR_14.1_PARITY.md` and `lib/screens/new_game_settings_screen.dart`).

## Tests
- Not run after latest changes. Last: `puro flutter test` (PASS, 2026-01-22 08:59).

## Open tasks / decisions
- Commit pending: new game multiplier selector + parity doc update.

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
