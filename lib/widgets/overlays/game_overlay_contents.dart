
import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';
import 'splash_content.dart';

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
    final colors = FortuneColors.of(context);
    return SplashContent(
      title: message.toUpperCase(),
      subtitle: '$penaltyPoints', // Display Penalty explicitly
      icon: Icons.warning_amber_rounded,
      color: Colors.cyanAccent, // Requested Cyan Glow
    );
  }
}

class SafeSplashContent extends StatelessWidget {
  const SafeSplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    return SplashContent(
      title: "SAFE",
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
    return SplashContent(
      title: "RE-RACK", 
      subtitle: title == "Re-rack!" || title == "14.1 Re-Rack" ? null : title,
      icon: null, // Removed Icon as requested
      color: colors.primaryBright,
    );
  }
}
