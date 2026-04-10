import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/app_database.dart';
import '../models/game_settings.dart';
import 'settings_service.dart';

class DataBackupException implements Exception {
  final String message;

  const DataBackupException(this.message);

  @override
  String toString() => message;
}

class DataBackupFileResult {
  final File file;
  final Map<String, dynamic> manifest;

  const DataBackupFileResult({
    required this.file,
    required this.manifest,
  });
}

class DataImportSummary {
  final int players;
  final int games;
  final int achievements;
  final int shotEvents;
  final int practiceDrillHistory;
  final GameSettings settings;

  const DataImportSummary({
    required this.players,
    required this.games,
    required this.achievements,
    required this.shotEvents,
    required this.practiceDrillHistory,
    required this.settings,
  });
}

class DataBackupService {
  static const int backupFormatVersion = 1;

  DataBackupService({
    AppDatabase? db,
    Future<String> Function()? appVersionProvider,
    DateTime Function()? now,
  })  : _db = db ?? appDatabase,
        _appVersionProvider = appVersionProvider,
        _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Future<String> Function()? _appVersionProvider;
  final DateTime Function() _now;

  Future<DataBackupFileResult> createBackupFile() async {
    final payload = await buildBackupPayload();
    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    final directory = await getTemporaryDirectory();
    final timestamp = _fileTimestamp(_now());
    final file = File(
      p.join(directory.path, 'foul-and-fortune-backup-$timestamp.json'),
    );
    await file.writeAsString(jsonString);
    return DataBackupFileResult(file: file, manifest: payload);
  }

