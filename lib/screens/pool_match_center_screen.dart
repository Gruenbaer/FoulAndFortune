import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../models/pool_match_state.dart';
import '../services/pool_match_service.dart';
import '../theme/fortune_theme.dart';
import '../utils/ui_utils.dart';
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

  void _showInfoDialog(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (_) => GameAlertDialog(
        title: title,
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schliessen'),
          ),
        ],
      ),
    );
  }

  void _showRuleSheet(PoolMatchState match) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        decoration: BoxDecoration(
          color: colors.backgroundMain,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.primary.withOpacity(0.25)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
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
                '${widget.discipline.label} Anleitung',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'So benutzt du den Screen',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.discipline.quickHowTo.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '• $entry',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textMain,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Regelwerk',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.discipline.ruleBook.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '• $entry',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textMain.withOpacity(0.92),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Aktuell stoest ${match.players[match.breakerIndex].name} an.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startPoolQuickTutorial(PoolMatchState match) async {
    final steps = <({String title, String body})>[
      (
        title: '${widget.discipline.label} Tutorial (1/5)',
        body:
            'Das Match-Center wird live pro Aufnahme gefuehrt. Jede Schnellaktion beschreibt den aktuellen Stoss und nicht nur eine spaete Match-Zusammenfassung.',
      ),
      (
        title: '${widget.discipline.label} Tutorial (2/5)',
        body:
            'Achte auf den aktiven Spieler oben im Kontext. Safety, Foul, Dry Break und Turnwechsel bewegen den Rack-Verlauf live weiter.',
      ),
      (
        title: '${widget.discipline.label} Tutorial (3/5)',
        body:
            'Ausgegraute Buttons bedeuten nur: Eine Voraussetzung fuer diese Aktion ist gerade nicht erfuellt. Long-Press erklaert dir immer den Grund.',
      ),
      (
        title: '${widget.discipline.label} Tutorial (4/5)',
        body:
            'Push Out loest nach trockenem Break eine Rueckfrage aus, wer die naechste Aufnahme spielt. So bleibt die Turn-Logik sauber.',
      ),
      (
        title: '${widget.discipline.label} Tutorial (5/5)',
        body:
            'Im Hamburger-Menü findest du jederzeit Anleitung & Regelwerk sowie dieses Tutorial erneut.',
      ),
    ];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (!mounted) return;
      final shouldContinue = await showZoomDialog<bool>(
        context: context,
        builder: (dialogContext) => GameAlertDialog(
          title: step.title,
          content: Text(step.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Beenden'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(i == steps.length - 1 ? 'Fertig' : 'Weiter'),
            ),
          ],
        ),
      );

      if (shouldContinue != true || i == steps.length - 1) {
        break;
      }
    }
  }

  void _showHelpAndTutorialSheet(PoolMatchState match) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: colors.backgroundMain,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.primary.withOpacity(0.25)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hilfe & Tutorial',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Starte das Kurz-Tutorial oder oeffne die vollstaendige Anleitung mit Regelwerk fuer den Live-Aufnahmefluss.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textMain,
                ),
              ),
              const SizedBox(height: 16),
              ThemedButton(
                label: '${widget.discipline.label} Kurz-Tutorial',
                icon: Icons.school_outlined,
                iconPosition: ThemedButtonIconPosition.top,
                forceSingleLineLabel: true,
                onPressed: () async {
                  Navigator.pop(context);
                  await _startPoolQuickTutorial(match);
                },
              ),
              const SizedBox(height: 10),
              ThemedButton(
                label: 'Anleitung & Regelwerk',
                icon: Icons.menu_book_outlined,
                iconPosition: ThemedButtonIconPosition.top,
                forceSingleLineLabel: true,
                onPressed: () {
                  Navigator.pop(context);
                  _showRuleSheet(match);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePushOut(PoolMatchState match) async {
    final keepCurrentPlayer = await showZoomDialog<bool>(
      context: context,
      builder: (dialogContext) => GameAlertDialog(
        title: 'Push Out',
        content: const Text(
          'Der Push Out wurde gespielt. Wer fuehrt die naechste Aufnahme aus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Gegner uebernimmt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Push-Spieler bleibt'),
          ),
        ],
      ),
    );

    if (keepCurrentPlayer == null) return;
    match.recordPushOut(keepCurrentPlayer: keepCurrentPlayer);
  }

  void _showBreakerSheet(PoolMatchState match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final colors = FortuneColors.of(context);
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: colors.backgroundMain,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.primary.withOpacity(0.25)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breaking Player wechseln',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Waehl den Spieler, der dieses Rack anstoessen soll. Der aktive Spieler wird dabei ebenfalls umgestellt.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textMain,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  match.players.length,
                  (index) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      index == match.breakerIndex
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    title: Text(match.players[index].name),
                    subtitle: Text(index == match.breakerIndex
                        ? 'Aktueller Breaker'
                        : 'Als Breaker setzen'),
                    onTap: () {
                      match.setBreaker(index);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  color: isActive
                      ? colors.accent
                      : colors.primary.withOpacity(0.25),
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
                      statChip(widget.discipline.scoreLabel,
                          player.rackWins.toString()),
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
          required String helpText,
          Color? accent,
          bool switchesPlayer = false,
          bool asksPlayerDecision = false,
          bool enabled = true,
        }) {
          final isEnabled = !match.matchOver && enabled;
          return Expanded(
            child: Stack(
              children: [
                ThemedButton(
                  label: label,
                  icon: icon,
                  iconPosition: ThemedButtonIconPosition.top,
                  forceSingleLineLabel: true,
                  contentSpacing: 8,
                  backgroundGradientColors: accent == null
                      ? null
                      : [
                          accent.withOpacity(0.35),
                          colors.backgroundCard,
                        ],
                  onPressed: isEnabled ? onPressed : null,
                  onLongPress: () => _showInfoDialog(label, helpText),
                ),
                if (switchesPlayer)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: IgnorePointer(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colors.backgroundMain.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.55),
                          ),
                        ),
                        child: Icon(
                          Icons.swap_horiz,
                          size: 12,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  ),
                if (asksPlayerDecision)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IgnorePointer(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.backgroundMain.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: colors.primary.withOpacity(0.55),
                              ),
                            ),
                            child: Icon(
                              Icons.swap_horiz,
                              size: 12,
                              color: colors.accent,
                            ),
                          ),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors.danger,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Center(
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
            leadingWidth: 44,
            titleSpacing: 8,
            title: Text(widget.discipline.label),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              GuardedIconButton(
                icon: Icons.undo,
                onPressed: match.canUndo ? match.undo : null,
                tooltip: 'Undo',
                shadows: const [],
              ),
              GuardedIconButton(
                icon: Icons.redo,
                onPressed: match.canRedo ? match.redo : null,
                tooltip: 'Redo',
                shadows: const [],
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    title: Text(
                      widget.discipline.label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.accent,
                      ),
                    ),
                    subtitle: Text(
                      match.contextLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textMain.withOpacity(0.75),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Hilfe & Tutorial'),
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpAndTutorialSheet(match);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Breaking Player wechseln'),
                    subtitle: Text(match.players[match.breakerIndex].name),
                    onTap: () {
                      Navigator.pop(context);
                      _showBreakerSheet(match);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.query_stats),
                    title: const Text('Live-Stats'),
                    onTap: () {
                      Navigator.pop(context);
                      showStatsSheet();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: const Text('Match zuruecksetzen'),
                    onTap: () {
                      Navigator.pop(context);
                      match.resetMatch();
                    },
                  ),
                ],
              ),
            ),
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
                        const SizedBox(height: 8),
                        Text(
                          'Long-Press auf einen Button zeigt dir kurz, was er genau macht. Ausgegraut heisst nur: Voraussetzung aktuell nicht erfuellt.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textMain.withOpacity(0.72),
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
                            if (match.pushOutAvailable)
                              statChip(
                                'Push',
                                'READY',
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
                        label: 'Safety',
                        icon: Icons.shield_outlined,
                        onPressed: match.recordSafety,
                        switchesPlayer: true,
                        helpText:
                            'Safety wird live als abgeschlossene Aufnahme erfasst und gibt den Tisch an den Gegner weiter.',
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Foul',
                        icon: Icons.warning_amber_rounded,
                        accent: colors.danger,
                        onPressed: match.recordFoul,
                        switchesPlayer: true,
                        helpText:
                            'Foul beendet die aktuelle Aufnahme live. Der Gegner bekommt Ball in Hand und ist danach am Tisch.',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: 'Switch Turn',
                        icon: Icons.swap_horiz,
                        onPressed: match.switchTurn,
                        switchesPlayer: true,
                        helpText:
                            'Manueller Spielerwechsel ohne Foul. Praktisch nach Safety-Duellen oder Korrekturen.',
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: match.ballInHand ? 'Clear BIH' : 'Ball in Hand',
                        icon: Icons.control_camera,
                        accent: colors.warning,
                        onPressed: match.toggleBallInHand,
                        helpText:
                            'Ball in Hand ein- oder ausschalten. Nutze das nach Fouls oder manuellen Korrekturen.',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: 'Dry Break',
                        icon: Icons.hourglass_bottom,
                        onPressed: match.recordDryBreak,
                        switchesPlayer: true,
                        enabled: match.canRecordDryBreak,
                        helpText: match.canRecordDryBreak
                            ? 'Der Break brachte keinen gelochten Ball. In 9-Ball und 10-Ball wird damit Push Out vorbereitet.'
                            : 'Dry Break ist nur direkt fuer den Anstoss des Breakers sinnvoll. Spaeter im Rack bleibt der Button absichtlich grau.',
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Push Out',
                        icon: Icons.assistant_navigation,
                        onPressed: () => _handlePushOut(match),
                        asksPlayerDecision: true,
                        enabled: match.canTogglePushOut,
                        helpText: !widget.discipline.supportsPushOut
                            ? 'In diesem Modus gibt es keinen Push Out. Der Button bleibt deshalb grau.'
                            : match.canTogglePushOut
                                ? 'Push Out ist nach trockenem Break verfuegbar. Danach fragt die App, wer die naechste Aufnahme spielt.'
                                : 'Push Out ist nur nach einem Dry Break verfuegbar. Ausserhalb dieses Fensters bleibt der Button grau.',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      actionButton(
                        label: '${widget.discipline.singleScoreLabel} Win',
                        icon: Icons.emoji_events,
                        accent: colors.accent,
                        onPressed: () => match.winRack(),
                        helpText:
                            'Normales gewonnenes Rack ohne Sondermerkmal. Nutze das fuer den regulaeren Punktgewinn.',
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: 'Runout',
                        icon: Icons.local_fire_department,
                        accent: colors.primaryBright,
                        onPressed: () => match.winRack(runOut: true),
                        helpText:
                            'Komplettes Ausspielen des Racks in einem Zug. Zaehlt auch als Rack Win.',
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
                        enabled: match.canRecordBreakAndRun,
                        helpText: match.canRecordBreakAndRun
                            ? 'Der Breaker gewinnt das Rack ohne den Tisch noch einmal abzugeben.'
                            : 'Break & Run ist nur sinnvoll, solange der Breaker das Rack noch ununterbrochen kontrolliert. Nach Dry Break, Foul, Turn Switch, Safety oder Ball in Hand bleibt der Button grau.',
                      ),
                      const SizedBox(width: 10),
                      actionButton(
                        label: _specialFinishLabel(),
                        icon: Icons.auto_awesome,
                        accent: colors.danger,
                        onPressed: () => match.winRack(goldenBreak: true),
                        enabled: match.canRecordSpecialFinish,
                        helpText: match.canRecordSpecialFinish
                            ? 'Sonderfinish des jeweiligen Modus, etwa Golden Break oder 8 on Break.'
                            : 'Dieses Break-Sonderfinish ist nur direkt vom Anstoss des Breakers sinnvoll. Spaeter im Rack bleibt der Button grau.',
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
                          selected: match.currentPlayer.assignedGroup ==
                              TableGroup.solids,
                          onSelected: (_) =>
                              match.assignTableGroup(TableGroup.solids),
                        ),
                        ChoiceChip(
                          label: const Text('Stripes'),
                          selected: match.currentPlayer.assignedGroup ==
                              TableGroup.stripes,
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
                          iconPosition: ThemedButtonIconPosition.top,
                          forceSingleLineLabel: true,
                          onPressed: showStatsSheet,
                          onLongPress: () => _showInfoDialog(
                            'Stats',
                            'Zeigt die Live-Statistiken des aktuellen Matches mit Rack Wins, Safeties, Fouls und Druckwerten.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ThemedButton(
                          label: 'Reset Match',
                          icon: Icons.restart_alt,
                          iconPosition: ThemedButtonIconPosition.top,
                          forceSingleLineLabel: true,
                          onPressed: match.resetMatch,
                          onLongPress: () => _showInfoDialog(
                            'Reset Match',
                            'Setzt das laufende Match auf Rack 1 zurueck und loescht die aktuelle Live-Chronik.',
                          ),
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
            buildRow(
                'Special Finish', '${p1.goldenBreaks}', '${p2.goldenBreaks}'),
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
