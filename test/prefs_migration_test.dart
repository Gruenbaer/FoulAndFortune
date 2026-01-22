import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/data/prefs_migration_service.dart';
import 'package:foulandfortune/models/achievement.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/services/player_service.dart' as player_service;
import 'package:foulandfortune/services/settings_service.dart';
import 'package:foulandfortune/data/outbox_service.dart';

void main() {
  group('Prefs migration', () {
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('migrates SharedPreferences data into the database', () async {
      final settings = GameSettings(
        raceToScore: 75,
        player1Name: 'Alice',
        player2Name: 'Bob',
        isTrainingMode: true,
        languageCode: 'en',
      );

      final players = [
        player_service.Player(
          id: 'p1',
          name: 'Alice',
          gamesPlayed: 3,
          gamesWon: 2,
          totalPoints: 120,
          totalInnings: 30,
          totalFouls: 4,
          totalSaves: 5,
          highestRun: 18,
        ),
        player_service.Player(
          id: 'p2',
          name: 'Bob',
          gamesPlayed: 2,
          gamesWon: 0,
          totalPoints: 50,
          totalInnings: 25,
          totalFouls: 6,
          totalSaves: 1,
          highestRun: 9,
        ),
      ];

      final game = GameRecord(
        id: 'g1',
        player1Name: 'Alice',
        player2Name: 'Bob',
        player1Score: 50,
        player2Score: 30,
        startTime: DateTime(2026, 1, 1, 10, 0, 0),
        endTime: DateTime(2026, 1, 1, 10, 45, 0),
        isCompleted: true,
        winner: 'Alice',
        raceToScore: 75,
        player1Innings: 12,
        player2Innings: 12,
        player1HighestRun: 14,
        player2HighestRun: 9,
        player1Fouls: 1,
        player2Fouls: 3,
        activeBalls: null,
        player1IsActive: null,
        snapshot: null,
      );

      final achievement = AchievementDefinitions.firstGame.copyWith(
        unlockedAt: DateTime(2026, 1, 1, 11, 0, 0),
        unlockedBy: ['Alice'],
      );

      SharedPreferences.setMockInitialValues({
        'game_settings': jsonEncode(settings.toJson()),
        'players': jsonEncode(players.map((p) => p.toJson()).toList()),
        'game_history': jsonEncode([game.toJson()]),
        'achievements': jsonEncode({'first_game': achievement.toJson()}),
      });

      final migration = PrefsMigrationService(db: db);
      await migration.migrateIfNeeded(deviceId: 'device-test');

      final settingsRow = await db.select(db.settings).getSingle();
      expect(settingsRow.raceToScore, 75);
      expect(settingsRow.player1Name, 'Alice');
      expect(settingsRow.player2Name, 'Bob');
      expect(settingsRow.isTrainingMode, true);

      final playerRows = await db.select(db.players).get();
      expect(playerRows.length, 2);
      final playerIds = playerRows.map((row) => row.id).toSet();
      expect(playerIds, containsAll(['p1', 'p2']));

      final gameRows = await db.select(db.games).get();
      expect(gameRows.length, 1);
      expect(gameRows.single.player1Id, 'p1');
      expect(gameRows.single.player2Id, 'p2');
      expect(gameRows.single.winner, 'Alice');

      final achievementRows = await db.select(db.achievements).get();
      expect(achievementRows.length, 1);
      expect(achievementRows.single.id, 'first_game');
      expect(achievementRows.single.unlockedBy, contains('Alice'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefsMigrationService.migrationKey), true);
    });

    test('skips migration when the database already has data', () async {
      final outbox = OutboxService(db: db);
      final settingsService = SettingsService(db: db, outbox: outbox);
      await settingsService.saveSettings(GameSettings(
        raceToScore: 99,
        player1Name: 'Seed',
        player2Name: 'Seed2',
      ));

      SharedPreferences.setMockInitialValues({
        'game_settings': jsonEncode(GameSettings(
          raceToScore: 50,
          player1Name: 'Alice',
          player2Name: 'Bob',
        ).toJson()),
        'players': jsonEncode([
          player_service.Player(id: 'p1', name: 'Alice').toJson(),
        ]),
      });

      final migration = PrefsMigrationService(db: db);
      await migration.migrateIfNeeded(deviceId: 'device-test');

      final playerRows = await db.select(db.players).get();
      expect(playerRows.length, 0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefsMigrationService.migrationKey), true);
    });
  });
}
