# Foul & Fortune: Straight Pool — Game Rules, Notation & Score Sheet UI (Canonical)

This document defines the complete rules for scoring, notation, and inning flow in 14.1 Fortune, including strict validation/parsing specifications and test vectors.

> [!IMPORTANT]
> **Implementation Status**: This document defines the **target canonical format**. The current implementation (v3.9.3) uses legacy notation (`•`, `|`, `-`). Migration to this canonical format is planned for a future release.

---

## 0. Terminology

**Inning**: One player's turn at the table. Ends on Miss, Safe, or Foul.

**Segment**: Points scored between re-racks within a single inning. An inning can contain multiple segments.

**Re-rack boundary**: The moment the rack is reset to 15 balls while the same inning continues.

**Inverse counting (UI model)**: The UI represents how many balls remain on the table, not ball identities. Points are derived from decreases in that remaining-ball count.

---

## 1. Scoring System

### 1.1 Basic Scoring Calculation

Points are awarded based on the number of balls pocketed.

#### Inverse counting (how "balls pocketed" is computed)

When the user changes the remaining-ball count:

```
BallsPocketed = RemainingPrevious − RemainingNew
```

#### Handicap application

```
SegmentPointsNet = round(BallsPocketedInSegment × HandicapMultiplier)
```

*   **Handicap Multiplier**: configurable per player (default 1.0).
*   **Rounding**: "nearest integer" using the platform's standard rounding. (In Dart, `double.round()` rounds ties away from zero.)

> [!TIP]
> **Implementation recommendation**: Accumulate raw balls pocketed during a segment and apply handicap + rounding once when the segment closes (on re-rack or inning end) to avoid rounding drift.

### 1.2 Special Point Events

#### Re-rack

*   **Trigger**: The game enters a re-rack state (typically when only 1 object ball remains and the app proceeds to a new rack).
*   **Scoring**: Close the current segment and start a new segment at 0.
*   **Turn**: The inning continues.

#### Double Sack (manual)

*   **Trigger**: User triggers the "Double Sack" action (clearing all balls in one go).
*   **Scoring**: Add points equal to the number of balls currently in play (typically 15, but can be less depending on state).
*   **Turn**: The inning continues, and a re-rack occurs (new segment begins at 0).

#### Defensive Pocketing (Safe)

*   **Trigger**: Player declares Safe, regardless of whether balls were pocketed.
*   **Scoring**: Points are awarded for pocketed balls (per the inverse-count model) and the inning ends.
*   **Turn**: Ends immediately.

> [!NOTE]
> This differs from some standard 14.1 interpretations; it is an explicit app rule.

### 1.3 Foul Penalties

Fouls deduct points. A player can have a negative total score.

| Foul Type | Penalty | Effect on Inning | Effect on 3-Foul Streak |
|---|---|---|---|
| **Normal Foul (F)** | **-1** | Ends inning | +1 |
| **Break Foul (BF)** | **-2** | Ends inning | Does not count |
| **Triple Foul (TF)** | **-15 (additional)** | Ends inning | Resets to 0 |

#### 3-Foul Rule

*   **Condition**: If enabled, 3 Normal Fouls in consecutive innings triggers the triple foul penalty.
*   **Penalty**: Additional **-15** is applied when the third consecutive normal foul occurs.
*   **Total impact on 3rd foul inning**: -1 (foul) + -15 (triple) = **-16 total penalty** in that inning.
*   **Reset**: Any inning that ends without a normal foul resets the consecutive normal foul counter to 0.
*   **Break Fouls**: do not increment or reset the normal-foul streak.

### 1.4 Inning Logic (Game Flow)

An inning ends when:

1.  **Miss**: no balls are pocketed and no special end condition is applied → the segment ends with 0.
2.  **Safe**: safe is declared (even if balls were pocketed).
3.  **Foul**: foul occurs (even if balls were pocketed).

**Scoring timeline**:

*   Segment points accumulate across the inning (spanning multiple re-racks).
*   When the inning ends, the inning's net points are applied to the player's total score:
    ```
    sum(segment net points) + foul penalties (if any)
    ```

