import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/pool_match_state.dart';
import '../models/achievement_manager.dart';
import '../models/game_record.dart';
import '../l10n/app_localizations.dart';
import 'game_screen.dart';
import '../screens/new_game_settings_screen.dart';
import '../screens/players_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/achievements_gallery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/game_history_screen.dart';
import '../screens/pool_match_center_screen.dart';
import '../screens/pool_match_setup_screen.dart';
import '../widgets/themed_widgets.dart';
import '../theme/fortune_theme.dart';
import '../services/game_history_service.dart';
import '../widgets/video_logo.dart';
import '../services/shot_event_service.dart';
import '../services/player_service.dart';
import '../data/app_database.dart'; // For appDatabase global

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameRecord? _activeGame;
  String _version = '';

  void _showModeInfo(GameDiscipline discipline) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (_) => GameAlertDialog(
        title: discipline.label,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              discipline.shortHomeHint,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textMain,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ...discipline.quickHowTo.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $entry'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schliessen'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkActiveGame();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  Future<void> _checkActiveGame() async {
    final games = await GameHistoryService().getActiveGames();
    if (mounted) {
      setState(() {
        _activeGame = games.isNotEmpty ? games.first : null;
      });
    }
  }

  void _resumeGame(GameRecord record) {
    if (record.isPoolMatch && record.snapshot != null) {
      final match = PoolMatchState.fromSnapshotJson(record.snapshot!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: match,
            child: PoolMatchCenterScreen(
              discipline: record.discipline,
            ),
          ),
        ),
      ).then((_) => _checkActiveGame());
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameState(
            settings: GameSettings(
              raceToScore: record.raceToScore,
              player1Name: record.player1Name,
              player2Name: record.player2Name,
              isTrainingMode: record.isTrainingMode,
              // Reconstruct other settings from record or defaults if missing in record
              // Assuming GameRecord stores standard settings:
              // threeFoulRuleEnabled, etc. might need to be added to GameRecord or defaulted.
              // For now, assuming defaults or minimal reconstruction.
            ),
            achievementManager:
                Provider.of<AchievementManager>(context, listen: false),
            shotEventService:
                ShotEventService(db: appDatabase), // Inject Service
          ),
          child: GameScreen(
            settings: Provider.of<GameSettings>(context, listen: false),
            onSettingsChanged: (s) {},
            resumeGame: record,
          ),
        ),
      ),
    ).then((_) => _checkActiveGame());
  }

  void showNewGameSettings(BuildContext context) {
    // Capture the AchievementManager before showing the modal
    // to avoid context issues when the modal is dismissed
    final achievementManager =
        Provider.of<AchievementManager>(context, listen: false);
    final playerService = PlayerService(db: appDatabase);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => NewGameSettingsScreen(
        playerService: playerService,
        onStartGame: (settings) {
          Navigator.pop(modalContext);
          Navigator.push(
            context, // Use the outer context, not modalContext
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => GameState(
                  settings: settings,
                  achievementManager:
                      achievementManager, // Use captured manager
                  shotEventService: ShotEventService(db: appDatabase),
                ),
                child: GameScreen(
                  settings: settings,
                  onSettingsChanged: (newSettings) {
                    Provider.of<Function(GameSettings)>(context, listen: false)(
                        newSettings);
                  },
                ),
              ),
            ),
          ).then((_) => _checkActiveGame());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      // Background handled by specialized widget
      body: Stack(
        children: [
          // Main content
          ThemedBackground(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // LOGO SECTION
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: VideoLogo(),
                    ),

                    const SizedBox(height: 48),

                    // MENU BUTTONS (Constrained width)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_activeGame != null) ...[
                            ThemedButton(
                              label:
                                  '${l10n.resume}: ${_activeGame!.player1Name} vs ${_activeGame!.player2Name}',
                              icon: Icons.play_circle_fill,
                              iconPosition: ThemedButtonIconPosition.top,
                              forceSingleLineLabel: true,
                              onPressed: () => _resumeGame(_activeGame!),
                            ),
                            const SizedBox(height: 16),
                          ],

                          ThemedButton(
                            label: l10n.new141Game,
                            icon: Icons.play_arrow,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () => showNewGameSettings(context),
                          ),

                          ThemedButton(
                            label: '8-Ball',
                            icon: Icons.sports_bar,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoolMatchSetupScreen(
                                    discipline: GameDiscipline.eightBall,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showModeInfo(GameDiscipline.eightBall),
                          ),

                          ThemedButton(
                            label: '9-Ball',
                            icon: Icons.adjust,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoolMatchSetupScreen(
                                    discipline: GameDiscipline.nineBall,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showModeInfo(GameDiscipline.nineBall),
                          ),

                          ThemedButton(
                            label: '10-Ball',
                            icon: Icons.blur_circular,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoolMatchSetupScreen(
                                    discipline: GameDiscipline.tenBall,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showModeInfo(GameDiscipline.tenBall),
                          ),

                          ThemedButton(
                            label: '1-Pocket',
                            icon: Icons.gpp_good,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoolMatchSetupScreen(
                                    discipline: GameDiscipline.onePocket,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showModeInfo(GameDiscipline.onePocket),
                          ),

                          ThemedButton(
                            label: 'Cowboy',
                            icon: Icons.auto_fix_high,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoolMatchSetupScreen(
                                    discipline: GameDiscipline.cowboy,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showModeInfo(GameDiscipline.cowboy),
                          ),

                          ThemedButton(
                            label: l10n.gameHistory,
                            icon: Icons.history,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GameHistoryScreen()),
                              );
                            },
                          ),

                          ThemedButton(
                            label: l10n.players,
                            icon: Icons.people_outline,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayersScreen()),
                              );
                            },
                          ),

                          ThemedButton(
                            label: l10n.statistics,
                            icon: Icons.bar_chart,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const StatisticsScreen()),
                              );
                            },
                          ),

                          // ACHIEVEMENTS BUTTON
                          ThemedButton(
                            label: l10n.achievements,
                            icon: Icons.emoji_events,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AchievementsGalleryScreen()),
                              );
                            },
                          ),

                          ThemedButton(
                            label: l10n.settings,
                            icon: Icons.settings_suggest,
                            iconPosition: ThemedButtonIconPosition.top,
                            forceSingleLineLabel: true,
                            onPressed: () async {
                              final currentSettings = Provider.of<GameSettings>(
                                  context,
                                  listen: false);
                              final updateSettings =
                                  Provider.of<Function(GameSettings)>(context,
                                      listen: false);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsScreen(
                                    currentSettings: currentSettings,
                                    onSettingsChanged: updateSettings,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // Space for cogs

                    // Version
                    if (_version.isNotEmpty)
                      Text(
                        _version,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: FortuneColors.of(context)
                              .textMain
                              .withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
