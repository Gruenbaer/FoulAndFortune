
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Center(
      child: Container(
        width: 280,
        height: 320,
        child: CustomPaint(
          painter: GlowingShieldPainter(),
        ),
      ),
    );
  }
}

class GlowingShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowColor = const Color(0xFF4DA21C);
    final brightGreen = const Color(0xFF7FFF5D); // Even brighter
    final width = size.width;
    final height = size.height;
    
    // Create shield path
    final shieldPath = Path();
    shieldPath.moveTo(width * 0.5, height * 0.1);
    shieldPath.lineTo(width * 0.85, height * 0.25);
    shieldPath.lineTo(width * 0.85, height * 0.55);
    shieldPath.quadraticBezierTo(width * 0.75, height * 0.8, width * 0.5, height * 0.9);
    shieldPath.quadraticBezierTo(width * 0.25, height * 0.8, width * 0.15, height * 0.55);
    shieldPath.lineTo(width * 0.15, height * 0.25);
    shieldPath.close();
    
    // Semi-transparent interior background
    final bgPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, bgPaint);
    
    // Extreme outer glow (widest, very transparent)
    final extremeGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawPath(shieldPath, extremeGlowPaint);
    
    // Very wide outer glow
    final veryOuterGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawPath(shieldPath, veryOuterGlowPaint);
    
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawPath(shieldPath, outerGlowPaint);
    
    // Middle glow
    final midGlowPaint = Paint()
      ..color = brightGreen.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(shieldPath, midGlowPaint);
    
    // Inner glow
    final innerGlowPaint = Paint()
      ..color = brightGreen.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(shieldPath, innerGlowPaint);
    
    // Bright green line (main outline)
    final linePaint = Paint()
      ..color = brightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, linePaint);
    
    // Checkmark inside shield
    final checkPath = Path();
    final checkCenterX = width * 0.5;
    final checkCenterY = height * 0.5;
    
    checkPath.moveTo(checkCenterX - 35, checkCenterY);
    checkPath.lineTo(checkCenterX - 10, checkCenterY + 30);
    checkPath.lineTo(checkCenterX + 45, checkCenterY - 35);
    
    // Checkmark extreme outer glow
    final checkExtremeGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawPath(checkPath, checkExtremeGlowPaint);
    
    // Checkmark outer glow
    final checkOuterGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawPath(checkPath, checkOuterGlowPaint);
    
    // Checkmark middle glow
    final checkMidGlowPaint = Paint()
      ..color = brightGreen.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(checkPath, checkMidGlowPaint);
    
    // Checkmark bright line
    final checkLinePaint = Paint()
      ..color = brightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(checkPath, checkLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
