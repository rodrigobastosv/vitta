import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_log_tile.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';

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
          case DietError(:final message):
            context.showErrorDialog(message: message, onRetry: context.read<DietCubit>().loadToday);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.dietFeatureTitle)),
        body: RefreshIndicator(
          onRefresh: cubit.loadToday,
          child: state.dailyMacros.entries.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(VTSpacing.m),
                      child: MacroSummaryCard(dailyMacros: state.dailyMacros),
                    ),
                    VTEmptyState(icon: Icons.restaurant_outlined, title: l10n.dietEmptyTitle, message: l10n.dietEmptyMessage),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  children: [
                    MacroSummaryCard(dailyMacros: state.dailyMacros),
                    const VTGap.l(),
                    for (final entry in state.dailyMacros.entries) ...[
                      FoodLogTile(
                        entry: entry,
                        onDelete: () => cubit.deleteLog(logId: entry.log.id),
                      ),
                      const VTGap.s(),
                    ],
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.pushRoute(.foodSearch);
            await cubit.loadToday();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
