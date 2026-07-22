import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/presentation/general/home_feature_labels.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class HomeFeatureTile extends StatelessWidget {
  const HomeFeatureTile({required this.feature, required this.state, required this.unitSystem, required this.onOpen, super.key});

  final HomeFeature feature;
  final HomeState state;
  final UnitSystem unitSystem;
  final ValueChanged<HomeFeature> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTFeatureTile(icon: feature.icon, accent: feature.accent, title: feature.label(l10n), subtitle: _subtitle(l10n), onTap: () => onOpen(feature));
  }

  String _subtitle(AppLocalizations l10n) => switch (feature) {
    .diet => l10n.homeMealsLogged(state.loggedMealCount),
    .water => '${unitSystem.millilitersToDisplayVolume(state.consumedMl).round()} ${unitSystem.volumeUnitLabel}',
    .reminders => state.nextReminder == null ? l10n.homeNoReminders : l10n.homeRemindersOpen(state.openReminders.length),
    .workout => state.hasWorkoutToday ? l10n.homeWorkoutProgress(state.completedExercises, state.totalExercises) : l10n.homeNoWorkout,
    .sleep => switch (state.lastNightHours) {
      final hours? => l10n.sleepDurationLabel(hours.floor(), ((hours - hours.floor()) * 60).round()),
      null => l10n.homeNotTrackedYet,
    },
    .bodyWeight => switch (state.latestWeightKg) {
      final weightKg? => '${unitSystem.kilogramsToDisplayLoad(weightKg).toStringAsFixed(1)} ${unitSystem.loadUnitLabel}',
      null => l10n.homeNotTrackedYet,
    },
  };
}
