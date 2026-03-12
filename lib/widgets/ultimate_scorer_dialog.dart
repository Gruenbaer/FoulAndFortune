import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/rack_result.dart';
import '../models/player.dart';
import '../theme/fortune_theme.dart';
import '../l10n/app_localizations.dart';

class UltimateScorerDialog extends StatefulWidget {
  final Player player;

  const UltimateScorerDialog({super.key, required this.player});

  @override
  State<UltimateScorerDialog> createState() => _UltimateScorerDialogState();
}

class _UltimateScorerDialogState extends State<UltimateScorerDialog> {
  bool _wasBreakSuccessful = false;
  bool _isBreakAndRun = false;
  late Player _winner;

  @override
  void initState() {
    super.initState();
    _winner = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final gameState = Provider.of<GameState>(context, listen: false);

    return Dialog(
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: colors.primary, width: 2),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'RACK COMPLETE',
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.primary,
                letterSpacing: 4,
                shadows: [
                  Shadow(blurRadius: 10, color: colors.primary.withOpacity(0.8)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Winner Selection
            _buildSectionHeader('WHO WON THE RACK?', colors),
            const SizedBox(height: 12),
            Row(
              children: gameState.players.map((p) {
                final isSelected = _winner.id == p.id;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _winner = p),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.disabled,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          p.name.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected ? colors.primary : colors.disabled,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Performance Switches
            _buildSectionHeader('PERFORMANCE FLAGS', colors),
            const SizedBox(height: 16),
            _buildSwitchTile(
              label: 'SUCCESSFUL BREAK',
              value: _wasBreakSuccessful,
              onChanged: (val) => setState(() {
                _wasBreakSuccessful = val;
                if (!val) _isBreakAndRun = false;
              }),
              colors: colors,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              label: 'BREAK & RUNOUT',
              value: _isBreakAndRun,
              enabled: _wasBreakSuccessful,
              onChanged: (val) => setState(() => _isBreakAndRun = val),
              colors: colors,
            ),

            const SizedBox(height: 40),

            // Actions
            ElevatedButton(
              onPressed: () {
                final result = RackResult(
                  playerId: _winner.id,
                  playerName: _winner.name,
                  wasBreakSuccessful: _wasBreakSuccessful,
                  isBreakAndRun: _isBreakAndRun,
                  timestamp: DateTime.now(),
                );
                gameState.recordRackResult(result);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textContrast,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: Text(
                'NEXT RACK',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, FortuneColors colors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          color: colors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.textMain.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required FortuneColors colors,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: value ? colors.accent : colors.disabled.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: value ? colors.accent : colors.textMain,
                ),
              ),
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeColor: colors.accent,
                activeTrackColor: colors.accent.withOpacity(0.2),
                inactiveThumbColor: colors.disabled,
                inactiveTrackColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
