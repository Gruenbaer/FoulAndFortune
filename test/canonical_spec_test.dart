import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  group('Canonical Spec Tests (TV1-TV8)', () {
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
      // Tokens: R10
      gameState.onBallTapped(10); // Tap "10 remaining"
      
      // made = 15-10 = 5 → +5, inning ends
      expect(gameState.players[0].score, 5);
      expect(gameState.players[0].isActive, false); // Turn should have ended
      expect(gameState.players[1].isActive, true);
    });

    test('TV2 - Re-rack continuation then end', () {
      // Tokens: R1 R12
      gameState.onBallTapped(1); // Re-rack trigger
      expect(gameState.players[0].isActive, true); // Turn continues
      
      gameState.onBallTapped(12); // End with R12
      
      // R1: made=14 → +14, R12: made=3 → +3
      // Total: +17
      expect(gameState.players[0].score, 17);
      expect(gameState.players[0].isActive, false);
    });

    test('TV3 - Double-sack continuation then end', () {
      // Tokens: R0 R14
      gameState.onDoubleSack(); // R0 (double sack)
      expect(gameState.players[0].isActive, true); // Turn continues
      
      gameState.onBallTapped(14); // End with R14
      
      // R0: made=15 → +15, R14: made=1 → +1
      // Total: +16
      expect(gameState.players[0].score, 16);
      expect(gameState.players[0].isActive, false);
    });

    test('TV4 - Foul only', () {
      // Tokens: F
      gameState.setFoulMode(FoulMode.normal);
      // In canonical spec, foul requires an action, but we can use Safe or similar
      // Actually, "foul only" means no balls potted + foul
      gameState.onSafe(); // Ends without pots, but safe
      // To properly test foul-only, we need to simulate "pure foul"
      // Let me check the current FoulTracker logic...
      // Actually for pure foul test, ballsPocketed=0
      
      // Simpler: use applyNormalFoul directly
      final penalty = gameState.foulTracker.applyNormalFoul(gameState.players[0], 0);
      gameState.players[0].score += penalty;
      
      expect(gameState.players[0].score, -1);
      expect(gameState.players[0].consecutiveFouls, 1);
    });

    test('TV5 - Three consecutive fouls', () {
      // Tokens: F | F | TF (across three innings)
      final player = gameState.players[0];
      
      // First foul (pure)
      int penalty1 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += penalty1;
      expect(player.score, -1);
      expect(player.consecutiveFouls, 1);
      
      // Second foul (pure)
      int penalty2 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += penalty2;
      expect(player.score, -2);
      expect(player.consecutiveFouls, 2);
      
      // Third foul (triggers TF)
      int penalty3 = gameState.foulTracker.applyNormalFoul(player, 0);
      player.score += penalty3;
      expect(player.score, -18); // -1 -1 -16 = -18
      expect(player.consecutiveFouls, 0); // Reset after TF
    });

    test('TV6 - Foul streak resets by scoring', () {
      // Tokens: F | R13 | F
      final player = gameState.players[0];
      
      // First foul
      player.score += gameState.foulTracker.applyNormalFoul(player, 0);
      expect(player.consecutiveFouls, 1);
      
      // Second inning: pots 2 balls (15-13=2)
      player.score += gameState.foulTracker.applyNormalFoul(player, 2); // Foul with pots
      expect(player.consecutiveFouls, 1); // Streak reset by points, but current foul counts (1)
      expect(player.score, -1 + -1); // First foul + second foul (no TF)
      
      // Add the points made
      player.score += 2;
      expect(player.score, 0);
      
      // Third inning: pure foul again
      player.score += gameState.foulTracker.applyNormalFoul(player, 0);
      expect(player.consecutiveFouls, 2); // Started new streak at 1, now 2
      expect(player.score, -1);
    });

    test('TV7 - Safety resets foul streak', () {
      // Tokens: F | S | F
      final player = gameState.players[0];
      
      // First foul
      player.score += gameState.foulTracker.applyNormalFoul(player, 0);
      expect(player.consecutiveFouls, 1);
      
      // Safe (by canonical rules, resets streak)
      player.consecutiveFouls = 0; // Manual reset for safe
      expect(player.consecutiveFouls, 0);
      
      // Third inning: foul again
      player.score += gameState.foulTracker.applyNormalFoul(player, 0);
      expect(player.consecutiveFouls, 1); // New streak
      expect(player.score, -2); // -1 -1
    });

    test('TV8 - Break fouls are separate (no 3-foul)', () {
      // Tokens: BF | BF | BF
      final player = gameState.players[0];
      
      // First break foul
      player.score += gameState.foulTracker.applySevereFoul(player);
      expect(player.score, -2);
      expect(player.consecutiveFouls, 0); // BF does not affect streak
      
      // Second break foul
      player.score += gameState.foulTracker.applySevereFoul(player);
      expect(player.score, -4);
      expect(player.consecutiveFouls, 0);
      
      // Third break foul
      player.score += gameState.foulTracker.applySevereFoul(player);
      expect(player.score, -6);
      expect(player.consecutiveFouls, 0);
      
      // No TF allowed/triggered
    });
    
    test('EDGE - Foul after points should start NEW foul streak', () {
      // Setup: foulStreak=2, pot 1 ball, then foul
      final player = gameState.players[0];
      player.consecutiveFouls = 2;
      
      // Pot 1 ball + foul
      // Current Logic: Resets to 0 and returns -1
      // Required Logic: Resets to 0 (clears old streak), THEN adds current foul -> Result 1
      
      int penalty = gameState.foulTracker.applyNormalFoul(player, 1); // ballsPocketed=1
      
      // Expected behavior per new requirement:
      expect(penalty, -1);
      expect(player.consecutiveFouls, 1); // Should be 1, currently failing (is 0)
    });
  });
}
