import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension HomeFeatureLabel on HomeFeature {
  String label(AppLocalizations l10n) => switch (this) {
    .diet => l10n.dietFeatureTitle,
    .water => l10n.waterFeatureTitle,
    .reminders => l10n.reminderFeatureTitle,
    .workout => l10n.workoutFeatureTitle,
    .sleep => l10n.sleepFeatureTitle,
    .bodyWeight => l10n.bodyWeightFeatureTitle,
  };

  IconData get icon => switch (this) {
    .diet => Icons.restaurant_outlined,
    .water => Icons.water_drop_outlined,
    .reminders => Icons.checklist_rounded,
    .workout => Icons.fitness_center_outlined,
    .sleep => Icons.bedtime_outlined,
    .bodyWeight => Icons.monitor_weight_outlined,
  };

  Color get accent => switch (this) {
    .diet => VTColors.macroCarbs,
    .water => VTColors.water,
    .reminders => VTColors.coral,
    .workout => VTColors.green,
    .sleep => VTColors.sleep,
    .bodyWeight => VTColors.success,
  };

  AppRoute get route => switch (this) {
    .diet => AppRoute.diet,
    .water => AppRoute.water,
    .reminders => AppRoute.reminders,
    .workout => AppRoute.workout,
    .sleep => AppRoute.sleep,
    .bodyWeight => AppRoute.bodyWeight,
  };
}
