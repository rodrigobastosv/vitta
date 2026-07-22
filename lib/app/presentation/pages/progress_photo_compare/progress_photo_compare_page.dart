import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_compare_slot.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_compare_summary.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_picker_sheet.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_pose_selector.dart';

class ProgressPhotoComparePage extends StatefulWidget {
  const ProgressPhotoComparePage({required this.photos, super.key});

  final List<ProgressPhoto> photos;

  @override
  State<ProgressPhotoComparePage> createState() => _ProgressPhotoComparePageState();
}

class _ProgressPhotoComparePageState extends State<ProgressPhotoComparePage> {
  late ProgressPhotoPose _pose = _defaultPose;
  late ProgressPhoto _before = _posePhotos.last;
  late ProgressPhoto _after = _posePhotos.first;

  List<ProgressPhotoPose> get _poses => [
    for (final pose in ProgressPhotoPose.values)
      if (widget.photos.any((photo) => photo.pose == pose)) pose,
  ];

  ProgressPhotoPose get _defaultPose => _poses.reduce((best, pose) => _countOf(pose) > _countOf(best) ? pose : best);

  int _countOf(ProgressPhotoPose pose) => widget.photos.where((photo) => photo.pose == pose).length;

  List<ProgressPhoto> get _posePhotos => [
    for (final photo in widget.photos)
      if (photo.pose == _pose) photo,
  ];

  void _selectPose(ProgressPhotoPose pose) => setState(() {
    _pose = pose;
    _before = _posePhotos.last;
    _after = _posePhotos.first;
  });

  Future<void> _pickBefore() async {
    final picked = await showProgressPhotoPickerSheet(context: context, photos: _posePhotos);
    if (picked != null && mounted) {
      setState(() => _before = picked);
    }
  }

  Future<void> _pickAfter() async {
    final picked = await showProgressPhotoPickerSheet(context: context, photos: _posePhotos);
    if (picked != null && mounted) {
      setState(() => _after = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressPhotosCompareTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ProgressPhotoPoseSelector(poses: _poses, selected: _pose, onSelected: _selectPose),
            const VTGap.l(),
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
            if (_posePhotos.length > 1)
              ProgressPhotoCompareSummary(before: _before, after: _after)
            else
              Text(
                l10n.progressPhotosComparePoseEmpty,
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
