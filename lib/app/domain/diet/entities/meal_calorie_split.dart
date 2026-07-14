import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class MealCalorieSplit extends Equatable {
  const MealCalorieSplit({required this.caloriesByMealType, required this.loggedDayCount});

  factory MealCalorieSplit.fromLoggedDays(List<DailyMacros> loggedDays) {
    final daysWithFood = loggedDays.where((day) => day.entries.isNotEmpty).toList();
    final caloriesByMealType = <MealType, double>{};
    for (final day in daysWithFood) {
      for (final meal in day.meals) {
        caloriesByMealType[meal.mealType] = (caloriesByMealType[meal.mealType] ?? 0) + meal.totalCalories;
      }
    }
    return MealCalorieSplit(caloriesByMealType: caloriesByMealType, loggedDayCount: daysWithFood.length);
  }

  final Map<MealType, double> caloriesByMealType;
  final int loggedDayCount;

  double get totalCalories => caloriesByMealType.values.fold(0, (sum, calories) => sum + calories);

  bool get hasData => totalCalories > 0;

  List<MealType> get presentMealTypes => [
    for (final mealType in MealType.values)
      if ((caloriesByMealType[mealType] ?? 0) > 0) mealType,
  ];

  double shareOf(MealType mealType) => hasData ? (caloriesByMealType[mealType] ?? 0) / totalCalories : 0;

  double dailyAverageOf(MealType mealType) => loggedDayCount == 0 ? 0 : (caloriesByMealType[mealType] ?? 0) / loggedDayCount;

  @override
  List<Object?> get props => [caloriesByMealType, loggedDayCount];
}
