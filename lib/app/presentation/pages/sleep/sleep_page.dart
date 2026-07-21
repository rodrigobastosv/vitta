import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/edit_sleep_goal_dialog.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/log_sleep_sheet.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_log_tile.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_summary_card.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<SleepCubit, SleepState, SleepPresentationEvent>(
    onPresentation: (context, event) {
      final l10n = context.l10n;
      switch (event) {
        case SleepShowLoading():
          context.showLoading();
        case SleepHideLoading():
          context.hideLoading();
        case SleepError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<SleepCubit>().loadRecent);
        case SleepImported(:final count):
          context.showToast(title: l10n.sleepSyncedTitle, message: l10n.sleepImportedMessage(count));
        case SleepHealthUnavailable():
          context.showWarningToast(message: l10n.sleepHealthUnavailableMessage);
        case SleepHealthPermissionDenied():
          context.showWarningToast(message: l10n.sleepHealthPermissionDeniedMessage);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.sleepFeatureTitle),
          actions: [
            if (kDebugMode)
              IconButton(icon: const Icon(Icons.bug_report_outlined), tooltip: l10n.sleepSyncDebugTooltip, onPressed: cubit.seedSampleSleepForDebug),
            IconButton(icon: const Icon(Icons.sync), tooltip: l10n.sleepSyncTooltip, onPressed: cubit.importFromHealth),
            IconButton(icon: const Icon(Icons.calendar_month_outlined), tooltip: l10n.sleepHistoryTitle, onPressed: () => context.pushRoute(.sleepHistory)),
          ],
        ),
        body: VTRefreshable(
          onRefresh: cubit.loadRecent,
          children: [
            if (state.logs.isEmpty)
              VTEmptyState(
                icon: Icons.bedtime_outlined,
                title: l10n.sleepEmptyTitle,
                message: l10n.sleepEmptyMessage,
                actionLabel: l10n.sleepLogAction,
                actionIcon: Icons.add,
                onAction: () => showLogSleepSheet(context: context),
              )
            else ...[
              SleepSummaryCard(
                logs: state.logs,
                goalHours: cubit.durationGoalHours,
                onEditGoal: () async {
                  final goalHours = await showEditSleepGoalDialog(context: context, currentGoalHours: cubit.durationGoalHours);
                  if (goalHours != null) {
                    await cubit.saveDurationGoalHours(goalHours);
                    await cubit.loadRecent();
                  }
                },
              ),
              const VTGap.l(),
              for (final log in state.logs) ...[
                SleepLogTile(
                  log: log,
                  onDelete: () => cubit.deleteLog(logId: log.id),
                ),
                const VTGap.s(),
              ],
            ],
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showLogSleepSheet(context: context),
          icon: const Icon(Icons.add),
          label: Text(l10n.sleepLogAction),
        ),
      );
    },
  );
}
