import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/fortune_theme.dart';

class GameControlButton extends StatelessWidget {
  final String text;
  final String? subText; // For penalty value e.g. "-1"
  final VoidCallback onPressed;
  final Color activeColor;
  final bool isActive;
  final bool isDestructive; // For Red styling

  const GameControlButton({
    super.key,
    required this.text,
    this.subText,
    required this.onPressed,
    required this.activeColor,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    
    // Determine effective toggle color (Active or Default Grey/White)
    final effectiveColor = isActive 
        ? activeColor 
        : colors.textMain.withValues(alpha: 0.7);
        
    final borderColor = isActive 
        ? activeColor 
        : colors.primaryDark.withValues(alpha: 0.3);

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 48, // Standard touch target
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4), // Dark translucent bg
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: isActive ? 2.0 : 1.0,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: text.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: effectiveColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (subText != null) ...[
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: subText,
                      style: GoogleFonts.orbitron(
                        color: effectiveColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
