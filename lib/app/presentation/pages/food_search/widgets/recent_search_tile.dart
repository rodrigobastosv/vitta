import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class RecentSearchTile extends StatelessWidget {
  const RecentSearchTile({required this.query, required this.onTap, required this.onRemove, super.key});

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: VTRadius.borderRadiusM,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.xs, vertical: VTSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.history, size: 20, color: colorScheme.onSurfaceVariant),
            const VTGap.m(),
            Expanded(child: Text(query, style: VTTextStyles.body(context), maxLines: 1, overflow: .ellipsis)),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              color: colorScheme.onSurfaceVariant,
              tooltip: context.l10n.dietRemoveRecentSearchTooltip,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
