// test/ff14_annotated_codec_test.dart
//
// Golden tests for FF14_AnnotatedCodec using your existing NotationCodec API.

import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/codecs/ff14_annotated_codec.dart';
import 'package:foulandfortune/codecs/notation_codec.dart' show FoulType;
import 'package:foulandfortune/codecs/notation_format.dart' show DelimiterStyle;

void main() {
  group('FF14_AnnotatedCodec.toCanonical', () {
    test('basic unchanged', () {
      expect(FF14AnnotatedCodec.toCanonical('14'), '14');
      expect(FF14AnnotatedCodec.toCanonical('0'), '0');
      expect(FF14AnnotatedCodec.toCanonical('5F'), '5F');
      expect(FF14AnnotatedCodec.toCanonical('14S'), '14S');
      expect(FF14AnnotatedCodec.toCanonical('0TF'), '0TF');
      expect(FF14AnnotatedCodec.toCanonical('0BF'), '0BF');
    });

    test('delimiter mapping | and · and • -> ⟲', () {
      expect(FF14AnnotatedCodec.toCanonical('15|14'), '15⟲14');
      expect(FF14AnnotatedCodec.toCanonical('15·14·13'), '15⟲14⟲13');
      expect(FF14AnnotatedCodec.toCanonical('15•14•5F'), '15⟲14⟲5F');
      expect(FF14AnnotatedCodec.toCanonical('15|14·5SF'), '15⟲14⟲5SF');
    });

    test('suffix order correction', () {
      expect(FF14AnnotatedCodec.toCanonical('5FS'), '5SF');
      expect(FF14AnnotatedCodec.toCanonical('0BFS'), '0SBF');
      expect(FF14AnnotatedCodec.toCanonical('0TFS'), '0STF');
    });

    test('trailing delimiters expand to zeros', () {
      expect(FF14AnnotatedCodec.toCanonical('14⟲⟲'), '14⟲0⟲0');
      expect(FF14AnnotatedCodec.toCanonical('14||'), '14⟲0⟲0');
      expect(FF14AnnotatedCodec.toCanonical('14··'), '14⟲0⟲0');
    });

    test('legacy miss dash', () {
      expect(FF14AnnotatedCodec.toCanonical('-'), '0');
    });

    test('TF only allowed when made == 0', () {
      expect(() => FF14AnnotatedCodec.toCanonical('1TF'), throwsFormatException);
      expect(() => FF14AnnotatedCodec.toCanonical('1|0TF'), throwsFormatException);
      expect(FF14AnnotatedCodec.toCanonical('0TF'), '0TF');
      expect(FF14AnnotatedCodec.toCanonical('0|0TF'), '0⟲0TF');
    });

    test('leading zeros rejected (except 0)', () {
      expect(() => FF14AnnotatedCodec.toCanonical('05'), throwsFormatException);
      expect(() => FF14AnnotatedCodec.toCanonical('15|04'), throwsFormatException);
    });

    test('empty / malformed rejected', () {
      expect(() => FF14AnnotatedCodec.toCanonical(''), throwsFormatException);
      expect(() => FF14AnnotatedCodec.toCanonical('F14'), throwsFormatException);
      expect(() => FF14AnnotatedCodec.toCanonical('14FF'), throwsFormatException);
    });
  });

  group('FF14_AnnotatedCodec.parse + serialize', () {
    test('round-trip with delimiter rendering', () {
      final rec = FF14AnnotatedCodec.parse('15|14·5SF');
      expect(rec.segments, [15, 14, 5]);
      expect(rec.safe, true);
      expect(rec.foul, FoulType.normal);

      expect(
        FF14AnnotatedCodec.serialize(rec, delimiter: DelimiterStyle.canonical),
        '15⟲14⟲5SF',
      );
      expect(
        FF14AnnotatedCodec.serialize(rec, delimiter: DelimiterStyle.bar),
        '15|14|5SF',
      );
      expect(
        FF14AnnotatedCodec.serialize(rec, delimiter: DelimiterStyle.dot),
        '15·14·5SF',
      );
    });

    test('parses canonical input as well', () {
      final rec = FF14AnnotatedCodec.parse('15⟲14⟲5F');
      expect(rec.segments, [15, 14, 5]);
      expect(rec.safe, false);
      expect(rec.foul, FoulType.normal);
    });

    test('rejects TF with points made', () {
      expect(() => FF14AnnotatedCodec.parse('5TF'), throwsFormatException);
      expect(() => FF14AnnotatedCodec.parse('1|0TF'), throwsFormatException);
    });

    test('accepts TF with zero points', () {
      final rec = FF14AnnotatedCodec.parse('0TF');
      expect(rec.segments, [0]);
      expect(rec.foul, FoulType.threeFouls);
    });
  });
}
