import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String trendAreaLabel(AppLocalizations l10n, TrendArea area) => switch (area) {
  .nutrition => l10n.dietFeatureTitle,
  .water => l10n.waterFeatureTitle,
  .sleep => l10n.sleepFeatureTitle,
  .workout => l10n.workoutFeatureTitle,
  .bodyWeight => l10n.bodyWeightFeatureTitle,
};

double trendAreaDisplayValue(UnitSystem unitSystem, TrendArea area, double value) => switch (area) {
  .nutrition || .sleep => value,
  .water => unitSystem.millilitersToDisplayVolume(value),
  .workout || .bodyWeight => unitSystem.kilogramsToDisplayLoad(value),
};

String trendAreaValueLabel(AppLocalizations l10n, UnitSystem unitSystem, TrendArea area, double value) => switch (area) {
  .nutrition => l10n.dietMealCalories(value.round()),
  .water => '${unitSystem.millilitersToDisplayVolume(value).round()} ${unitSystem.volumeUnitLabel}',
  .sleep => l10n.sleepHoursShort(value.toStringAsFixed(1)),
  .workout => '${unitSystem.kilogramsToDisplayLoad(value).round()} ${unitSystem.loadUnitLabel}',
  .bodyWeight => bodyWeightDisplay(l10n, unitSystem, value),
};

String trendAreaMetricLabel(AppLocalizations l10n, TrendArea area) => switch (area) {
  .nutrition => l10n.trendsMetricCalories,
  .water => l10n.trendsMetricWater,
  .sleep => l10n.trendsMetricSleep,
  .workout => l10n.trendsMetricVolume,
  .bodyWeight => l10n.trendsMetricBodyWeight,
};
