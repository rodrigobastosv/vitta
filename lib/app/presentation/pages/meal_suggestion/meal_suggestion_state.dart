import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_entry.dart';

class MealSuggestionState extends Equatable {
  const MealSuggestionState({
    this.dailyMacros = const DailyMacros(entries: []),
    this.goals = MacroGoals.defaultGoals,
    this.mealType = .lunch,
    this.meals = const [],
    this.entriesByMeal = const [],
    this.selectedIndex = 0,
    this.hasRequested = false,
    this.isLoaded = false,
  });

  final DailyMacros dailyMacros;
  final MacroGoals goals;
  final MealType mealType;
  final List<SuggestedMeal> meals;

  // One editable row list per suggestion rather than one for the selected meal,
  // so switching between two options and back does not throw away the amounts
  // already adjusted on the first.
  final List<List<MealSuggestionEntry>> entriesByMeal;
  final int selectedIndex;
  final bool hasRequested;

  // Whether the day behind the gap has been read at all - the skeleton/empty
  // distinction, not a loading flag (see XHistoryState.isLoaded).
  final bool isLoaded;

  MacroGap get gap => MacroGap.between(consumed: dailyMacros, goals: goals);

  SuggestedMeal? get selectedMeal => selectedIndex < meals.length ? meals[selectedIndex] : null;

  List<MealSuggestionEntry> get selectedEntries => selectedIndex < entriesByMeal.length ? entriesByMeal[selectedIndex] : const [];

  List<MealSuggestionEntry> get includedEntries => selectedEntries.where((entry) => entry.isIncluded).toList();

  bool get canLog => includedEntries.isNotEmpty && includedEntries.every((entry) => entry.isValid);

  double get totalCalories => includedEntries.fold(0, (sum, entry) => sum + entry.calories);

  MealSuggestionState copyWith({
    DailyMacros? dailyMacros,
    MacroGoals? goals,
    MealType? mealType,
    List<SuggestedMeal>? meals,
    List<List<MealSuggestionEntry>>? entriesByMeal,
    int? selectedIndex,
    bool? hasRequested,
    bool? isLoaded,
  }) => MealSuggestionState(
    dailyMacros: dailyMacros ?? this.dailyMacros,
    goals: goals ?? this.goals,
    mealType: mealType ?? this.mealType,
    meals: meals ?? this.meals,
    entriesByMeal: entriesByMeal ?? this.entriesByMeal,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    hasRequested: hasRequested ?? this.hasRequested,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [dailyMacros, goals, mealType, meals, entriesByMeal, selectedIndex, hasRequested, isLoaded];
}
