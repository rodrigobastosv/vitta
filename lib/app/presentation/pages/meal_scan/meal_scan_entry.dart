import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

class MealScanEntry extends Equatable {
  const MealScanEntry({required this.item, required this.gramsText, this.isIncluded = true});

  final ScannedMealItem item;
  final String gramsText;
  final bool isIncluded;

  double? get quantityGrams {
    final parsed = double.tryParse(gramsText.replaceAll(',', '.'));
    return parsed == null || parsed <= 0 ? null : parsed;
  }

  bool get isValid => quantityGrams != null;

  double get calories => item.caloriesPer100g * (quantityGrams ?? 0) / 100;

  MealScanEntry copyWith({String? gramsText, bool? isIncluded}) =>
      MealScanEntry(item: item, gramsText: gramsText ?? this.gramsText, isIncluded: isIncluded ?? this.isIncluded);

  @override
  List<Object?> get props => [item, gramsText, isIncluded];
}
