import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/game_settings.dart';
import '../models/achievement_manager.dart';
import '../models/game_record.dart';
import '../services/game_history_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart'; // Ensure ThemedBackground is available
import 'game_screen.dart';
import 'details_screen.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  final GameHistoryService _historyService = GameHistoryService();
  List<GameRecord> _games = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'active', 'completed'

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    List<GameRecord> games;
    switch (_filter) {
      case 'active':
        games = await _historyService.getActiveGames();
        break;
      case 'completed':
        games = await _historyService.getCompletedGames();
        break;
      default:
        games = await _historyService.getAllGames();
    }

    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _deleteGame(String id) async {
    await _historyService.deleteGame(id);
    _loadGames();
  }

  Future<void> _clearAllHistory() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllGames),
        content: Text(l10n.confirmDeleteAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearAllHistory();
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = FortuneColors.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.gameHistory, style: theme.textTheme.displayMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.primary),
        actions: [
          if (_games.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: colors.primaryBright),
              onPressed: _clearAllHistory,
              tooltip: l10n.deleteAllGames,
            ),
        ],
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Filter tabs
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: colors.primaryDark, width: 2)),
                  color: colors.backgroundCard.withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: l10n.allGames,
                        value: 'all',
                        colors: colors,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: l10n.inProgress,
                        value: 'active',
                        colors: colors,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: l10n.completed,
                        value: 'completed',
                        colors: colors,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),

              // Game list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colors.accent))
                    : _games.isEmpty
                        ? _buildEmptyState(l10n, colors, theme)
                        : RefreshIndicator(
                            color: colors.accent,
                            backgroundColor: colors.backgroundCard,
                            onRefresh: _loadGames,
                            child: ListView.builder(
                              itemCount: _games.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                return _buildGameCard(
                                    _games[index], l10n, theme, colors);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label, 
    required String value, 
    required FortuneColors colors, 
    required ThemeData theme
  }) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _loadGames();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected 
              ? [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)] 
              : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? colors.backgroundMain // Contrast text on filled chip
                : colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, FortuneColors colors, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu, // Quill/History icon
            size: 64,
            color: colors.primaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noGamesYet,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.playGameToSeeHistory,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
      GameRecord game, AppLocalizations l10n, ThemeData theme, FortuneColors colors) {
    
    // Check if we are in Steampunk mode to optionally use the texture
    // But for consistency, let's use colors primarily.
    // However, user liked the heavy card feel, so we keep the structure.
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primaryDark),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 4),
        ],
      ),
      child: Dismissible(
        key: Key(game.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000), // Dark Red
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete, color: colors.primaryBright),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deleteGame),
              content: Text(l10n.confirmDeleteGame),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => _deleteGame(game.id),
        child: ListTile(
          onTap: () {
            if (!game.isCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => GameState(
                      settings: GameSettings(
                        raceToScore: game.raceToScore,
                        player1Name: game.player1Name,
                        player2Name: game.player2Name,
                        isTrainingMode: game.isTrainingMode,
                      ),
                      achievementManager: Provider.of<AchievementManager>(
                          context,
                          listen: false),
                    ),
                    child: GameScreen(
                      settings:
                          Provider.of<GameSettings>(context, listen: false),
                      onSettingsChanged: (s) {},
                      resumeGame: game,
                    ),
                  ),
                ),
              ).then((_) => _loadGames());
            } else {
              // Reconstruct state for verification/details
              final tempState = GameState(
                settings: GameSettings(
                  raceToScore: game.raceToScore,
                  player1Name: game.player1Name,
                  player2Name: game.player2Name,
                  isTrainingMode: game.isTrainingMode,
                ),
                achievementManager:
                    Provider.of<AchievementManager>(context, listen: false),
              );

              if (game.snapshot != null) {
                tempState.loadFromJson(game.snapshot!);
              } else {
                // Fallback for old records
                tempState.players[0].score = game.player1Score;
                tempState.players[1].score = game.player2Score;
                tempState.players[0].currentInning = game.player1Innings;
                tempState.players[1].currentInning = game.player2Innings;
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailsScreen(gameState: tempState)));
            }
          },
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            '${game.player1Name} vs ${game.player2Name}',
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '${l10n.score}: ${game.player1Score} - ${game.player2Score}',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: colors.accent),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(game.startTime)} • ${game.getFormattedDuration()}',
                style: theme.textTheme.bodySmall,
              ),
              if (game.isTrainingMode) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    border: Border.all(color: colors.primaryBright),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.trainingLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primaryBright, fontSize: 14),
                  ),
                ),
              ],
              if (game.isCompleted && game.winner != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    border: Border.all(color: colors.primary), // Consistently use primary/info for "winner"
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${l10n.winner}: ${game.winner}',
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary, fontSize: 14),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    border: Border.all(color: colors.accent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.inProgress,
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.accent, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
          trailing: game.isCompleted
              ? Icon(Icons.check_circle, color: colors.primary)
              : Icon(Icons.timelapse, color: colors.accent),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
