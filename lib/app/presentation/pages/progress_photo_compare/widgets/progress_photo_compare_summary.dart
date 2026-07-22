import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class ProgressPhotoCompareSummary extends StatelessWidget {
  const ProgressPhotoCompareSummary({required this.before, required this.after, super.key});

  final ProgressPhoto before;
  final ProgressPhoto after;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final daysApart = after.takenDate.difference(before.takenDate).inDays.abs();
    final notes = [?before.note, ?after.note];
    return VTCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: .center,
            decoration: const BoxDecoration(color: VTColors.green, shape: .circle),
            child: Icon(Icons.timeline_outlined, color: VTColors.inkOn(VTColors.green), size: 22),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.progressPhotosCompareDaysApart(daysApart), style: VTTextStyles.title(context)),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: VTSpacing.xs),
                  Text(notes.join(' · '), style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
