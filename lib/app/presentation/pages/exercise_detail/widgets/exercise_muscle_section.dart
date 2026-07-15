import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class ExerciseMuscleSection extends StatelessWidget {
  const ExerciseMuscleSection({required this.title, required this.muscles, super.key});

  final String title;
  final List<MuscleGroup> muscles;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(title, style: VTTextStyles.overline(context)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.s,
          children: [for (final muscle in muscles) VTBadge(label: muscle.getLabel(l10n), color: muscle.region.color)],
        ),
      ],
    );
  }
}
