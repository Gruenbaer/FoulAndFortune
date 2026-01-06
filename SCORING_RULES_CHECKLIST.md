# Scoring Rules Code Review Checklist

**⚠ THIS IS FROZEN CANONICAL LOGIC**

All changes to scoring logic MUST go through this checklist before merge.

---

## Pre-Merge Requirements

- [ ] **No changes to `FoulTracker.applyNormalFoul`** without spec update
  - Canonical rule: Points reset streak; only pure fouls increment
  - Verify: `if (ballsPocketed > 0) { player.consecutiveFouls = 0; return -1; }`

- [ ] **No changes to `GameState` turn continuity logic** without spec update
  - Canonical rule: R0/R1 continue, R2-R15 end inning
  - Verify: `if (newBallCount >= 2 && newBallCount <= 15) { turnEnded = true; }`

- [ ] **No changes to TF penalty calculation** without spec update
  - Canonical value: `-16` (not -15)
  - Verify: `FoulEvent(player, -16, FoulType.threeFouls, ...)`

- [ ] **All canonical tests pass**
  - Run: `puro flutter test test/canonical_spec_test.dart`
  - All TV1-TV8 + edge case tests must pass
  - No new test failures in existing test suite

- [ ] **Manual verification of foul scenarios**
  - Test 1: Pot 2 balls, enable foul, tap number → Verify foul streak = 0 (NOT incremented)
  - Test 2: Pure foul × 3 → Verify TF triggers on 3rd
  - Test 3: Tap "10" → Verify turn switches immediately (R2-R15 ends inning)
  - Test 4: Tap "1" → Verify turn continues (R1 re-rack)
  - Test 5: Tap white ball (double-sack) → Verify turn continues (R0)

---

## Documentation Requirements

- [ ] Update `GAME_RULES.md` if scoring behavior changes
- [ ] Update canonical spec version/date if modified
- [ ] Document any NEW edge cases in test suite
- [ ] Update `technical_documentation.md` Section 4.1 if needed

---

## Version Control

- [ ] Commit changes with clear message referencing canonical spec
- [ ] Tag any scoring logic changes with `scoring-change-vX.X.X`
- [ ] Create PR with mandatory review from project owner
- [ ] Run full test suite **before** and **after** merge

---

## Regression Prevention

- [ ] Run `puro flutter analyze` → Zero scoring-related warnings
- [ ] Check for unintended side effects in `GameState._finalizeInning`
- [ ] Verify `NotationCodec` still correctly serializes TF/BF
- [ ] Confirm UI animations reflect correct score deltas

---

## Emergency Rollback Plan

If critical scoring bug is detected in production:

1. **Immediate:** Revert to last tagged stable version (`v4.0.0-canonical-spec`)
2. **Analysis:** Review PR history for scoring-related changes since tag
3. **Fix:** Create hotfix branch from stable tag
4. **Re-verify:** Run full canonical test suite before deploying fix

---

**Last Updated:** 2026-01-06  
**Canonical Spec Version:** 1.0  
**Frozen Logic Files:** `foul_tracker.dart`, `game_state.dart` (lines 320-590, 690-780)
