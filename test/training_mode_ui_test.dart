import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foulandfortune/widgets/victory_splash.dart';
import 'package:foulandfortune/widgets/score_card.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/codecs/notation_codec.dart'; // Correct import
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';

Widget createTestWidget({required Widget child}) {
  return MultiProvider(
    providers: [
      Provider<GameSettings>(create: (_) => GameSettings()),
    ],
    child: MaterialApp(
      theme: CyberpunkTheme.themeData, // Use real theme
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('VictorySplash in Training Mode hides opponent', (WidgetTester tester) async {
    final p1 = Player(name: 'Hero');
    p1.score = 50;
    final p2 = Player(name: 'Dummy');
    p2.score = 0;

    await tester.pumpWidget(createTestWidget(
      child: VictorySplash(
        player1: p1,
        player2: p2,
        winner: p1,
        raceToScore: 50,
        inningRecords: const [],
        elapsedDuration: const Duration(minutes: 5),
        onNewGame: () {},
        onExit: () {},
        isTrainingMode: true,
      ),
    ));

    await tester.pump(const Duration(seconds: 1));

    // Check for "TRAINING COMPLETE"
    expect(find.text('TRAINING COMPLETE'), findsOneWidget);

    // Verify P1 is shown
    expect(find.text('HERO'), findsWidgets);
    expect(find.text('50'), findsWidgets); // Score

    // Verify P2 is NOT shown
    // 'DUMMY' should not be visible as a header or score column
    expect(find.text('DUMMY'), findsNothing);
  });

  testWidgets('VictorySplash in Normal Mode shows both players', (WidgetTester tester) async {
    final p1 = Player(name: 'Player 1');
    final p2 = Player(name: 'Player 2');

    await tester.pumpWidget(createTestWidget(
      child: VictorySplash(
        player1: p1,
        player2: p2,
        winner: p1,
        raceToScore: 50,
        inningRecords: const [],
        elapsedDuration: const Duration(minutes: 5),
        onNewGame: () {},
        onExit: () {},
        isTrainingMode: false,
      ),
    ));

    await tester.pump(const Duration(seconds: 1));

    // Check for "VICTORY" (default text)
    // Note: AppLocalizations might return specific text. Default is usually "VICTORY"
    // We can just check that "TRAINING COMPLETE" is NOT present.
    expect(find.text('TRAINING COMPLETE'), findsNothing);
    expect(find.text('PLAYER 1'), findsWidgets);
    expect(find.text('PLAYER 2'), findsWidgets);
  });

  testWidgets('ScoreCard in Training Mode hides opponent', (WidgetTester tester) async {
    final p1 = Player(name: 'Hero');
    final p2 = Player(name: 'Dummy');

    await tester.pumpWidget(createTestWidget(
      child: Scaffold( // Requires Material
        body: ScoreCard(
          player1: p1,
          player2: p2,
          inningRecords: const [],
          winnerName: 'Hero',
          isTrainingMode: true,
        ),
      ),
    ));

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('HERO'), findsWidgets);
    expect(find.text('DUMMY'), findsNothing);
  });
}
