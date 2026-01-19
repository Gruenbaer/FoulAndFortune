# Phase 1: Extract Infrastructure - Step-by-Step Plan

**Goal**: Move timer, undo/redo, events, and table state out of GameState without changing behavior

**Success Criteria**: All 82 tests pass after EACH step

---

## Step 1.1: Extract GameTimer ✓ READY

### What to Extract
**From `game_state.dart` lines 146-202:**
- `_gameTimer` (Stopwatch)
- `_savedDuration` (Duration)
- `_ticker` (Timer?)
- `_isPaused` (bool)
- `isPaused` getter
- `elapsedDuration` getter
- `startGameTimer()`
- `pauseGame()`
- `resumeGame()`
- `togglePause()`
- `_startTicker()`
- `_stopTicker()`
- `dispose()` override

### New File
`lib/core/game_timer.dart`

### Test After
```bash
puro flutter test
# Must be 82/82 passing
```

### Commit Message
```
refactor(phase1): extract GameTimer from GameState

- Create lib/core/game_timer.dart
- Move timer logic (12 methods/fields)
- GameState now uses GameTimer instance
- Zero behavioral changes
- Tests: 82/82 passing

Step 1 of 4 in Phase 1
```

---

## Step 1.2: Extract GameHistory (Undo/Redo)

### What to Extract
- `_undoStack` (List<GameSnapshot>)
- `_redoStack` (List<GameSnapshot>)
- `canUndo` getter
 `canRedo` getter
- `_pushState()`
- `undo()`
- `redo()`
- `manualPushState()`

### New File
`lib/core/game_history.dart`

---

## Step 1.3: Extract EventManager

### What to Extract
- `eventQueue`  (List<GameEvent>)
- Event classes (FoulEvent, SafeEvent, etc.)

### New Files
- `lib/core/event_manager.dart`
- `lib/core/events/game_event.dart` (base)
- Maybe: separate event files

---

## Step 1.4: Extract TableState

### What to Extract
- `activeBalls` (Set<int>)
- `_resetRack()`
- `_updateRackCount()`

### New File
`lib/core/table_state.dart`

---

## Execution Rules

1. **One step at a time** - Complete extraction, test, commit
2. **Run tests after EVERY step** - Must be 82/82
3. **Commit after EVERY successful step**
4. **If tests fail** - Revert and debug before proceeding
5. **Update execution log** after each commit

---

## Current Status

- [ ] Step 1.1: GameTimer
- [ ] Step 1.2: GameHistory
- [ ] Step 1.3: EventManager
- [ ] Step 1.4: TableState

**Started**: Not yet  
**Current Step**: Ready to start 1.1
