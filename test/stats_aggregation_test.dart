import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/data/outbox_service.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';

void main() {
  group('Stats Aggregation (PlayerService)', () {
    late AppDatabase db;
    late OutboxService outbox;
    late PlayerService playerService;
    late GameHistoryService gameHistoryService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase();
      outbox = OutboxService(db: db);
      playerService = PlayerService(db: db, outbox: outbox);
      gameHistoryService = GameHistoryService(db: db, outbox: outbox);
    });

    tearDown(() async {
      await db.close();
    });

    GameRecord buildGame({
      required String id,
      required DateTime startTime,
      required String p1Name,
      required String p2Name,
      required int p1Score,
      required int p1Innings,
      required int p1HR,
      bool isCompleted = true,
    }) {
      return GameRecord(
        id: id,
        player1Name: p1Name,
        player2Name: p2Name,
        player1Score: p1Score,
        player2Score: 0,
        startTime: startTime,
        endTime: isCompleted ? startTime.add(const Duration(minutes: 10)) : null,
        isCompleted: isCompleted,
        winner: p1Score > 0 ? p1Name : p2Name,
        raceToScore: 50,
        isTrainingMode: false,
        player1Innings: p1Innings,
        player2Innings: 0,
        player1HighestRun: p1HR,
        player2HighestRun: 0,
        player1Fouls: 0,
        player2Fouls: 0,
        activeBalls: null,
        player1IsActive: null,
        snapshot: null,
      );
    }

    test('getPlayerTrends handles general BPI and High Run correctly', () async {
      final p1 = await playerService.createPlayer('Alice');
      final p2 = await playerService.createPlayer('Bob');

      // Game 1: 50 points in 10 innings = 5.0 BPI, HR 15
      await gameHistoryService.saveGame(buildGame(
        id: 'g1',
        startTime: DateTime(2026, 1, 1),
        p1Name: p1.name,
        p2Name: p2.name,
        p1Score: 50,
        p1Innings: 10,
        p1HR: 15,
      ));

      // Game 2: 25 points in 10 innings = 2.5 BPI, HR 5
      await gameHistoryService.saveGame(buildGame(
        id: 'g2',
        startTime: DateTime(2026, 1, 2),
        p1Name: p1.name,
        p2Name: p2.name,
        p1Score: 25,
        p1Innings: 10,
        p1HR: 5,
      ));

      // Game 3: 0 points in 5 innings = 0 BPI, HR 0
      await gameHistoryService.saveGame(buildGame(
        id: 'g3',
        startTime: DateTime(2026, 1, 3),
        p1Name: p1.name,
        p2Name: p2.name,
        p1Score: 0,
        p1Innings: 5,
        p1HR: 0,
      ));
      
      // Game 4: Div by zero check - 0 points in 0 innings = 0 BPI
      await gameHistoryService.saveGame(buildGame(
        id: 'g4',
        startTime: DateTime(2026, 1, 4),
        p1Name: p1.name,
        p2Name: p2.name,
        p1Score: 0,
        p1Innings: 0,
        p1HR: 0,
      ));

      final trends = await playerService.getPlayerTrends(p1.id);
      
      expect(trends.length, 4);
      
      // Sorted by date ascending
      expect(trends[0].bpi, 5.0);
      expect(trends[0].highRun, 15);
      
      expect(trends[1].bpi, 2.5);
      expect(trends[1].highRun, 5);
      
      expect(trends[2].bpi, 0.0);
      expect(trends[2].highRun, 0);
      
      expect(trends[3].bpi, 0.0); // Should handle div by zero
      expect(trends[3].highRun, 0);
    });
  });
}
