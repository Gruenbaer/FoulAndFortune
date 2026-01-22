# FoulAndFortune Source of Truth

This document is the canonical technical reference for the FoulAndFortune project.
It should be read before making changes. If this doc conflicts with code, fix the
code or update this document and any referenced specs together.

## ⚠️ MULTI-GAME REFACTOR IN PROGRESS

**Status**: Phase 1 Complete - All Infrastructure Extracted  
**Plan**: See `REFACTOR_PLAN.md` for condensed execution plan  
**Progress**: See `REFACTOR_EXECUTION_LOG.md` for current status  
**Parity**: See `REFACTOR_14.1_PARITY.md` for what must not change
**Work status**: See `STATUS.md` for the current handoff snapshot

**Completed Extractions (2026-01-20):**
- ✅ Phase 1.1: `lib/core/game_timer.dart` - Timer logic extracted
- ✅ Phase 1.2: `lib/core/game_history.dart` - Undo/redo stack management
- ✅ Phase 1.3: `lib/core/event_manager.dart` + `lib/core/events/game_event.dart` - Event queue
- ✅ Phase 1.4: `lib/core/table_state.dart` - Rack state management

**If you're working on this codebase during the refactor:**
1. Check `REFACTOR_EXECUTION_LOG.md` first for current phase
2. Do NOT make changes that conflict with the refactor plan
3. Coordinate with refactor team before modifying `lib/models/game_state.dart`

## Project Identity
- Product: Foul & Fortune: Straight Pool (evolving to multi-game billiards app)
- Platform: Flutter app (Android, iOS, Windows, macOS, Linux, Web)
- Domain: 14.1 Straight Pool scoring, notation, and stats (expanding to 8/9/10-ball, 1-Pocket, Cowboy, Training)
- Versioning: see `pubspec.yaml`

## Build and Tooling
- Flutter version management: Puro is required. Always use `puro flutter ...`.
- Running on emulator: `puro flutter run` (automatically downloads packages and builds).
- SDK targets: Dart >=3.0.0 <4.0.0 (per `pubspec.yaml`).
- Lints: `analysis_options.yaml` (flutter_lints default).
- DB codegen: `puro flutter pub run build_runner build --delete-conflicting-outputs`.

## Canonical Rules and Scoring
- Canonical spec: `GAME_RULES.md` (FF14 Canonical Notation v1.0).
- Frozen scoring checklist: `SCORING_RULES_CHECKLIST.md` (must follow before changing scoring).
- League-friendly multi-game rules reference: `LEAGUE_RULES_REFERENCE.md` (descriptive; not canonical).
- Notation format: segments joined by U+27F2 (`\u27F2`) + optional suffixes S, F/BF/TF.
- Notation serialization/parsing: `lib/codecs/notation_codec.dart`.
- Core scoring and turn logic: `lib/models/game_state.dart`.
- Foul streak tracking: `lib/models/foul_tracker.dart`.
- Tests: `test/canonical_spec_test.dart`, `test/notation_codec_test.dart`, `test/notation_test.dart`.

### Canonical Foul Streak Behavior (RESOLVED)
- ✅ When fouls occur WITH balls made: streak is set to `1` (resets previous, counts current foul)
- ✅ Only PURE fouls (no balls) increment streak beyond 1
- ✅ Checklist and code now match (updated 2026-01-16)

## Runtime Architecture
### Entry and Providers
- `lib/main.dart` initializes settings, creates `AchievementManager`, and wires providers.
- Providers: `GameSettings`, `AchievementManager`, `Function(GameSettings)` setter.

### Core State
- `GameState` is the authoritative game engine (scoring, rack state, turn logic).
- **Timer**: `lib/core/game_timer.dart` - Extracted timer with pause/resume, elapsed tracking.
- **History**: `lib/core/game_history.dart` - Generic undo/redo using snapshot memento (`GameSnapshot`).
- **Events**: `lib/core/event_manager.dart` - Event queue management; event types in `lib/core/events/game_event.dart`.
- Inning data recorded as `InningRecord` via `NotationCodec`.

