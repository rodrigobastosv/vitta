import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';

Future<ImagePickerSource?> showImageSourceSheet({required BuildContext context}) =>
    showModalBottomSheet<ImagePickerSource>(context: context, builder: (sheetContext) => const VTImageSourceSheet());

class VTImageSourceSheet extends StatelessWidget {
  const VTImageSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.takePhotoAction),
            onTap: () => Navigator.of(context).pop(ImagePickerSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.chooseFromGalleryAction),
            onTap: () => Navigator.of(context).pop(ImagePickerSource.gallery),
          ),
        ],
      ),
    );
  }
}
