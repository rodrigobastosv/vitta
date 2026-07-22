import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_pose_labels.dart';

class ProgressPhotoPoseSelector extends StatelessWidget {
  const ProgressPhotoPoseSelector({required this.poses, required this.selected, required this.onSelected, this.hint, super.key});

  final List<ProgressPhotoPose> poses;
  final ProgressPhotoPose selected;
  final void Function(ProgressPhotoPose pose) onSelected;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Icon(Icons.center_focus_strong_outlined, size: 18, color: colorScheme.onSurfaceVariant),
            const VTGap.xs(),
            Text(l10n.progressPhotosPoseLabel, style: VTTextStyles.overline(context)),
          ],
        ),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.s,
          children: [
            for (final pose in poses)
              ChoiceChip(
                selected: pose == selected,
                showCheckmark: false,
                avatar: Icon(
                  pose.icon,
                  size: 18,
                  color: pose == selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                ),
                label: Text(pose.label(l10n)),
                onSelected: (_) {
                  if (pose == selected) {
                    return;
                  }
                  VTHaptics.selection();
                  onSelected(pose);
                },
              ),
          ],
        ),
        if (hint case final hint?) ...[
          const VTGap.xs(),
          Text(hint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}
