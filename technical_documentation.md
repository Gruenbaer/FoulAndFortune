# Technical Documentation: Foul & Fortune: Straight Pool

This document provides a comprehensive technical overview of the **Foul & Fortune: Straight Pool** application, designed to help developers understand its architecture, core logic, and implementation details.

## 1. Overview
**Foul & Fortune: Straight Pool** is a specialized scoring application for **Straight Pool (14.1 Continuous)** billiards. It features **multiple visual themes** (Cyberpunk, Steampunk, and Ghibli/Whimsy) and handles complex rule enforcement including safe shots, break fouls, the 3-foul rule, and game history tracking.

## 2. Technology Stack
*   **Framework**: [Flutter](https://flutter.dev/) (Dart SDK >=3.0.0 <4.0.0)
*   **Environment Management**: [Puro](https://puro.dev/) is used for Flutter version management.
*   **State Management**: `provider` (ChangeNotifier pattern)
*   **Persistence**: `drift` + `drift_flutter` (SQLite/IndexedDB). `shared_preferences` only for device id and migration flags.
*   **Localization**: `flutter_localizations`, `intl`
*   **Assets**: `flutter_svg` (Vector graphics)
*   **Fonts**: `google_fonts`
*   **Effects**: `confetti` (Victory animations)

## 3. Project Architecture
The project follows a standard scalable Flutter architecture separation concerns between data, logic, and UI.

### Directory Structure (`lib/`)
*   **`main.dart`**: Application entry point. Sets up the `MultiProvider` for dependency injection and initializes the `MaterialApp` with localization and theming.
*   **`models/`**: Data classes and State Notifiers.
    *   `game_state.dart`: **Core Logic**. The primary State Object for the active game.
    *   `game_record.dart`: Data model for long-term storage of match history.
    *   `player.dart`: Model for player statistics and score.
    *   `game_settings.dart`: Configuration model (Race to score, rules).
    *   `achievement_manager.dart`: Handles unlocking achievements based on game events.
*   **`data/`**: Drift database, migration, and sync scaffolding.
    *   `app_database.dart`: Drift schema and database instance.
    *   `db_converters.dart`: JSON/list converters for Drift.
    *   `device_id_service.dart`: Stable device identifier for sync metadata.
    *   `outbox_service.dart`: Local outbox for future cloud sync.
    *   `prefs_migration_service.dart`: Imports legacy `SharedPreferences` data.
*   **`screens/`**: Full-page widgets.
    *   `game_screen.dart`: Main scoring interface.
    *   `home_screen.dart`: Landing page / Menu.
    *   `settings_screen.dart`: Configuration UI.
    *   `details_screen.dart`: Match statistics view.
*   **`services/`**: Data persistence and helper logic.
    *   `game_history_service.dart`: Reads/writes `games` via Drift.
    *   `settings_service.dart`: Persists `GameSettings` in `settings`.
    *   `player_service.dart`: Aggregates player stats in `players`.
*   **`widgets/`**: Reusable UI components.
    *   `steampunk_widgets.dart`: Legacy themed widgets (migrating to `FortuneTheme` system).
    *   `ball_button.dart`: Interactive billiard ball widget.
    *   `victory_splash.dart`: End-of-game overlay.
*   **`l10n/`**: Localization resources (ARB files).

## 4. Core Logic & State Management
The application's heart is the **`GameState`** class (extends `ChangeNotifier`), located in `lib/models/game_state.dart`.

### 4.1 Game Loop & Scoring
*   **Initialization**: `GameState` initializes with two `Player` objects and a full rack (balls 1-15).
*   **Turn Management**: Logic automatically tracks `currentPlayerIndex`.
    *   **Normal Play**: Turn switches after every ball potted (unless "Re-Rack" logic applies).
    *   **Miss/Safe**: Turn ends immediately.
    *   **Fouls**: Penalty applied, turn ends.
*   **Scoring**:
    *   Points are added to the current player.
    *   **Rack Tracking**: `activeBalls` (Set<int>) tracks valid balls remaining on table.
    *   **Re-Rack Logic**: If ball count drops to 1 (active ball + cue ball phantom), logic detects "Re-rack" potential. Tapping the last ball resets the rack to full (15).

### 4.2 Rules Implementation
*   **Foul Handling** (`FoulTracker`):
    *   **Standard Foul**: -1 point.
    *   **Severe Foul (Break Foul)**: -2 points.
    *   **3-Foul Rule**: If enabled, 3 consecutive fouls result in a -15 point penalty.
*   **Analysis & Notation**:
    *   The app generates standardized notation (e.g., `15•|•5F`) for every inning.
    *   **Reference**: See `GAME_RULES.md` for the complete ruleset.
*   **Foul Modes**: Use `FoulMode` enum (none, normal, severe).
*   **Safe Mode**: Defensive shots are tracked separately.

### 4.3 Undo/Redo System
Implemented using the **Memento Pattern**.
*   **`GameSnapshot`**: A robust DTO that serializes the entire state of `GameState` (Players, Scores, Rack, History, Fouls).
*   **Stacks**: `_undoStack` and `_redoStack` store `GameSnapshot` objects.
*   **Action**: Every state-changing action pushes a snapshot before mutating state.

### 4.4 Data Persistence
The app uses a local database via Drift:
1.  **Settings**: `SettingsService` stores a single row in `settings` (id `default`).
2.  **History**: `GameHistoryService` manages `games` (max 100 recent).
3.  **Players**: `PlayerService` stores stats in `players`.
4.  **Achievements**: `AchievementManager` persists `achievements`.
5.  **Migration**: `PrefsMigrationService` imports legacy `SharedPreferences` data once.
6.  **Sync Scaffolding**: `sync_outbox` and `sync_state` tables support future cloud sync.
7.  **Supabase**: Draft cloud schema lives in `supabase/schema.sql`.

## 5. UI/UX Details
The app supports **multiple visual themes** managed through `FortuneTheme`:
*   **Themes**:
    *   **Cyberpunk** (Default): Modern neon aesthetics.
    *   **Steampunk**: Vintage brass and mahogany.
    *   **Whimsy**: Ghibli-inspired aesthetic (New).
*   **Theme System**: `FortuneTheme` and `FortuneColors` provide theme-agnostic access to colors and styles. Refactoring is in progress to fully utilize this system (see `THEMING_REFACTOR_PROGRESS.md`).

## 6. Key Workflows

### Starting a New Game
1.  User enters `HomeScreen`.
2.  Clicks "New Game" -> `NewGameSettingsScreen`.
3.  Selects/Enters Player Names and Race Score.
4.  `Navigator` pushes `GameScreen`.
5.  `GameScreen` creates a **new** `GameState`.

### Resuming a Game
1.  `GameHistoryService` fetches active games.
2.  User selects a game card.
3.  `GameScreen` is pushed with `resumeGame: GameRecord`.
4.  `GameState.loadFromJson` hydrates the state.

## 7. Future Considerations
*   **Cloud Sync**: Process the outbox and wire a backend (Supabase schema in `supabase/schema.sql`).
*   **Schema Migrations**: Add Drift migrations as the DB evolves.
