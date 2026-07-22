import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/trends/trends_cubit.dart';
import 'package:vitta/app/presentation/pages/trends/trends_presentation_event.dart';
import 'package:vitta/app/presentation/pages/trends/trends_state.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_card.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trends_headline_card.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trends_skeleton.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<TrendsCubit, TrendsState, TrendsPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case TrendsShowLoading():
            context.showLoading();
          case TrendsHideLoading():
            context.hideLoading();
          case TrendsError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<TrendsCubit>().refresh);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.trendsTitle)),
        body: VTRefreshable(
          onRefresh: cubit.refresh,
          hasData: state.hasData,
          isLoaded: state.isLoaded,
          skeleton: const TrendsSkeleton(),
          emptyState: VTEmptyState(
            icon: Icons.insights_outlined,
            title: l10n.trendsEmptyTitle,
            message: l10n.trendsEmptyMessage,
            actionLabel: l10n.trendsEmptyAction,
            onAction: () => Navigator.of(context).pop(),
          ),
          children: [
            TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
            const VTGap.m(),
            VTAppearEffect(
              key: ValueKey('headline-${state.trendRange}'),
              child: TrendsHeadlineCard(state: state),
            ),
            const VTGap.l(),
            Text(l10n.trendsAreasTitle, style: VTTextStyles.overline(context)),
            const VTGap.s(),
            for (final (index, area) in TrendArea.values.indexed) ...[
              VTAppearEffect(
                key: ValueKey('$area-${state.trendRange}'),
                index: index + 1,
                child: TrendAreaCard(
                  area: area,
                  trend: state.trendOf(area),
                  unitSystem: cubit.unitSystem,
                  onOpenHistory: () => context.pushRoute(trendAreaHistoryRoute(area)),
                ),
              ),
              const VTGap.m(),
            ],
          ],
        ),
      ),
    );
  }
}
