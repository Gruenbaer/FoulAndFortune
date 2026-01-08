// lib/codecs/ff14_annotated_codec.dart
//
// FF14_Annotated codec (display/input dialect).
//
// - Accepts delimiters: ⟲ (U+27F2), |, · (U+00B7), • (U+2022)
// - Suffixes: S then (BF|TF|F)
// - Canonicalization maps all delimiters to ⟲ and validates via NotationCodec.parseCanonical.
// - Intended usage:
//    - User input: FF14AnnotatedCodec.toCanonical(userInput) -> store canonical string
//    - Display: FF14AnnotatedCodec.serialize(NotationCodec.parseCanonical(canon), delimiter: userPref)
//
// NOTE: This codec produces/consumes the structured fields (segments/safe/foul) on InningRecord.
// Other InningRecord fields (inning/playerName/notation/runningTotal) are left default unless provided.

import 'notation_codec.dart' show InningRecord, FoulType, NotationCodec;
import 'notation_format.dart' show DelimiterStyle;

class FF14AnnotatedCodec {
  static const String canonicalDelim = '⟲'; // U+27F2
  static const String barDelim = '|';
  static const String slashDelim = '/';
  static const String dotDelim = '·'; // U+00B7
  static const String legacyBullet = '•'; // U+2022

  /// Regex for accepting FF14_Annotated input (delimiters ⟲ | / · •).
  static final RegExp annotatedRegex =
      RegExp(r'^(?:0|[1-9]\d*)(?:[⟲|/·•](?:0|[1-9]\d*))*S?(?:BF|TF|F)?$');

  /// Parse FF14_Annotated string into an InningRecord that has:
  /// - segments
  /// - safe
  /// - foul
  ///
  /// The other fields are set to neutral defaults; caller may replace as needed.
  static InningRecord parse(String input) {
    final normalized = _normalizeForParsing(input);

    if (normalized.isEmpty) {
      throw FormatException('FF14_Annotated: empty string');
    }

    final suffix = _parseSuffixes(normalized);
    final core = suffix.core;
    final safe = suffix.safe;
    final foul = suffix.foul;

    final segments = _parseSegments(core);

    if (segments.isEmpty) {
      throw FormatException('FF14_Annotated: no segments');
    }

    // TF must be pure foul inning (no points made)
    if (foul == FoulType.threeFouls && _sum(segments) != 0) {
      throw FormatException(
        'FF14_Annotated: TF allowed only when made == 0 (pure foul inning)',
      );
    }

    return InningRecord(
      inning: 0,
      playerName: '',
      notation: '',
      runningTotal: 0,
      segments: segments,
      safe: safe,
      foul: foul,
    );
  }

  /// Serialize an InningRecord to FF14_Annotated with the selected delimiter style.
  ///
  /// Uses record.segments, record.safe, record.foul.
  /// If segments are empty, falls back to parsing record.notation (canonical expected).
  static String serialize(
    InningRecord record, {
    required DelimiterStyle delimiter,
  }) {
    // Prefer structured data; fallback to parsing the record.notation.
    List<int> segments = record.segments;
    bool safe = record.safe;
    FoulType foul = record.foul;

    if (segments.isEmpty) {
      if (record.notation.trim().isEmpty) {
        throw ArgumentError(
          'FF14_Annotated.serialize: record has no segments and empty notation.',
        );
      }
      final parsed = NotationCodec.parseCanonical(record.notation);
      segments = parsed.segments;
      safe = parsed.safe;
      foul = parsed.foul;
      if (segments.isEmpty) {
        throw StateError(
          'FF14_Annotated.serialize: canonical parse produced empty segments.',
        );
      }
    }

    final delim = delimiter.symbol;

    // Validate segment formatting rules.
    for (final n in segments) {
      if (n < 0) {
        throw ArgumentError('FF14_Annotated: segment values must be >= 0');
      }
    }

    final segText = segments.map((e) => e.toString()).join(delim);

    final buf = StringBuffer(segText);
    if (safe) buf.write('S');
    final foulText = _foulToSuffix(foul);
    if (foulText.isNotEmpty) buf.write(foulText);

    final out = buf.toString().toUpperCase();

    // Quick syntactic validation (accepts only ⟲|·• in the regex; if user chose '|',
    // replace it for validation purposes).
    final validateView = out.replaceAll('|', '·');
    if (!annotatedRegex.hasMatch(validateView)) {
      throw StateError('FF14_Annotated.serialize produced invalid output: $out');
    }

    // TF semantic constraint
    if (foul == FoulType.threeFouls && _sum(segments) != 0) {
      throw StateError('FF14_Annotated.serialize: TF requires made == 0');
    }

    return out;
  }

  /// Convert FF14_Annotated (or canonical) input into FF14_Canonical string.
  ///
  /// This is the function you should run on any user-entered notation prior to storing it.
  static String toCanonical(String input) {
    var s = input.trim();
    if (s.isEmpty) throw FormatException('FF14_Annotated: empty string');

    // Legacy miss shorthand
    if (s == '-') s = '0';

    // Uppercase
    s = s.toUpperCase();

    // Normalize/repair suffix order at end (FS->SF, BFS->SBF, TFS->STF)
    s = _fixSuffixOrder(s);

    // Expand trailing delimiters and consecutive delimiters by inserting zeros
    s = _expandDelimitersWithZeros(s);

    // Map delimiters to canonical ⟲
    s = s
        .replaceAll(legacyBullet, canonicalDelim)
        .replaceAll(dotDelim, canonicalDelim)
        .replaceAll(barDelim, canonicalDelim)
        .replaceAll(slashDelim, canonicalDelim);

    // Validate and obtain structured record via canonical parser.
    // This guarantees the result obeys your canonical regex and any extra internal rules.
    final record = NotationCodec.parseCanonical(s);

    // Enforce TF semantic constraint at the annotated layer too.
    if (record.foul == FoulType.threeFouls && _sum(record.segments) != 0) {
      throw FormatException('FF14_Annotated: TF requires made == 0');
    }

    // Re-serialize using your canonical codec (source of truth).
    return NotationCodec.serialize(record);
  }

