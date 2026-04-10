import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/models/achievement_manager.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/services/data_backup_service.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';
import 'package:foulandfortune/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataBackupService', () {
    late AppDatabase sourceDb;
    late AppDatabase targetDb;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sourceDb = AppDatabase(NativeDatabase.memory());
      targetDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await sourceDb.close();
      await targetDb.close();
    });

    test('exports and imports a full backup roundtrip', () async {
      final settingsService = SettingsService(db: sourceDb);
      final playerService = PlayerService(db: sourceDb);
      final historyService = GameHistoryService(db: sourceDb);
      final achievementManager = AchievementManager(db: sourceDb);

      await settingsService.saveSettings(
        GameSettings(
          player1Name: 'Emil',
          player2Name: 'Kai',
          raceToScore: 7,
          languageCode: 'de',
          themeId: 'cyberpunk',
          soundEnabled: false,
          isTrainingMode: false,
        ),
      );

      final emil = await playerService.createPlayer('Emil');
      await playerService.updatePlayer(
        emil.copyWith(
          gamesPlayed: 3,
          gamesWon: 2,
          totalPoints: 21,
          totalInnings: 15,
          totalFouls: 1,
          totalSaves: 4,
          highestRun: 12,
        ),
      );
      await playerService.createPlayer('Kai');

      await historyService.saveGame(
        GameRecord(
          id: 'game-1',
          player1Name: 'Emil',
          player2Name: 'Kai',
          player1Score: 7,
          player2Score: 5,
          startTime: DateTime.utc(2026, 4, 10, 10, 0),
          endTime: DateTime.utc(2026, 4, 10, 11, 0),
          isCompleted: true,
          winner: 'Emil',
          raceToScore: 7,
          player1Innings: 10,
          player2Innings: 9,
          player1HighestRun: 3,
          player2HighestRun: 2,
          player1Fouls: 0,
          player2Fouls: 1,
          snapshot: {
            'notation': '7-5',
            'mode': 'nineBall',
          },
        ),
      );

      await achievementManager.unlock('first_game', playerName: 'Emil');
      await sourceDb.into(sourceDb.shotEvents).insert(
            ShotEventsCompanion.insert(
              id: 'shot-1',
              gameId: 'game-1',
              playerId: emil.id,
              turnIndex: 0,
              shotIndex: 0,
              eventType: 'shot',
              payload: jsonEncode({
                'v': 1,
                'data': {'kind': 'break'},
              }),
              ts: DateTime.utc(2026, 4, 10, 10, 0, 5),
              createdAt: DateTime.utc(2026, 4, 10, 10, 0, 5),
            ),
          );
      await sourceDb.into(sourceDb.practiceDrillHistory).insert(
            PracticeDrillHistoryCompanion.insert(
              drillId: 'spot-shot',
              attempts: 12,
              successes: 8,
              timestamp: DateTime.utc(2026, 4, 9, 18, 30),
            ),
          );

      final backupService = DataBackupService(
        db: sourceDb,
        appVersionProvider: () async => 'test-version',
        now: () => DateTime.utc(2026, 4, 10, 12, 0),
      );

      final payload = await backupService.buildBackupPayload();

      expect(payload['format'], 'foul_and_fortune_backup');
      expect(payload['version'], DataBackupService.backupFormatVersion);

      final restoreService = DataBackupService(db: targetDb);
      final summary = await restoreService.importBackupPayload(payload);

      expect(summary.players, 2);
      expect(summary.games, 1);
      expect(summary.achievements, 1);
      expect(summary.shotEvents, 1);
      expect(summary.practiceDrillHistory, 1);
      expect(summary.settings.raceToScore, 7);
      expect(summary.settings.themeId, 'cyberpunk');

      final restoredPlayers = await PlayerService(db: targetDb).getAllPlayers();
      expect(restoredPlayers.map((player) => player.name), containsAll(['Emil', 'Kai']));
      expect(restoredPlayers.firstWhere((player) => player.name == 'Emil').highestRun, 12);

      final restoredGames = await GameHistoryService(db: targetDb).getAllGames();
      expect(restoredGames, hasLength(1));
      expect(restoredGames.single.snapshot?['notation'], '7-5');

      final restoredAchievements = await targetDb.select(targetDb.achievements).get();
      expect(restoredAchievements.single.id, 'first_game');

      final restoredShotEvents = await targetDb.select(targetDb.shotEvents).get();
      expect(restoredShotEvents.single.eventType, 'shot');
      expect(jsonDecode(restoredShotEvents.single.payload)['data']['kind'], 'break');

      final restoredPractice = await targetDb.select(targetDb.practiceDrillHistory).get();
      expect(restoredPractice.single.drillId, 'spot-shot');

      final outboxRows = await targetDb.select(targetDb.syncOutbox).get();
      expect(outboxRows, isEmpty);
    });

    test('rejects unsupported backup versions', () async {
      final backupService = DataBackupService(db: targetDb);

      await expectLater(
        backupService.importBackupPayload({
          'format': 'foul_and_fortune_backup',
          'version': 999,
          'data': <String, dynamic>{},
        }),
        throwsA(
          isA<DataBackupException>().having(
            (error) => error.message,
            'message',
            contains('nicht unterstuetzt'),
          ),
        ),
      );
    });
  });
}
