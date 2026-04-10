import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/pool_match_state.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';
import 'package:foulandfortune/services/pool_match_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('PoolMatchState scenario matrix', () {
    test(
        'eight-ball live flow tracks visits, fouls, BIH win and snapshot state',
        () {
      final match = PoolMatchState(
        discipline: GameDiscipline.eightBall,
        raceTo: 2,
        playerNames: const ['Alice', 'Bob'],
      );

      match.assignTableGroup(TableGroup.solids);
      match.recordSafety();
      match.recordFoul();

      expect(match.players[0].assignedGroup, TableGroup.solids);
      expect(match.players[1].assignedGroup, TableGroup.stripes);
      expect(match.players[0].safeties, 1);
      expect(match.players[1].fouls, 1);
      expect(match.players[0].visits, 1);
      expect(match.players[1].visits, 1);
      expect(match.currentPlayer.name, 'Alice');
      expect(match.ballInHand, true);
      expect(match.canRecordBreakAndRun, false);
      expect(match.canRecordSpecialFinish, false);

      match.winRack();

      expect(match.players[0].rackWins, 1);
      expect(match.players[0].ballInHandWins, 1);
      expect(match.ballInHand, false);
      expect(match.rackNumber, 2);

      final snapshot = match.toSnapshotJson();
      expect(snapshot['discipline'], GameDiscipline.eightBall.storageKey);
      expect(snapshot['player1Innings'], isNull);
      expect((snapshot['actionLog'] as List).first, contains('wins the rack'));
    });

    test('nine-ball dry-break into push-out handoff updates stats and guards',
        () {
      final match = PoolMatchState(
        discipline: GameDiscipline.nineBall,
        raceTo: 3,
        playerNames: const ['Alice', 'Bob'],
      );

      expect(match.canRecordDryBreak, true);
      expect(match.canTogglePushOut, false);
      expect(match.canRecordBreakAndRun, true);
      expect(match.canRecordSpecialFinish, true);

      match.recordDryBreak();

      expect(match.players[0].dryBreaks, 1);
      expect(match.players[0].visits, 1);
      expect(match.currentPlayer.name, 'Bob');
      expect(match.canTogglePushOut, true);
      expect(match.canRecordBreakAndRun, false);
      expect(match.canRecordSpecialFinish, false);

      match.recordPushOut(keepCurrentPlayer: false);

      expect(match.players[1].pushes, 1);
      expect(match.players[1].visits, 1);
      expect(match.currentPlayer.name, 'Alice');
      expect(match.pushOutAvailable, false);
      expect(match.actionLog.first, contains('takes the next shot'));

      match.recordFoul();

      expect(match.players[0].fouls, 1);
      expect(match.players[0].visits, 2);
      expect(match.currentPlayer.name, 'Bob');
      expect(match.ballInHand, true);

      match.winRack(runOut: true);

      expect(match.players[1].rackWins, 1);
      expect(match.players[1].runOuts, 1);
      expect(match.players[1].ballInHandWins, 1);
    });

    test('ten-ball supports push-out keep-current-player branch', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.tenBall,
        raceTo: 3,
        playerNames: const ['Alice', 'Bob'],
      );

      match.recordDryBreak();
      expect(match.currentPlayer.name, 'Bob');
      expect(match.canTogglePushOut, true);

      match.recordPushOut(keepCurrentPlayer: true);

      expect(match.players[1].pushes, 1);
      expect(match.players[1].visits, 0);
      expect(match.currentPlayer.name, 'Bob');
      expect(match.pushOutAvailable, false);
      expect(match.actionLog.first, contains('stays at the table'));
    });

    test('one-pocket uses game wins and defensive live tracking', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.onePocket,
        raceTo: 2,
        playerNames: const ['Alice', 'Bob'],
      );

      expect(GameDiscipline.onePocket.singleScoreLabel, 'Game');
      expect(match.canTogglePushOut, false);
      expect(match.canRecordSpecialFinish, true);

      match.recordSafety();
      match.recordFoul();

      expect(match.players[0].safeties, 1);
      expect(match.players[1].fouls, 1);
      expect(match.players[0].visits, 1);
      expect(match.players[1].visits, 1);
      expect(match.currentPlayer.name, 'Alice');

      match.winRack();

      expect(match.players[0].rackWins, 1);
      expect(match.actionLog.first, contains('wins the rack'));
    });

    test('cowboy clean finish behaves as set-based scoring path', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.cowboy,
        raceTo: 2,
        playerNames: const ['Alice', 'Bob'],
      );

      expect(GameDiscipline.cowboy.singleScoreLabel, 'Set');
      expect(match.canRecordSpecialFinish, true);

      match.winRack(goldenBreak: true);

      expect(match.players[0].rackWins, 1);
      expect(match.players[0].goldenBreaks, 1);
      expect(match.actionLog.first, contains('wins the golden break'));
    });
  });

  test(
      'pool scenario persistence stores stats and snapshots but no notation field',
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
      raceTo: 1,
      playerNames: const ['Alice', 'Bob'],
      alternatingBreaks: false,
    );

    match.recordDryBreak();
    match.recordPushOut(keepCurrentPlayer: false);
    match.recordFoul();
    match.winRack(runOut: true);

    await service.persistMatch(match);

    final record = (await historyService.getCompletedGames()).single;

    expect(record.discipline, GameDiscipline.nineBall);
    expect(record.player1Innings, 2);
    expect(record.player2Innings, 1);
    expect(record.player1Fouls, 1);
    expect(record.player2Fouls, 0);
    expect(record.snapshot?['poolMatch'], true);
    expect(record.snapshot?['discipline'], GameDiscipline.nineBall.storageKey);
    expect(record.toJson().containsKey('notation'), false);

    final restored = GameRecord.fromJson(record.toJson());
    expect(restored.isPoolMatch, true);
    expect(restored.snapshot?['actionLog'], isNotEmpty);
  });
}
