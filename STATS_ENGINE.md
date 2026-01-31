# Source of Truth – Statistics Engine

This file defines the canonical statistics system for the app.
It is implementation-oriented: data contracts, calculations, premium gating, and test cases.

---

## 0. Goals

### Product goals
- Provide *player-meaningful* statistics (performance, weaknesses, progress).
- Enable a sellable first paid add-on: **PRO STATS / Player Intelligence**.
- Support multiple billiard disciplines with one framework (rule-agnostic core, rule-specific adapters).

### Technical goals
- Stats are a **read-model over immutable events**.
- Deterministic, testable, offline-capable.
- Backwards compatible: historical games can be re-analyzed when new stats are added.

---

## 1. Architecture Overview

### Event-sourced stats
- The game layer emits `GameEvent`s as the source of truth.
- The stats engine consumes events and produces:
  - `GameStats` (per game)
  - `PlayerStats` (aggregated across games)
  - `Insights` (human-readable findings derived from aggregates)

No UI state, no mutation of game state, no side effects.

```
GameEvents (immutable) -> StatsEngine (pure) -> StatsSnapshot (read-model)
```

---

## 2. Data Model

### 2.1 Identity & scope
- `GameId`, `PlayerId`, `MatchId` are stable UUIDs.
- Stats are computed in two scopes:
  - **Per-Game**: `GameStats`
  - **Per-Player (global / filtered)**: `PlayerStats` over a set of games

### 2.2 Game types (discipline)
The engine is rule-agnostic but needs the discipline label for classification and some adapters.

```dart
enum Discipline {
  straightPool_14_1,
  eightBall,
  nineBall,
  tenBall,
  onePocket,
  bankPool,
  rotation,
  // extensible
}
```

---

## 3. Canonical Event Contract (minimum)

> IMPORTANT: Stats rely on *stable semantics*. If event names change, provide a mapping layer.

### 3.1 Core events (all disciplines)

- `GameStarted(gameId, discipline, players[], startTs)`
- `GameEnded(gameId, endTs, winnerPlayerId?, finalScores{playerId->score})`

- `TurnStarted(gameId, playerId, turnIndex, ts)`
- `TurnEnded(gameId, playerId, turnIndex, ts)`

- `InningStarted(gameId, playerId, inningIndex, ts)`
- `InningEnded(gameId, playerId, inningIndex, ts, pointsDelta, reason)`

- `FoulCommitted(gameId, playerId, ts, foulType, penaltyPointsDelta)`
  - `penaltyPointsDelta` must be signed negative when it affects score.

### 3.2 Shot / ball events (where applicable)

- `BallPocketed(gameId, playerId, ts, ballId, isBreakShot, isBreakBall, isGameBall)`
- `SafetyDeclared(gameId, playerId, ts)` (if your notation supports it)
- `SafetyAttempted(gameId, playerId, ts)` (optional)

### 3.3 Break & rack events
- `BreakShotTaken(gameId, playerId, ts)`
- `RackRebuilt(gameId, ts, reason)`
  - `reason`: e.g. `newRack`, `threeFoulReRack`, `startOfGame`, etc.

### 3.4 Straight Pool specifics (14.1)
- `RunStarted(gameId, playerId, ts, runIndex)`
- `RunEnded(gameId, playerId, ts, runIndex, ballsInRun, pointsInRun, endReason)`
  - If you don't explicitly have run events, the adapter derives runs from innings and pocketed balls.

---

## 4. Stats Engine Output

### 4.1 GameStats (per game)
Must be self-contained and derived only from the game's events.

Recommended fields (subset; extend as needed):

- `durationSeconds`
- `turnCountTotal`
- `inningCountTotal`

Per-player:
- `pointsFor`
- `pointsAgainst` (if meaningful)
- `avgPointsPerInning`
- `zeroInningRate` (% innings with 0 or negative net points)
- `foulsTotal`
- `foulsPerInning`
- `penaltyPointsTotal` (sum of negative deltas from fouls)
- `breakShotsTotal`
- `breakFoulsTotal`
- `breakFoulRate`
- `breakPointsTotal` (points in break innings)
- `peakRun` (if applicable)
- `avgRun` (if applicable)
- `runDistribution` (bins)

### 4.2 PlayerStats (aggregated across games)
Computed by aggregating multiple `GameStats` or directly from events filtered by `playerId`.

Recommended:
- `gamesPlayed`, `gamesWon`, `winRate`
- `avgPointsPerGame`
- `avgPointsPerInning` (weighted)
- `foulsPerGame`
- `foulsPer100Points`
- `penaltyPointsPerGame`
- `breakFoulRate`
- `peakRunAllTime`
- `avgRun` / `medianRun` / `p75Run`
- `progressWindows` (30/90/180 days)

---

## 5. Discipline Adapters

StatsEngine runs with adapters:

- `DisciplineAdapter` converts raw events into normalized "stat primitives":
  - `NormalizedInning`
  - `NormalizedRun`
  - `NormalizedBreak`
  - `NormalizedFoul`

Why:
- 14.1 has runs and racks in a specific sense.
- 8/9/10-ball "runs" mean something else (rack-run / table-run), potentially later.

Adapters MUST be pure and deterministic.

---

## 6. Metric Catalog (what we compute)

### 6.1 Universal metrics (all disciplines)
- Games: `gamesPlayed`, `gamesWon`, `winRate`
- Inning efficiency:
  - `avgPointsPerInning`
  - `zeroInningRate`
