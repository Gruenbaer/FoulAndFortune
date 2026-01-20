/// Result of applying a GameAction through GameRules.
/// Contains directives for the core engine to execute.
class RuleOutcome {
  /// Points delta to award (can be negative for fouls).
  final int pointsDelta;
  
  /// Turn directive: what should happen next.
  final TurnDirective turnDirective;
  
  /// Table directive: rack manipulation (optional).
  final TableDirective? tableDirective;
  
  /// Foul classification (optional).
  final FoulClassification? foul;
  
  /// Notation tokens for this action (segments, suffixes).
  final List<String> notationTokens;
  
  /// Whether this ends the current inning.
  final bool endsInning;
  
  const RuleOutcome({
    required this.pointsDelta,
    required this.turnDirective,
    this.tableDirective,
    this.foul,
    this.notationTokens = const [],
    this.endsInning = false,
  });
  
  @override
  String toString() => 'RuleOutcome('
      'points: $pointsDelta, '
      'turn: $turnDirective, '
      'table: $tableDirective, '
      'foul: $foul, '
      'endsInning: $endsInning)';
}

/// What should happen with player turns.
enum TurnDirective {
  continueTurn,  // Same player continues
  endTurn,       // Switch to next player
  gameOver       // Game has ended
}

/// Table manipulation directives.
enum TableDirective {
  reRack,        // Re-rack to 15 balls (14.1 re-rack)
  spot,          // Spot specific balls (e.g., 8-ball, 9-ball)
  reset          // Full table reset
}

/// Foul classification for tracking and notation.
class FoulClassification {
  final FoulType type;
  final int penalty;
  
  const FoulClassification({
    required this.type,
    required this.penalty,
  });
  
  @override
  String toString() => 'Foul(type: $type, penalty: $penalty)';
}

/// Types of fouls (notation-relevant).
enum FoulType {
  normal,        // Standard foul: F
  breakFoul,     // Break foul: BF
  threeFouls     // Three consecutive: TF
}

/// Result of checking win condition.
class WinResult {
  final int winningPlayerIndex;
  final String reason;
  
  const WinResult({
    required this.winningPlayerIndex,
    required this.reason,
  });
  
  @override
  String toString() => 'WinResult(player: $winningPlayerIndex, reason: $reason)';
}
