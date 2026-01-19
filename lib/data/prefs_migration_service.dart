import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/game_record.dart';
import '../models/game_settings.dart';
import '../services/player_service.dart';
import 'app_database.dart';

class PrefsMigrationService {
  PrefsMigrationService({AppDatabase? db}) : _db = db ?? appDatabase;

  static const String migrationKey = 'db_migration_v1';
  static const int _maxGames = 100;
  static const String _playersKey = 'players';
  static const String _settingsKey = 'game_settings';
  static const String _historyKey = 'game_history';
  static const String _achievementsKey = 'achievements';

  final AppDatabase _db;

  Future<void> migrateIfNeeded({required String deviceId}) async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(migrationKey) ?? false;
    if (migrated) {
      return;
    }

    final hasData = await _databaseHasData();
    if (hasData) {
      await prefs.setBool(migrationKey, true);
      return;
    }

    final settings = _loadSettings(prefs);
    await _insertSettings(settings, deviceId: deviceId);

    final players = _loadPlayers(prefs);
    final playerIdByName =
        await _insertPlayers(players, deviceId: deviceId);

    final games = _loadGames(prefs);
    await _insertGames(
      games,
      playerIdByName: playerIdByName,
      deviceId: deviceId,
    );

    final achievements = _loadAchievements(prefs);
    await _insertAchievements(achievements, deviceId: deviceId);

    await prefs.setBool(migrationKey, true);
  }

  Future<bool> _databaseHasData() async {
    final hasPlayers =
        (await (_db.select(_db.players)..limit(1)).get()).isNotEmpty;
    final hasGames =
        (await (_db.select(_db.games)..limit(1)).get()).isNotEmpty;
    final hasSettings =
        (await (_db.select(_db.settings)..limit(1)).get()).isNotEmpty;
    final hasAchievements =
        (await (_db.select(_db.achievements)..limit(1)).get()).isNotEmpty;
    return hasPlayers || hasGames || hasSettings || hasAchievements;
  }

  GameSettings _loadSettings(SharedPreferences prefs) {
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null) {
      return GameSettings();
    }
    try {
      final json = jsonDecode(jsonString);
      return GameSettings.fromJson(json);
    } catch (_) {
      return GameSettings();
    }
  }

  List<Player> _loadPlayers(SharedPreferences prefs) {
    final jsonString = prefs.getString(_playersKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((json) => Player.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<GameRecord> _loadGames(SharedPreferences prefs) {
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((json) => GameRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Achievement> _loadAchievements(SharedPreferences prefs) {
    final jsonString = prefs.getString(_achievementsKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.values
          .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _insertSettings(
    GameSettings settings, {
    required String deviceId,
  }) async {
    final now = DateTime.now();
    final entry = SettingsCompanion(
      id: const Value('default'),
      threeFoulRuleEnabled: Value(settings.threeFoulRuleEnabled),
      raceToScore: Value(settings.raceToScore),
      player1Name: Value(settings.player1Name),
      player2Name: Value(settings.player2Name),
      isLeagueGame: Value(settings.isLeagueGame),
      player1Handicap: Value(settings.player1Handicap),
      player2Handicap: Value(settings.player2Handicap),
      player1HandicapMultiplier:
          Value(settings.player1HandicapMultiplier),
      player2HandicapMultiplier:
          Value(settings.player2HandicapMultiplier),
      maxInnings: Value(settings.maxInnings),
      soundEnabled: Value(settings.soundEnabled),
      languageCode: Value(settings.languageCode),
      isDarkTheme: Value(settings.isDarkTheme),
      themeId: Value(settings.themeId),
      hasSeenBreakFoulRules: Value(settings.hasSeenBreakFoulRules),
      hasShown2FoulWarning: Value(settings.hasShown2FoulWarning),
      hasShown3FoulWarning: Value(settings.hasShown3FoulWarning),
      createdAt: Value(now),
      updatedAt: Value(now),
      deletedAt: const Value.absent(),
      deviceId: Value(deviceId),
      revision: const Value(1),
    );
    await _db.into(_db.settings).insert(entry);
  }

  Future<Map<String, String>> _insertPlayers(
    List<Player> players, {
    required String deviceId,
  }) async {
    if (players.isEmpty) {
      return {};
    }
    final entries = players.map((player) {
      return PlayersCompanion(
        id: Value(player.id),
        name: Value(player.name),
        createdAt: Value(player.createdAt),
        updatedAt: Value(player.createdAt),
        deletedAt: const Value.absent(),
        deviceId: Value(deviceId),
        revision: const Value(1),
        gamesPlayed: Value(player.gamesPlayed),
        gamesWon: Value(player.gamesWon),
        totalPoints: Value(player.totalPoints),
        totalInnings: Value(player.totalInnings),
        totalFouls: Value(player.totalFouls),
        totalSaves: Value(player.totalSaves),
        highestRun: Value(player.highestRun),
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAll(_db.players, entries);
    });

    final playerIdByName = <String, String>{};
    for (final player in players) {
      playerIdByName[player.name.toLowerCase()] = player.id;
    }
    return playerIdByName;
  }

  Future<void> _insertGames(
    List<GameRecord> games, {
    required Map<String, String> playerIdByName,
    required String deviceId,
  }) async {
    if (games.isEmpty) {
      return;
    }

    final entries = games.map((game) {
      final player1Id = playerIdByName[game.player1Name.toLowerCase()];
      final player2Id = playerIdByName[game.player2Name.toLowerCase()];
      final createdAt = game.startTime;
      final updatedAt = game.endTime ?? game.startTime;
      return GamesCompanion(
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
        updatedAt: Value(updatedAt),
        deletedAt: const Value.absent(),
        deviceId: Value(deviceId),
        revision: const Value(1),
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAll(_db.games, entries);
    });

    await _cleanupGames();
  }

  Future<void> _insertAchievements(
    List<Achievement> achievements, {
    required String deviceId,
  }) async {
    if (achievements.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final entries = achievements.map((achievement) {
      final createdAt = achievement.unlockedAt ?? now;
      return AchievementsCompanion(
        id: Value(achievement.id),
        unlockedAt: Value(achievement.unlockedAt),
        unlockedBy: Value(achievement.unlockedBy),
        createdAt: Value(createdAt),
        updatedAt: Value(achievement.unlockedAt ?? createdAt),
        deletedAt: const Value.absent(),
        deviceId: Value(deviceId),
        revision: const Value(1),
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAll(_db.achievements, entries);
    });
  }

  Future<void> _cleanupGames() async {
    final rows = await (_db.select(_db.games)
          ..where((game) => game.deletedAt.isNull())
          ..orderBy([(game) => OrderingTerm.desc(game.startTime)]))
        .get();
    if (rows.length <= _maxGames) {
      return;
    }

    final toRemove = rows.sublist(_maxGames);
    await _db.batch((batch) {
      for (final row in toRemove) {
        batch.delete(_db.games, row);
      }
    });
  }
}
