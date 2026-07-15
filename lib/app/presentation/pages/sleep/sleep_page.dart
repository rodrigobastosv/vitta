import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/edit_sleep_goal_dialog.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/log_sleep_sheet.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_log_tile.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<SleepCubit, SleepState, SleepPresentationEvent>(
    onPresentation: (context, event) {
      switch (event) {
        case SleepShowLoading():
          context.showLoading();
        case SleepHideLoading():
          context.hideLoading();
        case SleepError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<SleepCubit>().loadRecent);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.sleepFeatureTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: l10n.sleepHistoryTitle,
              onPressed: () => context.pushRoute(.sleepHistory),
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: l10n.sleepGoalDialogTitle,
              onPressed: () async {
                final goalHours = await showEditSleepGoalDialog(context: context, currentGoalHours: cubit.durationGoalHours);
                if (goalHours != null) {
                  await cubit.saveDurationGoalHours(goalHours);
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: cubit.loadRecent,
          child: state.logs.isEmpty
              ? ListView(
                  children: [VTEmptyState(icon: Icons.bedtime_outlined, title: l10n.sleepEmptyTitle, message: l10n.sleepEmptyMessage)],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  itemCount: state.logs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
                  itemBuilder: (context, index) {
                    final log = state.logs[index];
                    return SleepLogTile(
                      log: log,
                      onDelete: () => cubit.deleteLog(logId: log.id),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showLogSleepSheet(context: context),
          child: const Icon(Icons.add),
        ),
      );
    },
  );
}
