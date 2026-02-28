import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/data/outbox_service.dart';
import 'package:foulandfortune/models/achievement_manager.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';
import 'package:foulandfortune/services/settings_service.dart';

void main() {
  group('Database persistence', () {
    late AppDatabase db;
    late OutboxService outbox;
    late SettingsService settingsService;
    late PlayerService playerService;
    late GameHistoryService gameHistoryService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase();
      outbox = OutboxService(db: db);
      settingsService = SettingsService(db: db, outbox: outbox);
      playerService = PlayerService(db: db, outbox: outbox);
      gameHistoryService = GameHistoryService(db: db, outbox: outbox);
    });

    tearDown(() async {
      await db.close();
    });

    test('SettingsService saves and loads settings with outbox record', () async {
      final settings = GameSettings(
        raceToScore: 50,
        player1Name: 'Alice',
        player2Name: 'Bob',
        isTrainingMode: true,
        languageCode: 'en',
        themeId: 'steampunk',
      );

      await settingsService.saveSettings(settings);
      final loaded = await settingsService.loadSettings();

      expect(loaded.raceToScore, 50);
      expect(loaded.player1Name, 'Alice');
      expect(loaded.player2Name, 'Bob');
      expect(loaded.isTrainingMode, true);
      expect(loaded.languageCode, 'en');
      expect(loaded.themeId, 'steampunk');

      final row = await db.select(db.settings).getSingle();
      expect(row.revision, 1);

      final outboxRows = await db.select(db.syncOutbox).get();
      expect(outboxRows.length, 1);
      expect(outboxRows.single.entityType, 'settings');
      expect(outboxRows.single.operation, 'upsert');
      final payload = jsonDecode(outboxRows.single.payload!) as Map<String, dynamic>;
      expect(payload['raceToScore'], 50);
      expect(payload['isTrainingMode'], true);
    });

    test('PlayerService create/update/delete persists and records outbox', () async {
      final player = await playerService.createPlayer('Alice');
      final fetched = await playerService.getPlayerByName('Alice');
      expect(fetched, isNotNull);
      expect(fetched!.id, player.id);

      await playerService.updatePlayerName(player.id, 'Alice 2');
      final renamed = await playerService.getPlayerByName('Alice 2');
      expect(renamed, isNotNull);
      expect(renamed!.id, player.id);

      await playerService.deletePlayer(player.id);
      final deleted = await playerService.getPlayerByName('Alice 2');
      expect(deleted, isNull);

      final rows = await db.select(db.players).get();
      expect(rows.length, 1);
      expect(rows.single.deletedAt, isNotNull);

      final outboxRows = await db.select(db.syncOutbox).get();
      final deleteRows = outboxRows.where((row) =>
          row.entityType == 'player' && row.operation == 'delete');
      expect(deleteRows.length, 1);
    });

    test('GameHistoryService saves, filters, and preserves all history', () async {
      GameRecord buildGame({
        required String id,
        required DateTime startTime,
        bool isCompleted = false,
        bool isTrainingMode = false,
      }) {
        return GameRecord(
          id: id,
          player1Name: 'Alice',
          player2Name: 'Bob',
          player1Score: isCompleted ? 50 : 10,
          player2Score: isCompleted ? 30 : 5,
          startTime: startTime,
          endTime: isCompleted ? startTime.add(const Duration(minutes: 10)) : null,
          isCompleted: isCompleted,
          winner: isCompleted ? 'Alice' : null,
          raceToScore: 100,
          isTrainingMode: isTrainingMode,
          player1Innings: 10,
          player2Innings: 9,
          player1HighestRun: 12,
          player2HighestRun: 8,
          player1Fouls: 1,
          player2Fouls: 2,
          activeBalls: isCompleted ? null : [1, 2, 3],
          player1IsActive: isCompleted ? null : true,
          snapshot: isCompleted ? null : {'phase': 'live'},
        );
      }

      final now = DateTime(2026, 1, 1, 12, 0, 0);
      await gameHistoryService.saveGame(
        buildGame(
          id: 'active-1',
          startTime: now,
          isCompleted: false,
          isTrainingMode: true,
        ),
      );
      await gameHistoryService.saveGame(
        buildGame(id: 'done-1', startTime: now.add(const Duration(minutes: 5)), isCompleted: true),
      );

      final allGames = await gameHistoryService.getAllGames();
      expect(allGames.length, 2);

      final activeGames = await gameHistoryService.getActiveGames();
      expect(activeGames.length, 1);
      expect(activeGames.single.id, 'active-1');
      expect(activeGames.single.isTrainingMode, true);

      final completedGames = await gameHistoryService.getCompletedGames();
      expect(completedGames.length, 1);
      expect(completedGames.single.id, 'done-1');

      // No automatic cleanup: all games should be preserved.
      for (var i = 0; i < 101; i++) {
        await gameHistoryService.saveGame(
          buildGame(
            id: 'game-$i',
            startTime: now.add(Duration(minutes: 10 + i)),
            isCompleted: true,
          ),
        );
      }

      final rows = await db.select(db.games).get();
      expect(rows.length, 103);
      final preserved = await gameHistoryService.getGameById('game-0');
      expect(preserved, isNotNull);
      final newest = await gameHistoryService.getGameById('game-100');
      expect(newest, isNotNull);
    });

    test('AchievementManager unlock persists to db and outbox', () async {
      final manager = AchievementManager(db: db, outbox: outbox);
      await Future<void>.delayed(Duration.zero);

      await manager.unlock('first_game', playerName: 'Alice');

      final rows = await db.select(db.achievements).get();
      expect(rows.length, 1);
      expect(rows.single.id, 'first_game');
      expect(rows.single.unlockedBy, contains('Alice'));

      final outboxRows = await db.select(db.syncOutbox).get();
      final achievementRows = outboxRows.where((row) =>
          row.entityType == 'achievement' && row.operation == 'upsert');
      expect(achievementRows.length, 1);
    });
  });
}
