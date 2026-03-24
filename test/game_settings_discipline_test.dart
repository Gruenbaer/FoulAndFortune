import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_settings.dart';

void main() {
  test('GameSettings stores and restores every supported discipline', () {
    for (final discipline in GameDiscipline.values) {
      final settings = GameSettings(
        discipline: discipline,
        player1Name: 'Alice',
        player2Name: 'Bob',
      );

      final json = settings.toJson();
      final restored = GameSettings.fromJson(json);

      expect(
        json['discipline'],
        discipline.storageKey,
        reason: 'Stored discipline key must stay stable for ${discipline.name}',
      );
      expect(
        restored.discipline,
        discipline,
        reason: 'Roundtrip must restore ${discipline.name}',
      );
    }
  });

  test('Unknown stored discipline falls back to straight pool', () {
    final restored = GameSettings.fromJson({
      'discipline': 'mystery_mode',
      'player1Name': 'Alice',
      'player2Name': 'Bob',
    });

    expect(restored.discipline, GameDiscipline.straightPool);
  });
}
