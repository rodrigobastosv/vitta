import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';

class CustomFoodState extends Equatable {
  const CustomFoodState({this.name = '', this.brand = '', this.nutrients = const {}, this.imageBytes, this.imageExtension = ''});

  final String name;
  final String brand;
  final Map<CustomFoodNutrient, double> nutrients;
  final Uint8List? imageBytes;
  final String imageExtension;

  bool get isComplete => name.trim().isNotEmpty && CustomFoodNutrient.values.every(nutrients.containsKey);

  bool get hasNutrients => nutrients.values.any((value) => value > 0);

  CustomFoodState copyWith({
    String? name,
    String? brand,
    Map<CustomFoodNutrient, double>? nutrients,
    Uint8List? imageBytes,
    String? imageExtension,
  }) => CustomFoodState(
    name: name ?? this.name,
    brand: brand ?? this.brand,
    nutrients: nutrients ?? this.nutrients,
    imageBytes: imageBytes ?? this.imageBytes,
    imageExtension: imageExtension ?? this.imageExtension,
  );

  @override
  List<Object?> get props => [name, brand, nutrients, imageBytes, imageExtension];
}
