import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/services/shot_event_service.dart';
import 'package:foulandfortune/stats/shot_event_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('Shot Event Verification', () {
    late AppDatabase db;
    late ShotEventService service;
    late GameState gameState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase();
      service = ShotEventService(db: db);
      
      final settings = GameSettings(
        player1Name: 'Player 1',
        player2Name: 'Player 2',
        player1Id: 'p1-uuid',
        player2Id: 'p2-uuid',
        raceToScore: 100,
      );

      gameState = GameState(
        settings: settings,
        shotEventService: service,
      );
      
      gameState.setGameId('test-game-id');
    });

    tearDown(() async {
      await db.close();
    });

    test('Simulate game sequence and verify emitted shot events', () async {
      // 1. Initial State - Turn 1 Start
      // Inside GameState, we don't auto-emit turnStart on constructor. 
      // Usually _switchPlayer or similar at start? 
      // Actually, GameScreen handles the first turnStart or we can trigger it in test.
      
      // Let's manually trigger turn 1 start for consistency if needed, 
      // or assume the first action happens in Turn 1.
      // GameState.setGameId sets currentTurnIndex = 1.
      
      // Shot 1: P1 pockets Ball 2
      gameState.onBallTapped(2);
      
      // Shot 2: P1 plays Safety
      gameState.onSafe(); 
      // Note: onSafe is a toggle or confirm. In my implementation of onSafe:
      // if (!isSafeMode) { isSafeMode = true; } else { _emitEvent; apply; isSafeMode = false; }
      // So we need to call it twice to "confirm" a safety if we want to emit.
      gameState.onSafe(); 

      // Shot 3: P1 Fouls (Tap 0)
      gameState.onBallTapped(0);

      // Player Switch (End P1 Turn 1, Start P2 Turn 2)
      // _switchPlayer is private. We need to trigger it via finalizeInning or outcome.
      // In Straigt Pool, a foul/safety usually ends the inning if not training mode.
      // Let's check how _switchPlayer is called. It's usually called from _applyOutcome.
      // In SP, if you tap 0 (foul), the outcome typically switches player.

      // WAIT: In SP, onBallTapped(0) triggers a foul but might not switch player immediately 
      // if it's a break foul decision. 
      // For simplicity, let's call a method that we know triggers _switchPlayer.
      // Actually, finalizing a foul in SP ends the inning.

      // Let's check events in DB so far
      var events = await service.getEventsForGame('test-game-id');
      
      // Expected Sequence:
      // 0: shot (pocket, ballId: 2) -> Turn 1, Shot 0
      // 1: turnEnd                  -> Turn 1, Shot 1
      // 2: turnStart                -> Turn 2, Shot 0
      // 3: shot (safety)            -> Turn 2, Shot 1
      // 4: turnEnd                  -> Turn 2, Shot 2
      // 5: turnStart                -> Turn 3, Shot 0
      // 6: shot (pocket, ballId: 0) -> Turn 3, Shot 1
      
      expect(events.length, 7);
      
      expect(events[0].eventType, ShotEventType.shot.name);
      expect(jsonDecode(events[0].payload)['data']['ballId'], 2);
      expect(events[0].turnIndex, 1);
      expect(events[0].shotIndex, 0);

      expect(events[1].eventType, ShotEventType.turnEnd.name);
      expect(events[1].turnIndex, 1);
      expect(events[1].shotIndex, 1);

      expect(events[2].eventType, ShotEventType.turnStart.name);
      expect(events[2].turnIndex, 2);
      expect(events[2].shotIndex, 0);

      expect(events[3].eventType, ShotEventType.shot.name);
      expect(jsonDecode(events[3].payload)['data']['kind'], 'safety');
      expect(events[3].turnIndex, 2);
      expect(events[3].shotIndex, 1);

      expect(events[6].eventType, ShotEventType.shot.name);
      expect(jsonDecode(events[6].payload)['data']['ballId'], 0);
      expect(events[6].turnIndex, 3);
      expect(events[6].shotIndex, 1);
    });
  });
}
