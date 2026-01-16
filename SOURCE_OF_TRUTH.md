# FoulAndFortune Source of Truth

This document is the canonical technical reference for the FoulAndFortune project.
It should be read before making changes. If this doc conflicts with code, fix the
code or update this document and any referenced specs together.

## Project Identity
- Product: Foul & Fortune: Straight Pool
- Platform: Flutter app (Android, iOS, Windows, macOS, Linux, Web)
- Domain: 14.1 Straight Pool scoring, notation, and stats
- Versioning: see `pubspec.yaml`

## Build and Tooling
- Flutter version management: Puro is required. Always use `puro flutter ...`.
- Running on emulator: `puro flutter run` (automatically downloads packages and builds).
- SDK targets: Dart >=3.0.0 <4.0.0 (per `pubspec.yaml`).
- Lints: `analysis_options.yaml` (flutter_lints default).

## Canonical Rules and Scoring
- Canonical spec: `GAME_RULES.md` (FF14 Canonical Notation v1.0).
- Frozen scoring checklist: `SCORING_RULES_CHECKLIST.md` (must follow before changing scoring).
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
- `GameState` is the authoritative game engine (scoring, rack state, undo/redo, event queue).
- Undo/redo uses snapshot memento (`GameSnapshot`) with full state serialization.
- Inning data recorded as `InningRecord` via `NotationCodec`.

### Persistence
- Settings: `SettingsService` -> `SharedPreferences` key `game_settings`.
- Game history: `GameHistoryService` -> `SharedPreferences` key `game_history`.
- Player stats: `PlayerService` -> `SharedPreferences` key `players`.
- Achievements: `AchievementManager` -> `SharedPreferences` key `achievements`.
- Notation migration: `GameHistoryService.migrateNotation` is currently a stub; existing records rely on lazy parsing.

## Strict API Contracts
This section defines stable behaviors relied upon by UI, tests, and persistence. If you change any contract, update tests and this document.

### GameState (lib/models/game_state.dart)
- Input semantics:
  - `onBallTapped(int remainingCount)` expects remaining ball count (1-15), not a ball id.
  - `onDoubleSack()` represents the cue-ball/double-sack case (remaining count 0).
- State and event guarantees:
  - Public mutation methods call `notifyListeners` and may call `onSaveRequired`.
  - `consumeEvents()` returns and clears the event queue; callers must process events in order.
  - `ReRackEvent` requires the UI to call `finalizeReRack()` after the splash animation to refill the rack.
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
- Storage key: `game_history`. `saveGame()` upserts by `id`, keeps max 100 games.
- `getAllGames()` sorts by `startTime` descending.
- `snapshot` stores `GameState.toJson()` for in-progress games only; completed games should have `snapshot` null.

### SettingsService
- Storage key: `game_settings`. Invalid or missing data falls back to defaults.

### PlayerService
- Storage key: `players`. Player names must be unique case-insensitively.
- This Player model is different from the in-game `Player` in `lib/models/player.dart`.

### AchievementManager
- Storage key: `achievements`. `unlock()` persists and triggers `onAchievementUnlocked` if set.

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
- Unused deps in `pubspec.yaml`: `drift`, `drift_flutter`, `go_router`, `uuid` (not referenced in `lib/`).
- Encoding issues appear in docs and strings (mojibake). Keep separators consistent with `NotationCodec`.

## What To Update Together
- Scoring logic changes must update `GAME_RULES.md`, tests, and `SCORING_RULES_CHECKLIST.md`.
- Notation changes must update `NotationCodec`, tests, and any docs referencing the format.
- Theme or widget refactors should update `COMPONENT_ARCHITECTURE.md` if they change the plan.
