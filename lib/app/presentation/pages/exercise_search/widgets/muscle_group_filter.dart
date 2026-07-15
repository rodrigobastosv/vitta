import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class MuscleGroupFilter extends StatelessWidget {
  const MuscleGroupFilter({required this.selected, required this.onChanged, super.key});

  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: .horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
        children: [
          ChoiceChip(label: Text(l10n.exerciseSearchAllFilter), selected: selected == null, onSelected: (_) => onChanged(null)),
          for (final muscleGroup in MuscleGroup.values) ...[
            const SizedBox(width: VTSpacing.s),
            ChoiceChip(
              label: Text(muscleGroup.getLabel(l10n)),
              selected: selected == muscleGroup,
              onSelected: (isSelected) => onChanged(isSelected ? muscleGroup : null),
            ),
          ],
        ],
      ),
    );
  }
}
