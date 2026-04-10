import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_record.dart';
import '../models/game_settings.dart' hide Player;
import '../models/pool_match_state.dart';
import '../services/game_history_service.dart';
import '../services/player_service.dart';
import '../theme/fortune_theme.dart';
import '../widgets/player_name_field.dart';
import '../widgets/themed_widgets.dart';
import 'pool_match_center_screen.dart';

class PoolMatchSetupScreen extends StatefulWidget {
  const PoolMatchSetupScreen({
    super.key,
    required this.discipline,
    this.playerService,
    this.gameHistoryService,
  });

  final GameDiscipline discipline;
  final PlayerService? playerService;
  final GameHistoryService? gameHistoryService;

  @override
  State<PoolMatchSetupScreen> createState() => _PoolMatchSetupScreenState();
}

class _PoolMatchSetupScreenState extends State<PoolMatchSetupScreen> {
  late final TextEditingController _player1Controller;
  late final TextEditingController _player2Controller;
  late final PlayerService _playerService;
  late final GameHistoryService _gameHistoryService;
  late double _raceValue;
  bool _alternatingBreaks = true;
  int _startingBreakerIndex = 0;
  bool _hasLoadedDefaults = false;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _playerService = widget.playerService ?? PlayerService();
    _gameHistoryService = widget.gameHistoryService ?? GameHistoryService();
    _player1Controller = TextEditingController();
    _player2Controller = TextEditingController();
    switch (widget.discipline) {
      case GameDiscipline.eightBall:
        _raceValue = 7;
        break;
      case GameDiscipline.nineBall:
        _raceValue = 9;
        break;
      case GameDiscipline.tenBall:
        _raceValue = 7;
        break;
      case GameDiscipline.onePocket:
        _raceValue = 3;
        break;
      case GameDiscipline.cowboy:
        _raceValue = 5;
        break;
      case GameDiscipline.straightPool:
        _raceValue = 50;
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedDefaults) return;
    _hasLoadedDefaults = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefaults());
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  int get _maxRace {
    switch (widget.discipline) {
      case GameDiscipline.eightBall:
        return 15;
      case GameDiscipline.nineBall:
      case GameDiscipline.tenBall:
        return 21;
      case GameDiscipline.onePocket:
        return 9;
      case GameDiscipline.cowboy:
        return 11;
      case GameDiscipline.straightPool:
        return 100;
    }
  }

  List<int> get _quickRaces {
    switch (widget.discipline) {
      case GameDiscipline.eightBall:
        return const [5, 7, 9];
      case GameDiscipline.nineBall:
        return const [7, 9, 11];
      case GameDiscipline.tenBall:
        return const [5, 7, 9];
      case GameDiscipline.onePocket:
        return const [2, 3, 5];
      case GameDiscipline.cowboy:
        return const [3, 5, 7];
      case GameDiscipline.straightPool:
        return const [50, 75, 100];
    }
  }

  Future<void> _loadDefaults() async {
    final settings = Provider.of<GameSettings>(context, listen: false);
    final players = await _playerService.getAllPlayers();
    final lastGame = await _gameHistoryService.getMostRecentGame();
    if (!mounted) return;

    final defaults = _resolveDefaultPlayers(
      settings: settings,
      lastGame: lastGame,
      players: players,
    );

    setState(() {
      _players = players;
      _player1Controller.text = defaults.$1;
      _player2Controller.text = defaults.$2;
    });
  }

  (String, String) _resolveDefaultPlayers({
    required GameSettings settings,
    required GameRecord? lastGame,
    required List<Player> players,
  }) {
    var player1Name = '';
    var player2Name = '';

    if (lastGame != null) {
      player1Name = lastGame.player1Name.trim();
      player2Name = lastGame.player2Name.trim();
    }

    if (player1Name.isEmpty) {
      player1Name = settings.player1Name.trim();
    }
    if (player2Name.isEmpty) {
      player2Name = settings.player2Name.trim();
    }

    if (player1Name.isEmpty && players.isNotEmpty) {
      player1Name = players.first.name;
    }
    if (player2Name.isEmpty && players.length > 1) {
      player2Name = players
          .firstWhere(
            (player) => player.name != player1Name,
            orElse: () => players[1],
          )
          .name;
    }

    return (player1Name, player2Name);
  }

  Future<String?> _resolvePlayerId(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    Player? existing;
    for (final player in _players) {
      if (player.name.toLowerCase() == trimmed.toLowerCase()) {
        existing = player;
        break;
      }
    }
    if (existing != null) {
      return existing.id;
    }

    final created = await _playerService.createPlayer(trimmed);
    _players = [..._players, created];
    return created.id;
  }

  Future<void> _createPlayerInline(TextEditingController controller) async {
    final trimmed = controller.text.trim();
    if (trimmed.isEmpty) return;
    final created = await _playerService.createPlayer(trimmed);
    if (!mounted) return;
    setState(() {
      _players = [..._players, created];
      controller.text = created.name;
    });
  }

  Future<void> _startMatch() async {
    final p1 = _player1Controller.text.trim();
    final p2 = _player2Controller.text.trim();
    if (p1.isEmpty || p2.isEmpty) return;

    final currentSettings = Provider.of<GameSettings>(context, listen: false);
    final updateSettings =
        Provider.of<Function(GameSettings)>(context, listen: false);
    final player1Id = await _resolvePlayerId(p1);
    final player2Id = await _resolvePlayerId(p2);
    if (!mounted) return;

    updateSettings(
      currentSettings.copyWith(
        player1Name: p1,
        player2Name: p2,
        player1Id: player1Id,
        player2Id: player2Id,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => PoolMatchState(
            discipline: widget.discipline,
            raceTo: _raceValue.round(),
            alternatingBreaks: _alternatingBreaks,
            initialBreakerIndex: _startingBreakerIndex,
            playerNames: [p1, p2],
          ),
          child: PoolMatchCenterScreen(discipline: widget.discipline),
        ),
      ),
    );
  }

  void _showHowToSheet() {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        decoration: BoxDecoration(
          color: colors.backgroundMain,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: 52,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                '${widget.discipline.label} Anleitung',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.discipline.quickHowTo.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '- $entry',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textMain,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Regelwerk',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.discipline.ruleBook.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '- $entry',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textMain.withValues(alpha: 0.92),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    Widget buildCard({required Widget child}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.backgroundCard.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: child,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.discipline.label} Setup'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Anleitung und Regeln',
            onPressed: _showHowToSheet,
          ),
        ],
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            children: [
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.discipline.label,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.discipline.setupHint,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.textMain,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spieler',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PlayerNameField(
                      key: const ValueKey('pool_player1_input'),
                      label: 'Player 1',
                      initialValue: _player1Controller.text,
                      players: _players,
                      onChanged: (name) {
                        _player1Controller.text = name;
                        setState(() {});
                      },
                      onCreatePlayer: () =>
                          _createPlayerInline(_player1Controller),
                    ),
                    const SizedBox(height: 12),
                    PlayerNameField(
                      key: const ValueKey('pool_player2_input'),
                      label: 'Player 2',
                      initialValue: _player2Controller.text,
                      players: _players,
                      onChanged: (name) {
                        _player2Controller.text = name;
                        setState(() {});
                      },
                      onCreatePlayer: () =>
                          _createPlayerInline(_player2Controller),
                    ),
                  ],
                ),
              ),
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Race',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Race to ${_raceValue.round()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Slider(
                      value: _raceValue,
                      min: 3,
                      max: _maxRace.toDouble(),
                      divisions: _maxRace - 3,
                      label: _raceValue.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _raceValue = value;
                        });
                      },
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _quickRaces
                          .map(
                            (race) => ChoiceChip(
                              label: Text('Race $race'),
                              selected: _raceValue.round() == race,
                              onSelected: (_) {
                                setState(() {
                                  _raceValue = race.toDouble();
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Alternating Breaks'),
                      subtitle: Text(() {
                        switch (widget.discipline) {
                          case GameDiscipline.eightBall:
                            return 'Ideal fuer faire Race-Sessions im 8-Ball.';
                          case GameDiscipline.nineBall:
                          case GameDiscipline.tenBall:
                            return 'Empfohlen fuer laengere Rotation-Matches.';
                          case GameDiscipline.onePocket:
                            return 'Hilft bei taktischen Sessions mit klaren Break-Wechseln.';
                          case GameDiscipline.cowboy:
                            return 'Sauber fuer abwechslungsreiche Hybrid-Sets.';
                          case GameDiscipline.straightPool:
                            return 'Der 14.1-Flow bleibt separat im bestehenden Screen.';
                        }
                      }()),
                      value: _alternatingBreaks,
                      onChanged: (value) {
                        setState(() {
                          _alternatingBreaks = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Wer stoesst an?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: Text(_player1Controller.text.trim().isEmpty
                              ? 'Player 1'
                              : _player1Controller.text.trim()),
                          selected: _startingBreakerIndex == 0,
                          onSelected: (_) {
                            setState(() {
                              _startingBreakerIndex = 0;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(_player2Controller.text.trim().isEmpty
                              ? 'Player 2'
                              : _player2Controller.text.trim()),
                          selected: _startingBreakerIndex == 1,
                          onSelected: (_) {
                            setState(() {
                              _startingBreakerIndex = 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Was du im Match-Center bekommst',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '* Live-Aufnahmefluss mit Breaker, Shooter, Ball-in-Hand und Match-Kontext\n'
                      '* Schnelle Aktionen fuer Safety, Foul, Dry Break, Push Out und Rack/Game/Set Win\n'
                      '* Undo/Redo und eine laufende Match-Chronik\n'
                      '* Ausgegraute Buttons bedeuten nur: Eine Voraussetzung ist aktuell nicht erfuellt',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textMain.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              ThemedButton(
                label: '${widget.discipline.label} Starten',
                icon: Icons.play_circle_fill,
                iconPosition: ThemedButtonIconPosition.top,
                forceSingleLineLabel: true,
                onPressed: _startMatch,
                onLongPress: _showHowToSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
