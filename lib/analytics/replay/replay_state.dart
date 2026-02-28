
/// Metadata required to initialize a replay.
class GameMeta {
  final String gameId;
  final String discipline; // 'StraightPool', 'EightBall', etc.
  final int raceToScore;
  final DateTime startTime;
  final List<PlayerMeta> players;

  GameMeta({
    required this.gameId,
    required this.discipline,
    required this.raceToScore,
    required this.startTime,
    required this.players,
  });
}

class PlayerMeta {
  final String id;
  final String name;

  PlayerMeta({required this.id, required this.name});
}

/// Minimal, deterministic state reconstructed from events.
///
/// This state is pure data and does not contain UI logic or Flutter dependencies.
/// It serves as the source of truth for validating the database integrity.
class ReplayState {
  // Core State (Must match Snapshot)
  final Map<String, int> scores;
  final Map<String, int> fouls;
  final Map<String, int> innings;
  final Map<String, int> highestRuns;
  final Map<String, int> currentRuns; // Needed for run calculation
  
  String? activePlayerId;
  bool isCompleted;
  String? winnerId;

  // Extended State (Useful for deep validation)
  int currentTurnIndex;
  int currentShotIndex;
  
  // Specific to 14.1
  bool inBreakSequence; 

  ReplayState({
    required this.scores,
    required this.fouls,
    required this.innings,
    required this.highestRuns,
    required this.currentRuns,
    this.activePlayerId,
    this.isCompleted = false,
    this.winnerId,
    this.currentTurnIndex = 0,
    this.currentShotIndex = 0,
    this.inBreakSequence = true,
  });

  /// Create initial state from metadata
  factory ReplayState.initial(GameMeta meta) {
    final scores = <String, int>{};
    final fouls = <String, int>{};
    final innings = <String, int>{};
    final highestRuns = <String, int>{};
    final currentRuns = <String, int>{};

    for (final p in meta.players) {
      scores[p.id] = 0;
      fouls[p.id] = 0;
      innings[p.id] = 0;
      highestRuns[p.id] = 0;
      currentRuns[p.id] = 0;
    }

    return ReplayState(
      scores: scores,
      fouls: fouls,
      innings: innings,
      highestRuns: highestRuns,
      currentRuns: currentRuns,
      activePlayerId: meta.players.isNotEmpty ? meta.players.first.id : null,
      inBreakSequence: true, // Default start for 14.1
    );
  }

  /// Create a deep copy
  ReplayState copy() {
    return ReplayState(
      scores: Map.from(scores),
      fouls: Map.from(fouls),
      innings: Map.from(innings),
      highestRuns: Map.from(highestRuns),
      currentRuns: Map.from(currentRuns),
      activePlayerId: activePlayerId,
      isCompleted: isCompleted,
      winnerId: winnerId,
      currentTurnIndex: currentTurnIndex,
      currentShotIndex: currentShotIndex,
      inBreakSequence: inBreakSequence,
    );
  }
}
