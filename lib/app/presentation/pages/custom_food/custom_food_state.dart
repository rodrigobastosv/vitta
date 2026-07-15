import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';

class CustomFoodState extends Equatable {
  const CustomFoodState({
    this.name = '',
    this.brand = '',
    this.nutrients = const {},
    this.imageBytes,
    this.imageExtension = '',
    this.gramsPerUnitText = '',
  });

  final String name;
  final String brand;
  final Map<CustomFoodNutrient, double> nutrients;
  final Uint8List? imageBytes;
  final String imageExtension;

  /// Held as raw text like [name] and [brand], rather than as a parsed
  /// `double?`: emptying the field has to be expressible, and `copyWith` can
  /// never distinguish a null meaning "cleared" from one meaning "unchanged".
  /// It is the same problem [nutrients] uses a map to sidestep.
  final String gramsPerUnitText;

  /// Null whenever the field is empty or holds something that isn't a usable
  /// weight, which is exactly the food not being countable. Anything <= 0 is
  /// filtered here rather than at the database's check constraint.
  double? get gramsPerUnit {
    final parsed = double.tryParse(gramsPerUnitText.replaceAll(',', '.'));
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
  }) => CustomFoodState(
    name: name ?? this.name,
    brand: brand ?? this.brand,
    nutrients: nutrients ?? this.nutrients,
    imageBytes: imageBytes ?? this.imageBytes,
    imageExtension: imageExtension ?? this.imageExtension,
    gramsPerUnitText: gramsPerUnitText ?? this.gramsPerUnitText,
  );

  @override
  List<Object?> get props => [name, brand, nutrients, imageBytes, imageExtension, gramsPerUnitText];
}
