import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_card.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_label.dart';

class DietModalitySelector extends StatefulWidget {
  const DietModalitySelector({required this.selected, required this.onSelected, super.key});

  // Null means the current split matches no preset - a custom split.
  final DietModality? selected;
  final ValueChanged<DietModality> onSelected;

  @override
  State<DietModalitySelector> createState() => _DietModalitySelectorState();
}

class _DietModalitySelectorState extends State<DietModalitySelector> {
  bool _expanded = false;

  static const double _cardHeight = 110;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final selectedLabel = widget.selected == null ? l10n.macroGoalsModalityCustom : dietModalityLabel(l10n, widget.selected!);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Material(
          type: MaterialType.transparency,
          borderRadius: VTRadius.borderRadiusM,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: VTRadius.borderRadiusM,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: VTSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.macroGoalsModalityTitle, style: VTTextStyles.title(context))),
                  if (!_expanded)
                    Flexible(
                      child: Text(
                        selectedLabel,
                        style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: .ellipsis,
                        textAlign: .end,
                      ),
                    ),
                  const VTGap.s(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: VTMotion.transition,
          alignment: .topCenter,
          child: _expanded ? _cards(context) : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _cards(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        const VTGap.xs(),
        Text(l10n.macroGoalsModalityHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        const VTGap.s(),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: .horizontal,
            padding: EdgeInsets.zero,
            itemCount: DietModality.values.length,
            separatorBuilder: (context, index) => const VTGap.s(),
            itemBuilder: (context, index) {
              final modality = DietModality.values[index];
              return DietModalityCard(
                modality: modality,
                isSelected: modality == widget.selected,
                onTap: () => widget.onSelected(modality),
              );
            },
          ),
        ),
      ],
    );
  }
}
