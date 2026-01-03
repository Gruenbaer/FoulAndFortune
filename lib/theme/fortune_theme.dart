

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
@immutable
class FortuneColors extends ThemeExtension<FortuneColors> {
  final String themeId; // Theme identifier
  
  // Base colors
  final Color backgroundMain;
  final Color backgroundCard;
  final Color primary;
  final Color primaryDark;
  final Color primaryBright;
  final Color secondary;
  final Color accent;
  final Color textMain;
  final Color textContrast;
  final String? backgroundImagePath;
  
  // Semantic colors (theme-aware UI states)
  final Color danger;        // Errors, delete actions
  final Color dangerLight;   // Danger backgrounds
  final Color dangerDark;    // Danger borders/text
  final Color success;       // Confirmations, wins
  final Color successLight;  // Success backgrounds
  final Color successDark;   // Success borders/text
  final Color warning;       // Warnings, alerts
  final Color warningLight;
  final Color warningDark;
  final Color info;          // Informational
  final Color disabled;      // Inactive states
  final Color overlay;       // Modal backdrops
  
  // Chart/Stats colors (theme-aware)
  final Color chartBlue;
  final Color chartGreen;
  final Color chartOrange;
  final Color chartPurple;
  final Color chartRed;
  final Color chartAmber;

  const FortuneColors({
    required this.themeId,
    required this.backgroundMain,
    required this.backgroundCard,
    required this.primary,
    required this.primaryDark,
    required this.primaryBright,
    required this.secondary,
    required this.accent,
    required this.textMain,
    required this.textContrast,
    required this.danger,
    required this.dangerLight,
    required this.dangerDark,
    required this.success,
    required this.successLight,
    required this.successDark,
    required this.warning,
    required this.warningLight,
    required this.warningDark,
    required this.info,
    required this.disabled,
    required this.overlay,
    required this.chartBlue,
    required this.chartGreen,
    required this.chartOrange,
    required this.chartPurple,
    required this.chartRed,
    required this.chartAmber,
    this.backgroundImagePath,
  });

  // Helper to access colors easily
  static FortuneColors of(BuildContext context) {
    return Theme.of(context).extension<FortuneColors>()!;
  }

