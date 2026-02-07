import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../stats/shot_event_type.dart';

/// Service for emitting and querying shot-level events.
/// 
/// Events are append-only. See SHOT_EVENT_SOURCING.md for specification.
class ShotEventService {
  final AppDatabase db;
  final _uuid = const Uuid();
  
  ShotEventService({required this.db});
  
  /// Emit a shot event. Append-only, no updates allowed.
  Future<void> emit({
    required String gameId,
    required String playerId,
    required int turnIndex,
    required int shotIndex,
    required ShotEventType eventType,
    required Map<String, dynamic> data,
  }) async {
    final now = DateTime.now();
    
    // Versioned payload per spec
    final payload = jsonEncode({
      'v': 1,
      'data': data,
    });
    
    await db.into(db.shotEvents).insert(ShotEventsCompanion.insert(
      id: _uuid.v4(),
      gameId: gameId,
      playerId: playerId,
      turnIndex: turnIndex,
      shotIndex: shotIndex,
      eventType: eventType.name,
      payload: payload,
      ts: now,
      createdAt: now,
    ));
  }
  
  /// Emit a void/compensating event to undo a previous action.
  /// 
  /// Per spec: No hard deletes. Corrections via compensating events.
  Future<void> emitVoid({
    required String gameId,
    required String playerId,
    required int turnIndex,
    required int shotIndex,
    required String correctionOf,
  }) async {
    await emit(
      gameId: gameId,
      playerId: playerId,
      turnIndex: turnIndex,
      shotIndex: shotIndex,
      eventType: ShotEventType.shot,
      data: {
        'kind': ShotKind.void_.name,
        'correctionOf': correctionOf,
      },
    );
  }
  
  /// Get all events for a game, ordered by (turnIndex, shotIndex).
  Future<List<ShotEventRow>> getEventsForGame(String gameId) async {
    return (db.select(db.shotEvents)
      ..where((e) => e.gameId.equals(gameId))
      ..orderBy([
        (e) => OrderingTerm.asc(e.turnIndex),
        (e) => OrderingTerm.asc(e.shotIndex),
      ]))
      .get();
  }
  
  /// Watch events for a game in real-time.
  Stream<List<ShotEventRow>> watchEventsForGame(String gameId) {
    return (db.select(db.shotEvents)
      ..where((e) => e.gameId.equals(gameId))
      ..orderBy([
        (e) => OrderingTerm.asc(e.turnIndex),
        (e) => OrderingTerm.asc(e.shotIndex),
      ]))
      .watch();
  }
  
  /// Get the next shot index for a turn.
  Future<int> getNextShotIndex(String gameId, int turnIndex) async {
    final result = await (db.selectOnly(db.shotEvents)
      ..addColumns([db.shotEvents.shotIndex.max()])
      ..where(db.shotEvents.gameId.equals(gameId) & 
              db.shotEvents.turnIndex.equals(turnIndex)))
      .getSingleOrNull();
    
    final maxIndex = result?.read<int>(db.shotEvents.shotIndex.max());
    return (maxIndex ?? -1) + 1;
  }
  
  /// Check if shot-level events exist for a game.
  Future<bool> hasEventsForGame(String gameId) async {
    final count = await (db.select(db.shotEvents)
      ..where((e) => e.gameId.equals(gameId))
      ..limit(1))
      .get();
    return count.isNotEmpty;
  }
}
