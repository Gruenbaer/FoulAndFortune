import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/codecs/notation_codec.dart';

void main() {
  group('NotationCodec - Canonical Parsing', () {
    test('Valid single segment', () {
      final record = NotationCodec.parseCanonical('5');
      expect(record.segments, [5]);
      expect(record.safe, false);
      expect(record.foul, FoulType.none);
    });

    test('Valid multi-segment', () {
      final record = NotationCodec.parseCanonical('14⟲14⟲2');
      expect(record.segments, [14, 14, 2]);
      expect(record.safe, false);
      expect(record.foul, FoulType.none);
    });

    test('Valid with safe suffix', () {
      final record = NotationCodec.parseCanonical('5S');
      expect(record.segments, [5]);
      expect(record.safe, true);
      expect(record.foul, FoulType.none);
    });

    test('Valid with foul suffix', () {
      final record = NotationCodec.parseCanonical('0F');
      expect(record.segments, [0]);
      expect(record.safe, false);
      expect(record.foul, FoulType.normal);
    });

    test('Valid with safe and foul', () {
      final record = NotationCodec.parseCanonical('14⟲0SF');
      expect(record.segments, [14, 0]);
      expect(record.safe, true);
      expect(record.foul, FoulType.normal);
    });

    test('Valid with break foul', () {
      final record = NotationCodec.parseCanonical('0BF');
      expect(record.segments, [0]);
      expect(record.safe, false);
      expect(record.foul, FoulType.breakFoul);
    });

    test('Valid with triple foul', () {
      final record = NotationCodec.parseCanonical('5TF');
      expect(record.segments, [5]);
      expect(record.safe, false);
      expect(record.foul, FoulType.threeFouls);
    });
  });

  group('NotationCodec - Canonical Serialization', () {
    test('Serialize simple segment', () {
      final record = InningRecord(
        inning: 1,
        playerName: 'P1',
        notation: '',
        runningTotal: 5,
        segments: [5],
        safe: false,
        foul: FoulType.none,
      );
      expect(NotationCodec.serialize(record), '5');
    });

    test('Serialize multi-segment', () {
      final record = InningRecord(
        inning: 1,
        playerName: 'P1',
        notation: '',
        runningTotal: 30,
        segments: [14, 14, 2],
        safe: false,
        foul: FoulType.none,
      );
      expect(NotationCodec.serialize(record), '14⟲14⟲2');
    });

    test('Serialize with suffix', () {
      final record = InningRecord(
        inning: 1,
        playerName: 'P1',
        notation: '',
        runningTotal: 0,
        segments: [0],
        safe: true,
        foul: FoulType.normal,
      );
      expect(NotationCodec.serialize(record), '0SF');
    });
  });

  group('NotationCodec - Round-trip Property', () {
    final testCases = [
      '0',
      '5',
      '14',
      '15',
      '0S',
      '5S',
      '0F',
      '0BF',
      '0TF',
      '0SF',
      '0SBF',
      '0STF',
      '14⟲0',
      '14⟲5',
      '14⟲14⟲2',
      '14⟲0S',
      '14⟲0F',
      '14⟲0SF',
    ];

    for (final notation in testCases) {
      test('Round-trip: $notation', () {
        final parsed = NotationCodec.parseCanonical(notation);
        final serialized = NotationCodec.serialize(parsed);
        expect(serialized, notation);
      });
    }
  });

  group('NotationCodec - Invalid Canonical', () {
    final invalidCases = {
      '': 'Empty string',
      '00': 'Leading zeros',
      '01': 'Leading zeros',
      '14⟲01': 'Leading zeros in segment',
      '14⟲': 'Trailing separator',
      '⟲0': 'Leading separator',
      '0⟲⟲0': 'Empty mid-segment',
      'SF': 'Suffix-only',
      '0FS': 'Wrong suffix order',
      '0SS': 'Duplicate safe',
      '0FF': 'Duplicate foul',
      '14•0': 'Wrong separator',
      '-': 'Dash notation',
    };

    invalidCases.forEach((notation, reason) {
      test('Reject: $notation ($reason)', () {
        expect(
          () => NotationCodec.parseCanonical(notation),
          throwsFormatException,
        );
      });
    });
  });

  group('NotationCodec - Legacy Migration', () {
    final migrationCases = {
      '-': '0',
      '|': '14',
      '|•': '14⟲0',
      '|•5F': '14⟲5F',
      '|•|•2': '14⟲14⟲2',
      '10•': '10⟲0',
      '10•F': '10⟲0F',
      '14·0sf': '14⟲0SF',
      '0fs': '0SF',
      '14⟲01BFS': '14⟲1SBF',
      ' 14 • 14 • 0 ': '14⟲14⟲0',
    };

    migrationCases.forEach((legacy, canonical) {
      test('Migrate: $legacy → $canonical', () {
        final migrated = NotationCodec.canonicalize(legacy);
        expect(migrated, canonical);
      });
    });
  });

  group('NotationCodec - Legacy Rejection', () {
    final rejectCases = {
      '⟲0': 'Leading separator',
      '0⟲⟲0': 'Empty segment',
      '14-0': 'Dash in segment',
      '0SBF⟲0': 'Suffix not at end',
      '0XX': 'Unknown suffix',
    };

    rejectCases.forEach((notation, reason) {
      test('Reject migration: $notation ($reason)', () {
        expect(
          () => NotationCodec.canonicalize(notation),
          throwsFormatException,
        );
      });
    });
  });
}
