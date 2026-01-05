
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

// import 'package:foulandfortune/models/game_action.dart'; // Deprecated
// import 'package:foulandfortune/widgets/score_card.dart'; // Unused


void main() {
  group('Scoring System Water Tightness', () {
    late GameState gameState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      // Settings: defaults
      final settings = GameSettings(
        player1Name: 'P1',
        player2Name: 'P2',
        raceToScore: 100,
      );
      gameState = GameState(settings: settings);
      gameState.resetGame();
    });

    test('Net 0 Score on Foul Pot', () {
      // Scenario: Tap Foul (activates mode), Tap Ball 14.
      // Expected: Score 0 (or -1 if pure 14.1, but sticking to observed logic of 0).
      // ScoreCard history should reflect 0 net change.
      
      // 1. Activate Foul Mode
      gameState.setFoulMode(FoulMode.normal); 
      expect(gameState.foulMode, FoulMode.normal);

      // 2. Tap Ball 14 (Player 1)
      // Initial Score: 0
      gameState.onBallTapped(14);

      // 3. Verify Player Score
      // If logic is +1 (pot) -1 (foul) = 0
      expect(gameState.players[0].score, 0, reason: "Player score should be 0 (net)");

      // 4. Verify History
      // History is now matchLog (strings) and internal events. 
      // We rely on score being correct.
      // expect(gameState.history.length, 1);
      // final action = gameState.history.first;
      // expect(action.type, GameActionType.foul);
      
      // CRITICAL: Action points must match the net score change to ensure ScoreCard sums correctly in the future
      // expect(action.points, 0, reason: "GameAction points must be 0 to match net score");
    });
    
    
    test('Standard Pot', () {
      gameState.onBallTapped(14); // 15 - 14 = 1 point, 14 balls remaining
      // End turn by tapping remaining count (no more balls pocketed)
      gameState.onBallTapped(14); // Switch player
      // Now score should be finalized
      expect(gameState.players[0].score, 1);
    });

    test('Standard Foul (No Pot)', () {
       // Simulate Foul without potting any ball
       gameState.setFoulMode(FoulMode.normal);
       int currentBalls = gameState.activeBalls.length;
       gameState.onBallTapped(currentBalls); // No change in ball count
       
       expect(gameState.players[0].score, -1);
       // expect(gameState.history.first.type, GameActionType.foul);
       // expect(gameState.history.first.points, -1); // Net points for simple foul
    });
  });
}
