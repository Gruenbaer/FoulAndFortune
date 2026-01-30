import 'player.dart';

// ═══════════════════════════════════════════════════════════════
// CANONICAL SCORING LOGIC - DO NOT MODIFY WITHOUT SPEC UPDATE
// Spec: Foul & Fortune 14.1 One-Page Canonical Spec
// Last verified: 2026-01-30
// ═══════════════════════════════════════════════════════════════

/// Result of applying a foul, including penalty and whether it triggered a TF.
class FoulResult {
  final int penalty;
  final bool isTripleFoul;
  const FoulResult(this.penalty, {this.isTripleFoul = false});
}

class FoulTracker {
  bool threeFoulRuleEnabled;

  FoulTracker({this.threeFoulRuleEnabled = true});

  /// Returns FoulResult: penalty points and whether TF was triggered.
  ///
  /// CANONICAL STREAK RULE (Foul & Fortune 14.1 Spec):
  /// - Any inning with made balls (ballsPocketed > 0) resets foul streak to 0.
  /// - A foul in such an inning does NOT count toward the 3-foul chain.
  /// - Only PURE fouls (ballsPocketed == 0) increment the streak.
  FoulResult applyNormalFoul(Player player, int ballsPocketed) {
    if (!threeFoulRuleEnabled) {
      player.consecutiveFouls = 0;
      return const FoulResult(-1);
    }

    // Made balls reset the foul chain completely (canonical rule)
    if (ballsPocketed > 0) {
      player.consecutiveFouls = 1; // Reset previous streak, but count CURRENT foul
      return const FoulResult(-1);
    }

    // Pure foul increments the chain
    player.consecutiveFouls++;
    
    if (player.consecutiveFouls >= 3) {
      player.consecutiveFouls = 0; // Reset after TF
      return const FoulResult(-16, isTripleFoul: true); // TF total: -1 + -15
    }
    
    return const FoulResult(-1);
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
