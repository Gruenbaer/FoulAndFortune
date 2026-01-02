import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
import '../theme/fortune_theme.dart';
import 'themed_widgets.dart';
import 'score_card.dart';
import '../models/game_action.dart'; // Import for type
import '../l10n/app_localizations.dart';

class VictorySplash extends StatefulWidget {
  final Player winner;
  final Player loser;
  final int raceToScore;
  final List<GameAction> history;
  final Duration elapsedDuration;
  final VoidCallback onNewGame;
  final VoidCallback onExit;

  const VictorySplash({
    super.key,
    required this.winner,
    required this.loser,
    required this.raceToScore,
    required this.history,
    required this.elapsedDuration,
    required this.onNewGame,
    required this.onExit,
  });

  @override
  State<VictorySplash> createState() => _VictorySplashState();
}

class _VictorySplashState extends State<VictorySplash> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: colors.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(), // No back button
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            color: colors.primary,
            tooltip: AppLocalizations.of(context).undo,
            onPressed: () {
              // Undo last action before victory
              Navigator.of(context).pop();
              // The game state's undo will be called after popping
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            color: colors.primaryDark,
            tooltip: AppLocalizations.of(context).redo,
            onPressed: null, // Greyed out
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          ThemedBackground(
            child: Container(),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [
                colors.primary,
                colors.primaryBright,
                colors.secondary,
                colors.accent,
              ],
              numberOfParticles: 50,
              gravity: 0.3,
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Trophy Icon and Victory Text - Compact
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: colors.accent,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    AppLocalizations.of(context).victory.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: colors.primaryBright,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.none, // Fix double underline
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: colors.primary.withValues(alpha: 0.8),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Scoresheet - No border, more space
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Column(
                      children: [
                        // Player names and scores at top
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.winner.score.toString(),
                                    style: TextStyle(
                                      color: colors.accent,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.winner.name.toUpperCase(),
                                    style: TextStyle(
                                      color: colors.primaryBright,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.loser.score.toString(),
                                    style: TextStyle(
                                      color: colors.textMain,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.loser.name.toUpperCase(),
                                    style: TextStyle(
                                      color: colors.textMain,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),

                        // Match Time
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.backgroundCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, size: 20, color: colors.primary),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).matchTime(_formatDuration(widget.elapsedDuration)),
                                style: TextStyle(
                                  color: colors.primaryBright,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Stats table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.primaryDark),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Header row
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.backgroundCard,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.winner.name.toUpperCase(),
                                        style: TextStyle(
                                          color: colors.primaryBright,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 80, child: Text('')),
                                    Expanded(
                                      child: Text(
                                        widget.loser.name.toUpperCase(),
                                        style: TextStyle(
                                          color: colors.textMain,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Stats rows
                              _buildStatsRow(AppLocalizations.of(context).innings, widget.winner.currentInning.toString(), widget.loser.currentInning.toString()),
                              _buildStatsRow(AppLocalizations.of(context).saves, widget.winner.saves.toString(), widget.loser.saves.toString()),
                              _buildStatsRow(AppLocalizations.of(context).average, _calculateAverage(widget.winner), _calculateAverage(widget.loser)),
                              _buildStatsRow(AppLocalizations.of(context).highestRun, _calculateHighestRun(widget.winner), _calculateHighestRun(widget.loser)),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Score Card
                        Text(
                          AppLocalizations.of(context).scoreCard,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                          ScoreCard(
                            player1: widget.winner,
                            player2: widget.loser,
                            history: widget.history, // Pass structured history
                            winnerName: widget.winner.name,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons - Using SteampunkButton
                  Row(
                    children: [
                      Expanded(
                        child: ThemedButton(
                          label: AppLocalizations.of(context).newGame,
                          onPressed: widget.onNewGame,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ThemedButton(
                          label: AppLocalizations.of(context).exit,
                          onPressed: widget.onExit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    return "$hours$minutes:$seconds";
  }

  Widget _buildScoreLine(String name, int score, {required bool isWinner}) {
    final colors = FortuneColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinner ? colors.primaryBright : colors.textMain,
              fontSize: isWinner ? 24 : 18,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            color: isWinner ? colors.accent : colors.textMain,
            fontSize: isWinner ? 32 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatLine(String label, String winnerStat, String loserStat) {
    final colors = FortuneColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              winnerStat,
              style: TextStyle(color: colors.textMain),
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colors.primaryDark,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              loserStat,
              style: TextStyle(color: colors.textMain),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, String winnerStat, String loserStat) {
    final colors = FortuneColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.primaryDark, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              winnerStat,
              style: TextStyle(
                color: colors.primaryBright,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textMain,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              loserStat,
              style: TextStyle(
                color: colors.textMain,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAverage(Player player) {
    if (player.currentInning == 0) return '0.0';
    return (player.score / player.currentInning).toStringAsFixed(1);
  }

  String _calculateHighestRun(Player player) {
    // Determine highest run using structured history.
    int highest = 0;
    int currentRun = 0;
    
    // History is Newest -> Oldest. We want chronological for run calculation.
    for (int i = widget.history.length - 1; i >= 0; i--) {
       final action = widget.history[i];
       if (action.playerId == player.name) {
          if (action.points > 0 && action.type != GameActionType.safety) {
               currentRun += action.points;
          } else {
               if (currentRun > highest) highest = currentRun;
               currentRun = 0;
          }
          
          if (action.isTurnEnd) {
             if (currentRun > highest) highest = currentRun;
             currentRun = 0;
          }
       }
       // Opponent actions don't directly break run unless it implies turn change, which is handled by isTurnEnd.
    }
    
    if (currentRun > highest) highest = currentRun;
    return highest.toString();
  }
}
