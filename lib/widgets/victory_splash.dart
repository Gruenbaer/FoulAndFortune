import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player.dart';
import '../codecs/notation_codec.dart'; // For InningRecord
import '../theme/fortune_theme.dart';
import 'themed_widgets.dart';
import 'score_card.dart';
import '../l10n/app_localizations.dart';

class VictorySplash extends StatefulWidget {
  final Player player1; // Always Player 1 (Left)
  final Player player2; // Always Player 2 (Right)
  final Player winner;  // The actual winner object (for highlighting)
  
  final int raceToScore;
  final List<InningRecord> inningRecords;
  final Duration elapsedDuration;
  final VoidCallback onNewGame;
  final VoidCallback onExit;

  const VictorySplash({
    super.key,
    required this.player1,
    required this.player2,
    required this.winner,
    required this.raceToScore,
    required this.inningRecords,
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
    
    // Determine winner based on passed object
    final isP1Winner = widget.winner.name == widget.player1.name; 
    
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
                    AppLocalizations.of(context).victory,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colors.primaryBright,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: colors.accent,
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
                            Expanded(child: _buildPlayerHeader(context, widget.player1, isWinner: isP1Winner, align: CrossAxisAlignment.center)),
                            // Divider or VS?
                            const SizedBox(width: 16),
                            Expanded(child: _buildPlayerHeader(context, widget.player2, isWinner: !isP1Winner, align: CrossAxisAlignment.center)),
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
                                        widget.player1.name.toUpperCase(),
                                        style: TextStyle(
                                          color: isP1Winner ? colors.accent : colors.primaryBright, // Highlight winner name
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 80, child: Text('')),
                                    Expanded(
                                      child: Text(
                                        widget.player2.name.toUpperCase(),
                                        style: TextStyle(
                                          color: !isP1Winner ? colors.accent : colors.primaryBright, // Highlight winner name
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
                              _buildStatsRow(AppLocalizations.of(context).innings, widget.player1.currentInning.toString(), widget.player2.currentInning.toString()),
                              _buildStatsRow(AppLocalizations.of(context).saves, widget.player1.saves.toString(), widget.player2.saves.toString()),
                              _buildStatsRow(AppLocalizations.of(context).average, _calculateAverage(widget.player1), _calculateAverage(widget.player2)),
                              _buildStatsRow(AppLocalizations.of(context).highestRun, _calculateHighestRun(widget.player1), _calculateHighestRun(widget.player2)),
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
                          player1: widget.player1,
                          player2: widget.player2,
                          inningRecords: widget.inningRecords,
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

  Widget _buildPlayerHeader(BuildContext context, Player player, {required bool isWinner, required CrossAxisAlignment align}) {
    final colors = FortuneColors.of(context);
    return Column(
      crossAxisAlignment: align,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              player.score.toString(),
              style: TextStyle(
                color: isWinner ? colors.accent : colors.textMain,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: isWinner ? [Shadow(color: colors.accent.withValues(alpha:0.5), blurRadius: 10)] : [],
              ),
            ),
            if (isWinner)
              Positioned(
                top: -15,
                child: Icon(Icons.star, color: colors.accent, size: 24),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          player.name.toUpperCase(),
          style: TextStyle(
            color: isWinner ? colors.primaryBright : colors.textMain, // Winner gets brighter name too?
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    return "$hours$minutes:$seconds";
  }



  Widget _buildStatsRow(String label, String p1Stat, String p2Stat) {
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
              p1Stat,
              style: TextStyle(
                color: colors.textMain, // Standard color
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
              p2Stat,
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
    // Use the highestRun tracked directly in the Player model
    return player.highestRun.toString();
  }
}