---

## 2. Notation System (Canonical)

The notation string is a compact, deterministic representation of a single inning.

### 2.1 Canonical Design Rules

1.  **Always write numbers** (no shorthand like `|`).
2.  **`0` is allowed** and must be used explicitly when no balls were potted in a segment.
3.  **Re-rack boundaries are explicit** using a counter-clockwise round arrow.
4.  **No dash notation**: `-` does not exist. Use `0`.

### 2.2 Symbols & Values

| Symbol | Meaning | Notes |
|:---:|:---:|---|
| **`#`** | Segment points (net) | Non-negative integer (0, 5, 14, …). |
| **`⟲`** | Re-rack boundary | Counter-clockwise round arrow (U+27F2). |
| **`S`** | Safe | Safe was declared; inning ended. |
| **`F`** | Normal foul | -1 penalty. |
| **`BF`** | Break foul | -2 penalty. |
| **`TF`** | Triple foul | Triple foul event; additional -15 penalty. |

### 2.3 Core Structure

```
[Segment0] ⟲ [Segment1] ⟲ … ⟲ [SegmentN] [Suffixes]
```

*   Each segment is the points scored between re-racks.
*   The suffixes describe how the inning ended.

### 2.4 Suffix Priority (strict)

Suffixes (if present) must appear at the end in this order:

1.  **`S`** (optional)
2.  **one foul token** (optional): `BF` | `TF` | `F`

Examples:
*   `0S`, `5S`
*   `0F`, `0BF`, `5TF`
*   `14⟲0SF`

### 2.5 Examples

| Scenario | Notation | Explanation |
|---|---|---|
| **Standard miss** | `0` | No points in the inning. |
| **Simple run** | `5` | Scored 5, inning ended. |
| **Cleared rack + miss** | `14⟲0` | Scored 14, re-rack, then 0. |
| **Multi-rack run** | `14⟲14⟲2` | 14, re-rack, 14, re-rack, 2. |
| **Safe with no pots** | `0S` | Safe, no balls potted. |
| **Safe & foul** | `0SF` | Safe + foul (safe suffix precedes foul token). |
| **Break foul** | `0BF` | Break foul, no balls potted. |
| **Score + triple foul** | `5TF` | Scored 5, then 3rd consecutive foul triggered. |

---

## 3. Score Sheet UI

The Score Sheet is used in Match Details and History to present inning-by-inning progression.

### 3.1 Layout

| **POINTS** | **TOTAL** | **INN** | **TOTAL** | **POINTS** |
|:---:|:---:|:---:|:---:|:---:|
| *(P1 Notation)* | *(P1 Score)* | **1** | *(P2 Score)* | *(P2 Notation)* |
| `14⟲14⟲0F` | `27` | **2** | `12` | `12` |

### 3.2 Column Definitions

1.  **POINTS (Left)**: Player 1 inning notation.
2.  **TOTAL (Left)**: Player 1 cumulative score after the inning.
3.  **INN (Center)**: inning number.
4.  **TOTAL (Right)**: Player 2 cumulative score after the inning.
5.  **POINTS (Right)**: Player 2 inning notation.

---

## 4. Validation & Parsing Specification (Strict)

### 4.1 Canonical Grammar (EBNF)

**Terminals**

```ebnf
SEP         = ⟲  (* U+27F2 *)
SAFE        = S
FOUL        = F
BREAK_FOUL  = BF
TRIPLE_FOUL = TF
```

**Lexemes**

```ebnf
INT0       = "0" | ( "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ), 
                   { "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" } ;
FOULSUFFIX = "BF" | "TF" | "F" ;
SUFFIX     = [ "S" ], [ FOULSUFFIX ] ;
```

**Notation**

```ebnf
NOTATION = SEGMENTS, SUFFIX ;
SEGMENTS = INT0, { SEP, INT0 } ;
```

### 4.2 Canonical Regex

**Direct `⟲`:**

