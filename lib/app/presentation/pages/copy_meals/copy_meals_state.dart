import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class CopyMealsState extends Equatable {
  const CopyMealsState({
    required this.targetDate,
    required this.month,
    required this.macroGoals,
    this.sourceDate,
    this.macrosByDate = const {},
    this.selectedMealTypes = const {},
  });

  final DateTime targetDate;
  final DateTime month;
  final MacroGoals macroGoals;
  final DateTime? sourceDate;
  final Map<DateTime, DailyMacros> macrosByDate;
  final Set<MealType> selectedMealTypes;

  List<MealSection> get sourceMeals {
    final date = sourceDate;
    return date == null ? const [] : macrosByDate[date]?.meals ?? const [];
  }

  List<FoodLogEntry> get entriesToCopy => [
    for (final section in sourceMeals)
      if (selectedMealTypes.contains(section.mealType)) ...section.entries,
  ];

  bool get canCopy => entriesToCopy.isNotEmpty;

  CopyMealsState copyWith({
    DateTime? month,
    MacroGoals? macroGoals,
    DateTime? sourceDate,
    Map<DateTime, DailyMacros>? macrosByDate,
    Set<MealType>? selectedMealTypes,
  }) => CopyMealsState(
    targetDate: targetDate,
    month: month ?? this.month,
    macroGoals: macroGoals ?? this.macroGoals,
    sourceDate: sourceDate ?? this.sourceDate,
    macrosByDate: macrosByDate ?? this.macrosByDate,
    selectedMealTypes: selectedMealTypes ?? this.selectedMealTypes,
  );

  @override
  List<Object?> get props => [targetDate, month, macroGoals, sourceDate, macrosByDate, selectedMealTypes];
}
