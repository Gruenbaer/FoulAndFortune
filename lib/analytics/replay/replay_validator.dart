
import 'replay_state.dart';

enum ValidationLevel {
  core,
  extended,
}

class ValidationReport {
  final bool isValid;
  final List<String> mismatches;
  final ValidationLevel level;

  ValidationReport({
    required this.isValid,
    required this.mismatches,
    required this.level,
  });

  @override
  String toString() {
    if (isValid) return 'Validation PASS ($level)';
    return 'Validation FAIL ($level):\n  - ${mismatches.join('\n  - ')}';
  }
}

class ReplayValidator {
  
  /// Validate a reconstructed state against a stored snapshot (JSON map).
  ValidationReport validate({
    required ReplayState rebuilt,
    required Map<String, dynamic> snapshot,
    ValidationLevel level = ValidationLevel.core,
  }) {
    final mismatches = <String>[];

    // 1. Scores & Stats (Core)
    if (snapshot.containsKey('players')) {
      final playersList = snapshot['players'] as List;
      for (final p in playersList) {
        final pMap = p as Map<String, dynamic>;
        
        // Handle ID which might be null in some legacy snapshots
        final id = pMap['id'] as String?;
        final name = pMap['name'] as String;
        
        // If ID is null, we can match by Name if needed, or skip?
        // ReplayState uses IDs from GameMeta.
        // Assuming GameMeta was built from Players table which has IDs.
        // If snapshot has no ID, we have a problem mapping.
        // But let's assume valid ID for v4.
        if (id == null) continue; // Skip if no ID

        final snapScore = pMap['score'] as int? ?? 0;
        final replayScore = rebuilt.scores[id] ?? 0;
        
        if (snapScore != replayScore) {
          mismatches.add('Score Mismatch for $name: Snapshot=$snapScore, Replay=$replayScore');
        }
        
        // Highest Run
        final snapHighRun = pMap['highestRun'] as int? ?? 0;
        final replayHighRun = rebuilt.highestRuns[id] ?? 0;
        if (snapHighRun != replayHighRun) {
            mismatches.add('High Run Mismatch for $name: Snapshot=$snapHighRun, Replay=$replayHighRun');
        }
      }
    }

    // 2. Innings (Core)
    // Also in player list usually.

    // 3. Winner / Completion (Core)
    final snapCompleted = snapshot['gameOver'] as bool? ?? false; // GameState.gameOver
    if (snapCompleted != rebuilt.isCompleted) {
       // Only fail if snapshot says completed but replay doesn't?
       // Or strict equality?
       mismatches.add('Completion Status Mismatch: Snapshot=$snapCompleted, Replay=${rebuilt.isCompleted}');
    }

    if (level == ValidationLevel.extended) {
       // Check active player
       // snapshot['currentPlayerIndex'] -> map to ID
    }

    return ValidationReport(
      isValid: mismatches.isEmpty,
      mismatches: mismatches,
      level: level,
    );
  }
}
