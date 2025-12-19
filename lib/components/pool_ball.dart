import 'dart:math';
import 'package:flutter/material.dart';

class PoolBall extends StatelessWidget {
  final int number;
  final double size;
  final bool isPotted;

  const PoolBall({
    super.key,
    required this.number,
    this.size = 40.0,
    this.isPotted = false,
  });

  static const Map<int, Map<String, Color>> _ballPalette = {
    1: {'base': Color(0xFFFFD700), 'shadow': Color(0xFFDAA520)}, // Yellow
    2: {'base': Color(0xFF0288D1), 'shadow': Color(0xFF01579B)}, // Blue
    3: {'base': Color(0xFFFF3333), 'shadow': Color(0xFFCC0000)}, // Red
    4: {'base': Color(0xFFAB47BC), 'shadow': Color(0xFF7B1FA2)}, // Purple
    5: {'base': Color(0xFFFF9800), 'shadow': Color(0xFFE65100)}, // Orange
    6: {'base': Color(0xFF4CAF50), 'shadow': Color(0xFF1B5E20)}, // Green
    7: {'base': Color(0xFF8D6E63), 'shadow': Color(0xFF4E342E)}, // Brown
    8: {'base': Color(0xFF222222), 'shadow': Color(0xFF000000)}, // Black
    0: {'base': Color(0xFFFFFFFF), 'shadow': Color(0xFFCFD8DC)}, // Cue Ball
  };

  @override
  Widget build(BuildContext context) {
    bool isStripe = number > 8 && number < 16;
    int baseNum = number > 8 ? number - 8 : number;
    var palette = _ballPalette[baseNum] ?? _ballPalette[8]!;

    return Stack(
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _BallPainter(
            number: number,
            isStripe: isStripe,
            isCue: number == 0,
            baseColor: palette['base']!,
            shadowColor: palette['shadow']!,
          ),
        ),
        if (isPotted)
          Opacity(
            opacity: 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _BallPainter extends CustomPainter {
  final int number;
  final bool isStripe;
  final bool isCue;
  final Color baseColor;
  final Color shadowColor;

  _BallPainter({
    required this.number,
    required this.isStripe,
    required this.isCue,
    required this.baseColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final center = Offset(r, r);

    // 1. Base Sphere
    final Color mainBase = isStripe ? Colors.white : baseColor;
    final Color mainShadow = isStripe ? const Color(0xFFCFD8DC) : shadowColor;

    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.8,
        colors: [mainBase, mainShadow],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(center, r, basePaint);

    // 2. Stripe Band
    if (isStripe) {
      final stripePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.6,
          colors: [baseColor, shadowColor],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final Path stripePath = Path()
        ..addRect(Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.6));
      
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)));
      canvas.drawPath(stripePath, stripePaint);
      canvas.restore();
    }

    // 3. Badge (Number Circle)
    if (!isCue) {
      final badgePaint = Paint()..color = const Color(0xFFF0F0F0);
      canvas.drawCircle(center, size.width * 0.28, badgePaint);

      // 4. Number Text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$number',
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.35,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // 5. Specular Highlight (The "Plastic" Gloss)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0)],
      ).createShader(Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.4, size.height * 0.3));

    canvas.save();
    canvas.translate(size.width * 0.28, size.height * 0.24);
    canvas.rotate(-pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 0.45, height: size.height * 0.3),
      highlightPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
