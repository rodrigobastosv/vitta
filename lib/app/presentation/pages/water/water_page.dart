import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water/water_state.dart';
import 'package:vitta/app/presentation/pages/water/widgets/edit_water_goal_dialog.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_log_tile.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_progress_card.dart';

class WaterPage extends StatelessWidget {
  const WaterPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<WaterCubit, WaterState, WaterPresentationEvent>(
    onPresentation: (context, event) {
      switch (event) {
        case WaterShowLoading():
          context.showLoading();
        case WaterHideLoading():
          context.hideLoading();
        case WaterError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<WaterCubit>().loadToday);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      final unitSystem = cubit.unitSystem;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.waterFeatureTitle),
          actions: [
            IconButton(icon: const Icon(Icons.calendar_month_outlined), tooltip: l10n.waterHistoryTitle, onPressed: () => context.pushRoute(.waterHistory)),
          ],
        ),
        body: VTRefreshable(
          onRefresh: cubit.loadToday,
          isLoaded: state.isLoaded,
          skeleton: const ListSkeleton(headerHeight: 260),
          children: [
            WaterProgressCard(
              dailyWater: state.dailyWater,
              dailyGoalMl: state.dailyGoalMl,
              unitSystem: unitSystem,
              onQuickAdd: (amountMl) => cubit.addWater(amountMl: amountMl),
              onEditGoal: () async {
                final newGoalMl = await showEditWaterGoalDialog(context: context, currentGoalMl: state.dailyGoalMl, unitSystem: unitSystem);
                if (newGoalMl != null) {
                  await cubit.changeDailyGoal(goalMl: newGoalMl);
                }
              },
            ),
            const VTGap.l(),
            if (state.dailyWater.entries.isEmpty)
              VTEmptyState(icon: Icons.water_drop_outlined, title: l10n.waterEmptyTitle, message: l10n.waterEmptyMessage)
            else
              for (final log in state.dailyWater.entries) ...[
                WaterLogTile(
                  log: log,
                  unitSystem: unitSystem,
                  onDelete: () => cubit.deleteLog(logId: log.id),
                ),
                const VTGap.s(),
              ],
          ],
        ),
      );
    },
  );
}
