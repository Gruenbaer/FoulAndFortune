# AGENTS.md

## Purpose
This file is the entrypoint for working on FoulAndFortune. It is also a condensed index of the canonical SOURCE_OF_TRUTH document.

## Canonical Source of Truth
- Read `SOURCE_OF_TRUTH.md` first. It defines architecture, rules, and maintenance requirements.
- Strict API contracts are defined in `SOURCE_OF_TRUTH.md` under `## Strict API Contracts`.
- If this file conflicts with code, update code and `SOURCE_OF_TRUTH.md` together.

## Quick Orientation
- Entry: `lib/main.dart`.
- Core engine: `lib/models/game_state.dart`.
- Foul logic: `lib/models/foul_tracker.dart`.
- Notation: `lib/codecs/notation_codec.dart`.
- Canonical rules: `GAME_RULES.md` + `SCORING_RULES_CHECKLIST.md`.

## Critical Notes
- Spec mismatch: checklist says fouls with balls reset streak to 0, but code/tests expect streak to become 1. Reconcile before changing.
- Migration: notation migration in `GameHistoryService` is currently a stub; old games parse legacy notation on demand.
- Persistence: Drift DB in `lib/data/app_database.dart` with migration from legacy `SharedPreferences` via `PrefsMigrationService`.
- SharedPreferences now only store device id and migration flags.
- Supabase schema for future sync lives in `supabase/schema.sql` (RLS included).
- DB codegen: `puro flutter pub run build_runner build --delete-conflicting-outputs`.
- Tests use in-memory DB when `FLUTTER_TEST` is set (so `flutter test` runs without device storage).
- Conflict artifacts exist (`*_conflict_current.*` and conflict build folders). Treat them as non-authoritative.
- Canonical separator is `\u27F2` (see `lib/codecs/notation_codec.dart`), while docs contain mojibake.
