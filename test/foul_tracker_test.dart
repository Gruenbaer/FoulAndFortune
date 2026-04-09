import 'package:flutter_test/flutter_test.dart';
import 'package:foul_and_fortune/models/foul_tracker.dart';
import 'package:foul_and_fortune/models/player.dart';

void main() {
  group('FoulTracker.previewNormalFoul', () {
    test('predicts triple foul penalty at third pure foul without mutating player', () {
      final tracker = FoulTracker(threeFoulRuleEnabled: true);
      final player = Player(name: 'P1', consecutiveFouls: 2);

      final preview = tracker.previewNormalFoul(player, 0);

      expect(preview.penalty, -16);
      expect(preview.isTripleFoul, isTrue);
      expect(player.consecutiveFouls, 2);
    });

    test('predicts normal foul penalty when balls were pocketed in inning', () {
      final tracker = FoulTracker(threeFoulRuleEnabled: true);
      final player = Player(name: 'P1', consecutiveFouls: 2);

      final preview = tracker.previewNormalFoul(player, 5);

      expect(preview.penalty, -1);
      expect(preview.isTripleFoul, isFalse);
      expect(player.consecutiveFouls, 2);
    });

    test('matches applyNormalFoul result for same input', () {
      final tracker = FoulTracker(threeFoulRuleEnabled: true);
      final playerA = Player(name: 'A', consecutiveFouls: 2);
      final playerB = Player(name: 'B', consecutiveFouls: 2);

      final preview = tracker.previewNormalFoul(playerA, 0);
      final applied = tracker.applyNormalFoul(playerB, 0);

      expect(applied.penalty, preview.penalty);
      expect(applied.isTripleFoul, preview.isTripleFoul);
      expect(playerB.consecutiveFouls, 0);
    });
  });
}
