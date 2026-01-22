# AGENTS.md

## ⚠️ MULTI-GAME REFACTOR IN PROGRESS
**Current Phase**: Phase 1 Complete  
**Before making changes**: Read `REFACTOR_EXECUTION_LOG.md` to check current status  
**Refactor Plan**: See `REFACTOR_PLAN.md`  
**DO NOT MODIFY** `lib/models/game_state.dart` without coordinating with refactor team

---

## Purpose
This file is the entrypoint for working on FoulAndFortune. It is also a condensed index of the canonical SOURCE_OF_TRUTH document.

## Canonical Source of Truth
- Read `SOURCE_OF_TRUTH.md` first. It defines architecture, rules, and maintenance requirements.
- Current work status and handoff: `STATUS.md` (update each session).
- **NEW**: Multi-game refactor documentation in `REFACTOR_PLAN.md` and `REFACTOR_EXECUTION_LOG.md`
- Strict API contracts are defined in `SOURCE_OF_TRUTH.md` under `## Strict API Contracts`.
- If this file conflicts with code, update code and `SOURCE_OF_TRUTH.md` together.

## Quick Orientation
- Entry: `lib/main.dart`.
- Core engine: `lib/models/game_state.dart` **(being refactored - see REFACTOR_PLAN.md)**.
- Foul logic: `lib/models/foul_tracker.dart`.
- Notation: `lib/codecs/notation_codec.dart`.
- Canonical rules: `GAME_RULES.md` + `SCORING_RULES_CHECKLIST.md`.
- **Refactor docs**: `REFACTOR_PLAN.md`, `REFACTOR_EXECUTION_LOG.md`, `REFACTOR_14.1_PARITY.md`.
- **Stats roadmap**: `STATISTICS_SYSTEM_PLAN.md` (planned, not implemented).
- **Dialog testing brief**: `docs/DIALOG_TESTING_ARCHITECTURE_BRIEF.md` (planned, not implemented).

## Critical Notes
- Migration: notation migration in `GameHistoryService` is currently a stub; old games parse legacy notation on demand.
- Persistence: Drift DB in `lib/data/app_database.dart` with migration from legacy `SharedPreferences` via `PrefsMigrationService`.
- SharedPreferences now only store device id and migration flags.
- Supabase schema for future sync lives in `supabase/schema.sql` (RLS included).
- DB codegen: `puro flutter pub run build_runner build --delete-conflicting-outputs`.
- Tests use in-memory DB when `FLUTTER_TEST` is set (so `flutter test` runs without device storage).
- Conflict artifacts exist (`*_conflict_current.*` and conflict build folders). Treat them as non-authoritative.
- Canonical separator is `\u27F2` (see `lib/codecs/notation_codec.dart`), while docs contain mojibake.

## ⚠️ CRITICAL IMPLEMENTATION RULE
**NO PRAGMATIC APPROACHES. NO SHORTCUTS. EVER.**
- Implement everything correctly and completely
- Do not assume or simplify complex logic
- Extract full implementations, not simplified versions
- If the original code is 159 lines, extract all 159 lines
- Do not cut corners to save time
- When in doubt, ask - do not guess
