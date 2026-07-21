import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class SleepSyncStatusCard extends StatelessWidget {
  const SleepSyncStatusCard({required this.lastSyncedAt, required this.onSync, super.key});

  final DateTime lastSyncedAt;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    final when = '${materialLocalizations.formatShortDate(lastSyncedAt)} · ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(lastSyncedAt))}';
    return VTCard(
      onTap: onSync,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: .center,
            decoration: BoxDecoration(color: VTColors.sleep.withValues(alpha: 0.16), shape: .circle),
            child: const Icon(Icons.favorite_rounded, color: VTColors.sleep, size: 20),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.sleepSyncStatusTitle, style: VTTextStyles.bodyStrong(context)),
                Text(l10n.sleepLastSyncedLabel(when), style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const VTGap.s(),
          Icon(Icons.sync_rounded, size: 20, color: context.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
