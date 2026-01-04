import 'package:flutter/material.dart';
import '../theme/fortune_theme.dart';

class VideoLogo extends StatelessWidget {
  final VoidCallback? onUserInteraction;
  
  const VideoLogo({super.key, this.onUserInteraction});

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = FortuneColors.of(context);
    
    // Static Logo V2 (Placeholder for future video)
    return Center(
      child: GestureDetector(
        onTap: onUserInteraction,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent, 
            boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 4)),
               // Outer glow matching theme
               BoxShadow(color: fortuneTheme.accent.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
            ],
            // Thin border to define edge
            border: Border.all(color: fortuneTheme.primary.withValues(alpha: 0.8), width: 2), 
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_v2.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
