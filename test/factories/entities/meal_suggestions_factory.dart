import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';

import 'food_factory.dart';

abstract class MealSuggestionsFactory {
  static SuggestedMealItem buildItem({Food? food, String name = 'Grilled chicken', double quantityGrams = 150, double caloriesPer100g = 165}) =>
      SuggestedMealItem(
        food: food ?? FoodFactory.build(id: null, name: name, caloriesPer100g: caloriesPer100g, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6),
        quantityGrams: quantityGrams,
      );

  static SuggestedMeal buildMeal({String name = 'Chicken and rice', String summary = 'High protein', List<SuggestedMealItem>? items}) =>
      SuggestedMeal(name: name, summary: summary, items: items ?? [buildItem()]);

  static MealSuggestions build({List<SuggestedMeal>? meals}) => MealSuggestions(meals: meals ?? [buildMeal()]);
}
