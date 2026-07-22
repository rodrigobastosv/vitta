import 'package:equatable/equatable.dart';

class ProgressPhoto extends Equatable {
  const ProgressPhoto({
    required this.id,
    required this.takenDate,
    required this.storagePath,
    required this.createdAt,
    this.note,
    this.imageUrl,
  });

  factory ProgressPhoto.fromMap(Map<String, dynamic> row) => ProgressPhoto(
    id: row['id'] as String,
    takenDate: DateTime.parse(row['taken_date'] as String),
    storagePath: row['storage_path'] as String,
    note: row['note'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );

  final String id;
  final DateTime takenDate;
  final String storagePath;
  final String? note;
  final DateTime createdAt;

  final String? imageUrl;

  ProgressPhoto withImageUrl(String? imageUrl) =>
      ProgressPhoto(id: id, takenDate: takenDate, storagePath: storagePath, note: note, createdAt: createdAt, imageUrl: imageUrl);

  @override
  List<Object?> get props => [id, takenDate, storagePath, note, createdAt];
}
