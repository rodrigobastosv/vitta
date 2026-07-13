import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_date_selector.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_section_card.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<DietCubit, DietState, DietPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case DietShowLoading():
            context.showLoading();
          case DietHideLoading():
            context.hideLoading();
          case DietError(:final message, :final date):
            context.showErrorDialog(message: message, onRetry: () => context.read<DietCubit>().goToDate(date));
        }
      },
      builder: (context, cubit, state) {
        Future<void> openFoodSearch([MealType? mealType]) async {
          await context.pushRoute(.foodSearch, extra: mealType);
          await cubit.refresh();
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.dietFeatureTitle)),
          body: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.all(VTSpacing.m),
              children: [
                DietDateSelector(
                  date: state.date,
                  canGoToNextDay: !cubit.isViewingToday,
                  onPreviousDay: cubit.goToPreviousDay,
                  onNextDay: cubit.goToNextDay,
                  onPickDate: cubit.goToDate,
                ),
                const VTGap.m(),
                MacroSummaryCard(dailyMacros: state.dailyMacros, macroGoals: state.macroGoals),
                const VTGap.l(),
                if (state.dailyMacros.entries.isEmpty)
                  VTEmptyState(icon: Icons.restaurant_outlined, title: l10n.dietEmptyTitle, message: l10n.dietEmptyMessage)
                else
                  for (final section in state.dailyMacros.meals) ...[
                    MealSectionCard(
                      section: section,
                      onAddFood: cubit.isViewingToday ? () => openFoodSearch(section.mealType) : null,
                      onDeleteEntry: (entry) => cubit.deleteLog(logId: entry.log.id),
                    ),
                    const VTGap.m(),
                  ],
              ],
            ),
          ),
          floatingActionButton: cubit.isViewingToday
              ? FloatingActionButton(
                  onPressed: openFoodSearch,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
