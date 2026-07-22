import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class MealScanTypeSelector extends StatelessWidget {
  const MealScanTypeSelector({required this.selected, required this.onSelected, super.key});

  final MealType selected;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.mealScanMealTypeTitle, style: VTTextStyles.bodyStrong(context)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          children: [
            for (final mealType in MealType.values)
              ChoiceChip(
                // Material draws the selection checkmark in the avatar slot, so a
                // chip that supplies its own glyph stacks the check on top of it.
                // The fill already says it is selected.
                showCheckmark: false,
                // Inked here rather than in chipTheme: RawChip merges
                // chipTheme.iconTheme without resolving widget states, so a
                // WidgetStateColor there collapses to its fallback and the glyph
                // keeps the unselected ink on the selected fill.
                avatar: Icon(
                  mealType.icon,
                  size: 18,
                  color: selected == mealType ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                ),
                label: Text(mealType.getLabel(l10n)),
                selected: selected == mealType,
                onSelected: (_) => onSelected(mealType),
              ),
          ],
        ),
      ],
    );
  }
}
