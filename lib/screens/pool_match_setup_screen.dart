import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../models/pool_match_state.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';
import 'pool_match_center_screen.dart';

class PoolMatchSetupScreen extends StatefulWidget {
  const PoolMatchSetupScreen({
    super.key,
    required this.discipline,
  });

  final GameDiscipline discipline;

  @override
  State<PoolMatchSetupScreen> createState() => _PoolMatchSetupScreenState();
}

class _PoolMatchSetupScreenState extends State<PoolMatchSetupScreen> {
  late final TextEditingController _player1Controller;
  late final TextEditingController _player2Controller;
  late double _raceValue;
  bool _alternatingBreaks = true;

  @override
  void initState() {
    super.initState();
    _player1Controller = TextEditingController(text: 'Player 1');
    _player2Controller = TextEditingController(text: 'Player 2');
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
        return 21;
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

  void _startMatch() {
    final p1 = _player1Controller.text.trim();
    final p2 = _player2Controller.text.trim();
    if (p1.isEmpty || p2.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => PoolMatchState(
            discipline: widget.discipline,
            raceTo: _raceValue.round(),
            alternatingBreaks: _alternatingBreaks,
            playerNames: [p1, p2],
          ),
          child: PoolMatchCenterScreen(discipline: widget.discipline),
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
          color: colors.backgroundCard.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.primary.withOpacity(0.3), width: 2),
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
                    Text('Spieler',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.textMain,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _player1Controller,
                      decoration: const InputDecoration(labelText: 'Player 1'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _player2Controller,
                      decoration: const InputDecoration(labelText: 'Player 2'),
                    ),
                  ],
                ),
              ),
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Race',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.textMain,
                          fontWeight: FontWeight.bold,
                        )),
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
                  ],
                ),
              ),
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Was du im Match-Center bekommst',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.textMain,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    Text(
                      '* Live Rack-Flow mit Breaker, Shooter, Ball-in-Hand und Match-Kontext\n'
                      '* Schnelle Aktionen fuer Safety, Foul, Dry Break, Push-Out und Rack-Wins\n'
                      '* Undo/Redo und eine laufende Match-Chronik\n'
                      '* Direkt sichtbare Stats statt Spaeter-Auswertung',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textMain.withOpacity(0.92),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              ThemedButton(
                label: '${widget.discipline.label} Starten',
                icon: Icons.play_circle_fill,
                onPressed: _startMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
