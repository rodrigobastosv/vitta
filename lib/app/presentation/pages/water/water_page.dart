import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_error_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water/water_state.dart';
import 'package:vitta/app/presentation/pages/water/widgets/add_water_sheet.dart';
import 'package:vitta/app/presentation/pages/water/widgets/edit_water_goal_dialog.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_log_tile.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_progress_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class WaterPage extends StatelessWidget {
  const WaterPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<WaterCubit, WaterState, WaterPresentationEvent>(
    builder: (context, cubit, state) {
      final l10n = AppLocalizations.of(context);
      final unitSystem = context.watch<AppCubit>().state.unitSystem;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.waterFeatureTitle),
          actions: [
            if (state is WaterLoaded)
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                tooltip: l10n.waterGoalDialogTitle,
                onPressed: () async {
                  final newGoalMl = await showEditWaterGoalDialog(
                    context: context,
                    currentGoalMl: state.dailyGoalMl,
                    unitSystem: unitSystem,
                  );
                  if (newGoalMl != null) {
                    await cubit.changeDailyGoal(goalMl: newGoalMl);
                  }
                },
              ),
          ],
        ),
        body: switch (state) {
          WaterError(:final message) => VTErrorState(message: message, retryLabel: l10n.retry, onRetry: cubit.loadToday),
          WaterLoaded(:final dailyWater, :final dailyGoalMl) => RefreshIndicator(
            onRefresh: cubit.loadToday,
            child: dailyWater.entries.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(VTSpacing.m),
                        child: WaterProgressCard(dailyWater: dailyWater, dailyGoalMl: dailyGoalMl, unitSystem: unitSystem),
                      ),
                      VTEmptyState(icon: Icons.water_drop_outlined, title: l10n.waterEmptyTitle, message: l10n.waterEmptyMessage),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(VTSpacing.m),
                    children: [
                      WaterProgressCard(dailyWater: dailyWater, dailyGoalMl: dailyGoalMl, unitSystem: unitSystem),
                      const VTGap.l(),
                      for (final log in dailyWater.entries) ...[
                        WaterLogTile(log: log, unitSystem: unitSystem, onDelete: () => cubit.deleteLog(logId: log.id)),
                        const VTGap.s(),
                      ],
                    ],
                  ),
          ),
        },
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddWaterSheet(context: context, unitSystem: unitSystem),
          child: const Icon(Icons.add),
        ),
      );
    },
  );
}
