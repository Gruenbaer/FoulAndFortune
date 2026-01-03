
// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  test('Turn switching logic debug test', () {
    final settings = GameSettings(
      player1Name: 'Player 1',
      player2Name: 'Player 2',
      raceToScore: 100,
    );
    final gameState = GameState(settings: settings);

    // Scenario 1: Pocket a ball (15 -> 14)
    // Expect: Continue turn
    print('\n--- TEST: Pocket 1 Ball (15 -> 14) ---');
    gameState.onBallTapped(14); 
    // Logic: new=14. pocketed=1.
    expect(gameState.currentPlayerIndex, 0, reason: "Should continue turn after pocketing");
    
    // Scenario 2: Pocket another (14 -> 10) - 4 balls at once
    print('\n--- TEST: Pocket 4 Balls (14 -> 10) ---');
    gameState.onBallTapped(10);
    // Logic: new=10. pocketed=4.
    expect(gameState.currentPlayerIndex, 0, reason: "Should continue turn after pocketing multiple");

    // Scenario 3: Miss (10 -> 10) - Tap current ball count
    // Expect: Switch turn
    print('\n--- TEST: Miss (10 -> 10) ---');
    gameState.onBallTapped(10); 
    // Logic: new=10. pocketed=0. TurnEnded=true.
    expect(gameState.currentPlayerIndex, 1, reason: "Should switch turn after miss");
    
    // Scenario 4: Player 2 Pockets (10 -> 9)
    print('\n--- TEST: P2 Pockets (10 -> 9) ---');
    gameState.onBallTapped(9);
    expect(gameState.currentPlayerIndex, 1, reason: "P2 continues");
    
    // Scenario 5: Player 2 Re-racks (1 -> 1) 
    // Setup: set active balls to 1
    // Note: We can't easily force activeBalls=1 via public API without tapping down.
    // So let's tap down from 9 to 1.
    print('\n--- TEST: Drain to 1 ---');
    gameState.onBallTapped(1); 
    // Logic: new=1. pocketed=8. isReRack=true.
    // Expect: Continue (Fixed logic)
    expect(gameState.currentPlayerIndex, 1, reason: "P2 continues after re-rack");
    expect(gameState.activeBalls.length, 15, reason: "Should be reset to 15");
    
    // Scenario 6: Player 2 Misses on fresh rack (15 -> 15)
    print('\n--- TEST: P2 Misses on Fresh Rack (15 -> 15) ---');
    gameState.onBallTapped(15);
    // Logic: new=15. pocketed=0. TurnEnded=true.
    expect(gameState.currentPlayerIndex, 0, reason: "Should switch back to P1");

  });
}
