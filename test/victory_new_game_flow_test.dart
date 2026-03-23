import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';
import 'package:foulandfortune/main.dart' as app;
import 'package:foulandfortune/models/achievement_manager.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/screens/new_game_settings_screen.dart';
import 'package:foulandfortune/screens/game_screen.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/shot_event_service.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:foulandfortune/widgets/victory_splash.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const wakelockChannel = MethodChannel('wakelock_plus');

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(wakelockChannel, (call) async => true);
  });

  tearDown(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(wakelockChannel, null);
  });

  testWidgets(
    'Victory new game opens the setup sheet',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final db = AppDatabase(NativeDatabase.memory());
      final achievementManager = AchievementManager(db: db);
      final shotEventService = ShotEventService(db: db);
      final gameHistoryService = GameHistoryService(db: db);
      final settings = GameSettings(
        player1Name: 'Alice',
        player2Name: 'Bob',
        themeId: 'cyberpunk',
        languageCode: 'en',
      );
      final gameState = GameState(
        settings: settings,
        achievementManager: achievementManager,
        shotEventService: shotEventService,
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        gameState.dispose();
        achievementManager.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AchievementManager>.value(
              value: achievementManager,
            ),
            ChangeNotifierProvider<GameState>.value(value: gameState),
            Provider<GameSettings>.value(value: settings),
            Provider<Function(GameSettings)>.value(value: (_) {}),
          ],
          child: MaterialApp(
            navigatorKey: app.navigatorKey,
            locale: const Locale('en'),
            theme: CyberpunkTheme.themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GameScreen(
              settings: settings,
              onSettingsChanged: (_) {},
              gameHistoryService: gameHistoryService,
            ),
          ),
        ),
      );

      await tester.pump();

      gameState.concedeGame(gameState.players[0]);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(VictorySplash), findsOneWidget);
      expect(find.text('NEW GAME'), findsOneWidget);

      await tester.ensureVisible(find.text('NEW GAME'));
      await tester.tap(find.text('NEW GAME'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(NewGameSettingsScreen), findsOneWidget);
    },
  );
}
