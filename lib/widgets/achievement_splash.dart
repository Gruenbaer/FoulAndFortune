import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../models/game_settings.dart';
import '../theme/fortune_theme.dart';

class AchievementSplash extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementSplash({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementSplash> createState() => _AchievementSplashState();
}

class _AchievementSplashState extends State<AchievementSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _controller.forward();
    
    // Start confetti and sound
    Future.delayed(const Duration(milliseconds: 400), () {
      _confettiController.play();
      if (mounted) _playHornSound();
    });
  }

  Future<void> _playHornSound() async {
    try {
      // Use AssetSource for local assets or UrlSource for web
      // For now, using a simple system beep sound
      final soundEnabled = Provider.of<GameSettings>(context, listen: false).soundEnabled;
      if (!soundEnabled) return;

      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      // Play a notification-like sound (you can replace with custom horn.mp3)
      await _audioPlayer.play(AssetSource('sounds/horn.mp3'));
    } catch (e) {
      // Fallback: no sound if asset not found
      debugPrint('Sound error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Stack(
          children: [
            // Confetti from top center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                ],
              ),
            ),

            // Close Button (Top Right)
            Positioned(
              top: 50,
              right: 20,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: IconButton(
                   icon: const Icon(Icons.close, color: Colors.white, size: 32),
                   onPressed: widget.onDismiss,
                   tooltip: 'Close',
                ),
              ),
            ),
            
            // Achievement content
            Container(
              color: Colors.transparent,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: FortuneColors.of(context).backgroundCard,
                          border: Border.all(
                            color: FortuneColors.of(context).success,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: FortuneColors.of(context).success.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with trophies on same height
                            // Header with trophies on left/right and 2-line text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left Icon
                                Text(
                                  '🏆',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: FortuneColors.of(context).success,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Centered Text Stack
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ACHIEVEMENT',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: FortuneColors.of(context).success,
                                        letterSpacing: 2,
                                        fontFamily: 'Orbitron',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'UNLOCKED!',
                                      style: TextStyle(
                                        fontSize: 20, // Same size for consistency
                                        fontWeight: FontWeight.w900,
                                        color: FortuneColors.of(context).success,
                                        letterSpacing: 2,
                                        fontFamily: 'Orbitron',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Right Icon
                                Text(
                                  '🏆',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: FortuneColors.of(context).success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Emoji
                            Text(
                              widget.achievement.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                            const SizedBox(height: 16),
                            
                            // Title (Two lines allowed)
                            Text(
                              widget.achievement.title,
                              style: TextStyle(
                                fontSize: 24, // Reduced from 32
                                fontWeight: FontWeight.bold,
                                color: FortuneColors.of(context).textMain,
                                fontFamily: 'Orbitron',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 12),
                            
                            // Description (Flexible)
                            Text(
                              widget.achievement.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: FortuneColors.of(context).textMain.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 24),
                            
                            // Divider
                            Container(
                              height: 2,
                              width: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    FortuneColors.of(context).success,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // How to unlock explanation
                            Text(
                              widget.achievement.howToUnlock,
                              style: TextStyle(
                                fontSize: 14,
                                color: FortuneColors.of(context).textMain.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Show who unlocked it (if available)
                            if (widget.achievement.unlockedBy.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Unlocked by: ${widget.achievement.unlockedBy.last}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FortuneColors.of(context).textMain.withValues(alpha: 0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            const SizedBox(height: 24),
                            
                            // OK Button
                            ElevatedButton(
                              onPressed: widget.onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FortuneColors.of(context).success,
                                foregroundColor: Colors.black, // Dark text on success color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                elevation: 8,
                                shadowColor: FortuneColors.of(context).success.withValues(alpha: 0.5),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
