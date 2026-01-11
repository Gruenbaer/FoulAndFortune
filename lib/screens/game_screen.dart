import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/game_state.dart';
// Explicit import needed after aliasing player_service
import '../models/game_settings.dart';
import '../models/achievement_manager.dart';
import '../widgets/ball_button.dart';
import '../widgets/player_plaque.dart';
import '../widgets/hint_bubble.dart';
import '../widgets/achievement_splash.dart';
import '../l10n/app_localizations.dart';
import '../models/game_record.dart';
import '../services/game_history_service.dart';
import 'settings_screen.dart';
import 'new_game_settings_screen.dart';
import 'details_screen.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';
import '../widgets/victory_splash.dart';
import '../widgets/game_clock.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/game_event_overlay.dart'; // Unified Overlay System
import '../widgets/game_control_button.dart';
// For Arial alternative (Lato/Roboto) if Arial not available, but user said Arial.
import '../services/player_service.dart' as stats; // For stats fetching
import '../utils/ui_utils.dart'; // Zoom Dialog Helper

class GameScreen extends StatefulWidget {
  final GameSettings settings;
  final Function(GameSettings) onSettingsChanged;

  final GameRecord? resumeGame;

  const GameScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.resumeGame,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameHistoryService _historyService = GameHistoryService();
  late String _gameId; // Unique ID for this game
  DateTime? _gameStartTime; // Track when game started
  bool _isCompletedSaved = false;



  // Rack Animation Controller
  late AnimationController _rackAnimationController;

  // Keys for Player Plaques (to track position for Flying Penalty)
  final GlobalKey<PlayerPlaqueState> _p1PlaqueKey =
      GlobalKey<PlayerPlaqueState>();
  final GlobalKey<PlayerPlaqueState> _p2PlaqueKey =
      GlobalKey<PlayerPlaqueState>();

  // Screen Shake Controller
  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeOffset;

  // Input Locking (Prevent rapid taps breaking state)
  bool _isInputLocked = false;
  
  // Victory State Tracking
  bool _victoryShown = false;

