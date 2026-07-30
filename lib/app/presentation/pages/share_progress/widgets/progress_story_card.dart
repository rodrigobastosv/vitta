import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/components/general/vt_story_card.dart';
import 'package:vitta/app/design_system/components/general/vt_story_stat.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_labels.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_change_format.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class ProgressStoryCard extends StatelessWidget {
  const ProgressStoryCard({required this.story, required this.unitSystem, super.key});

  final ProgressStory story;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTStoryCard(
      brandName: l10n.appTitle,
      eyebrow: l10n.shareProgressPeriod(story.days),
      headline: _headline(context, l10n),
      stats: [
        for (final area in story.areasWithData) _stat(l10n, area, story.trendOf(area)),
      ],
      footnote: l10n.shareProgressFootnote(story.days),
    );
  }

  Widget _headline(BuildContext context, AppLocalizations l10n) {
    final colorScheme = context.colorScheme;
    final verdict = story.verdict;
    return Row(
      children: [
        VTMacroRing(
          value: story.judgedAreaCount == 0 ? 0 : story.onTrackAreaCount / story.judgedAreaCount,
          color: verdict?.adherence.color ?? colorScheme.onSurfaceVariant,
          size: 88,
          strokeWidth: 10,
          child: Text('${story.onTrackAreaCount}/${story.judgedAreaCount}', style: VTTextStyles.title(context)),
        ),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(_verdictTitle(l10n, verdict), style: VTTextStyles.title(context), maxLines: 2, overflow: .ellipsis),
              const VTGap.xs(),
              Text(
                verdict == null ? l10n.shareProgressHint : l10n.shareProgressGoals(story.onTrackAreaCount, story.judgedAreaCount),
                style: VTTextStyles.caption(context),
                maxLines: 3,
                overflow: .ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // A story with nothing to judge still says what it is. "Nothing to judge yet"
  // is the right thing for the trends page to admit and the wrong thing to hand
  // someone a picture of - a period with logged workouts and no goal to miss is
  // progress, not a blank.
  String _verdictTitle(AppLocalizations l10n, TrendsVerdict? verdict) => switch (verdict) {
    null => l10n.shareProgressStoryTitle,
    .onTrack => l10n.trendsVerdictOnTrackTitle,
    .mixed => l10n.trendsVerdictMixedTitle,
    .offTrack => l10n.trendsVerdictOffTrackTitle,
  };

  VTStoryStat _stat(AppLocalizations l10n, TrendArea area, AreaTrend trend) => VTStoryStat(
    icon: trendAreaIcon(area),
    accent: trendAreaAccent(area),
    label: trendAreaLabel(l10n, area),
    value: trendAreaValueLabel(l10n, unitSystem, area, trend.current.average),
    changeIcon: switch (trend.direction) {
      final direction? => trendDirectionIcon(direction),
      null => null,
    },
    changeLabel: switch (trend.changeRatio) {
      final changeRatio? => signedChangePercent(changeRatio),
      null => null,
    },
  );
}
