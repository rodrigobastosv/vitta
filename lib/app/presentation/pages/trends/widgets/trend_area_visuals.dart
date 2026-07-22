import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

IconData trendAreaIcon(TrendArea area) => switch (area) {
  .nutrition => Icons.restaurant_outlined,
  .water => Icons.water_drop_outlined,
  .sleep => Icons.bedtime_outlined,
  .workout => Icons.fitness_center_outlined,
  .bodyWeight => Icons.monitor_weight_outlined,
};

Color trendAreaAccent(TrendArea area) => switch (area) {
  .nutrition => VTColors.coral,
  .water => VTColors.water,
  .sleep => VTColors.sleep,
  .workout => VTColors.green,
  .bodyWeight => VTColors.success,
};

AppRoute trendAreaHistoryRoute(TrendArea area) => switch (area) {
  .nutrition => AppRoute.dietHistory,
  .water => AppRoute.waterHistory,
  .sleep => AppRoute.sleepHistory,
  .workout => AppRoute.workoutHistory,
  .bodyWeight => AppRoute.bodyWeightHistory,
};
