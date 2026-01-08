// lib/codecs/notation_format.dart
//
// Notation settings for display formatting.
// Storage is always FF14_Canonical; display may render FF14_Annotated.
//
// Mixed delimiters rule (FF14_Annotated):
// - Between segments: if previous segment == 15 -> rack delimiter (| or /)
// - else -> phase delimiter (·)

enum NotationFormat {
  ff14Canonical('FF14_Canonical', 'Canonical (Storage)'),
  ff14Annotated('FF14_Annotated', 'Annotated (Display)');

  final String id;
  final String displayName;
  const NotationFormat(this.id, this.displayName);

  static NotationFormat fromId(String? id) {
    return NotationFormat.values.firstWhere(
      (e) => e.id == id,
      orElse: () => NotationFormat.ff14Canonical,
    );
  }
}

enum RackDelimiterStyle {
  bar('|', 'Bar (Rack)'),
  slash('/', 'Slash (Rack)');

  final String symbol;
  final String displayName;
  const RackDelimiterStyle(this.symbol, this.displayName);

  static RackDelimiterStyle fromName(String? name) {
    return RackDelimiterStyle.values.firstWhere(
      (e) => e.name == name,
      orElse: () => RackDelimiterStyle.bar,
    );
  }
}

enum PhaseDelimiterStyle {
  dot('·', 'Dot (Phase)');

  final String symbol;
  final String displayName;
  const PhaseDelimiterStyle(this.symbol, this.displayName);

  static PhaseDelimiterStyle fromName(String? name) {
    return PhaseDelimiterStyle.values.firstWhere(
      (e) => e.name == name,
      orElse: () => PhaseDelimiterStyle.dot,
    );
  }
}
