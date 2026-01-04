import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  bool _isLoading = true;
  String _sortBy = 'gamesPlayed'; // Default sort

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await _playerService.getAllPlayers();
    setState(() {
      _players = players;
      _sortPlayers();
      _isLoading = false;
    });
  }

  void _sortPlayers() {
    switch (_sortBy) {
      case 'gamesPlayed':
        _players.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
        break;
      case 'winRate':
        _players.sort((a, b) => b.winRate.compareTo(a.winRate));
        break;
      case 'avgPoints':
        _players.sort((a, b) => b.averagePointsPerGame.compareTo(a.averagePointsPerGame));
        break;
      case 'highestRun':
        _players.sort((a, b) => b.highestRun.compareTo(a.highestRun));
        break;
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
        title: Text(l10n.statistics, style: theme.textTheme.displayMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primary),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: colors.primary),
            color: colors.backgroundCard,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortPlayers();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'gamesPlayed', child: Text(l10n.gamesPlayed, style: theme.textTheme.bodyMedium)),
              PopupMenuItem(value: 'winRate', child: Text(l10n.winRate, style: theme.textTheme.bodyMedium)),
              PopupMenuItem(value: 'avgPoints', child: Text(l10n.avgPoints, style: theme.textTheme.bodyMedium)),
              PopupMenuItem(value: 'highestRun', child: Text(l10n.highestRun, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ],
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: colors.accent))
              : _players.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 64, color: colors.primaryDark),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noStatistics,
                            style: theme.textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.playGamesToSee,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: colors.accent,
                      backgroundColor: colors.backgroundCard,
                      onRefresh: _loadPlayers,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Overall Stats Card
                          _buildOverallStatsCard(l10n, colors, theme),
                          
                          const SizedBox(height: 24),
                          
                          // Player Rankings Header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: colors.primary, width: 2)),
                              gradient: LinearGradient(
                                colors: [colors.primaryDark.withValues(alpha: 0.5), Colors.transparent],
                              ),
                            ),
                            child: Text(
                              l10n.playerRankings.toUpperCase(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.5,
                                color: colors.primaryBright,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          ..._players.asMap().entries.map((entry) {
                            final index = entry.key;
                            final player = entry.value;
                            return _buildPlayerCard(player, index + 1, colors, theme);
                          }),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(AppLocalizations l10n, FortuneColors colors, ThemeData theme) {
    final totalGames = _players.fold<int>(0, (sum, p) => sum + p.gamesPlayed);
    final totalPoints = _players.fold<int>(0, (sum, p) => sum + p.totalPoints);
    final totalFouls = _players.fold<int>(0, (sum, p) => sum + p.totalFouls);
    final highestRun = _players.fold<int>(0, (max, p) => p.highestRun > max ? p.highestRun : max);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        border: Border.all(color: colors.primaryDark, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.overallStatistics,
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 18, color: colors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(l10n.games, totalGames.toString(), Icons.sports_esports, colors, theme),
              _buildStatColumn(l10n.points, totalPoints.toString(), Icons.stars, colors, theme),
              _buildStatColumn(l10n.fouls, totalFouls.toString(), Icons.warning, colors, theme),
              _buildStatColumn(l10n.bestRun, highestRun.toString(), Icons.trending_up, colors, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, FortuneColors colors, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: colors.primaryBright, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 24, color: colors.accent),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.textMain.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, int rank, FortuneColors colors, ThemeData theme) {
    // Determine rank color
    final rankColor = rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFFC0C0C0) : (rank == 3 ? const Color(0xFFCD7F32) : colors.primaryDark));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(color: colors.primaryDark, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ExpansionTile(
        iconColor: colors.accent,
        collapsedIconColor: colors.primary,
        leading: CircleAvatar(
          backgroundColor: rankColor,
          foregroundColor: Colors.black,
          child: Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(player.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.textMain)),
        subtitle: Text(
          '${player.gamesPlayed} games | ${player.winRate.toStringAsFixed(1)}% Win',
          // Explicitly use textMain (Light Grey) as requested by user for readability
          style: theme.textTheme.bodySmall?.copyWith(color: colors.textMain.withValues(alpha: 0.7)),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Games Played', player.gamesPlayed.toString(), colors),
                _buildStatRow('Games Won', '${player.gamesWon} (${player.winRate.toStringAsFixed(1)}%)', colors),
                const Divider(),
                _buildStatRow('Total Points', player.totalPoints.toString(), colors),
                _buildStatRow('Avg Points/Game', player.averagePointsPerGame.toStringAsFixed(1), colors),
                _buildStatRow('Highest Run', player.highestRun.toString(), colors),
                const Divider(),
                _buildStatRow('Total Innings', player.totalInnings.toString(), colors),
                _buildStatRow('Avg Innings/Game', player.averageInningsPerGame.toStringAsFixed(1), colors),
                const Divider(),
                _buildStatRow('Total Fouls', player.totalFouls.toString(), colors),
                _buildStatRow('Avg Fouls/Game', player.averageFoulsPerGame.toStringAsFixed(1), colors),
                _buildStatRow('Total Saves', player.totalSaves.toString(), colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, FortuneColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textMain.withValues(alpha: 0.7)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
