import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

class CreateProgressPhotoRequest {
  CreateProgressPhotoRequest({required this.userId, required this.takenDate, required this.storagePath, required this.pose, this.note});

  final String userId;
  final DateTime takenDate;
  final String storagePath;
  final ProgressPhotoPose pose;
  final String? note;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'taken_date': takenDate.toIso8601String().split('T').first,
    'storage_path': storagePath,
    'pose': pose.wireValue,
    'note': note,
  };
}
