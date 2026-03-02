import '../services/shot_event_service.dart';
import '../stats/shot_event_type.dart';
import '../codecs/notation_codec.dart'; // For FoulType

/// Emitter for shot-level events, designed to be integrated into GameState.
/// 
/// Tracks turn/shot indices and emits events via ShotEventService.
/// See SHOT_EVENT_SOURCING.md for specification.
class ShotEventEmitter {
  final ShotEventService _service;
  final String gameId;
  
  int _currentTurnIndex = 0;
  int _currentShotIndex = 0;
  String _currentPlayerId = '';
  
  /// Whether event emission is enabled. Can be disabled for replays/tests.
  bool enabled = true;
  
  ShotEventEmitter({
    required ShotEventService service,
    required this.gameId,
  }) : _service = service;
  
  /// Initialize with player and turn state.
  void initialize({
    required String playerId,
    int turnIndex = 0,
    int shotIndex = 0,
  }) {
    _currentPlayerId = playerId;
    _currentTurnIndex = turnIndex;
    _currentShotIndex = shotIndex;
  }
  
  /// Set the current player (for turn tracking).
  void setCurrentPlayer(String playerId) {
    _currentPlayerId = playerId;
  }
  
  /// Emit: Ball pocketed
  Future<void> emitPocket(int ballId) async {
    if (!enabled) return;
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.shot,
      data: {
        'kind': ShotKind.pocket.name,
        'ballId': ballId,
      },
    );
  }
  
  /// Emit: Safety played
  Future<void> emitSafety() async {
    if (!enabled) return;
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.shot,
      data: {
        'kind': ShotKind.safety.name,
      },
    );
  }
  
  /// Emit: Foul committed
  Future<void> emitFoul({
    required FoulType foulType,
    required int penalty,
    String? reason,
  }) async {
    if (!enabled) return;
    final data = <String, dynamic>{
      'kind': ShotKind.foul.name,
      'foulType': foulType.name,
      'penalty': penalty,
    };
    if (reason != null) {
      data['reason'] = reason;
    }
    
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.shot,
      data: data,
    );
  }
  
  /// Emit: Turn ended
  Future<void> emitTurnEnd({int? pointsInTurn}) async {
    if (!enabled) return;
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.turnEnd,
      data: {
        if (pointsInTurn != null) 'pointsInTurn': pointsInTurn,
      },
    );
  }
  
  /// Emit: Turn started (called after player switch)
  Future<void> emitTurnStart() async {
    if (!enabled) return;
    _currentTurnIndex++;
    _currentShotIndex = 0;
    
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.turnStart,
      data: {},
    );
  }
  
  /// Emit: Re-rack
  Future<void> emitReRack({required String reason}) async {
    if (!enabled) return;
    await _service.emit(
      gameId: gameId,
      playerId: _currentPlayerId,
      turnIndex: _currentTurnIndex,
      shotIndex: _currentShotIndex++,
      eventType: ShotEventType.rerack,
      data: {
        'reason': reason,
      },
    );
  }
  
  /// Get current turn index (for external use).
  int get currentTurnIndex => _currentTurnIndex;
  
  /// Get current shot index (for external use).
  int get currentShotIndex => _currentShotIndex;
}
