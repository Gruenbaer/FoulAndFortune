# 14.1 Straight Pool - Parity Checklist

**Purpose**: These 10 behaviors MUST remain 100% identical after refactoring.

**How to use**: After each phase, manually test all 10 scenarios. All must pass before proceeding.

---

## Critical Behaviors (Cannot Change)

### 1. Re-rack at Ball 1
**Test**: Pot balls until only 1 ball remains on table  
**Expected**: 
- Auto re-rack to 15 balls
- Inning continues (same player)
- Notation shows `⟲` symbol
- Points awarded before re-rack

**How to verify**: Play until 14 balls potted, check re-rack triggers

---

### 2. Double-Sack (Ball 0)
**Test**: Clear entire table (pot all 15 balls in one inning)  
**Expected**:
- All 15 balls counted as points
- Auto re-rack to 15 balls
- Inning continues (same player)
- Notation shows all segments

**How to verify**: Use test mode to pot 15 balls, verify re-rack

---

### 3. Normal Foul Penalty
**Test**: Commit a standard foul (scratch, wrong ball, etc.)  
**Expected**:
- Player loses exactly **-1 point**
- Turn switches to opponent
- Notation shows `F` suffix
- Consecutive foul counter increments

**How to verify**: Tap "Foul" button, check score delta

---

### 4. Break Foul Penalty
**Test**: Commit a foul during break sequence  
**Expected**:
- Player loses exactly **-2 points**
- Decision dialog appears (re-break or switch)
- Notation shows `BF` suffix
- Can stack multiple break fouls before switching

**How to verify**: Start game, tap "Break Foul", verify penalty and dialog

---

### 5. Three Consecutive Fouls Penalty
**Test**: Commit 3 fouls in a row without potting a ball  
**Expected**:
- Player loses exactly **-16 points** on 3rd foul
- Turn switches to opponent
- Notation shows `TF` suffix
- Foul counter resets to 0

**How to verify**: Tap "Foul" 3 times in a row, check -16 penalty

---

### 6. Turn Ends on Pot 2-15 Balls
**Test**: Pot any number of balls between 2-15  
**Expected**:
- Points awarded correctly
- Turn switches to opponent
- Notation shows final ball count
- No re-rack

**How to verify**: Pot 5 balls leaving 10, verify turn switches

---

### 7. Turn Continues on Re-rack or Double-Sack
**Test**: Trigger re-rack (ball 1) or double-sack (ball 0)  
**Expected**:
- Same player continues
- Active player indicator unchanged
- Inning number unchanged
- Can keep playing immediately

**How to verify**: Re-rack and verify same player is still active

---

### 8. FF14 Canonical Notation Format
**Test**: Play a full inning with re-rack, safe, and foul  
**Expected**:
- Format: `15⟲14⟲5SF` (segments⟲inning-end-notation)
- Re-rack symbol: `⟲`
- Suffixes: `S` (safe), `F` (foul), `SF` (both), `BF` (break foul), `TF` (3-foul)

**How to verify**: Check game history notation matches canonical format

---

### 9. Undo/Redo Restores Exact State
**Test**: Play 3 actions, undo 2, redo 1  
**Expected**:
- Scores match exactly
- Ball rack state identical
- Inning numbers correct
- Turn order preserved
- Notation reverted/reapplied

**How to verify**: Record state, undo, verify restore, redo, verify re-application

---

### 10. Handicap Multipliers Apply Per Segment
**Test**: Set Player 1 handicap to 1.5x, pot 10 balls in re-rack inning  
**Expected**:
- First segment: 14 × 1.5 = 21 points
- Second segment (after re-rack): 10 × 1.5 = 15 points
- Total inning: 36 points
- Each segment multiplied independently

**How to verify**: Set handicap in settings, play re-rack inning, check score calculation

---

## Testing Protocol

### Before Starting Any Phase
1. Run all 82 automated tests: `puro flutter test`
2. Manually verify all 10 scenarios above
3. Record baseline behavior (screenshots if needed)

### After Completing Each Phase
1. Run all automated tests (must still be 82/82 passing)
2. Manually verify all 10 scenarios again
3. Compare to baseline - **must be identical**
4. Document any discrepancies immediately

### If Parity Breaks
1. **STOP** - Do not proceed to next phase
2. Identify which scenario failed
3. Debug and fix before continuing
4. Re-run full parity checklist
5. Only proceed when 10/10 pass

---

## Quick Parity Test (5 minutes)

**When short on time, test these 3 critical scenarios:**

1. **Re-rack**: Pot 14 balls → verify re-rack → verify inning continues
2. **3-Foul**: Tap foul 3 times → verify -16 penalty
3. **Undo/Redo**: Play 3 actions → undo all → redo all → verify identical state

If these 3 pass, full parity is likely intact. Still run full checklist before phase completion.

---

## Passing Criteria

**Phase 1 Exit Gate**: 10/10 scenarios pass  
**Phase 2 Exit Gate**: 10/10 scenarios pass  
**Phase 3 Exit Gate**: 10/10 scenarios pass (14.1 unchanged, 9-ball also works)  
**Phase 4 Exit Gate**: 10/10 scenarios pass

**Zero tolerance** for parity breaks. 14.1 behavior is frozen.
