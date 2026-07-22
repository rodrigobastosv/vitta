import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_compare_slot.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_compare_summary.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_picker_sheet.dart';

class ProgressPhotoComparePage extends StatefulWidget {
  const ProgressPhotoComparePage({required this.photos, super.key});

  final List<ProgressPhoto> photos;

  @override
  State<ProgressPhotoComparePage> createState() => _ProgressPhotoComparePageState();
}

class _ProgressPhotoComparePageState extends State<ProgressPhotoComparePage> {
  late ProgressPhoto _before = widget.photos.last;
  late ProgressPhoto _after = widget.photos.first;

  Future<void> _pickBefore() async {
    final picked = await showProgressPhotoPickerSheet(context: context, photos: widget.photos);
    if (picked != null && mounted) {
      setState(() => _before = picked);
    }
  }

  Future<void> _pickAfter() async {
    final picked = await showProgressPhotoPickerSheet(context: context, photos: widget.photos);
    if (picked != null && mounted) {
      setState(() => _after = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressPhotosCompareTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: ProgressPhotoCompareSlot(label: l10n.progressPhotosCompareBefore, photo: _before, onTap: _pickBefore),
                ),
                const VTGap.m(),
                Expanded(
                  child: ProgressPhotoCompareSlot(label: l10n.progressPhotosCompareAfter, photo: _after, onTap: _pickAfter),
                ),
              ],
            ),
            const VTGap.l(),
            ProgressPhotoCompareSummary(before: _before, after: _after),
          ],
        ),
      ),
    );
  }
}
