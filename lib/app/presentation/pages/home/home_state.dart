import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.user,
    required this.dailyMacros,
    required this.macroGoals,
    this.consumedMl = 0,
    this.dailyGoalMl = 0,
    this.nextReminder,
    this.workouts = const [],
    this.lastNightHours,
    this.latestWeightKg,
    this.isLoaded = true,
  });

  final User user;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final double consumedMl;
  final double dailyGoalMl;
  final Reminder? nextReminder;
  final List<Workout> workouts;
  final double? lastNightHours;
  final double? latestWeightKg;
  final bool isLoaded;

  int get completedExercises => workouts.expand((workout) => workout.exercises).where((exercise) => exercise.isCompleted).length;

  int get totalExercises => workouts.expand((workout) => workout.exercises).length;

  bool get hasWorkoutToday => totalExercises > 0;

  int get loggedMealCount => dailyMacros.entries.map((entry) => entry.log.mealType).toSet().length;

  double get waterLeftMl => (dailyGoalMl - consumedMl).clamp(0, dailyGoalMl).toDouble();

  HomeState copyWith({
    User? user,
    DailyMacros? dailyMacros,
    MacroGoals? macroGoals,
    double? consumedMl,
    double? dailyGoalMl,
    Reminder? nextReminder,
    List<Workout>? workouts,
    double? lastNightHours,
    double? latestWeightKg,
    bool? isLoaded,
  }) => HomeState(
    user: user ?? this.user,
    dailyMacros: dailyMacros ?? this.dailyMacros,
    macroGoals: macroGoals ?? this.macroGoals,
    consumedMl: consumedMl ?? this.consumedMl,
    dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
    nextReminder: nextReminder ?? this.nextReminder,
    workouts: workouts ?? this.workouts,
    lastNightHours: lastNightHours ?? this.lastNightHours,
    latestWeightKg: latestWeightKg ?? this.latestWeightKg,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [user, dailyMacros, macroGoals, consumedMl, dailyGoalMl, nextReminder, workouts, lastNightHours, latestWeightKg, isLoaded];
}
