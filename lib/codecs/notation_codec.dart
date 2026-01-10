/// Codec for parsing and serializing canonical notation strings
/// 
/// Canonical format: `[Segment0] ⟲ [Segment1] ⟲ ... ⟲ [SegmentN] [Suffixes]`
/// Example: `14⟲14⟲5F`
/// 
/// See `GAME_RULES.md` Section 4 for specification.
class NotationCodec {
  /// Separator character (U+27F2)
  static const String separator = '⟲';
  
  /// Canonical regex for validation
  static final RegExp canonicalRegex = RegExp(
    r'^(?:0|[1-9]\d*)(?:⟲(?:0|[1-9]\d*))*S?(?:BF|TF|F)?$',
    unicode: true,
  );

  /// Parse canonical notation string into InningRecord
  /// 
  /// Throws [FormatException] if string does not match canonical format.
  static InningRecord parseCanonical(String notation) {
    if (!canonicalRegex.hasMatch(notation)) {
      throw FormatException('Invalid canonical notation: $notation');
    }

    return _parseValidated(notation);
  }

  /// Parse legacy notation and migrate to canonical format
  /// 
  /// Supports:
  /// - Old separator: `•`, `·`
  /// - Shorthand: `|` → 14
  /// - Empty inning: `-` → 0
  /// - Trailing separators
  /// - Wrong suffix order
  /// 
  /// Throws [FormatException] if migration fails.
  static InningRecord parseLegacy(String notation) {
    final canonical = canonicalize(notation);
    return _parseValidated(canonical);
  }

  /// Attempt to parse notation (canonical first, then legacy fallback)
  static InningRecord parse(String notation) {
    try {
      return parseCanonical(notation);
    } catch (e) {
      return parseLegacy(notation);
    }
  }

  /// Serialize InningRecord to canonical notation
  static String serialize(InningRecord record) {
    if (record.segments.isEmpty) {
      throw ArgumentError('InningRecord must have at least one segment');
    }

    final buffer = StringBuffer();

    // Join segments with separator
    buffer.write(record.segments.join(separator));

    // Add suffix
    if (record.safe) {
      buffer.write('S');
    }

    if (record.foul != FoulType.none) {
      switch (record.foul) {
        case FoulType.breakFoul:
          buffer.write('BF');
          break;
        case FoulType.threeFouls:
          buffer.write('TF');
          break;
        case FoulType.normal:
          buffer.write('F');
          break;
        case FoulType.none:
          break;
      }
    }

    return buffer.toString();
  }

  /// Canonicalize legacy notation to canonical format
  /// 
  /// Performs 9-step migration algorithm from GAME_RULES.md Section 8.3.
  /// 
  /// Throws [FormatException] if input is ambiguous or invalid.
  static String canonicalize(String input) {
    String s = input;

    // Step 1: Trim whitespace
    s = s.trim().replaceAll(RegExp(r'\s+'), '');

    // Step 2: Normalize separators
    s = s.replaceAll('•', separator);
    s = s.replaceAll('·', separator);

    // Step 3: Replace | with 14
    s = s.replaceAll('|', '14');

    // Step 4: Replace - with 0 (only if entire string)
    if (s == '-') {
      s = '0';
    } else if (s.contains('-')) {
      throw FormatException('Dash only allowed as entire string, got: $input');
    }

    // Step 5: Normalize suffix casing
    s = s.toUpperCase();

    // Step 6: Normalize suffix order (FS → SF, BFS → SBF, TFS → STF)
    s = s.replaceAll('FS', 'SF');
    s = s.replaceAll('BFS', 'SBF');
    s = s.replaceAll('TFS', 'STF');

    // Step 7: Expand trailing separators
    s = _expandTrailingSeparators(s);

    // Step 8: Normalize numeric segments (remove leading zeros)
    s = _normalizeNumericSegments(s);

    // Step 9: Validate
    if (!canonicalRegex.hasMatch(s)) {
      throw FormatException('Migration failed, result invalid: $s (from: $input)');
    }

    return s;
  }