```regex
^(?:0|[1-9]\d*)(?:⟲(?:0|[1-9]\d*))*S?(?:BF|TF|F)?$
```

**JavaScript (unicode escape):**

```javascript
/^(?:0|[1-9]\d*)(?:\u27F2(?:0|[1-9]\d*))*S?(?:BF|TF|F)?$/u
```

### 4.3 Deterministic Parsing Contract

**Parsed output:**

```dart
class InningRecord {
  List<int> segments;  // one or more
  bool safe;
  FoulType foul;       // enum { none, F, BF, TF }
}
```

**Parsing steps:**

1.  Peel foul token from end (match longest first): `BF`, then `TF`, then `F`.
2.  Peel `S` if present directly before the foul token (or end).
3.  Split remaining body by `⟲` and parse each segment as int.

**Serializer must produce canonical format:**

*   segments joined by `⟲`
*   then `S` (if any)
*   then foul token (if any)
*   no spaces, no leading zeros (except single `0`)

---

## 5. Unit Test Vectors

### 5.1 Valid cases (must accept)

```json
[
  { "notation": "0", "segments": [0], "safe": false, "foul": "none" },
  { "notation": "5", "segments": [5], "safe": false, "foul": "none" },
  { "notation": "14", "segments": [14], "safe": false, "foul": "none" },
  { "notation": "15", "segments": [15], "safe": false, "foul": "none" },

  { "notation": "0S", "segments": [0], "safe": true, "foul": "none" },
  { "notation": "5S", "segments": [5], "safe": true, "foul": "none" },

  { "notation": "0F", "segments": [0], "safe": false, "foul": "F" },
  { "notation": "0BF", "segments": [0], "safe": false, "foul": "BF" },
  { "notation": "0TF", "segments": [0], "safe": false, "foul": "TF" },

  { "notation": "0SF", "segments": [0], "safe": true, "foul": "F" },
  { "notation": "0SBF", "segments": [0], "safe": true, "foul": "BF" },
  { "notation": "0STF", "segments": [0], "safe": true, "foul": "TF" },

  { "notation": "14⟲0", "segments": [14, 0], "safe": false, "foul": "none" },
  { "notation": "14⟲5", "segments": [14, 5], "safe": false, "foul": "none" },
  { "notation": "14⟲14⟲2", "segments": [14, 14, 2], "safe": false, "foul": "none" },

  { "notation": "14⟲0S", "segments": [14, 0], "safe": true, "foul": "none" },
  { "notation": "14⟲0F", "segments": [14, 0], "safe": false, "foul": "F" },
  { "notation": "14⟲0SF", "segments": [14, 0], "safe": true, "foul": "F" }
]
```

### 5.2 Invalid cases (must reject)

```json
[
  { "notation": "", "reason": "Empty string is invalid." },
  { "notation": "-", "reason": "Dash notation removed; use 0." },

  { "notation": "00", "reason": "Leading zeros not allowed; use 0." },
  { "notation": "01", "reason": "Leading zeros not allowed; use 1." },
  { "notation": "14⟲01", "reason": "Leading zeros in a segment not allowed." },

  { "notation": "14⟲", "reason": "Trailing separator not allowed; write explicit 0 (14⟲0)." },
  { "notation": "⟲0", "reason": "Must start with a numeric segment." },
  { "notation": "0⟲⟲0", "reason": "Empty segment between separators not allowed." },

  { "notation": "SF", "reason": "Suffix-only not allowed; use 0SF." },
  { "notation": "F", "reason": "Suffix-only not allowed; use 0F." },

  { "notation": "0FS", "reason": "Suffix order invalid; S must come before foul (use 0SF)." },
  { "notation": "0SS", "reason": "Duplicate safe suffix not allowed." },

  { "notation": "0FF", "reason": "Only one foul indicator allowed." },
  { "notation": "0X", "reason": "Unknown suffix token." },

  { "notation": "14•0", "reason": "Wrong separator; must use ⟲ (U+27F2)." },
  { "notation": "14⟳0", "reason": "Wrong arrow; must use ⟲ (U+27F2), not ⟳." },

  { "notation": "0SBF⟲0", "reason": "Suffixes must be at the end; no separators after suffix." }
]
```

