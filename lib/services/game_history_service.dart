import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_database.dart';
import '../data/device_id_service.dart';
import '../data/outbox_service.dart';
import '../models/game_record.dart';

class GameHistoryService {
  static const String _migrationKey = 'notation_v2_migrated';
  static const int _maxGames = 100;

  GameHistoryService({AppDatabase? db, OutboxService? outbox})
      : _db = db ?? appDatabase,
        _outbox = outbox ?? OutboxService(db: db ?? appDatabase);

  final AppDatabase _db;
  final OutboxService _outbox;

  Future<bool> isMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  Future<void> markMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationKey, true);
  }

  Future<int> migrateNotation() async {
    await markMigrated();
    return 0;
  }

  Future<List<GameRecord>> getAllGames() async {
    final rows = await (_db.select(_db.games)
          ..where((game) => game.deletedAt.isNull())
          ..orderBy([(game) => OrderingTerm.desc(game.startTime)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<GameRecord>> getActiveGames() async {
    final rows = await (_db.select(_db.games)
          ..where((game) =>
              game.isCompleted.equals(false) & game.deletedAt.isNull())
          ..orderBy([(game) => OrderingTerm.desc(game.startTime)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<GameRecord>> getCompletedGames() async {
    final rows = await (_db.select(_db.games)
          ..where(
              (game) => game.isCompleted.equals(true) & game.deletedAt.isNull())
          ..orderBy([(game) => OrderingTerm.desc(game.startTime)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<void> saveGame(GameRecord game) async {
    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final existing = await (_db.select(_db.games)
          ..where((row) => row.id.equals(game.id)))
        .getSingleOrNull();
    final createdAt = existing?.createdAt ?? now;
    final revision = (existing?.revision ?? 0) + 1;
    final player1Id =
        existing?.player1Id ?? await _findPlayerIdByName(game.player1Name);
    final player2Id =
        existing?.player2Id ?? await _findPlayerIdByName(game.player2Name);

    final entry = GamesCompanion(
      id: Value(game.id),
      player1Id: Value(player1Id),
      player2Id: Value(player2Id),
      player1Name: Value(game.player1Name),
      player2Name: Value(game.player2Name),
      player1Score: Value(game.player1Score),
      player2Score: Value(game.player2Score),
      startTime: Value(game.startTime),
      endTime: Value(game.endTime),
      isCompleted: Value(game.isCompleted),
      winner: Value(game.winner),
      raceToScore: Value(game.raceToScore),
      player1Innings: Value(game.player1Innings),
      player2Innings: Value(game.player2Innings),
      player1HighestRun: Value(game.player1HighestRun),
      player2HighestRun: Value(game.player2HighestRun),
      player1Fouls: Value(game.player1Fouls),
      player2Fouls: Value(game.player2Fouls),
      activeBalls: Value(game.activeBalls),
      player1IsActive: Value(game.player1IsActive),
      snapshot: Value(game.snapshot),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      deletedAt: const Value.absent(),
      deviceId: Value(deviceId),
      revision: Value(revision),
    );

    if (existing == null) {
      await _db.into(_db.games).insert(entry);
    } else {
      await (_db.update(_db.games)..where((row) => row.id.equals(game.id)))
          .write(entry);
    }

    await _cleanup();
    await _outbox.record(
      entityType: 'game',
      entityId: game.id,
      operation: 'upsert',
      payload: _gamePayload(game,
          player1Id: player1Id, player2Id: player2Id),
    );
  }

  Future<void> deleteGame(String id) async {
    final now = DateTime.now();
    final deleted = await (_db.delete(_db.games)
          ..where((row) => row.id.equals(id)))
        .go();
    if (deleted == 0) {
      return;
    }
    await _outbox.record(
      entityType: 'game',
      entityId: id,
      operation: 'delete',
      payload: {'deletedAt': now.toIso8601String()},
    );
  }

  Future<void> clearAllHistory() async {
    final rows = await (_db.select(_db.games)).get();
    if (rows.isEmpty) {
      return;
    }

    await _db.delete(_db.games).go();
    final now = DateTime.now();
    for (final row in rows) {
      await _outbox.record(
        entityType: 'game',
        entityId: row.id,
        operation: 'delete',
        payload: {'deletedAt': now.toIso8601String()},
      );
    }
  }

  Future<GameRecord?> getGameById(String id) async {
    final row = await (_db.select(_db.games)
          ..where((game) =>
              game.id.equals(id) & game.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<Map<String, dynamic>> getStatsSummary() async {
    final games = await getCompletedGames();
    if (games.isEmpty) {
      return {
        'totalGames': 0,
        'totalDuration': Duration.zero,
        'averageDuration': Duration.zero,
      };
    }

    final totalDuration = games.fold<Duration>(
      Duration.zero,
      (sum, game) => sum + game.getDuration(),
    );

    return {
      'totalGames': games.length,
      'totalDuration': totalDuration,
      'averageDuration': Duration(
        milliseconds: totalDuration.inMilliseconds ~/ games.length,
      ),
    };
  }

  GameRecord _fromRow(GameRow row) {
    return GameRecord(
      id: row.id,
      player1Name: row.player1Name,
      player2Name: row.player2Name,
      player1Score: row.player1Score,
      player2Score: row.player2Score,
      startTime: row.startTime,
      endTime: row.endTime,
      isCompleted: row.isCompleted,
      winner: row.winner,
      raceToScore: row.raceToScore,
      player1Innings: row.player1Innings,
      player2Innings: row.player2Innings,
      player1HighestRun: row.player1HighestRun,
      player2HighestRun: row.player2HighestRun,
      player1Fouls: row.player1Fouls,
      player2Fouls: row.player2Fouls,
      activeBalls: row.activeBalls,
      player1IsActive: row.player1IsActive,
      snapshot: row.snapshot,
    );
  }

  Future<void> _cleanup() async {
    final rows = await (_db.select(_db.games)
          ..where((game) => game.deletedAt.isNull())
          ..orderBy([(game) => OrderingTerm.desc(game.startTime)]))
        .get();
    if (rows.length <= _maxGames) {
      return;
    }

    final toRemove = rows.sublist(_maxGames);
    for (final row in toRemove) {
      await _db.delete(_db.games).delete(row);
      await _outbox.record(
        entityType: 'game',
        entityId: row.id,
        operation: 'delete',
        payload: {'deletedAt': DateTime.now().toIso8601String()},
      );
    }
  }

  Future<String?> _findPlayerIdByName(String name) async {
    final lowerName = name.toLowerCase();
    final row = await (_db.select(_db.players)
          ..where((player) =>
              player.name.lower().equals(lowerName) &
              player.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.id;
  }

  Map<String, dynamic> _gamePayload(GameRecord game,
      {String? player1Id, String? player2Id}) {
    final payload = Map<String, dynamic>.from(game.toJson());
    if (player1Id != null) {
      payload['player1Id'] = player1Id;
    }
    if (player2Id != null) {
      payload['player2Id'] = player2Id;
    }
    return payload;
  }
}
