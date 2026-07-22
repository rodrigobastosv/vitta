import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/trends_state.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_chip.dart';

class TrendsHeadlineCard extends StatelessWidget {
  const TrendsHeadlineCard({required this.state, super.key});

  final TrendsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final verdict = state.verdict;
    final title = switch (verdict) {
      null => l10n.trendsVerdictUnknownTitle,
      .onTrack => l10n.trendsVerdictOnTrackTitle,
      .mixed => l10n.trendsVerdictMixedTitle,
      .offTrack => l10n.trendsVerdictOffTrackTitle,
    };
    final message = verdict == null
        ? l10n.trendsVerdictUnknownMessage
        : l10n.trendsVerdictSummary(state.onTrackAreaCount, state.judgedAreaCount, state.trendRange.days);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTMacroRing(
                value: state.judgedAreaCount == 0 ? 0 : state.onTrackAreaCount / state.judgedAreaCount,
                color: verdict?.adherence.color ?? colorScheme.onSurfaceVariant,
                size: 92,
                strokeWidth: 10,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text('${state.onTrackAreaCount}/${state.judgedAreaCount}', style: VTTextStyles.title(context)),
                    Text(l10n.trendsRingCaption, style: VTTextStyles.overline(context), textAlign: .center),
                  ],
                ),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(title, style: VTTextStyles.title(context)),
                    const VTGap.xs(),
                    Text(message, style: VTTextStyles.caption(context)),
                  ],
                ),
              ),
            ],
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            runSpacing: VTSpacing.s,
            children: [
              for (final area in TrendArea.values)
                if (state.trendOf(area).hasData) TrendAreaChip(area: area, adherence: state.trendOf(area).adherence),
            ],
          ),
        ],
      ),
    );
  }
}
