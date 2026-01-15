import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';
import 'quick_button_group.dart';

/// A unified slider control with optional quick-select buttons and custom value display.
///
/// Combines a slider with preset value buttons for common use cases like
/// race-to score and max innings configuration.
class SettingsSlider extends StatelessWidget {
  /// Label text displayed above the slider
  final String label;

  /// Current slider value
  final double value;

  /// Minimum slider value
  final double min;

  /// Maximum slider value
  final double max;

  /// Number of discrete divisions (optional)
  final int? divisions;

  /// Callback when value changes
  final ValueChanged<double> onChanged;

  /// Optional quick-select preset values (e.g., [25, 50, 100])
  final List<int>? quickValues;

  /// Optional custom value formatter (e.g., "Unlimited" for 0)
  final String Function(double)? valueFormatter;

  /// Optional color for quick buttons (defaults to theme primary)
  final Color? quickButtonColor;

  /// Optional color for quick button borders
  final Color? quickButtonBorderColor;

  /// Whether to show the slider label
  final bool showLabel;

  const SettingsSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.quickValues,
    this.valueFormatter,
    this.quickButtonColor,
    this.quickButtonBorderColor,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FortuneColors.of(context);
    final roundedValue = value.round();
    final displayValue = valueFormatter?.call(value) ?? roundedValue.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (showLabel)
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        if (showLabel) const SizedBox(height: 12),

        // Quick buttons (if provided)
        if (quickValues != null) ...[
          QuickButtonGroup(
            values: quickValues!,
            currentValue: roundedValue,
            onChanged: (val) => onChanged(val.toDouble()),
            activeColor: quickButtonColor,
            borderColor: quickButtonBorderColor,
          ),
          const SizedBox(height: 16),
        ],

        // Slider with value display
        Row(
          children: [
            const Text('Custom: '),
            Expanded(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                label: displayValue,
                activeColor: theme.secondary,
                inactiveColor: theme.primaryDark.withValues(alpha: 0.3),
                thumbColor: theme.primary,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
