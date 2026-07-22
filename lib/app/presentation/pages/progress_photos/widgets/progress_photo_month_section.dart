import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_month.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_day_section.dart';

class ProgressPhotoMonthSection extends StatelessWidget {
  const ProgressPhotoMonthSection({required this.section, required this.onPhotoTap, super.key});

  final ProgressPhotoMonth section;
  final void Function(ProgressPhoto photo) onPhotoTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      Text(context.materialLocalizations.formatMonthYear(section.month), style: VTTextStyles.overline(context)),
      const VTGap.s(),
      for (final day in section.days) ...[ProgressPhotoDaySection(day: day, onPhotoTap: onPhotoTap), const VTGap.m()],
    ],
  );
}
