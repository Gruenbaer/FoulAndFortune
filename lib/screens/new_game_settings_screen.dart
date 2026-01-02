import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart' hide Player;
import '../l10n/app_localizations.dart';
import '../widgets/themed_widgets.dart';
import '../widgets/player_name_field.dart';
import '../services/player_service.dart';
import '../widgets/foul_overlays.dart';

class NewGameSettingsScreen extends StatefulWidget {
  final Function(GameSettings) onStartGame;

  const NewGameSettingsScreen({
    super.key,
    required this.onStartGame,
  });

  @override
  State<NewGameSettingsScreen> createState() => _NewGameSettingsScreenState();
}

class _NewGameSettingsScreenState extends State<NewGameSettingsScreen> {
  late GameSettings _settings;
  double _raceSliderValue = 100;
  final bool _hasLoadedPlayerNames = false;
  bool _initialSettingsLoaded = false;

  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    // Initialize with default settings
    _settings = GameSettings();
    _raceSliderValue = _settings.raceToScore.toDouble();
    _loadPlayers();
    
    // Defer loading initial values from provider until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSettingsFromProvider();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadInitialSettingsFromProvider() {
    if (!mounted) return;

    try {
      final currentSettings = Provider.of<GameSettings>(context, listen: false);

      // 1. Check if Provider has any data (player names are key indicator)
      if (currentSettings.player1Name.isNotEmpty || currentSettings.player2Name.isNotEmpty) {
         setState(() {
           // Fully adopt the persisted settings
           _settings = currentSettings;
           // Update local UI state to match
           _raceSliderValue = _settings.raceToScore.toDouble();
         });
      }
      
      // 2. If Provider is empty (fresh start), names should have come from _loadSettings() in main.dart
      //    But wait, main.dart loads settings into _settingsNotifier. 
      //    NewGameSettingsScreen gets defaults from GameSettings() constructor in initState.
      //    We must check if the Provider (which holds the loaded settings) has data.
      
      // Actually, if we are here, Provider ALREADY points to the loaded settings from main.dart
      // So checking currentSettings SHOULD work. 
      // ISSUE: In initState, we did _settings = GameSettings(); which resets to defaults.
      // FIX: Check if we haven't manually set names yet, then pull from provider.
      
      // Note: We already check isNotEmpty above. If main.dart loaded data, it should be in currentSettings.
      
      setState(() {
        _initialSettingsLoaded = true;
      });
    } catch (e) {
      // Provider not available, ignore
    }
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.getAllPlayers();
    if (mounted) {
      setState(() {
        _players = players;
        _isLoadingPlayers = false;
      });
    }
  }

  Future<void> _createPlayerInline(String name) async {
    if (name.trim().isEmpty) return;

    try {
      await _playerService.createPlayer(name.trim());
      await _loadPlayers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .playerCreatedSnackbar(name.trim()))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newGameSetup),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Game Type
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gameType,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(l10n.leagueGame),
                    subtitle: Text(l10n.leagueGameSubtitle),
                    value: _settings.isLeagueGame,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(isLeagueGame: value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Race to Score
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.raceTo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Quick buttons
                  Row(
                    children: [
                      _buildRaceButton(25),
                      const SizedBox(width: 8),
                      _buildRaceButton(50),
                      const SizedBox(width: 8),
                      _buildRaceButton(100),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Slider
                  Row(
                    children: [
                      Text('${l10n.custom}: '),
                      Expanded(
                        child: Slider(
                          value: _raceSliderValue,
                          min: 25,
                          max: 200,
                          divisions: 35,
                          label: _raceSliderValue.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _raceSliderValue = value;
                              _settings = _settings.copyWith(
                                  raceToScore: value.round());
                            });
                          },
                        ),
                      ),
                      Text(
                        '${_raceSliderValue.round()}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Max Innings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.maxInnings,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Quick buttons
                  Row(
                    children: [
                      _buildInningsButton(25),
                      const SizedBox(width: 8),
                      _buildInningsButton(50),
                      const SizedBox(width: 8),
                      _buildInningsButton(100),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Slider (always visible)
                  Row(
                    children: [
                      Text('${l10n.custom}: '),
                      Expanded(
                        child: Slider(
                          value: _settings.maxInnings.toDouble().clamp(0, 200),
                          min: 0,
                          max: 200,
                          divisions: 40,
                          label: _settings.maxInnings == 0
                              ? 'Unlimited'
                              : _settings.maxInnings.toString(),
                          onChanged: (value) {
                            setState(() {
                              _settings =
                                  _settings.copyWith(maxInnings: value.round());
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          _settings.maxInnings == 0
                              ? l10n.unlimited
                              : '${_settings.maxInnings}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Players
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.playersTitle,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Player 1 Input
                  PlayerNameField(
                    key: const ValueKey('player1_input'),
                    label: l10n.player1,
                    initialValue: _settings.player1Name,
                    players: _players,
                    onChanged: (name) {
                      setState(() {
                        _settings = _settings.copyWith(player1Name: name);
                      });
                    },
                    onCreatePlayer: () async {
                      await _createPlayerInline(_settings.player1Name);
                    },
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text('${l10n.handicap}: '),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _settings.player1Handicap > 0
                            ? () => setState(() {
                                  _settings = _settings.copyWith(
                                      player1Handicap:
                                          _settings.player1Handicap - 5);
                                })
                            : null,
                      ),
                      Text('+${_settings.player1Handicap}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() {
                          _settings = _settings.copyWith(
                              player1Handicap: _settings.player1Handicap + 5);
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Player 2 Input
                  PlayerNameField(
                    key: const ValueKey('player2_input'),
                    label: l10n.player2,
                    initialValue: _settings.player2Name,
                    players: _players,
                    onChanged: (name) {
                      setState(() {
                        _settings = _settings.copyWith(player2Name: name);
                      });
                    },
                    onCreatePlayer: () async {
                      await _createPlayerInline(_settings.player2Name);
                    },
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text('${l10n.handicap}: '),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _settings.player2Handicap > 0
                            ? () => setState(() {
                                  _settings = _settings.copyWith(
                                      player2Handicap:
                                          _settings.player2Handicap - 5);
                                })
                            : null,
                      ),
                      Text('+${_settings.player2Handicap}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() {
                          _settings = _settings.copyWith(
                              player2Handicap: _settings.player2Handicap + 5);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Additional Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.additionalRules,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SwitchListTile(
                    title: Text(l10n.threeFoulRule),
                    subtitle: Text(l10n.threeFoulRuleSubtitle),
                    value: _settings.threeFoulRuleEnabled,
                    onChanged: (value) {
                      setState(() {
                        _settings =
                            _settings.copyWith(threeFoulRuleEnabled: value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Start Game Button
          // Start Game Button
          // Start Game Button
          ThemedButton(
            label: l10n.startGame.toUpperCase(),
            icon: Icons.play_circle_fill,
            onPressed: () {
              if (_arePlayersValid) {
                _startGame();
              } else {
                _showValidationSplash();
              }
            },
            backgroundGradientColors: _arePlayersValid
                ? [
                    Colors.green.shade900,
                    Colors.green.shade700,
                  ]
                : [
                    Colors.grey.shade800,
                    Colors.grey.shade700,
                  ],
            textColor: _arePlayersValid ? Colors.white : Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildRaceButton(int value) {
    final isSelected = _settings.raceToScore == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _raceSliderValue = value.toDouble();
            _settings = _settings.copyWith(raceToScore: value);
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.green,
          side: BorderSide(color: Colors.green.shade700, width: 2),
        ),
        child: Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInningsButton(int value) {
    final isSelected = _settings.maxInnings == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _settings = _settings.copyWith(maxInnings: value);
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          side: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        child: Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool get _arePlayersValid {
    // 1. Names must not be empty
    if (_settings.player1Name.isEmpty || _settings.player2Name.isEmpty) return false;
    
    // 2. Names must exist in the loaded players list (DB)
    final p1Exists = _players.any((p) => p.name == _settings.player1Name);
    final p2Exists = _players.any((p) => p.name == _settings.player2Name);
    
    return p1Exists && p2Exists;
  }

  void _showValidationSplash() {
    print('Showing Splash'); // Debug
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => FoulMessageOverlay(
        message: "SET\nPLAYERS\nFIRST!",
        textColor: Colors.deepOrangeAccent,
        onFinish: () {
          entry.remove();
        },
      ),
    );
    
    overlay.insert(entry);
  }

  void _startGame() {
    // Save settings globally (persisting player names)
    Provider.of<Function(GameSettings)>(context, listen: false)(_settings);

    // Both players are selected, start the game
    widget.onStartGame(_settings);
  }
}
