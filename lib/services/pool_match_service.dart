import '../models/game_record.dart';
import '../models/pool_match_state.dart';
import 'game_history_service.dart';
import 'player_service.dart';

class PoolMatchService {
  PoolMatchService({
    GameHistoryService? historyService,
    PlayerService? playerService,
  })  : _historyService = historyService ?? GameHistoryService(),
        _playerService = playerService ?? PlayerService();

  final GameHistoryService _historyService;
  final PlayerService _playerService;

  Future<void> persistMatch(PoolMatchState match) async {
    final previous = await _historyService.getGameById(match.matchId);
    final record = _buildRecord(match);

    await _historyService.saveGame(record);

    if (match.matchOver && previous?.isCompleted != true) {
      await _applyPlayerStats(match);
    }
  }

  GameRecord _buildRecord(PoolMatchState match) {
    final p1 = match.players[0];
    final p2 = match.players[1];

    return GameRecord(
      id: match.matchId,
      player1Name: p1.name,
      player2Name: p2.name,
      player1Score: p1.rackWins,
      player2Score: p2.rackWins,
      startTime: match.startedAt,
      endTime: match.matchOver ? DateTime.now() : null,
      isCompleted: match.matchOver,
      winner: match.winner?.name,
      raceToScore: match.raceTo,
      isTrainingMode: false,
      player1Innings: p1.visits,
      player2Innings: p2.visits,
      player1HighestRun: _highRunProxy(p1),
      player2HighestRun: _highRunProxy(p2),
      player1Fouls: p1.fouls,
      player2Fouls: p2.fouls,
      snapshot: match.toSnapshotJson(),
    );
  }

  int _highRunProxy(PoolMatchPlayerStats player) {
    return [
      player.breakAndRuns,
      player.runOuts,
      player.goldenBreaks,
      player.momentum,
    ].reduce((a, b) => a > b ? a : b);
  }

  Future<void> _applyPlayerStats(PoolMatchState match) async {
    for (var index = 0; index < match.players.length; index++) {
      final stats = match.players[index];
      final existing = await _playerService.getPlayerByName(stats.name);
      final player = existing ?? await _playerService.createPlayer(stats.name);

      final updated = player.copyWith(
        gamesPlayed: player.gamesPlayed + 1,
        gamesWon: player.gamesWon + (match.winner?.name == stats.name ? 1 : 0),
        totalPoints: player.totalPoints + stats.rackWins,
        totalInnings: player.totalInnings + stats.visits,
        totalFouls: player.totalFouls + stats.fouls,
        totalSaves: player.totalSaves + stats.safeties,
        highestRun: _highRunProxy(stats) > player.highestRun
            ? _highRunProxy(stats)
            : player.highestRun,
      );
      await _playerService.updatePlayer(updated);
    }
  }
}
