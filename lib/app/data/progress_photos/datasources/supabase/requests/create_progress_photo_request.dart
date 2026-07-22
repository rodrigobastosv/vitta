class CreateProgressPhotoRequest {
  CreateProgressPhotoRequest({required this.userId, required this.takenDate, required this.storagePath, this.note});

  final String userId;
  final DateTime takenDate;
  final String storagePath;
  final String? note;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'taken_date': takenDate.toIso8601String().split('T').first,
    'storage_path': storagePath,
    'note': note,
  };
}
