import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log_source.dart';

class SleepLogTile extends StatelessWidget {
  const SleepLogTile({required this.log, required this.onDelete, super.key});

  final SleepLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final materialLocalizations = context.materialLocalizations;
    final duration = log.duration;
    final qualityRating = log.qualityRating;
    return VTCard(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: .center,
            decoration: BoxDecoration(color: VTColors.sleep.withValues(alpha: 0.16), shape: .circle),
            child: const Icon(Icons.bedtime_rounded, color: VTColors.sleep, size: 20),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(l10n.sleepDurationLabel(duration.inHours, duration.inMinutes.remainder(60)), style: VTTextStyles.bodyStrong(context))),
                    if (log.source == SleepLogSource.health) ...[const VTGap.s(), VTBadge(label: l10n.sleepSourceHealth, color: VTColors.sleep)],
                  ],
                ),
                const VTGap.xs(),
                Text(
                  '${materialLocalizations.formatShortDate(log.bedTime)} · '
                  '${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(log.bedTime))} → '
                  '${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(log.wakeTime))}',
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (qualityRating != null) ...[
                  const VTGap.s(),
                  Row(
                    children: [
                      for (var index = 0; index < 5; index++)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(index < qualityRating ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: VTColors.sleep),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const VTGap.s(),
          InkResponse(
            onTap: onDelete,
            radius: 20,
            child: Tooltip(
              message: l10n.sleepDeleteLogTooltip,
              child: Padding(
                padding: const EdgeInsets.all(VTSpacing.xs),
                child: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
