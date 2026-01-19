import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../data/device_id_service.dart';
import '../data/outbox_service.dart';

class Player {
  final String id;
  final String name;
  final DateTime createdAt;
  int gamesPlayed;
  int gamesWon;
  int totalPoints;
  int totalInnings;
  int totalFouls;
  int totalSaves;
  int highestRun;

  Player({
    required this.id,
    required this.name,
    DateTime? createdAt,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalPoints = 0,
    this.totalInnings = 0,
    this.totalFouls = 0,
    this.totalSaves = 0,
    this.highestRun = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'totalPoints': totalPoints,
        'totalInnings': totalInnings,
        'totalFouls': totalFouls,
        'totalSaves': totalSaves,
        'highestRun': highestRun,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        createdAt: DateTime.parse(json['createdAt']),
        gamesPlayed: json['gamesPlayed'] ?? 0,
        gamesWon: json['gamesWon'] ?? 0,
        totalPoints: json['totalPoints'] ?? 0,
        totalInnings: json['totalInnings'] ?? 0,
        totalFouls: json['totalFouls'] ?? 0,
        totalSaves: json['totalSaves'] ?? 0,
        highestRun: json['highestRun'] ?? 0,
      );

  Player copyWith({
    String? name,
    int? gamesPlayed,
    int? gamesWon,
    int? totalPoints,
    int? totalInnings,
    int? totalFouls,
    int? totalSaves,
    int? highestRun,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      totalPoints: totalPoints ?? this.totalPoints,
      totalInnings: totalInnings ?? this.totalInnings,
      totalFouls: totalFouls ?? this.totalFouls,
      totalSaves: totalSaves ?? this.totalSaves,
      highestRun: highestRun ?? this.highestRun,
    );
  }

  // Calculated statistics
  double get averagePointsPerGame =>
      gamesPlayed > 0 ? totalPoints / gamesPlayed : 0.0;
  
  // General Average (GD) / Points Per Inning
  double get generalAverage => 
      totalInnings > 0 ? totalPoints / totalInnings : 0.0;

  double get averageInningsPerGame =>
      gamesPlayed > 0 ? totalInnings / gamesPlayed : 0.0;

  double get averageFoulsPerGame =>
      gamesPlayed > 0 ? totalFouls / gamesPlayed : 0.0;

  double get winRate =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;
}

class PlayerService {
  PlayerService({AppDatabase? db, OutboxService? outbox})
      : _db = db ?? appDatabase,
        _outbox = outbox ?? OutboxService(db: db ?? appDatabase);

  final AppDatabase _db;
  final OutboxService _outbox;

  Future<List<Player>> getAllPlayers() async {
    final rows = await (_db.select(_db.players)
          ..where((player) => player.deletedAt.isNull())
          ..orderBy([(player) => OrderingTerm.desc(player.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<void> savePlayers(List<Player> players) async {
    for (final player in players) {
      await _upsertPlayer(player, recordOutbox: false);
    }
  }

  Future<Player> createPlayer(String name) async {
    final exists = await _getPlayerByName(name);
    if (exists != null) {
      throw Exception('Player with this name already exists');
    }

    final newPlayer = Player(
      id: const Uuid().v4(),
      name: name,
    );

    await _upsertPlayer(newPlayer, recordOutbox: true);
    return newPlayer;
  }

  Future<void> deletePlayer(String id) async {
    final existing = await (_db.select(_db.players)
          ..where((player) => player.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final revision = existing.revision + 1;
    final entry = PlayersCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      deviceId: Value(deviceId),
      revision: Value(revision),
    );
    await (_db.update(_db.players)..where((player) => player.id.equals(id)))
        .write(entry);

    await _outbox.record(
      entityType: 'player',
      entityId: id,
      operation: 'delete',
    );
  }

  Future<void> updatePlayer(Player player) async {
    await _upsertPlayer(player, recordOutbox: true);
  }

  Future<void> updatePlayerName(String id, String newName) async {
    final lowerName = newName.toLowerCase();
    final duplicate = await (_db.select(_db.players)
          ..where((player) =>
              player.name.lower().equals(lowerName) &
              player.id.equals(id).not() &
              player.deletedAt.isNull()))
        .getSingleOrNull();
    if (duplicate != null) {
      throw Exception('Player with this name already exists');
    }

    final existing = await (_db.select(_db.players)
          ..where((player) => player.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final revision = existing.revision + 1;
    final entry = PlayersCompanion(
      name: Value(newName),
      updatedAt: Value(now),
      deviceId: Value(deviceId),
      revision: Value(revision),
    );
    await (_db.update(_db.players)..where((player) => player.id.equals(id)))
        .write(entry);

    await _outbox.record(
      entityType: 'player',
      entityId: id,
      operation: 'upsert',
      payload: {
        'id': id,
        'name': newName,
      },
    );
  }

  Future<Player?> getPlayerByName(String name) async {
    return _getPlayerByName(name);
  }

  Future<Player?> _getPlayerByName(String name) async {
    final lowerName = name.toLowerCase();
    final row = await (_db.select(_db.players)
          ..where((player) =>
              player.name.lower().equals(lowerName) &
              player.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _fromRow(row);
  }

  Future<void> _upsertPlayer(Player player,
      {required bool recordOutbox}) async {
    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final existing = await (_db.select(_db.players)
          ..where((row) => row.id.equals(player.id)))
        .getSingleOrNull();
    final createdAt = existing?.createdAt ?? player.createdAt;
    final revision = (existing?.revision ?? 0) + 1;

    final entry = PlayersCompanion(
      id: Value(player.id),
      name: Value(player.name),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      deletedAt: const Value.absent(),
      deviceId: Value(deviceId),
      revision: Value(revision),
      gamesPlayed: Value(player.gamesPlayed),
      gamesWon: Value(player.gamesWon),
      totalPoints: Value(player.totalPoints),
      totalInnings: Value(player.totalInnings),
      totalFouls: Value(player.totalFouls),
      totalSaves: Value(player.totalSaves),
      highestRun: Value(player.highestRun),
    );

    if (existing == null) {
      await _db.into(_db.players).insert(entry);
    } else {
      await (_db.update(_db.players)
            ..where((row) => row.id.equals(player.id)))
          .write(entry);
    }

    if (recordOutbox) {
      await _outbox.record(
        entityType: 'player',
        entityId: player.id,
        operation: 'upsert',
        payload: player.toJson(),
      );
    }
  }

  Player _fromRow(PlayerRow row) {
    return Player(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      gamesPlayed: row.gamesPlayed,
      gamesWon: row.gamesWon,
      totalPoints: row.totalPoints,
      totalInnings: row.totalInnings,
      totalFouls: row.totalFouls,
      totalSaves: row.totalSaves,
      highestRun: row.highestRun,
    );
  }
}
