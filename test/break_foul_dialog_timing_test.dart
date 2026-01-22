import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/widgets/game_event_overlay.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';

void main() {
  testWidgets(
    'Break foul decision dialog appears right after the splash animation',
    (tester) async {
      final gameState = GameState(
        settings: GameSettings(player1Name: 'Alice', player2Name: 'Bob'),
      );
      addTearDown(gameState.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<GameState>.value(
          value: gameState,
          child: MaterialApp(
            locale: const Locale('en'),
            theme: CyberpunkTheme.themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Stack(
                children: [
                  GameEventOverlay(),
                ],
              ),
            ),
          ),
        ),
      );

      gameState.setFoulMode(FoulMode.severe);
      gameState.gameStarted = true; // Avoid starting the game timer in tests.
      gameState.onBallTapped(15);

      await tester.pump();
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);

      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Who breaks next?'), findsOneWidget);
    },
  );
}
