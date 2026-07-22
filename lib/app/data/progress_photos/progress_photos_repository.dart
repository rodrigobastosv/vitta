import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/progress_photos/datasources/supabase/supabase_progress_photos_datasource.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

class ProgressPhotosRepository {
  ProgressPhotosRepository({required this._supabaseProgressPhotosDataSource});

  final SupabaseProgressPhotosDataSource _supabaseProgressPhotosDataSource;

  Future<Result<VTError, List<ProgressPhoto>>> getPhotos() => _supabaseProgressPhotosDataSource.getPhotos();

  Future<Result<VTError, String>> uploadPhoto({required Uint8List bytes, required String fileExtension}) =>
      _supabaseProgressPhotosDataSource.uploadPhoto(bytes: bytes, fileExtension: fileExtension);

  Future<Result<VTError, ProgressPhoto>> createPhoto({
    required String storagePath,
    required DateTime takenDate,
    required ProgressPhotoPose pose,
    String? note,
  }) => _supabaseProgressPhotosDataSource.createPhoto(storagePath: storagePath, takenDate: takenDate, pose: pose, note: note);

  Future<Result<VTError, void>> deletePhoto({required String photoId, required String storagePath}) =>
      _supabaseProgressPhotosDataSource.deletePhoto(photoId: photoId, storagePath: storagePath);
}
