import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_food_tile.dart';

class RecentFoodsList extends StatelessWidget {
  const RecentFoodsList({required this.entries, required this.onOpenFood, required this.onQuickAdd, super.key});

  final List<FoodLogEntry> entries;
  final ValueChanged<FoodLogEntry> onOpenFood;
  final ValueChanged<FoodLogEntry> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (entries.isEmpty) {
      return VTEmptyState(icon: Icons.history, title: l10n.dietRecentEmptyTitle, message: l10n.dietRecentEmptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.xxl),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const VTGap.s(),
      itemBuilder: (context, index) => VTAppearEffect(
        index: index,
        child: RecentFoodTile(entry: entries[index], onTap: () => onOpenFood(entries[index]), onQuickAdd: () => onQuickAdd(entries[index])),
      ),
    );
  }
}
