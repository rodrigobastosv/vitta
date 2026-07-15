import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/text/accent_folding.dart';

void main() {
  group('AccentFolding.fold', () {
    test('lowercases and strips accents so an unaccented query matches an accented name', () {
      expect(AccentFolding.fold('Tríceps Testa'), 'triceps testa');
    });

    test('leaves an already-folded query alone', () {
      expect(AccentFolding.fold('triceps'), 'triceps');
    });

    test('folds every Portuguese accent the catalog uses', () {
      expect(AccentFolding.fold('Cãibra Óssea Único Pêso Açaí'), 'caibra ossea unico peso acai');
    });
  });
}
