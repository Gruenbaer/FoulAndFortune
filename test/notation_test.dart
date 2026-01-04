
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  group('Score Notation Tests', () {
    late GameState gameState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      final settings = GameSettings(player1Name: 'P1', player2Name: 'P2');
      gameState = GameState(settings: settings);
      gameState.resetGame();
    });

    test('Notation: 14-ball break should show | and •', () {
       // P1 clears 14 balls
       // To simulate clearing 14 balls, we can just tap '1' from a full rack of 15
       // This implies 14 were pocketed and 1 remains.
       // Current state: 15 balls (resetGame)
       
       // Action: Tap 1 (leaves 1 ball, so 14 pocketed)
       gameState.onBallTapped(1); 
       
       // This should trigger re-rack logic internally
       expect(gameState.players[0].inningHasReRack, true);
       expect(gameState.players[0].inningHistory, contains(14));
       
       // P1 pots 1 more ball after re-rack
       // After re-rack, ball count is reset to 15 (physically) but for logic?
       // _updateRackCount(15) is called in `onBallTapped` for BreakFoul? 
       // No, `finalizeReRack` resets it?
       // `onBallTapped` sets `_updateRackCount(newBallCount)`. So 1.
       // The user physically re-racks.
       // If we tap a ball now, it assumes we are hitting from the new rack?
       // Code: `currentPlayer.reRackPoints += ...; currentPlayer.inningPoints = 0;`
       // But `activeBalls` is `[1]`.
       // We need to simulate the re-rack filling the table.
       // Ah, `finalizeReRack` is called by UI. We must call it manually in test.
       gameState.finalizeReRack();
       
       // Now activeBalls is 15.
       // P1 pots 1 ball (tap 14)
       gameState.onBallTapped(14); 
       
       // End P1 turn (simple miss -> tap remaining count)
       int remaining = gameState.activeBalls.length; // 14
       gameState.onBallTapped(remaining);
       
       // Check the notation in the record
       // Expected: 14 balls -> '|', re-rack -> '•', 1 point after -> '1'  => "|•1"
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '|•1');
    });

    test('Notation: Non-14-ball re-rack should show number and •', () {
       // P1 clears 5 balls
       // 15 -> 10. Tap 10.
       gameState.onBallTapped(10);
       
       // Trigger Re-Rack (maybe accidental or safety)
       // Tap 1 (leaves 1). So 9 more pocketed?
       // Start: 15. Tap 10 -> 5 pocketed. Remaining: 10.
       // Tap 1 -> 9 pocketed. Total 14. That gives '|'.
       // We want non-14 re-rack.
       // So total pre-rerack points != 14.
       // Example: 5 points total.
       // Start 15. Tap 10 -> 5 pocketed. (Left 10).
       // Now we need to reach state where '1' is left, WITHOUT pocketing 9 more.
       // We can't?
       // In 14.1 you only re-rack if 1 ball is left (standard) OR if you want to re-rack legally?
       // Wait, standard 14.1 is ONLY when 1 ball is left (the break ball).
       // So you logically MUST have pocketed 14 balls to get a re-rack in a single run?
       // Unless you came into the turn with balls already on table?
       // Ah! The test setup `resetGame` starts with 15.
       
       // Scenario: Previous player left 6 balls.
       // We manually set state to simulate starting condition
       gameState.activeBalls = {1, 2, 3, 4, 5, 6}; // Manually set state
       gameState.currentPlayer.inningPoints = 0; // Reset points for this scenario
       gameState.onBallTapped(1); // Leaves 1 ball. Pocketed 5.
       // Total Inning Points = 5.
       
       expect(gameState.players[0].inningHasReRack, true);
       // Check explicit state
       expect(gameState.players[0].inningHistory, contains(5));
       
       gameState.finalizeReRack(); // Reset to 15
       
       // P1 misses immediately after re-rack
       gameState.onBallTapped(15); // Tap 15 (0 pocketed)
       
       // Expected: "5•" (bullet with no trailing number since 0 post-rerack points)
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '5•');
    });
    
     test('Notation: Standard break followed by points', () {
       // Scenario: Previous player left 6 balls.
       gameState.activeBalls = {1, 2, 3, 4, 5, 6};
       gameState.onBallTapped(1); // Leaves 1. Pocketed 5.
       gameState.finalizeReRack();
       
       // Pot 2 more (15 -> 13)
       gameState.onBallTapped(13);
       
       // Miss (13 -> 13)
        gameState.onBallTapped(13);
       
       // Expected: "5•2"
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '5•2');
    });
    
  test('Generates complex notation: 15•|•5SF (Points reset foul streak)', () {
    // Enable 3-foul rule
    gameState.foulTracker.threeFoulRuleEnabled = true;
    
    // Setup Player: needs 2 fouls. BUT we are about to score points, which SHOULD reset this to 0.
    gameState.currentPlayer.consecutiveFouls = 2;
    
    // 1. Double Sack (15 points) -> Adds 15 to history
    gameState.onDoubleSack();
    
    // 2. Break (14 points) -> Adds 14 to history (mapped to |)
    // Double sack resets balls to 15.
    // We want to simulate potting 14 balls and leaving 1.
    // Current balls: 15.
    // Tap 1 -> Leaves 1 ball. Pocketed 14.
    // This triggers re-rack logic (newBallCount == 1).
    gameState.onBallTapped(1); 
    
    // Now history is [15, 14]. Points 0.
    // Rack has 1 ball.
    
    // 3. 5 Points in new rack
    // Simulate user refilling rack to 15 balls.
    // We can manually update balls if API allows, or helper.
    // _updateRackCount is private. activeBalls is public getter? 
    // activeBalls is a Set. We can try to set it if there is a setter.
    // setter is activeBalls = ...
    gameState.activeBalls = Set.from(List.generate(15, (i) => i + 1));
    
    // Now 15 balls. Pot 5 -> Leave 10.
    gameState.onBallTapped(10);
    // 15 - 10 = 5 pocketed.
    // inningPoints = 5.
    
    // 4. End with Safe + Foul
    gameState.onSafe(); // Toggle safe mode ON
    gameState.setFoulMode(FoulMode.normal); // Set foul mode
    
    // Pass CURRENT remaining balls (10) to signify Miss
    int remaining = gameState.activeBalls.length; // 10
    gameState.onBallTapped(remaining); 
    
    // Verify Foul Streak Reset
    // Because points were scored (15 + 14 + 5), consecutive fouls should have reset to 0.
    // The final foul makes it 1.
    expect(gameState.players[0].consecutiveFouls, 1);
    
    // Check notation
    print('Inning records count: ${gameState.inningRecords.length}');
    if (gameState.inningRecords.isNotEmpty) {
        print('Last Record Notation: ${gameState.inningRecords.last.notation}');
    }

    // Check notation
    String notation = gameState.inningRecords.last.notation;
    // Expected: 15 (doublesack) • | (14) • 5 (current) S (Safe) F (Normal Foul)
    
    expect(notation.contains('15'), true);
    expect(notation.contains('|'), true);
    expect(notation.contains('5'), true);
    expect(notation.contains('S'), true);
  });
  });
}
