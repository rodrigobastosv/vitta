import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class RecentSearchesList extends StatelessWidget {
  const RecentSearchesList({required this.queries, required this.onSelect, required this.onRemove, required this.onClear, super.key});

  final List<String> queries;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 18, color: colorScheme.onSurfaceVariant),
            const VTGap.s(),
            Expanded(child: Text(l10n.dietRecentSearchesTitle, style: VTTextStyles.overline(context))),
            TextButton(onPressed: onClear, child: Text(l10n.dietClearRecentSearchesAction)),
          ],
        ),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.s,
          children: [
            for (final (index, query) in queries.indexed)
              VTAppearEffect(
                key: ValueKey(query),
                index: index,
                child: InputChip(
                  label: Text(query, style: VTTextStyles.body(context)),
                  avatar: Icon(Icons.history, size: 16, color: colorScheme.onSurfaceVariant),
                  onPressed: () => onSelect(query),
                  onDeleted: () => onRemove(query),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteButtonTooltipMessage: l10n.dietRemoveRecentSearchTooltip,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
