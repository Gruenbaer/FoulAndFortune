# Scoring & Last Run (LR) Display - Technical Documentation

## Overview

This document explains how the Foul & Fortune 14.1 Straight Pool app handles scoring and displays the Last Run (LR) indicator on player plaques.

---

## Point Awarding Flow

### 1. User Taps a Ball Number

**Entry Point:** User taps a number button (0-15) representing balls remaining on the table.

**Flow:**
```
User Tap → onBallTapped(remainingBalls) → Calculate balls pocketed → Award points
```

### 2. Calculate Balls Pocketed

```dart
int ballsPocketed = 15 - remainingBalls - currentBallCount;
```

**Example:**
- Start: 15 balls on table
- Tap "10": 15 - 10 = **5 balls pocketed**
- Tap "14": 15 - 14 = **1 ball pocketed**

### 3. Update Player Points (Real-Time)

**Method:** `player.addInningPoints(ballsPocketed)`

**What happens:**
1. Adds to `inningPoints` (tracks points in current rack)
2. Updates `currentRun` **immediately** (for live LR display)
3. Updates `highestRun` if current run exceeds it
4. Triggers animation via `updateCount++`

```dart
void addInningPoints(int points) {
  inningPoints += points;
  
  if (points > 0) {
    currentRun += points;  // ← Real-time update for LR
    if (currentRun > highestRun) {
      highestRun = currentRun;
    }
  }
  
  updateCount++;  // Triggers UI rebuild
}
```

### 4. Finalize Inning (Turn End)

**When:** Turn ends (R2-R15 tapped, or Safe/Foul)

**Method:** `_finalizeInning(player)`

**What happens:**
1. Calculates total inning points (including all rack segments + fouls)
2. Adds to player's score
3. Sets `lastRun = currentRun` (persists the run value)
4. Generates notation for score card

**Key:** `currentRun` is NOT updated here anymore (to avoid double-counting).

### 5. Player Switch

**Method:** `_switchPlayer()`

**What happens:**
1. Finalizes old player's inning
2. **Preserves:** `oldPlayer.lastRun = oldPlayer.currentRun`
3. Increments inning (resets `currentRun = 0` for new inning)
4. Switches to new player

---

## Last Run (LR) Display System

### Purpose

The LR box shows the player's **current run** - the cumulative points in their ongoing inning.

### Display Logic

```dart
if (player.isActive) {
  // Active player: show LIVE current run
  runValue = player.currentRun;
} else {
  // Inactive player: show LAST COMPLETED run
  runValue = player.lastRun;
}
```

### Data Flow

#### Active Player (During Turn)

```
Ball tapped → addInningPoints() → currentRun updated → UI rebuilds → LR shows new value
```

**Example:**
- Start of turn: `currentRun = 0` → LR shows `+0`
- Pot 5 balls: `currentRun = 5` → LR shows `+5`
- Pot 3 more: `currentRun = 8` → LR shows `+8`
- Turn ends: `lastRun = 8` saved

#### Inactive Player (After Turn)

```
Player switch → lastRun = currentRun → player.incrementInning() → currentRun = 0
```

**Display:**
- Inactive player's LR shows `lastRun = 8` (persisted)
- Even though `currentRun = 0` (reset for next turn)

### UI Rebuild Trigger

```dart
Provider.of<GameState>(context, listen: true)
```

**Why needed:** Ensures PlayerPlaque rebuilds when `currentRun` changes.

**Flow:**
1. `addInningPoints()` calls `updateCount++`
2. GameState calls `notifyListeners()`
3. Provider triggers rebuild
4. LR displays updated `currentRun`

---

## Key Fields & Their Roles

### Player Class

| Field | Purpose | Updated When | Used For |
|-------|---------|--------------|----------|
| `currentRun` | Current inning run total | Real-time via `addInningPoints()` | LR display (active player) |
| `lastRun` | Last completed run | Player switch via `lastRun = currentRun` | LR display (inactive player) |
| `inningPoints` | Points in current rack segment | Real-time via `addInningPoints()` | Calculation, score card |
| `inningHistory` | Completed rack segments | Re-rack events | Multi-rack innings |
| `score` | Total match score | Finalization via `addScore()` | Main score display |
| `highestRun` | Best run in match | When `currentRun` exceeds it | HR box display |

---

## Common Issues & Solutions

### Issue: LR Shows +0

**Cause:** `currentRun` not updating in real-time.

**Solution:** Ensure `addInningPoints()` updates `currentRun`:
```dart
if (points > 0) {
  currentRun += points;
}
```

### Issue: LR Shows Double Value

**Cause:** `currentRun` updated twice (once in `addInningPoints()`, once in `_finalizeInning()`).

**Solution:** Remove duplicate update from `_finalizeInning()`.

### Issue: LR Doesn't Update UI

**Cause:** PlayerPlaque not listening to GameState changes.

**Solution:** Add Provider listener:
```dart
Provider.of<GameState>(context, listen: true)
```

---

## Critical Methods

### `onBallTapped(remainingBalls)`
- Entry point for ball taps
- Calculates balls pocketed
- Calls `addInningPoints()`
- Handles turn continuation vs end

### `addInningPoints(points)`
- Updates `inningPoints` for score card
- **Updates `currentRun` for live LR display**
- Triggers UI animation via `updateCount++`

### `_finalizeInning(player)`
- Calculates total inning score (points + fouls)
- Adds to player's total score
- Sets `lastRun` for persistence
- Generates score card notation

### `_switchPlayer()`
- Preserves run: `lastRun = currentRun`
- Increments inning (resets `currentRun`)
- Switches active player

---

## Animation & Pulse Effect

The LR box pulses when values change:

```dart
_lastPointsController.forward(from: 0.0);  // Trigger pulse
```

**Scale animation:**
- 1.0 → 5.0 (grow)
- Hold at 5.0
- 5.0 → 1.0 (shrink back)

**Duration:** 900ms total

**Trigger:** `updateCount` changes in Player

---

## Summary

**Points Flow:**
```
User tap → Calculate → addInningPoints() → currentRun++ → UI rebuild → LR updates
```

**Key Principle:**
- **Active player:** LR = `currentRun` (live, changes as points scored)
- **Inactive player:** LR = `lastRun` (frozen, from their last turn)

**Critical:**
- `currentRun` must update in `addInningPoints()` for live display
- NO duplicate updates in `_finalizeInning()`
- Provider listener required for UI rebuilds
