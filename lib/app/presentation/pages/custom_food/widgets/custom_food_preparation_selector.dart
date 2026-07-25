import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_preparation.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_preparation_labels.dart';

class CustomFoodPreparationSelector extends StatelessWidget {
  const CustomFoodPreparationSelector({required this.preparation, required this.onChanged, super.key});

  final FoodPreparation? preparation;
  final ValueChanged<FoodPreparation?> onChanged;

  // Re-tapping the current choice clears it back to "not stated", the same
  // deselect SleepQualitySelector offers - which is why there is no third chip
  // for it. The chips carry no icon, so they keep Material's checkmark.
  void _select(FoodPreparation tapped) {
    VTHaptics.selection();
    onChanged(preparation == tapped ? null : tapped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.dietPreparationTitle, style: VTTextStyles.bodyStrong(context)),
        const VTGap.xs(),
        Text(l10n.dietPreparationHint, style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          children: [
            for (final value in FoodPreparation.values)
              ChoiceChip(label: Text(value.label(l10n)), selected: preparation == value, onSelected: (_) => _select(value)),
          ],
        ),
      ],
    );
  }
}
