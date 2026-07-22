import 'package:flutter/material.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_body_weight_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_reminders_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_sleep_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_today_card.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_water_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_workout_hero.dart';

// One hero per feature, because a hero is not a shape a feature can be poured into:
// diet, water, sleep and workout are day-vs-goal, body weight is a trend and
// reminders are a list.
class HomeHero extends StatelessWidget {
  const HomeHero({required this.feature, required this.state, required this.unitSystem, required this.sleepGoalHours, required this.onOpen, super.key});

  final HomeFeature feature;
  final HomeState state;
  final UnitSystem unitSystem;
  final double sleepGoalHours;
  final ValueChanged<HomeFeature> onOpen;

  @override
  Widget build(BuildContext context) => switch (feature) {
    .diet => HomeTodayCard(dailyMacros: state.dailyMacros, macroGoals: state.macroGoals, onTap: _open),
    .water => HomeWaterHero(consumedMl: state.consumedMl, dailyGoalMl: state.dailyGoalMl, unitSystem: unitSystem, onTap: _open),
    .reminders => HomeRemindersHero(openReminders: state.openReminders, onTap: _open),
    .workout => HomeWorkoutHero(completedExercises: state.completedExercises, totalExercises: state.totalExercises, onTap: _open),
    .sleep => HomeSleepHero(lastNightHours: state.lastNightHours, goalHours: sleepGoalHours, onTap: _open),
    .bodyWeight => HomeBodyWeightHero(logs: state.weightLogs, latestWeightKg: state.latestWeightKg, unitSystem: unitSystem, onTap: _open),
  };

  void _open() => onOpen(feature);
}
