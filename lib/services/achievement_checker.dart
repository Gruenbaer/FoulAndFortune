import 'package:flutter/foundation.dart';
import '../models/achievement_manager.dart';
import '../models/player.dart';
import '../models/game_state.dart';

/// Utility class for checking and unlocking achievements during gameplay
class AchievementChecker {
  /// Check for achievements after a player completes their inning
  static void checkAfterInning(Player player, AchievementManager manager) {
    // Run streak achievements (10, 20, 30, 40, 50)
    // Check all tiers - if they score 50, they should get all lower ones too
    final run = player.currentRun;
    
    if (run >= 10 && !manager.isUnlocked('streak_10')) {
      manager.unlock('streak_10', playerName: player.name);
    }
    if (run >= 20 && !manager.isUnlocked('streak_20')) {
      manager.unlock('streak_20', playerName: player.name);
    }
    if (run >= 30 && !manager.isUnlocked('streak_30')) {
      manager.unlock('streak_30', playerName: player.name);
    }
    if (run >= 40 && !manager.isUnlocked('streak_40')) {
      manager.unlock('streak_40', playerName: player.name);
    }
    if (run >= 50 && !manager.isUnlocked('streak_50')) {
      manager.unlock('streak_50', playerName: player.name);
    }
  }

  /// Check for achievements after a player wins the game
  static void checkAfterWin(
    Player winner,
    GameState state,
    AchievementManager manager,
  ) {
    try {
      // First win achievement
      if (!manager.isUnlocked('first_win')) {
        manager.unlock('first_win', playerName: winner.name);
      }

      // Perfect game (no fouls during the game)
      // Check if winner never committed a foul in any inning
      bool hadNoFouls = true;
      for (var record in state.inningRecords) {
        if (record.playerName == winner.name && 
            (record.notation.contains('F') || record.notation.contains('BF'))) {
          hadNoFouls = false;
          break;
        }
      }
      
      if (hadNoFouls && !manager.isUnlocked('perfect_game')) {
        manager.unlock('perfect_game', playerName: winner.name);
      }

      // Speed demon (< 10 innings)
      if (winner.currentInning < 10 && !manager.isUnlocked('speed_demon')) {
        manager.unlock('speed_demon', playerName: winner.name);
      }
    } catch (e) {
      // Fail silently - don't crash the game if achievement check fails
      debugPrint('Achievement check error: $e');
    }
  }
}
