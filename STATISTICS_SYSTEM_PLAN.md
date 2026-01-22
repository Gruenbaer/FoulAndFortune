# Statistics System Plan

This document defines a phased plan for a sophisticated statistics system
with charts, filters, player comparisons, and training separation. It is a
roadmap only. Nothing here is implemented yet.

## Goals
- Keep training data separate from match data, but allow optional inclusion in comparisons.
- Support advanced analytics: filters, charts, head-to-head, and groups.
- Ensure updates never lose data (additive migrations only).
- Make analytics reproducible from raw data, not just cached totals.

## Non-Goals
- No UI redesign for unrelated screens.
- No rule changes to scoring or notation.
- No destructive migrations.
- No server-side analytics yet (local only until sync is built).

## Principles
- Store raw facts once, compute aggregates many times.
- Game context is immutable for the lifetime of a game.
- Training does not unlock achievements.
- Defaults are safe and backward compatible.

## Definitions
Game Context values:
- training: practice, no achievements, excluded by default in stats.
- friendly: normal games (default for existing data).
- league: competitive games with rankings.

## Phases

### Phase 0 - Alignment and Spec
Tasks:
- Finalize game_context values and default behavior.
- Define which metrics require innings vs game-only data.
- Confirm that training is excluded by default and can be toggled on.

Acceptance:
- Spec reviewed and signed off.

### Phase 1 - Schema and Migrations (Update-safe)
Tasks:
- Add games.game_context with default "friendly".
- Add games.game_type (e.g. straight_pool) and rules_version for future-proofing.
- Add innings table for per-inning analytics.
- Update Supabase schema to match Drift.
- Update GameRecord model and GameHistoryService to persist game_context.
- Migrations: additive only, no drops.

Acceptance:
- Drift migration passes.
- Supabase schema updated.
- Existing data loads without changes.

### Phase 2 - Data Capture
Tasks:
- Freeze game_context at game start (no mid-game toggle).
- Persist innings for completed games (bulk upsert by game_id + inning + player).
- Capture per-inning fields: notation, points, foul_type, foul_count, safe, running_total.
- Block achievements for training context.

Acceptance:
- New games produce both game rows and innings rows.
- Training games do not unlock achievements.

### Phase 3 - Aggregation Layer
Tasks:
- Implement StatsAggregateService that queries games + innings.
- Filters: date range, player(s), game_context, game_type, opponent, group.
- Default: exclude training unless user toggles "include training".
- Update Statistics UI to use the aggregator, not cached totals.

Acceptance:
- Totals match existing UI when filters include friendly/league only.
- Toggling training changes totals and charts without data loss.

### Phase 4 - UI Analytics
Tasks:
- Charts: AVG trend, HR distribution, fouls per 100, run length histograms.
- Comparisons: head-to-head, group views, time windows.
- Saved filter presets.

Acceptance:
- Charts render with filters and update quickly.
- Comparisons are accurate and reproducible from raw data.

### Phase 5 - Sync and Performance
Tasks:
- Outbox support for innings table.
- Server indexes for time range and player filters.
- Local cache invalidation strategy.

Acceptance:
- Sync does not duplicate or drop innings.
- Performance stays acceptable on large datasets.

## Migration Notes
- Existing games get game_context = "friendly".
- Old games do not have innings data. Aggregator must handle missing innings
  by using game-level fields only.
- All migrations must be additive.

## Testing Plan
- Migration tests for games.game_context and innings table.
- Aggregation tests for filters and includeTraining toggle.
- Achievement tests to ensure training does not unlock badges.

