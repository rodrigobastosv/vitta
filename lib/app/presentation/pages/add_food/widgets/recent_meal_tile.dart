import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_quick_add_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/calorie_pill.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_avatar.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class RecentMealTile extends StatelessWidget {
  const RecentMealTile({required this.meal, required this.onLogAgain, super.key});

  final RecentMeal meal;
  final VoidCallback onLogAgain;

  // The count leads, because a bare list of food names reads as a list of
  // individual foods - which is exactly what this row is not. It says how many
  // foods one tap is about to add before it says which.
  String _meta(AppLocalizations l10n) =>
      '${l10n.dietRecentMealFoodCount(meal.entries.length)} · ${meal.entries.map((entry) => entry.food.name).join(' · ')}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      onTap: onLogAgain,
      child: Row(
        children: [
          MealAvatar(icon: meal.mealType.icon, color: meal.mealType.color),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  '${meal.mealType.getLabel(l10n)} · ${_relativeDay(context)}',
                  style: VTTextStyles.bodyStrong(context),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
                Text(
                  _meta(l10n),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
          const VTGap.s(),
          CaloriePill(calories: meal.totalCalories.round(), color: meal.mealType.color),
          VTQuickAddButton(onPressed: onLogAgain, tooltip: l10n.dietLogMealAgainAction),
        ],
      ),
    );
  }

  String _relativeDay(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    return switch (meal.date) {
      final day when day == today => l10n.dayToday,
      final day when day == yesterday => l10n.dayYesterday,
      _ => _weekdayName(context, meal.date),
    };
  }

  // Within the last week a weekday reads better than a date - "Monday" is how
  // anyone refers to the breakfast they are about to repeat. formatFullDate
  // leads with the weekday in both locales, so the name comes off the front of it.
  String _weekdayName(BuildContext context, DateTime date) {
    final materialLocalizations = context.materialLocalizations;
    final now = DateTime.now();
    final daysAgo = DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
    return daysAgo < DateTime.daysPerWeek ? materialLocalizations.formatFullDate(date).split(',').first : materialLocalizations.formatMediumDate(date);
  }
}