---

## 6. Property-Based Fuzz Testing Spec

### 6.1 Canonical oracle regex

```regex
^(?:0|[1-9]\d*)(?:⟲(?:0|[1-9]\d*))*S?(?:BF|TF|F)?$
```

### 6.2 Required properties

**P1 — Canonical round-trip**

For any canonical string `s`:
```
serialize(parse(s)) == s
```

**P2 — Canonicalization fixed point**

For any canonical string `s`:
```
canonicalize(s) == s
```

**P3 — Canonicalization output is canonical**

For any input `x` that canonicalizes to `y`:
*   `y` matches canonical regex
*   `serialize(parse(y)) == y`
*   `canonicalize(y) == y` (idempotence)

**P4 — Reversible dirty transforms restore canonical**

Generate canonical `s`, apply reversible dirty transforms to produce `x`, then:
```
canonicalize(x) == s
```

Reversible dirty transforms may include:
*   whitespace insertion/removal
*   separator mapping: `•`, `·` → `⟲`
*   shorthand mapping: `|` → `14` (legacy)
*   leading zeros in segments
*   lowercase suffixes
*   suffix order swap: `FS`→`SF`, `BFS`→`SBF`, `TFS`→`STF`
*   legacy trailing separator normalization (only if your canonicalizer supports it)

---

## 7. Implementation Boundary (Recommended)

> [!TIP]
> To prevent drift between score totals and notation:
>
> 1.  Treat scoring and inning events as **structured data** (e.g., `InningRecord` with `segments`, `safe`, `foul`).
> 2.  Notation is a **pure serialization** of that record:
>     ```dart
>     segments.join('⟲') + (safe ? 'S' : '') + foulToken
>     ```
>
> This ensures: score sheet totals, history storage, and notation display remain consistent across refactors and undo/redo.

---

## 8. Legacy Notation Migration

### 8.1 Canonical Target Format (Reminder)

Canonical notation must match:

```regex
^(?:0|[1-9]\d*)(?:⟲(?:0|[1-9]\d*))*S?(?:BF|TF|F)?$
```

Meaning:
*   At least one numeric segment (`0` or non-zero integer)
*   Additional segments separated by `⟲`
*   Optional suffix: `S` then one of `BF`|`TF`|`F`

### 8.2 Supported Legacy Inputs

The migration supports older stored forms that may include:

*   Legacy "empty inning" dash: `-`
*   Legacy "cleared rack" shorthand: `|`
*   Legacy segment separators:
    *   `•` (bullet)
    *   `·` (middle dot)
*   Legacy "trailing separator implies 0"
    *   e.g., `|•` meaning `14⟲0`
    *   e.g., `10•F` meaning `10⟲0F`
*   Lowercase suffix tokens: `s`, `f`, `bf`, `tf`
*   Wrong suffix order: `FS`, `BFS`, `TFS` (must become `SF`, `SBF`, `STF`)
*   Leading zeros in numbers: `01`, `007`, etc.

> [!WARNING]
> Anything outside this set should be **rejected** (fail migration) rather than guessed.

### 8.3 Migration Rules (Deterministic)

Migration is performed in these steps, **in this order**:

#### Step 1 — Trim whitespace
*   Remove leading/trailing whitespace.
*   Remove all internal whitespace.

Example: `" 14 • 0 F "` → `14•0F`

#### Step 2 — Normalize separators to `⟲`
Replace:
*   `•` → `⟲`
*   `·` → `⟲`

Example: `14•5` → `14⟲5`

#### Step 3 — Replace shorthand rack clear `|` with numeric `14`
Replace every `|` token with `14`.

Example: `|⟲|⟲2` → `14⟲14⟲2`

#### Step 4 — Replace legacy empty inning `-` with `0`
*   If the entire string is exactly `-`, convert to `0`.
*   If `-` appears anywhere else, **reject** (it is not meaningful inside a segment list).

