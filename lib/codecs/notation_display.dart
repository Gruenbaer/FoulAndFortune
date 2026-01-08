// lib/codecs/notation_display.dart
//
// Display renderer for notation.
// - Storage is always FF14_Canonical.
// - FF14_Annotated display uses mixed delimiters by rule:
//    delimiter between segments i-1 and i:
//      if segments[i-1] == 15 -> rack delimiter (| or /)
//      else -> phase delimiter (·)

import 'notation_codec.dart';
import 'notation_format.dart';
import '../models/game_settings.dart';

/// Render canonical notation for display based on user settings.
/// 
/// **Mixed delimiter rule**: When using FF14_Annotated format,
/// the delimiter between segments depends on the previous segment value:
/// - If previous segment == 15: use rack delimiter (| or /)
/// - Otherwise: use phase delimiter (·)
/// 
/// Example with rack=|, phase=·:
/// - Canonical: `15⟲14⟲5F`
/// - Display: `15|14·5F` (rack boundary after 15)
String renderNotationForDisplay(String canonicalNotation, GameSettings settings) {
  if (settings.notationFormat == NotationFormat.ff14Canonical) {
    return canonicalNotation;
  }

  try {
    final rec = NotationCodec.parseCanonical(canonicalNotation);

    final rackSep = settings.rackDelimiterStyle.symbol;
    final phaseSep = settings.phaseDelimiterStyle.symbol;

    final segs = rec.segments;
    if (segs.isEmpty) return canonicalNotation;

    final buf = StringBuffer();
    for (int i = 0; i < segs.length; i++) {
      if (i > 0) {
        final prev = segs[i - 1];
        buf.write(prev == 15 ? rackSep : phaseSep);
      }
      buf.write(segs[i].toString());
    }

    if (rec.safe) buf.write('S');
    switch (rec.foul) {
      case FoulType.none:
        break;
      case FoulType.normal:
        buf.write('F');
        break;
      case FoulType.breakFoul:
        buf.write('BF');
        break;
      case FoulType.threeFouls:
        buf.write('TF');
        break;
    }

    return buf.toString();
  } catch (e) {
    // Fallback to canonical if parsing fails
    return canonicalNotation;
  }
}

/// Batch render multiple canonical notations for display.
List<String> renderListForDisplay(
  List<String> canonicalNotations,
  GameSettings settings,
) {
  return canonicalNotations
      .map((notation) => renderNotationForDisplay(notation, settings))
      .toList();
}