### Persistence
- Local database: Drift (SQLite/IndexedDB) via `lib/data/app_database.dart`.
- Settings: `SettingsService` -> `settings` table (single row id `default`).
- Game history: `GameHistoryService` -> `games` table (max 100 recent).
- Player stats: `PlayerService` -> `players` table.
- Achievements: `AchievementManager` -> `achievements` table.
- Sync scaffolding: `sync_outbox` + `sync_state` tables (no remote sync yet).
- Supabase schema (future sync backend): `supabase/schema.sql`.
- Prefs migration: `PrefsMigrationService` imports legacy `SharedPreferences` data on first launch.
- SharedPreferences now only used for device id and migration flags.
- Notation migration: `GameHistoryService.migrateNotation` is currently a stub; existing records rely on lazy parsing.
- Statistics roadmap (planned): `STATISTICS_SYSTEM_PLAN.md` (games context + innings table).
- Dialog testing architecture (planned): `docs/DIALOG_TESTING_ARCHITECTURE_BRIEF.md`.

## Strict API Contracts
This section defines stable behaviors relied upon by UI, tests, and persistence. If you change any contract, update tests and this document.

### GameState (lib/models/game_state.dart)
- Input semantics:
  - `onBallTapped(int remainingCount)` expects remaining ball count (1-15), not a ball id.
  - `onDoubleSack()` represents the cue-ball/double-sack case (remaining count 0).
- State and event guarantees:
  - Public mutation methods call `notifyListeners` and may call `onSaveRequired`.
  - `consumeEvents()` delegates to `EventManager` and returns event list; callers must process events in order.
  - `ReRackEvent` requires the UI to call `finalizeReRack()` after the splash animation to refill the rack.
- Timer management:
  - Uses `GameTimer` instance; delegates `pauseTimer()`, `resumeTimer()`, `resetTimer()` to `_timer`.
  - Snapshot serialization includes `timerElapsedMs` for state restoration.
- History management:
  - Uses `GameHistory<GameSnapshot>` for undo/redo; delegates `canUndo`, `canRedo`, `undo()`, `redo()` to `_history`.
- Turn rules (invariants):
  - Remaining count 1 (re-rack) and 0 (double-sack) continue the turn unless a terminator mode (safe/foul/break foul) is active.
  - Remaining count 2-15 ends the turn.
  - `currentPlayerIndex` is the logical turn; `Player.isActive` is delayed for UI only.
- Foul/safe and break-foul rules:
  - `setFoulMode()` sets the pending foul type for the next action only.
  - `toggleSafeMode()` only toggles the flag; `onSafe()` confirms and ends the inning.
  - `_validateInteraction` rejects re-rack actions when safe or foul is active and enqueues a `WarningEvent`.
  - `canBreakFoul` is true only during break sequence for the breaking player; `handleBreakFoulDecision` either switches players (finalizes inning) or keeps the inning open.

### NotationCodec (lib/codecs/notation_codec.dart)
- `separator` is U+27F2 (`\u27F2`).
- `parseCanonical()` throws `FormatException` on invalid notation.
- `canonicalize()` normalizes legacy separators, suffix order, and numeric segments; `parse()` falls back to legacy parsing.
- `serialize()` requires at least one segment and throws `ArgumentError` otherwise.

### GameHistoryService / GameRecord
- Persistence: `games` table keyed by `id` (string). `saveGame()` upserts by `id`, keeps max 100 non-deleted games.
- `getAllGames()` sorts by `startTime` descending; `getActiveGames()` and `getCompletedGames()` filter by `isCompleted`.
- `snapshot` stores `GameState.toJson()` for in-progress games only; completed games should have `snapshot` null.
- Queries ignore rows where `deletedAt` is set; current deletes remove rows outright.

### SettingsService
- Persistence: `settings` table with a single row id `default`. Invalid or missing data falls back to defaults.

### PlayerService
- Persistence: `players` table keyed by `id` (UUID string).
- Player names must be unique case-insensitively among non-deleted rows.
- This Player model is different from the in-game `Player` in `lib/models/player.dart`.

### AchievementManager
- Persistence: `achievements` table keyed by definition id. `unlock()` persists and triggers `onAchievementUnlocked` if set.

### GameTimer (lib/core/game_timer.dart)
- Manages game duration with pause/resume support.
- Uses `Stopwatch` internally; tracks elapsed time across pause periods.
- `resetStopwatch(Duration elapsed)` restores timer state from snapshots.

### GameHistory (lib/core/game_history.dart)
- Generic undo/redo stack manager (`GameHistory<T>`).
- Supports configurable max size; provides `canUndo`, `canRedo`, `undo()`, `redo()`, `push()`.

