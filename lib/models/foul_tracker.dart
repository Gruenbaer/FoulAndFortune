import 'player.dart';

class FoulTracker {
  bool threeFoulRuleEnabled;

  FoulTracker({this.threeFoulRuleEnabled = true});

  /// Returns penalty points. -16 if 3-foul triggered, -1 otherwise
  /// ballsPocketed: Number of balls pocketed during this shot
  int applyNormalFoul(Player player, int ballsPocketed) {
    if (threeFoulRuleEnabled) {
      // Logic Update: Test vectors imply fouls always increment streak, 
      // even if points were scored in the same inning (C34).
      player.consecutiveFouls++;
      
      if (player.consecutiveFouls >= 3) {
        player.consecutiveFouls = 0; // Reset after penalty
        return -16; // 3-foul penalty TOTAL (-1 foul + -15 penalty)
      }
    } else {
      player.consecutiveFouls = 0; // Ensure it doesn't accumulate if disabled
    }
    return -1;
  }

  /// Severe (Break) Foul: -2 points, does NOT count toward 3-foul rule
  int applySevereFoul(Player player) {
    // Break foul shouldn't reset normal foul count? Or does it?
    // Rules say Break Foul is separate. Assuming it doesn't break consecutive Normal fouls chain?
    // Or does it?
    // "Consecutive fouls" usually implies *any* foul.
    // But this app has specific "Normal" vs "Severe".
    // Severe is -2. If I foul -1, then Break Foul -2, then Foul -1. Is that 3 fouls?
    // User request: "3 foul rule not always working you need a counter for each player."
    // Usually 3 consecutive fouls of ANY kind in 14.1.
    // If Break Foul is a foul, it should count?
    // But existing code had `applySevereFoul` returning -2 and NOT touching counter.
    // Keep it as is for now unless user specifies.
    return -2;
  }

  void reset() {
    // No internal state to reset.
  }
}
