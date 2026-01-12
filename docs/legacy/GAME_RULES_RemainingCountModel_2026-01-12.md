# Foul & Fortune 14.1 — One-Page Canonical Spec (Remaining-Count Model)

This spec defines a straight-pool scorer using an inverted UI model: there are no object balls, only a remaining-count `Rk` (0–15) recorded per user tap. Scoring is derived from changes in remaining-count plus explicit inning-ending tokens.

---

## 1) Token Definitions

### Remaining tokens
- **`Rk`** where `k ∈ {0..15}`
  - Means: "Remaining count is now k."
  
**Special meanings** (still just remaining-count):
- **`R1`** = re-rack trigger (inning continues; internal remaining resets to 15 immediately after scoring this step)
- **`R0`** = double-sack (inning continues)

### Inning-ending tokens
- **`F`** = foul, inning ends, score −1
- **`TF`** = third consecutive foul, inning ends, score −16 (−1 −15)
- **`S`** = safe, inning ends, score 0
- **`BF`** = break foul, inning ends, score `breakFoulPenalty` (config; commonly −2)

**Notes:**
- `TF` is recorded explicitly (not derived only).
- `BF` is separate from the 3-foul system.

---

## 2) State Model (for the programmer)

Maintain a single authoritative state derived from the token stream:
- **`rem`** (int): current remaining-count for the running inning segment (initially 15 at inning start)
- **`scoreTotal`** (int)
- **`inningSubtotal`** (int) — optional, derived
- **`foulStreak`** (int) — consecutive fouls by the same player, max 2 tracked; `TF` implies the 3rd
- **`isInningActive`** (bool) — whether current player is still at table

All UI taps append tokens. The UI never directly mutates score; it appends a token and the engine reduces tokens into state.

---

## 3) Validation Rules

### 3.1 Allowed next tokens
At any time you may record one of: `Rk`, `F`, `TF`, `S`, `BF`, but with constraints below.

### 3.2 Validity of `Rk`
Let `prev = rem` (current derived remaining before applying this token).

**General constraint:** `k ≤ prev` (remaining cannot increase)

**Exception:** none needed, because re-rack reset is internal (see scoring rule for `R1`).

### 3.3 `TF` validity
`TF` is valid only if `foulStreak == 2` at the start of the inning (i.e., it would be the 3rd consecutive foul for that player).

If `foulStreak != 2`, reject `TF`.

### 3.4 Inning continuity rule (core)
- **`R0` and `R1`** do not end the inning (player continues).
- **`Rk` with `k ∈ {2..15}`** ends the inning (player stops), because the player explicitly chose a non-continuation remaining-count.
- **`F`, `TF`, `S`** always end the inning.
- **`BF`** ends the inning *unless* the same player re-breaks (stacking permitted).

*(Your UI rule matches this exactly: the inning ends when the player taps a number different than white (0) or 1.)*

---

## 4) Derived Scoring Rules

### 4.1 Scoring for `Rk`
Compute `made = prev − k`.

Add `made` to `inningSubtotal` and `scoreTotal`.

Update `rem` as described:

**Case A: `R1` (re-rack trigger)**
- Score `made = prev − 1`
- Then set `rem = 15` immediately (re-rack), inning continues

**Case B: `R0` (double-sack)**
- Score `made = prev − 0`
- Set `rem = 0` (for completeness), inning continues

**Case C: `Rk` where `k ∈ {2..15}`**
- Score `made = prev − k`
- Set `rem = k`
- Inning ends (turn passes)

### 4.2 Scoring for inning-ending tokens
- **`F`**: add −1 to totals; inning ends
- **`TF`**: add −16 to totals; inning ends
- **`S`**: add 0; inning ends
- **`BF`**: add `breakFoulPenalty` (config; recommended default −2); inning ends *unless* re-breaking.
  - If re-breaking, multiple `BF` tokens can exist in one inning (e.g. `14BF2` means 14 points, then 2 break fouls).

---

## 5) Foul-Streak Rules (3-Foul System)

### 5.1 What counts toward foul streak
- **`F`** increments foul streak by 1 (up to 2; third must be `TF`)
- **`TF`** resolves the 3rd foul (apply −16) and then sets `foulStreak = 0` for that player

### 5.2 What resets foul streak to 0
Reset `foulStreak = 0` when **either** occurs in an inning:
1. The player scores any positive points via an `Rk` where `made > 0`, **OR**
2. The player records a legal safety `S`

**Important implication:**
A "foul after making balls" is represented as scoring first (via `Rk`) and then `F`/`BF` ending token; because `made > 0`, the foul streak is reset before the foul is applied, so it cannot be consecutive foul #2/#3.

### 5.3 Break foul interaction
- **`BF`** does not increment the 3-foul streak (separate category).
- **`BF`** does not qualify for `TF`.

---

## 6) Test Vectors (tokens → expected totals)

**Assume:**
- Start of inning: `rem = 15`, `foulStreak = 0`, `subtotal = 0`
- `breakFoulPenalty = −2`

