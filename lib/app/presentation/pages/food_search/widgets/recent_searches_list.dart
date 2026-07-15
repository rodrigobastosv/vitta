import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/recent_search_tile.dart';

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
        for (final (index, query) in queries.indexed)
          VTAppearEffect(
            key: ValueKey(query),
            delay: Duration(milliseconds: index.clamp(0, 8) * 40),
            child: RecentSearchTile(query: query, onTap: () => onSelect(query), onRemove: () => onRemove(query)),
          ),
      ],
    );
  }
}
