import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_pose_selector.dart';

Future<void> showAddProgressPhotoSheet({required BuildContext context, required PickedImage pickedImage}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.addProgressPhoto.settings,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(
    value: context.read<ProgressPhotosCubit>(),
    child: AddProgressPhotoSheet(pickedImage: pickedImage),
  ),
);

class AddProgressPhotoSheet extends StatefulWidget {
  const AddProgressPhotoSheet({required this.pickedImage, super.key});

  final PickedImage pickedImage;

  @override
  State<AddProgressPhotoSheet> createState() => _AddProgressPhotoSheetState();
}

class _AddProgressPhotoSheetState extends State<AddProgressPhotoSheet> {
  static const double _previewHeight = 220;

  final TextEditingController _noteController = TextEditingController();
  DateTime _takenDate = DateTime.now();
  ProgressPhotoPose _pose = ProgressPhotoPose.front;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _takenDate = picked);
    }
  }

  Future<void> _submit() async {
    final cubit = context.read<ProgressPhotosCubit>();
    final note = _noteController.text.trim();
    Navigator.of(context).pop();
    await cubit.addPhoto(
      bytes: widget.pickedImage.bytes,
      fileExtension: widget.pickedImage.fileExtension,
      takenDate: DateTime(_takenDate.year, _takenDate.month, _takenDate.day),
      pose: _pose,
      note: note.isEmpty ? null : note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(l10n.progressPhotosAddAction, style: VTTextStyles.title(context)),
            const VTGap.m(),
            ClipRRect(
              borderRadius: VTRadius.borderRadiusM,
              child: Image.memory(widget.pickedImage.bytes, height: _previewHeight, width: double.infinity, fit: .cover),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.progressPhotosDateLabel),
              subtitle: Text(context.materialLocalizations.formatShortDate(_takenDate)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickDate,
            ),
            ProgressPhotoPoseSelector(
              poses: ProgressPhotoPose.values,
              selected: _pose,
              hint: l10n.progressPhotosPoseHint,
              onSelected: (pose) => setState(() => _pose = pose),
            ),
            const VTGap.m(),
            VTTextField(
              controller: _noteController,
              label: l10n.progressPhotosNoteLabel,
              prefixIcon: Icons.notes_outlined,
              textCapitalization: .sentences,
            ),
            const VTGap.m(),
            Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: context.colorScheme.onSurfaceVariant),
                const VTGap.xs(),
                Expanded(
                  child: Text(
                    l10n.progressPhotosPrivacyHint,
                    style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const VTGap.l(),
            VTPrimaryButton(label: l10n.progressPhotosSaveAction, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