### TV1 — Simple inning, ends by non-continuation number
**Tokens:** `R10`
- `made = 15−10 = 5` → +5
- inning ends

**Expected:** +5

### TV2 — Re-rack continuation then end
**Tokens:** `R1 R12`
- `R1`: `made = 14` → +14, rem resets to 15, continues
- `R12`: `made = 3` → +3, inning ends

**Expected:** +17

### TV3 — Double-sack continuation then end
**Tokens:** `R0 R14`
- `R0`: `made = 15` → +15, continues
- `R14`: `made = 1` → +1, inning ends

**Expected:** +16

### TV4 — Foul only
**Tokens:** `F`

**Expected:** −1, `foulStreak` becomes 1

### TV5 — Three consecutive fouls
**Tokens across three consecutive innings by same player:** `F | F | TF`

**Expected total:** −1 −1 −16 = −18  
After `TF`: `foulStreak` resets to 0

### TV6 — Foul streak resets by scoring
**Tokens:** `F | R13 | F`
- First inning `F`: −1, `foulStreak=1`
- Second inning `R13`: `made = 2` → +2, `foulStreak` resets to 0; inning ends
- Third inning `F`: −1, `foulStreak=1`

**Expected total:** 0 (−1 +2 −1)

### TV7 — Safety resets foul streak
**Tokens:** `F | S | F`

**Expected:** −1 +0 −1 = −2  
Foul streak after `S` is 0

### TV8a — Break fouls are separate (no 3-foul)
**Tokens:** `BF`
**Expected:** -2
No `TF` allowed/triggered.

### TV8b — Stacked Break Fouls (Same Inning)
**Tokens:** `BF BF BF` (Same player re-breaks twice, then switches)
**Expected:** -6 for that inning context.

---

## 7) Reducer Pseudocode

```
DATA STRUCTURES

State:
  int rem                 // current remaining-count for active inning context
  int scoreTotal
  int inningSubtotal
  int foulStreak          // 0..2 (third foul is represented by TF)
  bool inningActive       // true while player continues (R0/R1), false when inning ended

Config:
  int breakFoulPenalty    // e.g. -2

HELPERS

function resetInning(state):
  state.rem = 15
  state.inningSubtotal = 0
  state.inningActive = true
  // foulStreak is NOT reset here (it belongs to the player across innings)

VALIDATION

function validateNext(state, token):
  if token is Rk:
    if k < 0 or k > 15: return false
    if k > state.rem: return false
    return true

  if token == TF:
    return (state.foulStreak == 2)

  // F, S, BF are always allowed
  return true

REDUCER

function applyToken(state, token, config) -> State:
  assert validateNext(state, token)

  if token is Rk:
    k = token.k
    made = state.rem - k
    // scoring from the tap
    state.scoreTotal += made
    state.inningSubtotal += made

    // foul streak reset condition: any positive score in an inning
    if made > 0:
      state.foulStreak = 0

    if k == 1:
      // rerack: inning continues, internal reset to 15
      state.rem = 15
      state.inningActive = true
      return state

    if k == 0:
      // double sack: inning continues
      state.rem = 0
      state.inningActive = true
      return state

    // k in 2..15 ends inning
    state.rem = k
    state.inningActive = false
    return state

  if token == S:
    // safety ends inning; also resets foul streak
    state.foulStreak = 0
    state.inningActive = false
    return state

  if token == F:
    state.scoreTotal -= 1
    // foul increments streak (max 2 tracked; third must be TF)
    state.foulStreak = min(state.foulStreak + 1, 2)
    state.inningActive = false
    return state

  if token == TF:
    // third consecutive foul: -16 total
    state.scoreTotal -= 16
    state.foulStreak = 0
    state.inningActive = false
    return state

  if token == BF:
    // break foul: separate from 3-foul system
    state.scoreTotal += config.breakFoulPenalty   // penalty is negative
    
    // Check if re-breaking (meta-data or context required in real impl)
    // If re-breaking: state.inningActive = true
    // Else: state.inningActive = false
    return state
```

---

## 8) Key Idea

Your entire game logic can be implemented as:
1. Append tokens to a list
2. Replay them through `applyToken` to get the derived state

This makes it extremely testable: your "test vectors" are just token sequences + expected final state.

---

## Appendix A: Score Sheet UI Specifications

*(Preserved from previous documentation)*

The score sheet displays innings in a table format with the following columns:
- **Inning Number** (I1, I2, I3...)
- **Player 1 Score**
- **Player 2 Score**
- **Running Totals**

Notation uses the canonical format:
- Segments joined by `⟲` (U+27F2)
- Optional suffixes: `S`, `F`, `BF`, `TF`
- Examples: `14⟲2`, `5F`, `0S`, `14⟲14⟲0TF`

---

## Appendix B: Legacy Notation Migration

The app supports automatic migration from legacy notation formats:
- Old separators: `•`, `·` → `⟲`
- Shorthand: `|` → `14`
- Empty inning: `-` → `0`

See `NotationCodec.canonicalize()` for implementation details.
