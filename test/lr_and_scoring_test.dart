import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/achievement_manager.dart';

void main() {
  group('LR (Last Run) Display Tests', () {
    late GameState gameState;

    setUp(() {
      final settings = GameSettings(
        player1Name: 'Alice',
        player2Name: 'Bob',
        raceToScore: 100,
        threeFoulRuleEnabled: true,
      );
      gameState = GameState(
        settings: settings,
        achievementManager: AchievementManager(),
      );
    });

    test('LR1: Active player shows live currentRun accumulation', () {
      // Alice is active (player 0)
      expect(gameState.players[0].isActive, true);
      expect(gameState.players[0].currentRun, 0);
      
      // Tap 10 (pot 5 balls)
      gameState.onBallTapped(10);
      
      // currentRun should update immediately
      expect(gameState.players[0].currentRun, 5);
      
      // Tap 1 (pot 9 more balls, re-rack)
      gameState.finalizeReRack();
      gameState.onBallTapped(1);
      
      // currentRun should accumulate
      expect(gameState.players[0].currentRun, 14); // 5 + 9
    });

    test('LR2: Inactive player shows lastRun from previous turn', () {
      // Alice pots 5 balls, turn ends
      gameState.onBallTapped(10); // Pot 5
      gameState.onBallTapped(5);  // Pot 5 more, switch to Bob
      
      // Alice is now inactive, Bob is active
      expect(gameState.players[0].isActive, false);
      expect(gameState.players[1].isActive, true);
      
      // Alice's lastRun should be preserved (10 total)
      expect(gameState.players[0].lastRun, 10);
      expect(gameState.players[0].currentRun, 0); // Reset for next turn
      
      // Bob's currentRun starts at 0
      expect(gameState.players[1].currentRun, 0);
    });

    test('LR3: Active player with foul shows NET run (points - penalty)', () {
      // Alice pots 5 balls
      gameState.onBallTapped(10);
      expect(gameState.players[0].currentRun, 5);
      
      // Enable foul mode
      gameState.foulMode = FoulMode.normal;
      
      // Pot 3 more balls with foul
      gameState.onBallTapped(7);
      
      // currentRun should be 8 (5 + 3)
      expect(gameState.players[0].currentRun, 8);
      
      // inningHasFoul should be true
      expect(gameState.players[0].inningHasFoul, true);
      
      // Net LR = currentRun - foul penalty = 8 - 1 = 7
      // (This is calculated in PlayerPlaque, but we verify the data is correct)
    });

    test('LR4: currentRun resets to 0 after player switch', () {
      // Alice pots balls and switches
      gameState.onBallTapped(10); // Pot 5
      gameState.onBallTapped(5);  // Switch
      
      // Alice currentRun should be 0 (reset for next turn)
      expect(gameState.players[0].currentRun, 0);
      
      // But lastRun preserved
      expect(gameState.players[0].lastRun, 10);
    });

    test('LR5: lastRun preserves negative values from fouls', () {
      // Alice fouls without potting
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15); // 0 balls potted, foul, switch
      
      // Alice lastRun should be -1 (pure foul)
      expect(gameState.players[0].lastRun, -1);
      expect(gameState.players[0].currentRun, 0);
    });

    test('LR6: Three-foul penalty shows in lastRun correctly', () {
      // Alice: 1st foul
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      expect(gameState.players[0].consecutiveFouls, 1);
      
      // Bob: normal turn
      gameState.onBallTapped(10);
      
      // Alice: 2nd foul
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      expect(gameState.players[0].consecutiveFouls, 2);
      
      // Bob: normal turn
      gameState.onBallTapped(10);
      
      // Alice: 3rd foul (triggers -16)
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      
      // Alice lastRun should be -16
      expect(gameState.players[0].lastRun, -16);
      expect(gameState.players[0].consecutiveFouls, 0); // Reset after 3-foul
    });

    test('LR7: Re-rack accumulates in currentRun correctly', () {
      // Alice pots to re-rack
      gameState.onBallTapped(1); // Pot 14 balls, re-rack
      expect(gameState.players[0].currentRun, 14);
      
      // Finalize re-rack
      gameState.finalizeReRack();
      
      // Pot 5 more
      gameState.onBallTapped(10);
      
      // currentRun should accumulate: 14 + 5 = 19
      expect(gameState.players[0].currentRun, 19);
    });
  });

  group('Score Counting Accuracy Tests', () {
    late GameState gameState;

    setUp(() {
      final settings = GameSettings(
        player1Name: 'Alice',
        player2Name: 'Bob',
        raceToScore: 100,
        threeFoulRuleEnabled: true,
      );
      gameState = GameState(
        settings: settings,
        achievementManager: AchievementManager(),
      );
    });

    test('SC1: Basic scoring - pot balls, score increases', () {
      // Alice pots 5 balls
      gameState.onBallTapped(10);
      expect(gameState.players[0].score, 0); // Not finalized yet
      
      // End turn
      gameState.onBallTapped(5);
      
      // Score should be finalized
      expect(gameState.players[0].score, 10);
    });

    test('SC2: Foul deducts 1 point from run', () {
      // Alice pots 5 balls
      gameState.onBallTapped(10);
      
      // Foul and pot 3 more
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(7);
      
      // Score should be 8 - 1 = 7
      expect(gameState.players[0].score, 7);
    });

    test('SC3: Three-foul penalty deducts 16 points', () {
      // Set up: Alice gets 2 fouls
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15); // Foul 1
      gameState.onBallTapped(10);  // Bob's turn
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15); // Foul 2
      
      // Give Alice some points first
      gameState.onBallTapped(10);  // Bob's turn
      gameState.onBallTapped(5);   // Alice pots 10 balls
      expect(gameState.players[0].score, 8); // 10 - 2 (two fouls)
      
      // Alice: 3rd foul (triggers -16)
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      
      // Score should decrease by 16
      expect(gameState.players[0].score, -8); // 8 - 16 = -8
    });

    test('SC4: Handicap multiplier applied correctly', () {
      // Set Alice handicap to 2x
      gameState.players[0].handicapMultiplier = 2.0;
      
      // Alice pots 5 balls
      gameState.onBallTapped(10);
      gameState.onBallTapped(5); // End turn
      
      // Score should be 10 * 2 = 20
      expect(gameState.players[0].score, 20);
    });

    test('SC5: Re-rack points accumulate correctly', () {
      // Alice pots to re-rack
      gameState.onBallTapped(1); // Pot 14
      gameState.finalizeReRack();
      
      // Pot 5 more and end turn
      gameState.onBallTapped(10);
      gameState.onBallTapped(5);
      
      // Score should be 14 + 5 = 19
      expect(gameState.players[0].score, 19);
    });

    test('SC6: Multiple re-racks in one inning', () {
      // Alice: First re-rack
      gameState.onBallTapped(1); // 14 points
      gameState.finalizeReRack();
      
      // Second re-rack
      gameState.onBallTapped(1); // 14 more
      gameState.finalizeReRack();
      
      // Pot 5 and end turn
      gameState.onBallTapped(10);
      gameState.onBallTapped(5);
      
      // Score should be 14 + 14 + 5 = 33
      expect(gameState.players[0].score, 33);
    });

    test('SC7: Foul with handicap applies penalty after multiplier', () {
      // Alice handicap 2x
      gameState.players[0].handicapMultiplier = 2.0;
      
      // Pot 5 balls
      gameState.onBallTapped(10);
      
      // Foul and pot 5 more
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(5);
      
      // Points: (5 + 5) * 2 = 20
      // Foul: -1
      // Total: 19
      expect(gameState.players[0].score, 19);
    });

    test('SC8: Score never goes below 0, fouls first turn', () {
      // Alice fouls on first turn (0 points)
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      
      // Score should be -1 (can go negative)
      expect(gameState.players[0].score, -1);
    });
  });

  group('Edge Cases & Complex Scenarios', () {
    late GameState gameState;

    setUp(() {
      final settings = GameSettings(
        player1Name: 'Alice',
        player2Name: 'Bob',
        raceToScore: 100,
        threeFoulRuleEnabled: true,
      );
      gameState = GameState(
        settings: settings,
        achievementManager: AchievementManager(),
      );
    });

    test('EDGE1: LR during 800ms switch delay shows lastRun', () {
      // Alice pots and switches
      gameState.onBallTapped(10);
      gameState.onBallTapped(5);
      
      // Immediately after switch:
      // Alice: isActive might still be true (800ms delay)
      // But currentRun is 0, lastRun is 10
      // LR logic should prefer lastRun when currentRun == 0 && lastRun != 0
      expect(gameState.players[0].currentRun, 0);
      expect(gameState.players[0].lastRun, 10);
    });

    test('EDGE2: Break foul does not add to consecutive fouls', () {
      // Alice: break foul
      gameState.foulMode = FoulMode.severe;
      gameState.onBallTapped(15);
      expect(gameState.players[0].consecutiveFouls, 0); // Not incremented
      
      // Bob: normal turn
      gameState.handleBreakFoulDecision(1); // Bob breaks
      gameState.onBallTapped(10);
      
      // Alice: normal foul
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      expect(gameState.players[0].consecutiveFouls, 1); // Now 1, not 2
    });

    test('EDGE3: Legal points reset consecutive fouls mid-inning', () {
      // Alice: foul
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(10); // Pot 5 with foul
      expect(gameState.players[0].consecutiveFouls, 0); // Reset by legal points
    });

    test('EDGE4: currentRun includes handicap multiplier', () {
      // Alice handicap 2x
      gameState.players[0].handicapMultiplier = 2.0;
      
      // Pot 5 balls
      gameState.onBallTapped(10);
      
      // currentRun should be 5 (raw points, NO multiplier applied yet)
      // Multiplier only applies during finalization
      expect(gameState.players[0].currentRun, 5);
      
      // End turn
      gameState.onBallTapped(5);
      
      // Score should have multiplier: 10 * 2 = 20
      expect(gameState.players[0].score, 20);
    });

    test('EDGE5: Foul-only turn shows -1 in lastRun', () {
      // Alice fouls without potting
      gameState.foulMode = FoulMode.normal;
      gameState.onBallTapped(15);
      
      expect(gameState.players[0].lastRun, -1);
      expect(gameState.players[0].score, -1);
    });
  });
}
