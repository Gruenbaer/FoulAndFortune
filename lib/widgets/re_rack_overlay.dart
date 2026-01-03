import 'package:flutter/material.dart';
import '../theme/fortune_theme.dart';
import 'themed_widgets.dart';

class ReRackOverlay extends StatefulWidget {
  final String type; // e.g. "14.1 Re-Rack"
  final VoidCallback onFinish;

  const ReRackOverlay({
    super.key,
    required this.type,
    required this.onFinish,
  });

  @override
  State<ReRackOverlay> createState() => _ReRackOverlayState();
}

class _ReRackOverlayState extends State<ReRackOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Simpler, faster animation
       vsync: this,
    );

    // Zoom in, Pause, Zoom out
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.2), weight: 60), // Longer hold
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 2.0), weight: 20), // Zoom out huge at end
    ]).animate(_controller);

    // Fade In, Hold, Fade Out
    _opacityAnimation = TweenSequence([
       TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
       TweenSequenceItem(tween: ConstantTween(1.0), weight: 70), // Longer hold
       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onFinish());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: CustomPaint(
                  painter: colors.themeId == 'cyberpunk'
                      ? CyberpunkFramePainter(colors)
                      : (colors.themeId == 'ghibli'
                          ? GhibliFramePainter(colors, seed: 42) // Constant seed for consistency
                          : BrassFramePainter(colors)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.backgroundMain.withValues(alpha: 0.9), // Fill background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.type,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            color: colors.primaryBright,
                            shadows: [
                              Shadow(blurRadius: 10, color: colors.accent, offset: const Offset(0, 0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
