import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_month.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_tile.dart';

class ProgressPhotoMonthSection extends StatelessWidget {
  const ProgressPhotoMonthSection({required this.section, required this.onPhotoTap, super.key});

  static const _columns = 3;

  final ProgressPhotoMonth section;
  final void Function(ProgressPhoto photo) onPhotoTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      Text(context.materialLocalizations.formatMonthYear(section.month), style: VTTextStyles.overline(context)),
      const VTGap.s(),
      GridView.count(
        crossAxisCount: _columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: VTSpacing.s,
        crossAxisSpacing: VTSpacing.s,
        childAspectRatio: 0.8,
        children: [for (final photo in section.photos) ProgressPhotoTile(photo: photo, onTap: () => onPhotoTap(photo))],
      ),
    ],
  );
}
