import 'package:flutter/material.dart';

class DrillVisualizer extends StatelessWidget {
  final String imageAsset;
  final double? height;
  final BoxFit fit;

  const DrillVisualizer({
    super.key,
    required this.imageAsset,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E14), // Obsidian background matching the cyberpunk theme
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: The New Cyberpunk Table (Background)
          Image.asset(
            'assets/images/cyberpunk_table.png',
            fit: fit,
            opacity: const AlwaysStoppedAnimation(0.6), // Subtle background
          ),
          
          // Layer 2: The Drill Markings (Foreground)
          // We use BlendMode.screen to make the black parts of the source images transparent
          // and keep only the bright/white/red markings.
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.8),
                  Colors.white.withOpacity(0.9),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop, // This applies a global tint to markings
            child: Image.asset(
              imageAsset,
              fit: fit,
              color: Colors.white,
              colorBlendMode: BlendMode.screen, // Essential to remove the black Aufbau-Markierung background
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, size: 48),
            ),
          ),
          
          // Optional: Overlay a slight glass effect or glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(12), // replaced withAlpha for withOpacity
                    Colors.transparent,
                    Colors.cyan.withAlpha(5), // replaced withAlpha for withOpacity
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
