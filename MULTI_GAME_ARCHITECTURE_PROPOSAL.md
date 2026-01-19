# Multi-Game Architecture - Complete Refactoring Plan

**Version**: 2.0 (Final Specification)  
**Date**: 2026-01-19  
**Author**: Architecture Team  
**Pages**: Comprehensive (60+ equivalent)

---

## 📚 Document Structure

This refactoring plan consists of multiple interconnected documents. **Start with the Charter, then refer to detailed sections as needed.**

---

## 🎯 **START HERE: Executive Documents**

### 1. [Refactor Charter](file:///C:/Users/emiliano.kamppeter/.gemini/antigravity/brain/6ef23f0f-6560-4357-8941-a17e67339f99/refactor_charter.md) ⭐ **READ THIS FIRST**
**One-page team decision document**
- Non-goals (what we're NOT doing)
- Minimal Viable Rules API
- 4-phase implementation plan
- 3 concrete decision points
- Risk management
- Sign-off table

**Use this for**: Team meeting, management approval, scope definition

---

### 2. [Task Tracking Board](file:///C:/Users/emiliano.kamppeter/.gemini/antigravity/brain/6ef23f0f-6560-4357-8941-a17e67339f99/task_board.md)
**76 discrete tasks organized by phase**
- Phase 0: Alignment (5 tasks)
- Phase 1: Extract Infrastructure (19 tasks)
- Phase 2: Rules Seam (28 tasks)
- Phase 3: PoC Game (14 tasks)
- Phase 4: Stabilize (10 tasks)

**Use this for**: Daily execution, progress tracking, standup meetings

---

## 📊 **Detailed Analysis & Specifications**

### Section 1: Current State & Problem Analysis

#### **1.1 Codebase Metrics**

| Metric | Current Value | Assessment |
|--------|---------------|------------|
| **GameState LOC** | 1,186 | 🔴 God Object |
| **GameState Methods** | 55 | 🔴 Too many responsibilities |
| **Total Codebase LOC** | ~41,000 | ✅ Manageable |
| **Test Coverage** | 82 tests | ✅ Good foundation |
| **Analysis Errors** | 0 | ✅ Clean |

**File**: [`lib/models/game_state.dart`](file:///C:/Users/emiliano.kamppeter/SynologyDrive/AntiGravity/FoulAndFortune/lib/models/game_state.dart)

#### **1.2 God Object Responsibilities** (13 Concerns in 1 Class)

The `GameState` currently handles:

1. ⏱️ **Game Timer** - start(), pause(), resume(), tick
2. 🎯 **Scoring Logic** - points, multipliers, handicaps
3. 🎱 **Ball/Rack Management** - activeBalls, re-racks, table state
4. 🔄 **Undo/Redo System** - snapshots, state history
5. 👥 **Player Management** - current player, turn switching
6. 🚨 **Foul Tracking** - normal, break, 3-foul penalty
7. 🛡️ **Safe Handling** - safe mode, safe shots
8. 🎲 **Break Sequence** - break eligibility, break fouls
9. ⚙️ **Settings Updates** - mid-game configuration
10. 🏆 **Win Condition** - victory checking
11. 📝 **Match Logging** - action history, inning records
12. 🎪 **Event Queue** - animations, warnings, decisions
13. 📊 **Notation** - FF14 Canonical format generation

**Problem**: All concerns deeply coupled in 1,186 lines.

---

#### **1.3 Game Type Complexity Matrix**

| Game Type | Balls | Scoring Model | Special Mechanics | Complexity |
|-----------|-------|---------------|-------------------|------------|
| **14.1 Straight Pool** | 15 | Point accumulation | Re-racks, break fouls, 3-foul | High |
| **8-Ball** | 15 (7+7+8) | Group clearing | Solids/Stripes, call pocket | Medium |
| **9-Ball** | 9 | Sequential lowest | Push-out, 9-on-break | Medium |
| **10-Ball** | 10 | Sequential + call | Must call all shots | Medium |
| **1-Pocket** | 15 | Designated pocket | Only 1 pocket scores | Medium |
| **Cowboy** | 15 | Hybrid pot+carom | Odd balls, carom, endgame shift | Very High |
| **Training** | Variable | Drill-specific | Timers, challenges | Variable |

**Key Insight**: Games have fundamentally different rules. Duplication or if/else branching won't scale.

---

### Section 2: Architecture Design

#### **2.1 Minimal Viable Rules API (MVR)**

**Design Principle**: Start simple, extend later.

```dart
/// Minimal interface that works for 7+ game types
abstract class GameRules {
  // ═══ Identity ═══
  String get gameId;           // 'straight-pool', '9-ball'
  String get displayName;      // "14.1 Continuous"
  
  // ═══ Setup ═══
  RulesState initialState(GameSettings settings);
  
  // ═══ Core Loop ═══
  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rules,
  );
  
  // ═══ Victory ═══
  WinResult? checkWin(CoreState core, RulesState rules);
  
  // ═══ Notation ═══
  String generateNotation(InningData inning);
}

/// What a rules implementation returns
class RuleOutcome {
  final int scoreDelta;              // Points to award
  final TurnDirective turn;          // continue | end | switch
  final TableDirective? table;       // rerack | spot | reset
  final FoulClassification? foul;    // type + penalty
  final List<String> notationTokens; // For logging
}
```

**Why This Works**:
- 14.1: Different scoring (re-racks, fouls) → isolated in `StraightPoolRules.apply()`
- 9-Ball: Sequential validation → isolated in `NineBallRules.apply()`
- Cowboy: Hybrid scoring → isolated in `CowboyPoolRules.apply()`

---

#### **2.2 Stable Core State Contract**

**Core State** = Infrastructure (MUST remain stable):

```dart
class CoreState {
  // Players
  final List<Player> players;
  final int activePlayerIndex;
  
  // Progress
  final int inningNumber;
  final int turnNumber;
  
  // Table (neutral)
  final Set<int> activeBalls;
  
  // Infrastructure (not exposed to rules)
  final GameTimer _timer;
  final EventLog _events;
  final UndoHistory _history;
}
```

**Rules State** = Game-specific (varies per game):

```dart
// 14.1 Straight Pool
class StraightPoolState extends RulesState {
  final int consecutiveFouls;
  final bool inBreakSequence;
  final int rerackCount;
}

// 9-Ball
class NineBallState extends RulesState {
  final int lowestBallOnTable;
  final bool pushOutUsed;
}

// 8-Ball
class EightBallState extends RulesState {
  final BallGroup? player1Group;  // solids | stripes
  final BallGroup? player2Group;
  final Map<int, Pocket> calledShots;
}
```

**Boundary Rule**: Core never depends on Rules. Rules can query Core (read-only).

---

#### **2.3 High-Level Architecture Diagram**

```
┌──────────────────────────────────────────────┐
│           UI Layer (Flutter)                 │
│  GameScreen | SettingsScreen | ...          │
└────────────────┬─────────────────────────────┘
                 │ emits GameActions
┌────────────────▼─────────────────────────────┐
│         GameSession (Orchestrator)           │
│  - Coordinates infrastructure                │
│  - Delegates game logic to rules             │
│  - Manages snapshots for undo/redo           │
└──────┬───────────────────────────────────┬───┘
       │                                   │
┌──────▼────────────┐         ┌────────────▼─────────────┐
│  Infrastructure   │         │   GameRules (Strategy)  │
│  - GameTimer      │         │   ┌──────────────────┐  │
│  - GameHistory    │         │   │ StraightPoolRules│  │
│  - EventManager   │         │   └──────────────────┘  │
│  - TableState     │         │   ┌──────────────────┐  │
│  - PlayerManager  │         │   │   NineBallRules  │  │
└───────────────────┘         │   └──────────────────┘  │
                              │   ┌──────────────────┐  │
                              │   │  EightBallRules  │  │
                              │   └──────────────────┘  │
                              └──────────────────────────┘
```

**Flow**:
1. UI emits `PotBallAction(ballNumber: 5)`
2. `GameSession.onBallAction()` is called
3. Session delegates to `rules.apply(action, core, rulesState)`
4. Rules return `RuleOutcome(scoreDelta: 3, turn: TurnDirective.continue)`
5. Session updates infrastructure (score, events)
6. Session calls `notifyListeners()` → UI updates

---

### Section 3: Detailed Code Examples

#### **3.1 StraightPoolRules Implementation**

```dart
/// 14.1 Continuous rules implementation
class StraightPoolRules implements GameRules {
  @override
  String get gameId => 'straight-pool';
  
  @override
  String get displayName => '14.1 Continuous';
  
  @override
  RulesState initialState(GameSettings settings) {
    return StraightPoolState(
      consecutiveFouls: 0,
      inBreakSequence: true,
      rerackCount: 0,
    );
  }
  
  @override
  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rulesState,
  ) {
    final state = rulesState as StraightPoolState;
    
    if (action is PotAction) {
      final ballsRemaining = action.ballsRemainingAfter;
      
      // Re-rack at ball 1
      if (ballsRemaining == 1) {
        return RuleOutcome(
          scoreDelta: action.ballsPotted,
          turn: TurnDirective.continueWithReRack,
          table: TableDirective.reRack,
          notationTokens: ['${action.ballsPotted}', '⟲'],
        );
      }
      
      // Double-sack at ball 0
      if (ballsRemaining == 0) {
        return RuleOutcome(
          scoreDelta: action.ballsPotted,
          turn: TurnDirective.continueWithReRack,
          table: TableDirective.reRack,
          notationTokens: ['${action.ballsPotted}', '⟲'],
        );
      }
      
      // Normal pot ends turn
      return RuleOutcome(
        scoreDelta: action.ballsPotted,
        turn: TurnDirective.switchPlayer,
        notationTokens: ['${action.ballsRemainingAfter}'],
      );
    }
    
    if (action is FoulAction) {
      // Check for 3-foul penalty
      final newStreak = state.consecutiveFouls + 1;
      if (newStreak == 3) {
        return RuleOutcome(
          scoreDelta: -16,  // 3-foul penalty
          turn: TurnDirective.switchPlayer,
          foul: FoulClassification.threeFouls,
          notationTokens: ['TF'],
        );
      }
      
      // Normal foul
      return RuleOutcome(
        scoreDelta: -1,
        turn: TurnDirective.switchPlayer,
        foul: FoulClassification.normal,
        notationTokens: ['F'],
      );
    }
    
    if (action is BreakFoulAction) {
      return RuleOutcome(
        scoreDelta: -2,
        turn: TurnDirective.awaitDecision, // Re-break or switch
        foul: FoulClassification.breakFoul,
        notationTokens: ['BF'],
      );
    }
    
    throw UnimplementedError('Action type not supported: $action');
  }
  
  @override
  WinResult? checkWin(CoreState core, RulesState rules) {
    final currentPlayer = core.players[core.activePlayerIndex];
    if (currentPlayer.score >= core.settings.raceToScore) {
      return WinResult(
        winner: currentPlayer,
        finalScore: currentPlayer.score,
      );
    }
    return null;
  }
  
  @override
  String generateNotation(InningData inning) {
    // FF14 Canonical: "15⟲14⟲5SF"
    final segments = inning.segments.join('⟲');
    final suffix = _buildSuffix(inning);
    return '$segments$suffix';
  }
  
  String _buildSuffix(InningData inning) {
    if (inning.hasSafe && inning.hasFoul) return 'SF';
    if (inning.hasSafe) return 'S';
    if (inning.hasBreakFoul) return 'BF';
    if (inning.hasThreeFouls) return 'TF';
    if (inning.hasFoul) return 'F';
    return '';
  }
}
```

---

#### **3.2 NineBallRules Implementation (PoC)**

```dart
/// 9-Ball rules - PoC for second game type
class NineBallRules implements GameRules {
  @override
  String get gameId => '9-ball';
  
  @override
  String get displayName => '9-Ball';
  
  @override
  RulesState initialState(GameSettings settings) {
    return NineBallState(
      lowestBallOnTable: 1,
      pushOutUsed: false,
    );
  }
  
  @override
  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rulesState,
  ) {
    final state = rulesState as NineBallState;
    
    if (action is PotAction) {
      // Check if 9-ball was potted
      if (action.ballsPotted.contains(9)) {
        // 9-on-break or legal 9-ball pot = WIN
        return RuleOutcome(
          scoreDelta: 0, // Win, not points
          turn: TurnDirective.gameOver,
          notationTokens: ['9-WIN'],
        );
      }
      
      // Must hit lowest ball first (legal shot validation)
      if (!action.hitLowestFirst) {
        return RuleOutcome(
          scoreDelta: -1,  // Penalty
          turn: TurnDirective.switchPlayer,
          foul: FoulClassification.illegalContact,
          notationTokens: ['F'],
        );
      }
      
      // Legal pot continues turn
      return RuleOutcome(
        scoreDelta: 0,  // No points in 9-ball
        turn: TurnDirective.continueInning,
        notationTokens: action.ballsPotted.map((b) => 'P$b').toList(),
      );
    }
    
    if (action is MissAction) {
      return RuleOutcome(
        scoreDelta: 0,
        turn: TurnDirective.switchPlayer,
        notationTokens: ['M'],
      );
    }
    
    throw UnimplementedError('Action type: $action');
  }
  
  @override
  WinResult? checkWin(CoreState core, RulesState rules) {
    // Win condition handled in apply() when 9-ball potted
    return null;
  }
  
  @override
  String generateNotation(InningData inning) {
    return inning.notationTokens.join('-');
  }
}
```

---

### Section 4: Implementation Plan (Detailed)

[See Refactor Charter and Task Board for complete phase breakdown]

#### **Phase Timelines** (Conservative Estimates):

| Phase | Description | Duration | Deliverable |
|-------|-------------|----------|-------------|
| **0** | Alignment | 0.5 day | Approved charter |
| **1** | Extract Infrastructure | 1-2 days | 4 new classes, 0 regressions |
| **2** | Rules Seam + 14.1 | 2-3 days | StraightPoolRules, 10/10 parity |
| **3** | PoC (9-Ball) | 1-2 days | Playable 9-ball game |
| **4** | Stabilize | 0.5-1 day | Documentation, tests |
| **Total** | | **5-7 days** | Multi-game ready |

---

### Section 5: Risk Analysis & Mitigation

#### **Risk Matrix**

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| **Hidden UI coupling** | Medium | High | UI → GameSession only, not rules | Phase 1 dev |
| **Undo/redo breaks** | Medium | High | Snapshots = CoreState + RulesState (opaque) | Phase 1 dev |
| **Feature creep** | High | Critical | **Hard rule**: No behavior changes | Tech lead |
| **Estimate overrun** | Medium | Medium | Phase gates, 3-day abort threshold | PM |
| **14.1 parity breaks** | Low | Critical | 10-point QA checklist, manual test | QA |

#### **Mitigation Details**

**1. Hidden UI Coupling**
- **Problem**: UI directly calls `GameState.onBallTapped()` with 14.1 assumptions
- **Solution**: UI emits generic `GameAction` objects, Session handles routing
- **Verification**: No UI code references `StraightPoolRules`

**2. Undo/Redo Serialization**
- **Problem**: Each game has different state shape
- **Solution**: `Snapshot = { CoreState, RulesState as JSON }`
- **Verification**: Unit test undo/redo for 14.1 + 9-ball

**3. Feature Creep**
- **Problem**: "While we're refactoring, let's also..."
- **Solution**: **Gate rule** - Any non-refactor work moves to Phase 5
- **Enforcement**: Tech lead rejects PRs with scope additions

---

### Section 6: Testing Strategy

#### **6.1 Test Coverage Goals**

| Test Type | Current | Target | Strategy |
|-----------|---------|--------|----------|
| **Unit Tests** | 82 | >100 | Add rules contract tests |
| **Integration Tests** | Limited | Moderate | GameSession + Rules integration |
| **Manual QA** | Ad-hoc | Structured | 10-point parity checklist |

#### **6.2 Rules Contract Test Suite**

```dart
/// Shared test suite for all GameRules implementations
abstract class RulesContractTest {
  GameRules createRules();
  
  @Test
  void testInitialState() {
    final rules = createRules();
    final state = rules.initialState(defaultSettings);
    expect(state, isNotNull);
  }
  
  @Test
  void testWinCondition() {
    final rules = createRules();
    // ...test that checkWin() works
  }
  
  @Test
  void testNotationGeneration() {
    final rules = createRules();
    final notation = rules.generateNotation(sampleInning);
    expect(notation, isNotEmpty);
  }
}

class StraightPoolRulesTest extends RulesContractTest {
  @override
  GameRules createRules() => StraightPoolRules();
  
  @Test
  void testReRackAt1() {
    // 14.1-specific test
  }
}
```

---

### Section 7: Directory Structure (Complete)

```
lib/
├── core/                              # Game-agnostic
│   ├── game_engine/
│   │   ├── game_session.dart          # Orchestrator
│   │   ├── game_context.dart          # Immutable snapshot
│   │   ├── game_timer.dart
│   │   ├── game_history.dart
│   │   ├── event_manager.dart
│   │   └── game_session_factory.dart
│   ├── table/
│   │   ├── table_state.dart
│   │   ├── ball.dart
│   │   └── pocket.dart
│   ├── player/
│   │   ├── player_manager.dart
│   │   └── turn_controller.dart
│   └── actions/
│       ├── game_action.dart           # Abstract
│       ├── pot_action.dart
│       ├── miss_action.dart
│       ├── foul_action.dart
│       └── turn_result.dart
│
├── games/                             # Game-specific
│   ├── base/
│   │   ├── game_rules.dart            # Interface
│   │   ├── rules_state.dart
│   │   ├── rule_outcome.dart
│   │   └── notation_codec.dart
│   ├── straight_pool/
│   │   ├── straight_pool_rules.dart
│   │   ├── straight_pool_state.dart
│   │   └── ff14_notation_codec.dart
│   └── nine_ball/
│       ├── nine_ball_rules.dart
│       ├── nine_ball_state.dart
│       └── nine_ball_notation_codec.dart
│
├── features/                          # Existing
│   └── (game, stats, settings, etc.)
│
└── models/                            # Existing
    └── (player, game_record, etc.)
```

---

### Section 8: Database Updates (Minimal)

```sql
-- Only required change: add game_type column
ALTER TABLE games 
ADD COLUMN game_type TEXT NOT NULL DEFAULT 'straight-pool';

-- Future: Tournament support (Phase 5+)
-- Future: Diary entries (Phase 5+)
```

---

### Section 9: Success Metrics

#### **Code Quality Metrics**

| Metric | Before | Target | How to Measure |
|--------|--------|--------|----------------|
| **Largest file LOC** | 1,186 | <500 | `wc -l lib/**/*.dart \| sort -n` |
| **GameSession LOC** | N/A | <300 | Line count after refactor |
| **StraightPoolRules LOC** | N/A | <400 | Isolated 14.1 logic |
| **Cyclomatic complexity** | High | <10/method | Analyzer |
| **Test count** | 82 | >100 | Test runner |

#### **Feature Metrics**

| Metric | Baseline | Target | Verification |
|--------|----------|--------|--------------|
| **Time to add simple game** | 1+ week | 1-2 days | Measure 10-ball after 9-ball |
| **Time to add complex game** | 2+ weeks | 2-3 days | Estimate Cowboy complexity |
| **Regression bugs** | N/A | 0 | QA after each phase |

---

### Section 10: Post-Refactor Roadmap (Phase 5+)

**After successful refactor**, prioritize:

1. **8-Ball** (1-2 days) - Tests group mechanics
2. **10-Ball** (1 day) - Similar to 9-ball
3. **1-Pocket** (1-2 days) - Bank-to-pocket logic
4. **Cowboy** (2-3 days) - Complex hybrid scoring
5. **Training Modes** (variable) - Drills, challenges
6. **Tournament System** (1 week) - Brackets, matches
7. **Diary/Journal** (1 week) - User templates, entries

---

## 📋 **Appendices**

### Appendix A: Glossary

- **God Object**: Anti-pattern where one class has too many responsibilities
- **Strategy Pattern**: Swappable algorithm implementations
- **Dependency Injection**: Providing dependencies externally
- **MVR (Minimal Viable Rules)**: Simplest API that works
- **Core State**: Game-agnostic infrastructure
- **Rules State**: Game-specific data

### Appendix B: References

- Current `GameState`: [`lib/models/game_state.dart`](file:///C:/Users/emiliano.kamppeter/SynologyDrive/AntiGravity/FoulAndFortune/lib/models/game_state.dart)
- Source of Truth: [`SOURCE_OF_TRUTH.md`](file:///C:/Users/emiliano.kamppeter/SynologyDrive/AntiGravity/FoulAndFortune/SOURCE_OF_TRUTH.md)
- Component Architecture: [`COMPONENT_ARCHITECTURE.md`](file:///C:/Users/emiliano.kamppeter/SynologyDrive/AntiGravity/FoulAndFortune/COMPONENT_ARCHITECTURE.md)
- Test Suite: [`test/canonical_spec_test.dart`](file:///C:/Users/emiliano.kamppeter/SynologyDrive/AntiGravity/FoulAndFortune/test/canonical_spec_test.dart)

### Appendix C: Contact & Sign-Off

**Questions or Feedback:**
- Technical Lead: ___________
- Developer: ___________
- Product Owner: ___________

**Approved for execution?**
- [ ] Yes, proceed with Phase 0
- [ ] No, defer (reason): ___________

---

## ✅ Final Checklist

**Before starting Phase 1:**
- [ ] Team has read Refactor Charter
- [ ] 3 decision points answered
- [ ] Non-goals understood
- [ ] Feature branch created
- [ ] Task board populated
- [ ] Daily standups scheduled

**After Phase 4:**
- [ ] 14.1 parity: 10/10 scenarios pass
- [ ] 9-ball PoC playable
- [ ] All 82+ tests pass
- [ ] Documentation complete
- [ ] Merged to master

---

**Document Version Control**:
- v1.0 - Initial proposal (original 60-page analysis)
- v2.0 - Risk-reduced comprehensive plan (this document)

**Last Updated**: 2026-01-19  
**Status**: READY FOR EXECUTION