Example:
*   `-` → `0`
*   `14⟲-` → **reject**

#### Step 5 — Normalize suffix casing and tokens
*   Uppercase suffix letters.
*   Foul tokens must be one of `BF`, `TF`, `F` (match longest-first).

Example:
*   `14⟲0sf` → `14⟲0SF`
*   `0bf` → `0BF`

#### Step 6 — Normalize suffix order
If both safe and foul are present, enforce:
*   `S` must appear before the foul token.

Conversions:
*   `FS` → `SF`
*   `BFS` → `SBF`
*   `TFS` → `STF`

Example: `0FS` → `0SF`

#### Step 7 — Expand legacy trailing separator to explicit `0` segment(s)
Legacy notation allowed a trailing separator to mean "entered a new rack but scored 0." Canonical notation requires the `0` to be explicit.

Rule:
*   If the body (segments portion) ends with `⟲`, append `0`.
*   If it ends with multiple `⟲`, append one `0` per trailing separator.

Examples:
*   `14⟲` → `14⟲0`
*   `14⟲⟲` → `14⟲0⟲0`
*   `10⟲F` → `10⟲0F`
*   `14⟲⟲SF` → `14⟲0⟲0SF`

#### Step 8 — Normalize numeric segments (leading zeros)
For each segment:
*   `0` stays `0`
*   Remove leading zeros from non-zero integers:
    *   `01` → `1`
    *   `007` → `7`

**Reject:**
*   Empty segments (`⟲⟲`)
*   Non-numeric segments

#### Step 9 — Validate output against canonical regex
If the final string does not match the canonical regex, migration **fails**.

### 8.4 Migration Examples (Old → Canonical)

| Legacy | Canonical |
|---|---|
| `-` | `0` |
| `5` | `5` |
| `5S` | `5S` |
| `5F` | `5F` |
| `\|` | `14` |
| `\|•` | `14⟲0` |
| `\|•5F` | `14⟲5F` |
| `\|•\|•2` | `14⟲14⟲2` |
| `10•` | `10⟲0` |
| `10•F` | `10⟲0F` |
| `14·0sf` | `14⟲0SF` |
| `14⟲01BFS` | `14⟲1SBF` |

### 8.5 Migration Test Vectors

#### 8.5.1 Must-migrate (input → output)

```json
[
  { "in": "-", "out": "0" },
  { "in": "|", "out": "14" },
  { "in": "|•", "out": "14⟲0" },
  { "in": "|•5F", "out": "14⟲5F" },
  { "in": "|•|•2", "out": "14⟲14⟲2" },
  { "in": "10•", "out": "10⟲0" },
  { "in": "10•F", "out": "10⟲0F" },
  { "in": "14·0sf", "out": "14⟲0SF" },
  { "in": "0fs", "out": "0SF" },
  { "in": "14⟲01BFS", "out": "14⟲1SBF" },
  { "in": " 14 • 14 • 0 ", "out": "14⟲14⟲0" }
]
```

#### 8.5.2 Must-reject (input → reason)

```json
[
  { "in": "", "reason": "Empty string cannot be migrated." },
  { "in": "⟲0", "reason": "Leading separator is ambiguous." },
  { "in": "0⟲⟲0", "reason": "Empty segment between separators is invalid." },
  { "in": "14-0", "reason": "Dash is only allowed as the entire legacy string '-'." },
  { "in": "0SBF⟲0", "reason": "Suffix must be at end; separators after suffix are invalid." },
  { "in": "0XX", "reason": "Unknown suffix token." }
]
```

### 8.6 Implementation Guidance (Recommended)

#### Canonicalize-on-load
When loading saved history:
1.  Attempt to parse as canonical.
2.  If canonical parse fails, run migration.
3.  Store back the canonical form (so migration happens once).

#### Canonicalize-on-save
Always serialize innings using canonical rules; do not emit legacy forms.

#### Don't "guess" missing data
Reject ambiguous cases rather than inventing segments. Examples that should remain rejects:
*   `⟲0` (missing first segment)
*   `0⟲⟲0` (empty segment)
