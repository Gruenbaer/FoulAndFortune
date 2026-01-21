import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/games/base/game_rules.dart' as rules;
import 'package:foulandfortune/games/base/rule_outcome.dart';
import 'package:foulandfortune/games/straight_pool/straight_pool_rules.dart';
import 'package:foulandfortune/games/straight_pool/straight_pool_state.dart';
import 'package:foulandfortune/core/actions/game_action.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/codecs/notation_codec.dart' as codec;

void main() {
  group('GameRules contract (extend for new games)', () {
    rules.CoreState buildCore({
      int activePlayerIndex = 0,
      int activeBallsCount = 15,
      List<int>? scores,
    }) {
      final players = [
        rules.Player(name: 'P1', score: scores?[0] ?? 0),
        rules.Player(name: 'P2', score: scores?[1] ?? 0),
      ];
      final activeBalls = <int>{};
      for (var i = 1; i <= activeBallsCount; i++) {
        activeBalls.add(i);
      }
      return rules.CoreState(
        players: players,
        activePlayerIndex: activePlayerIndex,
        inningNumber: 1,
        turnNumber: 1,
        activeBalls: activeBalls,
      );
    }

    StraightPoolState buildState({
      required StraightPoolRules rulesImpl,
      FoulMode foulMode = FoulMode.none,
      bool safeMode = false,
    }) {
      final settings = GameSettings(
        raceToScore: 50,
        player1Name: 'P1',
        player2Name: 'P2',
        threeFoulRuleEnabled: true,
      );
      final state = rulesImpl.initialState(settings) as StraightPoolState;
      state.pendingFoulMode = foulMode;
      state.pendingSafeMode = safeMode;
      return state;
    }

    test('StraightPoolRules metadata is defined', () {
      final rulesImpl = StraightPoolRules();
      expect(rulesImpl.gameId, isNotEmpty);
      expect(rulesImpl.displayName, isNotEmpty);
    });

    test('StraightPoolRules initialState can copy without mutation', () {
      final rulesImpl = StraightPoolRules();
      final state = buildState(rulesImpl: rulesImpl);
      final copy = state.copy();
      expect(copy.toJson(), state.toJson());
    });

    test('StraightPoolRules apply does not mutate rules state', () {
      final rulesImpl = StraightPoolRules();
      final core = buildCore();
      final actions = [
        const BallTappedAction(10),
        const BallTappedAction(1),
        const DoubleSackAction(),
        const SafeAction(),
      ];

      for (final action in actions) {
        final state = buildState(rulesImpl: rulesImpl);
        final before = state.toJson();
        rulesImpl.apply(action, core, state);
        expect(state.toJson(), before, reason: 'Action $action mutated rules state');
      }
    });

    test('StraightPoolRules ball tap ends turn on normal shot', () {
      final rulesImpl = StraightPoolRules();
      final state = buildState(rulesImpl: rulesImpl);
      final core = buildCore(activeBallsCount: 15);

      final outcome = rulesImpl.apply(const BallTappedAction(10), core, state);
      expect(outcome.rawPointsDelta, 5);
      expect(outcome.turnDirective, TurnDirective.endTurn);
      expect(outcome.endsInning, true);
      expect(outcome.tableDirective, isNull);
    });

    test('StraightPoolRules re-rack directive is emitted at 1 remaining', () {
      final rulesImpl = StraightPoolRules();
      final state = buildState(rulesImpl: rulesImpl);
      final core = buildCore(activeBallsCount: 15);

      final outcome = rulesImpl.apply(const BallTappedAction(1), core, state);
      expect(outcome.turnDirective, TurnDirective.continueTurn);
      expect(outcome.tableDirective, TableDirective.showOne);
      expect(outcome.endsInning, false);
      expect(
        outcome.stateMutations.whereType<SaveSegmentMutation>().length,
        1,
      );
      expect(
        outcome.stateMutations.whereType<MarkInningReRackMutation>().length,
        1,
      );
      final rerackEvents =
          outcome.events.whereType<ReRackEventDescriptor>().toList();
      expect(rerackEvents.length, 1);
      expect(rerackEvents.single.variant, 'reRack');
    });

    test('StraightPoolRules double-sack emits clear rack and rerack event', () {
      final rulesImpl = StraightPoolRules();
      final state = buildState(rulesImpl: rulesImpl);
      final core = buildCore(activeBallsCount: 15);

      final outcome = rulesImpl.apply(const DoubleSackAction(), core, state);
      expect(outcome.rawPointsDelta, 15);
      expect(outcome.turnDirective, TurnDirective.continueTurn);
      expect(outcome.tableDirective, TableDirective.clearRack);
      expect(outcome.endsInning, false);
      expect(
        outcome.events.whereType<ReRackEventDescriptor>().length,
        1,
      );
    });

    test('StraightPoolRules safe confirmation ends the inning', () {
      final rulesImpl = StraightPoolRules();
      final state = buildState(rulesImpl: rulesImpl, safeMode: true);
      final core = buildCore(activeBallsCount: 15);

      final outcome = rulesImpl.apply(const SafeAction(), core, state);
      expect(outcome.turnDirective, TurnDirective.endTurn);
      expect(outcome.endsInning, true);
      expect(
        outcome.stateMutations.whereType<MarkInningSafeMutation>().length,
        1,
      );
      expect(outcome.events.whereType<SafeEventDescriptor>().length, 1);
    });

    test('StraightPoolRules break foul decision switches or continues', () {
      final rulesImpl = StraightPoolRules();
      final core = buildCore(activePlayerIndex: 0);

      final switchState = buildState(rulesImpl: rulesImpl);
      final switchOutcome = rulesImpl.apply(
        const BreakFoulDecisionAction(1),
        core,
        switchState,
      );
      expect(switchOutcome.turnDirective, TurnDirective.endTurn);
      expect(switchOutcome.tableDirective, TableDirective.reRack);
      expect(switchOutcome.endsInning, true);
      expect(
        switchOutcome.stateMutations.whereType<DisableBreakFoulsMutation>().length,
        1,
      );

      final sameState = buildState(rulesImpl: rulesImpl);
      final sameOutcome = rulesImpl.apply(
        const BreakFoulDecisionAction(0),
        core,
        sameState,
      );
      expect(sameOutcome.turnDirective, TurnDirective.continueTurn);
      expect(sameOutcome.tableDirective, TableDirective.reRack);
      expect(sameOutcome.endsInning, false);
      expect(
        sameOutcome.stateMutations.whereType<DisableBreakFoulsMutation>().length,
        0,
      );
    });

    test('StraightPoolRules generateNotation uses canonical separator', () {
      final rulesImpl = StraightPoolRules();
      final sep = codec.NotationCodec.separator;
      final notation = rulesImpl.generateNotation(const rules.InningData(
        segments: [14, 0],
        isSafe: true,
        foulSuffix: 'F',
      ));
      expect(notation, '14${sep}0SF');
    });
  });
}
