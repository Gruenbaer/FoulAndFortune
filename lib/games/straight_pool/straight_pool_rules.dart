import '../base/game_rules.dart';
import '../base/rules_state.dart';
import '../base/rule_outcome.dart';
import '../../core/actions/game_action.dart';
import '../../models/game_settings.dart';
import '../../models/foul_tracker.dart';
import '../../codecs/notation_codec.dart' as codec;
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
    // Build InningRecord for serialization
    final record = codec.InningRecord(
      inning: 0, // Not used by serialize()
      playerName: '', // Not used by serialize()
      notation: '', // Will be generated
      runningTotal: 0, // Not used by serialize()
      segments: inning.segments,
      safe: inning.isSafe,
      foul: _parseFoulType(inning.foulSuffix),
      foulCount: _parseFoulCount(inning.foulSuffix),
    );
    
    return codec.NotationCodec.serialize(record);
  }
  
  // Helper to parse foul type from suffix
  codec.FoulType _parseFoulType(String? suffix) {
    if (suffix == null) return codec.FoulType.none;
    if (suffix.startsWith('BF')) return codec.FoulType.breakFoul;
    if (suffix == 'TF') return codec.FoulType.threeFouls;
    if (suffix == 'F') return codec.FoulType.normal;
    return codec.FoulType.none;
  }
  
  // Helper to parse foul count from suffix
  int _parseFoulCount(String? suffix) {
    if (suffix == null || !suffix.startsWith('BF')) return 1;
    
    // Extract number from BF suffix (e.g., "BF2" -> 2, "BF" -> 1)
    final match = RegExp(r'BF(\d+)').firstMatch(suffix);
    if (match != null && match.group(1) != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }
  
  // === Private Handlers ===
  
  RuleOutcome _handleBallTapped(
    BallTappedAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    final currentPlayer = core.players[core.activePlayerIndex];
    final ballsPocketed = core.activeBalls.length - action.remainingCount;
    final newBallCount = action.remainingCount;
    
    // --- CASE 1: BREAK FOUL (Severe Mode) ---
    if (state.pendingFoulMode == FoulMode.severe) {
      // Break foul: -2 points, decision required
      return RuleOutcome(
        rawPointsDelta: 0, // Penalty applied in finalize
        turnDirective: TurnDirective.awaitDecision,
        foul: const FoulClassification(type: FoulType.breakFoul, penalty: -2),
        notationTokens: const [],
        endsInning: false, // Depends on decision
        stateMutations: const [
          IncrementBreakFoulCountMutation(),
        ],
        events: [
          const FoulEventDescriptor(penalty: -2, type: FoulType.breakFoul),
        ],
        decisionRequirement: DecisionRequirement(
          type: 'breakFoulDecision',
          options: [core.players[0].name, core.players[1].name],
        ),
        logMessage: '${currentPlayer.name}: Break Foul #${state.currentInningBreakFoulCount + 1} (-2 pts)',
      );
    }
    
    // --- CASE 2: NORMAL SHOT ---
    final List<StateMutation> mutations = [];
    final List<EventDescriptor> events = [];
    
    // End break sequence on first normal action
    mutations.add(const EndBreakSequenceMutation());
    
    // Set breaking player if not set
    if (state.breakingPlayerIndex == null) {
      mutations.add(SetBreakingPlayerMutation(core.activePlayerIndex));
    }
    
    // Permanently disable break fouls if any balls potted
    if (ballsPocketed > 0 && state.breakFoulStillAvailable) {
      mutations.add(const DisableBreakFoulsMutation());
    }
    
    // Handle foul
    FoulClassification? foulClass;
    if (state.pendingFoulMode == FoulMode.normal) {
      mutations.add(const MarkInningFoulMutation());
      foulClass = const FoulClassification(type: FoulType.normal, penalty: -1);
      
      // Add foul event (three-foul detection happens in GameState finalize)
      events.add(const FoulEventDescriptor(penalty: -1, type: FoulType.normal));
    }
    
    // Handle safe
    if (state.pendingSafeMode) {
      mutations.add(const MarkInningSafeMutation());
      events.add(const SafeEventDescriptor());
    }
    
    // Determine continuation and table actions
    TableDirective? tableDirective;
    TurnDirective turnDirective;
    bool isReRack = (newBallCount == 1);
    bool isDoubleSack = (newBallCount == 0);
    
    if (isReRack) {
      // Re-rack: save segment, continue turn
      mutations.add(SaveSegmentMutation(state.currentInningPoints + ballsPocketed));
      mutations.add(const MarkInningReRackMutation());
      tableDirective = TableDirective.showOne; // Show ball 1, re-rack happens in animation callback
      turnDirective = TurnDirective.continueTurn;
      events.add(const ReRackEventDescriptor('reRack'));
    } else if (isDoubleSack) {
      // Double-sack: save segment, continue turn
      mutations.add(SaveSegmentMutation(state.currentInningPoints + ballsPocketed));
      mutations.add(const MarkInningReRackMutation());
      tableDirective = TableDirective.clearRack; // Clear immediately, re-rack in animation callback
      turnDirective = TurnDirective.continueTurn;
      events.add(const ReRackEventDescriptor('tableCleared'));
    } else {
      // Normal end (2-15): turn ends
      turnDirective = TurnDirective.endTurn;
    }
    
    // Build log message
    String? logMessage;
    if (ballsPocketed != 0 || state.pendingFoulMode != FoulMode.none) {
      final foulText = state.pendingFoulMode == FoulMode.normal ? ' (Foul)' : '';
      final safeText = state.pendingSafeMode ? ' (Safe)' : '';
      final sign = ballsPocketed > 0 ? '+' : '';
      logMessage = '${currentPlayer.name}: $sign$ballsPocketed balls$foulText$safeText (Left: $newBallCount)';
    }
    
    return RuleOutcome(
      rawPointsDelta: ballsPocketed,
      turnDirective: turnDirective,
      tableDirective: tableDirective,
      foul: foulClass,
      notationTokens: [ballsPocketed.toString()],
      endsInning: turnDirective == TurnDirective.endTurn,
      stateMutations: mutations,
      events: events,
      logMessage: logMessage,
    );
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
