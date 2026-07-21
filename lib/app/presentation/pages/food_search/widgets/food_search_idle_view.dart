import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/recent_food_tile.dart';

class FoodSearchIdleView extends StatelessWidget {
  const FoodSearchIdleView({
    required this.recentFoods,
    required this.recentSearches,
    required this.onOpenFood,
    required this.onQuickAdd,
    required this.onSelectSearch,
    required this.onClearSearches,
    super.key,
  });

  final List<FoodLogEntry> recentFoods;
  final List<String> recentSearches;
  final ValueChanged<FoodLogEntry> onOpenFood;
  final ValueChanged<FoodLogEntry> onQuickAdd;
  final ValueChanged<String> onSelectSearch;
  final VoidCallback onClearSearches;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (recentFoods.isEmpty && recentSearches.isEmpty) {
      return VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.xxl),
      children: [
        if (recentFoods.isNotEmpty) ...[
          Text(l10n.dietRecentlyLoggedTitle, style: VTTextStyles.overline(context)),
          const VTGap.s(),
          for (final (index, entry) in recentFoods.indexed) ...[
            VTAppearEffect(
              index: index,
              child: RecentFoodTile(entry: entry, onTap: () => onOpenFood(entry), onQuickAdd: () => onQuickAdd(entry)),
            ),
            const VTGap.s(),
          ],
        ],
        if (recentSearches.isNotEmpty) ...[
          const VTGap.m(),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(l10n.dietRecentSearchesTitle, style: VTTextStyles.overline(context)),
              TextButton(onPressed: onClearSearches, child: Text(l10n.dietClearRecentSearchesAction)),
            ],
          ),
          Wrap(
            spacing: VTSpacing.s,
            runSpacing: VTSpacing.xs,
            children: [for (final query in recentSearches) ActionChip(label: Text(query), onPressed: () => onSelectSearch(query))],
          ),
        ],
      ],
    );
  }
}
