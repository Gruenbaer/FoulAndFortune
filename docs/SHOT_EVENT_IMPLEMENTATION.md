# Technical Reference: Shot-Level Event Sourcing (v4)

## Overview
This document details the implementation of the Shot-Level Event Sourcing system introduced in version 4.0. It provides a granular, append-only log of every significant game action to enable advanced analytics.

## Architecture

### Data Flow
1.  **User Action**: Player taps a ball, calls a safety, or commits a foul in the UI.
2.  **GameState**: The `GameState` class processes the logic and calls `_emitEvent`.
3.  **ShotEventService**: The service receives the structured event data and persists it to the SQLite database via Drift.
4.  **StatsEngine**: On demand (e.g., in `StatisticsScreen`), the engine reads the event stream and computes aggregate metrics.

### Database Schema
**Table**: `shot_events`
- `id` (TEXT, PK): UUID v4.
- `game_id` (TEXT, FK): References `games.id`.
- `player_id` (TEXT): References `players.id`.
- `turn_index` (INT): 1-based turn number.
- `shot_index` (INT): 0-based, monotonic within a turn.
- `event_type` (TEXT): Enum name from `ShotEventType`.
- `payload` (TEXT): JSON string, versioned (e.g., `{"v":1, "data": {...}}`).
- `ts` (DATETIME): Timestamp of the action.

**Indices**:
- `idx_shot_events_game_ts`: Efficient time-range queries per game.
- `idx_shot_events_game_turn_shot`: Deterministic ordering.
- `idx_shot_events_player_ts`: Player-centric stats queries.

## Event Types & Payloads

### 1. `shot`
Represents a specific action taken by a player.
- **Payload (`kind`)**:
    - `pocket`: Ball potted. Data: `{'ballId': int}`.
    - `safety`: Safety played.
    - `foul`: Foul committed. Data: `{'foulType': string, 'penalty': int}` (Future Implementation).
    - `miss`: Missed shot (implied by turn end without success?).
- **Emission Points**:
    - `GameState.onBallTapped(n)` -> `pocket` (if valid ball).
    - `GameState.onSafe()` -> `safety`.

### 2. `turnStart` / `turnEnd`
Demarcates player control.
- **Payload**: Empty `{}`.
- **Emission Points**:
    - `GameState._switchPlayer()`: Emits `turnEnd` for outgoing player, then `turnStart` for incoming player.
    - **Note**: Handled correctly even during `TrainingMode` or `ThreeFoul` continuations where the *same* player continues (Turn Index increments).

### 3. `rerack`
Represents a physical table reset.
- **Payload**: Empty `{}`.
- **Emission Points**:
    - `GameState.finalizeReRack()`: Triggered after splash screen confirmation.

## Stats Engine Implementation

### `StatsEngine`
Pure Dart class for calculating generic metrics.
- **Input**: `List<ShotEventRow>`
- **Output**: `PlayerAnalytics`
- **Metrics**:
    - `totalShots`, `pockets`, `fouls`, `safeties`, `misses`.
    - `pocketSuccessRate`: `pockets / totalShots`.
    - `averagePace`: Mean time between consecutive events in a turn.

### `StraightPoolStatsAdapter`
Implements `DisciplineStatsAdapter` for 14.1 specific logic.
- **Metrics**:
    - `totalRacks`: Count of `rerack` events.
    - `breakShotSuccessRate`: Percentage of successful shots immediately following a `rerack`.

## Known Limitations & Edge Cases

1.  **Pace Calculation**:
    - The first shot of a game (or after a resume) has no "previous event" to calculate a diff against. It is strictly excluded from the average pace calculation.
2.  **Undo/Redo**:
    - Currently, `ShotEventService` does not have a high-level "undo" method exposed to `GameState`.
    - `GameState.undo()` reverts the in-memory state but does **not yet** emit a compensating `void` event to the database.
    - **Workaround**: Analytics are currently "append-only forward", meaning undone shots might still appear in stats until a comprehensive Undo-Event strategy is implemented (Planned for v4.1).
3.  **Foul Detail**:
    - Detailed foul types (e.g., "scratch", "ball in hand") are currently lumped into generic fouls or implied by `turnEnd`. Explicit `foul` payload support is stubbed but not fully utilized in `GameState` logic yet.

## Testing Strategy
- **Verification Test**: `test/shot_event_verification_test.dart` simulates a full game loop to verify event ordering and type correctness.
- **Unit Logic**: `test/stats_engine_test.dart` verifies the mathematical correctness of the aggregation logic.
