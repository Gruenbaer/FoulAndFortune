/// User input actions that drive game state changes.
/// These are game-agnostic - the Rules plugin interprets what they mean.
sealed class GameAction {
  const GameAction();
}

/// User tapped a ball on the rack (specified by remaining count).
class BallTappedAction extends GameAction {
  final int remainingCount;
  
  const BallTappedAction(this.remainingCount);
  
  @override
  String toString() => 'BallTapped(remaining: $remainingCount)';
}

/// User triggered double-sack (cleared entire table).
class DoubleSackAction extends GameAction {
  const DoubleSackAction();
  
  @override
  String toString() => 'DoubleSack';
}

/// User declared a safety (ends turn without scoring).
class SafeAction extends GameAction {
  const SafeAction();
  
  @override
  String toString() => 'Safe';
}

/// User committed a foul.
class FoulAction extends GameAction {
  final FoulSeverity severity;
  
  const FoulAction({required this.severity});
  
  @override
  String toString() => 'Foul(severity: $severity)';
}

/// Foul severity levels.
enum FoulSeverity {
  normal,   // Standard foul: -1 point
  breakFoul // Break foul: -2 points
}

/// User made a break foul decision (re-break or switch player).
class BreakFoulDecisionAction extends GameAction {
  final int selectedIndex; // 0 = re-break, 1 = switch
  
  const BreakFoulDecisionAction(this.selectedIndex);
  
  @override
  String toString() => 'BreakFoulDecision(index: $selectedIndex)';
}

/// Finalize re-rack after animation (internal action).
class FinalizeReRackAction extends GameAction {
  const FinalizeReRackAction();
  
  @override
  String toString() => 'FinalizeReRack';
}
