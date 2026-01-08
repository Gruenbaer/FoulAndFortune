import '../codecs/notation_codec.dart';
import '../codecs/ff14_annotated_codec.dart';
import '../codecs/notation_format.dart';
import '../models/game_settings.dart';

/// Helper functions for rendering notation in different formats for display
class NotationRenderer {
  /// Convert canonical notation to display format based on user settings
  /// 
  /// Takes a canonical notation string and renders it according to the
  /// selected notation format and delimiter style from settings.
  /// 
  /// **Storage invariant**: Notation is always stored in canonical format.
  /// This function is used ONLY for display purposes.
  /// 
  /// Example:
  /// ```dart
  /// final canonical = '15⟲14⟲5F';
  /// final settings = GameSettings(
  ///   notationFormat: NotationFormat.ff14Annotated,
  ///   delimiterStyle: DelimiterStyle.bar,
  /// );
  /// final display = NotationRenderer.renderForDisplay(canonical, settings);
  /// // Result: '15|14|5F'
  /// ```
  static String renderForDisplay(String canonicalNotation, GameSettings settings) {
    // If using canonical format, return as-is
    if (settings.notationFormat == NotationFormat.ff14Canonical) {
      return canonicalNotation;
    }
    
    // For annotated format, parse canonical and re-serialize with chosen delimiter
    try {
      final record = NotationCodec.parseCanonical(canonicalNotation);
      return FF14AnnotatedCodec.serialize(
        record,
        delimiter: settings.delimiterStyle,
      );
    } catch (e) {
      // Fallback to canonical if parsing fails (shouldn't happen with valid data)
      return canonicalNotation;
    }
  }
  
  /// Batch convert multiple canonical notations for display
  /// 
  /// Useful when rendering score cards or game history with multiple innings.
  static List<String> renderListForDisplay(
    List<String> canonicalNotations,
    GameSettings settings,
  ) {
    return canonicalNotations
        .map((notation) => renderForDisplay(notation, settings))
        .toList();
  }
}