  void _handleInteraction(VoidCallback action) {
    if (_isInputLocked) return;
    
    setState(() {
      _isInputLocked = true;
    });

    try {
      action();
    } finally {
      // Lock for duration of typical animations (ball fade is 300ms, mostly)
      // 500ms allows safe buffer for state updates
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isInputLocked = false;
          });
        }
      });
    }
  }
 
  Future<void> _saveInProgressGame(GameState gameState) async {
    // Check if game is completed (score >= raceToScore)
    final p1 = gameState.players[0];
    final p2 = gameState.players[1];
    final player1Fouls =
        gameState.getTotalFoulsForPlayer(p1, includeCurrent: true);
    final player2Fouls =
        gameState.getTotalFoulsForPlayer(p2, includeCurrent: true);
    final winner = (p1.score >= gameState.raceToScore)
        ? p1
        : (p2.score >= gameState.raceToScore ? p2 : null);

    // Don't save as in-progress if actually completed
    if (winner != null || _gameStartTime == null) return;

    final record = GameRecord(
      id: _gameId,
      player1Name: p1.name,
      player2Name: p2.name,
      player1Score: p1.score,
      player2Score: p2.score,
      startTime: _gameStartTime!,
      isCompleted: false,
      raceToScore: gameState.raceToScore,
      player1Innings: p1.currentInning,
      player2Innings: p2.currentInning,
      player1Fouls: player1Fouls,
      player2Fouls: player2Fouls,
      activeBalls: gameState.activeBalls.toList(),
      player1IsActive: p1.isActive,
      snapshot: gameState.toJson(),
    );

    await _historyService.saveGame(record);
  }

  // ... _saveCompletedGame restored:
  Future<void> _saveCompletedGame(GameState gameState) async {
    // 1. Mark as saved immediately to prevent double-save
    if (_isCompletedSaved) return;
    _isCompletedSaved = true;

    final p1 = gameState.players[0];
    final p2 = gameState.players[1];
    final player1Fouls = gameState.getTotalFoulsForPlayer(p1);
    final player2Fouls = gameState.getTotalFoulsForPlayer(p2);
    final winner = gameState.winner;
    // If winner is null for some reason, determine by score
    final effectiveWinner = winner ??
        ((p1.score >= gameState.raceToScore)
            ? p1
            : (p2.score >= gameState.raceToScore ? p2 : null));

    if (effectiveWinner == null) return; // Should not happen if game is over

    final record = GameRecord(
      id: _gameId,
      player1Name: p1.name,
      player2Name: p2.name,
      player1Score: p1.score,
      player2Score: p2.score,
      startTime: _gameStartTime ?? DateTime.now(), // Fallback
      endTime: DateTime.now(),
      isCompleted: true,
      raceToScore: gameState.raceToScore,
      winner: effectiveWinner.name,
      player1Innings: p1.currentInning,
      player2Innings: p2.currentInning,
      player1Fouls: player1Fouls,
      player2Fouls: player2Fouls,
      activeBalls: [], // Cleared
      player1IsActive: false,
      snapshot: null, // Don't save snapshot for completed game
    );

    // Add matchLog if GameRecord supports it (it appeared missing in previous step view of GameRecord, let's omit if not there)
    // Looking at GameRecord file view, there is NO matchLog field. Removing it.

    await _historyService.saveGame(record);

    // 2. Update Persistent Player Stats
    try {
      final playerService = stats.PlayerService();

      // Helper to update a single player
      Future<void> updatePlayerStats(Player gamePlayer, int gameFouls, bool isWinner) async {
        final existingPlayer =
            await playerService.getPlayerByName(gamePlayer.name);
        if (existingPlayer != null) {
          // Increment stats
          existingPlayer.gamesPlayed += 1;
          if (isWinner) existingPlayer.gamesWon += 1;
          existingPlayer.totalPoints += gamePlayer.score;
          existingPlayer.totalInnings += gamePlayer.currentInning;
          existingPlayer.totalSaves += gamePlayer.saves;
          existingPlayer.totalFouls += gameFouls;

          await playerService.updatePlayer(existingPlayer);
        }
      }

      await updatePlayerStats(p1, player1Fouls, p1 == effectiveWinner);
      await updatePlayerStats(p2, player2Fouls, p2 == effectiveWinner);
    } catch (e) {
      debugPrint('Error updating player stats: \$e');
    }
  }

  Widget _buildTrainingStatsPanel(BuildContext context, GameState gameState) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final player = gameState.players[0];
    final isCyberpunk = colors.themeId == 'cyberpunk';
    final totalFouls = gameState.getTotalFoulsForPlayer(
      player,
      includeCurrent: !gameState.gameOver,
    );

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
          color: colors.primaryDark,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          color: colors.primaryDark,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
          color: colors.textMain,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          color: colors.textMain,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        shape: isCyberpunk
            ? BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colors.primaryDark,
                  width: 2,
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colors.primaryDark,
                  width: 2,
                ),
              ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.backgroundCard,
            Color.lerp(colors.backgroundCard, Colors.black, 0.4)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.trainingLabel.toUpperCase(),
            textAlign: TextAlign.end,
            style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.accent,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(
                  color: colors.accent,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildTrainingStatRow(
                'LR',
                _formatSigned(gameState.getDynamicInningScore(player)),
                labelStyle,
                valueStyle,
              ),
              _buildTrainingStatRow(
                'HR',
                player.highestRun.toString(),
                labelStyle,
                valueStyle,
              ),
              _buildTrainingStatRow(
                'AVG',
                _formatAverage(player),
                labelStyle,
                valueStyle,
              ),
              _buildTrainingStatRow(
                'SAVES',
                _formatZeroDash(player.saves),
                labelStyle,
                valueStyle,
              ),
              _buildTrainingStatRow(
                'FOULS',
                _formatZeroDash(totalFouls),
                labelStyle,
                valueStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTrainingStatRow(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label, style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(value, style: valueStyle),
        ),
      ],
    );
  }

  String _formatAverage(Player player) {
    final innings = player.currentInning > 0 ? player.currentInning : 1;
    return (player.score / innings).toStringAsFixed(1);
  }

  String _formatSigned(int value) {
    return value >= 0 ? '+$value' : '$value';
  }

  String _formatZeroDash(int value) {
    return value == 0 ? '-' : value.toString();
  }

  @override
  void initState() {
    super.initState();

    if (widget.resumeGame != null) {
      _gameId = widget.resumeGame!.id;
      _gameStartTime = widget.resumeGame!.startTime;
    } else {
      _gameId = DateTime.now().millisecondsSinceEpoch.toString();
      _gameStartTime = DateTime.now();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = Provider.of<GameState>(context, listen: false);
      
      // 1. Load data if resuming
      if (widget.resumeGame != null && widget.resumeGame!.snapshot != null) {
        gameState.loadFromJson(widget.resumeGame!.snapshot!);
      }
      
      // 2. Attach auto-save listener (ALWAYS)
      gameState.onSaveRequired = () {
        if (mounted) {
          _saveInProgressGame(gameState);
        }
      };
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final achievementManager =
          Provider.of<AchievementManager>(context, listen: false);
      achievementManager.onAchievementUnlocked = (achievement) {
        // Defer navigation until after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Show achievement as modal route for proper z-index
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AchievementSplash(
                achievement: achievement,
                onDismiss: () => Navigator.of(context).pop(),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      };
        });

    _rackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300), // Faster (was 1500)
    );
    // Start visible by default
    _rackAnimationController.value = 1.0;

    // Enable wakelock to keep screen awake during gameplay
    WakelockPlus.enable();

    // Initialize Red Flash Controller
    _screenShakeController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 600),
    );
    // Flash Opacity Animation (0 -> 0.4 -> 0)
    _screenShakeOffset = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(0.3, 0)), weight: 1), // Using Offset type to reuse variable, but it represents Opacity now
      TweenSequenceItem(tween: Tween(begin: const Offset(0.3, 0), end: Offset.zero), weight: 3),
    ]).animate(_screenShakeController);
  }

  @override
  void deactivate() {
    if (!mounted) return; // Guard
    // Save game on exit
    // ... logic same ...
    try {
      final gameState = Provider.of<GameState>(context, listen: false);
      if (!gameState.gameStarted) {
        // Maybe delete empty game?
      } else {
        _saveInProgressGame(gameState);
      }
    } catch (e) {
      // Ignore provider issues on dispose
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _rackAnimationController.dispose();
    _screenShakeController.dispose();
    // Disable wakelock when leaving game screen
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider for Undo/Redo button state
    final gameState = Provider.of<GameState>(context);
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isTrainingMode = gameState.settings.isTrainingMode;

    // Watch for Game Over state
    if (gameState.gameOver && gameState.winner != null) {
      // Use PostFrameCallback to avoid setstate during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure we haven't already shown the victory screen (avoid loop)
        // Checking if already popped?
        // Actually, check if we are already showing it?
        // GameState.gameOver sticks to true.
        // We need a local flag to know if we've handled it.
        // Or check if the top route is VictorySplash?
        // Using a local flag is safest.
        if (!_victoryShown) {
           _victoryShown = true;
           // Reuse the Concede logic which saves and pushes splash
           // But concede calls finalize, which is already done by checkWinCondition
           // So we just call the UI part:
           _saveCompletedGame(gameState);
           Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => VictorySplash(
                player1: gameState.players[0],
                player2: gameState.players[1],
                winner: gameState.winner!,
                raceToScore: gameState.raceToScore,
                inningRecords: gameState.inningRecords,
                elapsedDuration: gameState.elapsedDuration,
                onUndo: () {
                   gameState.undo();
                   _victoryShown = false; // Reset flag
                   Navigator.of(context).pop(); 
                },
                onNewGame: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                onExit: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                 return FadeTransition(opacity: animation, child: child);
              }
            ),
          );
        }
      });
    } else {
        // Reset flag if game is not over (e.g. undo happened)
        _victoryShown = false;
    }

    Future<void> openSettings() async {
      final updateSettings =
          Provider.of<Function(GameSettings)>(context, listen: false);
      final currentSettings =
          Provider.of<GameSettings>(context, listen: false);

      // Create a Settings object that reflects the CURRENT game state
      // This ensures the menu shows real names/scores, not defaults
      final activeGameSettings = currentSettings.copyWith(
        player1Name: gameState.players[0].name,
        player2Name: gameState.players[1].name,
        raceToScore: gameState.raceToScore,
        threeFoulRuleEnabled: gameState.foulTracker.threeFoulRuleEnabled,
        isTrainingMode: gameState.settings.isTrainingMode,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsScreen(
            currentSettings: activeGameSettings,
            onSettingsChanged: (newSettings) {
              // 1. Update Global Settings (Persistence)
              updateSettings(newSettings);

              // 2. Update Active Game State (In-Game)
              gameState.updateSettings(newSettings);
            },
          ),
        ),
      );
    }

    void showRestartConfirmation() {
      Navigator.pop(context); // Close drawer
      showZoomDialog(
        context: context,
        builder: (context) => GameAlertDialog(
          title: l10n.restartGame,
          content: Text(l10n.restartGameMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(color: colors.textMain)),
            ),
            TextButton(
              onPressed: () {
                gameState.resetGame();
                Navigator.pop(context);
              },
              child: Text(l10n.restart, style: TextStyle(color: colors.danger)),
            ),
          ],
        ),
      );
    }
    
    void concedeGameTo(Player winner) {
      // Use the robust method in GameState that finalizes the inning first
      gameState.concedeGame(winner);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
          _saveCompletedGame(gameState);
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => VictorySplash(
                player1: gameState.players[0],
                player2: gameState.players[1],
                winner: winner,
                raceToScore: gameState.raceToScore,
                inningRecords: gameState.inningRecords,
                elapsedDuration: gameState.elapsedDuration,
                onUndo: () {
                   gameState.undo();
                   Navigator.of(context).pop(); 
                },
                onNewGame: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                onExit: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                 return FadeTransition(opacity: animation, child: child);
              }
            ),
          );
      });
    }

    void showGiveUpConfirmation() {
      Navigator.pop(context); // Close drawer
      showZoomDialog(
        context: context,
        builder: (context) => GameAlertDialog(
          title: l10n.whoWonTitle,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               ThemedButton(
                 label: gameState.players[0].name,
                 onPressed: () {
                   Navigator.pop(context);
                   concedeGameTo(gameState.players[0]);
                 },
               ),
               const SizedBox(height: 12),
               ThemedButton(
                 label: gameState.players[1].name,
                 onPressed: () {
                   Navigator.pop(context);
                   concedeGameTo(gameState.players[1]);
                 },
               ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(color: colors.textMain)),
            ),
          ],
        ),
      );
    }

    void showRulesPopup() {
      Navigator.pop(context); // Close drawer
      showZoomDialog(
        context: context,
        builder: (context) => GameAlertDialog(
          title: l10n.gameRules,
          content: SingleChildScrollView(
            child: Text(
              l10n.gameRulesContent,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.back),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScreenShakeNotification>(
      onNotification: (notification) {
        _screenShakeController.forward(from: 0.0);
        return true;
      },
      child: AbsorbPointer(
        absorbing: _isInputLocked,
        child: Stack(
        children: [
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final l10n = AppLocalizations.of(context);
            final shouldExit = await showZoomDialog<bool>(
              context: context,
              builder: (context) => GameAlertDialog(
                title: l10n.exitGameTitle,
                content: Text(l10n.exitGameMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.exit),
                  ),
                ],
              ),
            );
            if (shouldExit == true) {
              if (context.mounted) {
                // Save in-progress game before exiting
                final gameState =
                    Provider.of<GameState>(context, listen: false);
                await _saveInProgressGame(gameState);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              iconTheme: IconThemeData(color: colors.primary),
              title: Text(
                l10n.straightPool,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    const Shadow(
                        blurRadius: 3,
                        color: Colors.black87,
                        offset: Offset(1, 1)),
                    Shadow(
                        blurRadius: 6,
                        color: colors.primary.withValues(alpha: 0.5),
                        offset: const Offset(0, 0)),
                  ],
                ),
              ),
              leading:
                  null, // Allow default drawer icon if needed, or remove if strictly no menu desired
              actions: [
                IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  color: colors.primary,
                  tooltip: l10n.details,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(gameState: gameState),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: colors.primary,
                  tooltip: l10n.settings,
                  onPressed: openSettings,
                ),
                GuardedIconButton(
                  icon: Icons.undo,
                  shadows: colors.themeId == 'cyberpunk'
                      ? [
                          BoxShadow(
                              color: colors.primary,
                              blurRadius: 10,
                              spreadRadius: 2),
                        ]
                      : [],
                  color: colors.primary,
                  tooltip: l10n.undo,
                  onPressed: gameState.canUndo ? gameState.undo : null,
                  isGuarded: _isInputLocked,
                ),
                GuardedIconButton(
                  icon: Icons.redo,
                  shadows: colors.themeId == 'cyberpunk'
                      ? [
                          BoxShadow(
                              color: colors.primary,
                              blurRadius: 10,
                              spreadRadius: 2),
                        ]
                      : [],
                  color: colors.primary,
                  tooltip: l10n.redo,
                  onPressed: gameState.canRedo ? gameState.redo : null,
                  isGuarded: _isInputLocked,
                ),
              ],
            ),
            drawer: Drawer(
              elevation: 100, // High elevation to appear above overlays
              backgroundColor: colors.backgroundMain, // Themed background
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: colors.backgroundCard, // Themed header background
                    ),
                    child: Center(
                      child: Text(
                        l10n.appTitle,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: colors.primary, // Themed text
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh, color: colors.primary),
                    title: Text(l10n.restartGame,
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.textMain)),
                    onTap: showRestartConfirmation,
                  ),
                  ListTile(
                    leading: Icon(Icons.flag_outlined, color: colors.warning), // Warning color for giving up
                    title: Text(l10n.giveUp,
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.textMain)),
                    onTap: showGiveUpConfirmation,
                  ),
                  ListTile(
                    leading: Icon(Icons.menu_book, color: colors.primary),
                    title: Text(l10n.gameRules,
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.textMain)),
                    onTap: showRulesPopup,
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: colors.primary),
                    title: Text(l10n.settings,
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.textMain)),
                    onTap: () async {
                      Navigator.pop(context);
                      await openSettings();
                    },
                  ),
                ],
              ),
            ),
            body: ThemedBackground(
              child: SafeArea(
                child: Consumer<GameState>(
                  builder: (context, gameState, child) {
                    // Game Events moved to GameEventOverlay
                    
                    // Reset completion flag if game is no longer over (after undo)
                    if (!gameState.gameOver && _isCompletedSaved) {
                      _isCompletedSaved = false;
                    }

                    // Check gameOver flag, not scores (prevents re-trigger after undo)
                    if (gameState.gameOver && gameState.winner != null && !_isCompletedSaved) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _saveCompletedGame(gameState);
                        _saveCompletedGame(gameState);
                        // Navigate to victory screen with Zoom Transition
                        // Use PUSH instead of PUSH REPLACEMENT to preserve GameState/Undo Stack
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    VictorySplash(
                              player1: gameState.players[0],
                              player2: gameState.players[1],
                              winner: gameState.winner!,
                              raceToScore: gameState.raceToScore,
                              inningRecords: gameState.inningRecords,
                              elapsedDuration: gameState.elapsedDuration,
                              onUndo: () {
                                 // Undo the winning shot
                                 gameState.undo();
                                 Navigator.of(context).pop(); 
                              },
                              onNewGame: () {
                                // Pop until home, then show new game settings
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                // Use post-frame callback to show modal after navigation settles
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final homeContext = Navigator.of(context).context;
                                  // Access HomeScreen's showNewGameSettings method
                                  // Note: We can't directly call it, so we'll replicate the modal logic
                                  final achievementManager = Provider.of<AchievementManager>(homeContext, listen: false);
                                  showModalBottomSheet(
                                    context: homeContext,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (modalContext) => NewGameSettingsScreen(
                                      onStartGame: (settings) {
                                        Navigator.pop(modalContext);
                                        Navigator.push(
                                          homeContext,
                                          MaterialPageRoute(
                                            builder: (context) => ChangeNotifierProvider(
                                              create: (_) => GameState(
                                                settings: settings,
                                                achievementManager: achievementManager,
                                              ),
                                              child: GameScreen(
                                                settings: settings,
                                                onSettingsChanged: (newSettings) {},
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                });
                              },
                              onExit: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              // Custom Zoom + Fade Transition
                              var curve = Curves.easeOutBack;
                              var scaleTween =
                                  Tween<double>(begin: 0.8, end: 1.0)
                                      .chain(CurveTween(curve: curve));
                              var fadeTween =
                                  Tween<double>(begin: 0.0, end: 1.0);

                              return FadeTransition(
                                opacity: animation.drive(fadeTween),
                                child: ScaleTransition(
                                  scale: animation.drive(scaleTween),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(
                                milliseconds:
                                    500), // Slightly slower for Victory
                          ),
                        );
                      });
                    }

                    return Column(
                      children: [
                        // Race to XX / Inning Counter - Fades from prominent to compact
                        AnimatedOpacity(
                          opacity: !gameState.gameStarted ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: !gameState.gameStarted
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Race to ${gameState.raceToScore}',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: colors.accent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                      shadows: [
                                        const Shadow(
                                            blurRadius: 4,
                                            color: Colors.black,
                                            offset: Offset(2, 2)),
                                        Shadow(
                                            blurRadius: 8,
                                            color:
                                                colors.accent.withValues(alpha: 0.6)),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        AnimatedOpacity(
                          opacity: gameState.gameStarted ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: gameState.gameStarted
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Left: Inning
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${l10n.inning}: ',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${gameState.currentPlayer.currentInning}',
                                              style: theme
                                                  .textTheme.headlineSmall
                                                  ?.copyWith(
                                                color: colors.accent,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 28,
                                                shadows: [
                                                  const Shadow(
                                                      blurRadius: 3,
                                                      color: Colors.black,
                                                      offset: Offset(1, 1)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Spacer
                                      const SizedBox(width: 32),
                                      // Right: Race to
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${l10n.raceTo} ',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: colors.primary
                                                    .withValues(alpha: 0.8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${gameState.raceToScore}',
                                              style: theme
                                                  .textTheme.headlineSmall
                                                  ?.copyWith(
                                                color: colors
                                                    .accent, // Green to match Inning
                                                fontWeight: FontWeight.w900,
                                                fontSize: 28,
                                                shadows: [
                                                  const Shadow(
                                                      blurRadius: 3,
                                                      color: Colors.black,
                                                      offset: Offset(1, 1)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Z-INDEX FIX: Use VerticalDirection.up to paint Clock FIRST, then Plaques ON TOP
                        // Layout: Bottom (First Child in List) -> Top (Last Child in List) in placement?
                        // No: Column with VerticalDirection.up places children from bottom to top.
                        // Order in List: [Clock, Plaques]
                        // Layout: Clock at Bottom, Plaques above it.
                        // Paint Order: Clock (index 0) paints first. Plaques (index 1) paints second.
                        // Result: Plaques paint ON TOP of Clock.
                        Column(
                          verticalDirection: VerticalDirection.up,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CLOCK (Bottom position, painted first)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: GameClock(),
                            ),

                            // 1. Players & Scores Header (Top position, painted second)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.backgroundCard,
                                border: Border(
                                    bottom: BorderSide(
                                        color: colors.primary, width: 2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: PlayerPlaque(
                                        key: _p1PlaqueKey,
                                        player: gameState.players[0],
                                        raceToScore: gameState.raceToScore,
                                        isLeft: true),
                                  ),
                                  // Switch Button or Spacer
                                  if (!isTrainingMode &&
                                      !gameState.gameStarted &&
                                      gameState.matchLog.isEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.swap_horiz, size: 28),
                                      color: colors.accent,
                                      onPressed: gameState.swapStartingPlayer,
                                      tooltip: 'Swap Sides',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    )
                                  else
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: isTrainingMode
                                        ? _buildTrainingStatsPanel(context, gameState)
                                        : PlayerPlaque(
                                            key: _p2PlaqueKey,
                                            player: gameState.players[1],
                                            raceToScore: gameState.raceToScore,
                                            isLeft: false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 4. Notification / Last Action (Overlay)
                        // Using SizedBox to prevent jump
                        SizedBox(
                          height: 24,
                          width: double.infinity,
                          child: gameState.lastAction != null
                              ? Container(
                                  // Removed background color as requested
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    gameState.lastAction!.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.primary, // Text is now primary color
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2,
                                          color: Colors.black.withValues(alpha: 0.8),
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : null,
                        ),

                        // 5. Ball Rack (Expanded to fill remaining space)
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Gears behind the rack
                              if (colors.themeId == 'steampunk')
                                Opacity(
                                  opacity: 0.1,
                                  child: Image.asset(
                                      'assets/images/ui/gears.png',
                                      fit: BoxFit.contain),
                                ),
                              // The Rack
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      16.0), // Reduced padding
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: _buildRackFormation(
                                          context, gameState),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Controls
                        // Controls (COMPACT)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                            // Foul Button (Toggle)
                            GameControlButton(
                              text: gameState.foulMode == FoulMode.none
                                  ? 'NO FOUL'
                                  : (gameState.foulMode == FoulMode.normal
                                      ? 'FOUL'
                                      : 'BREAK FOUL'),
                              subText: gameState.foulMode == FoulMode.none
                                  ? null
                                  : (gameState.foulMode == FoulMode.normal
                                      ? '-1'
                                      : '-2'),
                              isActive: gameState.foulMode != FoulMode.none,
                              activeColor: colors.danger,
                              isGuarded: _isInputLocked,
                              onPressed: () {
                                
                                // Cycle: None -> Normal -> Severe -> None
                                FoulMode next;
                                switch (gameState.foulMode) {
                                  case FoulMode.none:
                                    next = FoulMode.normal;
                                    break;
                                  case FoulMode.normal:
                                    next = gameState.canBreakFoul
                                        ? FoulMode.severe
                                        : FoulMode.none;
                                    break;
                                  case FoulMode.severe:
                                    next = FoulMode.none;
                                    break;
                                }
                                _handleInteraction(() => gameState.setFoulMode(next));
                              },
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Safe Button (Toggle)
                            GameControlButton(
                              text: 'SAFE',
                              isActive: gameState.isSafeMode,
                              activeColor: const Color(0xFF4CAF50), // Green for Safe
                              isGuarded: _isInputLocked,
                              onPressed: gameState.gameOver
                                  ? () {}
                                  : () {
                                      _handleInteraction(() => gameState.toggleSafeMode());
                                    },
                            ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Achievement Splash now shown via Navigator.push (see initState)

        // Pause Overlay
        const PauseOverlay(),
        
        // Red Flash Overlay (For Triple Foul)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _screenShakeController,
              builder: (context, child) {
                return ColoredBox(
                  color: Colors.red.withValues(alpha: _screenShakeOffset.value.dx.clamp(0.0, 1.0)),
                );
              },
            ),
          ),
        ),

        // Unified Game Event System (Splashes)
        const GameEventOverlay(),
      ],
    ), // Close Stack
    ), // Close AbsorbPointer
   ); // Close NotificationListener
  }

  List<Widget> _buildRackFormation(BuildContext context, GameState gameState) {
    // Calculate responsive ball size based on available screen space
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Account for UI elements: AppBar, Stats, Clock, Controls, Padding
    // AppBar ~56, Stats ~36, Clock ~32, Controls ~80, Padding ~50
    final availableHeight = screenHeight - 254;
    final availableWidth = screenWidth - 32; // 16px padding on each side

    // Calculate maximum ball size based on constraints
    // Rack is 5 balls wide
    final maxWidthBallSize = availableWidth / 5.2; // 5 balls + minimal spacing

    // Rack is 5 rows tall (with vertical offset = diameter * 0.866)
    // Total height = 4 * verticalOffset + diameter = 4 * (d * 0.866) + d = 4.464d
    final maxHeightBallSize =
        availableHeight / 4.6; // 4.464 + buffer for Double Sack label

    // Use the smaller of the two to ensure it fits - increased max to 200px
    final ballSize = (maxWidthBallSize < maxHeightBallSize
            ? maxWidthBallSize
            : maxHeightBallSize)
        .clamp(70.0, 200.0);
    final diameter = ballSize;

    // Tighter packing: Vertical distance = diameter * sin(60 degrees)
    final verticalOffset = diameter * 0.866025;

    final rows = [
      [1],
      [2, 3],
      [4, 5, 6],
      [7, 8, 9, 10],
      [11, 12, 13, 14, 15],
    ];

    // Total rack dimensions
    final rackWidth = 5 * diameter;
    final rackHeight = 4 * verticalOffset + diameter;



    // Helper to determine if a ball is interactive based on game state
    bool canInteractWithBall(GameState state, int ballNumber) {
      if (state.gameOver) return false;

      // 1. Terminating Actions (Safe, Foul, Break Foul) disable Continuation Actions (0, 1)
      bool isTerminatorActive = state.isSafeMode || state.foulMode != FoulMode.none;
      if (isTerminatorActive && (ballNumber == 0 || ballNumber == 1)) {
        return false;
      }

      // 2. Break Foul Mode (Severe) disable everything except Ball 15
      // (Note: Ball 0 and 1 are already caught by Terminator check above)
      if (state.foulMode == FoulMode.severe && ballNumber != 15) {
        return false;
      }

      // 3. Table Presence (for 1-15)
      // Ball 0 (Double Sack) is virtual/always present unless cleared. 
      // This check is usually done by caller for opacity, but for interactability:
      if (ballNumber != 0 && !state.activeBalls.contains(ballNumber)) {
        return false;
      }

      return true;
    }

    // Helper to validate and handle taps
    void handleTap(int ballNumber) {
      if (_isInputLocked) return;

      // Disable all ball interactions if game is over
      if (gameState.gameOver) return;

      // Enforce rule: cannot tap last ball during foul/safe
      // if (!canTapBall(ballNumber)) return; // Logic simplified, always true now

      if (gameState.foulMode == FoulMode.severe &&
          ballNumber != 15 &&
          ballNumber != 0) {
        // Trigger progressive hint
        gameState.reportBreakFoulError(ballNumber: ballNumber);
        // No dialog - just apply the foul directly
        return;
      }

      if (gameState.showBreakFoulHint) {
        gameState.setShowBreakFoulHint(false);
      }

      // Ball 15 during Break Foul is processed normally, no special dialog needed

      if (ballNumber == 0) {
        _handleInteraction(() => gameState.onDoubleSack());
      } else {
        _handleInteraction(() => gameState.onBallTapped(ballNumber));
      }
    }

    // A stack that contains ALL rack balls + Cue Ball + Hint Layer
    Widget rackStack = SizedBox(
      width: rackWidth,
      height: rackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rack Balls
          for (int r = 0; r < rows.length; r++)
            for (int c = 0; c < rows[r].length; c++)
              Positioned(
                left: (rackWidth - (rows[r].length * diameter)) / 2 +
                    (c * diameter),
                top: r * verticalOffset,
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Builder(
                    builder: (context) {
                      final int ballNum = rows[r][c];
                      final bool isOnTable = gameState.activeBalls.contains(ballNum);
                      
                      // Use centralized helper
                      final bool isInteractable = canInteractWithBall(gameState, ballNum);
                      
                      final double targetOpacity = !isOnTable ? 0.15 : (isInteractable ? 1.0 : 0.5);

                      return AnimatedBuilder(
                    animation: _rackAnimationController,
                    builder: (context, child) {
                      // Sequential Fade In Logic
                      int flatIndex = 0;
                      for (int i = 0; i < r; i++) {
                        flatIndex += rows[i].length;
                      }
                      flatIndex += c;

                      final double start = flatIndex * 0.05;
                      final double end = start + 0.3;

                      final animOpacity = Curves.easeOut.transform(
                          ((_rackAnimationController.value - start) /
                                  (end - start))
                              .clamp(0.0, 1.0));

                      return Opacity(
                        opacity: animOpacity,
                        child: child,
                      );
                    },
                    child: BallButton(
                      ballNumber: ballNum,
                      isActive: isInteractable,
                      opacity: targetOpacity, 
                      onTap: () => handleTap(ballNum),
                    ),
                  );
                },
              ),
            ),
          ),

          // Cue Ball (Double Sack)
          // Moved closer to Ball 1 (left: 0) to avoid cutoff.
          // Ball 1 is at 2*diameter. This puts it at 0, aligning with rack left edge.
          Positioned(
            left: 0,
            top: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: diameter,
                  height: diameter,
                    child: BallButton(
                    ballNumber: 0,
                    isActive: canInteractWithBall(gameState, 0),
                    // Cue Ball always visible if game not over, or handled by rack animation
                    // No separate opacity logic needed as it doesn't get "pocketed" in same way
                    onTap: () => handleTap(0),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Double Sack',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // Progressive Error Hint (Bubble) - Show only after 1st error (2nd+)
          // No barrier - taps go through to balls
          if (gameState.breakFoulErrorCount > 1)
            Positioned.fill(
              child: IgnorePointer(
                child: HintBubble(
                  key: ValueKey(gameState.breakFoulHintMessage),
                  message: gameState.breakFoulHintMessage,
                  // Target: Ball 15 top edge (pointer points DOWN to top of ball)
                  target: Offset(4.5 * diameter, 4 * verticalOffset),
                  containerWidth: rackWidth,
                ),
              ),
            ),
        ],
      ),
    );

    return [
      // Minimal padding for hint bubbles - center balls vertically
      const SizedBox(height: 40),
      rackStack,
    ];
  }


}
