import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/pool_match_state.dart';

void main() {
  group('PoolMatchState support matrix', () {
    test('push-out is only enabled for nine-ball and ten-ball', () {
      final supported = {
        GameDiscipline.nineBall,
        GameDiscipline.tenBall,
      };

      for (final discipline in GameDiscipline.values) {
        final match = PoolMatchState(
          discipline: discipline,
          raceTo: 5,
          playerNames: const ['Alice', 'Bob'],
        );

        expect(
          discipline.supportsPushOut,
          supported.contains(discipline),
          reason: 'Support matrix drift for ${discipline.name}',
        );
        expect(
          match.pushOutAvailable,
          supported.contains(discipline),
          reason: 'Opening state mismatch for ${discipline.name}',
        );
      }
    });

    test('group assignment is only meaningful in eight-ball', () {
      final eightBall = PoolMatchState(
        discipline: GameDiscipline.eightBall,
        raceTo: 5,
        playerNames: const ['Alice', 'Bob'],
      );

      eightBall.assignTableGroup(TableGroup.solids);

      expect(eightBall.players[0].assignedGroup, TableGroup.solids);
      expect(eightBall.players[1].assignedGroup, TableGroup.stripes);

      for (final discipline in GameDiscipline.values.where(
        (value) => value != GameDiscipline.eightBall,
      )) {
        final match = PoolMatchState(
          discipline: discipline,
          raceTo: 5,
          playerNames: const ['Alice', 'Bob'],
        );

        match.assignTableGroup(TableGroup.solids);

        expect(match.players[0].assignedGroup, isNull);
        expect(match.players[1].assignedGroup, isNull);
      }
    });
  });

  group('PoolMatchState core flow', () {
    test('records wins, special finishes, undo and redo', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.nineBall,
        raceTo: 3,
        playerNames: const ['Alice', 'Bob'],
      );

      match.winRack(runOut: true);

      expect(match.players[0].rackWins, 1);
      expect(match.players[0].runOuts, 1);
      expect(match.canUndo, true);

      match.undo();

      expect(match.players[0].rackWins, 0);
      expect(match.players[0].runOuts, 0);
      expect(match.canRedo, true);

      match.redo();

      expect(match.players[0].rackWins, 1);
      expect(match.players[0].runOuts, 1);
      expect(match.actionLog.first, contains('wins'));
    });

    test('foul hands over turn and ball in hand', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.eightBall,
        raceTo: 5,
        playerNames: const ['Alice', 'Bob'],
      );

      match.recordFoul();

      expect(match.players[0].fouls, 1);
      expect(match.ballInHand, true);
      expect(match.currentPlayer.name, 'Bob');
    });

    test('dry break arms push-out flow for nine-ball', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.nineBall,
        raceTo: 5,
        playerNames: const ['Alice', 'Bob'],
      );

      match.recordDryBreak();

      expect(match.players[0].dryBreaks, 1);
      expect(match.currentPlayer.name, 'Bob');
      expect(match.pushOutAvailable, true);

      match.togglePushOut();

      expect(match.pushOutArmed, true);
      expect(match.players[1].pushes, 1);
    });

    test('match over exposes winner and snapshot metadata', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.onePocket,
        raceTo: 2,
        playerNames: const ['Alice', 'Bob'],
        alternatingBreaks: false,
      );

      match.winRack();
      match.winRack();

      expect(match.matchOver, true);
      expect(match.winner?.name, 'Alice');
      expect(match.scoreLine, '2:0');

      final snapshot = match.toSnapshotJson();

      expect(snapshot['poolMatch'], true);
      expect(snapshot['discipline'], GameDiscipline.onePocket.storageKey);
      expect(snapshot['scoreLine'], '2:0');
      expect((snapshot['players'] as List).length, 2);
    });

    test('reset clears the entire match state', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.cowboy,
        raceTo: 3,
        playerNames: const ['Alice', 'Bob'],
      );

      match.recordSafety();
      match.recordFoul();
      match.winRack(goldenBreak: true);
      match.resetMatch();

      for (final player in match.players) {
        expect(player.rackWins, 0);
        expect(player.safeties, 0);
        expect(player.fouls, 0);
        expect(player.goldenBreaks, 0);
      }
      expect(match.rackNumber, 1);
      expect(match.matchOver, false);
      expect(match.actionLog.first, 'Match reset');
    });

    test('advanced derived stats stay positive for aggressive players', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.tenBall,
        raceTo: 5,
        playerNames: const ['Alice', 'Bob'],
      );

      match.recordSafety();
      match.winRack(breakAndRun: true, runOut: true);

      expect(match.pressureIndexFor(0), greaterThan(0));
      expect(match.tableControlFor(0), greaterThan(0));
    });

    test('breaker can be switched manually for the current rack', () {
      final match = PoolMatchState(
        discipline: GameDiscipline.nineBall,
        raceTo: 5,
        playerNames: const ['Alice', 'Bob'],
      );

      match.setBreaker(1);

      expect(match.breakerIndex, 1);
      expect(match.activePlayerIndex, 1);
      expect(match.actionLog.first, contains('Breaker set to Bob'));
    });
  });
}
