

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
      secondary: neonMagenta,
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
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 30,
          color: neonCyan,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0, // Wider for sci-fi feel
          shadows: [
            Shadow(blurRadius: 10, color: neonCyan.withValues(alpha: 0.8), offset: const Offset(0, 0)),
          ],
        ),
        iconTheme: const IconThemeData(color: neonCyan),
      ),

      textTheme: TextTheme(
        // Headlines: Orbitron for everything
        displayLarge: GoogleFonts.orbitron(color: neonCyan, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        displayMedium: GoogleFonts.orbitron(color: neonCyan, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        displaySmall: GoogleFonts.orbitron(color: neonCyan, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        
        // Body: Orbitron (cleaner weight)
        bodyLarge: GoogleFonts.orbitron(color: textWhite, fontSize: 18),
        bodyMedium: GoogleFonts.orbitron(color: textWhite, fontSize: 16),
        bodySmall: GoogleFonts.orbitron(color: neonCyan.withValues(alpha: 0.8), fontSize: 14),
        
        // Buttons
        labelLarge: GoogleFonts.orbitron(
            color: textBlack, 
            fontSize: 20, 
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: neonCyan,
        size: 28,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkMatrix,
        titleTextStyle: GoogleFonts.orbitron(color: neonCyan, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        contentTextStyle: GoogleFonts.orbitron(color: textWhite, fontSize: 16),
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
        secondary: neonMagenta,
        surface: darkMatrix,
        error: Color(0xFFFF3333),
        onPrimary: textBlack,
        onSecondary: textBlack,
        onSurface: textWhite,
      ),
    );
  }
}

class SteampunkTheme {
  // Palette
  static const Color mahoganyDark = Color(0xFF2D160E);   // Deep wood for background
  static const Color mahoganyLight = Color(0xFF4A2817);  // Lighter wood for cards
  static const Color brassPrimary = Color(0xFFCDBE78);   // Main brass/gold color
  static const Color brassDark = Color(0xFF8B7E40);      // Shadow/Border brass
  static const Color brassBright = Color(0xFFFFF5C3);    // Highlight
  static const Color verdigris = Color(0xFF43B3AE);      // Oxidized copper accent
  static const Color leatherDark = Color(0xFF1A1110);    // Deepest shadow
  static const Color steamWhite = Color(0xFFE0E0E0);     // Text color (off-white)
  static const Color amberGlow = Color(0xFFFFA000);      // Active/Highlight glow

  static ThemeData get themeData {
    const colors = FortuneColors(
      themeId: 'steampunk',
      backgroundMain: mahoganyDark,
      backgroundCard: mahoganyLight,
      primary: brassPrimary,
      primaryDark: brassDark,
      primaryBright: brassBright,
      secondary: verdigris,
      accent: amberGlow,
      textMain: steamWhite,
      textContrast: leatherDark,
      // Semantic colors (Steampunk theme)
      danger: Color(0xFFD32F2F),           // Classic red (danger)
      dangerLight: Color(0xFF5D1B1B),      // Dark red background
      dangerDark: Color(0xFF8B0000),       // Deep red border
      success: verdigris,                  // Oxidized copper (success)
      successLight: Color(0xFF1B3D3A),     // Dark teal background
      successDark: Color(0xFF2B6B66),      // Deep teal border
      warning: amberGlow,                  // Amber glow (warning)
      warningLight: Color(0xFF4D3400),     // Dark amber background
      warningDark: Color(0xFFFFB300),      // Bright amber border
      info: brassBright,                   // Brass bright (info)
      disabled: Color(0xFF5A5A5A),         // Gray
      overlay: Color(0xBB1A1110),          // Semi-transparent dark
      // Chart colors
      chartBlue: Color(0xFF5DADE2),
      chartGreen: verdigris,
      chartOrange: amberGlow,
      chartPurple: Color(0xFF9B59B6),
      chartRed: Color(0xFFE74C3C),
      chartAmber: Color(0xFFF39C12),
      backgroundImagePath: 'assets/images/ui/background.png',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: brassPrimary,
      scaffoldBackgroundColor: mahoganyDark,
      
      extensions: const [colors],

      
      // Card Theme (Leather/Wood look)
      cardTheme: CardThemeData(
        color: mahoganyLight,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: brassDark, width: 2),
        ),
      ),
      
        // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: mahoganyDark,
        foregroundColor: brassPrimary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.crimsonPro(
          fontSize: 30, // Slightly larger to match presence
          fontWeight: FontWeight.w800, // Extra Bold for Title
          color: brassPrimary,
          shadows: [
            const Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
        iconTheme: const IconThemeData(color: brassPrimary),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        // Headlines (Victorian style -> Classic Serif)
        displayLarge: GoogleFonts.crimsonPro(color: brassPrimary, fontSize: 36, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.crimsonPro(color: brassPrimary, fontSize: 28, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.crimsonPro(color: brassPrimary, fontSize: 24, fontWeight: FontWeight.w700),
        
        // Body text (Readable Serif or Slab Serif)
        bodyLarge: GoogleFonts.libreBaskerville(color: steamWhite, fontSize: 18),
        bodyMedium: GoogleFonts.libreBaskerville(color: steamWhite, fontSize: 16),
        bodySmall: GoogleFonts.libreBaskerville(color: brassPrimary.withValues(alpha: 0.8), fontSize: 14),
        
        // Button text (Condensed, Bold Serif)
        labelLarge: GoogleFonts.crimsonPro(
            color: leatherDark, 
            fontSize: 20, // Slightly larger than Rye's 18 as it's more compact
            fontWeight: FontWeight.w900, 
            letterSpacing: 0.5 // Reduce spacing slightly
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: brassPrimary,
        size: 28,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: mahoganyLight,
        titleTextStyle: GoogleFonts.crimsonPro(color: brassPrimary, fontSize: 26, fontWeight: FontWeight.bold),
        contentTextStyle: GoogleFonts.libreBaskerville(color: steamWhite, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: brassPrimary, width: 3),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: brassDark,
        thickness: 1,
      ), colorScheme: const ColorScheme.dark(
        primary: brassPrimary,
        secondary: verdigris,
        surface: mahoganyLight,
        // background: mahoganyDark, // Deprecated in recent Flutter but safe to omit if surface covers it
        error: Color(0xFFCF6679),
        onPrimary: leatherDark,
        onSecondary: leatherDark,
        onSurface: steamWhite,
      ),
    );
  }
}

