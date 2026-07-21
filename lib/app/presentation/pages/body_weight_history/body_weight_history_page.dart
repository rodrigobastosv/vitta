import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_state.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/widgets/body_weight_trend_card.dart';

class BodyWeightHistoryPage extends StatelessWidget {
  const BodyWeightHistoryPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<BodyWeightHistoryCubit, BodyWeightHistoryState, BodyWeightHistoryPresentationEvent>(
    onPresentation: (context, event) {
      switch (event) {
        case BodyWeightHistoryShowLoading():
          context.showLoading();
        case BodyWeightHistoryHideLoading():
          context.hideLoading();
        case BodyWeightHistoryError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<BodyWeightHistoryCubit>().onInit);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bodyWeightHistoryTitle)),
        body: !state.isLoaded
            ? const Padding(padding: EdgeInsets.all(VTSpacing.m), child: ListSkeleton(headerHeight: 260, rows: 2))
            : ListView(
                padding: const EdgeInsets.all(VTSpacing.m),
                children: [
                  TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
                  const VTGap.l(),
                  if (state.logs.isEmpty)
                    VTEmptyState(
                      icon: Icons.monitor_weight_outlined,
                      title: l10n.bodyWeightHistoryEmptyTitle,
                      message: l10n.bodyWeightHistoryEmptyMessage,
                      actionLabel: l10n.bodyWeightHistoryEmptyAction,
                      onAction: () => Navigator.of(context).pop(),
                    )
                  else
                    BodyWeightTrendCard(logs: state.logs, unitSystem: cubit.unitSystem),
                ],
              ),
      );
    },
  );
}
