import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/presentation/general/body_profile_labels.dart';

class ActivityLevelSelector extends StatelessWidget {
  const ActivityLevelSelector({required this.activityLevel, required this.onChanged, super.key});

  final ActivityLevel? activityLevel;
  final ValueChanged<ActivityLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.bodyProfileActivityTitle, style: VTTextStyles.bodyStrong(context)),
        Text(l10n.bodyProfileActivityHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.xs,
          children: [
            for (final option in ActivityLevel.values)
              ChoiceChip(
                label: Text(option.label(l10n)),
                selected: option == activityLevel,
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
