import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_preparation.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';

class CustomFoodState extends Equatable {
  const CustomFoodState({
    this.name = '',
    this.brand = '',
    this.nutrients = const {},
    this.imageBytes,
    this.imageExtension = '',
    this.gramsPerUnitText = '',
    this.gramsPer100MlText = '',
    this.preparation,
  });

  /// Mirrors the `density_g_per_ml <= 2` check in supabase/schema.sql: nothing in
  /// a food diary is denser than honey, so a bigger number is a typo, and
  /// dropping it here is what keeps the insert from being rejected outright.
  static const double _maxDensityGPerMl = 2;

  final String name;
  final String brand;
  final Map<CustomFoodNutrient, double> nutrients;
  final Uint8List? imageBytes;
  final String imageExtension;

  final String gramsPerUnitText;

  /// What 100 mL of this food weighs, which is the question a person can answer
  /// off a bottle - a density in g/mL is not. It is a plain String for the same
  /// reason [gramsPerUnitText] is: emptying the field has to be expressible, and
  /// copyWith cannot tell a null meaning "cleared" from one meaning "unchanged".
  final String gramsPer100MlText;

  final FoodPreparation? preparation;

  double? get gramsPerUnit => _positiveNumber(gramsPerUnitText);

  double? get densityGPerMl {
    final gramsPer100Ml = _positiveNumber(gramsPer100MlText);
    if (gramsPer100Ml == null) {
      return null;
    }
    final density = gramsPer100Ml / 100;
    return density > _maxDensityGPerMl ? null : density;
  }

  double? _positiveNumber(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    return parsed == null || parsed <= 0 ? null : parsed;
  }

  bool get isComplete => name.trim().isNotEmpty && CustomFoodNutrient.values.every(nutrients.containsKey);

  bool get hasNutrients => nutrients.values.any((value) => value > 0);

  CustomFoodState copyWith({
    String? name,
    String? brand,
    Map<CustomFoodNutrient, double>? nutrients,
    Uint8List? imageBytes,
    String? imageExtension,
    String? gramsPerUnitText,
    String? gramsPer100MlText,
  }) => CustomFoodState(
    name: name ?? this.name,
    brand: brand ?? this.brand,
    nutrients: nutrients ?? this.nutrients,
    imageBytes: imageBytes ?? this.imageBytes,
    imageExtension: imageExtension ?? this.imageExtension,
    gramsPerUnitText: gramsPerUnitText ?? this.gramsPerUnitText,
    gramsPer100MlText: gramsPer100MlText ?? this.gramsPer100MlText,
    preparation: preparation,
  );

  /// Its own method rather than a copyWith argument, because "not stated" is a
  /// real choice here - re-tapping the selected chip clears it - and copyWith
  /// reads a null as "leave it alone".
  CustomFoodState withPreparation(FoodPreparation? preparation) => CustomFoodState(
    name: name,
    brand: brand,
    nutrients: nutrients,
    imageBytes: imageBytes,
    imageExtension: imageExtension,
    gramsPerUnitText: gramsPerUnitText,
    gramsPer100MlText: gramsPer100MlText,
    preparation: preparation,
  );

  @override
  List<Object?> get props => [name, brand, nutrients, imageBytes, imageExtension, gramsPerUnitText, gramsPer100MlText, preparation];
}
