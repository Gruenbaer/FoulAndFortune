import '../base/game_rules.dart';
import '../base/rules_state.dart';
import '../base/rule_outcome.dart';
import '../../core/actions/game_action.dart';
import '../../models/game_settings.dart';
import '../../models/foul_tracker.dart';
import '../../codecs/notation_codec.dart';
import 'straight_pool_state.dart';

/// 14.1 Straight Pool rules implementation.
/// 
/// Implements the canonical FF14 ruleset with:
/// - Re-rack at ball 1, double-sack at ball 0
/// - Foul penalties: -1 normal, -2 break, -16 three-consecutive
/// - Break foul sequencing
/// - Canonical notation generation
class StraightPoolRules implements GameRules {
  @override
  String get gameId => "14.1";
  
  @override
  String get displayName => "Straight Pool";
  
  @override
  RulesState initialState(GameSettings settings) {
    return StraightPoolState(
      foulTracker: FoulTracker(
        threeFoulRuleEnabled: settings.threeFoulRuleEnabled,
      ),
      raceToScore: settings.raceToScore,
    );
  }
  
  @override
  RuleOutcome apply(
    GameAction action,
    CoreState core,
    RulesState rules,
  ) {
    final state = rules as StraightPoolState;
    
    // Dispatch to appropriate handler based on action type
    return switch (action) {
      BallTappedAction() => _handleBallTapped(action, core, state),
      DoubleSackAction() => _handleDoubleSack(action, core, state),
      SafeAction() => _handleSafe(action, core, state),
      FoulAction() => _handleFoul(action, core, state),
      BreakFoulDecisionAction() => _handleBreakFoulDecision(action, core, state),
      FinalizeReRackAction() => _handleFinalizeReRack(action, core, state),
      _ => throw UnimplementedError('Unknown action: $action'),
    };
  }
  
  @override
  WinResult? checkWin(CoreState core, RulesState rules) {
    final state = rules as StraightPoolState;
    
    // Check all players for win condition
    for (var i = 0; i < core.players.length; i++) {
      final player = core.players[i];
      if (player.score >= state.raceToScore) {
        return WinResult(
          winningPlayerIndex: i,
          reason: "Reached ${state.raceToScore} points",
        );
      }
    }
    
    return null; // Game continues
  }
  
  @override
  String generateNotation(InningData inning) {
    // TODO: Implement notation generation
    return "";
  }
  
  // === Private Handlers ===
  
  RuleOutcome _handleBallTapped(
    BallTappedAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement ball tapped logic
    throw UnimplementedError('BallTappedAction not yet implemented');
  }
  
  RuleOutcome _handleDoubleSack(
    DoubleSackAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement double-sack logic
    throw UnimplementedError('DoubleSackAction not yet implemented');
  }
  
  RuleOutcome _handleSafe(
    SafeAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement safe logic
    throw UnimplementedError('SafeAction not yet implemented');
  }
  
  RuleOutcome _handleFoul(
    FoulAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement foul logic
    throw UnimplementedError('FoulAction not yet implemented');
  }
  
  RuleOutcome _handleBreakFoulDecision(
    BreakFoulDecisionAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement break foul decision logic
    throw UnimplementedError('BreakFoulDecisionAction not yet implemented');
  }
  
  RuleOutcome _handleFinalizeReRack(
    FinalizeReRackAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // TODO: Implement finalize re-rack logic
    throw UnimplementedError('FinalizeReRackAction not yet implemented');
  }
}
