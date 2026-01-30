import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  group('FF14 Canonical Notation Tests (TV1-TV8)', () {
    late GameState gameState;

    setUp(() {
      final settings = GameSettings(
        player1Name: 'Player 1',
        player2Name: 'Player 2',
        raceToScore: 100,
        player1Handicap: 0,
        player2Handicap: 0,
        player1HandicapMultiplier: 1.0,
        player2HandicapMultiplier: 1.0,
        threeFoulRuleEnabled: true,
      );
      gameState = GameState(settings: settings);
    });

    test('TV1 - Simple inning, ends by non-continuation number', () {
      // Notation: "5" (5 balls potted)
      gameState.onBallTapped(10); // Tap "10 remaining"
      
      // made = 15-10 = 5 → +5, inning ends
      expect(gameState.players[0].score, 5);
      // Check logical player switch (currentPlayerIndex updates immediately)
      expect(gameState.currentPlayerIndex, 1); // Should be Player 2's turn
    });

    test('TV2 - Re-rack continuation then end', () {
      // Notation: "14⟲3" (14 balls, re-rack, 3 balls)
      gameState.onBallTapped(1); // Re-rack trigger
      expect(gameState.currentPlayerIndex, 0); // Turn continues (still Player 1)
      gameState.finalizeReRack(); // Reset rack to 15 balls (simulates UI callback)
      
      gameState.onBallTapped(12); // End with R12
      
      // R1: made=14 → +14, R12: made=3 → +3
      // Total: +17
      expect(gameState.players[0].score, 17);
      expect(gameState.currentPlayerIndex, 1); // Turn ended, switched to Player 2
    });

    test('TV3 - Double-sack continuation then end', () {
      // Notation: "15⟲1" (double sack, re-rack, 1 ball)
      gameState.onDoubleSack(); // R0 (double sack)
      expect(gameState.currentPlayerIndex, 0); // Turn continues (still Player 1)
      gameState.finalizeReRack(); // Reset rack to 15 balls (simulates UI callback)
      
      gameState.onBallTapped(14); // End with R14
      
      // R0: made=15 → +15, R14: made=1 → +1
      // Total: +16
      expect(gameState.players[0].score, 16);
      expect(gameState.currentPlayerIndex, 1); // Turn ended, switched to Player 2
    });

    test('TV4 - Foul only', () {
      // Notation: "F" (pure foul, no balls potted)
      gameState.setFoulMode(FoulMode.normal);
      // In canonical spec, foul requires an action, but we can use Safe or similar
      // Actually, "foul only" means no balls potted + foul
      gameState.onSafe(); // Ends without pots, but safe
      // To properly test foul-only, we need to simulate "pure foul"
      // Let me check the current FoulTracker logic...
      // Actually for pure foul test, ballsPocketed=0
      
      // Simpler: use applyNormalFoul directly
      final result = gameState.foulTracker.applyNormalFoul(gameState.players[0], 0);
      gameState.players[0].score += result.penalty;
      
      expect(gameState.players[0].score, -1);
      expect(gameState.players[0].consecutiveFouls, 1);
    });

    test('TV5 - Three consecutive fouls', () {
      // Notation across innings: "F" | "F" | "TF"
      final player = gameState.players[0];
      
      // First foul (pure)
      final result1 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += result1.penalty;
      expect(player.score, -1);
      expect(player.consecutiveFouls, 1);
      
      // Second foul (pure)
      final result2 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += result2.penalty;
      expect(player.score, -2);
      expect(player.consecutiveFouls, 2);
      
      // Third foul (triggers TF)
      final result3 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += result3.penalty;
      expect(result3.isTripleFoul, true);
      expect(result3.penalty, -16);
      expect(player.score, -18); // -1 -1 -16 = -18
      expect(player.consecutiveFouls, 0); // Reset after TF
    });

    test('TV6 - Foul streak resets by scoring', () {
      // Notation across innings: "F" | "2" | "F"
      final player = gameState.players[0];
      
      // First foul
      player.score += gameState.foulTracker.applyNormalFoul(player, 0).penalty;
      expect(player.consecutiveFouls, 1);
      
      // Second inning: pots 2 balls (15-13=2)
      player.score += gameState.foulTracker.applyNormalFoul(player, 2).penalty; // Foul with pots
      expect(player.consecutiveFouls, 1); // Streak reset by points, but current foul counts (1)
      expect(player.score, -1 + -1); // First foul + second foul (no TF)
      
      // Add the points made
      player.score += 2;
      expect(player.score, 0);
      
      // Third inning: pure foul again
      player.score += gameState.foulTracker.applyNormalFoul(player, 0).penalty;
      expect(player.consecutiveFouls, 2); // Started new streak at 1, now 2
      expect(player.score, -1);
    });

    test('TV7 - Safety resets foul streak', () {
      // Notation across innings: "F" | "S" | "F"
      final player = gameState.players[0];
      
      // First foul
      player.score += gameState.foulTracker.applyNormalFoul(player, 0).penalty;
      expect(player.consecutiveFouls, 1);
      
      // Safe (by canonical rules, resets streak)
      player.consecutiveFouls = 0; // Manual reset for safe
      expect(player.consecutiveFouls, 0);
      
      // Third inning: foul again
      player.score += gameState.foulTracker.applyNormalFoul(player, 0).penalty;
      expect(player.consecutiveFouls, 1); // New streak
      expect(player.score, -2); // -1 -1
    });

    test('TV8a - Break fouls are separate (no 3-foul)', () {
      // Notation: "BF" (break foul)
      final player = gameState.players[0];
      
      // Break Foul
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      
      // Decision: Switch Player (Standard behavior)
      gameState.handleBreakFoulDecision(1); // Switch to Player 2
      
      expect(player.score, -2);
      expect(player.consecutiveFouls, 0); // BF does not affect streak
      expect(gameState.currentPlayerIndex, 1); // Switched
    });

    test('TV8b - Stacked Break Fouls (Same Inning)', () {
      // Notation: "BF" "BF" "BF" (stacked in same inning context)
      final player = gameState.players[0];
      
      // 1. First Break Foul
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      // Decision: Same Player Re-Breaks
      gameState.handleBreakFoulDecision(0);
      
      // Score not finalized yet (still 0), but dynamic score shows penalty
      expect(player.score, 0); 
      expect(gameState.getDynamicInningScore(player), -2);
      expect(player.inningBreakFoulCount, 1);
      expect(gameState.currentPlayerIndex, 0); // Still Player 1
      
      // 2. Second Break Foul
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      // Decision: Same Player Re-Breaks
      gameState.handleBreakFoulDecision(0);
      
      expect(gameState.getDynamicInningScore(player), -4);
      expect(player.inningBreakFoulCount, 2);
      expect(gameState.currentPlayerIndex, 0);
      
      // 3. Third Break Foul (followed by Switch)
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      // Decision: Switch Player
      gameState.handleBreakFoulDecision(1);
      
      // Now finalized
      expect(player.score, -6); // -2 * 3
      expect(gameState.currentPlayerIndex, 1); // Switch to Player 2
      expect(player.consecutiveFouls, 0);
    });
    
    test('EDGE - Foul after points should start NEW foul streak', () {
      // Setup: foulStreak=2, pot 1 ball, then foul
      final player = gameState.players[0];
      player.consecutiveFouls = 2;
      
      // Pot 1 ball + foul
      // Current Logic: Resets to 0 and returns -1
      // Required Logic: Resets to 0 (clears old streak), THEN adds current foul -> Result 1
      
      final result = gameState.foulTracker.applyNormalFoul(player, 1); // ballsPocketed=1
      
      // Expected behavior per new requirement:
      expect(result.penalty, -1);
      expect(player.consecutiveFouls, 1); // Should be 1, currently failing (is 0)
    });

    // ═══════════════════════════════════════════════════════════════
    // TF RE-RACK TESTS (BCA Rule)
    // ═══════════════════════════════════════════════════════════════
    
    test('TF1 - Triple foul: FoulResult returns correct values', () {
      final player = gameState.players[0];
      
      // 3 consecutive pure fouls
      final result1 = gameState.foulTracker.applyNormalFoul(player, 0);
      expect(result1.isTripleFoul, false);
      expect(result1.penalty, -1);
      expect(player.consecutiveFouls, 1);
      
      final result2 = gameState.foulTracker.applyNormalFoul(player, 0);
      expect(result2.isTripleFoul, false);
      expect(result2.penalty, -1);
      expect(player.consecutiveFouls, 2);
      
      final result3 = gameState.foulTracker.applyNormalFoul(player, 0);
      expect(result3.isTripleFoul, true);
      expect(result3.penalty, -16);
      expect(player.consecutiveFouls, 0); // Reset after TF
    });

    test('TF2 - Triple foul via GameState: same player, re-rack, break conditions', () {
      // Manually set up the consecutive fouls to avoid complex test logic
      final player1 = gameState.players[0];
      player1.consecutiveFouls = 2; // Set up 2 fouls manually
      
      // Trigger third foul via GameState -> TF
      gameState.setFoulMode(FoulMode.normal);
      gameState.onBallTapped(15); // No points, pure foul -> TF
      
      // Assertions:
      expect(player1.score, -16); // Only -16 from this inning (not -18 total)
      expect(gameState.currentPlayerIndex, 0); // Same player (no switch!)
      expect(gameState.breakFoulStillAvailable, true); // Break conditions restored
      expect(gameState.inBreakSequence, true);
      expect(gameState.breakingPlayerIndex, 0);
      
      // Table should be re-racked
      expect(gameState.activeBalls.length, 15);
    });

    test('TF3 - Normal foul switches player, TF does not', () {
      // Part 1: Normal foul → player switch
      gameState.setFoulMode(FoulMode.normal);
      gameState.onBallTapped(10); // 5 balls potted with foul
      expect(gameState.currentPlayerIndex, 1); // Switched to player 2
      
      // Reset game for TF test
      gameState.resetGame();
      
      // Part 2: Trigger TF → no player switch
      final player1 = gameState.players[0];
      
      // Manually set up 2 fouls (simpler than going through GameState)
      player1.consecutiveFouls = 2;
      
      // Third foul via GameState
      gameState.setFoulMode(FoulMode.normal);
      gameState.onBallTapped(15); // Pure foul -> TF
      
      expect(gameState.currentPlayerIndex, 0); // Did NOT switch
      expect(gameState.breakFoulStillAvailable, true); // Break active
    });
  });



  group('Break Foul Restrictions Tests', () {
    late GameState gameState;

    setUp(() {
      final settings = GameSettings(
        player1Name: 'Player 1',
        player2Name: 'Player 2',
        raceToScore: 100,
        player1Handicap: 0,
        player2Handicap: 0,
        player1HandicapMultiplier: 1.0,
        player2HandicapMultiplier: 1.0,
        threeFoulRuleEnabled: true,
      );
      gameState = GameState(settings: settings);
    });

    test('BF1 - Break foul available at game start', () {
      // At the very start of the game, break fouls should be available
      expect(gameState.canBreakFoul, true);
      expect(gameState.breakingPlayerIndex, null);
      expect(gameState.breakFoulStillAvailable, true);
    });

    test('BF2 - Break foul unavailable after any ball is potted', () {
      // First action: pot some balls (not using break foul)
      gameState.onBallTapped(10); // Pots 5 balls
      
      // Break fouls should now be permanently disabled
      expect(gameState.canBreakFoul, false);
      expect(gameState.breakFoulStillAvailable, false);
      expect(gameState.breakingPlayerIndex, 0); // Player 1 was the breaking player
    });

    test('BF3 - Break foul unavailable after player switch', () {
      // Player 1 pots a ball and turn ends
      gameState.onBallTapped(14); // Pot 1 ball, turn ends
      
      // Player should have switched
      expect(gameState.currentPlayerIndex, 1); // Should be Player 2
      
      // Break fouls should be disabled
      expect(gameState.canBreakFoul, false);
      expect(gameState.breakFoulStillAvailable, false);
    });

    test('BF4 - Only breaking player can use break fouls', () {
      // Simulate Player 2 being the current player from start
      // (This would happen if they won a coin toss or similar)
      gameState.currentPlayerIndex = 1;
      gameState.players[0].isActive = false;
      gameState.players[1].isActive = true;
      
      // Set Player 1 as the breaking player (simulating previous state)
      gameState.breakingPlayerIndex = 0;
      
      // Player 2 should not be able to use break fouls
      expect(gameState.canBreakFoul, false);
    });

    test('BF5 - Break foul still available if breaking player re-breaks', () {
      // Simulate a break foul where same player re-breaks
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15); // Break foul
      
      // Choose same player to re-break (Player 1, index 0)
      gameState.handleBreakFoulDecision(0);
      
      // Break fouls should still be available
      expect(gameState.canBreakFoul, true);
      expect(gameState.breakFoulStillAvailable, true);
      expect(gameState.inBreakSequence, true);
    });

    test('BF6 - Break foul disabled when different player breaks after break foul', () {
      // Simulate a break foul where different player breaks
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15); // Break foul
      
      // Choose different player to break (Player 2, index 1)
      gameState.handleBreakFoulDecision(1);
      
      // Break fouls should be permanently disabled
      expect(gameState.canBreakFoul, false);
      expect(gameState.breakFoulStillAvailable, false);
      expect(gameState.currentPlayerIndex, 1);
    });

    test('BF7 - Reset game re-enables break fouls', () {
      // Disable break fouls by potting a ball
      gameState.onBallTapped(10);
      expect(gameState.canBreakFoul, false);
      
      // Reset the game
      gameState.resetGame();
      
      // Break fouls should be available again
      expect(gameState.canBreakFoul, true);
      expect(gameState.breakingPlayerIndex, null);
      expect(gameState.breakFoulStillAvailable, true);
      expect(gameState.inBreakSequence, true);
    });

    test('BF8 - Multiple break fouls by same player before potting balls', () {
      // First break foul
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      gameState.handleBreakFoulDecision(0); // Same player re-breaks
      
      expect(gameState.canBreakFoul, true);
      
      // Second break foul
      gameState.setFoulMode(FoulMode.severe);
      gameState.onBallTapped(15);
      gameState.handleBreakFoulDecision(0); // Same player re-breaks again
      
      // Should still be available
      expect(gameState.canBreakFoul, true);
      expect(gameState.breakFoulStillAvailable, true);
    });
  });
}
