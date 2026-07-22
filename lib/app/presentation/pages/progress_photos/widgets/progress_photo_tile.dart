import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class ProgressPhotoTile extends StatelessWidget {
  const ProgressPhotoTile({required this.photo, required this.onTap, super.key});

  final ProgressPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: VTRadius.borderRadiusM,
    child: Stack(
      fit: .expand,
      children: [
        VTRemoteImage(
          imageUrl: photo.imageUrl,
          cacheKey: photo.storagePath,
          placeholderIcon: Icons.photo_camera_outlined,
          borderRadius: VTRadius.borderRadiusM,
          width: double.infinity,
          height: double.infinity,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(VTRadius.m)),
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.xs, vertical: VTSpacing.xs),
              child: Text(
                context.materialLocalizations.formatShortDate(photo.takenDate),
                style: VTTextStyles.caption(context).copyWith(color: Colors.white, fontWeight: .w600),
                maxLines: 1,
                overflow: .ellipsis,
                textAlign: .center,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
