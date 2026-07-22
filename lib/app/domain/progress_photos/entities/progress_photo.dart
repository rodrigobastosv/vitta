import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

class ProgressPhoto extends Equatable {
  const ProgressPhoto({
    required this.id,
    required this.takenDate,
    required this.storagePath,
    required this.pose,
    required this.createdAt,
    this.note,
    this.imageUrl,
  });

  factory ProgressPhoto.fromMap(Map<String, dynamic> row) => ProgressPhoto(
    id: row['id'] as String,
    takenDate: DateTime.parse(row['taken_date'] as String),
    storagePath: row['storage_path'] as String,
    pose: ProgressPhotoPose.fromWireValue(row['pose'] as String?),
    note: row['note'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );

  final String id;
  final DateTime takenDate;
  final String storagePath;
  final ProgressPhotoPose pose;
  final String? note;
  final DateTime createdAt;

  final String? imageUrl;

  DateTime get takenDay => DateTime(takenDate.year, takenDate.month, takenDate.day);

  ProgressPhoto withImageUrl(String? imageUrl) => ProgressPhoto(
    id: id,
    takenDate: takenDate,
    storagePath: storagePath,
    pose: pose,
    note: note,
    createdAt: createdAt,
    imageUrl: imageUrl,
  );

  @override
  List<Object?> get props => [id, takenDate, storagePath, pose, note, createdAt];
}