- Fouls:
  - `foulsPerGame`
  - `foulsPer100Points`
  - `penaltyPointsTotal`
  - `penaltyPointsPerGame`
- Time:
  - `avgGameDuration`
  - `pointsPerHour` (optional; depends on reliable duration)

### 6.2 Straight Pool (14.1) metrics
Runs:
- `avgRun`
- `medianRun`
- `p75Run`, `p90Run`
- `peakRun`
- `runRateOverThresholds` (>=10, >=20, >=30)
- `runFailureAfterBreakBallRate` (if break-ball tagging exists)

Break:
- `breakShotsTotal`
- `breakFoulsTotal`
- `breakFoulRate`
- `breakInningAvgPoints`

Three-foul / re-rack (if logged):
- `threeFoulCount`
- `threeFoulRatePerGame`
- `pointsLostToThreeFoulPenalty` (sum of penalty deltas in TF innings)

### 6.3 8/9/10-ball future-ready metrics (optional now)
- `breakAndRunRate` (requires rack resolution)
- `dryBreakRate` (requires break outcome events)
- `scratchOnBreakRate`

### 6.4 One Pocket future-ready metrics
- `bankAttempts`, `bankSuccessRate` (requires shot intent)
- `safetySuccessProxy` (derived from opponent zero-innings after safety)

---

## 7. Premium Gating (PRO STATS)

Principle:
- Store all events and compute all stats.
- Restrict **visibility** and **insights** behind entitlement.

### 7.1 Free tier
- Games played, wins/losses, win rate
- Total points, avg points per game
- Peak run (simple)
- Basic fouls total

### 7.2 PRO tier (first paid add-on)
- Full run analytics (avg/median/p75, distributions, thresholds)
- Full foul analytics (per 100 points, penalty totals, breakdown by foulType)
- Break analytics (break foul rate, break efficiency)
- Progress over time windows (30/90/180)
- Head-to-head (vs opponents) if opponent IDs exist
- Insights (see below)

Implementation:
- `StatsSnapshot` contains everything.
- UI renders based on entitlement: `canViewProStats`.

---

## 8. Insights (deterministic coaching-like findings)

Insights are generated from aggregates using explainable rules.

Format:
- `Insight { id, title, severity, evidence, recommendation }`

### 8.1 Example insights (14.1)

**1) Break is safe but unproductive**
- Trigger:
  - `breakFoulRate` low
  - `breakInningAvgPoints` < 30% of `avgPointsPerInning` *and* `avgRunAfterBreak` significantly below `avgRun`
- Recommendation:
  - Work on break-ball selection and first 3 shots pattern.

**2) Fouls drive losses**
- Trigger:
  - `penaltyPointsPerGame` > X
  - Losses correlate with foul spikes
- Recommendation:
  - Reduce risk shots late in racks; practice safeties.

**3) Too many zero innings**
- Trigger:
  - `zeroInningRate` > 40%
- Recommendation:
  - Focus on break-shot setup and conservative openings.

**4) Choking under pressure (optional)**
- Trigger:
  - `performanceInCloseGames` below baseline
- Recommendation:
  - Routine & shot selection in endgame.

Notes:
- Keep thresholds configurable (remote config optional).
- Always include evidence numbers.

---

## 9. Determinism & Testing

### 9.1 Golden tests
- A fixed list of events must yield a fixed `StatsSnapshot`.
- Use snapshot comparisons (JSON) for stable outputs.

### 9.2 Unit tests
- Metric calculators (pure functions)
- Adapter derivations (e.g., deriving runs from inning events)
- Edge cases:
  - aborted games
  - missing end events (should still compute partial)
  - negative innings due to penalties
  - re-rack mid-game

### 9.3 Invariants
- `sum(pointsDelta across innings) + sum(penaltyPointsDelta)` equals final score delta for that player (when rules align).
- `breakFoulsTotal <= breakShotsTotal`
- `0 <= breakFoulRate <= 1`
- Runs: `peakRun >= avgRun >= 0`

---

## 10. Implementation Notes (Dart)

### 10.1 Suggested modules
- `stats/`
  - `stats_engine.dart`
  - `discipline_adapter.dart`
  - `metrics/` (small calculators)
  - `insights/` (rules)
  - `models/` (`GameStats`, `PlayerStats`, `StatsSnapshot`, `Insight`)

### 10.2 Public API
- `StatsEngine.calculateGameStats(events, discipline)`
- `StatsEngine.calculatePlayerStats(gamesStats, filters)`
- `InsightsEngine.generate(playerStats, gameStats?)`

### 10.3 Performance
- Compute on demand with caching:
  - Cache `GameStats` by `gameId` + events hash/version.
  - Recompute only when new events arrive.

---

## 11. Migration Strategy

- Version `StatsSnapshot` schema.
- When adding a new metric:
  - Old snapshots can be recomputed from events.
  - Or fill with null and compute lazily.

---

## 12. Minimal Definition of Done (PRO STATS v1)

Must ship:
- Run analytics for 14.1: avg, median, peak, thresholds
- Foul analytics: per game, per 100 points, penalty totals, breakdown by type
- Break analytics: break shots, break fouls, break foul rate
- Progress windows: 30/90/180 days for avg run & foul rate
- 5 deterministic insights with evidence
- Snapshot-based golden tests for at least 3 sample games
