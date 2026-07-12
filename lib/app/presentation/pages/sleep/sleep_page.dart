import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_error_state.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/log_sleep_sheet.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_log_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<SleepCubit, SleepState, SleepPresentationEvent>(
    builder: (context, cubit, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sleepFeatureTitle)),
        body: switch (state) {
          SleepError(:final message) => VTErrorState(message: message, retryLabel: l10n.retry, onRetry: cubit.loadRecent),
          SleepLoaded(:final logs) => RefreshIndicator(
            onRefresh: cubit.loadRecent,
            child: logs.isEmpty
                ? ListView(
                    children: [VTEmptyState(icon: Icons.bedtime_outlined, title: l10n.sleepEmptyTitle, message: l10n.sleepEmptyMessage)],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(VTSpacing.m),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return SleepLogTile(log: log, onDelete: () => cubit.deleteLog(logId: log.id));
                    },
                  ),
          ),
        },
        floatingActionButton: FloatingActionButton(
          onPressed: () => showLogSleepSheet(context: context),
          child: const Icon(Icons.add),
        ),
      );
    },
  );
}
