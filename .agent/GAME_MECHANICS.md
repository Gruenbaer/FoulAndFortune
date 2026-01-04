# FoulAndFortune: Rules Engine & Logic Documentation

## 1. Core Concept: "Remaining Balls" Input

### The Fundamental Rule
**The user input represents the state of the table AFTER the turn is finished.**

- **Input**: Number of balls left on table (0–15)
- **Math**: `Points Scored = Balls on Table (Start of Turn) - Balls Tapped (End of Turn)`

### Critical Understanding
This is counter-intuitive to standard scoring apps (which usually ask "How many did you make?"). 
**We ask: "How many balls are LEFT?"**

## 2. Global Variables & State

- `currentRackCount`: Integer (2–15). The number of balls currently on the table.
- `foulCount`: Integer (0–2). Tracks consecutive fouls for the current player.
- `isFoul`: Boolean Toggle.
- `isBreakFoul`: Boolean Toggle.
- `isSafe`: Boolean Toggle.

## 3. Valid Inputs & Logic Matrix

### A. The "White Ball" (0) / Double Sack

- **Trigger**: User taps the White Ball (0)
- **Pre-requisite**: `currentRackCount` must be 15 (Full Rack)
- **Validation**: Cannot be combined with `isFoul` or `isSafe`
- **Score**: +15 points (or +14 depending on specific house rules, usually counts as clearing the rack)
- **Rack Action**: Reset `currentRackCount` to 15
- **Player Switch**: **NO** (Player cleared the rack and continues)

### B. The "1" Ball (The Break Ball)

- **Trigger**: User taps "1"
- **Meaning**: Player ran the rack but left the last ball (break ball) to continue the run
- **Validation**: Cannot be combined with `isFoul` (Impossible to foul and leave 1 ball)
- **Score**: `currentRackCount - 1`
- **Rack Action**: Reset `currentRackCount` to 15 (Simulates the re-rack around the break ball)
- **Player Switch**: **NO** (Player continues their run)

### C. Standard Number Taps (2 through 15)

**Trigger**: User taps a number N between 2 and 15

#### Scenario 1: Standard Scoring (Success)
- **Conditions**: `isFoul = OFF`, `isSafe = OFF`
- **Logic**:
  - If `N < currentRackCount`: Points = `currentRackCount - N`
  - If `N == currentRackCount`: Points = 0 (A Miss)
- **Rack Action**: `currentRackCount` becomes N
- **Player Switch**: **YES** (End of inning)

#### Scenario 2: Safety Play
- **Conditions**: `isSafe = ON`
- **Validation**: N MUST equal `currentRackCount` (You cannot pot a ball and call Safe)
  - **Error if** `N < currentRackCount`: "Invalid Safe: Balls were pocketed."
- **Score**: 0 points
- **Stat Recording**: Increment `safeCount` for player
- **Rack Action**: `currentRackCount` remains N
- **Player Switch**: **YES**

#### Scenario 3: Standard Foul
- **Conditions**: `isFoul = ON`
- **Validation**:
  - N cannot be 1 (Impossible state)
  - N cannot be 0
  - N must be ≥ 2
- **Logic**:
  - **Foul Counter Management**:
    - If **balls were pocketed** (N < currentRackCount): Reset `foulCount = 1`
    - If **no balls pocketed** (N == currentRackCount): Increment `foulCount += 1`
  - **Check Third Foul**: If `foulCount` reaches 3 (after increment):
    - **Score**: -16 points (-1 foul, -15 penalty)
    - **Reset**: `foulCount = 0`
    - **Rack**: Full Re-rack (`currentRackCount = 15`)
    - **Switch**: **YES**
  - **Standard Foul**: If `foulCount < 3`:
    - **Score**: -1 point
    - **Rack**: `currentRackCount` remains N
    - **Switch**: **YES**

**Examples**:
- Notation `1F, 1F, 1F`: Each pockets 1 ball + fouls → foulCount resets to 1 each time → NO penalty
- Notation `F, F, F`: Pure fouls (0 balls) → foulCount increments to 3 → -18 total (-1, -1, -16)
- Notation `1F, F, F`: First resets to 1, then increments to 2, then 3 → -16 penalty on third


#### Scenario 4: Break Foul (Opening Shot)
- **Conditions**: `isBreakFoul = ON`
- **Validation**:
  - `currentRackCount` must be 15
  - User MUST tap 15 (No other ball count is valid)
- **Score**: -2 points
- **Rack Action**: Re-rack (`currentRackCount = 15`)
- **Player Switch**: **YES**

## 4. Player Switching Logic (Summary)

### The function `shouldSwitchPlayer()` returns TRUE unless:

1. **Re-Rack Run**: The user tapped "1" (and `isFoul` is OFF)
2. **Perfect Sack**: The user tapped "0/White" (Double Sack)

**In all other cases** (Misses, Safeties, Fouls, or simply ending a turn with balls remaining), **the turn passes to the opponent**.

## 5. Edge Case Validation Errors

Trigger an alert if the user attempts these impossible combinations:

### The "Lone Ranger" Foul
- `isFoul == ON` AND `Input == 1`
- **Reason**: Impossible to leave 1 ball on a foul (ball would spot, or rack would reset)

### The Scoring Safe
- `isSafe == ON` AND `Input < currentRackCount`
- **Reason**: You cannot pocket balls and call a Safe

### The Partial Break Foul
- `isBreakFoul == ON` AND `Input < 15`
- **Reason**: A break foul implies the rack was not legally broken; balls are re-racked to 15

### The Penalized Perfection
- `isFoul == ON` AND `Input == 0` (White)
- **Reason**: You cannot clear the table and foul on the same shot

## Code Implementation Notes

### Key Variables in `onBallTapped`:
- `currentBallCount = activeBalls.length` - balls currently on table (START of turn)
- `newBallCount = ballNumber` - the number the player tapped (balls REMAINING / END of turn)
- `ballsPocketed = currentBallCount - newBallCount` - how many balls were pocketed

### Player Switch Implementation:
```dart
// DETERMINE IF TURN ENDS
bool turnEnded = false;

if (isReRack) {
    // Re-rack (ball 1): Player continues their run
    turnEnded = false;
} else {
    // All other taps: Turn ends and player switches
    turnEnded = true;
}

if (turnEnded) {
    _switchPlayer();
}
```
