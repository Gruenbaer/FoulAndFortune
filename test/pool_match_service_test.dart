import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/pool_match_state.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';
import 'package:foulandfortune/services/pool_match_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test(
      'PoolMatchService persists active and completed matches with player stats',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());

    final historyService = GameHistoryService(db: db);
    final playerService = PlayerService(db: db);
    final service = PoolMatchService(
      historyService: historyService,
      playerService: playerService,
    );

    final match = PoolMatchState(
      discipline: GameDiscipline.nineBall,
      raceTo: 2,
      playerNames: const ['Alice', 'Bob'],
      alternatingBreaks: false,
    );

    await service.persistMatch(match);

    final activeGames = await historyService.getActiveGames();
    expect(activeGames, hasLength(1));
    expect(activeGames.first.isPoolMatch, true);
    expect(activeGames.first.discipline, GameDiscipline.nineBall);

    match.winRack();
    match.winRack();
    await service.persistMatch(match);

    final completed = await historyService.getCompletedGames();
    expect(completed, hasLength(1));
    expect(completed.first.winner, 'Alice');
    expect(completed.first.player1Score, 2);

    final alice = await playerService.getPlayerByName('Alice');
    final bob = await playerService.getPlayerByName('Bob');

    expect(alice, isNotNull);
    expect(bob, isNotNull);
    expect(alice!.gamesPlayed, 1);
    expect(alice.gamesWon, 1);
    expect(alice.totalPoints, 2);
    expect(bob!.gamesPlayed, 1);
    expect(bob.gamesWon, 0);
  });

  test('PoolMatchState snapshot can be restored for resume', () {
    final original = PoolMatchState(
      discipline: GameDiscipline.eightBall,
      raceTo: 5,
      playerNames: const ['Alice', 'Bob'],
    );

    original.assignTableGroup(TableGroup.solids);
    original.recordSafety();
    final restored = PoolMatchState.fromSnapshotJson(original.toSnapshotJson());

    expect(restored.discipline, GameDiscipline.eightBall);
    expect(restored.players[0].assignedGroup, TableGroup.solids);
    expect(restored.players[0].safeties, 1);
    expect(restored.currentPlayer.name, 'Bob');
  });
}
