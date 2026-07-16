import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

Color sleepQualityColor(int rating) => switch (rating) {
  >= 5 => VTColors.green,
  4 => VTColors.success,
  3 => VTColors.warning,
  _ => VTColors.error,
};
