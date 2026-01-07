import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  group('Scoring System Water Tightness', () {
    late GameState gameState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      final settings = GameSettings(player1Name: 'P1', player2Name: 'P2');
      gameState = GameState(settings: settings);
      gameState.resetGame();
    });

    test('Net 0 Score on Foul Pot', () {
      // Setup: Foul Mode Normal
      gameState.setFoulMode(FoulMode.normal); // -1 point pending
      
      // Action: Pot 1 ball (1 point)
      // 15 -> 14 balls
      // Net: +1 (pot) -1 (foul) = 0
      gameState.onBallTapped(14);
      
      // Check score
      // Note: Score updates happen when inning is finalized (turn change)
      // For Normal Foul, turn ENDS.
      // onBallTapped checks: isPot (true), isFoul (true).
      // turnEnded = (isPot && !isFoul && !isSafe) -> (true && !true ...) -> false?
      // Wait. Logic: if (isPot && !isFoul && !isSafe) turnEnded = false; else turnEnded = true;
      // if isFoul is true, condition is false -> turnEnded = true.
      
      // So turn ends. _finalizeInning called. Score updated.
      // Score = 0 (currentPoints) + 0 (run) = 0?
      // Points pending: 1. Foul penalty: -1.
      // Net 0.
      
      expect(gameState.players[0].score, 0);
      
      // Verify turn switched
      expect(gameState.currentPlayerIndex, 1);
      
      // Verify Inning Record
      // Should show notation for 1 point and Foul
      // "1F"
      expect(gameState.inningRecords.last.notation, '1F');
    });
    
    
    test('Standard Pot (Ends Turn)', () {
      // Tap 14 -> 1 point, 14 left.
      // Logic: Player ran 1 ball and stopped. Turn Ends.
      gameState.onBallTapped(14); 
      
      // Turn ended (switch to P2)
      expect(gameState.currentPlayerIndex, 1);
      
      // Score finalized
      expect(gameState.players[0].score, 1);
    });

    test('Standard Foul (No Pot)', () {
      gameState.setFoulMode(FoulMode.normal);
      gameState.onBallTapped(15); // 0 balls pocketed
      
      // -1 point
      expect(gameState.players[0].score, -1);
      
      // Turn ended
      expect(gameState.currentPlayerIndex, 1);
      
      // Notation: "0F"
      expect(gameState.inningRecords.last.notation, '0F');
    });
    
    test('Standard Miss (Switch Turn)', () {
       // P1 shoots, misses (0 balls pocketed)
       // Current balls: 15. Tap 15.
       gameState.onBallTapped(15);
       
       // Score should be 0
       expect(gameState.players[0].score, 0);
       
       // Player should switch to P2
       expect(gameState.currentPlayerIndex, 1);
       
       // Notation: "0" because explicit 0 is required for canonical notation
       expect(gameState.inningRecords.last.notation, '0');
    });
    
    test('Table Clear (Continuity)', () {
      // P1 clears table (0 balls left)
      // Tap 0.
      gameState.onBallTapped(0);
      
      // Score: 15
      // Turn Continues (for re-rack)
      expect(gameState.currentPlayerIndex, 0);
      expect(gameState.players[0].inningPoints, 15);
      
      // Verify balls reset to 15 (auto-fill logic added)
      expect(gameState.activeBalls.length, 15);
    });
  });
}
