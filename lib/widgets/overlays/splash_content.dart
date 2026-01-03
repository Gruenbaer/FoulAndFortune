
import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Base Content Widget for Splash Screens
/// Provides standard consistent styling for text and icons
class SplashContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final Widget? customContent;

  const SplashContent({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final effectiveColor = color ?? colors.primaryBright;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        // Removed CustomPaint and Container decoration for "Text Glow Only" style
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon removed from here, let specific contents decide if they strictly need it, 
            // but user said "remove the icon" for re-rack and implied minimal style.
            // We'll keep icon support but specific widgets might not pass it.
            if (icon != null) ...[
              Icon(
                icon,
                size: 80,
                color: effectiveColor,
                shadows: [
                  Shadow(blurRadius: 20, color: effectiveColor, offset: const Offset(0, 0)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron( // Orbitron Font
                textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48, // Reduced from 64
                  color: effectiveColor,
                  height: 1.0, 
                  shadows: [
                    Shadow(
                        blurRadius: 30, // Strong Glow
                        color: effectiveColor, // Glow with own color
                        offset: const Offset(0, 0)),
                    Shadow(
                        blurRadius: 10,
                        color: Colors.black, // Contrast
                        offset: const Offset(2, 2)),
                  ],
                ),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 48, // Same size as title
                    color: effectiveColor,
                    fontWeight: FontWeight.w900, // Bold
                    shadows: [
                      Shadow(blurRadius: 20, color: effectiveColor, offset: const Offset(0, 0)),
                      Shadow(blurRadius: 10, color: Colors.black, offset: const Offset(2, 2)),
                    ],
                  ),
                ),
              ),
            ],
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],
          ],
        ),
      ),
    );
  }
}
