import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/general/food_reference_amount.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../factories/entities/food_factory.dart';

Future<AppLocalizations> englishL10n() => AppLocalizations.delegate.load(const Locale('en'));

void main() {
  test('a food you weigh states its numbers per 100 g, untouched', () async {
    final l10n = await englishL10n();
    final rice = FoodFactory.build(caloriesPer100g: 130);

    expect(rice.caloriesPerReference(l10n), '130 kcal / 100g');
    expect(rice.per100Reference(28), 28);
    expect(rice.nutritionReferenceTitle(l10n), 'Nutrition per 100g');
  });

  // The stored numbers are per 100 g, so a liquid's have to be *scaled* to
  // 100 mL. Printing milk's 61 kcal over "per 100 mL" would be wrong by its
  // density, which is exactly what the column exists to know.
  test('a food you pour states its numbers per 100 mL, scaled by its density', () async {
    final l10n = await englishL10n();
    final milk = FoodFactory.build(caloriesPer100g: 61, densityGPerMl: 1.03);

    expect(milk.caloriesPerReference(l10n), '63 kcal / 100mL');
    expect(milk.per100Reference(3.2), closeTo(3.296, 0.0001));
    expect(milk.nutritionReferenceTitle(l10n), 'Nutrition per 100mL');
  });

  test('scaling is a real conversion, so a lighter liquid reads lower not higher', () {
    final oil = FoodFactory.build(caloriesPer100g: 884, densityGPerMl: 0.92);

    expect(oil.per100Reference(oil.caloriesPer100g), closeTo(813.28, 0.01));
  });
}
