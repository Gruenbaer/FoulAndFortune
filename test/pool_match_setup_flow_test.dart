import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';
import 'package:foulandfortune/models/game_record.dart';
import 'package:foulandfortune/models/game_settings.dart' hide Player;
import 'package:foulandfortune/models/pool_match_state.dart';
import 'package:foulandfortune/screens/pool_match_center_screen.dart';
import 'package:foulandfortune/screens/pool_match_setup_screen.dart';
import 'package:foulandfortune/services/game_history_service.dart';
import 'package:foulandfortune/services/player_service.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:provider/provider.dart';

AppDatabase buildDb() => AppDatabase(NativeDatabase.memory());

class FakePlayerService extends PlayerService {
  FakePlayerService(List<Player> players, {required AppDatabase db})
      : _players = List<Player>.from(players),
        super(db: db);

  final List<Player> _players;

  @override
  Future<List<Player>> getAllPlayers() async => List<Player>.from(_players);

  @override
  Future<Player> createPlayer(String name) async {
    final created = Player(
      id: 'player-${_players.length + 1}',
      name: name,
    );
    _players.add(created);
    return created;
  }
}

class FakeGameHistoryService extends GameHistoryService {
  FakeGameHistoryService(this.record, {required AppDatabase db})
      : super(db: db);

  final GameRecord? record;

