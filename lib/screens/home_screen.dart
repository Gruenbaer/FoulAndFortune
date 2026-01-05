import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
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
import '../widgets/themed_widgets.dart';
import '../theme/steampunk_theme.dart';
import '../services/game_history_service.dart';
import '../widgets/video_logo.dart';
import '../widgets/migration_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameRecord? _activeGame;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _checkActiveGame();
    _loadVersion();
    _checkAndMigrateNotation();
  }

  Future<void> _checkAndMigrateNotation() async {
    final historyService = GameHistoryService();
    final bool alreadyMigrated = await historyService.isMigrated();

    if (!alreadyMigrated && mounted) {
      // Check if there are any games to migrate
      final games = await historyService.getAllGames();
      
      if (games.isEmpty) {
        // No games to migrate, just mark as complete
        await historyService.markMigrated();
        return;
      }

      // Show migration dialog
      final bool? proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => MigrationDialog(
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      );

      if (proceed == true && mounted) {
        // Show progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MigrationProgressDialog(
            totalGames: games.length,
            migratedGames: 0,
          ),
        );

        try {
          final migratedCount = await historyService.migrateNotation();
          
          if (mounted) {
            Navigator.of(context).pop(); // Close progress dialog
            debugPrint('Successfully migrated $migratedCount games to Notation V2');
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close progress dialog
            
            // Show error dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Migration Failed'),
                content: Text('Failed to migrate game history: $e\n\nPlease contact support.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          debugPrint('Migration error: $e');
        }
      }
    }
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameState(
            settings: GameSettings(
              raceToScore: record.raceToScore,
              player1Name: record.player1Name,
              player2Name: record.player2Name,
              // Reconstruct other settings from record or defaults if missing in record
              // Assuming GameRecord stores standard settings:
              // threeFoulRuleEnabled, etc. might need to be added to GameRecord or defaulted.
              // For now, assuming defaults or minimal reconstruction.
            ),
            achievementManager:
                Provider.of<AchievementManager>(context, listen: false),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => NewGameSettingsScreen(
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
                              onPressed: () => _resumeGame(_activeGame!),
                            ),
                            const SizedBox(height: 16),
                          ],

                          ThemedButton(
                            label: l10n.new141Game,
                            icon: Icons.play_arrow,
                            onPressed: () => showNewGameSettings(context),
                          ),

                          ThemedButton(
                            label: l10n.gameHistory,
                            icon: Icons.history,
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
                          color: SteampunkTheme.steamWhite.withValues(alpha: 0.7),
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
