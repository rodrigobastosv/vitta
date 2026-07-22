import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.user,
    required this.dailyMacros,
    required this.macroGoals,
    required this.layout,
    this.consumedMl = 0,
    this.dailyGoalMl = 0,
    this.reminders = const [],
    this.workouts = const [],
    this.lastNightHours,
    this.latestWeightKg,
    this.weightLogs = const [],
    this.isLoaded = true,
  });

  final User user;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final HomeLayout layout;
  final double consumedMl;
  final double dailyGoalMl;
  final List<Reminder> reminders;
  final List<Workout> workouts;
  final double? lastNightHours;
  final double? latestWeightKg;
  final List<BodyWeightLog> weightLogs;
  final bool isLoaded;

  int get completedExercises => workouts.expand((workout) => workout.exercises).where((exercise) => exercise.isCompleted).length;

  int get totalExercises => workouts.expand((workout) => workout.exercises).length;

  bool get hasWorkoutToday => totalExercises > 0;

  int get loggedMealCount => dailyMacros.entries.map((entry) => entry.log.mealType).toSet().length;

  double get waterLeftMl => (dailyGoalMl - consumedMl).clamp(0, dailyGoalMl).toDouble();

  List<Reminder> get openReminders => [
    for (final reminder in reminders)
      if (!reminder.isCompleted) reminder,
  ];

  Reminder? get nextReminder => openReminders.firstOrNull;

  HomeState copyWith({
    User? user,
    DailyMacros? dailyMacros,
    MacroGoals? macroGoals,
    HomeLayout? layout,
    double? consumedMl,
    double? dailyGoalMl,
    List<Reminder>? reminders,
    List<Workout>? workouts,
    double? lastNightHours,
    double? latestWeightKg,
    List<BodyWeightLog>? weightLogs,
    bool? isLoaded,
  }) => HomeState(
    user: user ?? this.user,
    dailyMacros: dailyMacros ?? this.dailyMacros,
    macroGoals: macroGoals ?? this.macroGoals,
    layout: layout ?? this.layout,
    consumedMl: consumedMl ?? this.consumedMl,
    dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
    reminders: reminders ?? this.reminders,
    workouts: workouts ?? this.workouts,
    lastNightHours: lastNightHours ?? this.lastNightHours,
    latestWeightKg: latestWeightKg ?? this.latestWeightKg,
    weightLogs: weightLogs ?? this.weightLogs,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [
    user,
    dailyMacros,
    macroGoals,
    layout,
    consumedMl,
    dailyGoalMl,
    reminders,
    workouts,
    lastNightHours,
    latestWeightKg,
    weightLogs,
    isLoaded,
  ];
}
