import 'player.dart';

// ═══════════════════════════════════════════════════════════════
// CANONICAL SCORING LOGIC - DO NOT MODIFY WITHOUT SPEC UPDATE
// Spec: Foul & Fortune 14.1 One-Page Canonical Spec
// Last verified: 2026-01-06
// ═══════════════════════════════════════════════════════════════

class FoulTracker {
  bool threeFoulRuleEnabled;

  FoulTracker({this.threeFoulRuleEnabled = true});

  /// Returns penalty points: -16 if TF triggered, -1 otherwise.
  ///
  /// CANONICAL STREAK RULE (Foul & Fortune 14.1 Spec):
  /// - Any inning with made balls (ballsPocketed > 0) resets foul streak to 0.
  /// - A foul in such an inning does NOT count toward the 3-foul chain.
  /// - Only PURE fouls (ballsPocketed == 0) increment the streak.
  int applyNormalFoul(Player player, int ballsPocketed) {
    if (!threeFoulRuleEnabled) {
      player.consecutiveFouls = 0;
      return -1;
    }

    // Made balls reset the foul chain completely (canonical rule)
    if (ballsPocketed > 0) {
      player.consecutiveFouls = 1; // Reset previous streak, but count CURRENT foul
      return -1;
    }

    // Pure foul increments the chain
    player.consecutiveFouls++;
    
    if (player.consecutiveFouls >= 3) {
      player.consecutiveFouls = 0; // Reset after TF
      return -16; // TF total: -1 + -15
    }
    
    return -1;
  }

  /// Severe (Break) Foul: -2 points, does NOT count toward 3-foul rule
  int applySevereFoul(Player player) {
    // Break foul: separate category, does not affect 3-foul chain
    return -2;
  }

  void reset() {
    // No internal state to reset.
  }
}
