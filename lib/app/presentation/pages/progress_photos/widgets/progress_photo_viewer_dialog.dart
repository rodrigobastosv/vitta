import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_pose_labels.dart';

Future<void> showProgressPhotoViewer({required BuildContext context, required ProgressPhoto photo}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => BlocProvider.value(
    value: context.read<ProgressPhotosCubit>(),
    child: ProgressPhotoViewerDialog(photo: photo),
  ),
);

class ProgressPhotoViewerDialog extends StatelessWidget {
  const ProgressPhotoViewerDialog({required this.photo, super.key});

  final ProgressPhoto photo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(VTSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Flexible(
              child: InteractiveViewer(
                child: VTRemoteImage(
                  imageUrl: photo.imageUrl,
                  cacheKey: photo.storagePath,
                  placeholderIcon: Icons.photo_camera_outlined,
                  borderRadius: VTRadius.borderRadiusM,
                  width: double.infinity,
                  height: 420,
                ),
              ),
            ),
            const VTGap.m(),
            Row(
              children: [
                Expanded(
                  child: Text(context.materialLocalizations.formatFullDate(photo.takenDate), style: VTTextStyles.title(context)),
                ),
                const VTGap.s(),
                VTBadge(label: photo.pose.label(l10n), color: colorScheme.primary),
              ],
            ),
            if (photo.note case final note?) ...[
              const VTGap.xs(),
              Text(note, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
            ],
            const VTGap.m(),
            Row(
              mainAxisAlignment: .end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.read<ProgressPhotosCubit>().deletePhoto(photo: photo);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.progressPhotosDeleteAction),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.progressPhotosCloseAction)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
