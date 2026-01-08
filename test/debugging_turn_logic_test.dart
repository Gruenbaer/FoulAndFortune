
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
    // Current Logic: Any tap (except 0/1) ENDS turn
    print('\n--- TEST: Pocket 1 Ball (15 -> 14) ---');
    gameState.onBallTapped(14); 
    // Logic: new=14. pocketed=1. turnEnded=true -> switches
    expect(gameState.currentPlayerIndex, 1, reason: "Turn ends after tapping (current logic)");
    
    // Scenario 2: Player 2 Pockets (14 -> 10) - 4 balls at once
    print('\n--- TEST: Pocket 4 Balls (14 -> 10) ---');
    gameState.onBallTapped(10);
    // Logic: new=10. pocketed=4. turnEnded=true -> switches back
    expect(gameState.currentPlayerIndex, 0, reason: "Turn ends, switches back to P1");

    // Scenario 3: Player 1 Pockets again (10 -> 9)
    print('\n--- TEST: P1 Pockets (10 -> 9) ---');
    gameState.onBallTapped(9); 
    expect(gameState.currentPlayerIndex, 1, reason: "Turn ends, switches to P2");
    
    // Scenario 4: Player 2 Re-racks (9 -> 1) 
    print('\n--- TEST: P2 Re-racks (9 -> 1) ---');
    gameState.onBallTapped(1);
    gameState.finalizeReRack(); // Simulate UI callback that resets rack to 15
    // Logic: new=1. isReRack=true. turnEnded=false -> CONTINUES
    expect(gameState.currentPlayerIndex, 1, reason: "P2 continues after re-rack");
    expect(gameState.activeBalls.length, 15, reason: "Should be reset to 15");
    
    // Scenario 5: Player 2 Taps on fresh rack (15 -> 14)
    print('\n--- TEST: P2 Taps on Fresh Rack (15 -> 14) ---');
    gameState.onBallTapped(14);
    // Logic: new=14. turnEnded=true -> switches
    expect(gameState.currentPlayerIndex, 0, reason: "Should switch back to P1");

  });
}
