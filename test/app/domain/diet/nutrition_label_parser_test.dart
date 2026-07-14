import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/text_recognition/ocr_text_line.dart';
import 'package:vitta/app/domain/diet/nutrition_label_parser.dart';

OcrTextLine _line(String text, {required double row, double left = 0}) =>
    OcrTextLine(text: text, top: row * 10, bottom: row * 10 + 8, left: left);

void main() {
  test('reassembles a columnar layout where labels and values are separate lines', () {
    final lines = [
      _line('Valor energetico', row: 0),
      _line('129 kcal', row: 0, left: 200),
      _line('Carboidratos', row: 1),
      _line('22 g', row: 1, left: 200),
      _line('Proteinas', row: 2),
      _line('3 g', row: 2, left: 200),
      _line('Gorduras totais', row: 3),
      _line('8 g', row: 3, left: 200),
      _line('Fibra alimentar', row: 4),
      _line('2 g', row: 4, left: 200),
    ];

    final facts = NutritionLabelParser.parse(lines);

    expect(facts.caloriesPer100g, 129);
    expect(facts.carbsPer100g, 22);
    expect(facts.proteinPer100g, 3);
    expect(facts.fatPer100g, 8);
    expect(facts.fiberPer100g, 2);
  });

  test('ignores the %VD footnote so its "2000 kcal" is never read as a value', () {
    final lines = [
      _line('Valor Energético', row: 0),
      _line('171kcal = 718kJ', row: 0, left: 200),
      _line('9', row: 0, left: 400),
      _line('Carboidratos', row: 1),
      _line('39g', row: 1, left: 200),
      _line('13', row: 1, left: 400),
      _line('Proteínas', row: 2),
      _line('3,7g', row: 2, left: 200),
      _line('Gorduras Totais', row: 3),
      _line('0g', row: 3, left: 200),
      _line('Gorduras Saturadas', row: 4),
      _line('0g', row: 4, left: 200),
      _line('Fibra Alimentar', row: 5),
      _line('0,8g', row: 5, left: 200),
      _line('* % Valores Diários com base em uma dieta de 2000 kcal ou 8400 kJ.', row: 6),
    ];

    final facts = NutritionLabelParser.parse(lines);

    expect(facts.caloriesPer100g, 171);
    expect(facts.carbsPer100g, 39);
    expect(facts.proteinPer100g, 3.7);
    expect(facts.fatPer100g, 0);
    expect(facts.fiberPer100g, 0.8);
  });

  test('scales per-serving values to per-100g when the serving is not 100g', () {
    final lines = [
      _line('Porção 50g (1/4 de xícara)', row: 0),
      _line('Quantidade por porção %VD(*)', row: 1),
      _line('Valor Energético 171kcal = 718kJ 9', row: 2),
      _line('Carboidratos 39g 13', row: 3),
      _line('Proteínas 3,7g 5', row: 4),
      _line('Gorduras Totais 0g 0', row: 5),
      _line('Fibra Alimentar 0,8g 3', row: 6),
    ];

    final facts = NutritionLabelParser.parse(lines);

    expect(facts.caloriesPer100g, 342);
    expect(facts.carbsPer100g, 78);
    expect(facts.proteinPer100g, 7.4);
    expect(facts.fatPer100g, 0);
    expect(facts.fiberPer100g, 1.6);
  });

  test('does not scale when the label already states a per-100g column', () {
    final lines = [
      _line('Porção de 30 g', row: 0),
      _line('100 g Porção', row: 1),
      _line('Carboidratos 75g 22g', row: 2),
    ];

    expect(NutritionLabelParser.parse(lines).carbsPer100g, 75);
  });

  test('parses a single-line-per-row layout with accents and comma decimals', () {
    final lines = [
      _line('Valor energético 129 kcal (541 kJ)', row: 0),
      _line('Carboidratos 22,5 g', row: 1),
      _line('Proteínas 3,2 g', row: 2),
      _line('Gorduras totais 2,5 g', row: 3),
      _line('Gorduras saturadas 0,5 g', row: 4),
      _line('Fibra alimentar 1,8 g', row: 5),
    ];

    final facts = NutritionLabelParser.parse(lines);

    expect(facts.caloriesPer100g, 129);
    expect(facts.carbsPer100g, 22.5);
    expect(facts.proteinPer100g, 3.2);
    expect(facts.fatPer100g, 2.5);
    expect(facts.fiberPer100g, 1.8);
  });

  test('takes the leftmost (per-100g) value when a row has two columns', () {
    final lines = [
      _line('Carboidratos', row: 0),
      _line('75 g', row: 0, left: 200),
      _line('22 g', row: 0, left: 400),
    ];

    expect(NutritionLabelParser.parse(lines).carbsPer100g, 75);
  });

  test('reads total fat and ignores saturated and trans rows', () {
    final lines = [
      _line('Gorduras totais 8 g', row: 0),
      _line('Gorduras saturadas 3 g', row: 1),
      _line('Gorduras trans 0 g', row: 2),
    ];

    expect(NutritionLabelParser.parse(lines).fatPer100g, 8);
  });

  test('parses an English label', () {
    final lines = [
      _line('Calories 180', row: 0),
      _line('Protein 5 g', row: 1),
      _line('Total Carbohydrate 20 g', row: 2),
      _line('Total Fat 9 g', row: 3),
      _line('Dietary Fiber 4 g', row: 4),
    ];

    final facts = NutritionLabelParser.parse(lines);

    expect(facts.caloriesPer100g, 180);
    expect(facts.proteinPer100g, 5);
    expect(facts.carbsPer100g, 20);
    expect(facts.fatPer100g, 9);
    expect(facts.fiberPer100g, 4);
  });

  test('leaves absent nutrients null', () {
    final facts = NutritionLabelParser.parse([_line('Proteínas 10 g', row: 0)]);

    expect(facts.proteinPer100g, 10);
    expect(facts.caloriesPer100g, isNull);
    expect(facts.carbsPer100g, isNull);
    expect(facts.fatPer100g, isNull);
    expect(facts.fiberPer100g, isNull);
    expect(facts.hasAnyValue, isTrue);
  });

  test('returns an empty result with no readable values', () {
    final facts = NutritionLabelParser.parse([_line('some unrelated text', row: 0)]);

    expect(facts.hasAnyValue, isFalse);
  });
}
