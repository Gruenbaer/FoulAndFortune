# Multi-Game Billiards App - Refactor Plan

**Version**: 2.0 (Condensed)  
**Status**: Approved - Ready to Execute  
**Effort**: 5-7 developer-days

---

## 1. Problem (one sentence)

The current `GameState` (1,186 LOC, 55 methods) mixes infrastructure and game rules, making multi-game support unscalable and error-prone.

---

## 2. Goal (what this refactor MUST achieve)

Enable multiple billiards game types (14.1, 8/9/10-ball, 1-Pocket, Cowboy, Training) without duplicating logic, while keeping 14.1 behavior **100% identical**.

---

## 3. Non-Goals (critical scope protection)

During this refactor, we explicitly do **NOT**:

- ❌ Add new games (except one PoC game: 9-Ball)
- ❌ Change UI/UX
- ❌ Add tournaments, diary, analytics
- ❌ Change database schema beyond `game_type` column
- ❌ Improve performance or visuals
- ❌ "Clean up" unrelated code

**This is architecture only, not a rewrite.**

---

## 4. Core Architectural Decision

Introduce a plugin-based Game Rules system with a stable core engine.

### Key Principle
> **Core decides when things happen. Rules decide what it means.**

---

## 5. Minimal Viable Rules API (do not overdesign)

```dart
abstract class GameRules {
  String get gameId;
  String get displayName;

  RulesState initialState(GameSettings settings);

  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rules,
  );

  WinResult? checkWin(CoreState core, RulesState rules);

  String generateNotation(InningData inning);
}
```

**RuleOutcome** contains only:
- Score delta or inning award
- Turn directive (continue / end / switch / game over)
- Optional table directive (rerack, spot, reset)
- Optional foul classification
- Notation tokens

This API already supports:
- 14.1 reracks + 3-foul rule
- 8-ball groups & calls
- 9/10-ball sequencing
- 1-Pocket scoring
- Cowboy hybrid pot + carom logic

---

## 6. Stable Core State (must not depend on rules)

```dart
class CoreState {
  List<Player> players;
  int activePlayerIndex;
  int inningNumber;
  int turnNumber;
  Set<int> activeBalls;

  GameTimer timer;
  EventLog events;
  UndoHistory history;
}
```

**Rules may read `CoreState` but never mutate it directly.**

---

## 7. File Structure (simplified & final)

```
lib/
├── core/                 # Game-agnostic
│   ├── game_session.dart # Orchestrator (replaces God Object)
│   ├── game_timer.dart
│   ├── game_history.dart
│   ├── event_log.dart
│   └── actions/
│       └── game_action.dart
│
├── games/
│   ├── base/
│   │   ├── game_rules.dart
│   │   ├── rules_state.dart
│   │   └── rule_outcome.dart
│   ├── straight_pool/
│   │   └── straight_pool_rules.dart
│   └── nine_ball/        # PoC game
│       └── nine_ball_rules.dart
```

---

## 8. Implementation Plan (gated, low risk)

### Phase 0 – Alignment (0.5 day)
- Confirm Non-Goals
- Approve Minimal Rules API
- Define "14.1 parity checklist"

**Exit**: Team sign-off

---

### Phase 1 – Extract Infrastructure (1–2 days)
Move without changing behavior:
- Timer
- Undo/redo
- Event logging

**Exit**: All tests pass, UI unchanged

---

### Phase 2 – Rules Seam + 14.1 (2–3 days)
- Introduce `GameSession`
- Move all 14.1 logic into `StraightPoolRules`
- Preserve notation and scoring exactly

**Exit**: 14.1 = identical behavior (10/10 scenarios)

---

### Phase 3 – Proof-of-Concept Game (1–2 days)
- Implement 9-Ball using rules plugin
- Minimal UI reuse

**Exit**: Playable 9-Ball session

---

### Phase 4 – Stabilize (0.5–1 day)
- Document "How to add a game"
- Add rules contract tests

**Exit**: Merge to main

---

## 9. Total Effort (realistic & defensible)

| Item | Time |
|------|------|
| Refactor core + rules | 5–7 days |
| ROI | New games in 1–2 days each |

---

## 10. Risks & Mitigation

| Risk | Mitigation |
|------|------------|
| Hidden UI coupling | UI emits `GameAction` only |
| Undo/redo breakage | Snapshot = Core + RulesState |
| Feature creep | Hard "no new features" rule |

---

## 11. Success Criteria (binary, testable)

- ✅ No file > 500 LOC
- ✅ `GameSession` < 300 LOC
- ✅ 14.1 behavior unchanged (see `REFACTOR_14.1_PARITY.md`)
- ✅ 9-Ball added without touching core
- ✅ All existing tests still pass
- ✅ Adding 10-Ball takes < 2 days (proven by 9-Ball timing)

---

## 12. Bottom Line

This refactor is **not speculative** and **not premature**.

It is the **minimum architectural investment** required to support your stated vision:

> One app for all billiards games, training, tournaments, stats, and journaling.

---

## References

- **Execution Log**: `REFACTOR_EXECUTION_LOG.md` - Current progress
- **Parity Checklist**: `REFACTOR_14.1_PARITY.md` - What must not break
- **Full Spec**: `MULTI_GAME_ARCHITECTURE_PROPOSAL.md` - Detailed analysis
- **Current GameState**: `lib/models/game_state.dart` - What we're refactoring
