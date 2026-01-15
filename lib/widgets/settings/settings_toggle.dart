import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';

/// A themed switch toggle with title, subtitle, and optional icon.
///
/// Provides consistent styling for all toggle controls across the app.
class SettingsToggle extends StatelessWidget {
  /// Title text for the toggle
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Current toggle state
  final bool value;

  /// Callback when toggle state changes
  final ValueChanged<bool> onChanged;

  /// Optional leading icon
  final IconData? icon;

  const SettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FortuneColors.of(context);

    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
      activeColor: theme.secondary,
      activeTrackColor: theme.secondary.withValues(alpha: 0.5),
      inactiveThumbColor: theme.disabled,
      inactiveTrackColor: theme.primaryDark.withValues(alpha: 0.5),
    );
  }
}
