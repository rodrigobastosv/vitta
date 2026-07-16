import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';

class UploadAvatarUseCase {
  UploadAvatarUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Future<Result<VTError, String>> call({required Uint8List bytes, required String fileExtension}) =>
      _authRepository.uploadAvatar(bytes: bytes, fileExtension: fileExtension);
}
