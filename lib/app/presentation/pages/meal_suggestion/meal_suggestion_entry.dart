import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';

// The per-row edit state of a suggested item - the amount as typed, plus whether
// it is going into the day at all. The MealScanEntry shape, and for the same
// reason: the numbers are an estimate, so reviewing them is the point.
class MealSuggestionEntry extends Equatable {
  const MealSuggestionEntry({required this.item, required this.gramsText, this.isIncluded = true});

  final SuggestedMealItem item;
  final String gramsText;
  final bool isIncluded;

  double? get quantityGrams {
    final parsed = double.tryParse(gramsText.replaceAll(',', '.'));
    return parsed == null || parsed <= 0 ? null : parsed;
  }

  bool get isValid => quantityGrams != null;

  double get calories => item.food.caloriesPer100g * (quantityGrams ?? 0) / 100;

  MealSuggestionEntry copyWith({String? gramsText, bool? isIncluded}) =>
      MealSuggestionEntry(item: item, gramsText: gramsText ?? this.gramsText, isIncluded: isIncluded ?? this.isIncluded);

  @override
  List<Object?> get props => [item, gramsText, isIncluded];
}