  @override
  FortuneColors copyWith({
    String? themeId,
    Color? backgroundMain,
    Color? backgroundCard,
    Color? primary,
    Color? primaryDark,
    Color? primaryBright,
    Color? secondary,
    Color? accent,
    Color? textMain,
    Color? textContrast,
    Color? danger,
    Color? dangerLight,
    Color? dangerDark,
    Color? success,
    Color? successLight,
    Color? successDark,
    Color? warning,
    Color? warningLight,
    Color? warningDark,
    Color? info,
    Color? disabled,
    Color? overlay,
    Color? chartBlue,
    Color? chartGreen,
    Color? chartOrange,
    Color? chartPurple,
    Color? chartRed,
    Color? chartAmber,
    String? backgroundImagePath,
  }) {
    return FortuneColors(
      themeId: themeId ?? this.themeId,
      backgroundMain: backgroundMain ?? this.backgroundMain,
      backgroundCard: backgroundCard ?? this.backgroundCard,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryBright: primaryBright ?? this.primaryBright,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      textMain: textMain ?? this.textMain,
      textContrast: textContrast ?? this.textContrast,
      danger: danger ?? this.danger,
      dangerLight: dangerLight ?? this.dangerLight,
      dangerDark: dangerDark ?? this.dangerDark,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      successDark: successDark ?? this.successDark,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      warningDark: warningDark ?? this.warningDark,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
      overlay: overlay ?? this.overlay,
      chartBlue: chartBlue ?? this.chartBlue,
      chartGreen: chartGreen ?? this.chartGreen,
      chartOrange: chartOrange ?? this.chartOrange,
      chartPurple: chartPurple ?? this.chartPurple,
      chartRed: chartRed ?? this.chartRed,
      chartAmber: chartAmber ?? this.chartAmber,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }

  @override
  FortuneColors lerp(ThemeExtension<FortuneColors>? other, double t) {
    if (other is! FortuneColors) return this;
    return FortuneColors(
      themeId: t < 0.5 ? themeId : other.themeId,
      backgroundMain: Color.lerp(backgroundMain, other.backgroundMain, t)!,
      backgroundCard: Color.lerp(backgroundCard, other.backgroundCard, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryBright: Color.lerp(primaryBright, other.primaryBright, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textContrast: Color.lerp(textContrast, other.textContrast, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerLight: Color.lerp(dangerLight, other.dangerLight, t)!,
      dangerDark: Color.lerp(dangerDark, other.dangerDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      warningDark: Color.lerp(warningDark, other.warningDark, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      chartBlue: Color.lerp(chartBlue, other.chartBlue, t)!,
      chartGreen: Color.lerp(chartGreen, other.chartGreen, t)!,
      chartOrange: Color.lerp(chartOrange, other.chartOrange, t)!,
      chartPurple: Color.lerp(chartPurple, other.chartPurple, t)!,
      chartRed: Color.lerp(chartRed, other.chartRed, t)!,
      chartAmber: Color.lerp(chartAmber, other.chartAmber, t)!,
      backgroundImagePath: t < 0.5 ? backgroundImagePath : other.backgroundImagePath,
    );
  }
}

class CyberpunkTheme {
  // Cyberpunk Palette
  static const Color blackVoid = Color(0xFF020408);
  static const Color darkMatrix = Color(0xFF0A1020);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color darkCyan = Color(0xFF008088);
  static const Color brightCyan = Color(0xFFD0FFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonGreen = Color(0xFF39FF14); // Acid Green
  static const Color textWhite = Color(0xFFE0E0E0);
  static const Color textBlack = Color(0xFF050505);

  static ThemeData get themeData {
    const colors = FortuneColors(
      themeId: 'cyberpunk',
      backgroundMain: blackVoid,
      backgroundCard: darkMatrix,
      primary: neonCyan,
      primaryDark: darkCyan,
      primaryBright: brightCyan,
      secondary: neonCyan, // Changed from neonMagenta to match cyan theme
      accent: neonGreen,
      textMain: textWhite,
      textContrast: textBlack,
      // Semantic colors (Cyberpunk theme)
      danger: Color(0xFFFF005E),           // Hot pink (cyber danger)
      dangerLight: Color(0xFF4D001F),      // Dark pink background
      dangerDark: Color(0xFFFF3366),       // Bright pink border
      success: neonGreen,                  // Acid green success
      successLight: Color(0xFF1A3D0F),     // Dark green background
      successDark: Color(0xFF5AFF33),      // Bright green border
      warning: Color(0xFFFFCC00),          // Cyber yellow
      warningLight: Color(0xFF332900),     // Dark yellow background
      warningDark: Color(0xFFFFDD33),      // Bright yellow border
      info: neonCyan,                      // Info same as primary
      disabled: Color(0xFF404040),         // Dark gray
      overlay: Color(0xBB020408),          // Semi-transparent black
      // Chart colors
      chartBlue: neonCyan,
      chartGreen: neonGreen,
      chartOrange: Color(0xFFFF6600),
      chartPurple: neonMagenta,
      chartRed: Color(0xFFFF005E),
      chartAmber: Color(0xFFFFCC00),
      backgroundImagePath: null,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: neonCyan,
      scaffoldBackgroundColor: blackVoid,
      
      extensions: const [colors], // <--- Critical for access

      cardTheme: CardThemeData(
        color: darkMatrix,
        elevation: 8,
        shadowColor: neonCyan.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Sharper corners for Cyberpunk
          side: const BorderSide(color: darkCyan, width: 2),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: blackVoid,
        foregroundColor: neonCyan,
        centerTitle: true,
        titleTextStyle: GoogleFonts.crimsonPro(
          fontSize: 30,
          color: neonCyan,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5, // Reduced spacing
          shadows: [
            Shadow(blurRadius: 10, color: neonCyan.withValues(alpha: 0.8), offset: const Offset(0, 0)),
          ],
        ),
        iconTheme: const IconThemeData(color: neonCyan),
      ),

      textTheme: TextTheme(
        // Headlines: Serif instead of Orbitron, but kept bold/neon
        displayLarge: GoogleFonts.crimsonPro(color: neonCyan, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.crimsonPro(color: neonCyan, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.crimsonPro(color: neonCyan, fontSize: 24, fontWeight: FontWeight.bold),
        
        // Body: LibreBaskerville for consistency ("normal serif")
        bodyLarge: GoogleFonts.libreBaskerville(color: textWhite, fontSize: 18),
        bodyMedium: GoogleFonts.libreBaskerville(color: textWhite, fontSize: 16),
        bodySmall: GoogleFonts.libreBaskerville(color: neonCyan.withValues(alpha: 0.8), fontSize: 14),
        
        // Buttons
        labelLarge: GoogleFonts.crimsonPro(
            color: textBlack, 
            fontSize: 20, 
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: neonCyan,
        size: 28,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkMatrix,
        titleTextStyle: GoogleFonts.crimsonPro(color: neonCyan, fontSize: 26, fontWeight: FontWeight.bold),
        contentTextStyle: GoogleFonts.libreBaskerville(color: textWhite, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: neonCyan, width: 2),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: darkCyan,
        thickness: 1,
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonCyan, // Changed from neonMagenta to cyan
        surface: darkMatrix,
        error: Color(0xFFFF3333),
        onPrimary: textBlack,
        onSecondary: textBlack,
        onSurface: textWhite,
      ),
    );
  }
}
