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
    final currentPlayer = core.players[core.activePlayerIndex];
    final ballsRemaining = core.activeBalls.length;
    
    final List<StateMutation> mutations = [
      SaveSegmentMutation(state.currentInningPoints + ballsRemaining),
      const MarkInningReRackMutation(),
    ];
    final List<EventDescriptor> events = [
      const ReRackEventDescriptor('reRack'),
    ];
    
    // Track foul if present
    FoulClassification? foulClass;
    if (state.pendingFoulMode == FoulMode.normal) {
      mutations.add(const MarkInningFoulMutation());
      foulClass = const FoulClassification(type: FoulType.normal, penalty: -1);
    } else if (state.pendingFoulMode == FoulMode.severe) {
      mutations.add(const IncrementBreakFoulCountMutation());
      foulClass = const FoulClassification(type: FoulType.breakFoul, penalty: -2);
    }
    
    // Check if player will win (projected score check)
    // Note: GameState applies handicap multipliers, rules work with raw points
    final rawSegmentTotal = state.currentInningSegments.fold(0, (sum, p) => sum + p);
    final rawInningTotal = rawSegmentTotal + state.currentInningPoints + ballsRemaining;
    final projectedScore = currentPlayer.score + rawInningTotal; // Handicap applied by GameState
    final projectedWin = projectedScore >= state.raceToScore;
    
    // Determine turn directive
    TurnDirective turnDirective;
    bool endsInning;
    if (projectedWin) {
      turnDirective = TurnDirective.gameOver;
      endsInning = true;
    } else if (state.pendingFoulMode != FoulMode.none) {
      turnDirective = TurnDirective.endTurn;
      endsInning = true;
    } else {
      turnDirective = TurnDirective.continueTurn;
      endsInning = false;
    }
    
    // Log message
    final foulText = state.pendingFoulMode == FoulMode.normal ? ' (Foul)' 
                   : state.pendingFoulMode == FoulMode.severe ? ' (Break Foul)' 
                   : '';
    final logMessage = '${currentPlayer.name}: Double-sack! $ballsRemaining balls$foulText';
    
    return RuleOutcome(
      rawPointsDelta: ballsRemaining,
      turnDirective: turnDirective,
      tableDirective: TableDirective.clearRack,
      foul: foulClass,
      notationTokens: [ballsRemaining.toString()],
      endsInning: endsInning,
      stateMutations: mutations,
      events: events,
      logMessage: logMessage,
    );
  }
  
  RuleOutcome _handleSafe(
    SafeAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    final currentPlayer = core.players[core.activePlayerIndex];
    
    // Safe action behavior depends on whether safe mode is already active
    if (!state.pendingSafeMode) {
      // ENTER safe mode - just toggle, don't end turn yet
      // This is handled by GameState setting the mode
      return const RuleOutcome(
        rawPointsDelta: 0,
        turnDirective: TurnDirective.continueTurn,
        notationTokens: [],
        endsInning: false,
        stateMutations: [], // GameState handles mode toggle
      );
    } else {
      // CONFIRM standard safe - end turn without ball tap
      return RuleOutcome(
        rawPointsDelta: 0,
        turnDirective: TurnDirective.endTurn,
        notationTokens: const [],
        endsInning: true,
        stateMutations: const [
          MarkInningSafeMutation(),
        ],
        events: const [
          SafeEventDescriptor(),
        ],
        logMessage: '${currentPlayer.name}: Safe (Standard)',
      );
    }
  }
  
  RuleOutcome _handleFoul(
    FoulAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // Foul action just sets the pending mode
    // GameState handles the toggle, rules just acknowledge
    return const RuleOutcome(
      rawPointsDelta: 0,
      turnDirective: TurnDirective.continueTurn,
      notationTokens: [],
      endsInning: false,
      stateMutations: [], // GameState handles foulMode toggle
    );
  }
  
  RuleOutcome _handleBreakFoulDecision(
    BreakFoulDecisionAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    final currentPlayer = core.players[core.activePlayerIndex];
    final selectedIndex = action.selectedPlayerIndex;
    
    List<StateMutation> mutations = [];
    TurnDirective turnDirective;
    bool endsInning;
    String logMessage;
    
    if (selectedIndex != core.activePlayerIndex) {
      // SWITCH: Opponent chose to break
      // Finalize current player's inning, switch to selected player
      mutations.add(const DisableBreakFoulsMutation());
      turnDirective = TurnDirective.endTurn; // Switch player
      endsInning = true;
      logMessage = 'Decision: ${core.players[selectedIndex].name} will break';
    } else {
      // SAME PLAYER: Re-break (Stacking)
      // Do NOT finalize. Keep inning open.
      turnDirective = TurnDirective.continueTurn;
      endsInning = false;
      logMessage = 'Decision: ${currentPlayer.name} re-breaks (Inning Continues)';
    }
    
    // Re-enter break sequence
    // Table resets to 15 handled by GameState
    
    return RuleOutcome(
      rawPointsDelta: 0,
      turnDirective: turnDirective,
      tableDirective: TableDirective.reRack,
      notationTokens: const [],
      endsInning: endsInning,
      stateMutations: mutations,
      logMessage: logMessage,
    );
  }
  
  RuleOutcome _handleFinalizeReRack(
    FinalizeReRackAction action,
    CoreState core,
    StraightPoolState state,
  ) {
    // Finalize re-rack is purely infrastructure (table reset after animation)
    // No game logic decisions needed
    return const RuleOutcome(
      rawPointsDelta: 0,
      turnDirective: TurnDirective.continueTurn,
      tableDirective: TableDirective.reset,
      notationTokens: [],
      endsInning: false,
    );
  }
}