  /// Format canonical notation for display (FF14_Annotated)
  /// 
  /// Implements Spec §9 Rendering Rule:
  /// - If previous segment == 15 → rack delimiter ('|')
  /// - Else → phase delimiter ('·')
  static String formatForDisplay(String canonical) {
    if (canonical.isEmpty) return '';

    try {
      // Parse first to get segments safely
      final record = parse(canonical);
      
      // If only one segment, just return notation (normalized)
      // Actually, we need to strip suffixes, format segments, re-add suffixes
      // But we can reconstruct from segments
      
      if (record.segments.isEmpty) return canonical;

      final buffer = StringBuffer();
      
      for (int i = 0; i < record.segments.length; i++) {
        final segment = record.segments[i];
        buffer.write(segment);

        // Add separator if not the last segment
        if (i < record.segments.length - 1) {
          // Rule: If THIS segment is 15, use Rack Separator
          if (segment == 15) {
            buffer.write('|');
          } else {
            buffer.write('·');
          }
        }
      }

      // Add Suffixes
      // We can extract suffixes from the original string or record properties
      // Record properties are safer (foul/safe enum)
      if (record.safe) buffer.write('S');
      
      switch (record.foul) {
        case FoulType.breakFoul:
          buffer.write('BF');
          break;
        case FoulType.threeFouls:
          buffer.write('TF');
          break; // Per spec: "TF is shown as only TF (-16)" - no need for extra logic here, Codec handles it
        case FoulType.normal:
          buffer.write('F');
          break;
        case FoulType.none:
          break;
      }

      return buffer.toString();

    } catch (e) {
      // Fallback: return as-is (e.g. if invalid)
      return canonical;
    }
  }

  // === Private Helpers ===

  /// Parse a validated canonical notation string
  static InningRecord _parseValidated(String notation) {
    String body = notation;
    bool safe = false;
    FoulType foul = FoulType.none;

    // Peel foul suffix (longest first)
    if (body.endsWith('BF')) {
      foul = FoulType.breakFoul;
      body = body.substring(0, body.length - 2);
    } else if (body.endsWith('TF')) {
      foul = FoulType.threeFouls;
      body = body.substring(0, body.length - 2);
    } else if (body.endsWith('F')) {
      foul = FoulType.normal;
      body = body.substring(0, body.length - 1);
    }

    // Peel safe suffix
    if (body.endsWith('S')) {
      safe = true;
      body = body.substring(0, body.length - 1);
    }

    // Parse segments
    final parts = body.split(separator);
    final segments = parts.map((p) => int.parse(p)).toList();

    return InningRecord(
      inning: 0, // Will be set by caller
      playerName: '', // Will be set by caller
      notation: notation,
      runningTotal: 0, // Will be set by caller
      segments: segments,
      safe: safe,
      foul: foul,
    );
  }

  /// Expand trailing separators to explicit 0 segments
  static String _expandTrailingSeparators(String s) {
    // Split by suffixes to avoid expanding inside suffixes
    final suffixMatch = RegExp(r'(S)?(?:BF|TF|F)?$').firstMatch(s);
    if (suffixMatch == null) return s;

    final suffixPart = suffixMatch.group(0) ?? '';
    final bodyPart = s.substring(0, s.length - suffixPart.length);

    if (bodyPart.isEmpty) return s;

    String expanded = bodyPart;
    while (expanded.endsWith(separator)) {
      expanded = '${expanded.substring(0, expanded.length - 1)}${separator}0';
    }

    return expanded + suffixPart;
  }

  /// Normalize numeric segments (remove leading zeros)
  static String _normalizeNumericSegments(String s) {
    // Extract body and suffix separately
    final suffixMatch = RegExp(r'(S)?(?:BF|TF|F)?$').firstMatch(s);
    if (suffixMatch == null) return s;

    final suffixPart = suffixMatch.group(0) ?? '';
    final bodyPart = s.substring(0, s.length - suffixPart.length);

    // Normalize each segment
    final parts = bodyPart.split(separator);
    final normalized = parts.map((p) {
      if (p.isEmpty) {
        throw FormatException('Empty segment found in: $s');
      }
      if (!RegExp(r'^\d+$').hasMatch(p)) {
        throw FormatException('Non-numeric segment: $p in: $s');
      }

      // Parse and reformat to remove leading zeros
      final num = int.parse(p);
      return num.toString();
    }).toList();

    return normalized.join(separator) + suffixPart;
  }
}

/// Foul type enumeration
enum FoulType {
  none,
  normal, // F
  breakFoul, // BF
  threeFouls, // TF
}

/// Extended InningRecord with structured notation data
class InningRecord {
  final int inning;
  final String playerName;
  final String notation;
  final int runningTotal;

  // Structured notation data (derived or stored)
  final List<int> segments;
  final bool safe;
  final FoulType foul;

  InningRecord({
    required this.inning,
    required this.playerName,
    required this.notation,
    required this.runningTotal,
    this.segments = const [],
    this.safe = false,
    this.foul = FoulType.none,
  });

  Map<String, dynamic> toJson() => {
        'inning': inning,
        'playerName': playerName,
        'notation': notation,
        'runningTotal': runningTotal,
      };

  factory InningRecord.fromJson(Map<String, dynamic> json) {
    final notation = json['notation'] as String;
    final parsed = NotationCodec.parse(notation);

    return InningRecord(
      inning: json['inning'] as int,
      playerName: json['playerName'] as String,
      notation: notation,
      runningTotal: json['runningTotal'] as int,
      segments: parsed.segments,
      safe: parsed.safe,
      foul: parsed.foul,
    );
  }
}
