import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/fortune_theme.dart';

class FoulToggleButton extends StatelessWidget {
  final FoulMode currentMode;
  final VoidCallback onPressed;

  const FoulToggleButton({
    super.key,
    required this.currentMode,
    required this.onPressed,
  });

  Color _getButtonColor(FortuneColors colors) {
    // Background is now consistent or transparent-ish, relying on border/text/shadow to show state
    return colors.backgroundCard; 
  }

  Color _getActiveColor(FortuneColors colors) {
    switch (currentMode) {
      case FoulMode.none:
        return colors.disabled; // or textMain
      case FoulMode.normal:
        return colors.warning; // Orange/Amber
      case FoulMode.severe:
        return colors.danger; // Red
    }
  }

  String _getButtonText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (currentMode) {
      case FoulMode.none:
        return l10n.noFoul;
      case FoulMode.normal:
        return l10n.foulMinusOne;
      case FoulMode.severe:
        return l10n.breakFoulMinusTwo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final activeColor = _getActiveColor(colors);
    final isActive = currentMode != FoulMode.none;

    return SizedBox(
      height: 56, 
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.6),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonColor(colors),
            side: BorderSide(
              color: isActive ? activeColor : colors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _getButtonText(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : colors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
