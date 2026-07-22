import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/presentation/general/body_profile_labels.dart';

class BiologicalSexSelector extends StatelessWidget {
  const BiologicalSexSelector({required this.sex, required this.onChanged, super.key});

  final BiologicalSex? sex;
  final ValueChanged<BiologicalSex> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.bodyProfileSexTitle, style: VTTextStyles.bodyStrong(context)),
        Text(l10n.bodyProfileSexHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.xs,
          children: [
            for (final option in BiologicalSex.values)
              ChoiceChip(
                avatar: Icon(option.icon, size: 18, color: option == sex ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
                label: Text(option.label(l10n)),
                selected: option == sex,
                showCheckmark: false,
                onSelected: (_) {
                  VTHaptics.selection();
                  onChanged(option);
                },
              ),
          ],
        ),
      ],
    );
  }
}
