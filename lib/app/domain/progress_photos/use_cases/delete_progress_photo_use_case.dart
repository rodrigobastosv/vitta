import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/progress_photos/progress_photos_repository.dart';

class DeleteProgressPhotoUseCase {
  DeleteProgressPhotoUseCase({required this._progressPhotosRepository});

  final ProgressPhotosRepository _progressPhotosRepository;

  Future<Result<VTError, void>> call({required String photoId, required String storagePath}) =>
      _progressPhotosRepository.deletePhoto(photoId: photoId, storagePath: storagePath);
}
