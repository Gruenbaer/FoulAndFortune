import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_history_service.dart';
import '../services/player_service.dart';
import '../models/game_state.dart';
import '../models/game_record.dart';
import 'package:flutter/foundation.dart';

class HighestRunMigration {
  static const String _migrationKey = 'highest_run_recalculated_v1';

  static Future<void> runMigrationIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) ?? false) {
      return; // Already run
    }

    try {
      debugPrint('Starting historical highest run recalculation migration...');
      final historyService = GameHistoryService();
      final playerService = PlayerService();

      final allGames = await historyService.getCompletedGames();
      
      // Track highest runs for each player globally across all their games
      final Map<String, int> globalHighRuns = {};

      for (var game in allGames) {
        if (game.snapshot == null) continue;

        try {
          final snapshot = GameSnapshot.fromJson(game.snapshot!);
          
          int p1MaxRun = 0;
          int p2MaxRun = 0;

          // Parse inning records
          for (var record in snapshot.inningRecords) {
            // Note: Inning segments include handicap multiplier, but this is the best historical estimate we have
            int run = record.segments.fold(0, (sum, val) => sum + val);

            if (record.playerName == game.player1Name) {
              if (run > p1MaxRun) p1MaxRun = run;
            } else if (record.playerName == game.player2Name) {
              if (run > p2MaxRun) p2MaxRun = run;
            }
          }

          final newP1HR = p1MaxRun > game.player1HighestRun ? p1MaxRun : game.player1HighestRun;
          final newP2HR = p2MaxRun > game.player2HighestRun ? p2MaxRun : game.player2HighestRun;

          // If calculated runs are greater than stored (e.g. stored was 0 due to bug)
          if (newP1HR > game.player1HighestRun || newP2HR > game.player2HighestRun) {
            final newRecord = GameRecord(
              id: game.id,
              player1Name: game.player1Name,
              player2Name: game.player2Name,
              player1Score: game.player1Score,
              player2Score: game.player2Score,
              startTime: game.startTime,
              endTime: game.endTime,
              isCompleted: game.isCompleted,
              winner: game.winner,
              raceToScore: game.raceToScore,
              isTrainingMode: game.isTrainingMode,
              player1Innings: game.player1Innings,
              player2Innings: game.player2Innings,
              player1HighestRun: newP1HR,
              player2HighestRun: newP2HR,
              player1Fouls: game.player1Fouls,
              player2Fouls: game.player2Fouls,
              activeBalls: game.activeBalls,
              player1IsActive: game.player1IsActive,
              snapshot: game.snapshot, // preserve snapshot
            );
            await historyService.saveGame(newRecord);
          }

          // Update global map
          final p1Name = game.player1Name.toLowerCase();
          final p2Name = game.player2Name.toLowerCase();
          
          if (!globalHighRuns.containsKey(p1Name) || newP1HR > globalHighRuns[p1Name]!) {
            globalHighRuns[p1Name] = newP1HR;
          }
          if (!globalHighRuns.containsKey(p2Name) || newP2HR > globalHighRuns[p2Name]!) {
            globalHighRuns[p2Name] = newP2HR;
          }
        } catch (e) {
          debugPrint('Error parsing game snapshot for HR migration: $e');
        }
      }

      // Update Player records
      final players = await playerService.getAllPlayers();
      for (var player in players) {
        final lowerName = player.name.toLowerCase();
        if (globalHighRuns.containsKey(lowerName)) {
          final maxRun = globalHighRuns[lowerName]!;
          if (maxRun > player.highestRun) {
             player.highestRun = maxRun;
             await playerService.updatePlayer(player);
          }
        }
      }

      await prefs.setBool(_migrationKey, true);
      debugPrint('Successfully completed highest run migration.');
    } catch (e) {
      debugPrint('Error running highest run migration: $e');
    }
  }
}
