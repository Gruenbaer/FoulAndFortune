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
    final evaluation = _evaluateNormalFoul(
      consecutiveFouls: player.consecutiveFouls,
      ballsPocketed: ballsPocketed,
    );

    player.consecutiveFouls = evaluation.nextConsecutiveFouls;
    return evaluation.result;
  }

  /// Predicts the normal foul result WITHOUT mutating player state.
  /// Use this for event/overlay preview paths so scoring logic stays centralized.
  FoulResult previewNormalFoul(Player player, int ballsPocketed) {
    return _evaluateNormalFoul(
      consecutiveFouls: player.consecutiveFouls,
      ballsPocketed: ballsPocketed,
    ).result;
  }

  ({FoulResult result, int nextConsecutiveFouls}) _evaluateNormalFoul({
    required int consecutiveFouls,
    required int ballsPocketed,
  }) {
    if (!threeFoulRuleEnabled) {
      return (result: const FoulResult(-1), nextConsecutiveFouls: 0);
    }

    // Made balls reset the previous chain, but this inning's foul still counts.
    if (ballsPocketed > 0) {
      return (result: const FoulResult(-1), nextConsecutiveFouls: 1);
    }

    final nextStreak = consecutiveFouls + 1;
    if (nextStreak >= 3) {
      return (
        result: const FoulResult(-16, isTripleFoul: true),
        nextConsecutiveFouls: 0,
      );
    }

    return (result: const FoulResult(-1), nextConsecutiveFouls: nextStreak);
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
