import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/services/shot_event_service.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:foulandfortune/widgets/game_event_overlay.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Re-rack splash clears after animation and restores a full rack',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final shotEventService = ShotEventService(db: db);

      final gameState = GameState(
        settings: GameSettings(player1Name: 'Alice', player2Name: 'Bob'),
        shotEventService: shotEventService,
      );

      addTearDown(() async {
        gameState.dispose();
        await db.close();
      });

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

      gameState.gameStarted = true;
      gameState.onBallTapped(1);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('RE-RACK!'), findsOneWidget);
      expect(gameState.activeBalls.length, 1);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump();

      expect(find.text('RE-RACK!'), findsNothing);
      expect(gameState.activeBalls.length, 15);
      expect(find.byType(Dialog), findsNothing);
    },
  );
}
