import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';

class MealSuggestions extends Equatable {
  const MealSuggestions({required this.meals});

  factory MealSuggestions.fromMap(Map<String, dynamic> row) => MealSuggestions(
    meals: [
      for (final meal in (row['meals'] as List? ?? const []))
        if (meal is Map<String, dynamic>) SuggestedMeal.fromMap(meal),
    ],
  );

  final List<SuggestedMeal> meals;

  bool get hasMeals => meals.isNotEmpty;

  @override
  List<Object?> get props => [meals];
}

class SuggestedMeal extends Equatable with MacroTotals {
  const SuggestedMeal({required this.name, required this.summary, required this.items});

  factory SuggestedMeal.fromMap(Map<String, dynamic> row) => SuggestedMeal(
    name: row['name'] as String,
    summary: row['summary'] as String? ?? '',
    items: [
      for (final item in (row['items'] as List? ?? const []))
        if (item is Map<String, dynamic>) SuggestedMealItem.fromMap(item),
    ],
  );

  final String name;
  final String summary;
  final List<SuggestedMealItem> items;

  @override
  List<FoodPortion> get entries => items;

  @override
  List<Object?> get props => [name, summary, items];
}

// A suggested item is a food and an amount of it, so it mixes in FoodPortion and
// its meal totals up through MacroTotals exactly like a logged day or a recipe -
// there is no second way to add macros in this app.
class SuggestedMealItem extends Equatable with FoodPortion {
  const SuggestedMealItem({required this.food, required this.quantityGrams});

  // The model answers with a name plus per-100g macros, which is a catalog food
  // that does not exist yet - the same FoodSource.custom row a scanned item
  // becomes. Every macro defaults to 0 so an omitted field needs no null branch
  // downstream, mirroring ScannedMealItem.
  factory SuggestedMealItem.fromMap(Map<String, dynamic> row) => SuggestedMealItem(
    food: Food(
      name: row['name'] as String,
      source: .custom,
      caloriesPer100g: (row['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (row['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (row['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (row['fatPer100g'] as num?)?.toDouble() ?? 0,
      fiberPer100g: (row['fiberPer100g'] as num?)?.toDouble() ?? 0,
    ),
    quantityGrams: (row['suggestedGrams'] as num?)?.toDouble() ?? 0,
  );

  @override
  final Food food;

  @override
  final double quantityGrams;

  @override
  List<Object?> get props => [food, quantityGrams];
}

class SuggestedMealLogItem extends Equatable {
  const SuggestedMealLogItem({required this.food, required this.quantityGrams});

  final Food food;
  final double quantityGrams;

  @override
  List<Object?> get props => [food, quantityGrams];
}
