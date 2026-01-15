import 'package:flutter/material.dart';
import '../../theme/fortune_theme.dart';

/// A number picker with +/- buttons for adjusting values.
///
/// Used for handicap adjustments and multiplier selectors.
class HandicapPicker extends StatelessWidget {
  /// Label text displayed before the picker
  final String label;

  /// Current value
  final int value;

  /// Callback when value changes
  final ValueChanged<int> onChanged;

  /// Increment/decrement step (default: 5)
  final int step;

  /// Minimum allowed value (default: 0)
  final int? minValue;

  /// Maximum allowed value (optional)
  final int? maxValue;

  /// Display format (e.g., show '+' prefix for positive values)
  final String Function(int)? formatter;

  const HandicapPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 5,
    this.minValue = 0,
    this.maxValue,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FortuneColors.of(context);
    final canDecrement = minValue == null || value > minValue!;
    final canIncrement = maxValue == null || value < maxValue!;

    String displayValue = formatter?.call(value) ?? value.toString();
    if (formatter == null && value > 0) {
      displayValue = '+$value';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: canDecrement
              ? () => onChanged(value - step)
              : null,
          color: theme.primary,
        ),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: canIncrement
              ? () => onChanged(value + step)
              : null,
          color: theme.primary,
        ),
      ],
    );
  }
}
