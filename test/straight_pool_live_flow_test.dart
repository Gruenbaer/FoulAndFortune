import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/shot_event_service.dart';

void main() {
  group('Straight Pool live flow scenarios', () {
    late AppDatabase db;
    late ShotEventService shotEventService;
    late GameHistoryService historyService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase();
      shotEventService = ShotEventService(db: db);
      historyService = GameHistoryService(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    GameState buildGame({int raceToScore = 20}) {
      final settings = GameSettings(
        player1Name: 'Alice',
        player2Name: 'Bob',
        raceToScore: raceToScore,
        threeFoulRuleEnabled: true,
      );

      final state = GameState(
        settings: settings,
        shotEventService: shotEventService,
      );
      state.setGameId('test-game-$raceToScore');
      state.resetGame();
      return state;
    }

    GameRecord buildCompletedRecord(GameState gameState, {String id = 'game-1'}) {
      final p1 = gameState.players[0];
      final p2 = gameState.players[1];

      return GameRecord(
        id: id,
        player1Name: p1.name,
        player2Name: p2.name,
        player1Score: p1.score,
        player2Score: p2.score,
        startTime: DateTime(2026, 4, 10, 12, 0),
        endTime: DateTime(2026, 4, 10, 12, 30),
        isCompleted: true,
        winner: gameState.winner?.name,
        raceToScore: gameState.raceToScore,
        isTrainingMode: gameState.settings.isTrainingMode,
        player1Innings: p1.currentInning,
        player2Innings: p2.currentInning,
        player1HighestRun: p1.highestRun,
        player2HighestRun: p2.highestRun,
        player1Fouls: gameState.getTotalFoulsForPlayer(p1),
        player2Fouls: gameState.getTotalFoulsForPlayer(p2),
        activeBalls: const [],
        player1IsActive: false,
        snapshot: gameState.toJson(),
      );
    }

    test('multi-tap re-rack flow keeps canonical notation after snapshot reload',
        () {
      final gameState = buildGame();

      gameState.onDoubleSack();
      gameState.finalizeReRack();
      gameState.onBallTapped(14);

      expect(gameState.gameOver, isFalse);
      expect(gameState.players[0].score, 16);
      expect(gameState.players[0].highestRun, 16);
      expect(gameState.inningRecords, hasLength(1));
      expect(gameState.inningRecords.single.notation, '15⟲1');

      final restored = buildGame();
      restored.loadFromJson(gameState.toJson());

      expect(restored.players[0].score, 16);
      expect(restored.players[0].highestRun, 16);
      expect(restored.inningRecords, hasLength(1));
      expect(restored.inningRecords.single.notation, '15⟲1');
    });

    test('game ends exactly at configured race score and completed snapshot stays saved',
        () async {
      final gameState = buildGame(raceToScore: 5);

      gameState.onBallTapped(10);

      expect(gameState.players[0].score, 5);
      expect(gameState.gameOver, isTrue);
      expect(gameState.winner?.name, 'Alice');
      expect(gameState.inningRecords.last.notation, '5');

      final record =
          buildCompletedRecord(gameState, id: 'straight-pool-finish-at-race');
      await historyService.saveGame(record);
      final loaded = await historyService.getGameById(record.id);

      expect(loaded, isNotNull);
      expect(loaded!.isCompleted, isTrue);
      expect(loaded.winner, 'Alice');
      expect(loaded.raceToScore, 5);
      expect(loaded.player1Score, 5);
      expect(loaded.player2Score, 0);
      expect(loaded.snapshot?['gameOver'], isTrue);

      final inningRecords =
          (loaded.snapshot?['inningRecords'] as List<dynamic>? ?? const []);
      expect(inningRecords, hasLength(1));
      expect((inningRecords.first as Map<String, dynamic>)['notation'], '5');
    });

    test('completed game keeps safe and foul stats plus scorecard notations',
        () async {
      final gameState = buildGame(raceToScore: 5);

      gameState.onSafe();
      gameState.onSafe();

      gameState.setFoulMode(FoulMode.normal);
      gameState.onBallTapped(15);

      gameState.onBallTapped(10);

      expect(gameState.gameOver, isTrue);
      expect(gameState.winner?.name, 'Alice');
      expect(gameState.players[0].saves, 1);
      expect(gameState.getTotalFoulsForPlayer(gameState.players[0]), 0);
      expect(gameState.getTotalFoulsForPlayer(gameState.players[1]), 1);
      expect(gameState.players[0].highestRun, 5);
      expect(
        gameState.inningRecords.map((record) => record.notation).toList(),
        ['0S', '0F', '5'],
      );

      final record =
          buildCompletedRecord(gameState, id: 'straight-pool-stats-complete');
      await historyService.saveGame(record);
      final loaded = await historyService.getGameById(record.id);

      expect(loaded, isNotNull);
      expect(loaded!.player1HighestRun, 5);
      expect(loaded.player1Fouls, 0);
      expect(loaded.player2Fouls, 1);
      expect(loaded.player1Innings, gameState.players[0].currentInning);
      expect(loaded.player2Innings, gameState.players[1].currentInning);

      final inningRecords =
          (loaded.snapshot?['inningRecords'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
      expect(
        inningRecords.map((record) => record['notation']).toList(),
        ['0S', '0F', '5'],
      );
    });
  });
}
