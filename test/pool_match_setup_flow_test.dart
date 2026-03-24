import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/models/game_settings.dart';
import 'package:foulandfortune/models/pool_match_state.dart';
import 'package:foulandfortune/screens/pool_match_center_screen.dart';
import 'package:foulandfortune/screens/pool_match_setup_screen.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> useLargeSurface(WidgetTester tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1400, 2200));
  }

  Widget buildHarness(GameDiscipline discipline) {
    return MaterialApp(
      theme: CyberpunkTheme.themeData,
      home: PoolMatchSetupScreen(discipline: discipline),
    );
  }

  Widget buildCenterHarness(GameDiscipline discipline) {
    return MaterialApp(
      theme: CyberpunkTheme.themeData,
      home: ChangeNotifierProvider(
        create: (_) => PoolMatchState(
          discipline: discipline,
          raceTo: 5,
          playerNames: const ['Alice', 'Bob'],
        ),
        child: PoolMatchCenterScreen(discipline: discipline),
      ),
    );
  }

  testWidgets('nine-ball setup shows correct quick races', (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildHarness(GameDiscipline.nineBall));
    await tester.pumpAndSettle();

    expect(find.text('9-Ball Setup'), findsOneWidget);
    expect(find.text('Race 7'), findsOneWidget);
    expect(find.text('Race 9'), findsWidgets);
    expect(find.text('Race 11'), findsOneWidget);
  });

  testWidgets('eight-ball center exposes table group controls', (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarness(GameDiscipline.eightBall));
    await tester.pumpAndSettle();

    expect(find.text('8-Ball'), findsWidgets);
    expect(find.text('Tisch / Gruppen'), findsOneWidget);
    expect(find.text('Open Table'), findsOneWidget);
    expect(find.text('Solids'), findsOneWidget);
    expect(find.text('Stripes'), findsOneWidget);
  });

  testWidgets('nine-ball center shows pressure and control stats',
      (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarness(GameDiscipline.nineBall));
    await tester.pumpAndSettle();

    expect(find.text('9-Ball'), findsWidgets);
    expect(find.textContaining('Pressure'), findsWidgets);
    expect(find.textContaining('Control'), findsWidgets);
    expect(find.textContaining('Push'), findsWidgets);
  });

  testWidgets('one-pocket setup reflects discipline-specific defaults',
      (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildHarness(GameDiscipline.onePocket));
    await tester.pumpAndSettle();

    expect(find.text('1-Pocket Setup'), findsOneWidget);
    expect(find.text('Race 2'), findsOneWidget);
    expect(find.text('Race 3'), findsWidgets);
    expect(find.text('Race 5'), findsOneWidget);
    expect(
      find.textContaining('Taktischer Defensivmodus'),
      findsOneWidget,
    );
  });

  testWidgets('cowboy setup reflects discipline-specific defaults',
      (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildHarness(GameDiscipline.cowboy));
    await tester.pumpAndSettle();

    expect(find.text('Cowboy Setup'), findsOneWidget);
    expect(find.text('Race 3'), findsOneWidget);
    expect(find.text('Race 5'), findsWidgets);
    expect(find.text('Race 7'), findsOneWidget);
    expect(find.textContaining('Hybrid-Modus'), findsOneWidget);
  });

  testWidgets('center drawer offers rules and breaker switch', (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarness(GameDiscipline.nineBall));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Anleitung & Regelwerk'), findsOneWidget);
    expect(find.text('Breaking Player wechseln'), findsOneWidget);

    await tester.tap(find.text('Breaking Player wechseln'));
    await tester.pumpAndSettle();

    expect(find.text('Breaking Player wechseln'), findsWidgets);
    expect(find.text('Bob'), findsWidgets);
  });

  testWidgets('long press on action button shows explanation', (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarness(GameDiscipline.eightBall));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('SAFETY').first);
    await tester.pumpAndSettle();

    expect(find.text('Safety'), findsOneWidget);
    expect(find.textContaining('Defensivstoss'), findsOneWidget);
  });

  testWidgets('setup allows choosing the starting breaker', (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(buildHarness(GameDiscipline.tenBall));
    await tester.pumpAndSettle();

    expect(find.text('Wer stoesst an?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Player 2'));
    await tester.pumpAndSettle();

    final bobChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Player 2'),
    );
    expect(bobChip.selected, isTrue);
  });
}
