import 'package:flutter/material.dart';
import 'fortune_theme.dart';

/// Extension methods for easier theme access throughout the app
extension ThemeContextExtension on BuildContext {
  /// Quick access to FortuneColors
  FortuneColors get fortuneColors => FortuneColors.of(this);
  
  /// Check if current theme is Cyberpunk
  bool get isCyberpunk => fortuneColors.themeId == 'cyberpunk';
  
  /// Check if current theme is Steampunk
  bool get isSteampunk => fortuneColors.themeId == 'steampunk';
}

/// Helper class for theme-aware styling
class ThemeStyleHelper {
  /// Get themed border for cards
  static BoxBorder themedCardBorder(BuildContext context) {
    final colors = FortuneColors.of(context);
    return Border.all(
      color: colors.primaryDark,
      width: 2,
    );
  }
  
  /// Get themed box decoration for containers
  static BoxDecoration themedContainer(
    BuildContext context, {
    bool isCard = false,
    double borderRadius = 12,
    double borderWidth = 2,
  }) {
    final colors = FortuneColors.of(context);
    return BoxDecoration(
      color: isCard ? colors.backgroundCard : colors.backgroundMain,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: colors.primary,
        width: borderWidth,
      ),
    );
  }
  
  /// Get themed elevated decoration with shadow
  static BoxDecoration themedElevatedCard(
    BuildContext context, {
    double borderRadius = 12,
    bool glowEffect = false,
  }) {
    final colors = FortuneColors.of(context);
    final isCyberpunk = context.isCyberpunk;
    
    return BoxDecoration(
      color: colors.backgroundCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: colors.primaryDark, width: 2),
      boxShadow: glowEffect && isCyberpunk
          ? [
              BoxShadow(
                color: colors.primary.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
  
  /// Get themed button style
  static ButtonStyle themedButtonStyle(
    BuildContext context, {
    bool isPrimary = true,
    EdgeInsets? padding,
  }) {
    final colors = FortuneColors.of(context);
    
    return ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? colors.primary : colors.secondary,
      foregroundColor: colors.textContrast,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isPrimary ? colors.primaryDark : colors.secondary,
          width: 2,
        ),
      ),
    );
  }
  
  /// Get themed divider
  static Widget themedDivider(BuildContext context, {double thickness = 1}) {
    final colors = FortuneColors.of(context);
    return Divider(
      color: colors.primaryDark,
      thickness: thickness,
    );
  }
  
  /// Get accent color for highlights/active states
  static Color getAccentColor(BuildContext context) {
    return FortuneColors.of(context).accent;
  }
  
  /// Get proper text color for contrast
  static Color getTextColor(BuildContext context, {bool onPrimary = false}) {
    final colors = FortuneColors.of(context);
    return onPrimary ? colors.textContrast : colors.textMain;
  }
}

/// Widget builder that provides theme colors to its child
class ThemedBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, FortuneColors colors) builder;
  
  const ThemedBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return builder(context, FortuneColors.of(context));
  }
}

/// Wrapper widget that applies themed container styling
class ThemedContainer extends StatelessWidget {
  final Widget child;
  final bool isCard;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  
  const ThemedContainer({
    super.key,
    required this.child,
    this.isCard = false,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.padding,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: ThemeStyleHelper.themedContainer(
        context,
        isCard: isCard,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
      ),
      child: child,
    );
  }
}

/// Themed card with elevation and glow effects
class ThemedCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool glowEffect;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  
  const ThemedCard({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.glowEffect = false,
    this.padding,
    this.margin,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final container = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: ThemeStyleHelper.themedElevatedCard(
        context,
        borderRadius: borderRadius,
        glowEffect: glowEffect,
      ),
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }
    
    return container;
  }
}