  Future<Map<String, dynamic>> buildBackupPayload() async {
    final settingsRow = await (_db.select(_db.settings)
          ..where((row) => row.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    final players = await (_db.select(_db.players)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
    final games = await (_db.select(_db.games)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.startTime)]))
        .get();
    final achievements = await (_db.select(_db.achievements)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
    final shotEvents = await (_db.select(_db.shotEvents)
          ..orderBy([
            (row) => OrderingTerm.asc(row.gameId),
            (row) => OrderingTerm.asc(row.turnIndex),
            (row) => OrderingTerm.asc(row.shotIndex),
          ]))
        .get();
    final practiceHistory = await (_db.select(_db.practiceDrillHistory)
          ..orderBy([(row) => OrderingTerm.asc(row.timestamp)]))
        .get();

    final appVersion = await _resolveAppVersion();
    final exportedAt = _now().toUtc().toIso8601String();

    return {
      'format': 'foul_and_fortune_backup',
      'version': backupFormatVersion,
      'schemaVersion': _db.schemaVersion,
      'appVersion': appVersion,
      'exportedAt': exportedAt,
      'data': {
        'settings': settingsRow == null ? null : _settingsToJson(settingsRow),
        'players': players.map(_playerToJson).toList(growable: false),
        'games': games.map(_gameToJson).toList(growable: false),
        'achievements':
            achievements.map(_achievementToJson).toList(growable: false),
        'shotEvents': shotEvents.map(_shotEventToJson).toList(growable: false),
        'practiceDrillHistory':
            practiceHistory.map(_practiceRowToJson).toList(growable: false),
      },
    };
  }

  Future<DataImportSummary> importBackupFile(File file) async {
    final content = await file.readAsString();
    return importBackupJson(content);
  }

  Future<DataImportSummary> importBackupJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const DataBackupException('Backup-Datei hat kein gueltiges Format.');
    }
    return importBackupPayload(decoded);
  }

  Future<DataImportSummary> importBackupPayload(Map<String, dynamic> payload) async {
    if (payload['format'] != 'foul_and_fortune_backup') {
      throw const DataBackupException('Unbekanntes Backup-Format.');
    }

    final version = payload['version'];
    if (version is! int || version != backupFormatVersion) {
      throw DataBackupException(
        'Backup-Version $version wird von dieser App nicht unterstuetzt.',
      );
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const DataBackupException('Backup enthaelt keinen gueltigen Datenblock.');
    }

    final settingsMap = _optionalMap(data['settings']);
    final players = _mapList(data['players']);
    final games = _mapList(data['games']);
    final achievements = _mapList(data['achievements']);
    final shotEvents = _mapList(data['shotEvents']);
    final practiceHistory = _mapList(data['practiceDrillHistory']);

    await _db.transaction(() async {
      await _db.delete(_db.shotEvents).go();
      await _db.delete(_db.practiceDrillHistory).go();
      await _db.delete(_db.games).go();
      await _db.delete(_db.players).go();
      await _db.delete(_db.achievements).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.syncOutbox).go();
      await _db.delete(_db.syncState).go();

      if (settingsMap != null) {
        await _db.into(_db.settings).insert(_settingsCompanion(settingsMap));
      }

      if (players.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.players,
            players.map(_playerCompanion).toList(growable: false),
          );
        });
      }

      if (games.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.games,
            games.map(_gameCompanion).toList(growable: false),
          );
        });
      }

      if (achievements.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.achievements,
            achievements.map(_achievementCompanion).toList(growable: false),
          );
        });
      }

      if (shotEvents.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.shotEvents,
            shotEvents.map(_shotEventCompanion).toList(growable: false),
          );
        });
      }

      if (practiceHistory.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.practiceDrillHistory,
            practiceHistory.map(_practiceCompanion).toList(growable: false),
          );
        });
      }
    });

    final settings = await SettingsService(db: _db).loadSettings();
    return DataImportSummary(
      players: players.length,
      games: games.length,
      achievements: achievements.length,
      shotEvents: shotEvents.length,
      practiceDrillHistory: practiceHistory.length,
      settings: settings,
    );
  }

  Map<String, dynamic> _settingsToJson(SettingsRow row) => {
        'id': row.id,
        'threeFoulRuleEnabled': row.threeFoulRuleEnabled,
        'raceToScore': row.raceToScore,
        'player1Name': row.player1Name,
        'player2Name': row.player2Name,
        'isTrainingMode': row.isTrainingMode,
        'isLeagueGame': row.isLeagueGame,
        'player1Handicap': row.player1Handicap,
        'player2Handicap': row.player2Handicap,
        'player1HandicapMultiplier': row.player1HandicapMultiplier,
        'player2HandicapMultiplier': row.player2HandicapMultiplier,
        'maxInnings': row.maxInnings,
        'soundEnabled': row.soundEnabled,
        'languageCode': row.languageCode,
        'isDarkTheme': row.isDarkTheme,
        'themeId': row.themeId,
        'hasSeenBreakFoulRules': row.hasSeenBreakFoulRules,
        'hasShown2FoulWarning': row.hasShown2FoulWarning,
        'hasShown3FoulWarning': row.hasShown3FoulWarning,
        'createdAt': row.createdAt.toIso8601String(),
        'updatedAt': row.updatedAt.toIso8601String(),
        'deletedAt': row.deletedAt?.toIso8601String(),
        'deviceId': row.deviceId,
        'revision': row.revision,
      };

  Map<String, dynamic> _playerToJson(PlayerRow row) => {
        'id': row.id,
        'name': row.name,
        'createdAt': row.createdAt.toIso8601String(),
        'updatedAt': row.updatedAt.toIso8601String(),
        'deletedAt': row.deletedAt?.toIso8601String(),
        'deviceId': row.deviceId,
        'revision': row.revision,
        'gamesPlayed': row.gamesPlayed,
        'gamesWon': row.gamesWon,
        'totalPoints': row.totalPoints,
        'totalInnings': row.totalInnings,
        'totalFouls': row.totalFouls,
        'totalSaves': row.totalSaves,
        'highestRun': row.highestRun,
      };

  Map<String, dynamic> _gameToJson(GameRow row) => {
        'id': row.id,
        'player1Id': row.player1Id,
        'player2Id': row.player2Id,
        'player1Name': row.player1Name,
        'player2Name': row.player2Name,
        'isTrainingMode': row.isTrainingMode,
        'player1Score': row.player1Score,
        'player2Score': row.player2Score,
        'startTime': row.startTime.toIso8601String(),
        'endTime': row.endTime?.toIso8601String(),
        'isCompleted': row.isCompleted,
        'winner': row.winner,
        'raceToScore': row.raceToScore,
        'player1Innings': row.player1Innings,
        'player2Innings': row.player2Innings,
        'player1HighestRun': row.player1HighestRun,
        'player2HighestRun': row.player2HighestRun,
        'player1Fouls': row.player1Fouls,
        'player2Fouls': row.player2Fouls,
        'activeBalls': row.activeBalls,
        'player1IsActive': row.player1IsActive,
        'snapshot': row.snapshot,
        'createdAt': row.createdAt.toIso8601String(),
        'updatedAt': row.updatedAt.toIso8601String(),
        'deletedAt': row.deletedAt?.toIso8601String(),
        'deviceId': row.deviceId,
        'revision': row.revision,
      };

  Map<String, dynamic> _achievementToJson(AchievementRow row) => {
        'id': row.id,
        'unlockedAt': row.unlockedAt?.toIso8601String(),
        'unlockedBy': row.unlockedBy,
        'createdAt': row.createdAt.toIso8601String(),
        'updatedAt': row.updatedAt.toIso8601String(),
        'deletedAt': row.deletedAt?.toIso8601String(),
        'deviceId': row.deviceId,
        'revision': row.revision,
      };

  Map<String, dynamic> _shotEventToJson(ShotEventRow row) => {
        'id': row.id,
        'gameId': row.gameId,
        'playerId': row.playerId,
        'turnIndex': row.turnIndex,
        'shotIndex': row.shotIndex,
        'eventType': row.eventType,
        'payload': _decodeJsonField(row.payload),
        'ts': row.ts.toIso8601String(),
        'createdAt': row.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _practiceRowToJson(PracticeDrillHistoryRow row) => {
        'id': row.id,
        'drillId': row.drillId,
        'attempts': row.attempts,
        'successes': row.successes,
        'timestamp': row.timestamp.toIso8601String(),
      };

  SettingsCompanion _settingsCompanion(Map<String, dynamic> json) => SettingsCompanion(
        id: Value(json['id'] as String? ?? 'default'),
        threeFoulRuleEnabled: Value(json['threeFoulRuleEnabled'] as bool? ?? true),
        raceToScore: Value(json['raceToScore'] as int? ?? 100),
        player1Name: Value(json['player1Name'] as String? ?? 'Player 1'),
        player2Name: Value(json['player2Name'] as String? ?? 'Player 2'),
        isTrainingMode: Value(json['isTrainingMode'] as bool? ?? false),
        isLeagueGame: Value(json['isLeagueGame'] as bool? ?? false),
        player1Handicap: Value(json['player1Handicap'] as int? ?? 0),
        player2Handicap: Value(json['player2Handicap'] as int? ?? 0),
        player1HandicapMultiplier:
            Value((json['player1HandicapMultiplier'] as num? ?? 1).toDouble()),
        player2HandicapMultiplier:
            Value((json['player2HandicapMultiplier'] as num? ?? 1).toDouble()),
        maxInnings: Value(json['maxInnings'] as int? ?? 30),
        soundEnabled: Value(json['soundEnabled'] as bool? ?? true),
        languageCode: Value(json['languageCode'] as String? ?? 'de'),
        isDarkTheme: Value(json['isDarkTheme'] as bool? ?? true),
        themeId: Value(json['themeId'] as String? ?? 'steampunk'),
        hasSeenBreakFoulRules:
            Value(json['hasSeenBreakFoulRules'] as bool? ?? false),
        hasShown2FoulWarning:
            Value(json['hasShown2FoulWarning'] as bool? ?? false),
        hasShown3FoulWarning:
            Value(json['hasShown3FoulWarning'] as bool? ?? false),
        createdAt: Value(_dateTime(json['createdAt'])),
        updatedAt: Value(_dateTime(json['updatedAt'])),
        deletedAt: Value.absentIfNull(_nullableDateTime(json['deletedAt'])),
        deviceId: Value.absentIfNull(json['deviceId'] as String?),
        revision: Value(json['revision'] as int? ?? 1),
      );

  PlayersCompanion _playerCompanion(Map<String, dynamic> json) => PlayersCompanion(
        id: Value(json['id'] as String),
        name: Value(json['name'] as String),
        createdAt: Value(_dateTime(json['createdAt'])),
        updatedAt: Value(_dateTime(json['updatedAt'])),
        deletedAt: Value.absentIfNull(_nullableDateTime(json['deletedAt'])),
        deviceId: Value.absentIfNull(json['deviceId'] as String?),
        revision: Value(json['revision'] as int? ?? 1),
        gamesPlayed: Value(json['gamesPlayed'] as int? ?? 0),
        gamesWon: Value(json['gamesWon'] as int? ?? 0),
        totalPoints: Value(json['totalPoints'] as int? ?? 0),
        totalInnings: Value(json['totalInnings'] as int? ?? 0),
        totalFouls: Value(json['totalFouls'] as int? ?? 0),
        totalSaves: Value(json['totalSaves'] as int? ?? 0),
        highestRun: Value(json['highestRun'] as int? ?? 0),
      );

  GamesCompanion _gameCompanion(Map<String, dynamic> json) => GamesCompanion(
        id: Value(json['id'] as String),
        player1Id: Value.absentIfNull(json['player1Id'] as String?),
        player2Id: Value.absentIfNull(json['player2Id'] as String?),
        player1Name: Value(json['player1Name'] as String),
        player2Name: Value(json['player2Name'] as String),
        isTrainingMode: Value(json['isTrainingMode'] as bool? ?? false),
        player1Score: Value(json['player1Score'] as int? ?? 0),
        player2Score: Value(json['player2Score'] as int? ?? 0),
        startTime: Value(_dateTime(json['startTime'])),
        endTime: Value.absentIfNull(_nullableDateTime(json['endTime'])),
        isCompleted: Value(json['isCompleted'] as bool? ?? false),
        winner: Value.absentIfNull(json['winner'] as String?),
        raceToScore: Value(json['raceToScore'] as int? ?? 0),
        player1Innings: Value(json['player1Innings'] as int? ?? 0),
        player2Innings: Value(json['player2Innings'] as int? ?? 0),
        player1HighestRun: Value(json['player1HighestRun'] as int? ?? 0),
        player2HighestRun: Value(json['player2HighestRun'] as int? ?? 0),
        player1Fouls: Value(json['player1Fouls'] as int? ?? 0),
        player2Fouls: Value(json['player2Fouls'] as int? ?? 0),
        activeBalls:
            Value.absentIfNull((json['activeBalls'] as List<dynamic>?)?.cast<int>()),
        player1IsActive: Value.absentIfNull(json['player1IsActive'] as bool?),
        snapshot:
            Value.absentIfNull(_optionalMap(json['snapshot'])),
        createdAt: Value(_dateTime(json['createdAt'])),
        updatedAt: Value(_dateTime(json['updatedAt'])),
        deletedAt: Value.absentIfNull(_nullableDateTime(json['deletedAt'])),
        deviceId: Value.absentIfNull(json['deviceId'] as String?),
        revision: Value(json['revision'] as int? ?? 1),
      );

  AchievementsCompanion _achievementCompanion(Map<String, dynamic> json) =>
      AchievementsCompanion(
        id: Value(json['id'] as String),
        unlockedAt:
            Value.absentIfNull(_nullableDateTime(json['unlockedAt'])),
        unlockedBy: Value.absentIfNull(
          (json['unlockedBy'] as List<dynamic>?)?.cast<String>(),
        ),
        createdAt: Value(_dateTime(json['createdAt'])),
        updatedAt: Value(_dateTime(json['updatedAt'])),
        deletedAt: Value.absentIfNull(_nullableDateTime(json['deletedAt'])),
        deviceId: Value.absentIfNull(json['deviceId'] as String?),
        revision: Value(json['revision'] as int? ?? 1),
      );

  ShotEventsCompanion _shotEventCompanion(Map<String, dynamic> json) =>
      ShotEventsCompanion(
        id: Value(json['id'] as String),
        gameId: Value(json['gameId'] as String),
        playerId: Value(json['playerId'] as String),
        turnIndex: Value(json['turnIndex'] as int? ?? 0),
        shotIndex: Value(json['shotIndex'] as int? ?? 0),
        eventType: Value(json['eventType'] as String),
        payload: Value(jsonEncode(json['payload'])),
        ts: Value(_dateTime(json['ts'])),
        createdAt: Value(_dateTime(json['createdAt'])),
      );

  PracticeDrillHistoryCompanion _practiceCompanion(Map<String, dynamic> json) =>
      PracticeDrillHistoryCompanion(
        id: Value(json['id'] as int),
        drillId: Value(json['drillId'] as String),
        attempts: Value(json['attempts'] as int? ?? 0),
        successes: Value(json['successes'] as int? ?? 0),
        timestamp: Value(_dateTime(json['timestamp'])),
      );

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value == null) {
      return const [];
    }
    if (value is! List) {
      throw const DataBackupException('Backup-Daten sind unvollstaendig.');
    }
    return value
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const DataBackupException('Backup-Daten enthalten ungueltige Eintraege.');
          }
          return entry;
        })
        .toList(growable: false);
  }

  Map<String, dynamic>? _optionalMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const DataBackupException('Backup enthaelt einen ungueltigen Objektblock.');
  }

  DateTime _dateTime(dynamic value) {
    if (value is! String) {
      throw const DataBackupException('Backup enthaelt ein ungueltiges Datum.');
    }
    return DateTime.parse(value);
  }

  DateTime? _nullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return _dateTime(value);
  }

  dynamic _decodeJsonField(String payload) {
    try {
      return jsonDecode(payload);
    } catch (_) {
      return payload;
    }
  }

  Future<String> _resolveAppVersion() async {
    if (_appVersionProvider != null) {
      return _appVersionProvider!();
    }
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  String _fileTimestamp(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${local.year}${two(local.month)}${two(local.day)}-'
        '${two(local.hour)}${two(local.minute)}${two(local.second)}';
  }
}
