
import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';
import 'splash_content.dart';
import '../../l10n/app_localizations.dart';

class FoulSplashContent extends StatelessWidget {
  final String message;
  final int penaltyPoints;

  const FoulSplashContent({
    super.key,
    required this.message,
    required this.penaltyPoints,
  });

  @override
  Widget build(BuildContext context) {

    return SplashContent(
      title: message.toUpperCase(),
      subtitle: '$penaltyPoints', // Display Penalty explicitly
      icon: Icons.warning_amber_rounded,
      color: Colors.cyanAccent, // Glow Color & Icon
      textColor: Colors.cyanAccent, // Title Text
      subtitleColor: Colors.redAccent, // Number Text
      subtitleGlowColor: Colors.yellowAccent, // Number Glow (Yellow Border effect)
      backgroundColor: Colors.black.withValues(alpha: 0.7), // Semi-transparent background
    );
  }
}

class SafeSplashContent extends StatelessWidget {
  const SafeSplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final l10n = AppLocalizations.of(context);
    return SplashContent(
      title: l10n.safe,
      icon: Icons.shield,
      color: colors.success,
    );
  }
}

class ReRackSplashContent extends StatelessWidget {
  final String title;

  const ReRackSplashContent({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final l10n = AppLocalizations.of(context);
    // Translate 'reRack' key if needed
    String displayTitle = title;
    if (title == 'reRack') {
      displayTitle = l10n.reRack;
    }
    
    return SplashContent(
      title: displayTitle, 
      subtitle: null,
      icon: null, // Removed Icon as requested
      color: colors.primaryBright,
    );
  }
}
