import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_presentation_event.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_state.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_log_tile.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_summary_card.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/log_body_weight_sheet.dart';

class BodyWeightPage extends StatelessWidget {
  const BodyWeightPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<BodyWeightCubit, BodyWeightState, BodyWeightPresentationEvent>(
    onPresentation: (context, event) {
      final l10n = context.l10n;
      switch (event) {
        case BodyWeightShowLoading():
          context.showLoading();
        case BodyWeightHideLoading():
          context.hideLoading();
        case BodyWeightError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<BodyWeightCubit>().loadRecent);
        case BodyWeightLogged():
          context.showToast(title: l10n.bodyWeightFeatureTitle, message: l10n.bodyWeightLogAction);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      final unitSystem = cubit.unitSystem;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.bodyWeightFeatureTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: l10n.bodyWeightHistoryTitle,
              onPressed: () => context.pushRoute(.bodyWeightHistory),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showLogBodyWeightSheet(context: context),
          icon: const Icon(Icons.add),
          label: Text(l10n.bodyWeightLogAction),
        ),
        body: RefreshIndicator(
          onRefresh: cubit.loadRecent,
          child: state.logs.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  children: [
                    VTEmptyState(
                      icon: Icons.monitor_weight_outlined,
                      title: l10n.bodyWeightEmptyTitle,
                      message: l10n.bodyWeightEmptyMessage,
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  children: [
                    BodyWeightSummaryCard(logs: state.logs, unitSystem: unitSystem),
                    const VTGap.l(),
                    Text(l10n.bodyWeightRecentTitle, style: VTTextStyles.title(context)),
                    const VTGap.s(),
                    for (final (index, log) in state.logs.indexed) ...[
                      BodyWeightLogTile(
                        log: log,
                        unitSystem: unitSystem,
                        previousWeightKg: index + 1 < state.logs.length ? state.logs[index + 1].weightKg : null,
                        onDelete: () => cubit.deleteLog(logId: log.id),
                      ),
                      const VTGap.s(),
                    ],
                  ],
                ),
        ),
      );
    },
  );
}