  @override
  Future<GameRecord?> getMostRecentGame() async => record;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> useLargeSurface(WidgetTester tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1400, 2200));
  }

  Widget buildHarness(
    GameDiscipline discipline, {
    GameSettings? settings,
    PlayerService? playerService,
    GameHistoryService? historyService,
    void Function(GameSettings)? onSettingsChanged,
  }) {
    return MultiProvider(
      providers: [
        Provider<GameSettings>.value(value: settings ?? GameSettings()),
        Provider<Function(GameSettings)>.value(
          value: onSettingsChanged ?? (_) {},
        ),
      ],
      child: MaterialApp(
        theme: CyberpunkTheme.themeData,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PoolMatchSetupScreen(
          discipline: discipline,
          playerService: playerService,
          gameHistoryService: historyService,
        ),
      ),
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

  Widget buildCenterHarnessWithMatch(PoolMatchState match) {
    return MaterialApp(
      theme: CyberpunkTheme.themeData,
      home: ChangeNotifierProvider.value(
        value: match,
        child: PoolMatchCenterScreen(discipline: match.discipline),
      ),
    );
  }

  testWidgets('nine-ball setup shows correct quick races', (tester) async {
    final db = buildDb();
    addTearDown(() => db.close());
    await useLargeSurface(tester);
    await tester.pumpWidget(
      buildHarness(
        GameDiscipline.nineBall,
        playerService: PlayerService(db: db),
        historyService: GameHistoryService(db: db),
      ),
    );
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
    final db = buildDb();
    addTearDown(() => db.close());
    await useLargeSurface(tester);
    await tester.pumpWidget(
      buildHarness(
        GameDiscipline.onePocket,
        playerService: PlayerService(db: db),
        historyService: GameHistoryService(db: db),
      ),
    );
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
    final db = buildDb();
    addTearDown(() => db.close());
    await useLargeSurface(tester);
    await tester.pumpWidget(
      buildHarness(
        GameDiscipline.cowboy,
        playerService: PlayerService(db: db),
        historyService: GameHistoryService(db: db),
      ),
    );
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

    expect(find.text('Hilfe & Tutorial'), findsOneWidget);
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
    expect(find.textContaining('abgeschlossene Aufnahme'), findsOneWidget);
  });

  testWidgets(
      'disabled push out explains missing prerequisite and does not open dialog',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.nineBall,
      raceTo: 5,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PUSH OUT').first);
    await tester.pumpAndSettle();

    expect(find.text('Push Out'), findsNothing);
    expect(match.pushOutAvailable, isFalse);
    expect(match.players[0].pushes, 0);

    await tester.longPress(find.text('PUSH OUT').first);
    await tester.pumpAndSettle();

    expect(find.text('Push Out'), findsOneWidget);
    expect(find.textContaining('nur nach einem Dry Break'), findsOneWidget);
  });

  testWidgets('push out dialog resolves next shooter and updates state',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.nineBall,
      raceTo: 5,
      playerNames: const ['Alice', 'Bob'],
    );
    match.recordDryBreak();

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PUSH OUT').first);
    await tester.pumpAndSettle();

    expect(find.text('Push Out'), findsOneWidget);
    expect(find.text('Gegner uebernimmt'), findsOneWidget);
    expect(find.text('Push-Spieler bleibt'), findsOneWidget);

    await tester.tap(find.text('Push-Spieler bleibt'));
    await tester.pumpAndSettle();

    expect(match.players[1].pushes, 1);
    expect(match.currentPlayer.name, 'Bob');
    expect(match.pushOutAvailable, isFalse);
  });

  testWidgets('break and run stays blocked after a foul and explains why',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.nineBall,
      raceTo: 5,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    await tester.tap(find.text('FOUL').first);
    await tester.pumpAndSettle();

    expect(match.ballInHand, isTrue);
    expect(match.currentPlayer.name, 'Bob');
    expect(match.players[0].rackWins, 0);

    await tester.tap(find.text('BREAK & RUN').first);
    await tester.pumpAndSettle();

    expect(match.players[0].rackWins, 0);
    expect(match.players[1].rackWins, 0);

    await tester.longPress(find.text('BREAK & RUN').first);
    await tester.pumpAndSettle();

    expect(find.text('Break & Run'), findsOneWidget);
    expect(find.textContaining('bleibt der Button grau'), findsOneWidget);
  });

  testWidgets('eight-ball widget flow tracks groups, safety, foul and rack win',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.eightBall,
      raceTo: 3,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Solids'));
    await tester.pumpAndSettle();

    expect(match.currentPlayer.assignedGroup, TableGroup.solids);
    expect(match.players[1].assignedGroup, TableGroup.stripes);

    await tester.tap(find.text('SAFETY').first);
    await tester.pumpAndSettle();

    expect(match.players[0].safeties, 1);
    expect(match.currentPlayer.name, 'Bob');

    await tester.tap(find.text('FOUL').first);
    await tester.pumpAndSettle();

    expect(match.players[1].fouls, 1);
    expect(match.ballInHand, isTrue);
    expect(match.currentPlayer.name, 'Alice');

    await tester.tap(find.text('RACK WIN').first);
    await tester.pumpAndSettle();

    expect(match.players[0].rackWins, 1);
    expect(find.text('1'), findsWidgets);
    expect(match.rackNumber, 2);
  });

  testWidgets('nine-ball widget flow handles dry break push-out and runout',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.nineBall,
      raceTo: 3,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DRY BREAK').first);
    await tester.pumpAndSettle();

    expect(match.players[0].dryBreaks, 1);
    expect(match.currentPlayer.name, 'Bob');
    expect(match.pushOutAvailable, isTrue);

    await tester.tap(find.text('PUSH OUT').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gegner uebernimmt'));
    await tester.pumpAndSettle();

    expect(match.players[1].pushes, 1);
    expect(match.currentPlayer.name, 'Alice');
    expect(match.players[1].visits, 1);

    await tester.tap(find.text('RUNOUT').first);
    await tester.pumpAndSettle();

    expect(match.players[0].rackWins, 1);
    expect(match.players[0].runOuts, 1);
    expect(match.rackNumber, 2);
  });

  testWidgets('one-pocket widget flow exposes game win and live stats',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.onePocket,
      raceTo: 2,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    expect(find.text('GAME WIN'), findsOneWidget);

    await tester.tap(find.text('SAFETY').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FOUL').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GAME WIN').first);
    await tester.pumpAndSettle();

    expect(match.players[0].rackWins, 1);
    expect(match.players[0].ballInHandWins, 1);

    await tester.tap(find.text('STATS').first);
    await tester.pumpAndSettle();

    expect(find.text('1-Pocket Live Stats'), findsOneWidget);
    expect(find.text('Ball-in-Hand Wins'), findsOneWidget);
    expect(find.text('Visits'), findsOneWidget);
  });

  testWidgets('cowboy widget flow exposes set win and clean finish',
      (tester) async {
    final match = PoolMatchState(
      discipline: GameDiscipline.cowboy,
      raceTo: 2,
      playerNames: const ['Alice', 'Bob'],
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(buildCenterHarnessWithMatch(match));
    await tester.pumpAndSettle();

    expect(find.text('SET WIN'), findsOneWidget);
    expect(find.text('CLEAN FINISH'), findsOneWidget);

    await tester.tap(find.text('CLEAN FINISH').first);
    await tester.pumpAndSettle();

    expect(match.players[0].rackWins, 1);
    expect(match.players[0].goldenBreaks, 1);

    await tester.tap(find.text('SET WIN').first);
    await tester.pumpAndSettle();

    expect(match.players[1].rackWins, 1);
    expect(match.rackNumber, 3);
  });

  testWidgets('setup allows choosing the starting breaker', (tester) async {
    final db = buildDb();
    addTearDown(() => db.close());
    await useLargeSurface(tester);
    await tester.pumpWidget(
      buildHarness(
        GameDiscipline.tenBall,
        playerService: PlayerService(db: db),
        historyService: GameHistoryService(db: db),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wer stoesst an?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Player 2'));
    await tester.pumpAndSettle();

    final bobChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Player 2'),
    );
    expect(bobChip.selected, isTrue);
  });

  testWidgets('setup preloads most recent game players as new default',
      (tester) async {
    final db = buildDb();
    addTearDown(() => db.close());
    final players = FakePlayerService([
      Player(id: 'p1', name: 'Alice'),
      Player(id: 'p2', name: 'Bob'),
    ], db: db);
    final history = FakeGameHistoryService(
      GameRecord(
        id: 'recent-game',
        player1Name: 'Alice',
        player2Name: 'Bob',
        player1Score: 7,
        player2Score: 5,
        startTime: DateTime.now(),
        isCompleted: true,
        raceToScore: 9,
      ),
      db: db,
    );

    await useLargeSurface(tester);
    await tester.pumpWidget(
      buildHarness(
        GameDiscipline.eightBall,
        settings: GameSettings(player1Name: 'Old 1', player2Name: 'Old 2'),
        playerService: players,
        historyService: history,
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Alice'), findsWidgets);
    expect(find.text('Bob'), findsWidgets);
  });
}
