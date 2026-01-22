# Project Status and Handoff

Last updated: 2026-01-22 15:01 (local)
Branch: master (tracking origin/master)
Latest commit: run `git log -1 --oneline`

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Training mode (single-player) UI and settings support.
- Total fouls tracking in game state and stats persistence.
- Documentation: stats roadmap and dialog testing brief (ASCII).

## Refactor status
- Multi-game refactor Phase 2 is marked complete in `REFACTOR_EXECUTION_LOG.md`.
- Manual parity testing completed; results logged in `REFACTOR_14.1_PARITY.md`.

## Working tree
- Clean.

## Tests
- `puro flutter test` (PASS, 2026-01-22 14:59). Requires elevated shell due to Puro access restrictions.

## Open tasks / decisions
- Confirm new multiplier selector appears in new game setup (manual smoke check).

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