### EventManager (lib/core/event_manager.dart)
- Event queue management; event types defined in `lib/core/events/game_event.dart`.
- Events: `FoulEvent`, `SafeEvent`, `ReRackEvent`, `WarningEvent`, `InningChangeEvent`, `VictoryEvent`, `TurnEndEvent`.
- `consumeAll()` returns and clears event queue.

### GameEventOverlay (lib/widgets/game_event_overlay.dart)
- Consumes `GameState` events via `consumeEvents()` and drives overlays.
- `ReRackEvent` triggers `GameState.finalizeReRack()` after the animation finishes.

## UI Structure
### Screens
- `HomeScreen`: main menu, resume latest active game, entry to all screens.
- `NewGameSettingsScreen`: configure new game, players, race, innings.
- `GameScreen`: primary scoring UI, rack interaction, controls, overlays.
- `GameHistoryScreen`: list/filters history, resume or inspect games.
- `DetailsScreen`: match details and score sheet.
- `PlayersScreen`/`PlayerProfileScreen`: player list and profile management.
- `StatisticsScreen`: aggregated player stats.
- `AchievementsGalleryScreen`: achievement gallery and details.
- `SettingsScreen`: global settings and data reset.

### Widgets and UI Systems
- Theme-aware base widgets: `ThemedBackground`, `ThemedButton`, `GameAlertDialog` in `lib/widgets/themed_widgets.dart`.
- Rack and scoring UI: `BallButton`, `PlayerPlaque`, `ScoreCard`, `GameClock`.
- Overlays: `GameEventOverlay` + `lib/widgets/overlays/*` for splashes and dialogs.
- Achievement UI: `AchievementBadge`, `AchievementSplash`.

### Themes and Visual System
- Theme extension: `FortuneColors` in `lib/theme/fortune_theme.dart`.
- Theme implementations: `steampunk_theme.dart`, `ghibli_theme.dart`, `fortune_theme.dart` (cyberpunk theme is defined there).
- Some widgets still use hardcoded colors; refactor plan lives in `COMPONENT_ARCHITECTURE.md`.

### Localization
- ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb`.
- Localization setup: `lib/l10n/app_localizations.dart` and `lib/l10n/l10n.dart`.

## Game Flow Summary
1) Home -> New Game Settings -> GameScreen.
2) GameState initializes rack, players, foul tracking, timer.
3) User taps balls; GameState updates inning points, rack state, and event queue.
4) Overlays consume events (foul, re-rack, safe) and trigger UI feedback.
5) Inning finalization creates notation and updates scores; history saved.
6) Game completion writes record and updates player stats; Victory screen shown.

## Data Models
- `GameSettings`: game configuration and preferences.
- `Player` (models): in-game scoring state and inning tracking.
- `Player` (services): persistent stats model for players list.
- `GameRecord`: persisted history and resume snapshot.
- `Achievement`, `AchievementManager`: definitions and persistence.
- `IssueData`: models for issue tracking (not wired into UI).

## Testing
- Canonical rules tests: `test/canonical_spec_test.dart`.
- Notation parsing/serialization: `test/notation_codec_test.dart`.
- Notation behavior: `test/notation_test.dart`.
- Misc: `test/debugging_turn_logic_test.dart`, `test/widget_test.dart`.

## Assets
- Images and UI: `assets/images`, `assets/images/ui`, `assets/images/balls`.
- Achievements badges: `assets/images/achievements`.
- Sounds: `assets/sounds`.

## Release and Store
- Play Console checklist: `PLAY_CONSOLE_SETUP.md`.
- Privacy policy: `PRIVACY_POLICY.md`.
- Release notes: `RELEASE_NOTES.md`.

## Repo Hygiene and Risks
- Conflict artifacts exist (`*_conflict_current.*` and conflict build folders). Treat as non-authoritative.
- Encoding issues appear in docs and strings (mojibake). Keep separators consistent with `NotationCodec`.

## What To Update Together
- Scoring logic changes must update `GAME_RULES.md`, tests, and `SCORING_RULES_CHECKLIST.md`.
- Notation changes must update `NotationCodec`, tests, and any docs referencing the format.
- Theme or widget refactors should update `COMPONENT_ARCHITECTURE.md` if they change the plan.
- Database schema changes must update `lib/data/app_database.dart`, migrations, `supabase/schema.sql` (if sync schema mirrors local), and regenerate `lib/data/app_database.g.dart`.
