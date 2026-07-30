import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

// A meal as it was actually eaten on a given day, so it can be logged again
// whole. Deliberately not MealSection, which is a meal *within a day already on
// screen* and so carries no date of its own - the date is the whole point here,
// both for saying "Breakfast (Yesterday)" and for ordering the list.
class RecentMeal extends Equatable with MacroTotals {
  const RecentMeal({required this.date, required this.mealType, required this.entries});

  final DateTime date;
  final MealType mealType;

  @override
  final List<FoodLogEntry> entries;

  @override
  List<Object?> get props => [date, mealType, entries];
}
