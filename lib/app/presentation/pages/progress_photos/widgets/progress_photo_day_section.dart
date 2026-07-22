import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_day.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_tile.dart';

class ProgressPhotoDaySection extends StatelessWidget {
  const ProgressPhotoDaySection({required this.day, required this.onPhotoTap, super.key});

  static const _columns = 3;

  final ProgressPhotoDay day;
  final void Function(ProgressPhoto photo) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Text(context.materialLocalizations.formatMediumDate(day.day), style: VTTextStyles.bodyStrong(context)),
            const VTGap.s(),
            Text(
              l10n.progressPhotosDayPhotoCount(day.photos.length),
              style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const VTGap.s(),
        GridView.count(
          crossAxisCount: _columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: VTSpacing.s,
          crossAxisSpacing: VTSpacing.s,
          childAspectRatio: 0.8,
          children: [
            for (final photo in day.photos) ProgressPhotoTile(photo: photo, showDate: false, onTap: () => onPhotoTap(photo)),
          ],
        ),
      ],
    );
  }
}
