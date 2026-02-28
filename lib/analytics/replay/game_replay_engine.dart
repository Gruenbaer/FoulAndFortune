
import 'dart:convert';
import 'package:foulandfortune/data/app_database.dart';
import 'replay_state.dart';

/// Engine to replay a game deterministically from its event stream.
class GameReplayEngine {
  /// Replay a game from start to finish.
  ReplayResult replayGame({
    required GameMeta meta,
    required List<ShotEventRow> events,
    bool strictMode = true,
  }) {
    var state = ReplayState.initial(meta);
    final warnings = <String>[];

    // Check strict monotonicity of ordering
    for (int i = 0; i < events.length - 1; i++) {
        if (events[i].turnIndex > events[i+1].turnIndex ||
           (events[i].turnIndex == events[i+1].turnIndex && 
            events[i].shotIndex >= events[i+1].shotIndex)) {
             warnings.add("Event ordering violation at index $i vs ${i+1}");
        }
    }

    for (final event in events) {
      try {
        state = _applyEvent(state, event, meta);
      } catch (e) {
        final msg = "Error applying event ${event.id}: $e";
        if (strictMode) throw ReplayException(msg);
        warnings.add(msg);
      }
    }
    
    // Finalize state (e.g. determine winner if not set)
    // For MVP, we rely on state as established by events.
    if (!state.isCompleted && (meta.raceToScore > 0)) {
       // Check if someone reached raceToScore (if logic implies auto-complete)
       // But usually 'game_over' turn directive handles this locally.
    }

    return ReplayResult(state, warnings);
  }

  ReplayState _applyEvent(ReplayState state, ShotEventRow event, GameMeta meta) {
    // Create a working copy
    final nextState = state.copy();
    final playerId = nextState.activePlayerId;
    
    // Guard: Basic integrity
    if (playerId == null) {
       // Only allow turnStart/setup events if no player active? 
       // Start of game usually sets activePlayerId from Meta.
       // Only 'turnStart' might change it?
    }

    // Parse payload
    final payloadMap = jsonDecode(event.payload) as Map<String, dynamic>;
    final version = payloadMap['v'] as int?;
    final data = payloadMap['data'] as Map<String, dynamic>;

    if (version != 1) {
       // For now only v1 supported
    }

    nextState.currentTurnIndex = event.turnIndex;
    nextState.currentShotIndex = event.shotIndex;

    switch (event.eventType) {
      case 'shot':
        _applyShot(nextState, data, meta);
        break;
      case 'turnEnd':
        _applyTurnEnd(nextState, meta);
        break;
      case 'turnStart':
        // Mostly bookkeeping/validation
        break;
      case 'rerack':
        _applyRerack(nextState, data, meta);
        break;
      case 'gameEnd': // If we have this event?
        nextState.isCompleted = true;
        break;
      default:
        // Ignore unknown events for now (or warn)
        break;
    }

    return nextState;
  }

  void _applyShot(ReplayState state, Map<String, dynamic> data, GameMeta meta) {
    final kind = data['kind'] as String;
    final playerId = state.activePlayerId!;

    switch (kind) {
      case 'pocket':
        _handlePocket(state, playerId, data, meta);
        break;
      case 'foul':
        _handleFoul(state, playerId, data, meta);
        break;
      case 'safety':
        _handleSafety(state, playerId);
        break;
      case 'miss':
        _handleMiss(state, playerId);
        break;
      default:
        // Warning?
        break;
    }
  }

  void _handlePocket(ReplayState state, String playerId, Map<String, dynamic> data, GameMeta meta) {
    // Basic scoring
    state.scores[playerId] = (state.scores[playerId] ?? 0) + 1;
    state.currentRuns[playerId] = (state.currentRuns[playerId] ?? 0) + 1;
    
    // Update High Run
    if (state.currentRuns[playerId]! > (state.highestRuns[playerId] ?? 0)) {
      state.highestRuns[playerId] = state.currentRuns[playerId]!;
    }

    // Straight Pool Break Logic
    if (meta.discipline == 'StraightPool') {
       final isBreakShot = data['isBreakShot'] as bool? ?? false;
       if (isBreakShot) {
          // Special scoring? No, points are same. Logic is about state.
          // If break shot was successful, we are technically not in break sequence anymore??
          // Actually StraightPoolState.inBreakSequence goes false after successful break.
          state.inBreakSequence = false;
       }
    }
  }

  void _handleFoul(ReplayState state, String playerId, Map<String, dynamic> data, GameMeta meta) {
    final foulType = data['foulType'] as String?; // normal, breakFoul, threeFouls
    
    // Derive penalty
    int penalty = -1; // Default
    if (meta.discipline == 'StraightPool') {
       if (foulType == 'breakFoul') penalty = -2;
       if (foulType == 'threeFouls') penalty = -15;
    } else {
       // Other disciplines might be ball-in-hand (0 points deduction usually)
       // But let's assume -1 for legacy MVP unless specified
    }

    // Update Score
    state.scores[playerId] = (state.scores[playerId] ?? 0) + penalty;
    
    // Update Stats
    state.fouls[playerId] = (state.fouls[playerId] ?? 0) + 1;
    
    // End Run
    state.currentRuns[playerId] = 0;
    
    // 3-Foul Logic? 
    // If threeFouls, usually implies rerack. Rerack event handles board state.
    // Penalty is handled here.
  }

  void _handleSafety(ReplayState state, String playerId) {
    state.currentRuns[playerId] = 0;
  }

  void _handleMiss(ReplayState state, String playerId) {
    state.currentRuns[playerId] = 0;
  }

  void _applyTurnEnd(ReplayState state, GameMeta meta) {
    final currentPlayer = state.activePlayerId!;
    
    // Increment innings for the player failing to continue
    state.innings[currentPlayer] = (state.innings[currentPlayer] ?? 0) + 1;

    // Switch Player
    // For 2 players, find the other one.
    if (meta.players.length == 2) {
       final other = meta.players.firstWhere((p) => p.id != currentPlayer);
       state.activePlayerId = other.id;
    }

    // Reset current run for new player? 
    // Usually yes, but if they are continuing a run? 
    // In strict turn-based, new player starts at 0.
    // If same player continues (e.g. after re-rack?), use logic?
    // But turnEnd usually implies control change.
    
    // Wait: If TurnDirective is continueTurn, we don't get turnEnd event?
    // Correct. So turnEnd IS a switch.
    
    // Ensure next player starts with 0 run
    if (state.activePlayerId != currentPlayer) {
       state.currentRuns[state.activePlayerId!] = 0;
    }
  }

  void _applyRerack(ReplayState state, Map<String, dynamic> data, GameMeta meta) {
      // reason: three_foul, normal
      final reason = data['reason'] as String?;
      if (reason == 'three_foul') {
         // Reset break sequence
         if (meta.discipline == 'StraightPool') {
            state.inBreakSequence = true;
         }
      }
  }
}

class ReplayResult {
  final ReplayState state;
  final List<String> warnings;

  ReplayResult(this.state, this.warnings);
  
  bool get isClean => warnings.isEmpty;
}

class ReplayException implements Exception {
  final String message;
  ReplayException(this.message);
  @override
  String toString() => 'ReplayException: $message';
}
