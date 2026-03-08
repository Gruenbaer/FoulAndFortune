import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/fortune_theme.dart';
import '../l10n/app_localizations.dart';

class FastScoreInput extends StatefulWidget {
  const FastScoreInput({super.key});

  @override
  State<FastScoreInput> createState() => _FastScoreInputState();
}

class _FastScoreInputState extends State<FastScoreInput> {
  bool _confirmMiss = false;
  bool _confirmFoul = false;

  void _resetConfirms() {
    if (mounted) {
      setState(() {
        _confirmMiss = false;
        _confirmFoul = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final colors = FortuneColors.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: +/- Points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLargeButton(
                icon: Icons.remove,
                color: colors.danger,
                onPressed: gameState.canUndo ? gameState.undo : null,
                label: '-1',
              ),
              // Current Score Display
              Column(
                children: [
                  Text(
                    '${gameState.currentPlayer.currentRun}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.inning.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(color: colors.textMain.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              _buildLargeButton(
                icon: Icons.add,
                color: colors.accent,
                onPressed: () {
                  // Find first active ball to pot
                  final balls = gameState.activeBalls.where((b) => b >= 2).toList();
                  if (balls.isNotEmpty) {
                    gameState.onBallTapped(balls.first);
                  } else if (gameState.activeBalls.contains(1)) {
                    gameState.onBallTapped(1);
                  }
                  _resetConfirms();
                },
                label: '+1',
              ),
              _buildLargeButton(
                icon: Icons.security,
                color: colors.primary,
                onPressed: () {
                  gameState.onSafe();
                  _resetConfirms();
                },
                label: l10n.safe.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Row 2: Miss / Foul
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // MISS BUTTON (2-tap)
              _buildActionButton(
                label: _confirmMiss ? l10n.confirm.toUpperCase() : l10n.miss.toUpperCase(),
                color: _confirmMiss ? colors.warning : colors.primary,
                isActive: _confirmMiss,
                onPressed: () {
                  if (_confirmMiss) {
                    // APPLY MISS
                    // In Straight Pool, a miss is a tap on ball 0 (Cue Ball) without any other mode
                    gameState.onBallTapped(0);
                    _resetConfirms();
                  } else {
                    setState(() {
                      _confirmMiss = true;
                      _confirmFoul = false;
                    });
                    // Auto-reset after 3 seconds
                    Future.delayed(const Duration(seconds: 3), _resetConfirms);
                  }
                },
              ),
              
              // FOUL BUTTON (2nd tap options)
              if (!_confirmFoul)
                _buildActionButton(
                  label: l10n.foul.toUpperCase(),
                  color: colors.danger,
                  onPressed: () {
                    setState(() {
                      _confirmFoul = true;
                      _confirmMiss = false;
                    });
                  },
                )
              else ...[
                _buildActionButton(
                  label: 'F (-1)',
                  color: colors.danger,
                  onPressed: () {
                    gameState.setFoulMode(FoulMode.normal);
                    gameState.onBallTapped(0); // Apply normal foul
                    _resetConfirms();
                  },
                ),
                _buildActionButton(
                  label: 'SF (-2)',
                  color: colors.danger.withValues(alpha: 0.7),
                  onPressed: () {
                    gameState.setFoulMode(FoulMode.severe);
                    gameState.onBallTapped(0); // Apply severe foul
                    _resetConfirms();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: colors.textMain,
                  onPressed: _resetConfirms,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String label,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.2),
            foregroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            side: BorderSide(color: color, width: 2),
            elevation: 0,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : Colors.transparent,
          foregroundColor: isActive ? Colors.black : color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
