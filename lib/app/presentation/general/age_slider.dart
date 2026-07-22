import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';

class AgeSlider extends StatelessWidget {
  const AgeSlider({required this.ageYears, required this.onChanged, super.key});

  static const double minAgeYears = 14;
  static const double maxAgeYears = 100;

  final int ageYears;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTLabeledSlider(
      label: l10n.bodyProfileAgeLabel,
      valueLabel: l10n.bodyProfileAgeValue(ageYears),
      value: ageYears.toDouble(),
      min: minAgeYears,
      max: maxAgeYears,
      color: context.colorScheme.primary,
      onChanged: (value) => onChanged(value.round()),
    );
  }
}
