import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_section_card.dart';

class DietDayPage extends StatelessWidget {
  const DietDayPage({required this.date, required this.dailyMacros, required this.macroGoals, super.key});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.materialLocalizations.formatFullDate(date)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: VTSpacing.m),
            child: Center(child: VTBadge(label: l10n.dietDayReadOnlyBadge, color: context.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(VTSpacing.m),
        children: [
          VTAppearEffect(
            child: MacroSummaryCard(dailyMacros: dailyMacros, macroGoals: macroGoals),
          ),
          const VTGap.l(),
          if (dailyMacros.entries.isEmpty)
            VTEmptyState(icon: Icons.restaurant_outlined, message: l10n.dietDayDetailsEmptyMessage)
          else
            for (final (index, section) in dailyMacros.meals.indexed) ...[
              VTAppearEffect(
                key: ValueKey(section.mealType),
                index: index + 1,
                child: MealSectionCard(section: section, initiallyExpanded: true),
              ),
              const VTGap.m(),
            ],
        ],
      ),
    );
  }
}
