/// Result of applying a GameAction through GameRules.
/// Contains COMPLETE, EXPLICIT directives for GameState to mechanically execute.
/// 
/// CRITICAL: This must be rich enough that GameState NEVER interprets game rules.
/// If GameState needs to infer what to do, add fields here instead.
class RuleOutcome {
  /// Points to award in the current segment (before handicap).
  /// GameState applies handicap multiplier.
  final int rawPointsDelta;
  
  /// Turn directive: what happens next.
  final TurnDirective turnDirective;
  
  /// Table directive: rack manipulation (optional).
  final TableDirective? tableDirective;
  
  /// Foul classification (optional).
  final FoulClassification? foul;
  
  /// Notification tokens for this action.
  final List<String> notationTokens;
  
  /// Whether this action ends the current inning.
  final bool endsInning;
  
  /// State mutations to apply to RulesState.
  /// GameState applies these mutations to the rules state.
  final List<StateMutation> stateMutations;
  
  /// Events to queue (generic descriptors, not UI events).
  final List<EventDescriptor> events;
  
  /// Decision required from user (optional).
  final DecisionRequirement? decisionRequirement;
  
  /// Log message (optional).
  final String? logMessage;
  
  const RuleOutcome({
    required this.rawPointsDelta,
    required this.turnDirective,
    this.tableDirective,
    this.foul,
    this.notationTokens = const [],
    this.endsInning = false,
    this.stateMutations = const [],
    this.events = const [],
    this.decisionRequirement,
    this.logMessage,
  });
  
  @override
  String toString() => 'RuleOutcome('
      'points: $rawPointsDelta, '
      'turn: $turnDirective, '
      'table: $tableDirective, '
      'foul: $foul, '
      'decision: $decisionRequirement, '
      'endsInning: $endsInning)';
}

/// What should happen with player turns.
enum TurnDirective {
  continueTurn,     // Same player continues
  endTurn,          // Current inning ends, switch to next player
  awaitDecision,    // Waiting for user decision before proceeding
  gameOver          // Game has ended
}

/// Table manipulation directives.
enum TableDirective {
  reRack,     // Re-rack to 15 balls (14.1 re-rack or break foul re-break)
  clearRack,  // Clear all balls (14.1 double-sack, show 0 before re-rack animation)
  showOne,    // Show only ball 1 (14.1 re-rack at ball 1, before animation)
  spot,       // Spot specific balls (e.g., 8-ball, 9-ball)
  reset       // Full table reset
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

/// State mutations to apply to RulesState.
/// GameState applies these mutations.
sealed class StateMutation {
  const StateMutation();
}

/// Save current inning segment to history and reset for next segment.
class SaveSegmentMutation extends StateMutation {
  final int points;
  const SaveSegmentMutation(this.points);
}

/// Increment break foul count.
class IncrementBreakFoulCountMutation extends StateMutation {
  const IncrementBreakFoulCountMutation();
}

/// Mark inning as having a foul.
class MarkInningFoulMutation extends StateMutation {
  const MarkInningFoulMutation();
}

/// Mark inning as having a safe.
class MarkInningSafeMutation extends StateMutation {
  const MarkInningSafeMutation();
}

/// Mark inning as having a re-rack.
class MarkInningReRackMutation extends StateMutation {
  const MarkInningReRackMutation();
}

/// Disable break foul availability permanently.
class DisableBreakFoulsMutation extends StateMutation {
  const DisableBreakFoulsMutation();
}

/// End break sequence.
class EndBreakSequenceMutation extends StateMutation {
  const EndBreakSequenceMutation();
}

/// Set breaking player index.
class SetBreakingPlayerMutation extends StateMutation {
  final int playerIndex;
  const SetBreakingPlayerMutation(this.playerIndex);
}

/// Event descriptors (generic, not UI-specific).
sealed class EventDescriptor {
  const EventDescriptor();
}

/// Foul event occurred.
class FoulEventDescriptor extends EventDescriptor {
  final int penalty;
  final FoulType type;
  
  const FoulEventDescriptor({
    required this.penalty,
    required this.type,
  });
}

/// Safe event occurred.
class SafeEventDescriptor extends EventDescriptor {
  const SafeEventDescriptor();
}

/// Re-rack event occurred.
class ReRackEventDescriptor extends EventDescriptor {
  final String variant; // "reRack" or "tableCleared"
  
  const ReRackEventDescriptor(this.variant);
}

/// Decision required from user.
class DecisionRequirement {
  final String type; // e.g., "breakFoulDecision"
  final List<String> options;
  
  const DecisionRequirement({
    required this.type,
    required this.options,
  });
}

