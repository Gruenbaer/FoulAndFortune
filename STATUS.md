# Project Status and Handoff

Last updated: 2026-01-22 08:59 (local)
Branch: master (tracking origin/master)
Latest commit: run `git log -1 --oneline`

## Purpose
This file is the single handoff snapshot for current work-in-progress.
Update it at the end of every session.

## Current focus
- Training mode (single-player) UI and settings support.
- Total fouls tracking in game state and stats persistence.
- Break foul dialog timing fix and coverage test.
- Documentation: stats roadmap and dialog testing brief (ASCII).

## Refactor status
- Multi-game refactor Phase 2 is marked complete in `REFACTOR_EXECUTION_LOG.md`.
- Manual parity testing and doc confirmation are still recommended.

## Working tree
- Clean (all changes committed in this snapshot).

## Tests
- `puro flutter test` (PASS, 2026-01-22 08:59). Requires elevated shell due to Puro access restrictions.

## Open tasks / decisions
- None confirmed. Manual parity testing is still recommended per `REFACTOR_EXECUTION_LOG.md`.

## Runbook
- L10n: `puro flutter gen-l10n`
- Build runner: `puro flutter pub run build_runner build --delete-conflicting-outputs`
- Tests: `puro flutter test`
