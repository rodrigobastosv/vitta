import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class ProgressPhotoCompareSlot extends StatelessWidget {
  const ProgressPhotoCompareSlot({required this.label, required this.photo, required this.onTap, super.key});

  static const double _photoHeight = 320;

  final String label;
  final ProgressPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: VTTextStyles.overline(context)),
        const VTGap.xs(),
        InkWell(
          onTap: onTap,
          borderRadius: VTRadius.borderRadiusM,
          child: VTRemoteImage(
            imageUrl: photo.imageUrl,
            cacheKey: photo.storagePath,
            placeholderIcon: Icons.photo_camera_outlined,
            borderRadius: VTRadius.borderRadiusM,
            width: double.infinity,
            height: _photoHeight,
          ),
        ),
        const VTGap.xs(),
        Text(
          context.materialLocalizations.formatShortDate(photo.takenDate),
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
