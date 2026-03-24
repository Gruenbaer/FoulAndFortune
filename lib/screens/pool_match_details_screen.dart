import 'package:flutter/material.dart';
import '../models/game_record.dart';
import '../models/pool_match_state.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';

class PoolMatchDetailsScreen extends StatelessWidget {
  const PoolMatchDetailsScreen({
    super.key,
    required this.record,
  });

  final GameRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);
    final snapshot = record.snapshot ?? const <String, dynamic>{};
    final match = PoolMatchState.fromSnapshotJson(snapshot);
    final duration = record.getFormattedDuration();

    Widget statRow(String label, String left, String right) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(left, style: theme.textTheme.bodyLarge)),
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
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${record.disciplineLabel} Details'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.backgroundCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.primary.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.player1Name} vs ${record.player2Name}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Endstand ${record.scoreLine}  |  ${duration}  |  Race ${record.raceToScore}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.accent,
                      ),
                    ),
                    if (record.winner != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Sieger: ${record.winner}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.primaryBright,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.backgroundCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.primary.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${record.disciplineLabel} Match Stats',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    statRow(match.discipline.scoreLabel,
                        '${match.players[0].rackWins}', '${match.players[1].rackWins}'),
                    statRow('Safeties', '${match.players[0].safeties}',
                        '${match.players[1].safeties}'),
                    statRow('Fouls', '${match.players[0].fouls}',
                        '${match.players[1].fouls}'),
                    statRow('Break & Run', '${match.players[0].breakAndRuns}',
                        '${match.players[1].breakAndRuns}'),
                    statRow('Runouts', '${match.players[0].runOuts}',
                        '${match.players[1].runOuts}'),
                    statRow('Pressure Index',
                        match.pressureIndexFor(0).toStringAsFixed(1),
                        match.pressureIndexFor(1).toStringAsFixed(1)),
                    statRow('Table Control',
                        match.tableControlFor(0).toStringAsFixed(2),
                        match.tableControlFor(1).toStringAsFixed(2)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.backgroundCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.primary.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chronik',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...(match.actionLog.isEmpty
                        ? [
                            Text(
                              'Keine Chronik gespeichert.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ]
                        : match.actionLog
                            .take(20)
                            .map(
                              (entry) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.chevron_right),
                                title: Text(entry),
                              ),
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
