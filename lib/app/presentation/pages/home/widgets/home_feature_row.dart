import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/presentation/general/home_feature_labels.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_supporting_row.dart';

class HomeFeatureRow extends StatelessWidget {
  const HomeFeatureRow({required this.feature, required this.state, required this.unitSystem, required this.onOpen, super.key});

  final HomeFeature feature;
  final HomeState state;
  final UnitSystem unitSystem;
  final ValueChanged<HomeFeature> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return HomeSupportingRow(
      icon: feature.icon,
      accent: feature.accent,
      title: switch (feature) {
        .reminders => state.nextReminder?.title ?? l10n.reminderFeatureTitle,
        _ => feature.label(l10n),
      },
      subtitle: _subtitle(context),
      value: _value(context),
      onTap: () => onOpen(feature),
    );
  }

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    return switch (feature) {
      .diet => l10n.homeMealsLogged(state.loggedMealCount),
      .water =>
        state.waterLeftMl <= 0
            ? l10n.homeWaterDone
            : l10n.homeWaterLeft(unitSystem.millilitersToDisplayVolume(state.waterLeftMl).round().toString(), unitSystem.volumeUnitLabel),
      .reminders => state.nextReminder == null ? l10n.homeNoReminders : l10n.homeNextReminder,
      .workout => state.hasWorkoutToday ? l10n.homeWorkoutProgress(state.completedExercises, state.totalExercises) : l10n.homeNoWorkout,
      .sleep => state.lastNightHours == null ? l10n.homeNotTrackedYet : l10n.homeSleepLastNight,
      .bodyWeight => state.latestWeightKg == null ? l10n.homeNotTrackedYet : l10n.homeWeightLatest,
    };
  }

  String _value(BuildContext context) {
    final l10n = context.l10n;
    return switch (feature) {
      .diet => '${state.dailyMacros.totalCalories.round()}',
      .water => '${unitSystem.millilitersToDisplayVolume(state.consumedMl).round()} ${unitSystem.volumeUnitLabel}',
      .reminders => switch (state.nextReminder?.remindAt) {
        final remindAt? => context.materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(remindAt)),
        _ => '',
      },
      .workout => state.hasWorkoutToday ? '${state.completedExercises}/${state.totalExercises}' : '',
      .sleep => switch (state.lastNightHours) {
        final hours? => l10n.sleepDurationLabel(hours.floor(), ((hours - hours.floor()) * 60).round()),
        null => '',
      },
      .bodyWeight => switch (state.latestWeightKg) {
        final weightKg? => '${unitSystem.kilogramsToDisplayLoad(weightKg).toStringAsFixed(1)} ${unitSystem.loadUnitLabel}',
        null => '',
      },
    };
  }
}
