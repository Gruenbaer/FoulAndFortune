import 'rules_state.dart';
import 'rule_outcome.dart';
import '../../core/actions/game_action.dart';
import '../../models/game_settings.dart';

/// Abstract interface for game-specific rules plugins.
/// 
/// Design principle: Core decides WHEN things happen, Rules decide WHAT it means.
/// 
/// Implementations: StraightPoolRules, NineBallRules, EightBallRules, etc.
abstract class GameRules {
  /// Unique identifier for this game type (e.g., "14.1", "9-ball").
  String get gameId;
  
  /// Human-readable display name (e.g., "Straight Pool", "9-Ball").
  String get displayName;
  
  /// Create initial rules state from game settings.
  RulesState initialState(GameSettings settings);
  
  /// Apply a user action and return the outcome.
  /// 
  /// The core engine will execute the directives in the outcome:
  /// - Award/deduct points
  /// - Continue/end turn
  /// - Manipulate table (re-rack, spot balls, etc.)
  /// - Record notation
  /// 
  /// Rules MUST NOT mutate CoreState directly - only return directives.
  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rules,
  );
  
  /// Check if a player has won the game.
  /// Returns null if game is still in progress.
  WinResult? checkWin(CoreState core, RulesState rules);
  
  /// Generate canonical notation for an inning.
  String generateNotation(InningData inning);
}

/// Core game state (game-agnostic infrastructure).
/// Rules can read but never mutate this directly.
class CoreState {
  final List<Player> players;
  final int activePlayerIndex;
  final int inningNumber;
  final int turnNumber;
  final Set<int> activeBalls;
  
  const CoreState({
    required this.players,
    required this.activePlayerIndex,
    required this.inningNumber,
    required this.turnNumber,
    required this.activeBalls,
  });
}

/// Inning data for notation generation.
class InningData {
  final List<int> segments;
  final bool isSafe;
  final String? foulSuffix; // 'F', 'BF', 'TF', or null
  
  const InningData({
    required this.segments,
    this.isSafe = false,
    this.foulSuffix,
  });
}

// Player class will be imported from existing models
// This is a placeholder to prevent errors during interface definition
class Player {
  final String name;
  int score;
  
  Player({required this.name, this.score = 0});
}