  // -------------------------
  // Internals
  // -------------------------

  static String _normalizeForParsing(String input) {
    var s = input.trim();
    if (s == '-') return '0';

    s = s.toUpperCase();

    // Normalize legacy bullet to middle dot for easier splitting;
    // (it remains an accepted delimiter regardless)
    s = s.replaceAll(legacyBullet, dotDelim);

    // Fix common suffix order issues
    s = _fixSuffixOrder(s);

    // Remove internal whitespace
    s = s.replaceAll(RegExp(r'\s+'), '');

    // Expand trailing delimiters and consecutive delimiters
    s = _expandDelimitersWithZeros(s);

    return s;
  }

  static _SuffixParseResult _parseSuffixes(String s) {
    bool safe = false;
    FoulType foul = FoulType.none;

    // Foul marker from end (BF|TF|F)
    if (s.endsWith('BF')) {
      foul = FoulType.breakFoul;
      s = s.substring(0, s.length - 2);
    } else if (s.endsWith('TF')) {
      foul = FoulType.threeFouls;
      s = s.substring(0, s.length - 2);
    } else if (s.endsWith('F')) {
      foul = FoulType.normal;
      s = s.substring(0, s.length - 1);
    }

    // Safe marker
    if (s.endsWith('S')) {
      safe = true;
      s = s.substring(0, s.length - 1);
    }

    if (s.isEmpty) {
      throw FormatException('FF14_Annotated: missing segments before suffixes');
    }

    return _SuffixParseResult(core: s, safe: safe, foul: foul);
  }

  static List<int> _parseSegments(String core) {
    // Split on any delimiter: ⟲ | / · • (bullet already normalized to dot but keep it)
    final parts = core.split(RegExp(r'[⟲|/·•]'));
    if (parts.any((p) => p.isEmpty)) {
      throw FormatException('FF14_Annotated: empty segment (consecutive delimiters?)');
    }

    final segments = <int>[];
    for (final p in parts) {
      if (!RegExp(r'^\d+$').hasMatch(p)) {
        throw FormatException('FF14_Annotated: invalid segment token "$p"');
      }
      if (p.length > 1 && p.startsWith('0')) {
        throw FormatException('FF14_Annotated: leading zeros not allowed: "$p"');
      }
      segments.add(int.parse(p));
    }
    return segments;
  }

  static String _foulToSuffix(FoulType foul) {
    switch (foul) {
      case FoulType.none:
        return '';
      case FoulType.normal:
        return 'F';
      case FoulType.breakFoul:
        return 'BF';
      case FoulType.threeFouls:
        return 'TF';
    }
  }

  static String _fixSuffixOrder(String s) {
    // Only fix common "wrong order at end" patterns.
    // Must process longer patterns first to avoid partial matches
    if (s.endsWith('TFS')) {
      return '${s.substring(0, s.length - 3)}STF';
    } else if (s.endsWith('BFS')) {
      return '${s.substring(0, s.length - 3)}SBF';
    } else if (s.endsWith('FS')) {
      return '${s.substring(0, s.length - 2)}SF';
    }
    return s;
  }

  static bool _isDelimiterChar(String c) =>
      c == canonicalDelim || c == barDelim || c == slashDelim || c == dotDelim || c == legacyBullet;

  static String _expandDelimitersWithZeros(String s) {
    if (s.isEmpty) return s;

    // If ends with one or more delimiters, append a 0 for each missing segment.
    while (s.isNotEmpty && _isDelimiterChar(s[s.length - 1])) {
      s = '${s}0';
    }

    // Replace runs of delimiters by inserting zeros between them.
    // Example: "14||" -> "14|0|0"
    // Example: "14⟲⟲" -> "14⟲0⟲0"
    s = s.replaceAllMapped(RegExp(r'([⟲|/·•])([⟲|/·•])+'), (m) {
      final run = m.group(0)!; // e.g. "|||" or "⟲⟲"
      final chars = run.split('');
      final buf = StringBuffer();
      for (int i = 0; i < chars.length; i++) {
        buf.write(chars[i]);
        if (i != chars.length - 1) buf.write('0');
      }
      return buf.toString();
    });

    return s;
  }

  static void _assertNoLeadingZeros(String s, {required String delimiter}) {
    // Separate suffixes first
    final suf = _parseSuffixes(s);
    final core = suf.core;

    final parts = core.split(delimiter);
    for (final p in parts) {
      if (p.length > 1 && p.startsWith('0')) {
        throw FormatException('Leading zeros not allowed: "$p"');
      }
    }
  }

  static int _sum(List<int> xs) => xs.fold<int>(0, (a, b) => a + b);
}

class _SuffixParseResult {
  final String core;
  final bool safe;
  final FoulType foul;

  _SuffixParseResult({required this.core, required this.safe, required this.foul});
}
