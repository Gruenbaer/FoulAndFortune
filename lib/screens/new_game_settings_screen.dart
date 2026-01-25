import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart' hide Player;
import '../l10n/app_localizations.dart';
import '../widgets/player_name_field.dart';
import '../services/player_service.dart';
import '../theme/fortune_theme.dart';
import '../widgets/settings/settings_slider.dart';
import '../widgets/settings/settings_toggle.dart';
import '../widgets/settings/handicap_picker.dart';

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
  String? _cachedPlayer2Name;
  int? _cachedPlayer2Handicap;
  double? _cachedPlayer2Multiplier;
  bool _hasLoadedFromProvider = false;


  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];


  @override
  void initState() {
    super.initState();
    // Initialize with default settings (will be replaced in didChangeDependencies)
    _settings = GameSettings();
    _raceSliderValue = _settings.raceToScore.toDouble();
    _loadPlayers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load settings from provider once when dependencies are available
    if (!_hasLoadedFromProvider) {
      _hasLoadedFromProvider = true;
      
      try {
        final currentSettings = Provider.of<GameSettings>(context, listen: false);
        
        // Initialize from provider settings to preserve player names and all preferences
        // This ensures global settings (including player names) are populated
        setState(() {
          _settings = currentSettings.copyWith();
          _raceSliderValue = _settings.raceToScore.toDouble();
        });
      } catch (e) {
        // Provider not available, keep defaults
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setTrainingMode(bool enabled, AppLocalizations l10n) {
    setState(() {
      if (enabled) {
        _cachedPlayer2Name = _settings.player2Name;
        _cachedPlayer2Handicap = _settings.player2Handicap;
        _cachedPlayer2Multiplier = _settings.player2HandicapMultiplier;
        _settings = _settings.copyWith(
          isTrainingMode: true,
          player2Name: l10n.trainingOpponentName,
          player2Handicap: 0,
          player2HandicapMultiplier: 1.0,
        );
      } else {
        _settings = _settings.copyWith(
          isTrainingMode: false,
          player2Name: _cachedPlayer2Name ?? _settings.player2Name,
          player2Handicap: _cachedPlayer2Handicap ?? _settings.player2Handicap,
          player2HandicapMultiplier:
              _cachedPlayer2Multiplier ?? _settings.player2HandicapMultiplier,
        );
      }
    });
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.getAllPlayers();
    if (mounted) {
      setState(() {
        _players = players;
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
    final theme = Theme.of(context);
    final fortuneTheme = FortuneColors.of(context);

    Widget buildMultiplierSelector({
      required String playerName,
      required double value,
      required ValueChanged<double> onChanged,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(playerName, style: theme.textTheme.bodyLarge),
              Text(l10n.pointMultiplier, style: theme.textTheme.bodySmall),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: fortuneTheme.primaryDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: fortuneTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [1.0, 2.0, 3.0].map((val) {
                final isSelected = value == val;
                return GestureDetector(
                  onTap: () => setState(() => onChanged(val)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? fortuneTheme.secondary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '${val.toInt()}x',
                      style: TextStyle(
                        color: isSelected
                            ? fortuneTheme.textContrast
                            : fortuneTheme.primary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

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
                  SettingsToggle(
                    title: l10n.leagueGame,
                    subtitle: l10n.leagueGameSubtitle,
                    value: _settings.isLeagueGame,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(isLeagueGame: value);
                      });
                    },
                  ),
                  SettingsToggle(
                    title: l10n.trainingMode,
                    subtitle: l10n.trainingModeSubtitle,
                    value: _settings.isTrainingMode,
                    onChanged: (value) => _setTrainingMode(value, l10n),
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
              child: SettingsSlider(
                label: l10n.raceTo,
                value: _raceSliderValue,
                min: 25,
                max: 200,
                divisions: 35,
                quickValues: const [25, 50, 100],
                quickButtonColor: Colors.green,
                quickButtonBorderColor: Colors.green.shade700,
                onChanged: (value) {
                  setState(() {
                    _raceSliderValue = value;
                    _settings = _settings.copyWith(raceToScore: value.round());
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Max Innings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SettingsSlider(
                label: l10n.maxInnings,
                value: _settings.maxInnings.toDouble(),
                min: 0,
                max: 200,
                divisions: 40,
                quickValues: const [25, 50, 100],
                quickButtonColor: Colors.blue,
                quickButtonBorderColor: Colors.blue.shade700,
                valueFormatter: (value) => value.round() == 0 ? l10n.unlimited : value.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(maxInnings: value.round());
                  });
                },
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

                  HandicapPicker(
                    label: l10n.handicap,
                    value: _settings.player1Handicap,
                    step: 5,
                    minValue: 0,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(player1Handicap: value);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  buildMultiplierSelector(
                    playerName: _settings.player1Name,
                    value: _settings.player1HandicapMultiplier,
                    onChanged: (value) {
                      _settings =
                          _settings.copyWith(player1HandicapMultiplier: value);
                    },
                  ),

                  const SizedBox(height: 24),

                  if (!_settings.isTrainingMode) ...[
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

                    HandicapPicker(
                      label: l10n.handicap,
                      value: _settings.player2Handicap,
                      step: 5,
                      minValue: 0,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(player2Handicap: value);
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    buildMultiplierSelector(
                      playerName: _settings.player2Name,
                      value: _settings.player2HandicapMultiplier,
                      onChanged: (value) {
                        _settings = _settings.copyWith(
                            player2HandicapMultiplier: value);
                      },
                    ),
                  ],
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
                  SettingsToggle(
                    title: l10n.threeFoulRule,
                    subtitle: l10n.threeFoulRuleSubtitle,
                    value: _settings.threeFoulRuleEnabled,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(threeFoulRuleEnabled: value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Start Game Button
          ElevatedButton.icon(
            onPressed: _settings.hasValidPlayers ? _startGame : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _settings.hasValidPlayers
                  ? Colors.green.shade700
                  : Colors.grey.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade600,
              disabledForegroundColor: Colors.white60,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _settings.hasValidPlayers ? 4 : 0,
            ),
            icon: const Icon(Icons.play_circle_fill, size: 32),
            label: Text(
              l10n.startGame,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _startGame() {
    // Save settings globally (persisting player names)
    Provider.of<Function(GameSettings)>(context, listen: false)(_settings);

    // Both players are selected, start the game
    widget.onStartGame(_settings);
  }
}
