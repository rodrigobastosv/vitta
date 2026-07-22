import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_tile.dart';

Future<ProgressPhoto?> showProgressPhotoPickerSheet({required BuildContext context, required List<ProgressPhoto> photos}) =>
    showModalBottomSheet<ProgressPhoto>(
      context: context,
      routeSettings: VTBottomSheet.progressPhotoPicker.settings,
      isScrollControlled: true,
      builder: (sheetContext) => ProgressPhotoPickerSheet(photos: photos),
    );

class ProgressPhotoPickerSheet extends StatelessWidget {
  const ProgressPhotoPickerSheet({required this.photos, super.key});

  static const _columns = 3;

  final List<ProgressPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(l10n.progressPhotosPickerTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            Flexible(
              child: GridView.count(
                crossAxisCount: _columns,
                shrinkWrap: true,
                mainAxisSpacing: VTSpacing.s,
                crossAxisSpacing: VTSpacing.s,
                childAspectRatio: 0.8,
                children: [for (final photo in photos) ProgressPhotoTile(photo: photo, onTap: () => Navigator.of(context).pop(photo))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
