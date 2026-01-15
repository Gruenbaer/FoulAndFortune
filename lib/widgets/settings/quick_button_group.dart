import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';

/// A row of preset value buttons with active/inactive states.
///
/// Used for quick selection of common values (e.g., 25, 50, 100 for race or innings).
class QuickButtonGroup extends StatelessWidget {
  /// List of preset values to display as buttons
  final List<int> values;

  /// Currently selected value
  final int currentValue;

  /// Callback when a value is selected
  final ValueChanged<int> onChanged;

  /// Optional color for active state (defaults to theme primary)
  final Color? activeColor;

  /// Optional color for borders (defaults to activeColor or theme primary)
  final Color? borderColor;

  const QuickButtonGroup({
    super.key,
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.activeColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FortuneColors.of(context);
    final effectiveActiveColor = activeColor ?? theme.primary;
    final effectiveBorderColor = borderColor ?? effectiveActiveColor;

    return Row(
      children: values.map((value) {
        final isSelected = currentValue == value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => onChanged(value),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isSelected ? effectiveActiveColor : Colors.transparent,
                foregroundColor: isSelected ? Colors.white : effectiveActiveColor,
                side: BorderSide(color: effectiveBorderColor, width: 2),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
