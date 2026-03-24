import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../models/pool_match_state.dart';
import '../services/pool_match_service.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';

class PoolMatchCenterScreen extends StatefulWidget {
  const PoolMatchCenterScreen({
    super.key,
    required this.discipline,
    this.poolMatchService,
  });

  final GameDiscipline discipline;
  final PoolMatchService? poolMatchService;

  @override
  State<PoolMatchCenterScreen> createState() => _PoolMatchCenterScreenState();
}

class _PoolMatchCenterScreenState extends State<PoolMatchCenterScreen> {
  PoolMatchState? _match;
  late final PoolMatchService _poolMatchService =
      widget.poolMatchService ?? PoolMatchService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextMatch = Provider.of<PoolMatchState>(context);
    if (!identical(_match, nextMatch)) {
      _match?.removeListener(_persistMatch);
      _match = nextMatch;
      _match?.addListener(_persistMatch);
      WidgetsBinding.instance.addPostFrameCallback((_) => _persistMatch());
    }
  }

  @override
  void dispose() {
    _match?.removeListener(_persistMatch);
    super.dispose();
  }

  void _persistMatch() {
    final current = _match;
    if (current == null) return;
    _poolMatchService.persistMatch(current);
  }

  String _groupLabel(TableGroup group) {
    switch (group) {
      case TableGroup.open:
        return 'OPEN';
      case TableGroup.solids:
        return 'SOLIDS';
      case TableGroup.stripes:
        return 'STRIPES';
    }
  }

  String _specialFinishLabel() {
    switch (widget.discipline) {
      case GameDiscipline.eightBall:
        return '8 On Break';
      case GameDiscipline.nineBall:
      case GameDiscipline.tenBall:
        return 'Golden Break';
      case GameDiscipline.onePocket:
        return 'Table Closeout';
      case GameDiscipline.cowboy:
        return 'Clean Finish';
      case GameDiscipline.straightPool:
        return 'Finish';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    return Consumer<PoolMatchState>(
      builder: (context, match, _) {
        Widget statChip(String label, String value, {Color? color}) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.backgroundCard.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (color ?? colors.primary).withOpacity(0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color ?? colors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textMain.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }

        Widget playerPanel(int index) {
          final player = match.players[index];
          final isActive = index == match.activePlayerIndex;
          final isBreaking = index == match.breakerIndex;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? colors.backgroundCard
                    : colors.backgroundCard.withOpacity(0.78),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      isActive ? colors.accent : colors.primary.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isActive)
                        _StatusPill(label: 'AT TABLE', color: colors.accent),
                      if (isBreaking)
                        _StatusPill(
                          label: 'BREAKING',
                          color: colors.primaryBright,
                        ),
                      if (widget.discipline.supportsGroups &&
                          player.assignedGroup != null)
                        _StatusPill(
                          label: _groupLabel(player.assignedGroup!),
                          color: colors.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      statChip(widget.discipline.scoreLabel, player.rackWins.toString()),
                      statChip(
                        'Safeties',
                        player.safeties.toString(),
                        color: colors.primary,
                      ),
                      statChip(
                        'Fouls',
                        player.fouls.toString(),
                        color: colors.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'B&R ${player.breakAndRuns}  |  Runouts ${player.runOuts}  |  Dry ${player.dryBreaks}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textMain.withOpacity(0.84),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'BIH wins ${player.ballInHandWins}  |  Pushes ${player.pushes}  |  Winrate ${match.winRateFor(index).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textMain.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pressure ${match.pressureIndexFor(index).toStringAsFixed(1)}  |  Control ${match.tableControlFor(index).toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textMain.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget actionButton({
          required String label,
          required IconData icon,
          required VoidCallback onPressed,
          Color? accent,
        }) {
          return Expanded(
            child: ThemedButton(
              label: label,
              icon: icon,
              backgroundGradientColors: accent == null
                  ? null
                  : [
                      accent.withOpacity(0.35),
                      colors.backgroundCard,
                    ],
              onPressed: match.matchOver ? null : onPressed,
            ),
          );
        }

        void showStatsSheet() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _MatchStatsSheet(
              match: match,
              discipline: widget.discipline,
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('${widget.discipline.label} Match Center'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              GuardedIconButton(
                icon: Icons.undo,
                onPressed: match.canUndo ? match.undo : null,
                tooltip: 'Undo',
              ),
              GuardedIconButton(
                icon: Icons.redo,
                onPressed: match.canRedo ? match.redo : null,
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.query_stats),
                onPressed: showStatsSheet,
                tooltip: 'Stats',
              ),
            ],
          ),
          body: ThemedBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.backgroundCard.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: colors.primary.withOpacity(0.28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.contextLine,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.textMain,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            statChip('Race', '${match.raceTo}'),
                            statChip('Rack', '${match.rackNumber}'),
                            statChip('Score', match.scoreLine),
                            if (match.ballInHand)
                              statChip('BIH', 'LIVE', color: colors.warning),
                            if (match.pushOutAvailable || match.pushOutArmed)
                              statChip(
                                'Push',
                                match.pushOutArmed ? 'ARMED' : 'READY',
                                color: colors.primaryBright,
                              ),
                          ],
                        ),
                        if (match.matchOver && match.winner != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            '${match.winner!.name} hat das Match gewonnen.',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      playerPanel(0),
                      const SizedBox(width: 12),
                      playerPanel(1),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Schnellaktionen',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      actionButton(
                        label: '${widget.discipline.scoreLabel} Win',
                        icon: Icons.emoji_events,
                        accent: colors.accent,
                        onPressed: () => match.winRack(),
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Runout',
                        icon: Icons.local_fire_department,
                        accent: colors.primaryBright,
                        onPressed: () => match.winRack(runOut: true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: 'Break & Run',
                        icon: Icons.bolt,
                        accent: colors.warning,
                        onPressed: () =>
                            match.winRack(breakAndRun: true, runOut: true),
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: _specialFinishLabel(),
                        icon: Icons.auto_awesome,
                        accent: colors.danger,
                        onPressed: () => match.winRack(goldenBreak: true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: 'Safety',
                        icon: Icons.shield_outlined,
                        onPressed: match.recordSafety,
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Foul',
                        icon: Icons.warning_amber_rounded,
                        accent: colors.danger,
                        onPressed: match.recordFoul,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: 'Switch Turn',
                        icon: Icons.swap_horiz,
                        onPressed: match.switchTurn,
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Dry Break',
                        icon: Icons.hourglass_bottom,
                        onPressed: match.recordDryBreak,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: match.ballInHand ? 'Clear BIH' : 'Ball in Hand',
                        icon: Icons.control_camera,
                        accent: colors.warning,
                        onPressed: match.toggleBallInHand,
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: match.pushOutArmed ? 'Push Armed' : 'Push Out',
                        icon: Icons.assistant_navigation,
                        onPressed: widget.discipline.supportsPushOut
                            ? match.togglePushOut
                            : () {},
                      ),
                    ],
                  ),
                  if (widget.discipline.supportsGroups) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tisch / Gruppen',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text('Open Table'),
                          selected: match.tableGroup == TableGroup.open,
                          onSelected: (_) =>
                              match.assignTableGroup(TableGroup.open),
                        ),
                        ChoiceChip(
                          label: const Text('Solids'),
                          selected:
                              match.currentPlayer.assignedGroup == TableGroup.solids,
                          onSelected: (_) =>
                              match.assignTableGroup(TableGroup.solids),
                        ),
                        ChoiceChip(
                          label: const Text('Stripes'),
                          selected:
                              match.currentPlayer.assignedGroup == TableGroup.stripes,
                          onSelected: (_) =>
                              match.assignTableGroup(TableGroup.stripes),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ThemedButton(
                          label: 'Stats',
                          icon: Icons.analytics_outlined,
                          onPressed: showStatsSheet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ThemedButton(
                          label: 'Reset Match',
                          icon: Icons.restart_alt,
                          onPressed: match.resetMatch,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Chronik',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.backgroundCard.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: colors.primary.withOpacity(0.24)),
                    ),
                    child: match.actionLog.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              'Noch keine Aktionen. Starte mit Break, Safety, Foul oder ${widget.discipline.scoreLabel.toLowerCase()}-Win.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textMain.withOpacity(0.8),
                              ),
                            ),
                          )
                        : Column(
                            children: match.actionLog
                                .take(12)
                                .map(
                                  (entry) => ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.chevron_right),
                                    title: Text(entry),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MatchStatsSheet extends StatelessWidget {
  const _MatchStatsSheet({
    required this.match,
    required this.discipline,
  });

  final PoolMatchState match;
  final GameDiscipline discipline;

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    Widget buildRow(String label, String left, String right) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                left,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMain.withOpacity(0.7),
                ),
              ),
            ),
            Expanded(
              child: Text(
                right,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final p1 = match.players[0];
    final p2 = match.players[1];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: BoxDecoration(
        color: colors.backgroundMain,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.primary.withOpacity(0.25)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text(
              '${discipline.label} Live Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            buildRow(discipline.scoreLabel, '${p1.rackWins}', '${p2.rackWins}'),
            buildRow('Safeties', '${p1.safeties}', '${p2.safeties}'),
            buildRow('Fouls', '${p1.fouls}', '${p2.fouls}'),
            buildRow('Break & Run', '${p1.breakAndRuns}', '${p2.breakAndRuns}'),
            buildRow('Special Finish', '${p1.goldenBreaks}', '${p2.goldenBreaks}'),
            buildRow('Runouts', '${p1.runOuts}', '${p2.runOuts}'),
            buildRow('Dry Breaks', '${p1.dryBreaks}', '${p2.dryBreaks}'),
            buildRow(
              'Ball-in-Hand Wins',
              '${p1.ballInHandWins}',
              '${p2.ballInHandWins}',
            ),
            buildRow('Visits', '${p1.visits}', '${p2.visits}'),
            buildRow('Momentum', '${p1.momentum}', '${p2.momentum}'),
            buildRow(
              'Pressure Index',
              match.pressureIndexFor(0).toStringAsFixed(1),
              match.pressureIndexFor(1).toStringAsFixed(1),
            ),
            buildRow(
              'Table Control',
              match.tableControlFor(0).toStringAsFixed(2),
              match.tableControlFor(1).toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }
}
