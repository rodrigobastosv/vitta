import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/progress_photos/progress_photos_repository.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

class AddProgressPhotoUseCase {
  AddProgressPhotoUseCase({required this._progressPhotosRepository});

  final ProgressPhotosRepository _progressPhotosRepository;

  Future<Result<VTError, ProgressPhoto>> call({
    required Uint8List bytes,
    required String fileExtension,
    required DateTime takenDate,
    required ProgressPhotoPose pose,
    String? note,
  }) async {
    final uploadedResult = await _progressPhotosRepository.uploadPhoto(bytes: bytes, fileExtension: fileExtension);
    return uploadedResult.when(
      (error) => Future.value(Failure(error)),
      (value) => _progressPhotosRepository.createPhoto(storagePath: value, takenDate: takenDate, pose: pose, note: note),
    );
  }
}
