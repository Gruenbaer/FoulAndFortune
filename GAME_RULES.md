# FF14_Canonical Notation — Logic Specification

## 1. Purpose

The canonical notation encodes one complete inning (turn) of a player in a compact, deterministic string.

It records:
- how many balls were potted,
- how many re-racks occurred,
- and how the inning ended (miss, foul, safe).

---

## 2. Grammar

```
<segment>(⟲<segment>)*[S][F|BF|TF]
```

### Components

| Element | Meaning |
|---------|---------|
| `<segment>` | Integer ≥ 0, points scored between re-racks |
| `⟲` | Re-rack separator (rack reset, inning continues) |
| `S` | Safe (metadata only) |
| `F` | Normal foul (−1) |
| `BF` | Break foul (−2) |
| `TF` | Third foul (−16) |

**Suffix order is always:**
1. `S` → foul marker

**Only one foul marker is allowed.**

---

## 3. Semantic meaning of `15⟲14⟲6F`

### Step-by-step interpretation

This string represents one inning consisting of three segments.

#### Segment breakdown

| Segment | Value | Meaning |
|---------|-------|---------|
| `15` | 15 points | All balls of a rack were potted (Double Sack) |
| `⟲` | re-rack | Table reset to 15 balls, same player continues |
| `14` | 14 points | A full rack was cleared |
| `⟲` | re-rack | Table reset again, same inning |
| `6` | 6 points | 6 balls potted in final rack |

#### Suffix
- `F` → inning ended with a normal foul

---

## 4. Scoring logic

### 4.1 Gross points
```
gross = sum(segments)
gross = 15 + 14 + 6 = 35
```

### 4.2 Penalty
- `F` → −1 point

### 4.3 Net result
```
net = 35 − 1 = 34
```

### 4.4 Run tracking
- `currentRun` increased by 35
- `lastRun = 35`
- `highestRun` updated if applicable

---

## 5. Inning lifecycle rules

### 5.1 What a segment represents

A segment is the number of balls potted since the last re-rack.

**Segments are created when:**
- the inning starts
- a re-rack occurs (0 or 1 tap)

### 5.2 What `⟲` means
- A re-rack occurred
- Remaining balls were reset to 15
- The inning did not end
- The same player continued
- **`⟲` is never a scoring event.**

---

## 6. Foul rules in notation

### Normal Foul (F)
- Ends the inning
- Penalty: −1
- Counts toward 3-foul rule **only if no points were scored in the inning**

### Break Foul (BF)
- Ends the inning
- Penalty: −2
- Does not affect foul streak

### Third Foul (TF)
- Ends the inning
- Penalty: −16
- Represented as `TF` only
- No additional `F` is shown

---

## 7. Safe (S)

- **Metadata only**
- Ends the inning
- Adds no points
- Does not affect foul streak
- May coexist with fouls (`SF`, `SBF`, `STF`)

---

## 8. Validation rules (must be enforced)

✅ At least one segment must exist

✅ Segments must be integers ≥ 0

✅ No leading zeros (except `0`)

✅ Only one foul marker allowed

✅ `TF` may only occur if total points in inning == 0

✅ Suffix order must be `S` then foul

✅ `⟲` may not appear at the start or end without a segment

---

## 9. What this notation is not

❌ It does not represent individual shots

❌ It does not store remaining-ball values

❌ It does not encode player switches explicitly

❌ It does not imply standard BCA scorekeeping

✅ **It is a deterministic accounting record for one inning.**

---

## 10. Examples

| Notation | Meaning | Gross | Penalty | Net |
|----------|---------|-------|---------|-----|
| `5` | Potted 5 balls, missed | 5 | 0 | 5 |
| `15⟲14` | Double sack, then 14 balls | 29 | 0 | 29 |
| `0S` | Safe shot, no balls potted | 0 | 0 | 0 |
| `3F` | 3 balls potted, then fouled | 3 | -1 | 2 |
| `TF` | Third consecutive foul | 0 | -16 | -16 |
| `BF` | Break foul | 0 | -2 | -2 |
| `15⟲15⟲15⟲2F` | Three double sacks, 2 balls, foul | 47 | -1 | 46 |
| `5SF` | 5 balls, safe called, then fouled | 5 | -1 | 4 |

---

**Last Updated:** 2026-01-12  
**Specification Version:** FF14_v1.0  
**Replaces:** Remaining-Count Model (archived)
