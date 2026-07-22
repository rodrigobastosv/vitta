import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

abstract class ProgressPhotoFactory {
  static ProgressPhoto build({
    String id = 'photo-1',
    DateTime? takenDate,
    String storagePath = 'user-1/1.jpg',
    ProgressPhotoPose pose = ProgressPhotoPose.front,
    String? note,
    DateTime? createdAt,
    String? imageUrl = 'https://example.com/signed/1.jpg',
  }) => ProgressPhoto(
    id: id,
    takenDate: takenDate ?? DateTime(2026, 7, 18),
    storagePath: storagePath,
    pose: pose,
    note: note,
    createdAt: createdAt ?? DateTime(2026, 7, 18, 8),
    imageUrl: imageUrl,
  );
}
