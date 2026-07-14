import 'dart:math';

import 'package:vitta/app/core/services/text_recognition/ocr_text_line.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';

abstract class NutritionLabelParser {
  static ScannedNutritionFacts parse(List<OcrTextLine> lines) {
    final rows = _rows(lines);
    final scale = _per100gScale(rows);

    return ScannedNutritionFacts(
      caloriesPer100g: _scaled(_calories(rows), scale),
      proteinPer100g: _scaled(_value(rows, include: const ['proteina', 'protein']), scale),
      carbsPer100g: _scaled(_value(rows, include: const ['carboidrato', 'carbohydrate', 'carbs']), scale),
      fatPer100g: _scaled(
        _value(rows, include: const ['gorduras totais', 'total fat', 'gordura', 'fat', 'lipidio'], exclude: const ['satur', 'trans', 'insatur']),
        scale,
      ),
      fiberPer100g: _scaled(_value(rows, include: const ['fibra', 'fiber']), scale),
    );
  }

  /// Values on a label are usually stated per serving. When the serving isn't
  /// 100 g and the label offers no explicit per-100 g column, scale the read
  /// values up to the app's per-100 g basis.
  static double _per100gScale(List<String> rows) {
    final portionGrams = _portionGrams(rows);
    if (portionGrams == null || portionGrams == 100 || _hasPer100gBasis(rows)) {
      return 1;
    }
    return 100 / portionGrams;
  }

  static double? _scaled(double? value, double scale) => value == null ? null : (value * scale * 10).roundToDouble() / 10;

  static double? _portionGrams(List<String> rows) {
    for (final row in rows) {
      if (!row.contains('porcao') && !row.contains('serving')) {
        continue;
      }
      final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*g\b').firstMatch(row);
      if (match != null) {
        return _toDouble(match.group(1)!);
      }
    }
    return null;
  }

  static bool _hasPer100gBasis(List<String> rows) => rows.any((row) => RegExp(r'100\s*g\b').hasMatch(row));

  /// Groups lines that share the same visual row and joins each row's text
  /// left-to-right, so a label and its value read as one string even when OCR
  /// returns them as separate columns. A line joins a row when its vertical
  /// center is within half a line height of the row's first (anchor) line — an
  /// anchor that never moves, so nearly-touching rows can't cascade into one.
  static List<String> _rows(List<OcrTextLine> lines) {
    final sorted = [...lines]..sort((a, b) => _centerY(a).compareTo(_centerY(b)));
    final groups = <List<OcrTextLine>>[];
    for (final line in sorted) {
      final anchor = groups.isEmpty ? null : groups.last.first;
      final tolerance = anchor == null ? 0.0 : max(line.bottom - line.top, anchor.bottom - anchor.top) * 0.5;
      if (anchor != null && (_centerY(line) - _centerY(anchor)).abs() <= tolerance) {
        groups.last.add(line);
      } else {
        groups.add([line]);
      }
    }
    return [
      for (final group in groups)
        _stripAccents((group..sort((a, b) => a.left.compareTo(b.left))).map((line) => line.text).join(' ').toLowerCase()),
    ];
  }

  static double _centerY(OcrTextLine line) => (line.top + line.bottom) / 2;

  /// The `%VD` footnote ("...com base em uma dieta de 2000 kcal...") carries
  /// numbers that belong to no nutrient — skip it so its 2000 kcal can't be read
  /// as a value.
  static bool _isFootnote(String row) => row.contains('valores diarios') || row.contains('dieta de');

  static double? _calories(List<String> rows) {
    for (final row in rows) {
      if (_isFootnote(row)) {
        continue;
      }
      final kcalMatch = RegExp(r'(\d+(?:[.,]\d+)?)\s*kcal').firstMatch(row);
      if (kcalMatch != null) {
        return _toDouble(kcalMatch.group(1)!);
      }
    }
    return _value(rows, include: const ['valor energetico', 'energia', 'calorias', 'energy', 'calories']);
  }

  static double? _value(List<String> rows, {required List<String> include, List<String> exclude = const []}) {
    for (final row in rows) {
      if (_isFootnote(row) || !include.any(row.contains) || exclude.any(row.contains)) {
        continue;
      }
      final number = _numberIn(row);
      if (number != null) {
        return number;
      }
    }
    return null;
  }

  static double? _numberIn(String row) {
    final match = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(row);
    return match == null ? null : _toDouble(match.group(0)!);
  }

  static double _toDouble(String value) => double.parse(value.replaceAll(',', '.'));

  static String _stripAccents(String value) {
    const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final index = accented.indexOf(char);
      buffer.write(index == -1 ? char : plain[index]);
    }
    return buffer.toString();
  }
}
