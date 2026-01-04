
import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Base Content Widget for Splash Screens
/// Provides standard consistent styling for text and icons
class SplashContent extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final Widget? customContent;
  final Color? textColor;
  final Color? subtitleColor; // Support distinct scale/color for subtitle
  final Color? subtitleGlowColor; // Support distinct glow for subtitle
  final Color? backgroundColor; // Background for the splash box

  const SplashContent({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.textColor,
    this.subtitleColor,
    this.subtitleGlowColor,
    this.backgroundColor,
    this.customContent,
  });

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    // Staggered Delay: Start appearing after 200ms (reduced from 450ms)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final effectiveColor = widget.color ?? colors.primaryBright;
    final effectiveTextColor = widget.textColor ?? effectiveColor;
    final effectiveSubtitleColor = widget.subtitleColor ?? effectiveTextColor;
    final effectiveSubtitleGlow = widget.subtitleGlowColor ?? effectiveSubtitleColor;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: widget.backgroundColor != null 
          ? BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  widget.backgroundColor!, 
                  widget.backgroundColor!.withOpacity(0.0)
                ],
                stops: const [0.2, 1.0], // Core is solid-ish, then fades
                radius: 0.8,
              ),
              // No border or box shadow, just the fade
            )
          : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon removed from here, let specific contents decide if they strictly need it, 
            // but user said "remove the icon" for re-rack and implied minimal style.
            // We'll keep icon support but specific widgets might not pass it.
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 80,
                color: effectiveColor,
                shadows: [
                  Shadow(blurRadius: 20, color: effectiveColor, offset: const Offset(0, 0)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron( // Orbitron Font
                textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48, // Reduced from 64
                  color: effectiveTextColor, // Use specific text color
                  height: 1.0, 
                  shadows: [
                    Shadow(
                        blurRadius: 30, // Strong Glow
                        color: effectiveColor, // Glow with GLOW color
                        offset: const Offset(0, 0)),
                    const Shadow(
                        blurRadius: 10,
                        color: Colors.black, // Contrast
                        offset: Offset(2, 2)),
                  ],
                ),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 12),
              // Animated Subtitle
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 100, // Increased from 80
                        color: effectiveSubtitleColor, // Use specific text color
                        fontWeight: FontWeight.w900, // Bold
                        shadows: [
                          // Use distinct glow color (e.g. Yellow) or default to subtitle color
                          Shadow(blurRadius: 30, color: effectiveSubtitleGlow, offset: const Offset(0, 0)), // Strong outer glow
                          Shadow(blurRadius: 10, color: effectiveSubtitleGlow, offset: const Offset(0, 0)), // Inner tight glow
                          const Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)), // Sharp drop shadow for legibility
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.customContent != null) ...[
              const SizedBox(height: 16),
              widget.customContent!,
            ],
          ],
        ),
      ),
    );
  }
}
