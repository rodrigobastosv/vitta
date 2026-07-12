import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SleepLogTile extends StatelessWidget {
  const SleepLogTile({required this.log, required this.onDelete, super.key});

  final SleepLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);
    final duration = log.duration;
    final qualityRating = log.qualityRating;
    return VTCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  l10n.sleepDurationLabel(duration.inHours, duration.inMinutes.remainder(60)),
                  style: VTTextStyles.bodyStrong(context),
                ),
                const VTGap.xs(),
                Text(
                  '${materialLocalizations.formatShortDate(log.bedTime)} ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(log.bedTime))} '
                  '→ ${materialLocalizations.formatShortDate(log.wakeTime)} ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(log.wakeTime))}',
                  style: VTTextStyles.caption(context).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (qualityRating != null) ...[
                  const VTGap.xs(),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < qualityRating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.sleepDeleteLogTooltip, onPressed: onDelete),
        ],
      ),
    );
  }
}
