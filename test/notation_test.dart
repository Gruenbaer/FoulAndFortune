
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

    test('Notation: 14-ball break should show 14⟲ (canonical)', () {
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
       gameState.finalizeReRack();
       
       // Now activeBalls is 15.
       // P1 pots 1 ball (tap 14)
       gameState.onBallTapped(14); 
       
       // End P1 turn (Tap 14 means "Left 14 on table" -> Potted 1 -> Turn Ends)
       // int remaining = gameState.activeBalls.length; // 14
       // gameState.onBallTapped(remaining);
       
       // Check the notation in the record
       // Expected: 14 balls -> '14', re-rack -> '⟲', 1 point after -> '1'  => "14⟲1"
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '14⟲1');
    });

    test('Notation: Non-14-ball re-rack should show number and ⟲', () {
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
       
        // P1 misses immediately after re-rack (Tap 15 balls left -> 0 potted)
        // Or actually, if they tapped 15, they say "I left 15 balls" -> 0 points.
        gameState.onBallTapped(15);
       
       // Expected: "5⟲0" (canonical requires explicit 0 for empty segment)
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '5⟲0');
    });
    
    test('Notation: Standard break followed by points', () {
       // Scenario: Previous player left 6 balls.
       gameState.activeBalls = {1, 2, 3, 4, 5, 6};
       gameState.onBallTapped(1); // Leaves 1. Pocketed 5.
       gameState.finalizeReRack();
       
       // Pot 2 more (15 -> 13)
       gameState.onBallTapped(13);
       
        // Tap 13 -> "I left 13 balls". Start was 15.
        // So Potted = 2.
        // Turn Ends automatically.
        // gameState.onBallTapped(13); // REMOVED explicit miss
       
       // Expected: "5⟲2"
       final lastRecord = gameState.inningRecords.last;
       expect(lastRecord.notation, '5⟲2');
    });
    
  test('Generates complex notation: 15⟲14⟲5SF (Points reset foul streak)', () {
    // Enable 3-foul rule
    gameState.foulTracker.threeFoulRuleEnabled = true;
    
    // Setup Player: needs 2 fouls. BUT we are about to score points, which SHOULD reset this to 0.
    gameState.currentPlayer.consecutiveFouls = 2;
    
    // 1. Double Sack (15 balls)
    // Tap 0 (Clear table) -> This keeps turn? 
    // Wait. My onBallTapped logic for 0 DOES NOT add points if called directly?
    // onDoubleSack adds points manually.
    gameState.onDoubleSack();
    gameState.finalizeReRack(); // Reset to 15 balls (simulating UI callback)
    
    // 2. Break (14 points) -> Adds 14 to history
    // Double sack resets balls to 15.
    // We want to simulate potting 14 balls and leaving 1.
    // Current balls: 15.
    // Tap 1 -> Leaves 1 ball. Pocketed 14.
    // This triggers re-rack logic (newBallCount == 1).
    gameState.onBallTapped(1); 
    
    // Now history is [15, 14]. Points 0.
    // Rack has 1 ball.
    
    // 3. 5 Points in new rack AND Safe + Foul
    // Simulate user refilling rack to 15 balls.
    gameState.activeBalls = Set.from(List.generate(15, (i) => i + 1));
    
    // Setup Safe + Foul BEFORE tapping
    gameState.onSafe(); // Toggle safe mode ON
    gameState.setFoulMode(FoulMode.normal); // Set foul mode
    
    // Tap 10 -> Left 10 balls. Start 15. Potted 5.
    // Safe + Foul modes are active.
    // Turn Ends.
    gameState.onBallTapped(10); 
    
    // Verify Foul Streak Reset
    // Because points were scored (15 + 14 + 5), consecutive fouls should have reset to 0.
    // The final foul makes it 1.
    expect(gameState.players[0].consecutiveFouls, 1);
    
    // Check notation
    String notation = gameState.inningRecords.last.notation;
    // Expected: 15 (doublesack) ⟲ 14 (break) ⟲ 5 (current) S (Safe) F (Normal Foul)
    // Canonical format: 15⟲14⟲5SF
    
    expect(notation, '15⟲14⟲5SF');
  });
  });
}
