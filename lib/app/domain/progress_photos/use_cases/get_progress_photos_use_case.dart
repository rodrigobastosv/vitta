import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/progress_photos/progress_photos_repository.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class GetProgressPhotosUseCase {
  GetProgressPhotosUseCase({required this._progressPhotosRepository});

  final ProgressPhotosRepository _progressPhotosRepository;

  Future<Result<VTError, List<ProgressPhoto>>> call() => _progressPhotosRepository.getPhotos();
}
