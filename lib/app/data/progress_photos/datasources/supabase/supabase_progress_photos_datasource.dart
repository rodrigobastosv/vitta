import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/progress_photos/datasources/supabase/requests/create_progress_photo_request.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';

class SupabaseProgressPhotosDataSource {
  SupabaseProgressPhotosDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  static const _signedUrlTtlSeconds = 3600;

  Future<Result<VTError, List<ProgressPhoto>>> getPhotos() async {
    try {
      final rows = await _supabaseService
          .from(.progressPhotos)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .order('taken_date', ascending: false)
          .order('created_at', ascending: false);
      final photos = rows.map(ProgressPhoto.fromMap).toList();
      final urlsByPath = await _signedUrlsFor(photos.map((photo) => photo.storagePath).toList());
      return Success([for (final photo in photos) photo.withImageUrl(urlsByPath[photo.storagePath])]);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load progress photos', cause: error));
    }
  }

  Future<Result<VTError, String>> uploadPhoto({required Uint8List bytes, required String fileExtension}) async {
    try {
      final path = '${_supabaseService.currentUserId}/${DateTime.now().microsecondsSinceEpoch}.$fileExtension';
      await _supabaseService.storage(.progressPhotos).uploadBinary(path, bytes);
      return Success(path);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to upload progress photo', cause: error));
    }
  }

  Future<Result<VTError, ProgressPhoto>> createPhoto({
    required String storagePath,
    required DateTime takenDate,
    required ProgressPhotoPose pose,
    String? note,
  }) async {
    try {
      final request = CreateProgressPhotoRequest(
        userId: _supabaseService.currentUserId,
        takenDate: takenDate,
        storagePath: storagePath,
        pose: pose,
        note: note,
      );
      final row = await _supabaseService.from(.progressPhotos).insert(request.toJson()).select().single();
      final photo = ProgressPhoto.fromMap(row);
      final urlsByPath = await _signedUrlsFor([photo.storagePath]);
      return Success(photo.withImageUrl(urlsByPath[photo.storagePath]));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to save progress photo', cause: error));
    }
  }

  Future<Result<VTError, void>> deletePhoto({required String photoId, required String storagePath}) async {
    try {
      await _supabaseService.from(.progressPhotos).delete().eq('id', photoId).eq('user_id', _supabaseService.currentUserId);
      await _supabaseService.storage(.progressPhotos).remove([storagePath]);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete progress photo $photoId', cause: error));
    }
  }

  Future<Map<String, String>> _signedUrlsFor(List<String> paths) async {
    if (paths.isEmpty) {
      return const {};
    }
    final signedUrls = await _supabaseService.storage(.progressPhotos).createSignedUrlsResult(paths, _signedUrlTtlSeconds);
    return {for (final signedUrl in signedUrls.whereType<SignedUrlSuccess>()) signedUrl.path: signedUrl.signedUrl};
  }
}
